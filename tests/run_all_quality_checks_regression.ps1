#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

. (Join-Path $RepoRoot 'tests/helpers/assert_run_all_quality_checks_json.ps1')

function Invoke-Runner {
    param([string[]]$RunnerArgs)

    $script = Join-Path $RepoRoot 'tests/run_all_quality_checks.ps1'
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & powershell -ExecutionPolicy Bypass -File $script @RunnerArgs 2>&1
        return [PSCustomObject]@{ ExitCode = $LASTEXITCODE; Output = ($out | Out-String) }
    } finally {
        $ErrorActionPreference = $old
    }
}

Write-Output 'Running US1 test: JSON mode emits parseable summary payload'
$r1 = Invoke-Runner -RunnerArgs @('-Json', '-IncludeDocsOnly')
if ($r1.ExitCode -ne 0) { throw "Expected success in JSON mode. Output: $($r1.Output)" }
$trim = $r1.Output.Trim()
if (-not $trim.StartsWith('{')) { throw 'Expected JSON mode output to start with {' }
Assert-RunAllQualityChecksJson -JsonText $trim | Out-Null

Write-Output 'Running US2 test: text mode keeps run/pass blocks and summary'
$r2 = Invoke-Runner -RunnerArgs @('-IncludeDocsOnly')
if ($r2.ExitCode -ne 0) { throw "Expected success in text mode. Output: $($r2.Output)" }
if ($r2.Output -notmatch '--- RUN ') { throw 'Expected RUN block in text mode output.' }
if ($r2.Output -notmatch '--- PASS ') { throw 'Expected PASS block in text mode output.' }
if ($r2.Output -notmatch 'run_all_quality_checks:\s*PASSED') { throw 'Expected PASSED summary line in text mode output.' }

Write-Output 'Running US3 test: runner preserves current branch after execution'
$before = (git -C $RepoRoot rev-parse --abbrev-ref HEAD).Trim()
$r3 = Invoke-Runner -RunnerArgs @('-Json', '-IncludeDocsOnly')
if ($r3.ExitCode -ne 0) { throw "Expected success in branch-stability check. Output: $($r3.Output)" }
$after = (git -C $RepoRoot rev-parse --abbrev-ref HEAD).Trim()
if ($before -ne $after) { throw "Expected branch to remain stable, before=$before after=$after" }

Write-Output 'run_all_quality_checks_regression: PASSED'
