#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

. (Join-Path $RepoRoot 'tests/helpers/create_new_feature_test_helper.ps1')

function Invoke-TextScript {
    param(
        [string]$ScriptPath,
        [string[]]$CommandArgs,
        [string]$WorkingDirectory = $RepoRoot
    )

    $previousEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    Push-Location $WorkingDirectory
    try {
        $out = & powershell -ExecutionPolicy Bypass -File $ScriptPath @CommandArgs 2>&1
        return [PSCustomObject]@{
            ExitCode = $LASTEXITCODE
            Output = ($out | Out-String)
        }
    } finally {
        Pop-Location
        $ErrorActionPreference = $previousEap
    }
}

function Assert-Contains {
    param([string]$Text, [string]$Needle, [string]$Label)
    if ($Text -notmatch [Regex]::Escape($Needle)) {
        throw "Assertion failed ($Label): expected '$Needle'"
    }
}

function Assert-Match {
    param([string]$Text, [string]$Pattern, [string]$Label)
    if ($Text -notmatch $Pattern) {
        throw "Assertion failed ($Label): pattern '$Pattern' not matched"
    }
}

function Assert-LineOrder {
    param([string]$Text, [string[]]$Needles, [string]$Label)
    $index = -1
    foreach ($needle in $Needles) {
        $next = $Text.IndexOf($needle, [Math]::Max($index + 1, 0), [System.StringComparison]::Ordinal)
        if ($next -lt 0) {
            throw "Assertion failed ($Label): missing '$needle'"
        }
        $index = $next
    }
}

$checkScript = Join-Path $RepoRoot '.specify/scripts/powershell/check-prerequisites.ps1'
$setupScript = Join-Path $RepoRoot '.specify/scripts/powershell/setup-plan.ps1'

Write-Output 'Running US1 test: check-prerequisites text output has stable key labels'
$r1 = Invoke-TextScript -ScriptPath $checkScript -CommandArgs @()
if ($r1.ExitCode -ne 0) { throw "Expected check-prerequisites text success. Output: $($r1.Output)" }
Assert-Contains -Text $r1.Output -Needle 'FEATURE_DIR:' -Label 'check text FEATURE_DIR'
Assert-Contains -Text $r1.Output -Needle 'AVAILABLE_DOCS:' -Label 'check text AVAILABLE_DOCS'
Assert-LineOrder -Text $r1.Output -Needles @('FEATURE_DIR:', 'AVAILABLE_DOCS:') -Label 'check text line order'

Write-Output 'Running US1 test: setup-plan text output has stable key labels'
$r2 = Invoke-TextScript -ScriptPath $setupScript -CommandArgs @()
if ($r2.ExitCode -ne 0) { throw "Expected setup-plan text success. Output: $($r2.Output)" }
Assert-Contains -Text $r2.Output -Needle 'ACTION:' -Label 'setup text ACTION'
Assert-Contains -Text $r2.Output -Needle 'FEATURE_SPEC:' -Label 'setup text FEATURE_SPEC'
Assert-Contains -Text $r2.Output -Needle 'IMPL_PLAN:' -Label 'setup text IMPL_PLAN'
Assert-LineOrder -Text $r2.Output -Needles @('ACTION:', 'FEATURE_SPEC:', 'IMPL_PLAN:') -Label 'setup text line order'

Write-Output 'Running US1 test: create-new-feature text output has stable key labels'
$baseTemp = Join-Path $env:TEMP 'text-output-check-tests'
if (-not (Test-Path $baseTemp)) { New-Item -ItemType Directory -Path $baseTemp | Out-Null }
$workspace = New-CreateNewFeatureWorkspace -BaseTempDir $baseTemp -ScenarioName ('text-output-' + [Guid]::NewGuid().ToString('N'))
$createScript = Join-Path $workspace '.specify/scripts/powershell/create-new-feature.ps1'
$number = Get-Random -Minimum 9300 -Maximum 9699
$r3 = Invoke-TextScript -ScriptPath $createScript -WorkingDirectory $workspace -CommandArgs @('-Number', "$number", '-ShortName', "text-output-$number", 'text output pass')
if ($r3.ExitCode -ne 0) { throw "Expected create-new-feature text success. Output: $($r3.Output)" }
Assert-Contains -Text $r3.Output -Needle 'ACTION:' -Label 'create text ACTION'
Assert-Contains -Text $r3.Output -Needle 'BRANCH_NAME:' -Label 'create text BRANCH_NAME'
Assert-Contains -Text $r3.Output -Needle 'FEATURE_NUM:' -Label 'create text FEATURE_NUM'
Assert-LineOrder -Text $r3.Output -Needles @('ACTION:', 'BRANCH_NAME:', 'SPEC_FILE:', 'FEATURE_NUM:') -Label 'create text line order'

Write-Output 'Running US1 test: check-prerequisites text failure exposes error and hint'
$prevFeature = $env:SPECIFY_FEATURE
$env:SPECIFY_FEATURE = 'not-a-feature-branch'
try {
    $r4 = Invoke-TextScript -ScriptPath $checkScript -CommandArgs @()
    if ($r4.ExitCode -eq 0) { throw 'Expected check-prerequisites text failure.' }
    Assert-Match -Text $r4.Output -Pattern '(?m)^ERROR:' -Label 'check failure ERROR prefix'
    Assert-Match -Text $r4.Output -Pattern '(?m)^HINT:' -Label 'check failure HINT prefix'
    Assert-Contains -Text $r4.Output -Needle 'ERROR: Not on a feature branch.' -Label 'check failure ERROR'
    Assert-Contains -Text $r4.Output -Needle 'HINT:' -Label 'check failure HINT'
} finally {
    $env:SPECIFY_FEATURE = $prevFeature
}

Write-Output 'Running US1 test: setup-plan text failure exposes error and hint'
$prevFeature = $env:SPECIFY_FEATURE
$env:SPECIFY_FEATURE = 'not-a-feature-branch'
try {
    $r5 = Invoke-TextScript -ScriptPath $setupScript -CommandArgs @()
    if ($r5.ExitCode -eq 0) { throw 'Expected setup-plan text failure.' }
    Assert-Match -Text $r5.Output -Pattern '(?m)^ERROR:' -Label 'setup failure ERROR prefix'
    Assert-Match -Text $r5.Output -Pattern '(?m)^HINT:' -Label 'setup failure HINT prefix'
    Assert-Contains -Text $r5.Output -Needle 'ERROR: Not on a feature branch.' -Label 'setup failure ERROR'
    Assert-Contains -Text $r5.Output -Needle 'HINT:' -Label 'setup failure HINT'
} finally {
    $env:SPECIFY_FEATURE = $prevFeature
}

Write-Output 'Running US1 test: create-new-feature text failure exposes error line'
$r6 = Invoke-TextScript -ScriptPath $createScript -WorkingDirectory $workspace -CommandArgs @()
if ($r6.ExitCode -eq 0) { throw 'Expected create-new-feature text failure.' }
Assert-Match -Text $r6.Output -Pattern '(?m)^ERROR:' -Label 'create failure ERROR prefix'
Assert-Match -Text $r6.Output -Pattern '(?m)^HINT:' -Label 'create failure HINT prefix'
Assert-Contains -Text $r6.Output -Needle 'ERROR:' -Label 'create failure ERROR'
Assert-Contains -Text $r6.Output -Needle 'Usage: ./create-new-feature.ps1' -Label 'create failure usage'

Write-Output 'text_output_check_regression: PASSED'