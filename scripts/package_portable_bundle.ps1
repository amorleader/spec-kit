param(
    [string]$ProjectRoot = ".",
    [string]$DistDir = "dist/portable",
    [string]$JavaHome = "",
    [switch]$SkipTests,
    [switch]$NoRuntime
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-CommandExists {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found in PATH."
    }
}

$root = Resolve-Path $ProjectRoot
Assert-CommandExists -Name "mvn"

Push-Location $root
try {
    $skipTestsValue = if ($SkipTests) { "true" } else { "false" }
    & mvn ("-DskipTests=" + $skipTestsValue) "clean" "package"
    if ($LASTEXITCODE -ne 0) {
        throw "Maven build failed."
    }

    $targetDir = Join-Path $root "target"
    $jar = Get-ChildItem -Path $targetDir -Filter "*.jar" | Where-Object { $_.Name -notlike "original-*" } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($null -eq $jar) {
        throw "Packaged JAR not found in target/."
    }

    $dist = if ([System.IO.Path]::IsPathRooted($DistDir)) { $DistDir } else { Join-Path $root $DistDir }
    if (Test-Path $dist) {
        Remove-Item -Path $dist -Recurse -Force
    }
    New-Item -ItemType Directory -Path $dist | Out-Null

    Copy-Item -Path $jar.FullName -Destination (Join-Path $dist "app.jar") -Force
    Copy-Item -Path (Join-Path $root "src\main\resources\static") -Destination (Join-Path $dist "static") -Recurse -Force

    $runtimeDir = Join-Path $dist "runtime"
    if (-not $NoRuntime) {
        $resolvedJavaHome = $JavaHome
        if ([string]::IsNullOrWhiteSpace($resolvedJavaHome)) {
            $resolvedJavaHome = $env:JAVA_HOME
        }
        if ([string]::IsNullOrWhiteSpace($resolvedJavaHome) -or -not (Test-Path (Join-Path $resolvedJavaHome "bin\java.exe"))) {
            throw "JAVA_HOME is not set to a valid JDK/JRE. Pass -JavaHome or set JAVA_HOME."
        }
        Copy-Item -Path $resolvedJavaHome -Destination $runtimeDir -Recurse -Force
    }

    $runBat = @(
        '@echo off',
        'setlocal',
        'set APP_DIR=%~dp0',
        'if exist "%APP_DIR%runtime\\bin\\java.exe" (',
        '  "%APP_DIR%runtime\\bin\\java.exe" -jar "%APP_DIR%app.jar"',
        ') else (',
        '  java -jar "%APP_DIR%app.jar"',
        ')'
    ) -join [Environment]::NewLine
    [System.IO.File]::WriteAllText((Join-Path $dist "run.bat"), $runBat, (New-Object System.Text.UTF8Encoding($false)))

    $runPs1 = @(
        '$ErrorActionPreference = ''Stop''',
        '$appDir = Split-Path -Parent $MyInvocation.MyCommand.Path',
        '$java = Join-Path $appDir ''runtime\\bin\\java.exe''',
        'if (Test-Path $java) {',
        '    & $java -jar (Join-Path $appDir ''app.jar'')',
        '} else {',
        '    & java -jar (Join-Path $appDir ''app.jar'')',
        '}'
    ) -join [Environment]::NewLine
    [System.IO.File]::WriteAllText((Join-Path $dist "run.ps1"), $runPs1, (New-Object System.Text.UTF8Encoding($false)))

    $zip = Join-Path (Split-Path $dist -Parent) "mhr-build-planner-portable.zip"
    if (Test-Path $zip) {
        Remove-Item -Path $zip -Force
    }
    Compress-Archive -Path (Join-Path $dist "*") -DestinationPath $zip -Force

    Write-Host "[portable] jar: $($jar.FullName)"
    Write-Host "[portable] dist: $dist"
    Write-Host "[portable] zip: $zip"
}
finally {
    Pop-Location
}
