#!/usr/bin/env pwsh

function Assert-SetupPlanPureJson {
    param([string]$StdoutText)

    $trimmed = $StdoutText.Trim()
    if (-not $trimmed.StartsWith('{')) {
        throw 'Expected stdout to start with JSON object.'
    }

    $parsed = $trimmed | ConvertFrom-Json
    foreach ($field in @('FEATURE_SPEC','IMPL_PLAN','SPECS_DIR','BRANCH','HAS_GIT')) {
        if ($null -eq $parsed.$field -or [string]::IsNullOrWhiteSpace([string]$parsed.$field)) {
            throw "Missing required JSON field: $field"
        }
    }
    return $true
}
