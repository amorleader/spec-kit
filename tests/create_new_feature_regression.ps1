#!/usr/bin/env pwsh

param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

. (Join-Path $RepoRoot 'tests/helpers/assert_create_new_feature_json.ps1')
. (Join-Path $RepoRoot 'tests/helpers/create_new_feature_test_helper.ps1')

$baseTemp = Join-Path $env:TEMP 'create-new-feature-tests'
if (-not (Test-Path $baseTemp)) {
    New-Item -ItemType Directory -Path $baseTemp | Out-Null
}

function Invoke-CreateNewFeatureJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Workspace,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $scriptPath = Join-Path $Workspace '.specify/scripts/powershell/create-new-feature.ps1'
    Push-Location $Workspace
    try {
        $output = & powershell -ExecutionPolicy Bypass -File $scriptPath @Arguments
        if ($LASTEXITCODE -ne 0) {
            throw "create-new-feature failed with exit code $LASTEXITCODE"
        }

        return ($output | Select-Object -Last 1)
    } finally {
        Pop-Location
    }
}

Write-Output 'Running US1 test: supports -Json then description order'
$ws1 = New-CreateNewFeatureWorkspace -BaseTempDir $baseTemp -ScenarioName 'us1-json-first'
$json1 = Invoke-CreateNewFeatureJson -Workspace $ws1 -Arguments @('-Json', '-Number', '901', 'json first description')
Assert-CreateNewFeatureJson -JsonText $json1 | Out-Null

Write-Output 'Running US1 test: supports description then -Json order'
$ws2 = New-CreateNewFeatureWorkspace -BaseTempDir $baseTemp -ScenarioName 'us1-desc-first'
$json2 = Invoke-CreateNewFeatureJson -Workspace $ws2 -Arguments @('desc first description', '-Json', '-Number', '902')
Assert-CreateNewFeatureJson -JsonText $json2 | Out-Null

Write-Output 'Running US2 test: deterministic parsing with -ShortName and description'
$ws3 = New-CreateNewFeatureWorkspace -BaseTempDir $baseTemp -ScenarioName 'us2-shortname'
$json3 = Invoke-CreateNewFeatureJson -Workspace $ws3 -Arguments @('-Json', '-ShortName', 'demo-short', '-Number', '910', 'shortname parse description')
Assert-CreateNewFeatureJson -JsonText $json3 | Out-Null
$obj3 = $json3 | ConvertFrom-Json
if ($obj3.BRANCH_NAME -ne '910-demo-short') {
    throw "Expected BRANCH_NAME to be 910-demo-short but got $($obj3.BRANCH_NAME)"
}

Write-Output 'Running US2 test: explicit -Number override remains deterministic'
$ws4 = New-CreateNewFeatureWorkspace -BaseTempDir $baseTemp -ScenarioName 'us2-number-override'
$json4 = Invoke-CreateNewFeatureJson -Workspace $ws4 -Arguments @('number override scenario', '-Json', '-Number', '915')
Assert-CreateNewFeatureJson -JsonText $json4 | Out-Null
$obj4 = $json4 | ConvertFrom-Json
if ($obj4.FEATURE_NUM -ne '915') {
    throw "Expected FEATURE_NUM to be 915 but got $($obj4.FEATURE_NUM)"
}
if (-not ($obj4.BRANCH_NAME -like '915-*')) {
    throw "Expected BRANCH_NAME to start with 915- but got $($obj4.BRANCH_NAME)"
}

Write-Output 'create_new_feature_regression: PASSED'
