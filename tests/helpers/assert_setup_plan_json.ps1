#!/usr/bin/env pwsh

function Assert-SetupPlanJsonFields {
    param(
        [string]$JsonText
    )

    $obj = $JsonText | ConvertFrom-Json
    $required = @('FEATURE_SPEC', 'IMPL_PLAN', 'SPECS_DIR', 'BRANCH', 'HAS_GIT')

    foreach ($field in $required) {
        if (-not ($obj.PSObject.Properties.Name -contains $field)) {
            throw "Missing required JSON field: $field"
        }
    }

    if (-not ($obj.HAS_GIT -is [bool])) {
        throw 'HAS_GIT must be boolean'
    }

    return $true
}
