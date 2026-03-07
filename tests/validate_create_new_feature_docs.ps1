#!/usr/bin/env pwsh

param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

$quickstart = Join-Path $RepoRoot 'specs/005-fix-create-new/quickstart.md'
$contract = Join-Path $RepoRoot 'specs/005-fix-create-new/contracts/create-new-feature-arg-contract.md'
$spec = Join-Path $RepoRoot 'specs/005-fix-create-new/spec.md'

foreach ($file in @($quickstart, $contract, $spec)) {
    if (-not (Test-Path $file)) {
        throw "Missing required doc file: $file"
    }
}

$quickText = Get-Content $quickstart -Raw
$contractText = Get-Content $contract -Raw
$specText = Get-Content $spec -Raw

$checks = @(
    @{ Name = 'Quickstart has Json-first example'; Pass = ($quickText -match 'create-new-feature\.ps1 -Json') },
    @{ Name = 'Quickstart has desc-first example'; Pass = ($quickText -match 'create-new-feature\.ps1 "demo feature description" -Json') },
    @{ Name = 'Contract has BRANCH_NAME'; Pass = ($contractText -match 'BRANCH_NAME') },
    @{ Name = 'Contract has SPEC_FILE'; Pass = ($contractText -match 'SPEC_FILE') },
    @{ Name = 'Spec mentions deterministic option parsing'; Pass = ($specText -match 'Deterministic Option Parsing') }
)

$failed = @($checks | Where-Object { -not $_.Pass })
if ($failed.Count -gt 0) {
    $names = ($failed | ForEach-Object { $_.Name }) -join '; '
    Write-Output "validate_create_new_feature_docs: FAILED -> $names"
    exit 1
}

Write-Output 'validate_create_new_feature_docs: PASSED'
