#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

. (Join-Path $RepoRoot 'tests/helpers/create_new_feature_warning_helper.ps1')

$baseTemp = Join-Path $env:TEMP 'create-new-feature-warning-tests'
if (-not (Test-Path $baseTemp)) { New-Item -ItemType Directory -Path $baseTemp | Out-Null }

$ws = New-CreateFeatureWarningWorkspace -BaseTempDir $baseTemp -ScenarioName 'warning-stream'
Push-Location $ws
try {
    $script = Join-Path $ws '.specify/scripts/powershell/create-new-feature.ps1'

    $veryLong = ('segment-' * 80) + 'tail'
    $desc = 'json warning stream'

    Write-Output 'Running US1 test: JSON mode stays pure under truncation warning scenario'
    $jsonCombined = & powershell -ExecutionPolicy Bypass -File $script -Json -Number 11 -ShortName $veryLong $desc 3>&1 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { throw "Expected success in JSON mode. Output: $jsonCombined" }
    $trimmed = $jsonCombined.Trim()
    if (-not $trimmed.StartsWith('{')) { throw 'Expected combined output to start with JSON object in JSON mode.' }
    $null = $trimmed | ConvertFrom-Json

    Write-Output 'Running US2 test: text mode still shows warning under truncation scenario'
    $textCombined = & powershell -ExecutionPolicy Bypass -File $script -Number 12 -ShortName $veryLong $desc 3>&1 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { throw "Expected success in text mode. Output: $textCombined" }
    if ($textCombined -notmatch 'WARNING:') { throw 'Expected warning text in non-JSON mode.' }
    if ($textCombined -notmatch 'ACTION:') { throw 'Expected ACTION text in non-JSON mode.' }

    Write-Output 'create_new_feature_warning_stream_regression: PASSED'
}
finally {
    Pop-Location
}
