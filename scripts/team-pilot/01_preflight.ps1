param(
    [string]$JavaHome = "",
    [string]$MavenCommand = "mvn"
)

$ErrorActionPreference = "Stop"

if ($JavaHome -ne "") {
    $env:JAVA_HOME = $JavaHome
    $env:Path = "$JavaHome\bin;$env:Path"
}

Write-Host "[preflight] Checking java..."
java -version

Write-Host "[preflight] Checking maven..."
& $MavenCommand -v

Write-Host "[preflight] OK"
