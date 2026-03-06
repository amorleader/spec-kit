#!/usr/bin/env pwsh

function New-CreateFeatureNumberingWorkspace {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseTempDir,
        [Parameter(Mandatory = $true)]
        [string]$ScenarioName
    )

    $workspace = Join-Path $BaseTempDir $ScenarioName
    if (Test-Path $workspace) {
        Remove-Item -Path $workspace -Recurse -Force
    }

    New-Item -ItemType Directory -Path $workspace | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $workspace '.specify/scripts/powershell') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $workspace '.specify/templates') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $workspace 'specs') -Force | Out-Null

    Copy-Item -Path (Join-Path $PSScriptRoot '../../.specify/scripts/powershell/create-new-feature.ps1') -Destination (Join-Path $workspace '.specify/scripts/powershell/create-new-feature.ps1') -Force
    Copy-Item -Path (Join-Path $PSScriptRoot '../../.specify/templates/spec-template.md') -Destination (Join-Path $workspace '.specify/templates/spec-template.md') -Force

    return $workspace
}
