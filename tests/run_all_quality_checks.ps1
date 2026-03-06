#!/usr/bin/env pwsh

param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [switch]$IncludeDocsOnly
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
    if ($scripts.Count -eq 0) {
        Write-Output 'run_all_quality_checks: NO_SCRIPTS_FOUND'
        exit 1
    }

    $failures = @()

    foreach ($script in $scripts) {
        $name = Split-Path $script -Leaf
        Write-Output "--- RUN $name ---"

        $previousEap = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            $output = & powershell -ExecutionPolicy Bypass -File $script 2>&1
            $exitCode = $LASTEXITCODE
        } finally {
            $ErrorActionPreference = $previousEap
        }

        if ($output) {
            $normalizedOutput = $output | ForEach-Object { $_.ToString() }
            $normalizedOutput | ForEach-Object { Write-Output $_ }
        }

        if ($exitCode -ne 0) {
            $failures += [PSCustomObject]@{
                Script   = $name
                ExitCode = $exitCode
            }
            Write-Output "--- FAIL $name (exit=$exitCode) ---"
        } else {
            Write-Output "--- PASS $name ---"
        }
    }

    if ($failures.Count -gt 0) {
        Write-Output ''
        Write-Output 'run_all_quality_checks: FAILED'
        $failures | ForEach-Object { Write-Output ("  - " + $_.Script + " (exit=" + $_.ExitCode + ")") }
        exit 1
    }

    Write-Output ''
    Write-Output 'run_all_quality_checks: PASSED'
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
                        Write-Output "run_all_quality_checks: restored branch to $originalBranch"
                    } else {
                        Write-Warning "run_all_quality_checks: failed to restore branch to $originalBranch"
                    }
                }
            }
        } finally {
            $ErrorActionPreference = $previousEap
        }
    }
    Pop-Location
}
