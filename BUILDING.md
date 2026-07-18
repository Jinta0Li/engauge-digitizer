# Building Engauge Digitizer

The maintained build baseline is Qt 6, C++17, and a 64-bit toolchain. qmake
remains the release and regression-test authority while the application target
is migrated to CMake in parallel.

The versions recorded here are a reproducible baseline, not a promise that newer
patch releases are incompatible. Dependency upgrades are intentionally tested in
separate changes.

## Windows baseline

- Windows 10 or 11, x64
- Visual Studio 2022 with the Desktop development with C++ workload
- Qt 6.8.3 `msvc2022_64`
- FFTW 3.3.5 double-precision library
- CMake 3.21.1 or newer and Ninja
- PowerShell 7 or Windows PowerShell 5.1

`FFTW_HOME` must contain `include/fftw3.h`, `lib/libfftw3-3.def` or
`lib/libfftw3-3.lib`, and `lib/libfftw3-3.dll`.

From the repository root, run:

```powershell
.\dev\windows\build_qmake_qt6.ps1 `
  -QtRoot C:\Qt\6.8.3\msvc2022_64 `
  -FftwRoot C:\Libraries\fftw-3.3.5 `
  -BuildDirectory .\build-windows `
  -CompileTranslations
```

The executable is written to `build-windows/bin/Engauge.exe`. The script locates
Visual Studio with `vswhere`, creates the FFTW import library when necessary,
uses qmake to generate a Visual Studio project, and builds it in parallel with
MSBuild. It uses the bundled null log4cpp implementation and does not create an
installer.

### Parallel CMake application build

Open **Developer PowerShell for VS 2022** in the repository root, then run:

```powershell
$env:QT_ROOT = 'C:\Qt\6.8.3\msvc2022_64'
$env:FFTW_HOME = 'C:\Libraries\fftw-3.3.5'
cmake --preset windows-msvc-release
cmake --build --preset windows-msvc-release
$env:Path = "$env:QT_ROOT\bin;$env:Path"
$env:QT_QPA_PLATFORM = 'offscreen'
ctest --preset windows-msvc-release
```

The executable, FFTW runtime, 18 compiled translation catalogs, and generated Qt
help collection are written under `cmake-build/windows-msvc-release/bin`. The
output directory is named `cmake-build` because the repository's existing
`BUILD` file prevents creation of a case-insensitive `build` directory on
Windows.

CMake builds and runs the 17 QtTest programs in the existing qmake test list.
The shared `EngaugeCore` object target compiles the application sources once for
the GUI executable and all unit-test executables. The tests use isolated INI
settings so they do not clear or modify the user's Engauge preferences.

CMake still excludes the qmake GUI regression scripts, coordinate regression
script, PDF import, and JPEG 2000 import. Do not remove the qmake path until
those remaining responsibilities have equivalent CMake coverage.

### Windows packages

For normal Windows distribution, prefer the Inno Setup EXE: it supplies an
uninstaller, Start menu shortcuts, optional desktop shortcut, `.dig` file
association, and the Microsoft Visual C++ runtime. Keep the ZIP as the portable
alternative for users who cannot or do not want to install the application.

Build and verify both the CMake application and portable package with:

```powershell
.\dev\windows\package_cmake_qt6.ps1 `
  -QtRoot C:\Qt\6.8.3\msvc2022_64 `
  -FftwRoot C:\Libraries\fftw-3.3.5
```

The script configures, builds, runs all 17 CMake tests, installs into a clean
staging directory, runs `windeployqt`, checks required files and all 18 Engauge
translations, launches the staged application with Qt development paths
removed, and creates:

- `dist/Engauge-Digitizer-12.9.1.2-Multilingual-Windows-x64-Portable.zip`
- `dist/Engauge Digitizer Multilingual/` (the unpacked staging directory)

To also compile the installer, install the current Inno Setup 6 baseline and
run:

```powershell
.\dev\windows\package_cmake_qt6.ps1 `
  -QtRoot C:\Qt\6.8.3\msvc2022_64 `
  -FftwRoot C:\Libraries\fftw-3.3.5 `
  -CreateInstaller
```

Pass `-InnoCompiler C:\path\to\ISCC.exe` when it is not installed in a
standard location. The resulting installer is
`dist/Engauge-Digitizer-12.9.1.2-Multilingual-Windows-x64-Setup.exe`. Public
releases should code-sign the EXE; local and pull-request builds are expected to
be unsigned.

Validate an installer in a temporary per-user directory with:

```powershell
.\dev\windows\test_installer.ps1 `
  -SetupExecutable .\dist\Engauge-Digitizer-12.9.1.2-Multilingual-Windows-x64-Setup.exe
```

The test installs silently, verifies the deployed runtime and translations,
launches Engauge without Qt development paths, uninstalls silently, and confirms
that the application executable was removed. On an elevated CI runner it also
exercises the normal all-users installation mode. A non-elevated local test uses
Inno Setup's command-line-only current-user override and skips the system VC++
runtime installer.

### GitHub draft release

The four-part release version must agree in `CMakeLists.txt`,
`src/util/Version.cpp`, and `dev/windows/engauge_qt6.iss`. Since upstream tag
`v12.9.1` is immutable, this modernization build uses version `12.9.1.2` and tag
`v12.9.1.2`.

After the reviewed branch has been pushed to a repository you control, create
and push an annotated tag:

```powershell
git tag -a v12.9.1.2 -m "Engauge Digitizer 12.9.1.2"
git push origin v12.9.1.2
```

`.github/workflows/release-windows.yml` accepts only a four-part `v` tag whose
value matches all three source version declarations. It builds and tests the
application, compiles both Windows packages, performs the install-launch-
uninstall test, writes `SHA256SUMS.txt`, and then creates a draft GitHub Release.
No Release is created when an earlier step fails. Review the draft and code-sign
the executables before converting it into a public Release.

## Ubuntu baseline

The continuous-integration baseline is Ubuntu 24.04 with the distribution Qt 6,
FFTW, and log4cpp packages:

```bash
sudo apt-get update
sudo apt-get install --yes --no-install-recommends \
  cmake ninja-build \
  libfftw3-dev liblog4cpp5-dev python3-lxml python3-numpy python3-pandas \
  qt6-base-dev qt6-documentation-tools qt6-l10n-tools qt6-tools-dev xvfb

qmake6 engauge.pro
make --jobs "$(nproc)"
(cd help && ./build.bash)
xvfb-run --auto-servernum bash -c 'cd src && ./build_and_run_all_gui_tests'
(cd test && python3 ./DumpGraphAndScreenCoordinates_test.py)
(cd src && ./build_and_run_all_cli_tests)
```

The parallel Linux CMake application build is:

```bash
cmake --preset linux-release
cmake --build --preset linux-release
xvfb-run --auto-servernum ctest --preset linux-release
```

PDF and JPEG 2000 support are optional and disabled in this baseline. They will
be enabled only in dependency-specific builds with their own regression tests.

## Build acceptance criteria

A build-system change is considered compatible only when:

1. the Windows x64 release executable builds with Qt 6 and MSVC 2022;
2. all translation catalogs compile;
3. the help collection is regenerated from `help/engauge.qhp`;
4. all 17 CMake QtTest programs pass on Windows and Linux;
5. the CMake install layout is complete and the Windows deployment launches
   without the Qt development directory on `PATH`;
6. the Linux qmake GUI, coordinate, and command-line regression tests pass; and
7. the existing qmake build remains available until CMake reaches parity.
