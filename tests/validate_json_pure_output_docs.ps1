#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

$spec = Join-Path $RepoRoot 'specs/883-stabilize-json-pure/spec.md'
$plan = Join-Path $RepoRoot 'specs/883-stabilize-json-pure/plan.md'
$contract = Join-Path $RepoRoot 'specs/883-stabilize-json-pure/contracts/json-pure-output-contract.md'
$quick = Join-Path $RepoRoot 'specs/883-stabilize-json-pure/quickstart.md'

foreach ($file in @($spec, $plan, $contract, $quick)) {
    if (-not (Test-Path $file)) { throw "Missing doc: $file" }
}

$specText = Get-Content -Path $spec -Raw
$planText = Get-Content -Path $plan -Raw
$contractText = Get-Content -Path $contract -Raw
$quickText = Get-Content -Path $quick -Raw

$checks = @(
    @{ Name = 'spec mentions json purity'; Pass = ($specText -match 'JSON.*纯净|json pure|纯净输出') },
    @{ Name = 'plan mentions json mode'; Pass = ($planText -match '-Json|JSON') },
    @{ Name = 'contract defines one json document'; Pass = ($contractText -match 'one valid JSON document|exactly one valid JSON document|单个.*JSON') },
    @{ Name = 'quickstart includes json regression'; Pass = ($quickText -match 'json_pure_output_regression') },
    @{ Name = 'quickstart includes docs-only aggregate'; Pass = ($quickText -match 'IncludeDocsOnly') }
)

$failed = @($checks | Where-Object { -not $_.Pass })
if ($failed.Count -gt 0) {
    $names = ($failed | ForEach-Object { $_.Name }) -join '; '
    Write-Output ("validate_json_pure_output_docs: FAILED -> " + $names)
    exit 1
}

Write-Output 'validate_json_pure_output_docs: PASSED'
