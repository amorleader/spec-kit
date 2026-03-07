#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

$quick = Join-Path $RepoRoot 'specs/018-quality-runner-regression-coverage/quickstart.md'
$contract = Join-Path $RepoRoot 'specs/018-quality-runner-regression-coverage/contracts/quality-runner-regression-contract.md'
$spec = Join-Path $RepoRoot 'specs/018-quality-runner-regression-coverage/spec.md'

foreach ($f in @($quick,$contract,$spec)) { if (-not (Test-Path $f)) { throw "Missing doc: $f" } }

$q = Get-Content $quick -Raw
$c = Get-Content $contract -Raw
$s = Get-Content $spec -Raw

$checks = @(
 @{Name='quickstart json mode';Pass=($q -match '-Json')},
 @{Name='contract required fields';Pass=($c -match 'TOTAL_SCRIPTS' -and $c -match 'RESULTS')},
 @{Name='spec branch stability';Pass=($s -match 'branch')}
)
$failed = @($checks | Where-Object { -not $_.Pass })
if ($failed.Count -gt 0) { Write-Output ('validate_run_all_quality_checks_docs: FAILED -> ' + (($failed | ForEach-Object { $_.Name }) -join '; ')); exit 1 }
Write-Output 'validate_run_all_quality_checks_docs: PASSED'
