#!/usr/bin/env pwsh

param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [switch]$VerboseOutput
)

$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'helpers/setup_plan_test_helper.ps1')
. (Join-Path $PSScriptRoot 'helpers/assert_setup_plan_json.ps1')

function Invoke-SetupPlan {
    param(
        [string]$WorkingDir,
        [switch]$ForceOverwrite
    )

    $scriptPath = Join-Path $RepoRoot '.specify/scripts/powershell/setup-plan.ps1'
    $args = @('-ExecutionPolicy', 'Bypass', '-File', $scriptPath, '-Json')
    if ($ForceOverwrite) { $args += '-Force' }

    Push-Location $WorkingDir
    try {
        $output = & powershell @args 2>&1
        $exitCode = $LASTEXITCODE
        [PSCustomObject]@{ Output = $output; ExitCode = $exitCode }
    }
    finally {
        Pop-Location
    }
}

function Get-JsonFromOutput {
    param([object[]]$OutputLines)

    $jsonLine = $OutputLines | Where-Object { $_ -match '^\{.+\}$' } | Select-Object -Last 1
    if (-not $jsonLine) {
        throw 'No JSON payload found in setup-plan output'
    }
    return [string]$jsonLine
}

$branch = git -C $RepoRoot rev-parse --abbrev-ref HEAD
$featureDir = Join-Path $RepoRoot (Join-Path 'specs' $branch)
$planPath = Join-Path $featureDir 'plan.md'

if (-not (Test-Path $featureDir)) {
    throw "Feature directory not found for branch '$branch': $featureDir"
}

$backupPath = "$planPath.us1.bak"
$hadOriginalPlan = Test-Path $planPath
if ($hadOriginalPlan) {
    Copy-Item $planPath $backupPath -Force
}

$failureCount = 0

try {
    Write-Output 'Running US1 test: existing plan should be preserved by default'
    $originalContent = "# Existing Plan Fixture`n`nmarker: DO_NOT_OVERWRITE`n"
    Set-Content -Path $planPath -Value $originalContent -Encoding UTF8

    $existingResult = Invoke-SetupPlan -WorkingDir $RepoRoot
    if ($existingResult.ExitCode -ne 0) {
        Write-Output "FAIL: setup-plan returned non-zero on existing plan case: $($existingResult.ExitCode)"
        $failureCount++
    }

    $contentAfter = Get-Content -Path $planPath -Raw
    if ($contentAfter -notmatch 'DO_NOT_OVERWRITE') {
        Write-Output 'FAIL: existing plan content was overwritten in default mode'
        $failureCount++
    }

    if (($existingResult.Output -join "`n") -notmatch 'ACTION:\s*preserved') {
        Write-Output 'FAIL: expected ACTION: preserved in output for existing plan case'
        $failureCount++
    }

    $existingJson = Get-JsonFromOutput -OutputLines $existingResult.Output
    Assert-SetupPlanJsonFields -JsonText $existingJson | Out-Null

    Write-Output 'Running US1 test: missing plan should be created by default'
    if (Test-Path $planPath) {
        Remove-Item $planPath -Force
    }

    $missingResult = Invoke-SetupPlan -WorkingDir $RepoRoot
    if ($missingResult.ExitCode -ne 0) {
        Write-Output "FAIL: setup-plan returned non-zero on missing plan case: $($missingResult.ExitCode)"
        $failureCount++
    }

    if (-not (Test-Path $planPath)) {
        Write-Output 'FAIL: plan.md was not created in missing plan case'
        $failureCount++
    }

    if (($missingResult.Output -join "`n") -notmatch 'ACTION:\s*created') {
        Write-Output 'FAIL: expected ACTION: created in output for missing plan case'
        $failureCount++
    }

    $missingJson = Get-JsonFromOutput -OutputLines $missingResult.Output
    Assert-SetupPlanJsonFields -JsonText $missingJson | Out-Null

    Write-Output 'Running US2 test: force mode should overwrite existing plan'
    $forceOriginal = "# Force Plan Fixture`n`nmarker: OVERWRITE_ME`n"
    Set-Content -Path $planPath -Value $forceOriginal -Encoding UTF8

    $forceResult = Invoke-SetupPlan -WorkingDir $RepoRoot -ForceOverwrite
    if ($forceResult.ExitCode -ne 0) {
        Write-Output "FAIL: setup-plan returned non-zero on force overwrite case: $($forceResult.ExitCode)"
        $failureCount++
    }

    $contentAfterForce = Get-Content -Path $planPath -Raw
    if ($contentAfterForce -match 'OVERWRITE_ME') {
        Write-Output 'FAIL: existing plan content was not overwritten in force mode'
        $failureCount++
    }

    if (($forceResult.Output -join "`n") -notmatch 'ACTION:\s*overwritten') {
        Write-Output 'FAIL: expected ACTION: overwritten in output for force mode case'
        $failureCount++
    }

    Write-Output 'Running US2 test: JSON output fields should stay backward compatible'
    $forceJson = Get-JsonFromOutput -OutputLines $forceResult.Output
    Assert-SetupPlanJsonFields -JsonText $forceJson | Out-Null
}
finally {
    if (Test-Path $backupPath) {
        Move-Item $backupPath $planPath -Force
    } elseif (-not $hadOriginalPlan -and (Test-Path $planPath)) {
        Remove-Item $planPath -Force
    }
}

if ($failureCount -gt 0) {
    Write-Output "setup_plan_regression: FAILED ($failureCount)"
    exit 1
}

Write-Output 'setup_plan_regression: PASSED'
