#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

$quick = Join-Path $RepoRoot 'specs/007-allow-check-prerequisites/quickstart.md'
$contract = Join-Path $RepoRoot 'specs/007-allow-check-prerequisites/contracts/paths-only-contract.md'
$spec = Join-Path $RepoRoot 'specs/007-allow-check-prerequisites/spec.md'

foreach ($f in @($quick, $contract, $spec)) { if (-not (Test-Path $f)) { throw "Missing doc: $f" } }

$q = Get-Content $quick -Raw
$c = Get-Content $contract -Raw
$s = Get-Content $spec -Raw

$checks = @(
  @{ Name='quickstart paths-only'; Pass=($q -match 'PathsOnly') },
  @{ Name='contract normal mode'; Pass=($c -match 'Normal Mode Guardrail') },
  @{ Name='spec user story'; Pass=($s -match 'PathsOnly Works Everywhere') }
)
$failed = @($checks | Where-Object { -not $_.Pass })
if ($failed.Count -gt 0) { Write-Output ('validate_check_prerequisites_paths_only_docs: FAILED -> ' + (($failed | ForEach-Object { $_.Name }) -join '; ')); exit 1 }
Write-Output 'validate_check_prerequisites_paths_only_docs: PASSED'
