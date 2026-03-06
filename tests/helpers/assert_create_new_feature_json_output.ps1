#!/usr/bin/env pwsh

function Assert-PureJsonOutput {
    param([string]$StdoutText)

    $trimmed = $StdoutText.Trim()
    if (-not $trimmed.StartsWith('{')) {
        throw 'Expected stdout to start with JSON object.'
    }

    $parsed = $trimmed | ConvertFrom-Json
    foreach ($field in @('BRANCH_NAME','SPEC_FILE','FEATURE_NUM','HAS_GIT')) {
        if ($null -eq $parsed.$field -or [string]::IsNullOrWhiteSpace([string]$parsed.$field)) {
            throw "Missing required field: $field"
        }
    }

    return $true
}
