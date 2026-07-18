# Dependency baseline

This file records the supported build baseline. It separates dependencies used
by the normal application from optional import features and historical Windows
artifacts that remain in the repository.

| Component | Baseline | Role | Default build |
| --- | --- | --- | --- |
| Qt | 6.8.3 on Windows; distribution Qt 6 on Ubuntu 24.04 | Core, GUI, Widgets, PrintSupport, XML, Help | Required |
| C++ | C++17 | Language standard required by Qt 6 | Required |
| CMake | 3.21.1 minimum; 4.4.0 validated | Parallel application build generation | Build only |
| Ninja | 1.13.2 validated | CMake preset build executor | Build only |
| FFTW | 3.3.5 on Windows; distribution package on Ubuntu | Correlation and point matching | Required |
| log4cpp | bundled `log4cpp_null` on Windows; distribution package on Ubuntu | Logging API | Required |
| OpenJPEG | not pinned in the baseline | JPEG 2000 import | Optional, disabled |
| Poppler Qt 6 | not pinned in the baseline | PDF import and cropping | Optional, disabled |
| Inno Setup | 6.7.3 | Windows installer | Packaging only |

The Windows FFTW 3.3.5 package is retained only to reproduce the existing build.
Its planned upgrade to FFTW 3.3.11 is a separate change with correlation and
point-matching regression tests.

CMake and Ninja are build tools rather than shipped runtime dependencies. Their
validated versions may advance independently; `CMakeLists.txt` records the true
minimum CMake version accepted by the project.

`windeployqt` supplies the Qt runtime, plugins, Qt translation catalogs, and
Microsoft's `vc_redist.x64.exe` to the Windows staging directory. The Inno Setup
package runs that redistributable before launching Engauge. The portable ZIP
retains the redistributable so it can be installed manually on a clean Windows
system.

Inno Setup is used only to turn the already verified staging directory into a
single installer EXE. The compiler is not redistributed with Engauge, and a
public release still requires a separate code-signing step.

The old Poppler/Qt 5 libraries, source archives, CMake 3.8 installer, and 32-bit
packaging scripts under `dev/windows` are not part of the supported Qt 6 build.
They must not be used for new releases and can be removed after the replacement
dependency and packaging pipelines are verified.

Engauge source files are licensed under GPL version 2 or, at the recipient's
option, a later version. Release artifacts must include the Engauge license,
applicable third-party notices, and corresponding source or source-access
instructions required by the dependency licenses.
