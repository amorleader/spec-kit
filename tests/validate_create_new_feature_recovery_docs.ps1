#!/usr/bin/env pwsh

param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

$quickstart = Join-Path $RepoRoot 'specs/006-recover-missing-specs/quickstart.md'
$contract = Join-Path $RepoRoot 'specs/006-recover-missing-specs/contracts/create-new-feature-recovery-contract.md'
$spec = Join-Path $RepoRoot 'specs/006-recover-missing-specs/spec.md'

foreach ($file in @($quickstart, $contract, $spec)) {
    if (-not (Test-Path $file)) { throw "Missing required doc file: $file" }
}

$quickText = Get-Content $quickstart -Raw
$contractText = Get-Content $contract -Raw
$specText = Get-Content $spec -Raw

$checks = @(
    @{ Name = 'Quickstart recovery scenario present'; Pass = ($quickText -match '当前分支已存在但 specs 目录缺失') },
    @{ Name = 'Contract mentions existing branch recovery'; Pass = ($contractText -match 'Existing target branch') },
    @{ Name = 'Contract keeps JSON fields'; Pass = ($contractText -match 'BRANCH_NAME') },
    @{ Name = 'Spec mentions recovery contract'; Pass = ($specText -match 'Document Recovery Contract') }
)

$failed = @($checks | Where-Object { -not $_.Pass })
if ($failed.Count -gt 0) {
    $names = ($failed | ForEach-Object { $_.Name }) -join '; '
    Write-Output "validate_create_new_feature_recovery_docs: FAILED -> $names"
    exit 1
}

Write-Output 'validate_create_new_feature_recovery_docs: PASSED'
