#pragma once
#include "visualization_base.h" // 基础可视化类
#include "DataTransferObjects.h" // 新增: 包含DTO定义

class SensorModule : public VisualizationBase {
    Q_OBJECT
    // QML属性，用于在UI中显示传感器数据
    Q_PROPERTY(int co2 READ co2 NOTIFY displayDataChanged) // CO2浓度 (ppm)
    Q_PROPERTY(double ch2o READ ch2o NOTIFY displayDataChanged) // 甲醛浓度 (mg/m³)
    Q_PROPERTY(double tvoc READ tvoc NOTIFY displayDataChanged) // TVOC浓度 (mg/m³)
    Q_PROPERTY(int pm25 READ pm25 NOTIFY displayDataChanged) // PM2.5颗粒物 (µg/m³)
    Q_PROPERTY(int pm10 READ pm10 NOTIFY displayDataChanged) // PM10颗粒物 (µg/m³)
    Q_PROPERTY(double airTemperature READ airTemperature NOTIFY displayDataChanged) // 空气温度 (℃)
    Q_PROPERTY(double airHumidity READ airHumidity NOTIFY displayDataChanged)    // 空气湿度 (%RH)
    Q_PROPERTY(double waterTurbidity READ waterTurbidity NOTIFY displayDataChanged) // 水体浊度 (NTU)
    Q_PROPERTY(double ph READ ph NOTIFY displayDataChanged)             // pH值
    Q_PROPERTY(double tds READ tds NOTIFY displayDataChanged)            // 总溶解固体 (ppm)
    Q_PROPERTY(double waterTemperature READ waterTemperature NOTIFY displayDataChanged) // 水体温度 (℃)
    Q_PROPERTY(double waterLevel READ waterLevel NOTIFY displayDataChanged)     // 水位 (m)

    // 新增: 传感器阈值属性
    Q_PROPERTY(int co2WarningLimit READ co2WarningLimit CONSTANT)
    Q_PROPERTY(int co2CriticalLimit READ co2CriticalLimit CONSTANT)
    Q_PROPERTY(double ch2oWarningLimit READ ch2oWarningLimit CONSTANT) // mg/m³
    Q_PROPERTY(double ch2oCriticalLimit READ ch2oCriticalLimit CONSTANT) // mg/m³
    Q_PROPERTY(int tvocWarningLimit READ tvocWarningLimit CONSTANT) // ppb
    Q_PROPERTY(int tvocCriticalLimit READ tvocCriticalLimit CONSTANT) // ppb
    Q_PROPERTY(int pm25WarningLimit READ pm25WarningLimit CONSTANT)
    Q_PROPERTY(int pm25CriticalLimit READ pm25CriticalLimit CONSTANT)
    Q_PROPERTY(int pm10WarningLimit READ pm10WarningLimit CONSTANT)
    Q_PROPERTY(int pm10CriticalLimit READ pm10CriticalLimit CONSTANT)
    Q_PROPERTY(int turbidityWarningLimit READ turbidityWarningLimit CONSTANT)
    Q_PROPERTY(int turbidityCriticalLimit READ turbidityCriticalLimit CONSTANT)
    Q_PROPERTY(double phWarningLimit READ phWarningLimit CONSTANT)
    Q_PROPERTY(double phCriticalLimit READ phCriticalLimit CONSTANT)
    Q_PROPERTY(int tdsWarningLimit READ tdsWarningLimit CONSTANT)
    Q_PROPERTY(int tdsCriticalLimit READ tdsCriticalLimit CONSTANT)

public:
    explicit SensorModule(QObject *parent = nullptr); // 构造函数

    // Getter 方法，供QML属性读取 (从扁平化的 m_displayData 读取)
    int co2() const { return m_displayData.value("co2", 0).toInt(); }
    double ch2o() const { return m_displayData.value("ch2o", 0.0).toDouble(); } // DTO: mg/m³
    double tvoc() const { return m_displayData.value("tvoc", 0.0).toDouble(); } // DTO: mg/m³
    int pm25() const { return m_displayData.value("pm25", 0).toInt(); }
    int pm10() const { return m_displayData.value("pm10", 0).toInt(); }
    double airTemperature() const { return m_displayData.value("airTemperature", 0.0).toDouble(); }
    double airHumidity() const { return m_displayData.value("airHumidity", 0.0).toDouble(); }
    double waterTurbidity() const { return m_displayData.value("waterTurbidity", 0.0).toDouble(); } // DTO: NTU (double)
    double ph() const { return m_displayData.value("ph", 0.0).toDouble(); }
    double tds() const { return m_displayData.value("tds", 0.0).toDouble(); } // DTO: ppm (double)
    double waterTemperature() const { return m_displayData.value("waterTemperature", 0.0).toDouble(); }
    double waterLevel() const { return m_displayData.value("waterLevel", 0.0).toDouble(); } // DTO中waterLevel是double (m)

    // 新增: 传感器阈值Getter方法
    int co2WarningLimit() const;
    int co2CriticalLimit() const;
    double ch2oWarningLimit() const; // mg/m³
    double ch2oCriticalLimit() const; // mg/m³
    int tvocWarningLimit() const; // ppb
    int tvocCriticalLimit() const; // ppb
    int pm25WarningLimit() const;
    int pm25CriticalLimit() const;
    int pm10WarningLimit() const;
    int pm10CriticalLimit() const;
    int turbidityWarningLimit() const;
    int turbidityCriticalLimit() const;
    double phWarningLimit() const;
    double phCriticalLimit() const;
    int tdsWarningLimit() const;
    int tdsCriticalLimit() const;

signals:
    // void sensorDataParsed(int co2, int ch2o, int tvoc, int pm25, int pm10, // 旧信号，已移除
    //                       double airTemp, double humidity,
    //                       int turbidity, double ph, int tds, double waterTemp,
    //                       int levelValue);
    void sensorDataReadyForLog(const SensorDataDto& dataToLog); // 新信号，发送DTO用于日志记录

public slots:
    void handleSensorDataUpdated(const SensorDataDto& sensorData); // 新槽函数，处理来自DataSource的DTO更新

protected:
    // void parseData(const QString& data) override; // 旧的数据解析方法，已移除

// private: // 旧的私有解析辅助函数，已移除
    // void parseAirQuality(const QStringList& data, int& offset);
    // void parseWaterQuality(const QStringList& data, int& offset);
    // void parseWaterLevel(const QStringList& data, int& offset);
    // bool validateFrame(const QStringList& data);
};
