#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

$quick = Join-Path $RepoRoot 'specs/010-normalize-branch-numbering/quickstart.md'
$contract = Join-Path $RepoRoot 'specs/010-normalize-branch-numbering/contracts/numbering-contract.md'
$spec = Join-Path $RepoRoot 'specs/010-normalize-branch-numbering/spec.md'

foreach ($f in @($quick,$contract,$spec)) { if (-not (Test-Path $f)) { throw "Missing doc: $f" } }

$q = Get-Content $quick -Raw
$c = Get-Content $contract -Raw
$s = Get-Content $spec -Raw

$checks = @(
 @{Name='quickstart polluted scenario';Pass=($q -match '8034')},
 @{Name='contract three-digit rule';Pass=($c -match '\^\\d\{3\}-')},
 @{Name='spec p1 story';Pass=($s -match 'Ignore Non-standard Branch Numbers')}
)
$failed = @($checks | Where-Object { -not $_.Pass })
if ($failed.Count -gt 0) { Write-Output ('validate_create_new_feature_numbering_docs: FAILED -> ' + (($failed | ForEach-Object { $_.Name }) -join '; ')); exit 1 }
Write-Output 'validate_create_new_feature_numbering_docs: PASSED'
