#!/usr/bin/env pwsh

function Assert-CheckPrerequisitesJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$JsonText
    )

    $parsed = $JsonText | ConvertFrom-Json
    if ($null -eq $parsed.FEATURE_DIR -or [string]::IsNullOrWhiteSpace([string]$parsed.FEATURE_DIR)) {
        throw 'FEATURE_DIR is required and must be non-empty.'
    }

    if ($null -eq $parsed.AVAILABLE_DOCS) {
        throw 'AVAILABLE_DOCS is required and must not be null.'
    }

    if (-not ($parsed.AVAILABLE_DOCS -is [System.Array])) {
        throw 'AVAILABLE_DOCS must be an array.'
    }

    return $true
}
