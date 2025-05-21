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

// --- 传感器阈值 Getter 方法实现 ---
// 注意：这些阈值直接从 FrameConstants::SensorLimits 返回。

// CO2 阈值
int SensorModule::co2WarningLimit() const { return FrameConstants::SensorLimits::CO2_WARNING; }
int SensorModule::co2CriticalLimit() const { return FrameConstants::SensorLimits::CO2_CRITICAL; }

// 甲醛 (CH2O) 阈值 - 单位: mg/m³
// FrameConstants::SensorLimits::CH2O_WARNING 和 CH2O_CRITICAL 已经是 mg/m³
double SensorModule::ch2oWarningLimit() const { return FrameConstants::SensorLimits::CH2O_WARNING; }
double SensorModule::ch2oCriticalLimit() const { return FrameConstants::SensorLimits::CH2O_CRITICAL; }

// TVOC 阈值 - 单位: ppb
// SensorDataPanel.qml 中 TVOC 的单位显示和比较基准可能需要与此处的 ppb 单位对齐。
// DTO 中的 TVOC 是 mg/m³。QML显示的是mg/m³。
// 如果QML中的图表和状态检查使用mg/m³，那么这些限制也应该转换为mg/m³。
// FrameConstants::SensorLimits::TVOC_WARNING 和 TVOC_CRITICAL 是 ppb.
// 转换: 1 ppb TVOC (以甲苯计) ≈ 3.75 µg/m³ = 0.00375 mg/m³
// For consistency with DTO and QML display, converting limits to mg/m³ might be better.
// However, the property is defined as int, and FrameConstants are int (ppb).
// Let's stick to ppb for these properties as defined, QML will need to handle it or we need to change property type.
// For now, returning ppb as per property type `int`.
int SensorModule::tvocWarningLimit() const { return FrameConstants::SensorLimits::TVOC_WARNING; } // ppb
int SensorModule::tvocCriticalLimit() const { return FrameConstants::SensorLimits::TVOC_CRITICAL; } // ppb


// PM2.5 阈值
int SensorModule::pm25WarningLimit() const { return FrameConstants::SensorLimits::PM25_WARNING; }
int SensorModule::pm25CriticalLimit() const { return FrameConstants::SensorLimits::PM25_CRITICAL; }

// PM10 阈值
int SensorModule::pm10WarningLimit() const { return FrameConstants::SensorLimits::PM10_WARNING; }
int SensorModule::pm10CriticalLimit() const { return FrameConstants::SensorLimits::PM10_CRITICAL; }

// 水体浊度 (Turbidity) 阈值
int SensorModule::turbidityWarningLimit() const { return FrameConstants::SensorLimits::TURBIDITY_WARNING; }
int SensorModule::turbidityCriticalLimit() const { return FrameConstants::SensorLimits::TURBIDITY_CRITICAL; }

// pH值 阈值
// pH的警告和临界值通常是范围，例如过高或过低。
// FrameConstants 定义的是上限警告/临界。这里直接返回它们。
// QML端可能需要更复杂的逻辑来处理pH范围。
double SensorModule::phWarningLimit() const { return FrameConstants::SensorLimits::PH_WARNING; } // 通常是上限
double SensorModule::phCriticalLimit() const { return FrameConstants::SensorLimits::PH_CRITICAL; } // 通常是上限

// 总溶解固体 (TDS) 阈值
int SensorModule::tdsWarningLimit() const { return FrameConstants::SensorLimits::TDS_WARNING; }
int SensorModule::tdsCriticalLimit() const { return FrameConstants::SensorLimits::TDS_CRITICAL; }
