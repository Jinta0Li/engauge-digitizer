# Engauge Digitizer

Engauge Digitizer 是一款优秀的开源软件，用于从图表图像中提取数据点。然而，官方项目在较新版本中不再直接提供 Windows 平台的预编译安装包（仅提供源代码）。为了让普通用户和研究人员能够开箱即用，我建立了这个仓库，定期将最新源码编译为 Windows 可执行文件。

Engauge Digitizer is an excellent open-source tool for extracting data points from graphical images. However, the official project stopped providing pre-compiled Windows binaries for recent versions, offering only source code. This repository was created to help non-developer users by providing ready-to-use Windows installers compiled from the latest source.

## Download / 下载

Open the [latest release](../../releases/latest) and choose one of these packages:

打开[最新版本页面](../../releases/latest)，选择以下任一软件包：

- **Setup.exe**: standard Windows installation with Start Menu shortcuts and uninstall support. Windows 标准安装版，提供开始菜单快捷方式和卸载功能。
- **Portable.zip**: extract and run `Engauge.exe`; no installation is required. 解压后直接运行 `Engauge.exe`，无需安装。

Both packages include the required Qt and FFTW runtime files.

两种软件包均包含所需的 Qt 和 FFTW 运行库。

These community binaries are not code-signed, so Windows SmartScreen may request confirmation. Verify downloads with the published SHA256 checksums.

社区构建目前没有代码签名，Windows SmartScreen 可能要求确认；请使用发布页提供的 SHA256 校验值验证文件。

## This fork / 本维护分支

- Windows x64 build based on Qt 6.
- Unified image import, clipboard paste, and coordinate calibration workflows.
- Three-point and four-point axis calibration, with four-point calibration as the default.
- Automated Windows build, test, deployment, and packaging scripts.

## Project links / 项目链接

- [Official project website / 官方项目网站](https://akhuettel.github.io/engauge-digitizer/)
- [Official upstream repository / 官方上游仓库](https://github.com/akhuettel/engauge-digitizer)
- [Releases / 发布版本](../../releases)
- [Build workflows / 自动构建](../../actions)
- [Citation DOI](https://zenodo.org/badge/latestdoi/26443394)

The original application was created and maintained by Mark Mitchell. The upstream source was restored and is maintained by Andreas K. Hüttel and other contributors. This fork retains the upstream copyright and licensing notices.

## License / 许可证

Engauge Digitizer is distributed under the GNU General Public License version 2 or, at your option, any later version. See [LICENSE](LICENSE).
