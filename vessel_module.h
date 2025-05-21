#ifndef VESSEL_MODULE_H
#define VESSEL_MODULE_H

#include "visualization_base.h" // 基础可视化类
#include "DataTransferObjects.h" // 包含DTO定义

class VesselModule : public VisualizationBase {
    Q_OBJECT
    // QML属性，用于在UI中显示船体状态
    Q_PROPERTY(double latitude READ latitude NOTIFY displayDataChanged) // 纬度
    Q_PROPERTY(double longitude READ longitude NOTIFY displayDataChanged) // 经度
    Q_PROPERTY(double speed READ speed NOTIFY displayDataChanged) // 速度
    Q_PROPERTY(double heading READ heading NOTIFY displayDataChanged) // 航向

public:
    explicit VesselModule(QObject *parent = nullptr); // 构造函数

    // Getter 方法，供QML属性读取
    double latitude() const { return m_displayData.value("latitude", 0.0).toDouble(); } // 获取纬度
    double longitude() const { return m_displayData.value("longitude", 0.0).toDouble(); } // 获取经度
    double speed() const { return m_displayData.value("speed", 0.0).toDouble(); }       // 获取速度
    double heading() const { return m_displayData.value("heading", 0.0).toDouble(); }   // 获取航向

signals:
    // void vesselDataParsed(double latitude, double longitude, double speed, double heading); // 旧信号，已移除
    void vesselStateReadyForLog(const VesselStateDto& dataToLog); // 新信号，发送DTO用于日志记录

public slots:
    void updateData() override; // 更新数据槽函数 (可能需要审阅其在DTO上下文中的作用)
    void handleVesselStateUpdated(const VesselStateDto& vesselState); // 新槽函数，处理来自DataSource的DTO更新


    // protected:
    // void parseData(const QString& data) override; // 旧的数据解析方法，已移除
};

#endif // VESSEL_MODULE_H
