[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SetupExecutable,

    [string]$InstallDirectory = (Join-Path `
        ([System.IO.Path]::GetTempPath()) `
        "engauge-installer-test-$PID"),

    [ValidateRange(1, 60)]
    [int]$SmokeTestSeconds = 5
)

$ErrorActionPreference = "Stop"

function Invoke-ProcessAndCheck {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string[]]$ArgumentList
    )

    $process = Start-Process `
        -FilePath $FilePath `
        -ArgumentList $ArgumentList `
        -WindowStyle Hidden `
        -Wait `
        -PassThru
    if ($process.ExitCode -ne 0) {
        throw "$FilePath failed with exit code $($process.ExitCode)."
    }
}

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
$isElevated = $principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)

$setupPath = (Resolve-Path $SetupExecutable).Path
$installDirectoryPath = [System.IO.Path]::GetFullPath($InstallDirectory)
$tempDirectoryPath = [System.IO.Path]::GetFullPath(
    [System.IO.Path]::GetTempPath())
$tempPrefix = $tempDirectoryPath.TrimEnd('\', '/') + `
    [System.IO.Path]::DirectorySeparatorChar
if (-not $installDirectoryPath.StartsWith(
        $tempPrefix,
        [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Installer test directory must be inside the current temp directory."
}
if (Test-Path $installDirectoryPath) {
    throw "Installer test directory already exists: $installDirectoryPath"
}

$uninstaller = Join-Path $installDirectoryPath "unins000.exe"
$application = Join-Path $installDirectoryPath "Engauge.exe"
$testFailure = $null

try {
    $setupArguments = @(
        "/VERYSILENT",
        "/SUPPRESSMSGBOXES",
        "/NORESTART",
        "/SP-",
        "/NOICONS",
        "/NoFileAssociation=1",
        "/DIR=`"$installDirectoryPath`""
    )
    if (-not $isElevated) {
        $setupArguments += "/CURRENTUSER"
    }
    Invoke-ProcessAndCheck $setupPath $setupArguments

    $requiredFiles = @(
        "Engauge.exe",
        "libfftw3-3.dll",
        "Qt6Core.dll",
        "Qt6Help.dll",
        "Qt6Widgets.dll",
        "platforms\qwindows.dll",
        "documentation\engauge.qch",
        "documentation\engauge.qhc",
        "translations\qt_zh_CN.qm",
        "translations\qt_zh_TW.qm",
        "unins000.exe"
    )
    $missingFiles = $requiredFiles | Where-Object {
        -not (Test-Path (Join-Path $installDirectoryPath $_) -PathType Leaf)
    }
    if ($missingFiles) {
        throw "Installer omitted required files: $($missingFiles -join ', ')."
    }

    $engaugeTranslations = @(Get-ChildItem `
        (Join-Path $installDirectoryPath "translations\engauge_*.qm"))
    if ($engaugeTranslations.Count -ne 18) {
        throw "Expected 18 Engauge translations, found $($engaugeTranslations.Count)."
    }

    $savedPath = $env:Path
    $savedQtPluginPath = $env:QT_PLUGIN_PATH
    $savedQmlImportPath = $env:QML2_IMPORT_PATH
    $savedEngaugeSettingsDirectory = $env:ENGAUGE_SETTINGS_DIR
    $smokeSettingsDirectory = [System.IO.Path]::GetFullPath((Join-Path `
        $tempDirectoryPath `
        "engauge-installed-smoke-$([guid]::NewGuid().ToString('N'))"))
    if (-not $smokeSettingsDirectory.StartsWith(
            $tempPrefix,
            [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Smoke-test settings directory escaped the temp directory."
    }
    New-Item -ItemType Directory $smokeSettingsDirectory | Out-Null
    $applicationProcess = $null
    try {
        $env:Path = "$env:SystemRoot\System32;$env:SystemRoot"
        $env:ENGAUGE_SETTINGS_DIR = $smokeSettingsDirectory
        Remove-Item Env:\QT_PLUGIN_PATH -ErrorAction SilentlyContinue
        Remove-Item Env:\QML2_IMPORT_PATH -ErrorAction SilentlyContinue
        $applicationProcess = Start-Process `
            -FilePath $application `
            -WorkingDirectory $installDirectoryPath `
            -WindowStyle Hidden `
            -PassThru
        Start-Sleep -Seconds $SmokeTestSeconds
        if ($applicationProcess.HasExited) {
            throw "Installed Engauge exited during startup with code $($applicationProcess.ExitCode)."
        }
    }
    finally {
        if ($applicationProcess -and -not $applicationProcess.HasExited) {
            Stop-Process -Id $applicationProcess.Id -Force
            Wait-Process -Id $applicationProcess.Id -ErrorAction SilentlyContinue
        }
        $env:Path = $savedPath
        if ($null -eq $savedQtPluginPath) {
            Remove-Item Env:\QT_PLUGIN_PATH -ErrorAction SilentlyContinue
        }
        else {
            $env:QT_PLUGIN_PATH = $savedQtPluginPath
        }
        if ($null -eq $savedQmlImportPath) {
            Remove-Item Env:\QML2_IMPORT_PATH -ErrorAction SilentlyContinue
        }
        else {
            $env:QML2_IMPORT_PATH = $savedQmlImportPath
        }
        if ($null -eq $savedEngaugeSettingsDirectory) {
            Remove-Item Env:\ENGAUGE_SETTINGS_DIR -ErrorAction SilentlyContinue
        }
        else {
            $env:ENGAUGE_SETTINGS_DIR = $savedEngaugeSettingsDirectory
        }
        Remove-Item `
            -LiteralPath $smokeSettingsDirectory `
            -Recurse `
            -Force
    }
}
catch {
    $testFailure = $_
}
finally {
    if (Test-Path $uninstaller -PathType Leaf) {
        Invoke-ProcessAndCheck $uninstaller @(
            "/VERYSILENT",
            "/SUPPRESSMSGBOXES",
            "/NORESTART"
        )
        Start-Sleep -Seconds 2
    }
}

if ($testFailure) {
    throw $testFailure
}
if (Test-Path $application -PathType Leaf) {
    throw "Uninstaller left the application executable behind: $application"
}

Write-Host "Installer validation passed: install, launch, and uninstall."
