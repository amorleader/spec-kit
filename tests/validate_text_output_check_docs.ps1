#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

$spec = Join-Path $RepoRoot 'specs/884-stabilize-text-output/spec.md'
$plan = Join-Path $RepoRoot 'specs/884-stabilize-text-output/plan.md'
$contract = Join-Path $RepoRoot 'specs/884-stabilize-text-output/contracts/text-output-check-contract.md'
$quick = Join-Path $RepoRoot 'specs/884-stabilize-text-output/quickstart.md'

foreach ($file in @($spec, $plan, $contract, $quick)) {
    if (-not (Test-Path $file)) { throw "Missing doc: $file" }
}

$specText = Get-Content -Path $spec -Raw
$planText = Get-Content -Path $plan -Raw
$contractText = Get-Content -Path $contract -Raw
$quickText = Get-Content -Path $quick -Raw

$checks = @(
    @{ Name = 'spec mentions text output stability'; Pass = ($specText -match '文本模式输出稳定|text output') },
    @{ Name = 'plan mentions text mode constraints'; Pass = ($planText -match '文本模式|text mode') },
    @{ Name = 'contract includes failure text contract'; Pass = ($contractText -match 'Failure Text Contract') },
    @{ Name = 'quickstart includes text regression'; Pass = ($quickText -match 'text_output_check_regression') },
    @{ Name = 'quickstart includes docs-only aggregate'; Pass = ($quickText -match 'IncludeDocsOnly') }
)

$failed = @($checks | Where-Object { -not $_.Pass })
if ($failed.Count -gt 0) {
    $names = ($failed | ForEach-Object { $_.Name }) -join '; '
    Write-Output ("validate_text_output_check_docs: FAILED -> " + $names)
    exit 1
}

Write-Output 'validate_text_output_check_docs: PASSED'
