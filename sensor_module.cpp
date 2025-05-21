#include "sensor_module.h" // 包含头文件
#include <QDebug> // 用于调试输出 (如果需要)

// 构造函数
SensorModule::SensorModule(QObject *parent)
    : VisualizationBase(parent)
{
    // 初始化用于QML显示的扁平化数据结构
    // 键名与Q_PROPERTY的READ函数名(首字母小写)和SensorDataDto的成员名对应
    m_displayData = {
        {"co2", 0},
        {"ch2o", 0.0},
        {"tvoc", 0.0},
        {"pm25", 0},
        {"pm10", 0},
        {"airTemperature", 0.0},
        {"airHumidity", 0.0},    // 对应 DTO 的 airHumidity
        {"waterTurbidity", 0.0}, // 对应 DTO 的 waterTurbidity
        {"ph", 0.0},
        {"tds", 0.0},            // 对应 DTO 的 tds
        {"waterTemperature", 0.0},
        {"waterLevel", 0.0}      // 对应 DTO 的 waterLevel
    };
}

// void SensorModule::parseData(const QString& data) // 旧的解析函数，已移除
// {
//     // ... 实现已删除 ...
// }

// void SensorModule::parseAirQuality(const QStringList& data, int& offset) // 旧的辅助解析函数，已移除
// {
//     // ... 实现已删除 ...
// }

// void SensorModule::parseWaterQuality(const QStringList& data, int& offset) // 旧的辅助解析函数，已移除
// {
//     // ... 实现已删除 ...
// }

// void SensorModule::parseWaterLevel(const QStringList& data, int& offset) // 旧的辅助解析函数，已移除
// {
//     // ... 实现已删除 ...
// }

// bool SensorModule::validateFrame(const QStringList& data) // 旧的校验函数，已移除
// {
//     // ... 实现已删除 ...
//     return false;
// }

// 处理来自DataSource的SensorDataDto更新的槽函数
void SensorModule::handleSensorDataUpdated(const SensorDataDto& sensorData) {
    // 更新内部存储以供QML显示，使用扁平化结构
    m_displayData["co2"] = sensorData.co2;
    m_displayData["ch2o"] = sensorData.ch2o;
    m_displayData["tvoc"] = sensorData.tvoc;
    m_displayData["pm25"] = sensorData.pm25;
    m_displayData["pm10"] = sensorData.pm10;
    m_displayData["airTemperature"] = sensorData.airTemperature;
    m_displayData["airHumidity"] = sensorData.airHumidity; // 使用 airHumidity 键
    m_displayData["waterTurbidity"] = sensorData.waterTurbidity; // 使用 waterTurbidity 键
    m_displayData["ph"] = sensorData.ph;
    m_displayData["tds"] = sensorData.tds; // 使用 tds 键
    m_displayData["waterTemperature"] = sensorData.waterTemperature;
    m_displayData["waterLevel"] = sensorData.waterLevel; // 使用 waterLevel 键

    // qDebug() << "SensorModule: Received SensorDataDto - CO2:" << sensorData.co2
    //          << "AirTemp:" << sensorData.airTemperature
    //          << "WaterLevel:" << sensorData.waterLevel;

    emit displayDataChanged(); // 发送信号通知QML更新视图

    emit sensorDataReadyForLog(sensorData); // 发送带有DTO的信号，用于数据库日志记录
}
