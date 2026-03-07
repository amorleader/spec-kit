#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

function Assert-Contains {
    param([string]$Text, [string]$Pattern, [string]$Label)
    if ($Text -notmatch $Pattern) {
        throw "Assertion failed ($Label): pattern '$Pattern' not matched"
    }
}

function Invoke-DocsValidator {
    param([string]$ValidatorPath)

    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & powershell -ExecutionPolicy Bypass -Command "& '$ValidatorPath'" 2>&1
        return [PSCustomObject]@{
            ExitCode = $LASTEXITCODE
            Output   = ($output | Out-String)
        }
    } finally {
        $ErrorActionPreference = $old
    }
}

$runnerScript = Join-Path $RepoRoot 'tests/run_all_quality_checks.ps1'
if (-not (Test-Path $runnerScript)) {
    throw "Missing script: $runnerScript"
}

$runnerText = Get-Content -Path $runnerScript -Raw

Write-Output 'Running US1 test: docs-only selection logic is explicit and docs-only scoped'
Assert-Contains -Text $runnerText -Pattern 'testsDir' -Label 'tests dir variable present'
Assert-Contains -Text $runnerText -Pattern 'validate_\*_docs\.ps1' -Label 'docs validator discovery'
Assert-Contains -Text $runnerText -Pattern 'Docs-only mode must execute docs validators only' -Label 'docs-only script selection comment'
Assert-Contains -Text $runnerText -Pattern 'scripts = @\(\$docChecks\)' -Label 'docs-only scripts assignment'

Write-Output 'Running US2 test: aggregation status/counts derive from result items'
Assert-Contains -Text $runnerText -Pattern 'failedCount = @\(\$results \| Where-Object \{ \$_.STATUS -ne ''PASS'' \}\)\.Count' -Label 'failed count from results'
Assert-Contains -Text $runnerText -Pattern 'passedCount = \$results\.Count - \$failedCount' -Label 'passed count from results'
Assert-Contains -Text $runnerText -Pattern 'overallExitCode = if \(\$failedCount -gt 0\) \{ 1 \} else \{ 0 \}' -Label 'status from failed count'

Write-Output 'Running US3 test: docs validators execute cleanly in docs-only scope'
$validators = Get-ChildItem -Path (Join-Path $RepoRoot 'tests') -Filter 'validate_*_docs.ps1' |
    Sort-Object Name |
    ForEach-Object { $_.FullName }

if ($validators.Count -lt 1) {
    throw 'Expected at least one docs validator script.'
}

$failures = @()
foreach ($validator in $validators) {
    $result = Invoke-DocsValidator -ValidatorPath $validator
    if ($result.ExitCode -ne 0) {
        $failures += [PSCustomObject]@{
            Script = (Split-Path $validator -Leaf)
            Output = $result.Output.Trim()
        }
    }
}

if ($failures.Count -gt 0) {
    $details = ($failures | ForEach-Object { $_.Script + ': ' + $_.Output }) -join '; '
    throw ('Expected all docs validators to pass, failures: ' + $details)
}

Write-Output 'run_all_quality_checks_docs_only_regression: PASSED'
