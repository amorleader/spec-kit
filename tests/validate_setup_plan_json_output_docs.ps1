#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

$quick = Join-Path $RepoRoot 'specs/009-setup-plan-json-purity/quickstart.md'
$contract = Join-Path $RepoRoot 'specs/009-setup-plan-json-purity/contracts/json-output-contract.md'
$spec = Join-Path $RepoRoot 'specs/009-setup-plan-json-purity/spec.md'

foreach ($f in @($quick,$contract,$spec)) { if (-not (Test-Path $f)) { throw "Missing doc: $f" } }

$q = Get-Content $quick -Raw
$c = Get-Content $contract -Raw
$s = Get-Content $spec -Raw

$checks = @(
 @{Name='quickstart json mode';Pass=($q -match '-Json')},
 @{Name='contract json mode';Pass=($c -match 'JSON Mode')},
 @{Name='spec json story';Pass=($s -match 'Parseable JSON Only')}
)
$failed = @($checks | Where-Object { -not $_.Pass })
if ($failed.Count -gt 0) { Write-Output ('validate_setup_plan_json_output_docs: FAILED -> ' + (($failed | ForEach-Object { $_.Name }) -join '; ')); exit 1 }
Write-Output 'validate_setup_plan_json_output_docs: PASSED'
