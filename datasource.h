#pragma once

#include <QObject>
#include <QSerialPort>
#include <QTimer>
#include <QDebug>
#include <QStringList>
#include <QElapsedTimer>

#include "DataTransferObjects.h" // <-- 新增: 包含DTO头文件

// 数据帧常量定义
namespace FrameConstants {
// 帧大小常量
const int RECEIVE_FRAME_SIZE = 65;    // 接收帧大小

// 帧头帧尾常量
const uint8_t FRAME_HEADER = 0xFF;    // 帧头
const uint8_t FRAME_TRAILER = 0xFE;   // 帧尾

// 接收帧偏移量
const int SENSOR_DATA_OFFSET = 2;     // 传感器数据起始位置
const int SENSOR_DATA_LENGTH = 30;    // 传感器数据长度
const int LAT_OFFSET = 32;            // 纬度起始位置
const int LON_OFFSET = 37;            // 经度起始位置
const int HEADING_OFFSET = 42;        // 航向角起始位置
const int SPEED_OFFSET = 44;          // 速度起始位置
const int BATTERY_OFFSET = 46;        // 电池起始位置
const int MODE_OFFSET = 48;           // 模式起始位置

// 发送帧偏移量
const int FRAME_HEADER_SIZE=2;        //帧头长度
const int TIMESTAMP_LENGTH = 8;       // 时间戳长度
const int HOME_POINT_SIZE = 10;       // Home点长度
const int TASK_POINT_SIZE = 10;       // 任务点长度
const int MAX_TASK_POINTS = 50;       // 最大任务点数量
const int CONTROL_BLOCK_SIZE=7;       //控制指令块长度 (7字节, 偏移 20 + 10*N 起)
const int RESERVED_SIZE=14;           //保留区长度 (14字节, 偏移 27 + 10*N 起)

// 坐标点结构
const int COORD_INT_SIZE = 1;         // 整数部分大小
const int COORD_FLOAT_SIZE = 4;       // 小数部分大小
const int COORD_TOTAL_SIZE = 5;       // 坐标总大小

// 电机控制常量
const int MOTOR_MIN_VALUE = 675;      // 电机最小值
const int MOTOR_NEUTRAL = 1013;       // 电机中值
const int MOTOR_MAX_VALUE = 1353;     // 电机最大值

// 传感器常量
namespace SensorLimits {
// CO2范围（ppm）
const int CO2_MIN = 400;
const int CO2_MAX = 2000;
const int CO2_WARNING = 1000;
const int CO2_CRITICAL = 2000;

// 甲醛范围（mg/m³）
const double CH2O_MIN = 0.01;
const double CH2O_MAX = 0.15;
const double CH2O_WARNING = 0.08;
const double CH2O_CRITICAL = 0.1;

// TVOC范围（ppb）
const int TVOC_MIN = 50;
const int TVOC_MAX = 1000;
const int TVOC_WARNING = 500;
const int TVOC_CRITICAL = 800;

// PM2.5范围（μg/m³）
const int PM25_MIN = 0;
const int PM25_MAX = 250;
const int PM25_WARNING = 75;
const int PM25_CRITICAL = 150;

// PM10范围（μg/m³）
const int PM10_MIN = 0;
const int PM10_MAX = 350;
const int PM10_WARNING = 150;
const int PM10_CRITICAL = 250;

// 空气温度范围（°C）
const double AIR_TEMP_MIN = 5.0;
const double AIR_TEMP_MAX = 40.0;

// 湿度范围（%）
const double HUMIDITY_MIN = 20.0;
const double HUMIDITY_MAX = 90.0;

// 浊度范围（NTU）
const int TURBIDITY_MIN = 0;
const int TURBIDITY_MAX = 25;
const int TURBIDITY_WARNING = 5;
const int TURBIDITY_CRITICAL = 20;

// pH值范围
const double PH_MIN = 5.0;
const double PH_MAX = 10.0;
const double PH_WARNING = 8.5;
const double PH_CRITICAL = 9.0;

// TDS范围（ppm）
const int TDS_MIN = 50;
const int TDS_MAX = 1500;
const int TDS_WARNING = 500;
const int TDS_CRITICAL = 1000;

// 水温范围（°C）
const double WATER_TEMP_MIN = 5.0;
const double WATER_TEMP_MAX = 35.0;

// 液位范围（mm）
const int LEVEL_MIN = 0;
const int LEVEL_MAX = 100;
}
}

class DataSource : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString mergedFrameHeader READ mergedFrameHeader WRITE setMergedFrameHeader NOTIFY mergedFrameHeaderChanged)
    Q_PROPERTY(QString mergedFrameTrailer READ mergedFrameTrailer WRITE setMergedFrameTrailer NOTIFY mergedFrameTrailerChanged)
    Q_PROPERTY(bool isSimulating READ isSimulating WRITE setIsSimulating NOTIFY isSimulatingChanged)
    Q_PROPERTY(bool isPortOpen READ isPortOpen NOTIFY portOpenChanged)
    Q_PROPERTY(QStringList availablePorts READ availablePorts NOTIFY availablePortsChanged)
    Q_PROPERTY(bool pumpState READ pumpState WRITE setPumpState NOTIFY pumpStateChanged)
    Q_PROPERTY(quint16 motor1 READ motor1 WRITE setMotor1 NOTIFY motor1Changed)
    Q_PROPERTY(quint16 motor2 READ motor2 WRITE setMotor2 NOTIFY motor2Changed) // 电机2输出值属性
    Q_PROPERTY(bool pump_mode READ pump_mode WRITE updatePumpModeInDataSource NOTIFY pump_modeChanged) // 水泵模式属性 (false=手动, true=自动)
    Q_PROPERTY(bool boat_mode READ boat_mode WRITE updateBoatModeInDataSource NOTIFY boat_modeChanged) // 船只模式属性 (false=手动, true=自动)
public:
    explicit DataSource(QObject *parent = nullptr); // 构造函数
    ~DataSource(); // 析构函数

    // 属性访问器
    bool pumpState() const { return m_pumpState; } // 获取水泵状态
    bool pump_mode() const {return m_pump_mode; } // 获取水泵模式
    bool boat_mode() const {return m_boat_mode; } // 获取船只模式
    quint16 motor1() const { return m_motor1; } // 获取电机1的值
    quint16 motor2() const { return m_motor2; } // 获取电机2的值
    QStringList availablePorts() const { return m_availablePorts; } // 获取可用串口列表
    bool isPortOpen() const { return serialPort->isOpen(); } // 检查串口是否打开
    bool isSimulating() const { return m_isSimulating; } // 检查是否处于模拟模式
    QString mergedFrameHeader() const { return m_mergedFrameHeader; } // 获取合并帧头 (十六进制字符串)
    QString mergedFrameTrailer() const { return m_mergedFrameTrailer; } // 获取合并帧尾 (十六进制字符串)

    // Q_INVOKABLE方法 (可从QML调用)
    Q_INVOKABLE bool openSerialPort(const QString& portName, int baudRate); // 打开串口
    Q_INVOKABLE void closeSerialPort(); // 关闭串口

    // 数据有效性检查方法
    bool isValidMotorValue(quint16 value) const; // 检查电机值是否在有效范围内
    bool isValidGpsCoordinate(double lat, double lon) const; // 检查GPS坐标是否有效

public slots:
    void setIsSimulating(bool enabled); // 设置是否启用数据模拟
    void setMergedFrameHeader(const QString& header); // 设置合并帧头 (十六进制字符串)
    void setMergedFrameTrailer(const QString& trailer); // 设置合并帧尾 (十六进制字符串)
    void sendData(const std::vector<QString>& taskPointsData); // @deprecated 旧的发送任务点数据接口，将由handleMissionCommand取代
    void setPumpState(bool state); // 设置水泵开启/关闭状态
    void setMotor1(quint16 value); // 设置电机1的输出值
    void setMotor2(quint16 value); // 设置电机2的输出值
    void updatePumpModeInDataSource(bool mode); // @deprecated 更新水泵的工作模式 (手动/自动) -已被新的控制流程取代
    void updateBoatModeInDataSource(bool mode); // @deprecated 更新船只的工作模式 (手动/自动) -已被新的控制流程取代
    void handleDeviceControl(const DeviceControlDto& controlCmd); // 处理来自DeviceModule的设备控制指令
    void handleMissionCommand(const MissionCommandDto& missionCmd); // 新增: 处理来自DeviceModule的任务指令

signals:
    // 新的DTO信号 - 用于通知数据更新
    void sensorDataUpdated(const SensorDataDto& sensorData);     // 传感器数据更新信号 (DTO)
    void vesselStateUpdated(const VesselStateDto& vesselState);   // 船体状态更新信号 (DTO)
    void deviceStatusUpdated(const DeviceStatusDto& deviceStatus); // 设备状态更新信号 (DTO)

    void error(const QString& message); // 错误信息信号
    void portOpenChanged(); // 串口打开状态变更信号
    void availablePortsChanged(); // 可用串口列表变更信号
    void isSimulatingChanged();
    void mergedFrameHeaderChanged();
    void mergedFrameTrailerChanged();
    void pumpStateChanged();
    void motor1Changed();
    void motor2Changed();
    void pump_modeChanged();
    void boat_modeChanged();
private:
    // 私有属性
    bool m_pumpState = false;
    quint16 m_motor1 = FrameConstants::MOTOR_NEUTRAL;
    quint16 m_motor2 = FrameConstants::MOTOR_NEUTRAL;
    QStringList m_availablePorts;
    bool m_isSimulating = false; // 当前是否处于数据模拟状态
    QString m_mergedFrameHeader; // 合并帧头字符串 (十六进制)
    QString m_mergedFrameTrailer; // 合并帧尾字符串 (十六进制)
    bool m_pump_mode = false; // 水泵模式 (false=手动, true=自动)
    bool m_boat_mode = false; // 船只模式 (false=手动, true=自动)

    // 私有对象
    QSerialPort* serialPort; // 串口对象
    QTimer* portUpdateTimer; // 串口列表更新定时器
    QTimer* simulationTimer; // 数据模拟定时器
    QByteArray buffer; // 串口数据接收缓冲区
    QElapsedTimer m_simulationElapsedTimer; // 模拟持续时间计时器

    // 模拟数据生成相关变量
    double m_simulatedLatitude;    // 模拟的纬度
    double m_simulatedLongitude;   // 模拟的经度
    double m_simulatedHeading = 0.0; // 模拟的航向
    double m_simulatedSpeed = 0.0;   // 模拟的速度
    uint16_t m_simulatedBattery = 100; // 模拟的电池电量
    bool m_simulatedMode = false;    // 模拟的船只操作模式 (false=手动, true=自动)

    // 私有方法
    QByteArray parseHexString(const QString& hexStr); // 解析十六进制字符串为字节数组
    bool isValidFrame(const QByteArray& data); // 校验接收的数据帧的帧头帧尾是否匹配
    void processReceivedData(const QByteArray& data); // 处理从串口接收到的原始数据，解析并发送DTO信号
    void readSerialData(); // 当串口有数据可读时调用此方法
    void handleSerialError(QSerialPort::SerialPortError error); // 处理串口发生的错误
    void checkAvailablePorts(); // 定期检查系统中的可用串口列表
    void generateFakeData(); // 生成模拟的传感器、船体和设备数据 (DTOs) 并发送信号
    // QByteArray generateMergedFrame(); // 此函数已从 .cpp 中移除，其声明在此处注释掉或删除
    int calculateFrameSize(const QByteArray& data); // 根据帧定义计算期望的帧大小

    // 数据转换辅助方法
    double convertAirTemperature(uint8_t high, uint8_t low); // 将高低字节组合为空气温度值
    double convertWaterTemperature(uint8_t high, uint8_t low); // 将高低字节组合为水体温度值
    uint16_t convertFromLittleEndian(uint8_t low, uint8_t high); // 将小端序的两个字节转换为uint16_t

    // DTO模拟数据生成函数的声明 (这些函数在.cpp中实现)
    SensorDataDto generateFakeSensorDataDto();       // 生成模拟的传感器数据DTO
    VesselStateDto generateFakeVesselStateDto();     // 生成模拟的船体状态DTO
    DeviceStatusDto generateFakeDeviceStatusDto();   // 生成模拟的设备状态DTO

    // 更新模拟数据中的船只位置和状态
    void updateSimulatedPosition(); // 更新模拟的船只位置、航向、速度等
};
