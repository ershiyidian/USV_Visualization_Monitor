# 设定最低版本
QT += core gui widgets quick serialport charts qml quickcontrols2 location positioning sql

TARGET = Visualization
TEMPLATE = app

# C++标准
CONFIG += c++17

# 项目源文件
SOURCES += \
    device_module.cpp \
    main.cpp \
    visualization_base.cpp \
    sensor_module.cpp \
    vessel_module.cpp \
    datasource.cpp \
    database.cpp

HEADERS += \
    device_module.h \
    visualization_base.h \
    sensor_module.h \
    vessel_module.h \
    datasource.h \
    database.h

# QML 资源文件
RESOURCES += qml.qrc

# 额外的编译选项
DEFINES += REPLACE_INTER_FONT

# 指定QML文件的导入路径
QML_IMPORT_PATH = $$PWD/qml

# 安装规则
target.path = $$[QT_INSTALL_EXAMPLES]/Visualization
INSTALLS += target

# 如果是 macOS 或 iOS, 配置特定设置
macx {
    # 设置 macOS 应用程序的标识符、版本等
    macx_bundle {
        macx_bundle_identifier = com.example.Visualization
        macx_bundle_version = $$VERSION
        macx_bundle_short_version_string = $$QT_MAJOR_VERSION.$$QT_MINOR_VERSION
        DESTDIR = $$PWD
    }
}

# Android 特性
android {
    TARGET = libVisualization
    # 添加更多针对 Android 的设置和优化
}
