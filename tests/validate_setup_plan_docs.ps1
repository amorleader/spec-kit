#!/usr/bin/env pwsh

param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

$quickstart = Join-Path $RepoRoot 'specs/003-prevent-setup-plan/quickstart.md'
$contract = Join-Path $RepoRoot 'specs/003-prevent-setup-plan/contracts/setup-plan-safe-overwrite-contract.md'
$spec = Join-Path $RepoRoot 'specs/003-prevent-setup-plan/spec.md'

$files = @($quickstart, $contract, $spec)
foreach ($file in $files) {
    if (-not (Test-Path $file)) {
        throw "Missing required doc file: $file"
    }
}

$quickText = Get-Content $quickstart -Raw
$contractText = Get-Content $contract -Raw
$specText = Get-Content $spec -Raw

$checks = @(
    @{ Name = 'Quickstart includes default mode command'; Pass = ($quickText -match 'setup-plan\.ps1 -Json') },
    @{ Name = 'Quickstart includes force mode command'; Pass = ($quickText -match 'setup-plan\.ps1 -Json -Force') },
    @{ Name = 'Contract includes ACTION preserved'; Pass = ($contractText -match 'ACTION:\s*preserved|preserved') },
    @{ Name = 'Contract includes ACTION overwritten'; Pass = ($contractText -match 'ACTION:\s*overwritten|overwritten') },
    @{ Name = 'Spec includes explicit overwrite control story'; Pass = ($specText -match 'Explicit Overwrite Control') }
)

$failed = @($checks | Where-Object { -not $_.Pass })
if ($failed.Count -gt 0) {
    $names = ($failed | ForEach-Object { $_.Name }) -join '; '
    Write-Output "validate_setup_plan_docs: FAILED -> $names"
    exit 1
}

Write-Output 'validate_setup_plan_docs: PASSED'
