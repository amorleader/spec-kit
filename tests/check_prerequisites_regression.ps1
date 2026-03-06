#!/usr/bin/env pwsh

param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

$scriptPath = Join-Path $RepoRoot '.specify/scripts/powershell/check-prerequisites.ps1'
. (Join-Path $RepoRoot 'tests/helpers/assert_check_prerequisites_json.ps1')

function Invoke-CheckPrerequisitesJson {
    param(
        [switch]$RequireTasks,
        [switch]$IncludeTasks
    )

    $args = @('-ExecutionPolicy', 'Bypass', '-File', $scriptPath, '-Json')
    if ($RequireTasks) { $args += '-RequireTasks' }
    if ($IncludeTasks) { $args += '-IncludeTasks' }

    $output = & powershell @args
    if ($LASTEXITCODE -ne 0) {
        throw "check-prerequisites failed with exit code $LASTEXITCODE"
    }

    return ($output | Select-Object -Last 1)
}

function Invoke-CheckPrerequisitesRaw {
    param(
        [switch]$RequireTasks,
        [switch]$IncludeTasks
    )

    $args = @('-ExecutionPolicy', 'Bypass', '-File', $scriptPath, '-Json')
    if ($RequireTasks) { $args += '-RequireTasks' }
    if ($IncludeTasks) { $args += '-IncludeTasks' }

    $previousEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & powershell @args 2>&1
        return [PSCustomObject]@{
            ExitCode = $LASTEXITCODE
            Output   = ($output | Out-String)
        }
    } finally {
        $ErrorActionPreference = $previousEap
    }
}

function Assert-ContainsText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Expected,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if ($Text -notmatch [Regex]::Escape($Expected)) {
        throw "Assertion failed ($Label): expected text '$Expected' not found."
    }
}

Write-Output 'Running US1 test: JSON output contains required fields'
 $previousFeatureEnv = $env:SPECIFY_FEATURE
 $env:SPECIFY_FEATURE = '004-improve-check-prerequisites'
 try {
    $jsonDefault = Invoke-CheckPrerequisitesJson
    Assert-CheckPrerequisitesJson -JsonText $jsonDefault | Out-Null

    Write-Output 'Running US1 test: AVAILABLE_DOCS remains array with IncludeTasks mode'
    $jsonWithTasks = Invoke-CheckPrerequisitesJson -RequireTasks -IncludeTasks
    Assert-CheckPrerequisitesJson -JsonText $jsonWithTasks | Out-Null

    $featureDir = Join-Path $RepoRoot 'specs/004-improve-check-prerequisites'
    $planFile = Join-Path $featureDir 'plan.md'
    $planBackup = Join-Path $featureDir 'plan.md.bak'
    $tasksFile = Join-Path $featureDir 'tasks.md'
    $tasksBackup = Join-Path $featureDir 'tasks.md.bak'

    Write-Output 'Running US2 test: missing plan returns non-zero and actionable message'
    if (Test-Path $planBackup) { Remove-Item -Path $planBackup -Force }
    Move-Item -Path $planFile -Destination $planBackup
    try {
        $resultMissingPlan = Invoke-CheckPrerequisitesRaw
        if ($resultMissingPlan.ExitCode -eq 0) {
            throw 'Expected non-zero exit code when plan.md is missing.'
        }
        Assert-ContainsText -Text $resultMissingPlan.Output -Expected 'plan.md not found' -Label 'missing-plan message'
    } finally {
        Move-Item -Path $planBackup -Destination $planFile -Force
    }

    Write-Output 'Running US2 test: require tasks mode fails when tasks.md missing'
    if (Test-Path $tasksBackup) { Remove-Item -Path $tasksBackup -Force }
    Move-Item -Path $tasksFile -Destination $tasksBackup
    try {
        $resultMissingTasks = Invoke-CheckPrerequisitesRaw -RequireTasks -IncludeTasks
        if ($resultMissingTasks.ExitCode -eq 0) {
            throw 'Expected non-zero exit code when tasks.md is missing in require-tasks mode.'
        }
        Assert-ContainsText -Text $resultMissingTasks.Output -Expected 'tasks.md not found' -Label 'missing-tasks message'
    } finally {
        Move-Item -Path $tasksBackup -Destination $tasksFile -Force
    }
 } finally {
    $env:SPECIFY_FEATURE = $previousFeatureEnv
 }

Write-Output 'check_prerequisites_regression: PASSED'
