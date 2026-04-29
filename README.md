# USV Visualization Monitor

一个基于 C++17 与 Qt/QML 的无人艇可视化监控客户端，用于串口遥测接入、环境传感器展示、船舶状态监控、地图轨迹显示与历史数据查询。

## 项目定位

本项目面向无人艇或水面环境监测场景，提供一个桌面端可视化操作界面。程序通过 `DataSource` 管理串口连接、接收与解析数据帧，并将传感器、船舶与设备状态分发到对应模块；QML 前端负责地图、状态面板、传感器图表、历史数据窗口与任务点选择等交互；SQLite 用于保存历史遥测数据。

## 功能概览

- 串口连接与数据帧接收：支持串口打开、关闭、端口刷新、帧头帧尾校验和模拟数据生成。
- 环境监测数据展示：包括 CO2、CH2O、TVOC、PM2.5、PM10、空气温湿度、浊度、pH、TDS、水温与液位。
- 船舶状态监控：展示经纬度、速度、航向、电池电量与工作模式。
- 地图与轨迹可视化：通过 `MapViewPanel.qml` 展示船舶位置、航迹和任务点。
- 历史数据管理：使用 Qt SQL/SQLite 保存传感器、船舶、轨迹与设备数据，并提供历史数据窗口。
- 控制与配置界面：包含串口控制、任务点选择、设置弹窗、顶部消息提示等 QML 组件。

## 技术栈

- 语言：C++17、QML
- 框架：Qt 5.15.2
- Qt 模块：Core、Gui、Widgets、Quick、QML、QuickControls2、SerialPort、Charts、Location、Positioning、SQL
- 构建系统：qmake
- 本地存储：SQLite，数据库文件默认名为 `historical_data.db`

## 项目结构

```text
.
├── Visualization.pro          # qmake 项目配置
├── main.cpp                   # 应用入口、模块初始化和信号连接
├── datasource.*               # 串口通信、数据帧解析、模拟数据生成
├── sensor_module.*            # 传感器数据解析与 QML 暴露
├── vessel_module.*            # 船舶位置、速度、航向数据解析
├── device_module.*            # 设备电量、模式等状态解析
├── database.*                 # SQLite 表初始化与数据写入
├── main.qml                   # QML 主界面布局
├── MapViewPanel.qml           # 地图与轨迹显示
├── SensorDataPanel.qml        # 传感器数据面板
├── SensorChart.qml            # 传感器曲线图
├── SerialControlPanel.qml     # 串口控制面板
├── BoatStatusPanel.qml        # 船舶状态面板
├── TaskPointSelector.qml      # 任务点选择
├── HistoryDataWindow.qml      # 历史数据查询窗口
├── SettingsDialog.qml         # 设置窗口
└── TopMessageBar.qml          # 顶部状态与消息栏
```

## 数据帧说明

接收帧相关常量定义在 `datasource.h` 的 `FrameConstants` 命名空间中：

- 接收帧长度：`65` 字节
- 帧头：`0xFF`
- 帧尾：`0xFE`
- 传感器数据起始偏移：`2`
- GPS 纬度偏移：`32`
- GPS 经度偏移：`37`
- 航向角偏移：`42`
- 速度偏移：`44`
- 电池偏移：`46`
- 模式偏移：`48`

这些偏移决定了后续硬件协议对接时的数据解析方式。如硬件端协议变化，应优先同步更新 `datasource.h` 与 `datasource.cpp` 中的解析逻辑。

## 环境要求

- Qt 5.15.2
- 支持 C++17 的编译器
  - Windows：MSVC 或 MinGW
  - Linux：GCC
  - macOS：Clang
- Qt Creator，或已配置 Qt 环境变量的命令行
- SQLite Qt 驱动，通常随 Qt SQL 模块安装

## 构建与运行

### 使用 Qt Creator

1. 安装 Qt 5.15.2，并确认安装了 SerialPort、Charts、Location、Positioning、SQL 等模块。
2. 打开 Qt Creator。
3. 选择 `File` -> `Open File or Project`。
4. 打开仓库根目录下的 `Visualization.pro`。
5. 选择匹配的 Kit。
6. 点击 Build 或 Run。

### 使用命令行

```bash
git clone https://github.com/ershiyidian/USV_Visualization_Monitor.git
cd USV_Visualization_Monitor
qmake Visualization.pro
make
```

Windows MinGW 环境可使用：

```bash
qmake Visualization.pro
mingw32-make
```

MSVC 环境可在 Visual Studio Developer Command Prompt 中使用：

```bat
qmake Visualization.pro
nmake
```

## 使用流程

1. 启动程序后，主界面会加载地图、传感器面板、串口控制面板和船舶状态面板。
2. 在串口控制面板中选择串口和波特率，打开连接。
3. 程序接收到合法数据帧后，会解析并更新传感器、船舶和设备状态。
4. 船舶经纬度会同步到地图面板，历史轨迹会写入本地 SQLite 数据库。
5. 可以通过历史数据窗口查看已经保存的遥测记录。

## 开发说明

- `main.cpp` 中通过 Qt 信号槽把 `DataSource`、`SensorModule`、`VesselModule`、`DeviceModule` 和 `Database` 连接起来。
- QML 通过 `engine.rootContext()->setContextProperty(...)` 访问后端模块实例。
- 传感器阈值集中定义在 `FrameConstants::SensorLimits` 中，便于统一调整告警范围。
- 当前项目以 qmake 为主构建方式；如果需要迁移到 CMake，应先保证 `qml.qrc`、Qt 模块和 QML import 路径完整迁移。

## 当前限制

- 本仓库未包含真实运行截图，建议后续添加 `screenshots/` 目录并在 README 中展示主界面、串口面板、地图轨迹和历史数据窗口。
- 仓库当前未提供明确的开源许可证文件；在正式复用或分发前应补充 `LICENSE`。
- 串口协议与硬件端强绑定，部署到新的硬件平台前需要核对数据帧长度、偏移和单位。

## 维护者

- GitHub: [ershiyidian](https://github.com/ershiyidian)
- Email: esyd060406@gmail.com
