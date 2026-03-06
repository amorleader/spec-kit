#!/usr/bin/env pwsh

param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

. (Join-Path $RepoRoot 'tests/helpers/assert_create_new_feature_json.ps1')
. (Join-Path $RepoRoot 'tests/helpers/create_new_feature_test_helper.ps1')

$baseTemp = Join-Path $env:TEMP 'create-new-feature-recovery-tests'
if (-not (Test-Path $baseTemp)) {
    New-Item -ItemType Directory -Path $baseTemp | Out-Null
}

function Initialize-TestRepo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Workspace
    )

    Push-Location $Workspace
    try {
        git init | Out-Null
        git config user.email 'test@example.com' | Out-Null
        git config user.name 'Test Runner' | Out-Null
        Set-Content -Path (Join-Path $Workspace 'README.md') -Value 'seed'
        git add README.md | Out-Null
        git commit -m 'seed' | Out-Null
    } finally {
        Pop-Location
    }
}

function Invoke-CreateFeature {
    param(
        [string]$Workspace,
        [string[]]$CommandArgs
    )

    $scriptPath = Join-Path $Workspace '.specify/scripts/powershell/create-new-feature.ps1'
    Push-Location $Workspace
    try {
        $previousEap = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            $out = & powershell -ExecutionPolicy Bypass -File $scriptPath @CommandArgs 2>&1
            return [PSCustomObject]@{ ExitCode = $LASTEXITCODE; Output = ($out | Out-String) }
        } finally {
            $ErrorActionPreference = $previousEap
        }
    } finally {
        Pop-Location
    }
}

Write-Output 'Running US1 test: recover when current branch exists and specs missing'
$ws1 = New-CreateNewFeatureWorkspace -BaseTempDir $baseTemp -ScenarioName 'recover-current'
Push-Location $ws1
try {
    Initialize-TestRepo -Workspace $ws1
    git checkout -b 006-recover-missing-specs | Out-Null
    $r1 = Invoke-CreateFeature -Workspace $ws1 -CommandArgs @('-Json', '-Number', '6', 'recover current branch')
    if ($r1.ExitCode -ne 0) { throw "Expected success but got $($r1.ExitCode). Output: $($r1.Output)" }
    $j1 = ($r1.Output.Trim().Split([Environment]::NewLine) | Select-Object -Last 1)
    Assert-CreateNewFeatureJson -JsonText $j1 | Out-Null
    $obj1 = $j1 | ConvertFrom-Json
    if (-not (Test-Path $obj1.SPEC_FILE)) { throw 'Expected SPEC_FILE to exist after recovery.' }
} finally {
    Pop-Location
}

Write-Output 'Running US1 test: preserve existing spec content'
$ws2 = New-CreateNewFeatureWorkspace -BaseTempDir $baseTemp -ScenarioName 'preserve-spec'
Push-Location $ws2
try {
    Initialize-TestRepo -Workspace $ws2
    git checkout -b 006-recover-missing-specs | Out-Null
    $specDir = Join-Path $ws2 'specs/006-recover-missing-specs'
    New-Item -ItemType Directory -Path $specDir -Force | Out-Null
    $specFile = Join-Path $specDir 'spec.md'
    Set-Content -Path $specFile -Value 'DO_NOT_OVERWRITE'
    $r2 = Invoke-CreateFeature -Workspace $ws2 -CommandArgs @('-Json', '-Number', '6', 'preserve existing spec')
    if ($r2.ExitCode -ne 0) { throw "Expected success but got $($r2.ExitCode)." }
    $after = Get-Content $specFile -Raw
    if ($after -notmatch 'DO_NOT_OVERWRITE') { throw 'Expected existing spec content to be preserved.' }
} finally {
    Pop-Location
}

Write-Output 'Running US2 test: recover when branch exists but is non-current'
$ws3 = New-CreateNewFeatureWorkspace -BaseTempDir $baseTemp -ScenarioName 'recover-non-current'
Push-Location $ws3
try {
    Initialize-TestRepo -Workspace $ws3
    git checkout -b 006-recover-missing-specs | Out-Null
    git checkout -b temp-work | Out-Null
    $r3 = Invoke-CreateFeature -Workspace $ws3 -CommandArgs @('-Json', '-Number', '6', '-ShortName', 'recover-missing-specs', 'recover non current')
    if ($r3.ExitCode -ne 0) { throw "Expected success but got $($r3.ExitCode). Output: $($r3.Output)" }
    $cur = (git rev-parse --abbrev-ref HEAD).Trim()
    if ($cur -ne '006-recover-missing-specs') { throw "Expected checkout to target branch, got $cur" }
} finally {
    Pop-Location
}

Write-Output 'Running US2 test: failed checkout returns actionable error'
$ws4 = New-CreateNewFeatureWorkspace -BaseTempDir $baseTemp -ScenarioName 'checkout-fail-path'
Push-Location $ws4
try {
    Initialize-TestRepo -Workspace $ws4
    git checkout -b 006-recover-missing-specs | Out-Null
    git checkout -b another | Out-Null
    $script = Join-Path $ws4 '.specify/scripts/powershell/create-new-feature.ps1'
    $content = Get-Content $script -Raw
    $content = $content -replace 'git checkout \$branchName \| Out-Null', 'throw "checkout failed"'
    Set-Content -Path $script -Value $content

    $r4 = Invoke-CreateFeature -Workspace $ws4 -CommandArgs @('-Json', '-Number', '6', '-ShortName', 'recover-missing-specs', 'checkout fail')
    if ($r4.ExitCode -eq 0) { throw 'Expected non-zero exit on checkout failure.' }
} finally {
    Pop-Location
}

Write-Output 'create_new_feature_recovery_regression: PASSED'
