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
if ($paths.HAS_GIT -and $paths.CURRENT_BRANCH -notmatch '^[0-9]{3}-') {
    if ($Json) {
        [PSCustomObject][ordered]@{
            STATUS = 'ERROR'
            ERROR  = "Not on a feature branch. Current branch: $($paths.CURRENT_BRANCH)"
            HINT   = 'Feature branches should be named like: 001-feature-name'
        } | ConvertTo-Json -Compress
    } else {
        Write-Output "ERROR: Not on a feature branch. Current branch: $($paths.CURRENT_BRANCH)"
        Write-Output 'Feature branches should be named like: 001-feature-name'
    }
    exit 1
}

if (-not $paths.HAS_GIT -and -not $Json) {
    Write-Warning '[specify] Warning: Git repository not detected; skipped branch validation'
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
            if (-not $Json) {
                Write-Output "ACTION: overwritten plan from template at $($paths.IMPL_PLAN)"
            }
        } else {
            if (-not $Json) {
                Write-Warning "Plan template not found at $template"
            }
            New-Item -ItemType File -Path $paths.IMPL_PLAN -Force | Out-Null
            $action = 'overwritten'
            if (-not $Json) {
                Write-Output "ACTION: overwritten plan with empty file at $($paths.IMPL_PLAN)"
            }
        }
    } else {
        $action = 'preserved'
        if (-not $Json) {
            Write-Output "ACTION: preserved existing plan at $($paths.IMPL_PLAN)"
        }
    }
} else {
    if (Test-Path $template) {
        Copy-Item $template $paths.IMPL_PLAN -Force
        $action = 'created'
        if (-not $Json) {
            Write-Output "ACTION: created plan from template at $($paths.IMPL_PLAN)"
        }
    } else {
        if (-not $Json) {
            Write-Warning "Plan template not found at $template"
        }
        New-Item -ItemType File -Path $paths.IMPL_PLAN -Force | Out-Null
        $action = 'created'
        if (-not $Json) {
            Write-Output "ACTION: created empty plan at $($paths.IMPL_PLAN)"
        }
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
