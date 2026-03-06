#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

$quick = Join-Path $RepoRoot 'specs/020-runner-workspace-guard/quickstart.md'
$contract = Join-Path $RepoRoot 'specs/020-runner-workspace-guard/contracts/quality-runner-workspace-guard-contract.md'
$spec = Join-Path $RepoRoot 'specs/020-runner-workspace-guard/spec.md'

foreach ($f in @($quick, $contract, $spec)) {
    if (-not (Test-Path $f)) { throw "Missing doc: $f" }
}

$q = Get-Content $quick -Raw
$c = Get-Content $contract -Raw
$s = Get-Content $spec -Raw

$checks = @(
    @{ Name = 'quickstart workspace guard regression'; Pass = ($q -match 'workspace_guard_regression') },
    @{ Name = 'contract json recovery fields'; Pass = ($c -match 'RECOVERED_TRACKED_CHANGES' -and $c -match 'DELETED_TEMP_FILES') },
    @{ Name = 'spec existing changes preserved'; Pass = ($s -match '已有|existing') }
)

$failed = @($checks | Where-Object { -not $_.Pass })
if ($failed.Count -gt 0) {
    Write-Output ('validate_run_all_quality_checks_workspace_guard_docs: FAILED -> ' + (($failed | ForEach-Object { $_.Name }) -join '; '))
    exit 1
}

Write-Output 'validate_run_all_quality_checks_workspace_guard_docs: PASSED'
