function Remove-TestZombieProcesses {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoRoot,
        [int]$ExcludeProcessId = $PID,
        [switch]$IncludeGit
    )

    $killed = New-Object System.Collections.Generic.List[object]
    $failed = New-Object System.Collections.Generic.List[object]

    # Only target shells launched with explicit test script files from this repo.
    $repoPattern = [Regex]::Escape((Resolve-Path $RepoRoot).Path)
    $scriptHintPattern = '(?i)(-File\s+"?.*\\tests\\(?:run_all_quality_checks(?:_regression)?|.*_regression|validate_.*_docs|cleanup_test_zombie_processes)\.ps1"?)'

    $names = @('powershell.exe', 'pwsh.exe')
    if ($IncludeGit) {
        $names += 'git.exe'
    }

    $nameFilter = ($names | ForEach-Object { "Name='$_'" }) -join ' OR '
    $processes = @(Get-CimInstance Win32_Process -Filter $nameFilter)

    foreach ($proc in $processes) {
        $pid = [int]$proc.ProcessId
        if ($pid -eq $ExcludeProcessId) {
            continue
        }

        $cmd = [string]$proc.CommandLine
        if ([string]::IsNullOrWhiteSpace($cmd)) {
            continue
        }

        if ($cmd -notmatch $repoPattern) {
            continue
        }

        if ($cmd -notmatch $scriptHintPattern) {
            continue
        }

        try {
            $result = Invoke-CimMethod -InputObject $proc -MethodName Terminate
            if ($result.ReturnValue -eq 0) {
                $killed.Add([PSCustomObject]@{
                    PID     = $pid
                    Name    = $proc.Name
                    Command = $cmd
                }) | Out-Null
            } else {
                $failed.Add([PSCustomObject]@{
                    PID        = $pid
                    Name       = $proc.Name
                    ReturnCode = $result.ReturnValue
                    Command    = $cmd
                }) | Out-Null
            }
        } catch {
            $failed.Add([PSCustomObject]@{
                PID        = $pid
                Name       = $proc.Name
                ReturnCode = -1
                Command    = $cmd
                Error      = $_.Exception.Message
            }) | Out-Null
        }
    }

    [PSCustomObject]@{
        KilledCount = $killed.Count
        FailedCount = $failed.Count
        Killed      = @($killed)
        Failed      = @($failed)
    }
}
