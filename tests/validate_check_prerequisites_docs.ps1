#!/usr/bin/env pwsh

param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

$quickstart = Join-Path $RepoRoot 'specs/004-improve-check-prerequisites/quickstart.md'
$contract = Join-Path $RepoRoot 'specs/004-improve-check-prerequisites/contracts/check-prerequisites-output-contract.md'
$spec = Join-Path $RepoRoot 'specs/004-improve-check-prerequisites/spec.md'

foreach ($file in @($quickstart, $contract, $spec)) {
    if (-not (Test-Path $file)) {
        throw "Missing required doc file: $file"
    }
}

$quickText = Get-Content $quickstart -Raw
$contractText = Get-Content $contract -Raw
$specText = Get-Content $spec -Raw

$checks = @(
    @{ Name = 'Quickstart has default Json command'; Pass = ($quickText -match 'check-prerequisites\.ps1 -Json') },
    @{ Name = 'Quickstart has require tasks command'; Pass = ($quickText -match 'check-prerequisites\.ps1 -Json -RequireTasks -IncludeTasks') },
    @{ Name = 'Contract includes FEATURE_DIR field'; Pass = ($contractText -match 'FEATURE_DIR') },
    @{ Name = 'Contract includes AVAILABLE_DOCS array'; Pass = ($contractText -match 'AVAILABLE_DOCS') },
    @{ Name = 'Spec includes stable JSON contract story'; Pass = ($specText -match 'Stable JSON Contract') }
)

$failed = @($checks | Where-Object { -not $_.Pass })
if ($failed.Count -gt 0) {
    $names = ($failed | ForEach-Object { $_.Name }) -join '; '
    Write-Output "validate_check_prerequisites_docs: FAILED -> $names"
    exit 1
}

Write-Output 'validate_check_prerequisites_docs: PASSED'
