#!/usr/bin/env pwsh
# Setup implementation plan for a feature

[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$Force,
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

# Show help if requested
if ($Help) {
    Write-Output "Usage: ./setup-plan.ps1 [-Json] [-Force] [-Help]"
    Write-Output "  -Json     Output results in JSON format"
    Write-Output "  -Force    Overwrite existing plan.md from template"
    Write-Output "  -Help     Show this help message"
    exit 0
}

# Load common functions
. "$PSScriptRoot/common.ps1"

# Get all paths and variables from common functions
$paths = Get-FeaturePathsEnv

# Check if we're on a proper feature branch (only for git repos)
if (-not (Test-FeatureBranch -Branch $paths.CURRENT_BRANCH -HasGit $paths.HAS_GIT)) { 
    exit 1 
}

# Ensure the feature directory exists
New-Item -ItemType Directory -Path $paths.FEATURE_DIR -Force | Out-Null

# Copy plan template if it exists, otherwise note it or create empty file
$template = Join-Path $paths.REPO_ROOT '.specify/templates/plan-template.md'
$action = ''

if (Test-Path $paths.IMPL_PLAN) {
    if ($Force) {
        if (Test-Path $template) {
            Copy-Item $template $paths.IMPL_PLAN -Force
            $action = 'overwritten'
            Write-Output "ACTION: overwritten plan from template at $($paths.IMPL_PLAN)"
        } else {
            Write-Warning "Plan template not found at $template"
            New-Item -ItemType File -Path $paths.IMPL_PLAN -Force | Out-Null
            $action = 'overwritten'
            Write-Output "ACTION: overwritten plan with empty file at $($paths.IMPL_PLAN)"
        }
    } else {
        $action = 'preserved'
        Write-Output "ACTION: preserved existing plan at $($paths.IMPL_PLAN)"
    }
} else {
    if (Test-Path $template) {
        Copy-Item $template $paths.IMPL_PLAN -Force
        $action = 'created'
        Write-Output "ACTION: created plan from template at $($paths.IMPL_PLAN)"
    } else {
        Write-Warning "Plan template not found at $template"
        New-Item -ItemType File -Path $paths.IMPL_PLAN -Force | Out-Null
        $action = 'created'
        Write-Output "ACTION: created empty plan at $($paths.IMPL_PLAN)"
    }
}

# Output results
if ($Json) {
    $result = [PSCustomObject]@{ 
        FEATURE_SPEC = $paths.FEATURE_SPEC
        IMPL_PLAN = $paths.IMPL_PLAN
        SPECS_DIR = $paths.FEATURE_DIR
        BRANCH = $paths.CURRENT_BRANCH
        HAS_GIT = $paths.HAS_GIT
    }
    $result | ConvertTo-Json -Compress
} else {
    Write-Output "ACTION: $action"
    Write-Output "FEATURE_SPEC: $($paths.FEATURE_SPEC)"
    Write-Output "IMPL_PLAN: $($paths.IMPL_PLAN)"
    Write-Output "SPECS_DIR: $($paths.FEATURE_DIR)"
    Write-Output "BRANCH: $($paths.CURRENT_BRANCH)"
    Write-Output "HAS_GIT: $($paths.HAS_GIT)"
}
