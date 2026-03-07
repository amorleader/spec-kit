#!/usr/bin/env pwsh

param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [switch]$IncludeGit,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

. (Join-Path $RepoRoot 'tests/helpers/process_hygiene.ps1')

$result = Remove-TestZombieProcesses -RepoRoot $RepoRoot -ExcludeProcessId $PID -IncludeGit:$IncludeGit

if ($Json) {
    [PSCustomObject][ordered]@{
        REPO_ROOT    = $RepoRoot
        KILLED_COUNT = $result.KilledCount
        FAILED_COUNT = $result.FailedCount
        STATUS       = if ($result.FailedCount -eq 0) { 'OK' } else { 'PARTIAL' }
        KILLED       = $result.Killed | ForEach-Object {
            [PSCustomObject]@{ PID = $_.PID; NAME = $_.Name }
        }
        FAILED       = $result.Failed | ForEach-Object {
            [PSCustomObject]@{ PID = $_.PID; NAME = $_.Name; RETURN_CODE = $_.ReturnCode }
        }
    } | ConvertTo-Json -Compress
} else {
    Write-Output ("cleanup_test_zombie_processes: killed={0} failed={1}" -f $result.KilledCount, $result.FailedCount)
    if ($result.KilledCount -gt 0) {
        $result.Killed | ForEach-Object {
            Write-Output ("  - killed pid={0} name={1}" -f $_.PID, $_.Name)
        }
    }
    if ($result.FailedCount -gt 0) {
        $result.Failed | ForEach-Object {
            Write-Warning ("failed pid={0} name={1} return={2}" -f $_.PID, $_.Name, $_.ReturnCode)
        }
        exit 1
    }
}
