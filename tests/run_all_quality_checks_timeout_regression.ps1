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
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('quality_runner_timeout_' + [System.Guid]::NewGuid().ToString('N'))
$tempTests = Join-Path $tempRoot 'tests'

New-Item -ItemType Directory -Path $tempTests -Force | Out-Null

try {
    @'
#!/usr/bin/env pwsh
Start-Sleep -Seconds 3
Write-Output 'slow script completed'
exit 0
'@ | Set-Content -Path (Join-Path $tempTests '001_slow_regression.ps1') -Encoding UTF8

    @'
#!/usr/bin/env pwsh
Write-Output 'fast script completed'
exit 0
'@ | Set-Content -Path (Join-Path $tempTests '002_fast_regression.ps1') -Encoding UTF8

    @'
#!/usr/bin/env pwsh
Write-Output 'docs validator completed'
exit 0
'@ | Set-Content -Path (Join-Path $tempTests 'validate_smoke_docs.ps1') -Encoding UTF8

    Write-Output 'Running US1 test: timeout script is terminated and execution continues'
    $r1 = Invoke-Runner -RunnerPath $runner -TargetRepoRoot $tempRoot -RunnerArgs @('-Json', '-PerScriptTimeoutSec', '1')
    if ($r1.ExitCode -eq 0) { throw "Expected timeout scenario to fail. Output: $($r1.Output)" }
    $j1 = $r1.Output.Trim() | ConvertFrom-Json
    if ($j1.TIMED_OUT_SCRIPTS -lt 1) { throw 'Expected TIMED_OUT_SCRIPTS >= 1 in timeout scenario.' }
    if ($j1.FAILED_SCRIPTS -lt 1) { throw 'Expected FAILED_SCRIPTS >= 1 in timeout scenario.' }
    $slow = @($j1.RESULTS | Where-Object { $_.SCRIPT -eq '001_slow_regression.ps1' }) | Select-Object -First 1
    if (-not $slow) { throw 'Expected slow regression entry in RESULTS.' }
    if ($slow.STATUS -ne 'TIMEOUT') { throw "Expected slow script STATUS=TIMEOUT, actual=$($slow.STATUS)" }
    if (-not $slow.TIMED_OUT) { throw 'Expected slow script TIMED_OUT=true.' }
    $fast = @($j1.RESULTS | Where-Object { $_.SCRIPT -eq '002_fast_regression.ps1' }) | Select-Object -First 1
    if (-not $fast) { throw 'Expected fast regression entry in RESULTS.' }
    if ($fast.STATUS -ne 'PASS') { throw "Expected fast script PASS after timeout continuation, actual=$($fast.STATUS)" }

    Write-Output 'Running US2 test: timeout metadata appears in text output'
    $r2 = Invoke-Runner -RunnerPath $runner -TargetRepoRoot $tempRoot -RunnerArgs @('-PerScriptTimeoutSec', '1')
    if ($r2.Output -notmatch '--- TIMEOUT 001_slow_regression.ps1') { throw 'Expected TIMEOUT marker in text output.' }
    if ($r2.Output -notmatch 'timed_out_scripts:\s*1') { throw 'Expected timed_out_scripts summary in text output.' }

    Write-Output 'Running US3 test: disabling timeout keeps legacy behavior'
    $r3 = Invoke-Runner -RunnerPath $runner -TargetRepoRoot $tempRoot -RunnerArgs @('-Json', '-PerScriptTimeoutSec', '0')
    if ($r3.ExitCode -ne 0) { throw "Expected success with timeout disabled. Output: $($r3.Output)" }
    $j3 = $r3.Output.Trim() | ConvertFrom-Json
    if ($j3.TIMED_OUT_SCRIPTS -ne 0) { throw 'Expected TIMED_OUT_SCRIPTS=0 when timeout disabled.' }
    if ($j3.STATUS -ne 'PASSED') { throw "Expected PASSED with timeout disabled, actual=$($j3.STATUS)" }

    Write-Output 'run_all_quality_checks_timeout_regression: PASSED'
}
finally {
    if (Test-Path $tempRoot) {
        Remove-Item -Path $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
