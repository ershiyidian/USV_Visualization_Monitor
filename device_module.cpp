#include "device_module.h" // 包含头文件
// #include"datasource.h" // DataSource的直接包含已移除，通过信号槽与外部交互
#include <QDebug> // 用于调试输出
// #include <QtMath> // QtMath 可能不再需要
#include "datasource.h" // 包含DataSource.h以访问FrameConstants中的电机常量

// 构造函数
DeviceModule::DeviceModule(QObject *parent)
    : VisualizationBase(parent),
      m_pumpActive(false),      // 初始化水泵激活状态为false
      m_pumpAutoMode(false),    // 初始化水泵自动模式为false
      m_boatAutoMode(false),    // 初始化船只自动模式为false (简化表示)
      m_motor1Value(FrameConstants::MOTOR_NEUTRAL), // 初始化电机1为中立值
      m_motor2Value(FrameConstants::MOTOR_NEUTRAL)  // 初始化电机2为中立值
{
    // 初始化用于QML显示的数据结构
    m_displayData = {
        {"battery", 0},                     // 电池电量
        {"operationalMode", "手动"}         // 操作模式，默认为手动
    };
}

// DeviceModule::DeviceModule(DataSource* dataSource,QObject *parent) // 带DataSource指针的构造函数已移除
//     : VisualizationBase(parent),m_dataSource(dataSource)
// {
//     // ...
// }

// void DeviceModule::parseData(const QString& data) // 旧的解析函数，已移除
// {
//     // ... 实现已删除 ...
// }

// 处理来自DataSource的DeviceStatusDto更新的槽函数
void DeviceModule::handleDeviceStatusUpdated(const DeviceStatusDto& deviceStatus) {
    // 更新内部存储以供QML显示
    m_displayData["battery"] = deviceStatus.batteryLevel;
    m_displayData["operationalMode"] = deviceStatus.operationalMode; // DTO直接提供字符串

    // qDebug() << "DeviceModule: Received DeviceStatusDto - Battery:" << deviceStatus.batteryLevel
    //          << "Mode:" << deviceStatus.operationalMode;

    emit displayDataChanged(); // 发送信号通知QML更新视图

    emit deviceStatusReadyForLog(deviceStatus); // 发送带有DTO的信号，用于数据库日志记录
}


// 更新数据的槽函数 (目前主要由handleDeviceStatusUpdated驱动)
void DeviceModule::updateData() {
    // 此函数在VisualizationBase中声明为纯虚函数，必须实现。
    // 在当前DTO驱动的架构中，数据更新主要由 handleDeviceStatusUpdated 触发。
    // qDebug() << "DeviceModule::updateData() called, but updates are DTO-driven.";
}

// Getter 方法已在 .h 文件中内联定义

// 设置水泵激活状态 (由QML调用)
void DeviceModule::setPumpActive(bool active) {
    if (m_pumpActive != active) {
        m_pumpActive = active;
        emit pumpActiveChanged(active); // 通知QML属性变更

        DeviceControlDto controlDto;
        // Populate all fields for DeviceControlDto
        controlDto.pumpActive = m_pumpActive;
        controlDto.pumpAuto = m_pumpAutoMode;
        controlDto.boatMode = m_boatAutoMode ? DeviceControlDto::Auto : DeviceControlDto::Manual; // 简化映射
        controlDto.motor1Value = m_motor1Value; // 新增: 填充电机1值
        controlDto.motor2Value = m_motor2Value; // 新增: 填充电机2值

        emit deviceControlRequested(controlDto); // 发送设备控制请求信号
        qDebug() << "DeviceModule: Pump active state set to" << active << ", control DTO sent with M1:" << controlDto.motor1Value << "M2:" << controlDto.motor2Value;
    }
}

// 设置水泵自动模式 (由QML调用)
void DeviceModule::setPumpAutoMode(bool mode){
    if(m_pumpAutoMode != mode){
        m_pumpAutoMode = mode;
        emit pumpAutoModeChanged(mode); // 通知QML属性变更

        DeviceControlDto controlDto;
        controlDto.pumpActive = m_pumpActive;
        controlDto.pumpAuto = m_pumpAutoMode;
        controlDto.boatMode = m_boatAutoMode ? DeviceControlDto::Auto : DeviceControlDto::Manual;
        controlDto.motor1Value = m_motor1Value; // 新增: 填充电机1值
        controlDto.motor2Value = m_motor2Value; // 新增: 填充电机2值
        emit deviceControlRequested(controlDto);
        qDebug() << "DeviceModule: Pump auto mode set to" << mode << ", control DTO sent with M1:" << controlDto.motor1Value << "M2:" << controlDto.motor2Value;
    }
}

// 设置船只自动模式 (由QML调用, 简化表示)
void DeviceModule::setBoatAutoMode(bool mode){
    if(m_boatAutoMode != mode){
        m_boatAutoMode = mode;
        emit boatAutoModeChanged(mode); // 通知QML属性变更

        DeviceControlDto controlDto;
        controlDto.pumpActive = m_pumpActive;
        controlDto.pumpAuto = m_pumpAutoMode;
        controlDto.boatMode = m_boatAutoMode ? DeviceControlDto::Auto : DeviceControlDto::Manual;
        controlDto.motor1Value = m_motor1Value; // 新增: 填充电机1值
        controlDto.motor2Value = m_motor2Value; // 新增: 填充电机2值
        // If boatMode becomes Auto, should motors go to neutral or hold position?
        // This logic should reside in DataSource or the boat's firmware.
        // DeviceModule just signals the intent.
        if (controlDto.boatMode == DeviceControlDto::Auto) {
             // Example: When switching to Auto, reset manual motor overrides to neutral if needed
             // This depends on desired behavior. For now, we don't change motor values directly here.
             // However, the DTO now carries the current m_motor1Value and m_motor2Value.
             // If Auto mode implies neutral motors, DataSource::handleDeviceControl should enforce it.
        }
        emit deviceControlRequested(controlDto);
        qDebug() << "DeviceModule: Boat auto mode set to" << mode << ", control DTO sent with M1:" << controlDto.motor1Value << "M2:" << controlDto.motor2Value;
    }
}

// 设置电机1的值 (由QML调用)
void DeviceModule::setMotor1Value(int value) {
    // 校验电机值是否有效 (使用FrameConstants)
    if (value < FrameConstants::MOTOR_MIN_VALUE || value > FrameConstants::MOTOR_MAX_VALUE) {
        // qWarning() << "DeviceModule: Invalid motor1 value:" << value;
        // Optionally, clamp or ignore. For now, we allow it to be set,
        // but the real control might be on DataSource or hardware.
        // Let's clamp it for safety on DeviceModule side for now.
        value = qBound(FrameConstants::MOTOR_MIN_VALUE, value, FrameConstants::MOTOR_MAX_VALUE);
    }

    if (m_motor1Value != value) {
        m_motor1Value = value;
        emit motor1ValueChanged(m_motor1Value); // 通知QML属性变更

        DeviceControlDto controlDto;
        controlDto.pumpActive = m_pumpActive;
        controlDto.pumpAuto = m_pumpAutoMode;
        // When motors are manually controlled, boatMode should likely be Manual
        // However, this could also be a speed override in an Auto mode.
        // For now, setting motors implies manual steering override.
        controlDto.boatMode = DeviceControlDto::Manual; // Assume motor control implies manual mode
        m_boatAutoMode = false; // Reflect this state change
        emit boatAutoModeChanged(m_boatAutoMode);


        // The DeviceControlDto doesn't have direct motor1/motor2 fields.
        // This implies that DataSource::handleDeviceControl should either:
        // 1. Infer motor commands from boatMode (e.g., if Manual, check DataSource's own motor properties)
        // 2. DeviceControlDto needs motor command fields, or a nested MotorCommandDto.
        //
        // For the current task, we need to send motor values.
        // Let's assume DataSource's handleDeviceControl will look at its own motor properties
        // if boatMode is Manual. So, DeviceModule needs to update DataSource's motor properties.
        // This is what the old direct call `m_dataSource->setMotor1(value)` did.
        // The new way is via a DTO.
        //
        // The current DeviceControlDto is insufficient for direct motor control.
        // This was an oversight in step 8's DTO design if direct motor setting from UI is desired
        // without DataSource managing its own motor values for manual mode.
        //
        // TEMPORARY WORKAROUND: We will emit deviceControlRequested with the boatMode set to Manual.
        // DataSource's handleDeviceControl will need to be made aware (in step 10) that if it receives
        // a Manual mode, it should then check its *own* m_motor1/m_motor2 properties which DeviceModule
        // will update through a separate mechanism OR DeviceControlDto needs to be extended.
        //
        // Let's assume for now that DeviceModule's setMotor1Value is a high-level request
        // and DataSource will eventually get these values.
        // The current `deviceControlRequested` signal sends a DTO that *lacks* explicit motor values.
        // This means DataSource won't receive the motor values via this DTO.
        //
        // This part of the architecture needs refinement. For step 9, I will emit the DTO as is,
        // and make a note that DataSource's `handleDeviceControl` and potentially the DTO itself
        // will need changes in step 10 to correctly relay motor commands.
        // For now, let's assume the request sets the boat to Manual, and a separate update mechanism
        // for motor values in DataSource will be used (like the old direct calls, but that's what we are removing).
        //
        // Correct approach: Extend DeviceControlDto or have a separate MotorCommandDto signal.
        // Given the current tools, I will have to make do.
        // The most straightforward way with current DTOs is to assume if boatMode in DTO is Manual,
        // DataSource will use its own motor values. DeviceModule should update these in DataSource.
        // But DeviceModule no longer has a direct DataSource pointer.
        //
        controlDto.motor1Value = m_motor1Value; // 使用更新后的 m_motor1Value
        controlDto.motor2Value = m_motor2Value; // 使用当前的 m_motor2Value

        // qDebug() << "DeviceModule: Motor1 value set to" << m_motor1Value << ". Control DTO sent (manual mode assumed).";
        // qDebug() << "DESIGN NOTE: DeviceControlDto needs fields for motor1/motor2 or a separate MotorCommand signal/DTO is required for proper motor control propagation to DataSource.";
        // DESIGN NOTE 已解决，DTO现在包含电机值。

        emit deviceControlRequested(controlDto);
        qDebug() << "DeviceModule: Motor1 value set to" << m_motor1Value << ", control DTO sent with M1:" << controlDto.motor1Value << "M2:" << controlDto.motor2Value;
    }
}

// 设置电机2的值 (由QML调用)
void DeviceModule::setMotor2Value(int value) {
    if (value < FrameConstants::MOTOR_MIN_VALUE || value > FrameConstants::MOTOR_MAX_VALUE) {
        // qWarning() << "DeviceModule: Invalid motor2 value:" << value;
        value = qBound(FrameConstants::MOTOR_MIN_VALUE, value, FrameConstants::MOTOR_MAX_VALUE);
    }

    if (m_motor2Value != value) {
        m_motor2Value = value;
        emit motor2ValueChanged(m_motor2Value);

        DeviceControlDto controlDto;
        controlDto.pumpActive = m_pumpActive;
        controlDto.pumpAuto = m_pumpAutoMode;
        controlDto.boatMode = DeviceControlDto::Manual; // Assume motor control implies manual mode
        m_boatAutoMode = false; // Reflect this state change
        emit boatAutoModeChanged(m_boatAutoMode);
        controlDto.motor1Value = m_motor1Value; // 使用当前的 m_motor1Value
        controlDto.motor2Value = m_motor2Value; // 使用更新后的 m_motor2Value

        // qDebug() << "DeviceModule: Motor2 value set to" << m_motor2Value << ". Control DTO sent (manual mode assumed).";
        // DESIGN NOTE 已解决

        emit deviceControlRequested(controlDto);
        qDebug() << "DeviceModule: Motor2 value set to" << m_motor2Value << ", control DTO sent with M1:" << controlDto.motor1Value << "M2:" << controlDto.motor2Value;
    }
}

// QML调用的发送任务指令的槽函数
void DeviceModule::sendMissionCommand(const QVariantMap& homePointData, const QVariantList& waypointsData)
{
    MissionCommandDto missionDto; // 创建任务指令DTO

    // 解析Home点数据
    if (homePointData.contains("latitude") && homePointData.contains("longitude") && homePointData.contains("timestamp")) {
        missionDto.homePoint.latitude = homePointData["latitude"].toDouble();
        missionDto.homePoint.longitude = homePointData["longitude"].toDouble();
        missionDto.homePoint.timestamp = homePointData["timestamp"].toString(); // 时间戳为字符串
        qDebug() << "DeviceModule: Parsed Home Point - Lat:" << missionDto.homePoint.latitude
                 << "Lon:" << missionDto.homePoint.longitude
                 << "TS:" << missionDto.homePoint.timestamp;
    } else {
        qWarning() << "DeviceModule: Home point data is invalid or incomplete.";
        // Optionally, return or handle error
    }

    // 解析航点数据
    for (const QVariant& waypointVar : waypointsData) {
        QVariantMap waypointMap = waypointVar.toMap();
        if (waypointMap.contains("latitude") && waypointMap.contains("longitude") && waypointMap.contains("timestamp")) {
            MissionPointDto waypointDto;
            waypointDto.latitude = waypointMap["latitude"].toDouble();
            waypointDto.longitude = waypointMap["longitude"].toDouble();
            waypointDto.timestamp = waypointMap["timestamp"].toString(); // 时间戳为字符串
            missionDto.waypoints.append(waypointDto);
        } else {
            qWarning() << "DeviceModule: A waypoint data is invalid or incomplete.";
        }
    }
    qDebug() << "DeviceModule: Parsed" << missionDto.waypoints.size() << "waypoints.";

    // 发送任务指令请求信号，携带DTO
    emit missionCommandRequested(missionDto);
    qDebug() << "DeviceModule: Emitted missionCommandRequested signal.";
}
