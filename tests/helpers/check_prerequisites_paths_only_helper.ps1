#!/usr/bin/env pwsh

function New-CheckPrerequisitesPathsOnlyWorkspace {
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

    Copy-Item -Path (Join-Path $PSScriptRoot '../../.specify/scripts/powershell/check-prerequisites.ps1') -Destination (Join-Path $workspace '.specify/scripts/powershell/check-prerequisites.ps1') -Force
    Copy-Item -Path (Join-Path $PSScriptRoot '../../.specify/scripts/powershell/common.ps1') -Destination (Join-Path $workspace '.specify/scripts/powershell/common.ps1') -Force

    return $workspace
}
