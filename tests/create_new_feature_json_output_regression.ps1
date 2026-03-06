#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

. (Join-Path $RepoRoot 'tests/helpers/assert_create_new_feature_json_output.ps1')
. (Join-Path $RepoRoot 'tests/helpers/create_new_feature_test_helper.ps1')

$baseNumber = Get-Random -Minimum 8000 -Maximum 8990
$baseTemp = Join-Path $env:TEMP 'create-new-feature-json-output-tests'
if (-not (Test-Path $baseTemp)) { New-Item -ItemType Directory -Path $baseTemp | Out-Null }

$workspace = New-CreateNewFeatureWorkspace -BaseTempDir $baseTemp -ScenarioName 'json-pure-output'

function Invoke-CreateFeature {
  param([string]$Workspace,[string[]]$CommandArgs)
  $script = Join-Path $Workspace '.specify/scripts/powershell/create-new-feature.ps1'
  $old = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  Push-Location $Workspace
  try {
    $out = & powershell -ExecutionPolicy Bypass -File $script @CommandArgs 2>&1
    return [PSCustomObject]@{ ExitCode=$LASTEXITCODE; Output=($out | Out-String) }
  } finally {
    Pop-Location
    $ErrorActionPreference = $old
  }
}

Write-Output 'Running US1 test: JSON mode emits pure parseable JSON'
$r1 = Invoke-CreateFeature -Workspace $workspace -CommandArgs @('-Json', '-Number', "$baseNumber", '-ShortName', "json-pure-check-$baseNumber", 'json pure check')
if ($r1.ExitCode -ne 0) { throw "Expected success in JSON mode. Output: $($r1.Output)" }
Assert-PureJsonOutput -StdoutText $r1.Output | Out-Null

Write-Output 'Running US2 test: text mode includes ACTION and key-value lines'
$textNumber = $baseNumber + 1
$r2 = Invoke-CreateFeature -Workspace $workspace -CommandArgs @('-Number', "$textNumber", '-ShortName', "text-output-check-$textNumber", 'text output check')
if ($r2.ExitCode -ne 0) { throw "Expected success in text mode. Output: $($r2.Output)" }
if ($r2.Output -notmatch 'ACTION:') { throw 'Expected ACTION line in text mode output.' }
if ($r2.Output -notmatch 'BRANCH_NAME:') { throw 'Expected BRANCH_NAME line in text mode output.' }

Write-Output 'create_new_feature_json_output_regression: PASSED'
