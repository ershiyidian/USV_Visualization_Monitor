# 无人艇可视化与监控系统 (USV Visualization & Monitoring System)

[![Qt Version](https://img.shields.io/badge/Qt-5.15.2-green.svg)](https://www.qt.io)
[![C++ Standard](https://img.shields.io/badge/C%2B%2B-17-blue.svg)](https://isocpp.org/std/وندی-πήγε-το-cxx17)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.md) 本项目是一个基于 C++17 和 Qt 5.15.2 (QML) 开发的无人艇 (USV) 综合可视化与监控应用程序。它旨在提供实时数据显示、状态监控、历史数据分析以及用户交互界面，用以提高无人艇作业的效率和安全性。

---

## 目录

- [项目简介](#项目简介)
- [核心功能](#核心功能)
- [技术栈](#技术栈)
- [项目结构](#项目结构)
- [截图预览](#截图预览)
- [安装与构建](#安装与构建)
  - [环境要求](#环境要求)
  - [构建步骤](#构建步骤)
- [使用说明](#使用说明)
- [未来展望](#未来展望)
- [贡献指南](#贡献指南)
- [许可证](#许可证)
- [联系方式](#联系方式)

---

## 项目简介

该系统为无人艇操作员和数据分析人员提供了一个强大的工具，用于实时监控无人艇的运行状态、传感器数据和地理位置。通过集成的QML界面，用户可以直观地与数据交互，并进行有效的态势感知。主要目标是简化复杂数据的呈现，提供直观的操作反馈，并辅助决策。

---

## 核心功能

* **实时数据显示**:
    * GPS 位置与轨迹地图可视化 (基于 MapViewPanel.qml, 使用 Qt Location/Positioning)
    * 艇体姿态（速度、航向、横摇、纵摇、艏摇等）及历史曲线 (SensorChart.qml)
    * 动力系统状态（电池电压、电流、剩余电量等）
    * 各类传感器数据实时面板展示 (SensorDataPanel.qml, sensor_module.cpp)
    * 设备连接与运行状态指示 (BoatStatusPanel.qml, device_module.cpp)
* **历史数据管理**:
    * 关键遥测数据本地记录与存储 (可能使用 Qt SQL 模块, datasource.cpp, database.cpp)
    * 历史数据加载、回放与图表化分析 (HistoryDataWindow.qml)
* **用户交互与控制**:
    * 系统参数配置与用户偏好设置 (SettingsDialog.qml)
    * （若支持）任务点选择与简单路径规划辅助 (TaskPointSelector.qml)
    * 串口/网络通信参数配置与控制 (SerialControlPanel.qml)
    * 顶部消息提示与状态反馈 (TopMessageBar.qml)
* **模块化设计**:
    * 传感器数据处理模块 (sensor_module.cpp/h)
    * 艇体核心逻辑模块 (essel_module.cpp/h)
    * 数据源管理模块 (datasource.cpp/h)
    * 设备通信模块 (device_module.cpp/h)

---

## 技术栈

* **编程语言**: C++17 (CONFIG += c++17 in .pro)
* **核心框架**: Qt 5.15.2
    * **UI 技术**: QML (Qt Quick Controls 2) for modern, fluid interfaces. Some Qt Widgets might be used for specific dialogs or compatibility.
    * **Qt Modules Used**: core, gui, widgets, quick, serialport, charts, qml, quickcontrols2, location, positioning, sql (as declared in Visualization.pro).
* **构建系统**: qmake (Project file: Visualization.pro)
* **数据存储**: Likely SQLite via Qt SQL module for local data logging (inferred from database.cpp and sql module).
* **关键编译定义**: REPLACE_INTER_FONT (as per .pro file - if this implies custom font handling, it's a notable detail).

---

## 项目结构 (主要组件)

\\\
USV_Visualization_Monitor/  # Repository Root
├── Visualization.pro       # qmake 项目配置文件, 定义了源码、资源和依赖
├── main.cpp                # C++ 程序主入口, 初始化Qt应用和QML引擎
├── qml.qrc                 # Qt 资源文件, 编译QML文件、图片等资源到可执行文件中
│   └── qml/                # 存放QML文件的主要目录 (通常由 QML_IMPORT_PATH 或 qmldir 指向)
│       ├── BoatStatusPanel.qml
│       ├── HistoryDataWindow.qml
│       ├── MapViewPanel.qml
│       ├── SensorChart.qml
│       ├── SensorDataPanel.qml
│       ├── SerialControlPanel.qml
│       ├── SettingsDialog.qml
│       ├── TaskPointSelector.qml
│       ├── TopMessageBar.qml
│       └── main.qml        # QML应用的入口文件 (示例名称)
├── device_module.cpp
├── device_module.h
├── main.cpp
├── visualization_base.cpp
├── visualization_base.h
├── sensor_module.cpp
├── sensor_module.h
├── vessel_module.cpp
├── vessel_module.h
├── datasource.cpp
├── datasource.h
├── database.cpp
├── database.h
├── resources/              # (建议) 存放图标、字体等非QML静态资源
├── screenshots/            # (建议) 存放项目截图
└── README.md               # 本文档
\\\

---

## 截图预览

**请您务必将程序的实际运行截图添加到项目中的 screenshots 文件夹，并在此处更新以下链接。**

*例如:*
请替换为您的真实截图和描述！例如： ![程序概览](./screenshots/your_screenshot_name.jpg)

---

## 安装与构建

### 环境要求

* **操作系统**: Windows 10/11 (主要开发和测试平台), Linux (如 Ubuntu 20.04+), macOS.
* **Qt SDK**: Qt 5.15.2 (LTS). 确保安装了与您的编译器匹配的版本 (例如, MSVC for Visual Studio, MinGW for Windows, GCC for Linux, Clang for macOS).
    * **必需的Qt模块**: 请确保在Qt安装中包含了 Core, GUI, Widgets, Quick, QML, QuickControls2, SerialPort, Charts, Location, Positioning, SQL.
* **C++编译器**: 支持 C++17 标准。
* **Git**: 用于克隆代码和版本管理。

### 构建步骤

1.  **克隆仓库** (如果您是从其他地方获取此项目):
    \\\ash
    git clone https://github.com/ershiyidian/USV_Visualization_Monitor.git
    cd USV_Visualization_Monitor
    \\\

2.  **使用 Qt Creator (推荐)**:
    * 启动 Qt Creator。
    * 选择 "文件 (File)" > "打开文件或项目 (Open File or Project)..."
    * 导航到克隆的项目根目录，选择 Visualization.pro 文件。
    * 配置项目，选择一个已正确安装的 Qt 5.15.2 Kit (构建套件)。
    * 点击左下角的 "构建 (Build)" 图标 (锤子) 或 "运行 (Run)" 图标 (绿色三角)。

3.  **命令行构建**:
    打开一个配置好 Qt 环境变量的命令行终端 (例如 Qt 5.15.2 MinGW 64-bit Command Prompt)。
    \\\ash
    # 进入项目根目录
    qmake Visualization.pro  # 或者直接 'qmake' 生成 Makefile
    # 根据您的构建环境执行 make
    # Windows (MinGW):
    # mingw32-make
    # Windows (MSVC - 需要在Visual Studio的开发者命令提示符下运行):
    # nmake
    # Linux/macOS:
    # make
    \\\
    编译生成的可执行文件通常位于与源码目录同级的 uild-<ProjectName>-<KitName>-<BuildType> 目录中，或者在 debug / elease 子目录内 (取决于qmake的配置和构建类型)。

---

## 使用说明

1.  成功构建应用程序后，运行生成的可执行文件。
2.  **[请在此处补充您程序的基本启动和操作流程，例如：]**
    * 如何通过 SerialControlPanel.qml 配置串口并连接到无人艇设备。
    * 主界面 (BoatStatusPanel.qml, SensorDataPanel.qml) 各个信息区域的含义。
    * 如何查看历史数据 (HistoryDataWindow.qml) 或地图轨迹 (MapViewPanel.qml)。
    * 是否有默认的登录凭据或初始配置步骤。

---

## 未来展望

* [ ] **高级路径规划**: 集成更复杂的路径算法和避障逻辑。
* [ ] **扩展传感器支持**: 增加对更多类型传感器和数据格式的兼容性。
* [ ] **网络通信增强**: 支持 TCP/IP、UDP 等多种网络通信方式，适应不同无人艇控制链路。
* [ ] **数据分析工具**: 内建更多数据统计、分析和导出功能。
* [ ] **用户权限管理**: 若涉及多用户操作，增加权限控制。
* [ ] **国际化与本地化**: 支持多语言界面。

---

## 贡献指南

我们欢迎并感谢所有形式的贡献！如果您希望为项目贡献代码、文档或提出建议，请遵循以下步骤：

1.  **Fork** 本仓库到您自己的 GitHub 账户。
2.  从 main 分支创建一个新的特性分支 (e.g., git checkout -b feature/awesome-feature or ix/bug-name).
3.  在您的特性分支上进行修改和提交。请编写清晰的提交信息。
4.  确保您的代码遵循项目的编码规范 (如果已定义)。
5.  将您的特性分支推送到您 Fork 的仓库 (git push origin feature/awesome-feature).
6.  从您 Fork 仓库的特性分支向本项目的 main 分支创建一个 **Pull Request (PR)**。
7.  在 PR 中详细描述您的更改内容、目的以及任何相关的issue编号。

---

## 许可证

本项目采用 **MIT 许可证**。请在项目根目录创建 LICENSE.md 文件并包含以下内容：
\\\	ext
MIT License

Copyright (c) 2025 ershiyidian

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
\\\

---

## 联系方式

* **项目维护者 / 主要贡献者**: ershiyidian
* **邮箱**: esyd060406@gmail.com
* **项目仓库**: [https://github.com/ershiyidian/USV_Visualization_Monitor](https://github.com/ershiyidian/USV_Visualization_Monitor)

---
*本文档最后更新于: 2025-05-21 11:43:40*
