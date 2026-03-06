#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

$quick = Join-Path $RepoRoot 'specs/011-json-warning-purity/quickstart.md'
$contract = Join-Path $RepoRoot 'specs/011-json-warning-purity/contracts/warning-stream-contract.md'
$spec = Join-Path $RepoRoot 'specs/011-json-warning-purity/spec.md'

foreach ($f in @($quick,$contract,$spec)) { if (-not (Test-Path $f)) { throw "Missing doc: $f" } }

$q = Get-Content $quick -Raw
$c = Get-Content $contract -Raw
$s = Get-Content $spec -Raw

$checks = @(
 @{Name='quickstart warning scenario';Pass=($q -match 'warning')},
 @{Name='contract json mode';Pass=($c -match 'JSON Mode')},
 @{Name='spec story';Pass=($s -match 'warning conditions')}
)
$failed = @($checks | Where-Object { -not $_.Pass })
if ($failed.Count -gt 0) { Write-Output ('validate_create_new_feature_warning_docs: FAILED -> ' + (($failed | ForEach-Object { $_.Name }) -join '; ')); exit 1 }
Write-Output 'validate_create_new_feature_warning_docs: PASSED'
