#!/usr/bin/env pwsh

function New-CheckPrerequisitesScenarioWorkspace {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseTempDir,
        [Parameter(Mandatory = $true)]
        [string]$ScenarioName
    )

    $scenarioRoot = Join-Path $BaseTempDir $ScenarioName
    if (Test-Path $scenarioRoot) {
        Remove-Item -Path $scenarioRoot -Recurse -Force
    }

    New-Item -ItemType Directory -Path $scenarioRoot | Out-Null
    $specsRoot = Join-Path $scenarioRoot 'specs'
    New-Item -ItemType Directory -Path $specsRoot | Out-Null

    return $scenarioRoot
}
