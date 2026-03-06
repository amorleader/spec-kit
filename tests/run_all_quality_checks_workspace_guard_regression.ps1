#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

function Invoke-Runner {
    param(
        [string]$RunnerPath,
        [string]$TargetRepoRoot,
        [string[]]$RunnerArgs
    )

    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & powershell -ExecutionPolicy Bypass -File $RunnerPath -RepoRoot $TargetRepoRoot @RunnerArgs 2>&1
        [PSCustomObject]@{ ExitCode = $LASTEXITCODE; Output = ($out | Out-String) }
    } finally {
        $ErrorActionPreference = $old
    }
}

$runner = Join-Path $RepoRoot 'tests/run_all_quality_checks.ps1'
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('quality_runner_workspace_' + [System.Guid]::NewGuid().ToString('N'))
$tempTests = Join-Path $tempRoot 'tests'

New-Item -ItemType Directory -Path $tempTests -Force | Out-Null

Push-Location $tempRoot
try {
    git init | Out-Null
    git config user.email "test@example.com" | Out-Null
    git config user.name "test" | Out-Null

    @'
base line
'@ | Set-Content -Path 'tracked.txt' -Encoding Ascii
    git add tracked.txt | Out-Null
    git commit -m "init" | Out-Null

    @'
Add-Content -Path (Join-Path $PSScriptRoot '..\tracked.txt') -Value 'pollution'
Set-Content -Path (Join-Path $PSScriptRoot '..\tracked.txt.us1.bak') -Value 'tmp'
Write-Output 'pollution script executed'
exit 0
'@ | Set-Content -Path (Join-Path $tempTests '001_pollute_regression.ps1') -Encoding Ascii

    @'
Write-Output 'docs validator completed'
exit 0
'@ | Set-Content -Path (Join-Path $tempTests '002_smoke_regression.ps1') -Encoding Ascii

    Write-Output 'Running US1 test: newly introduced pollution is cleaned'
    $baselineStatus = git status --short | Out-String
    $r1 = Invoke-Runner -RunnerPath $runner -TargetRepoRoot $tempRoot -RunnerArgs @('-Json')
    if ($r1.ExitCode -ne 0) { throw "Expected runner success. Output: $($r1.Output)" }
    $j1 = $r1.Output.Trim() | ConvertFrom-Json
    if ($j1.RECOVERED_TRACKED_CHANGES -lt 1) { throw 'Expected RECOVERED_TRACKED_CHANGES >= 1.' }
    if ($j1.DELETED_TEMP_FILES -lt 1) { throw 'Expected DELETED_TEMP_FILES >= 1.' }
    $statusAfter = git status --short | Out-String
    if ($statusAfter -ne $baselineStatus) {
        throw "Expected workspace status unchanged after recovery. Before: $baselineStatus After: $statusAfter"
    }

    Write-Output 'Running US2 test: existing changes are preserved'
    Add-Content -Path 'tracked.txt' -Value 'pre-existing'
    $r2 = Invoke-Runner -RunnerPath $runner -TargetRepoRoot $tempRoot -RunnerArgs @('-Json')
    if ($r2.ExitCode -ne 0) { throw "Expected runner success with pre-existing change. Output: $($r2.Output)" }
    $after = git status --short | Out-String
    if ($after -notmatch 'tracked.txt') { throw 'Expected pre-existing tracked change to remain.' }
    if ($after -match 'tracked.txt.us1.bak') { throw 'Expected newly created bak file to be removed.' }

    Write-Output 'run_all_quality_checks_workspace_guard_regression: PASSED'
}
finally {
    Pop-Location
    if (Test-Path $tempRoot) {
        Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
