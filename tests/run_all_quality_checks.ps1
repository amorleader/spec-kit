#!/usr/bin/env pwsh

param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [switch]$IncludeDocsOnly,
    [switch]$Json,
    [ValidateRange(0, 86400)]
    [int]$PerScriptTimeoutSec = 0
)

$ErrorActionPreference = 'Stop'

function Invoke-TestScript {
    param(
        [string]$ScriptPath,
        [int]$TimeoutSec
    )

    $powerShellExe = (Get-Command powershell -CommandType Application | Select-Object -First 1).Source
    if ([string]::IsNullOrWhiteSpace($powerShellExe)) {
        $powerShellExe = 'powershell'
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $powerShellExe
    $psi.Arguments = ('-ExecutionPolicy Bypass -File "' + $ScriptPath + '"')
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi

    try {
        $null = $process.Start()

        $timedOut = $false
        if ($TimeoutSec -gt 0) {
            if (-not $process.WaitForExit($TimeoutSec * 1000)) {
                $timedOut = $true
                try {
                    $process.Kill()
                } catch {
                }
            }
        }

        $process.WaitForExit()

        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        $combined = @()
        if (-not [string]::IsNullOrEmpty($stdout)) {
            $combined += ($stdout -split "`r?`n")
        }
        if (-not [string]::IsNullOrEmpty($stderr)) {
            $combined += ($stderr -split "`r?`n")
        }

        [PSCustomObject]@{
            ExitCode = if ($timedOut) { 124 } else { $process.ExitCode }
            TimedOut = $timedOut
            Output   = @($combined | Where-Object { $_ -ne '' })
        }
    }
    finally {
        $process.Dispose()
    }
}

function Get-WorkspaceSnapshot {
    param([string]$Root)

    $snapshot = [PSCustomObject]@{
        Tracked   = @()
        Untracked = @()
    }

    $gitExe = (Get-Command git -CommandType Application | Select-Object -First 1).Source
    if ([string]::IsNullOrWhiteSpace($gitExe)) {
        return $snapshot
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $gitExe
    $psi.Arguments = ('-C "' + $Root + '" status --porcelain -z')
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi

    try {
        $null = $process.Start()
        $memory = New-Object System.IO.MemoryStream
        $process.StandardOutput.BaseStream.CopyTo($memory)
        $process.WaitForExit()

        if ($process.ExitCode -ne 0) {
            return $snapshot
        }

        $raw = [System.Text.Encoding]::UTF8.GetString($memory.ToArray())
        $tokens = @($raw -split "`0" | Where-Object { -not [string]::IsNullOrEmpty($_) })

        $index = 0
        while ($index -lt $tokens.Count) {
            $entry = $tokens[$index]
            $index++
            if ($entry.Length -lt 4) { continue }

            $code = $entry.Substring(0, 2)
            $path1 = $entry.Substring(3)
            $paths = @($path1)

            $isRenameOrCopy = ($code.Contains('R') -or $code.Contains('C'))
            if ($isRenameOrCopy -and $index -lt $tokens.Count) {
                $path2 = $tokens[$index]
                $index++
                $paths += $path2
            }

            if ($code -eq '??') {
                foreach ($path in $paths) {
                    if (-not [string]::IsNullOrWhiteSpace($path)) {
                        $snapshot.Untracked += $path
                    }
                }
            } else {
                foreach ($path in $paths) {
                    if (-not [string]::IsNullOrWhiteSpace($path)) {
                        $snapshot.Tracked += $path
                    }
                }
            }
        }
    } finally {
        $process.Dispose()
    }

    return $snapshot
}

function Restore-WorkspaceChanges {
    param(
        [string]$Root,
        [object]$Before,
        [object]$After
    )

    $beforeTrackedSet = @{}
    foreach ($path in @($Before.Tracked)) { $beforeTrackedSet[$path] = $true }

    $beforeUntrackedSet = @{}
    foreach ($path in @($Before.Untracked)) { $beforeUntrackedSet[$path] = $true }

    $revertedTracked = @()
    $introducedTrackedCandidates = @()
    foreach ($path in @($After.Tracked)) {
        if (-not $beforeTrackedSet.ContainsKey($path)) {
            $introducedTrackedCandidates += $path
            $previousEap = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            try {
                $null = git -C $Root reset HEAD -- "$path" 2>$null
                $null = git -C $Root checkout -- "$path" 2>$null
                if ($LASTEXITCODE -eq 0) {
                    $revertedTracked += $path
                }
            } finally {
                $ErrorActionPreference = $previousEap
            }
        }
    }

    foreach ($path in @($introducedTrackedCandidates)) {
        if ($beforeUntrackedSet.ContainsKey($path)) {
            continue
        }

        $previousEap = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        $trackedInHead = $false
        try {
            $null = git -C $Root cat-file -e ("HEAD:" + $path) 2>$null
            if ($LASTEXITCODE -eq 0) {
                $trackedInHead = $true
            }
        } finally {
            $ErrorActionPreference = $previousEap
        }

        if ($trackedInHead) {
            continue
        }

        $absolute = Join-Path $Root $path
        if (Test-Path $absolute) {
            Remove-Item -Path $absolute -Force -ErrorAction SilentlyContinue
        }
    }

    $deletedTemp = @()
    foreach ($path in @($After.Untracked)) {
        if ($beforeUntrackedSet.ContainsKey($path)) {
            continue
        }
        if ($path -notmatch '\.bak$' -and $path -notmatch '\.tmp$') {
            continue
        }
        $absolute = Join-Path $Root $path
        if (Test-Path $absolute) {
            Remove-Item -Path $absolute -Force -ErrorAction SilentlyContinue
            if (-not (Test-Path $absolute)) {
                $deletedTemp += $path
            }
        }
    }

    [PSCustomObject]@{
        RevertedTracked = @($revertedTracked)
        DeletedTemp     = @($deletedTemp)
    }
}

Push-Location $RepoRoot
try {
    $originalBranch = $null
    $hasGitRepo = $false
    $previousEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $branchOutput = git rev-parse --abbrev-ref HEAD 2>$null
        if ($LASTEXITCODE -eq 0) {
            $hasGitRepo = $true
            $originalBranch = ($branchOutput | Select-Object -First 1).ToString().Trim()
        }
    } finally {
        $ErrorActionPreference = $previousEap
    }

    $testsDir = Join-Path $RepoRoot 'tests'
    $docChecks = Get-ChildItem -Path $testsDir -Filter 'validate_*_docs.ps1' |
        Sort-Object Name |
        ForEach-Object { $_.FullName }

    if ($IncludeDocsOnly) {
        # Docs-only mode must execute docs validators only.
        $scripts = @($docChecks)
    } else {
        $regressions = Get-ChildItem -Path $testsDir -Filter '*_regression.ps1' |
            Sort-Object Name |
            ForEach-Object { $_.FullName }
        $scripts = @($regressions + $docChecks)
    }
    $results = @()
    $overallExitCode = 0
    $recoveredTrackedChanges = 0
    $deletedTempFiles = 0

    if ($scripts.Count -eq 0) {
        if ($Json) {
            [PSCustomObject][ordered]@{
                TOTAL_SCRIPTS      = 0
                FAILED_SCRIPTS     = 0
                PASSED_SCRIPTS     = 0
                TIMED_OUT_SCRIPTS  = 0
                RECOVERED_TRACKED_CHANGES = 0
                DELETED_TEMP_FILES = 0
                INCLUDE_DOCS_ONLY  = [bool]$IncludeDocsOnly
                PER_SCRIPT_TIMEOUT_SEC = $PerScriptTimeoutSec
                ORIGINAL_BRANCH    = $originalBranch
                RESULTS            = @()
                STATUS             = 'NO_SCRIPTS_FOUND'
            } | ConvertTo-Json -Compress
        } else {
            Write-Output 'run_all_quality_checks: NO_SCRIPTS_FOUND'
        }
        exit 1
    }

    $failures = @()
    $timedOutCount = 0

    foreach ($script in $scripts) {
        $name = Split-Path $script -Leaf
        if (-not $Json) {
            Write-Output "--- RUN $name ---"
        }

        $beforeSnapshot = if ($hasGitRepo) { Get-WorkspaceSnapshot -Root $RepoRoot } else { $null }
        $execution = Invoke-TestScript -ScriptPath $script -TimeoutSec $PerScriptTimeoutSec
        if ($hasGitRepo -and $beforeSnapshot) {
            $afterSnapshot = Get-WorkspaceSnapshot -Root $RepoRoot
            $recovery = Restore-WorkspaceChanges -Root $RepoRoot -Before $beforeSnapshot -After $afterSnapshot
            $recoveredTrackedChanges += @($recovery.RevertedTracked).Count
            $deletedTempFiles += @($recovery.DeletedTemp).Count
            if (-not $Json -and (@($recovery.RevertedTracked).Count -gt 0 -or @($recovery.DeletedTemp).Count -gt 0)) {
                Write-Output ("run_all_quality_checks: workspace recovery for " + $name + " -> reverted=" + @($recovery.RevertedTracked).Count + ", deleted_temp=" + @($recovery.DeletedTemp).Count)
            }
        }

        $output = @($execution.Output)
        $exitCode = $execution.ExitCode
        $timedOut = [bool]$execution.TimedOut

        if ($output -and -not $Json) {
            $normalizedOutput = $output | ForEach-Object { $_.ToString() }
            $normalizedOutput | ForEach-Object { Write-Output $_ }
        }

        $status = 'PASS'
        if ($exitCode -ne 0) {
            if ($timedOut) {
                $timedOutCount++
                $status = 'TIMEOUT'
            } else {
                $status = 'FAIL'
            }
            $failures += [PSCustomObject]@{
                Script   = $name
                ExitCode = $exitCode
                Status   = $status
            }
            if (-not $Json) {
                if ($timedOut) {
                    Write-Output "--- TIMEOUT $name (timeout=${PerScriptTimeoutSec}s) ---"
                } else {
                    Write-Output "--- FAIL $name (exit=$exitCode) ---"
                }
            }
        } else {
            if (-not $Json) {
                Write-Output "--- PASS $name ---"
            }
        }

        $results += [PSCustomObject]@{
            SCRIPT   = $name
            EXIT_CODE = $exitCode
            STATUS   = $status
            TIMED_OUT = $timedOut
        }
    }

    $failedCount = @($results | Where-Object { $_.STATUS -ne 'PASS' }).Count
    $timedOutCount = @($results | Where-Object { $_.STATUS -eq 'TIMEOUT' }).Count
    $passedCount = $results.Count - $failedCount
    $overallExitCode = if ($failedCount -gt 0) { 1 } else { 0 }

    if ($Json) {
        [PSCustomObject][ordered]@{
            TOTAL_SCRIPTS      = $scripts.Count
            FAILED_SCRIPTS     = $failedCount
            PASSED_SCRIPTS     = $passedCount
            TIMED_OUT_SCRIPTS  = $timedOutCount
            RECOVERED_TRACKED_CHANGES = $recoveredTrackedChanges
            DELETED_TEMP_FILES = $deletedTempFiles
            INCLUDE_DOCS_ONLY  = [bool]$IncludeDocsOnly
            PER_SCRIPT_TIMEOUT_SEC = $PerScriptTimeoutSec
            ORIGINAL_BRANCH    = $originalBranch
            RESULTS            = @($results)
            STATUS             = if ($overallExitCode -eq 0) { 'PASSED' } else { 'FAILED' }
        } | ConvertTo-Json -Compress
    } else {
        if ($overallExitCode -ne 0) {
            Write-Output ''
            Write-Output 'run_all_quality_checks: FAILED'
            Write-Output ("timed_out_scripts: " + $timedOutCount)
            Write-Output ("recovered_tracked_changes: " + $recoveredTrackedChanges)
            Write-Output ("deleted_temp_files: " + $deletedTempFiles)
            $failures | ForEach-Object {
                if ($_.Status -eq 'TIMEOUT') {
                    Write-Output ("  - " + $_.Script + " (TIMEOUT, limit=" + $PerScriptTimeoutSec + "s)")
                } else {
                    Write-Output ("  - " + $_.Script + " (exit=" + $_.ExitCode + ")")
                }
            }
        } else {
            Write-Output ''
            Write-Output 'run_all_quality_checks: PASSED'
            Write-Output ("recovered_tracked_changes: " + $recoveredTrackedChanges)
            Write-Output ("deleted_temp_files: " + $deletedTempFiles)
        }
    }

    exit $overallExitCode
}
finally {
    if ($hasGitRepo -and -not [string]::IsNullOrWhiteSpace($originalBranch) -and $originalBranch -ne 'HEAD') {
        $previousEap = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            $currentBranchOutput = git rev-parse --abbrev-ref HEAD 2>$null
            if ($LASTEXITCODE -eq 0) {
                $currentBranch = ($currentBranchOutput | Select-Object -First 1).ToString().Trim()
                if ($currentBranch -ne $originalBranch) {
                    $null = git checkout $originalBranch 2>$null
                    if ($LASTEXITCODE -eq 0) {
                        if (-not $Json) {
                            Write-Output "run_all_quality_checks: restored branch to $originalBranch"
                        }
                    } else {
                        if (-not $Json) {
                            Write-Warning "run_all_quality_checks: failed to restore branch to $originalBranch"
                        }
                    }
                }
            }
        } finally {
            $ErrorActionPreference = $previousEap
        }
    }
    Pop-Location
}
