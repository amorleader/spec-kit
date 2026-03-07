#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

. (Join-Path $RepoRoot 'tests/helpers/assert_check_prerequisites_json.ps1')
. (Join-Path $RepoRoot 'tests/helpers/assert_setup_plan_json_output.ps1')
. (Join-Path $RepoRoot 'tests/helpers/assert_create_new_feature_json_output.ps1')
. (Join-Path $RepoRoot 'tests/helpers/create_new_feature_test_helper.ps1')

function Assert-IsPureJson {
    param(
        [string]$Text,
        [string]$Scenario
    )

    $trimmed = $Text.Trim()
    if (-not $trimmed.StartsWith('{')) {
        throw "Expected pure JSON output in $Scenario. Actual: $Text"
    }

    $null = $trimmed | ConvertFrom-Json
}

function Assert-JsonErrorContract {
    param(
        [object]$JsonObject,
        [string]$Scenario
    )

    if ([string]::IsNullOrWhiteSpace([string]$JsonObject.STATUS)) {
        throw "Expected STATUS field in $Scenario"
    }
    if ($JsonObject.STATUS -ne 'ERROR') {
        throw "Expected STATUS='ERROR' in $Scenario"
    }
    if ([string]::IsNullOrWhiteSpace([string]$JsonObject.ERROR)) {
        throw "Expected non-empty ERROR field in $Scenario"
    }
    if ($null -eq $JsonObject.PSObject.Properties['HINT']) {
        throw "Expected HINT field in $Scenario"
    }
}

function Invoke-PowerShellScript {
    param(
        [string]$ScriptPath,
        [string[]]$CommandArgs,
        [string]$WorkingDirectory = $RepoRoot
    )

    $previousEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    Push-Location $WorkingDirectory
    try {
        $output = & powershell -ExecutionPolicy Bypass -File $ScriptPath @CommandArgs 2>&1
        return [PSCustomObject]@{
            ExitCode = $LASTEXITCODE
            Output = ($output | Out-String)
        }
    } finally {
        Pop-Location
        $ErrorActionPreference = $previousEap
    }
}

Write-Output 'Running US1 test: check-prerequisites JSON success stays parseable'
$checkScript = Join-Path $RepoRoot '.specify/scripts/powershell/check-prerequisites.ps1'
$r1 = Invoke-PowerShellScript -ScriptPath $checkScript -CommandArgs @('-Json')
if ($r1.ExitCode -ne 0) { throw "Expected check-prerequisites success JSON output. Output: $($r1.Output)" }
Assert-IsPureJson -Text $r1.Output -Scenario 'check-prerequisites success'
Assert-CheckPrerequisitesJson -JsonText $r1.Output.Trim() | Out-Null

Write-Output 'Running US1 test: setup-plan JSON success stays parseable'
$setupScript = Join-Path $RepoRoot '.specify/scripts/powershell/setup-plan.ps1'
$r2 = Invoke-PowerShellScript -ScriptPath $setupScript -CommandArgs @('-Json')
if ($r2.ExitCode -ne 0) { throw "Expected setup-plan success JSON output. Output: $($r2.Output)" }
Assert-IsPureJson -Text $r2.Output -Scenario 'setup-plan success'
Assert-SetupPlanPureJson -StdoutText $r2.Output | Out-Null

Write-Output 'Running US1 test: create-new-feature JSON success stays parseable'
$baseTemp = Join-Path $env:TEMP 'json-pure-output-tests'
if (-not (Test-Path $baseTemp)) { New-Item -ItemType Directory -Path $baseTemp | Out-Null }
$workspace = New-CreateNewFeatureWorkspace -BaseTempDir $baseTemp -ScenarioName ('json-pure-' + [Guid]::NewGuid().ToString('N'))
$createScript = Join-Path $workspace '.specify/scripts/powershell/create-new-feature.ps1'
$featureNumber = Get-Random -Minimum 8600 -Maximum 8990
$r3 = Invoke-PowerShellScript -ScriptPath $createScript -WorkingDirectory $workspace -CommandArgs @('-Json', '-Number', "$featureNumber", '-ShortName', "json-pure-$featureNumber", 'json pure pass')
if ($r3.ExitCode -ne 0) { throw "Expected create-new-feature success JSON output. Output: $($r3.Output)" }
Assert-IsPureJson -Text $r3.Output -Scenario 'create-new-feature success'
Assert-PureJsonOutput -StdoutText $r3.Output | Out-Null

Write-Output 'Running US1 test: check-prerequisites JSON failure stays parseable'
$previousFeature = $env:SPECIFY_FEATURE
$env:SPECIFY_FEATURE = 'not-a-feature-branch'
try {
    $r4 = Invoke-PowerShellScript -ScriptPath $checkScript -CommandArgs @('-Json')
    if ($r4.ExitCode -eq 0) { throw 'Expected check-prerequisites failure for invalid branch.' }
    Assert-IsPureJson -Text $r4.Output -Scenario 'check-prerequisites failure'
    $j4 = $r4.Output.Trim() | ConvertFrom-Json
    Assert-JsonErrorContract -JsonObject $j4 -Scenario 'check-prerequisites failure'
} finally {
    $env:SPECIFY_FEATURE = $previousFeature
}

Write-Output 'Running US1 test: setup-plan JSON failure stays parseable'
$previousFeature = $env:SPECIFY_FEATURE
$env:SPECIFY_FEATURE = 'not-a-feature-branch'
try {
    $r5 = Invoke-PowerShellScript -ScriptPath $setupScript -CommandArgs @('-Json')
    if ($r5.ExitCode -eq 0) { throw 'Expected setup-plan failure for invalid branch.' }
    Assert-IsPureJson -Text $r5.Output -Scenario 'setup-plan failure'
    $j5 = $r5.Output.Trim() | ConvertFrom-Json
    Assert-JsonErrorContract -JsonObject $j5 -Scenario 'setup-plan failure'
} finally {
    $env:SPECIFY_FEATURE = $previousFeature
}

Write-Output 'Running US1 test: create-new-feature JSON failure stays parseable'
$r6 = Invoke-PowerShellScript -ScriptPath $createScript -WorkingDirectory $workspace -CommandArgs @('-Json')
if ($r6.ExitCode -eq 0) { throw 'Expected create-new-feature failure when description is missing.' }
Assert-IsPureJson -Text $r6.Output -Scenario 'create-new-feature failure'
$j6 = $r6.Output.Trim() | ConvertFrom-Json
Assert-JsonErrorContract -JsonObject $j6 -Scenario 'create-new-feature failure'

Write-Output 'json_pure_output_regression: PASSED'
