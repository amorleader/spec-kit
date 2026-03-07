#!/usr/bin/env pwsh

param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [switch]$IncludeDocsOnly,
    [ValidateRange(1, 86400)]
    [int]$PerScriptTimeoutSec = 300,
    [ValidateRange(1, 500)]
    [int]$MaxScriptsPerRun = 8,
    [ValidateRange(1, 200)]
    [int]$MaxConcurrentPowerShellProcesses = 20,
    [ValidateRange(5, 3600)]
    [int]$ProcessBudgetWaitSec = 120,
    [ValidateRange(0, 86400)]
    [int]$NoOutputTimeoutSec = 180,
    [string]$StateFile = (Join-Path $PSScriptRoot '.quality_resume_state.json'),
    [switch]$ResetState,
    [switch]$ContinueOnFailure,
    [switch]$RetryFailures
)

$ErrorActionPreference = 'Stop'

function Get-TestPowerShellProcesses {
    $pattern = 'tests\\run_all_quality_checks(_resume)?\.ps1|tests\\run_all_quality_checks_.*_regression\.ps1'
    Get-CimInstance Win32_Process |
        Where-Object {
            ($_.Name -ieq 'powershell.exe' -or $_.Name -ieq 'pwsh.exe') -and
            -not [string]::IsNullOrWhiteSpace($_.CommandLine) -and
            ($_.CommandLine -match $pattern)
        }
}

function Get-ScriptPathFromCommandLine {
    param([string]$CommandLine)

    if ([string]::IsNullOrWhiteSpace($CommandLine)) {
        return $null
    }

    $m = [regex]::Match($CommandLine, '-File\s+"([^"]+)"')
    if ($m.Success) { return $m.Groups[1].Value }

    $m = [regex]::Match($CommandLine, "-File\s+'([^']+)'")
    if ($m.Success) { return $m.Groups[1].Value }

    $m = [regex]::Match($CommandLine, '-File\s+([^\s]+)')
    if ($m.Success) { return $m.Groups[1].Value.Trim('"') }

    return $null
}

function Remove-InvalidTestPowerShellProcesses {
    param([int]$ExcludePid)

    $killed = @()
    $procs = @(Get-TestPowerShellProcesses)

    foreach ($p in $procs) {
        if ($p.ProcessId -eq $ExcludePid) {
            continue
        }

        $invalid = $false
        if ([string]::IsNullOrWhiteSpace($p.CommandLine)) {
            $invalid = $true
        } else {
            $scriptPath = Get-ScriptPathFromCommandLine -CommandLine $p.CommandLine
            if (-not [string]::IsNullOrWhiteSpace($scriptPath) -and -not (Test-Path $scriptPath)) {
                $invalid = $true
            }
        }

        if ($invalid) {
            try {
                Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
                $killed += $p.ProcessId
            } catch {
            }
        }
    }

    return @($killed)
}

function Wait-ForProcessBudget {
    param(
        [int]$MaxProcesses,
        [int]$WaitSec,
        [int]$ExcludePid
    )

    $deadline = (Get-Date).AddSeconds($WaitSec)
    while ($true) {
        $killed = @(Remove-InvalidTestPowerShellProcesses -ExcludePid $ExcludePid)
        if ($killed.Count -gt 0) {
            Write-Output ("run_all_quality_checks_resume: cleaned_invalid_processes=" + ($killed -join ','))
        }

        $active = @((Get-TestPowerShellProcesses) | Where-Object { $_.ProcessId -ne $ExcludePid })
        if ($active.Count -lt $MaxProcesses) {
            return
        }

        if ((Get-Date) -ge $deadline) {
            throw ("run_all_quality_checks_resume: process budget exceeded (active=" + $active.Count + ", max=" + $MaxProcesses + ")")
        }

        Write-Output ("run_all_quality_checks_resume: waiting_for_budget active=" + $active.Count + " max=" + $MaxProcesses)
        Start-Sleep -Milliseconds 1000
    }
}

function Get-TestScriptList {
    param(
        [string]$TestsDir,
        [bool]$DocsOnly
    )

    $docChecks = Get-ChildItem -Path $TestsDir -Filter 'validate_*_docs.ps1' |
        Sort-Object Name |
        ForEach-Object { $_.FullName }

    if ($DocsOnly) {
        return @($docChecks)
    }

    $regressions = Get-ChildItem -Path $TestsDir -Filter '*_regression.ps1' |
        Sort-Object Name |
        ForEach-Object { $_.FullName }

    return @($regressions + $docChecks)
}

function Read-ResumeState {
    param(
        [string]$Path,
        [string[]]$AllScripts,
        [bool]$Reset
    )

    if ($Reset -or -not (Test-Path $Path)) {
        return [ordered]@{
            completed = @{}
            runOrder = @()
            failures = @()
            createdAtUtc = (Get-Date).ToUniversalTime().ToString('o')
            updatedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
        }
    }

    try {
        $raw = Get-Content -Path $Path -Raw
        $parsed = $raw | ConvertFrom-Json

        $obj = [ordered]@{
            completed = @{}
            runOrder = @()
            failures = @()
            createdAtUtc = (Get-Date).ToUniversalTime().ToString('o')
            updatedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
        }

        if ($null -ne $parsed.createdAtUtc) { $obj.createdAtUtc = $parsed.createdAtUtc }
        if ($null -ne $parsed.updatedAtUtc) { $obj.updatedAtUtc = $parsed.updatedAtUtc }
        if ($null -ne $parsed.runOrder) { $obj.runOrder = @($parsed.runOrder) }
        if ($null -ne $parsed.failures) { $obj.failures = @($parsed.failures) }

        $parsedCompleted = $parsed.completed
        if ($null -ne $parsedCompleted) {
            $completedNames = @($parsedCompleted | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name)
            foreach ($name in $completedNames) {
                $obj.completed[$name] = $parsedCompleted.$name
            }
        }

        $valid = @{}
        foreach ($script in $AllScripts) {
            if ($obj.completed.ContainsKey($script)) {
                $valid[$script] = $obj.completed[$script]
            }
        }
        $obj.completed = $valid
        return $obj
    }
    catch {
        return [ordered]@{
            completed = @{}
            runOrder = @()
            failures = @()
            createdAtUtc = (Get-Date).ToUniversalTime().ToString('o')
            updatedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
        }
    }
}

function Save-ResumeState {
    param(
        [string]$Path,
        [hashtable]$State
    )

    $State.updatedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    $State | ConvertTo-Json -Depth 8 | Set-Content -Path $Path -Encoding UTF8
}

function Get-LatestLogWriteTime {
    param(
        [string]$StdOutLogPath,
        [string]$StdErrLogPath,
        [datetime]$Fallback
    )

    $latest = $Fallback
    foreach ($path in @($StdOutLogPath, $StdErrLogPath)) {
        if ([string]::IsNullOrWhiteSpace($path) -or -not (Test-Path $path)) {
            continue
        }

        try {
            $time = (Get-Item -LiteralPath $path).LastWriteTime
            if ($time -gt $latest) {
                $latest = $time
            }
        } catch {
        }
    }

    return $latest
}

function Invoke-ScriptIsolated {
    param(
        [string]$ScriptPath,
        [int]$TimeoutSec,
        [int]$NoOutputTimeoutSec,
        [string]$StdOutLogPath,
        [string]$StdErrLogPath
    )

    $powerShellExe = (Get-Command powershell -CommandType Application | Select-Object -First 1).Source
    if ([string]::IsNullOrWhiteSpace($powerShellExe)) {
        $powerShellExe = 'powershell'
    }

    $argList = @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', $ScriptPath
    )

    $proc = Start-Process -FilePath $powerShellExe `
        -ArgumentList $argList `
        -RedirectStandardOutput $StdOutLogPath `
        -RedirectStandardError $StdErrLogPath `
        -WindowStyle Hidden `
        -PassThru

    $timedOut = $false
    $timeoutReason = $null
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    $lastOutputAt = Get-Date
    while (-not $proc.HasExited -and (Get-Date) -lt $deadline) {
        $lastOutputAt = Get-LatestLogWriteTime -StdOutLogPath $StdOutLogPath -StdErrLogPath $StdErrLogPath -Fallback $lastOutputAt

        if ($NoOutputTimeoutSec -gt 0 -and ((Get-Date) - $lastOutputAt).TotalSeconds -ge $NoOutputTimeoutSec) {
            $timedOut = $true
            $timeoutReason = 'NO_OUTPUT'
            break
        }

        Start-Sleep -Milliseconds 200
    }
    if (-not $proc.HasExited) {
        $timedOut = $true
        if ([string]::IsNullOrWhiteSpace($timeoutReason)) {
            $timeoutReason = 'WALL_CLOCK'
        }
        try {
            $null = & taskkill /PID $proc.Id /T /F 2>$null
        } catch {}
        if (-not $proc.HasExited) {
            try { Stop-Process -Id $proc.Id -Force } catch {}
        }
    }

    if ($timedOut) {
        $null = $proc.WaitForExit(5000)
    } else {
        $proc.WaitForExit()
    }

    $proc.Refresh()
    $finalExitCode = if ($timedOut) { 124 } elseif ($null -eq $proc.ExitCode) { 0 } else { [int]$proc.ExitCode }

    return [PSCustomObject]@{
        ExitCode = $finalExitCode
        TimedOut = $timedOut
        TimeoutReason = $timeoutReason
    }
}

Push-Location $RepoRoot
try {
    $testsDir = Join-Path $RepoRoot 'tests'
    $allScripts = Get-TestScriptList -TestsDir $testsDir -DocsOnly ([bool]$IncludeDocsOnly)

    if ($allScripts.Count -eq 0) {
        Write-Output 'run_all_quality_checks_resume: NO_SCRIPTS_FOUND'
        exit 1
    }

    $state = Read-ResumeState -Path $StateFile -AllScripts $allScripts -Reset ([bool]$ResetState)

    $pending = @()
    foreach ($script in $allScripts) {
        if (-not $state.completed.ContainsKey($script)) {
            $pending += $script
            continue
        }

        if ($RetryFailures) {
            $entry = $state.completed[$script]
            $status = if ($null -ne $entry -and $null -ne $entry.status) { [string]$entry.status } else { 'PASS' }
            if ($status -ne 'PASS') {
                $pending += $script
            }
        }
    }

    if ($pending.Count -eq 0) {
        Write-Output 'run_all_quality_checks_resume: ALL_SCRIPTS_ALREADY_COMPLETED'
        Write-Output ("state_file: " + $StateFile)
        exit 0
    }

    $batch = @($pending | Select-Object -First $MaxScriptsPerRun)
    $logsDir = Join-Path $testsDir '.quality_logs'
    if (-not (Test-Path $logsDir)) {
        New-Item -ItemType Directory -Path $logsDir | Out-Null
    }

    $runFailed = $false

    foreach ($script in $batch) {
        Wait-ForProcessBudget -MaxProcesses $MaxConcurrentPowerShellProcesses -WaitSec $ProcessBudgetWaitSec -ExcludePid $PID

        $name = Split-Path $script -Leaf
        $safeName = ($name -replace '[^a-zA-Z0-9._-]', '_')
        $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
        $stdoutLogPath = Join-Path $logsDir ("$safeName.$stamp.out.log")
        $stderrLogPath = Join-Path $logsDir ("$safeName.$stamp.err.log")

        Write-Output ("--- RUN " + $name + " ---")
        $result = Invoke-ScriptIsolated -ScriptPath $script -TimeoutSec $PerScriptTimeoutSec -NoOutputTimeoutSec $NoOutputTimeoutSec -StdOutLogPath $stdoutLogPath -StdErrLogPath $stderrLogPath

        $status = if ($result.ExitCode -eq 0) { 'PASS' } elseif ($result.TimedOut) { 'TIMEOUT' } else { 'FAIL' }
        $entry = [ordered]@{
            script = $script
            name = $name
            exitCode = $result.ExitCode
            status = $status
            timeoutReason = $result.TimeoutReason
            stdoutLog = $stdoutLogPath
            stderrLog = $stderrLogPath
            completedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
        }

        $state.completed[$script] = $entry
        $state.runOrder += $script
        $state.failures = @($state.completed.Values | Where-Object { $_.status -ne 'PASS' })
        if ($status -ne 'PASS') { $runFailed = $true }
        Save-ResumeState -Path $StateFile -State $state

        if ($result.TimedOut -and -not [string]::IsNullOrWhiteSpace($result.TimeoutReason)) {
            Write-Output ("--- " + $status + " " + $name + " (exit=" + $result.ExitCode + ", reason=" + $result.TimeoutReason + ") ---")
        } else {
            Write-Output ("--- " + $status + " " + $name + " (exit=" + $result.ExitCode + ") ---")
        }
        Write-Output ("stdout_log: " + $stdoutLogPath)
        Write-Output ("stderr_log: " + $stderrLogPath)

        $postKilled = @(Remove-InvalidTestPowerShellProcesses -ExcludePid $PID)
        if ($postKilled.Count -gt 0) {
            Write-Output ("run_all_quality_checks_resume: post_task_cleaned_invalid_processes=" + ($postKilled -join ','))
        }

        if ($status -ne 'PASS' -and -not $ContinueOnFailure) {
            Write-Output 'run_all_quality_checks_resume: STOP_ON_FIRST_FAILURE'
            break
        }
    }

    $doneCount = $state.completed.Count
    $totalCount = $allScripts.Count
    $remaining = $totalCount - $doneCount
    $failedCount = @($state.completed.Values | Where-Object { $_.status -ne 'PASS' }).Count

    Write-Output ''
    Write-Output 'run_all_quality_checks_resume: SUMMARY'
    Write-Output ("completed: " + $doneCount + "/" + $totalCount)
    Write-Output ("failed_or_timeout: " + $failedCount)
    Write-Output ("remaining: " + $remaining)
    Write-Output ("state_file: " + $StateFile)

    if ($failedCount -gt 0 -or $runFailed) {
        exit 1
    }

    if ($remaining -gt 0) {
        exit 2
    }

    exit 0
}
finally {
    $finalKilled = @(Remove-InvalidTestPowerShellProcesses -ExcludePid $PID)
    if ($finalKilled.Count -gt 0) {
        Write-Output ("run_all_quality_checks_resume: final_cleaned_invalid_processes=" + ($finalKilled -join ','))
    }
    Pop-Location
}
