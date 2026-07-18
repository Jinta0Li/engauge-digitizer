# Engauge Digitizer

Engauge Digitizer converts graph and map images into numerical data. This maintained fork provides tested Windows x64 builds and interface improvements based on the official Engauge Digitizer source code.

Engauge Digitizer 可以把图表或地图图像转换为数值数据。本维护分支基于官方源代码，提供经过测试的 Windows x64 构建和界面改进。

## Download / 下载

Open the [latest release](../../releases/latest) and choose one of these packages:

打开[最新版本页面](../../releases/latest)，选择以下任一软件包：

- **Setup.exe — recommended / 推荐**: standard Windows installation with Start Menu shortcuts and uninstall support. Windows 标准安装版，提供开始菜单快捷方式和卸载功能。
- **Portable.zip**: extract and run `Engauge.exe`; no installation is required. 解压后直接运行 `Engauge.exe`，无需安装。

Both packages include the required Qt and FFTW runtime files and all available interface languages.

两种软件包均包含所需的 Qt、FFTW 运行库以及全部可用界面语言。

These community binaries are not code-signed, so Windows SmartScreen may request confirmation. Verify downloads with the published SHA256 checksums.

社区构建目前没有代码签名，Windows SmartScreen 可能要求确认；请使用发布页提供的 SHA256 校验值验证文件。

## This fork / 本维护分支

- Windows x64 build based on Qt 6.
- Simplified Chinese and Traditional Chinese translations with runtime language switching.
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
