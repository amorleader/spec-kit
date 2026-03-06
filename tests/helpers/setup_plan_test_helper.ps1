#!/usr/bin/env pwsh

function New-TempFeatureWorkspace {
    param(
        [string]$BasePath,
        [string]$BranchName = '999-test-setup-plan'
    )

    $workspace = Join-Path $BasePath ("tmp-{0}" -f [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $workspace -Force | Out-Null

    $specs = Join-Path $workspace 'specs'
    $feature = Join-Path $specs $BranchName
    New-Item -ItemType Directory -Path $feature -Force | Out-Null

    [PSCustomObject]@{
        Workspace = $workspace
        FeatureDir = $feature
        Branch = $BranchName
    }
}

function Set-PlanContent {
    param(
        [string]$FeatureDir,
        [string]$Content
    )

    $planPath = Join-Path $FeatureDir 'plan.md'
    Set-Content -Path $planPath -Value $Content -Encoding UTF8
    return $planPath
}
