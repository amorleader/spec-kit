param(
    [string]$JavaHome = "",
    [string]$MavenCommand = "mvn"
)

$ErrorActionPreference = "Stop"

if ($JavaHome -ne "") {
    $env:JAVA_HOME = $JavaHome
    $env:Path = "$JavaHome\bin;$env:Path"
}

Write-Host "[build] Running tests..."
& $MavenCommand -q -DskipTests=false test

Write-Host "[build] Running package..."
& $MavenCommand -q -DskipTests package

Write-Host "[build] Done"
