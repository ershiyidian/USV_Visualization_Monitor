#include "vessel_module.h" // 包含头文件
#include <QDebug> // 用于调试输出
// #include <QtMath> // QtMath 可能不再需要，因为DTO直接提供double值

// 构造函数
VesselModule::VesselModule(QObject *parent)
    : VisualizationBase(parent) {
    // 初始化用于QML显示的数据结构
    m_displayData = {
        {"latitude", 0.0},  // 纬度
        {"longitude", 0.0}, // 经度
        {"speed", 0.0},     // 速度
        {"heading", 0.0}    // 航向
    };
}

// void VesselModule::parseData(const QString& data) // 旧的解析函数，已移除
// {
//     // ... 实现已删除 ...
// }

// 处理来自DataSource的VesselStateDto更新的槽函数
void VesselModule::handleVesselStateUpdated(const VesselStateDto& vesselState) {
    // 更新内部存储以供QML显示
    m_displayData["latitude"] = vesselState.latitude;
    m_displayData["longitude"] = vesselState.longitude;
    m_displayData["speed"] = vesselState.speed;
    m_displayData["heading"] = vesselState.heading;

    // qDebug() << "VesselModule: Received VesselStateDto - Lat:" << vesselState.latitude
    //          << "Lon:" << vesselState.longitude
    //          << "Speed:" << vesselState.speed
    //          << "Heading:" << vesselState.heading;

    emit displayDataChanged(); // 发送信号通知QML更新视图

    emit vesselStateReadyForLog(vesselState); // 发送带有DTO的信号，用于数据库日志记录
}

// 更新数据的槽函数 (目前主要由handleVesselStateUpdated驱动)
void VesselModule::updateData() {
    // 此函数在VisualizationBase中声明为纯虚函数，必须实现。
    // 在当前DTO驱动的架构中，数据更新主要由 handleVesselStateUpdated 触发。
    // 如果有其他基于时间的或轮询的更新逻辑，可以在这里实现。
    // 对于由DataSource推送的更新，此函数可能不需要做太多事情。
    // qDebug() << "VesselModule::updateData() called, but updates are DTO-driven.";
}
