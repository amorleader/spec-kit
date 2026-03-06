#!/usr/bin/env pwsh

function Assert-CreateNewFeatureJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$JsonText
    )

    $parsed = $JsonText | ConvertFrom-Json

    foreach ($field in @('BRANCH_NAME', 'SPEC_FILE', 'FEATURE_NUM', 'HAS_GIT')) {
        if ($null -eq $parsed.$field -or [string]::IsNullOrWhiteSpace([string]$parsed.$field)) {
            throw "Missing required JSON field: $field"
        }
    }

    return $true
}
