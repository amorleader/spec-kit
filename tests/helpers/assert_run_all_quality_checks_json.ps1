#!/usr/bin/env pwsh

function Assert-RunAllQualityChecksJson {
    param([string]$JsonText)

    $obj = $JsonText | ConvertFrom-Json
    $required = @('TOTAL_SCRIPTS','FAILED_SCRIPTS','PASSED_SCRIPTS','INCLUDE_DOCS_ONLY','ORIGINAL_BRANCH','RESULTS','STATUS')
    foreach ($field in $required) {
        if (-not ($obj.PSObject.Properties.Name -contains $field)) {
            throw "Missing required JSON field: $field"
        }
    }

    if ($obj.TOTAL_SCRIPTS -lt 1) { throw 'TOTAL_SCRIPTS must be >= 1' }
    if ($obj.FAILED_SCRIPTS -lt 0) { throw 'FAILED_SCRIPTS must be >= 0' }
    if ($obj.PASSED_SCRIPTS -lt 0) { throw 'PASSED_SCRIPTS must be >= 0' }
    if ($obj.STATUS -notin @('PASSED','FAILED','NO_SCRIPTS_FOUND')) { throw 'Unexpected STATUS value' }

    return $true
}
