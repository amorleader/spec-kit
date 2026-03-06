#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

. (Join-Path $RepoRoot 'tests/helpers/assert_setup_plan_json_output.ps1')

function Invoke-SetupPlan {
    param([string[]]$CommandArgs)
    $script = Join-Path $RepoRoot '.specify/scripts/powershell/setup-plan.ps1'
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & powershell -ExecutionPolicy Bypass -File $script @CommandArgs 2>&1
        return [PSCustomObject]@{ ExitCode=$LASTEXITCODE; Output=($out | Out-String) }
    } finally { $ErrorActionPreference = $old }
}

Write-Output 'Running US1 test: JSON mode emits pure parseable JSON'
$r1 = Invoke-SetupPlan -CommandArgs @('-Json')
if ($r1.ExitCode -ne 0) { throw "Expected success in JSON mode. Output: $($r1.Output)" }
Assert-SetupPlanPureJson -StdoutText $r1.Output | Out-Null

Write-Output 'Running US2 test: text mode includes ACTION and paths'
$r2 = Invoke-SetupPlan -CommandArgs @()
if ($r2.ExitCode -ne 0) { throw "Expected success in text mode. Output: $($r2.Output)" }
if ($r2.Output -notmatch 'ACTION:') { throw 'Expected ACTION line in text mode.' }
if ($r2.Output -notmatch 'FEATURE_SPEC:') { throw 'Expected FEATURE_SPEC line in text mode.' }

Write-Output 'setup_plan_json_output_regression: PASSED'
