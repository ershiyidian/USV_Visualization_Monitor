# 无人艇可视化监控程序 (USV Visualization & Monitoring Program)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

一个基于 C++ 和 Qt 开发的无人艇（USV）实时数据显示、状态监控和可视化操作界面。

---

## 目录

- [项目简介](#项目简介)
- [主要功能](#主要功能)
- [技术栈](#技术栈)
- [项目结构](#项目结构)
- [截图预览](#截图预览)
- [安装与构建](#安装与构建)
  - [环境要求](#环境要求)
  - [构建步骤](#构建步骤)
- [使用说明](#使用说明)
- [数据接口](#数据接口)
- [未来计划](#未来计划)
- [贡献](#贡献)
- [许可证](#许可证)
- [联系方式](#联系方式)

---

## 项目简介

本项目旨在为无人艇操作员提供一个直观、实时的监控界面。通过该程序，用户可以查看无人艇的各项遥测数据（如位置、速度、姿态、传感器读数等），发送控制指令（如果支持），并对数据进行记录和回放。

**核心价值**: 提高无人艇作业的效率和安全性，简化数据分析过程。

---

## 主要功能

* **实时数据显示**:
    * GPS 位置与轨迹地图可视化 (MapViewPanel.qml)
    * 速度、航向、横摇、纵摇、艏摇等姿态数据
    * 电池电压、电流、剩余电量
    * 传感器数据（例如：水深、水温、避障传感器等 - SensorDataPanel.qml, sensor_module.cpp/h)
    * 设备状态监控 (device_module.cpp/h, BoatStatusPanel.qml)
* **历史数据**:
    * 数据记录与存储 (datasource.cpp/h, HistoryDataWindow.qml)
    * 数据回放与分析
* **图表展示**:
    * 关键参数的时序图表 (SensorChart.qml)
* **用户交互**:
    * 参数设置 (SettingsDialog.qml)
    * 任务规划与下发 (TaskPointSelector.qml)
* **通信接口**:
    * 串口通信 (SerialControlPanel.qml)

---

## 技术栈

* **编程语言**: C++
* **GUI框架**: Qt (QWidgets 和 Qt Quick/QML)
    * Qt Version: [请填写您使用的 Qt 版本, 例如 Qt 5.15.2 或 Qt 6.x.x]
* **编译器**: [请填写您使用的编译器, 例如 MSVC2019, MinGW 8.1.0, GCC, Clang]
* **构建系统**: qmake (从 Visualization.pro 文件推断)
* **数据库**: [如果使用了，例如 SQLite (从 database.h/cpp 推断)]

---

## 项目结构 (简要说明)

\\\
USV_Visualization_Monitor/
├── datasource.cpp/h        # 数据源管理，数据存储与读取
├── device_module.cpp/h     # 设备状态逻辑处理
├── main.cpp                # 程序入口
├── visualization_base.cpp/h # 基础类或通用功能
├── *.qml                   # QML UI 界面文件
│   ├── BoatStatusPanel.qml
│   ├── HistoryDataWindow.qml
│   ├── MapViewPanel.qml
│   ├── SensorChart.qml
│   ├── SensorDataPanel.qml
│   ├── SerialControlPanel.qml
│   ├── SettingsDialog.qml
│   ├── TaskPointSelector.qml
│   └── TopMessageBar.qml
├── sensor_module.cpp/h     # 传感器数据处理逻辑
├── vessel_module.cpp/h     # 艇体相关数据或逻辑
├── Visualization.pro       # qmake 项目配置文件
└── README.md               # 本文件
\\\

---

## 截图预览

**重要提示**: 请将您的程序截图 (例如您之前提供的 image_0d82ae.jpg) 放到项目根目录，或者创建一个 screenshots 文件夹并将图片放入其中。然后取消下面这行注释并修改路径。

*(这里可以放一张您觉得最能代表程序功能的截图)*

---

## 安装与构建

### 环境要求

* 操作系统: [例如 Windows 10/11, Linux (Ubuntu 20.04+), macOS]
* Qt SDK: [版本号，例如 Qt 5.15.2 (MinGW 8.1.0 64-bit) 或 Qt 6.2.4]
* [其他依赖，例如特定数据库驱动等]

### 构建步骤

1.  **克隆仓库**:
    \\\ash
    git clone https://github.com/<YOUR_GITHUB_USERNAME>/USV_Visualization_Monitor.git
    cd USV_Visualization_Monitor
    \\\
    *(请将 <YOUR_GITHUB_USERNAME> 替换为您的 GitHub 用户名)*

2.  **使用 Qt Creator 打开项目**:
    * 打开 Qt Creator。
    * 选择 "File" > "Open File or Project..."。
    * 导航到克隆下来的项目文件夹，选择 \Visualization.pro\ 文件。
    * 配置项目，选择合适的 Kit (构建套件)。
    * 点击 "Build" (锤子图标) 或按 \Ctrl+B\。

3.  **或者通过命令行 (qmake & make/nmake)**:
    \\\ash
    # 进入项目根目录
    qmake Visualization.pro # 或者直接 qmake
    # 对于MSVC，可能是 nmake；对于MinGW/Linux/macOS，可能是 make
    make # 或者 mingw32-make, nmake (取决于您的编译器和环境)
    \\\

---

## 使用说明

1.  构建成功后，运行生成的可执行文件。
2.  [简要说明如何开始使用，例如：配置串口、连接设备等]

---

## 数据接口

* **与无人艇通信协议**: [例如 NMEA 0183, MAVLink, 或自定义协议]
* **数据格式**: [如果程序导入/导出特定格式的数据文件，请说明]

---

## 未来计划

* [ ] 增加路径规划模块。
* [ ] 支持更多的传感器类型。
* [ ] 优化地图加载速度。

---

## 贡献

欢迎对本项目进行贡献！请遵循标准的 Fork & Pull Request 工作流程。

---

## 许可证

本项目采用 [MIT许可证](https://opensource.org/licenses/MIT)。

---

## 联系方式

项目维护者: [您的名字或团队名 - 可选]
邮箱: 2776201171@qq.com

项目链接: [https://github.com/<YOUR_GITHUB_USERNAME>/USV_Visualization_Monitor](https://github.com/<YOUR_GITHUB_USERNAME>/USV_Visualization_Monitor)
*(请将 <YOUR_GITHUB_USERNAME> 替换为您的 GitHub 用户名)*
