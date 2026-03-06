#!/usr/bin/env pwsh

param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [switch]$IncludeDocsOnly,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

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

    $regressions = @()
    if (-not $IncludeDocsOnly) {
        $regressions = Get-ChildItem -Path (Join-Path $RepoRoot 'tests') -Filter '*_regression.ps1' |
            Sort-Object Name |
            ForEach-Object { $_.FullName }
    }

    $docChecks = Get-ChildItem -Path (Join-Path $RepoRoot 'tests') -Filter 'validate_*_docs.ps1' |
        Sort-Object Name |
        ForEach-Object { $_.FullName }

    $scripts = @($regressions + $docChecks)
    $results = @()
    $overallExitCode = 0

    if ($scripts.Count -eq 0) {
        if ($Json) {
            [PSCustomObject][ordered]@{
                TOTAL_SCRIPTS      = 0
                FAILED_SCRIPTS     = 0
                PASSED_SCRIPTS     = 0
                INCLUDE_DOCS_ONLY  = [bool]$IncludeDocsOnly
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

    foreach ($script in $scripts) {
        $name = Split-Path $script -Leaf
        if (-not $Json) {
            Write-Output "--- RUN $name ---"
        }

        $previousEap = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            $output = & powershell -ExecutionPolicy Bypass -File $script 2>&1
            $exitCode = $LASTEXITCODE
        } finally {
            $ErrorActionPreference = $previousEap
        }

        if ($output -and -not $Json) {
            $normalizedOutput = $output | ForEach-Object { $_.ToString() }
            $normalizedOutput | ForEach-Object { Write-Output $_ }
        }

        if ($exitCode -ne 0) {
            $failures += [PSCustomObject]@{
                Script   = $name
                ExitCode = $exitCode
            }
            if (-not $Json) {
                Write-Output "--- FAIL $name (exit=$exitCode) ---"
            }
        } else {
            if (-not $Json) {
                Write-Output "--- PASS $name ---"
            }
        }

        $results += [PSCustomObject]@{
            SCRIPT   = $name
            EXIT_CODE = $exitCode
            STATUS   = if ($exitCode -eq 0) { 'PASS' } else { 'FAIL' }
        }
    }

    if ($failures.Count -gt 0) {
        $overallExitCode = 1
    }

    if ($Json) {
        [PSCustomObject][ordered]@{
            TOTAL_SCRIPTS      = $scripts.Count
            FAILED_SCRIPTS     = $failures.Count
            PASSED_SCRIPTS     = $scripts.Count - $failures.Count
            INCLUDE_DOCS_ONLY  = [bool]$IncludeDocsOnly
            ORIGINAL_BRANCH    = $originalBranch
            RESULTS            = @($results)
            STATUS             = if ($overallExitCode -eq 0) { 'PASSED' } else { 'FAILED' }
        } | ConvertTo-Json -Compress
    } else {
        if ($overallExitCode -ne 0) {
            Write-Output ''
            Write-Output 'run_all_quality_checks: FAILED'
            $failures | ForEach-Object { Write-Output ("  - " + $_.Script + " (exit=" + $_.ExitCode + ")") }
        } else {
            Write-Output ''
            Write-Output 'run_all_quality_checks: PASSED'
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
