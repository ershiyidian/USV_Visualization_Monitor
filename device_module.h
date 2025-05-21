#ifndef DEVICE_MODULE_H
#ifndef DEVICE_MODULE_H
#define DEVICE_MODULE_H

#include "visualization_base.h" // 基础可视化类
#include "DataTransferObjects.h" // 新增: 包含DTO定义

// class DataSource; // 前向声明，如果DataSource指针作为成员（已移除）

class DeviceModule : public VisualizationBase {
    Q_OBJECT
    // QML属性，用于在UI中显示设备状态
    Q_PROPERTY(int battery READ battery NOTIFY displayDataChanged) // 电池电量 (%)
    Q_PROPERTY(QString operationalMode READ operationalMode NOTIFY displayDataChanged) // 操作模式 (字符串形式)
    Q_PROPERTY(bool pumpActive READ pumpActive WRITE setPumpActive NOTIFY pumpActiveChanged) // 水泵是否激活 (用于QML控制)
    Q_PROPERTY(bool pumpAutoMode READ pumpAutoMode WRITE setPumpAutoMode NOTIFY pumpAutoModeChanged) // 水泵自动模式
    Q_PROPERTY(bool boatAutoMode READ boatAutoMode WRITE setBoatAutoMode NOTIFY boatAutoModeChanged) // 船只自动模式
    Q_PROPERTY(int motor1Value READ motor1Value WRITE setMotor1Value NOTIFY motor1ValueChanged) // 电机1输出值
    Q_PROPERTY(int motor2Value READ motor2Value WRITE setMotor2Value NOTIFY motor2ValueChanged) // 电机2输出值

public:
    explicit DeviceModule(QObject *parent = nullptr); // 构造函数

    // Getter 方法，供QML属性读取
    int battery() const { return m_displayData.value("battery", 0).toInt(); } // 获取电池电量
    QString operationalMode() const { return m_displayData.value("operationalMode", "未知").toString(); } // 获取操作模式字符串
    bool pumpActive() const { return m_pumpActive; } // 获取水泵激活状态
    bool pumpAutoMode() const { return m_pumpAutoMode; } // 获取水泵自动模式状态
    bool boatAutoMode() const { return m_boatAutoMode; } // 获取船只自动模式状态
    int motor1Value() const { return m_motor1Value; } // 获取电机1值
    int motor2Value() const { return m_motor2Value; } // 获取电机2值

signals:
    // void deviceDataParsed(int battery,bool mode); // 旧信号，已移除
    void deviceStatusReadyForLog(const DeviceStatusDto& dataToLog); // 新信号，发送DTO用于日志记录
    void deviceControlRequested(const DeviceControlDto& controlCommand); // 新信号，请求设备控制
    void pumpActiveChanged(bool active); // 水泵激活状态变更信号
    void pumpAutoModeChanged(bool mode); // 水泵自动模式变更信号
    void boatAutoModeChanged(bool mode); // 船只自动模式变更信号
    void motor1ValueChanged(int value); // 电机1值变更信号
    void motor2ValueChanged(int value); // 电机2值变更信号
    void missionCommandRequested(const MissionCommandDto& missionCmd); // 新增: 请求发送任务指令的信号

public slots:
    void updateData() override; // 更新数据槽函数 (可能需要审阅其在DTO上下文中的作用)
    void handleDeviceStatusUpdated(const DeviceStatusDto& deviceStatus); // 新槽函数，处理来自DataSource的DTO更新
    void setPumpActive(bool active); // 设置水泵激活状态 (QML调用)
    void setPumpAutoMode(bool mode); // 设置水泵自动模式 (QML调用)
    void setBoatAutoMode(bool mode); // 设置船只自动模式 (QML调用)
    void setMotor1Value(int value); // 设置电机1的值 (QML调用)
    void setMotor2Value(int value); // 设置电机2的值 (QML调用)
    Q_INVOKABLE void sendMissionCommand(const QVariantMap& homePointData, const QVariantList& waypointsData); // 新增: QML调用的发送任务指令的槽

protected:
    // void parseData(const QString& data) override; // 旧的数据解析方法，已移除
    bool m_pumpActive = false; // 水泵当前是否激活
    bool m_pumpAutoMode = false; // 水泵是否处于自动模式
    bool m_boatAutoMode = false; // 船只是否处于自动模式 (简化表示，实际可能为枚举)
    int m_motor1Value; // 电机1当前值
    int m_motor2Value; // 电机2当前值
    // DataSource* m_dataSource=nullptr; // 已移除
};

#endif // DEVICE_MODULE_H

