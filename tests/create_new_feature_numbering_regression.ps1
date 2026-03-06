#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

. (Join-Path $RepoRoot 'tests/helpers/create_new_feature_numbering_helper.ps1')

$baseTemp = Join-Path $env:TEMP 'create-new-feature-numbering-tests'
if (-not (Test-Path $baseTemp)) { New-Item -ItemType Directory -Path $baseTemp | Out-Null }

$ws = New-CreateFeatureNumberingWorkspace -BaseTempDir $baseTemp -ScenarioName 'polluted-numbering'

Push-Location $ws
try {
    git init | Out-Null
    git config user.email 'test@example.com' | Out-Null
    git config user.name 'Test Runner' | Out-Null
    Set-Content -Path (Join-Path $ws 'README.md') -Value 'seed'
    git add README.md | Out-Null
    git commit -m 'seed' | Out-Null

    git checkout -b 010-normalize-branch-numbering | Out-Null
    git checkout -b 8034-test-noise | Out-Null
    git checkout 010-normalize-branch-numbering | Out-Null

    New-Item -ItemType Directory -Path (Join-Path $ws 'specs/010-normalize-branch-numbering') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $ws 'specs/8034-test-noise') -Force | Out-Null

    $script = Join-Path $ws '.specify/scripts/powershell/create-new-feature.ps1'

    Write-Output 'Running US1 test: auto-number ignores 4-digit branch noise'
    $out1 = & powershell -ExecutionPolicy Bypass -File $script -Json 'next standard feature'
    if ($LASTEXITCODE -ne 0) { throw 'Expected success for auto-number scenario.' }
    $obj1 = ($out1 | Select-Object -Last 1) | ConvertFrom-Json
    if ($obj1.FEATURE_NUM -ne '011') { throw "Expected FEATURE_NUM=011, got $($obj1.FEATURE_NUM)" }

    Write-Output 'Running US2 test: manual -Number still honored'
    $out2 = & powershell -ExecutionPolicy Bypass -File $script -Json -Number 123 -ShortName manual-keep 'manual keep'
    if ($LASTEXITCODE -ne 0) { throw 'Expected success for manual number override.' }
    $obj2 = ($out2 | Select-Object -Last 1) | ConvertFrom-Json
    if ($obj2.FEATURE_NUM -ne '123') { throw "Expected FEATURE_NUM=123, got $($obj2.FEATURE_NUM)" }
    if ($obj2.BRANCH_NAME -ne '123-manual-keep') { throw "Expected BRANCH_NAME=123-manual-keep, got $($obj2.BRANCH_NAME)" }

    Write-Output 'create_new_feature_numbering_regression: PASSED'
}
finally {
    Pop-Location
}
