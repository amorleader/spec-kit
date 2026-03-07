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
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('quality_runner_zmode_' + [System.Guid]::NewGuid().ToString('N'))
$tempTests = Join-Path $tempRoot 'tests'

New-Item -ItemType Directory -Path $tempTests -Force | Out-Null

Push-Location $tempRoot
try {
    git init | Out-Null
    git config user.email "test@example.com" | Out-Null
    git config user.name "test" | Out-Null

    @'
seed
'@ | Set-Content -Path 'old name with spaces.txt' -Encoding Ascii
    git add 'old name with spaces.txt' | Out-Null
    git commit -m "init" | Out-Null

    @'
git -C (Join-Path $PSScriptRoot '..') mv 'old name with spaces.txt' 'new name with spaces.txt' | Out-Null
Set-Content -Path (Join-Path $PSScriptRoot '..\new name with spaces.txt.tmp') -Value 'tmp'
Write-Output 'zmode rename pollution done'
exit 0
'@ | Set-Content -Path (Join-Path $tempTests '001_zmode_pollute_regression.ps1') -Encoding Ascii

    Write-Output 'Running US1 test: porcelain-z handles rename with spaced paths'
    $before = git status --short | Out-String
    $r1 = Invoke-Runner -RunnerPath $runner -TargetRepoRoot $tempRoot -RunnerArgs @('-Json')
    if ($r1.ExitCode -ne 0) { throw "Expected runner success. Output: $($r1.Output)" }
    $j1 = $r1.Output.Trim() | ConvertFrom-Json
    if ($j1.RECOVERED_TRACKED_CHANGES -lt 1) { throw 'Expected RECOVERED_TRACKED_CHANGES >= 1.' }
    if ($j1.DELETED_TEMP_FILES -lt 1) { throw 'Expected DELETED_TEMP_FILES >= 1.' }
    $after = git status --short | Out-String
    if ($after -ne $before) { throw "Expected workspace status unchanged. Before: $before After: $after" }

    Write-Output 'Running US2 test: docs-only output contract remains parseable'
    $r2 = Invoke-Runner -RunnerPath $runner -TargetRepoRoot $tempRoot -RunnerArgs @('-Json', '-IncludeDocsOnly')
    if ($r2.Output.Trim() -notmatch '^\{') { throw 'Expected JSON docs-only output to remain parseable.' }

    Write-Output 'run_all_quality_checks_status_parser_zmode_regression: PASSED'
}
finally {
    Pop-Location
    if (Test-Path $tempRoot) {
        Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
