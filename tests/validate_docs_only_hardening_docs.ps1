#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

$spec = Join-Path $RepoRoot 'specs/885-harden-docs-only/spec.md'
$plan = Join-Path $RepoRoot 'specs/885-harden-docs-only/plan.md'
$research = Join-Path $RepoRoot 'specs/885-harden-docs-only/research.md'
$dataModel = Join-Path $RepoRoot 'specs/885-harden-docs-only/data-model.md'
$contract = Join-Path $RepoRoot 'specs/885-harden-docs-only/contracts/docs-only-aggregate-contract.md'
$quick = Join-Path $RepoRoot 'specs/885-harden-docs-only/quickstart.md'
$tasks = Join-Path $RepoRoot 'specs/885-harden-docs-only/tasks.md'

foreach ($file in @($spec, $plan, $research, $dataModel, $contract, $quick, $tasks)) {
    if (-not (Test-Path $file)) { throw "Missing doc: $file" }
}

$specText = Get-Content -Path $spec -Raw
$planText = Get-Content -Path $plan -Raw
$researchText = Get-Content -Path $research -Raw
$dataModelText = Get-Content -Path $dataModel -Raw
$contractText = Get-Content -Path $contract -Raw
$quickText = Get-Content -Path $quick -Raw
$tasksText = Get-Content -Path $tasks -Raw

$checks = @(
    @{ Name = 'spec defines docs-only stability story'; Pass = ($specText -match 'docs-only' -and $specText -match '输出契约稳定|output') },
    @{ Name = 'plan captures docs-only hardening summary'; Pass = ($planText -match 'docs-only' -and $planText -match '加固|hardening') },
    @{ Name = 'research captures docs-only decisions'; Pass = ($researchText -match 'docs-only' -and $researchText -match '契约|contract') },
    @{ Name = 'data model defines docs-only summary entities'; Pass = ($dataModelText -match 'DocsOnlySummary' -and $dataModelText -match 'DocsOnlyResultItem') },
    @{ Name = 'contract requires stable json fields'; Pass = ($contractText -match 'TOTAL_SCRIPTS' -and $contractText -match 'RESULTS' -and $contractText -match 'STATUS') },
    @{ Name = 'contract enforces docs-only result scope'; Pass = ($contractText -match 'RESULTS.*only docs validator|contains only docs validator') },
    @{ Name = 'quickstart references docs-only regression script'; Pass = ($quickText -match 'run_all_quality_checks_docs_only_regression\.ps1') },
    @{ Name = 'quickstart references docs-only docs validator'; Pass = ($quickText -match 'validate_docs_only_hardening_docs\.ps1') },
    @{ Name = 'quickstart references docs-only aggregate command'; Pass = ($quickText -match 'run_all_quality_checks\.ps1 -Json -IncludeDocsOnly') },
    @{ Name = 'tasks includes docs-only regression task'; Pass = ($tasksText -match 'T007' -and $tasksText -match 'run_all_quality_checks_docs_only_regression\.ps1') },
    @{ Name = 'tasks includes docs-only docs validator task'; Pass = ($tasksText -match 'T015' -and $tasksText -match 'validate_docs_only_hardening_docs\.ps1') }
)

$failed = @($checks | Where-Object { -not $_.Pass })
if ($failed.Count -gt 0) {
    $names = ($failed | ForEach-Object { $_.Name }) -join '; '
    Write-Output ('validate_docs_only_hardening_docs: FAILED -> ' + $names)
    exit 1
}

Write-Output 'validate_docs_only_hardening_docs: PASSED'
