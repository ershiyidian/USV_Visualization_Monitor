# USV Visualization Monitor

[中文版](README.zh-CN.md)

A C++17 and Qt/QML-based visualization and monitoring client for unmanned surface vehicles: serial telemetry ingestion, environmental sensor display, vessel status monitoring, map trajectory visualization, and historical data query.

## Overview

Built for USV and surface-water monitoring scenarios, this project provides a desktop visualization interface. A `DataSource` manages the serial connection, receives and parses data frames, and dispatches sensor, vessel, and device status to the corresponding modules; the QML frontend handles the map, status panels, sensor charts, the history window, and task-point selection; SQLite persists historical telemetry.

## Features

- Serial connection and frame reception: open/close ports, refresh the port list, frame header/tail validation, and simulated data generation.
- Environmental monitoring display: CO2, CH2O, TVOC, PM2.5, PM10, air temperature/humidity, turbidity, pH, TDS, water temperature, and liquid level.
- Vessel status monitoring: latitude/longitude, speed, heading, battery level, and operating mode.
- Map and trajectory visualization: vessel position, tracks, and task points via `MapViewPanel.qml`.
- Historical data management: sensor, vessel, trajectory, and device data stored with Qt SQL/SQLite, plus a history window for queries.
- Control and configuration UI: serial control, task-point selection, settings dialog, top message bar, and other QML components.

## Tech Stack

- Languages: C++17, QML
- Framework: Qt 5.15.2
- Qt modules: Core, Gui, Widgets, Quick, QML, QuickControls2, SerialPort, Charts, Location, Positioning, SQL
- Build system: qmake
- Local storage: SQLite, default database file `historical_data.db`

## Project Structure

```text
.
├── Visualization.pro          # qmake project configuration
├── main.cpp                   # app entry, module init, signal connections
├── datasource.*               # serial comms, frame parsing, simulated data
├── sensor_module.*            # sensor parsing, exposed to QML
├── vessel_module.*            # position, speed, heading parsing
├── device_module.*            # battery, mode, and status parsing
├── database.*                 # SQLite table init and writes
├── main.qml                   # main QML layout
├── MapViewPanel.qml           # map and trajectory display
├── SensorDataPanel.qml        # sensor data panel
├── SensorChart.qml            # sensor charts
├── SerialControlPanel.qml     # serial control panel
├── BoatStatusPanel.qml        # vessel status panel
├── TaskPointSelector.qml      # task-point selection
├── HistoryDataWindow.qml      # history query window
├── SettingsDialog.qml         # settings dialog
└── TopMessageBar.qml          # top status/message bar
```

## Data Frames

Frame constants live in the `FrameConstants` namespace in `datasource.h`:

- Frame length: `65` bytes
- Frame header: `0xFF`
- Frame tail: `0xFE`
- Sensor data offset: `2`
- GPS latitude offset: `32`
- GPS longitude offset: `37`
- Heading offset: `42`
- Speed offset: `44`
- Battery offset: `46`
- Mode offset: `48`

Frame definitions are centralized in the `FrameConstants` namespace in `datasource.h`; when the hardware-side protocol changes, update the parsing logic in `datasource.h` and `datasource.cpp` accordingly.

## Requirements

- Qt 5.15.2
- A C++17-capable compiler
  - Windows: MSVC or MinGW
  - Linux: GCC
  - macOS: Clang
- Qt Creator, or a command line with the Qt environment configured
- SQLite Qt driver, usually shipped with the Qt SQL module

## Build & Run

### Qt Creator

1. Install Qt 5.15.2 with the SerialPort, Charts, Location, Positioning, and SQL modules.
2. Open Qt Creator.
3. `File` -> `Open File or Project`.
4. Open `Visualization.pro` in the repository root.
5. Select a matching Kit.
6. Hit Build or Run.

### Command line

```bash
git clone https://github.com/ershiyidian/USV_Visualization_Monitor.git
cd USV_Visualization_Monitor
qmake Visualization.pro
make
```

MinGW on Windows:

```bash
qmake Visualization.pro
mingw32-make
```

MSVC, in a Visual Studio Developer Command Prompt:

```bat
qmake Visualization.pro
nmake
```

## Usage

1. On launch, the main window loads the map, sensor panels, serial control panel, and vessel status panel.
2. Pick a serial port and baud rate in the serial control panel and open the connection.
3. Valid frames are parsed, updating sensor, vessel, and device status.
4. Vessel coordinates sync to the map panel; tracks are written to the local SQLite database.
5. Past telemetry is available in the history window.

## Development Notes

- `main.cpp` wires `DataSource`, `SensorModule`, `VesselModule`, `DeviceModule`, and `Database` together with Qt signals and slots.
- QML accesses backend module instances via `engine.rootContext()->setContextProperty(...)`.
- Sensor thresholds live in `FrameConstants::SensorLimits` for unified alert-range tuning.
- Build system: qmake. Migrating to CMake requires moving `qml.qrc`, the Qt modules, and the QML import paths together.

## Maintainer

- GitHub: [ershiyidian](https://github.com/ershiyidian)
