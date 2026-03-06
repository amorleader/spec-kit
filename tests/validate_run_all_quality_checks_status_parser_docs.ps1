#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

$quick = Join-Path $RepoRoot 'specs/021-workspace-status-parser/quickstart.md'
$contract = Join-Path $RepoRoot 'specs/021-workspace-status-parser/contracts/quality-runner-status-parser-contract.md'
$spec = Join-Path $RepoRoot 'specs/021-workspace-status-parser/spec.md'

foreach ($file in @($quick, $contract, $spec)) {
    if (-not (Test-Path $file)) {
        throw "Missing doc: $file"
    }
}

$q = Get-Content -Path $quick -Raw
$c = Get-Content -Path $contract -Raw
$s = Get-Content -Path $spec -Raw

$checks = @(
    @{ Name = 'quickstart parser regression'; Pass = ($q -match 'status_parser_regression') },
    @{ Name = 'contract rename syntax'; Pass = ($c -match 'old -> new') },
    @{ Name = 'spec rename story'; Pass = ($s -match 'rename|workspace status parser') }
)

$failed = @($checks | Where-Object { -not $_.Pass })
if ($failed.Count -gt 0) {
    $names = ($failed | ForEach-Object { $_.Name }) -join '; '
    Write-Output ("validate_run_all_quality_checks_status_parser_docs: FAILED -> " + $names)
    exit 1
}

Write-Output 'validate_run_all_quality_checks_status_parser_docs: PASSED'
