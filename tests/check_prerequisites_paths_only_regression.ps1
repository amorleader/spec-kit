#!/usr/bin/env pwsh

param([string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'

. (Join-Path $RepoRoot 'tests/helpers/check_prerequisites_paths_only_helper.ps1')

$baseTemp = Join-Path $env:TEMP 'check-prerequisites-paths-only-tests'
if (-not (Test-Path $baseTemp)) { New-Item -ItemType Directory -Path $baseTemp | Out-Null }

function Initialize-TestRepo {
  param([string]$Workspace)
  Push-Location $Workspace
  try {
    git init | Out-Null
    git config user.email 'test@example.com' | Out-Null
    git config user.name 'Test Runner' | Out-Null
    Set-Content -Path (Join-Path $Workspace 'README.md') -Value 'seed'
    git add README.md | Out-Null
    git commit -m 'seed' | Out-Null
    $hasMaster = (git branch --list master)
    if ($hasMaster) {
      git checkout master | Out-Null
    } else {
      git checkout -b master | Out-Null
    }
  } finally { Pop-Location }
}

function Invoke-Check {
  param([string]$Workspace, [string[]]$CommandArgs)
  $script = Join-Path $Workspace '.specify/scripts/powershell/check-prerequisites.ps1'
  Push-Location $Workspace
  try {
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
      $out = & powershell -ExecutionPolicy Bypass -File $script @CommandArgs 2>&1
      return [PSCustomObject]@{ ExitCode=$LASTEXITCODE; Output=($out | Out-String) }
    } finally { $ErrorActionPreference = $old }
  } finally { Pop-Location }
}

$ws = New-CheckPrerequisitesPathsOnlyWorkspace -BaseTempDir $baseTemp -ScenarioName 'non-feature-master'
Initialize-TestRepo -Workspace $ws

Write-Output 'Running US1 test: paths-only json succeeds on non-feature branch'
$r1 = Invoke-Check -Workspace $ws -CommandArgs @('-PathsOnly', '-Json')
if ($r1.ExitCode -ne 0) { throw "Expected success for PathsOnly JSON. Output: $($r1.Output)" }

Write-Output 'Running US1 test: paths-only text succeeds on non-feature branch'
$r2 = Invoke-Check -Workspace $ws -CommandArgs @('-PathsOnly')
if ($r2.ExitCode -ne 0) { throw "Expected success for PathsOnly text. Output: $($r2.Output)" }

Write-Output 'Running US2 test: normal mode still fails on non-feature branch'
$r3 = Invoke-Check -Workspace $ws -CommandArgs @('-Json')
if ($r3.ExitCode -eq 0) { throw 'Expected failure for normal mode on non-feature branch.' }

Write-Output 'Running US2 test: normal mode require tasks still fails on non-feature branch'
$r4 = Invoke-Check -Workspace $ws -CommandArgs @('-Json', '-RequireTasks', '-IncludeTasks')
if ($r4.ExitCode -eq 0) { throw 'Expected failure for normal mode with tasks on non-feature branch.' }

Write-Output 'check_prerequisites_paths_only_regression: PASSED'
