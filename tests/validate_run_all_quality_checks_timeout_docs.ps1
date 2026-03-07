#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

$quick = Join-Path $RepoRoot 'specs/019-runner-timeout-guard/quickstart.md'
$contract = Join-Path $RepoRoot 'specs/019-runner-timeout-guard/contracts/quality-runner-timeout-contract.md'
$spec = Join-Path $RepoRoot 'specs/019-runner-timeout-guard/spec.md'

foreach ($f in @($quick, $contract, $spec)) {
    if (-not (Test-Path $f)) { throw "Missing doc: $f" }
}

$q = Get-Content $quick -Raw
$c = Get-Content $contract -Raw
$s = Get-Content $spec -Raw

$checks = @(
    @{ Name = 'quickstart timeout option'; Pass = ($q -match 'PerScriptTimeoutSec') },
    @{ Name = 'contract timeout json field'; Pass = ($c -match 'TIMED_OUT_SCRIPTS') },
    @{ Name = 'spec timeout story'; Pass = ($s -match '超时|timeout') }
)

$failed = @($checks | Where-Object { -not $_.Pass })
if ($failed.Count -gt 0) {
    Write-Output ('validate_run_all_quality_checks_timeout_docs: FAILED -> ' + (($failed | ForEach-Object { $_.Name }) -join '; '))
    exit 1
}

Write-Output 'validate_run_all_quality_checks_timeout_docs: PASSED'
