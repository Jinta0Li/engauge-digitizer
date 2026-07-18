[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$QtRoot,

    [Parameter(Mandatory = $true)]
    [string]$FftwRoot,

    [string]$BuildDirectory = "build-windows",

    [ValidateSet("release", "debug")]
    [string]$Configuration = "release",

    [switch]$CompileTranslations
)

$ErrorActionPreference = "Stop"

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$qtRootPath = (Resolve-Path $QtRoot).Path
$fftwRootPath = (Resolve-Path $FftwRoot).Path
if ([System.IO.Path]::IsPathRooted($BuildDirectory)) {
    $buildDirectoryPath = [System.IO.Path]::GetFullPath($BuildDirectory)
}
else {
    $buildDirectoryPath = [System.IO.Path]::GetFullPath(
        (Join-Path (Get-Location).Path $BuildDirectory))
}

$qmake = Join-Path $qtRootPath "bin\qmake.exe"
$lrelease = Join-Path $qtRootPath "bin\lrelease.exe"
$fftwHeader = Join-Path $fftwRootPath "include\fftw3.h"
$fftwDefinition = Join-Path $fftwRootPath "lib\libfftw3-3.def"
$fftwImportLibrary = Join-Path $fftwRootPath "lib\libfftw3-3.lib"
$fftwRuntime = Join-Path $fftwRootPath "lib\libfftw3-3.dll"

foreach ($requiredFile in @($qmake, $fftwHeader, $fftwRuntime)) {
    if (-not (Test-Path $requiredFile -PathType Leaf)) {
        throw "Required build file was not found: $requiredFile"
    }
}

$vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vswhere -PathType Leaf)) {
    throw "Visual Studio Installer tool was not found: $vswhere"
}

$visualStudioRoot = & $vswhere -latest -products * `
    -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    -property installationPath
if ($LASTEXITCODE -ne 0 -or -not $visualStudioRoot) {
    throw "Visual Studio 2022 with the C++ toolchain was not found."
}

$launchDevShell = Join-Path $visualStudioRoot "Common7\Tools\Launch-VsDevShell.ps1"
if (-not (Test-Path $launchDevShell -PathType Leaf)) {
    throw "Visual Studio developer shell was not found: $launchDevShell"
}

& $launchDevShell -Arch amd64 -HostArch amd64 -SkipAutomaticLocation
if ($LASTEXITCODE -ne 0) {
    throw "Visual Studio developer shell initialization failed."
}

if (-not (Test-Path $fftwImportLibrary -PathType Leaf)) {
    if (-not (Test-Path $fftwDefinition -PathType Leaf)) {
        throw "FFTW import library and module definition were both missing."
    }

    & lib.exe /NOLOGO /MACHINE:X64 "/DEF:$fftwDefinition" "/OUT:$fftwImportLibrary"
    if ($LASTEXITCODE -ne 0) {
        throw "Creating the FFTW import library failed with exit code $LASTEXITCODE."
    }
}

New-Item -ItemType Directory -Force $buildDirectoryPath | Out-Null
$env:FFTW_HOME = $fftwRootPath
$msbuildConfiguration = if ($Configuration -eq "release") { "Release" } else { "Debug" }

Push-Location $buildDirectoryPath
try {
    & $qmake -tp vc `
        (Join-Path $repositoryRoot "engauge.pro") `
        "CONFIG+=$Configuration" `
        "CONFIG+=log4cpp_null" `
        "QMAKE_CXXFLAGS+=/MP"
    if ($LASTEXITCODE -ne 0) {
        throw "qmake failed with exit code $LASTEXITCODE."
    }

    & msbuild.exe .\Engauge.vcxproj `
        /NOLOGO `
        /M `
        /T:Build `
        "/P:Configuration=$msbuildConfiguration" `
        /P:Platform=x64
    if ($LASTEXITCODE -ne 0) {
        throw "MSBuild failed with exit code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}

if ($CompileTranslations) {
    if (-not (Test-Path $lrelease -PathType Leaf)) {
        throw "Qt translation compiler was not found: $lrelease"
    }

    & $lrelease (Join-Path $repositoryRoot "engauge.pro")
    if ($LASTEXITCODE -ne 0) {
        throw "lrelease failed with exit code $LASTEXITCODE."
    }
}

$executable = Join-Path $buildDirectoryPath "bin\Engauge.exe"
if (-not (Test-Path $executable -PathType Leaf)) {
    throw "Build completed without producing the expected executable: $executable"
}

Write-Host "Built $executable"
