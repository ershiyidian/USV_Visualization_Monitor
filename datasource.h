#pragma once

#include <QObject>
#include <QSerialPort>
#include <QTimer>
#include <QDebug>
#include <QStringList>
#include <QElapsedTimer>

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
    Q_PROPERTY(quint16 motor2 READ motor2 WRITE setMotor2 NOTIFY motor2Changed)
    Q_PROPERTY(bool pump_mode READ pump_mode WRITE updatePumpModeInDataSource NOTIFY pump_modeChanged)
    Q_PROPERTY(bool boat_mode READ boat_mode WRITE updateBoatModeInDataSource NOTIFY boat_modeChanged)
public:
    // 传感器数据结构
    struct SensorData {
        uint16_t PWM_SET1;        // 电机1 PWM
        uint16_t PWM_SET2;        // 电机2 PWM
        uint16_t CO2;             // CO2浓度 (ppm)
        uint16_t CH2O;            // 甲醛浓度 (ppb)
        uint16_t TVOC;            // 总挥发性有机物 (ppb)
        uint16_t PM2_5;           // PM2.5 (μg/m³)
        uint16_t PM10;            // PM10 (μg/m³)
        uint8_t temperature_air_High; // 空气温度高字节
        uint8_t temperature_air_Low;  // 空气温度低字节
        uint8_t humidity_air_High;    // 空气湿度高字节
        uint8_t humidity_air_Low;     // 空气湿度低字节
        uint16_t turbidity;       // 浊度 (NTU)
        uint16_t PH;              // pH值 * 100
        uint16_t TDS;             // 总溶解固体 (ppm)
        uint8_t temperaturewater_High; // 水温高字节
        uint8_t temperaturewater_Low;  // 水温低字节
        int16_t dis;              // 液位值 (mm)
    };

    // 船只数据结构
    struct BoatData {
        double latitude;          // 纬度
        double longitude;         // 经度
        double speed;             // 速度 (m/s)
        double heading;           // 航向角 (-180~180°)
    };

    // 设备数据结构
    struct DeviceData {
        uint16_t battery;         // 电池电量 (%)
        bool mode;                // 工作模式 (0=手动, 1=自动)
    };

    // 任务点数据结构
    struct TaskPointData {
        double latitude;          // 纬度
        double longitude;         // 经度
        bool isHomePoint;         // 是否为Home点
        std::time_t timestamp;    // 时间戳
    };

    explicit DataSource(QObject *parent = nullptr);
    ~DataSource();

    // 属性访问器
    bool pumpState() const { return m_pumpState; }
    bool pump_mode() const {return m_pump_mode; }
    bool boat_mode() const {return m_boat_mode; }
    quint16 motor1() const { return m_motor1; }
    quint16 motor2() const { return m_motor2; }
    QStringList availablePorts() const { return m_availablePorts; }
    bool isPortOpen() const { return serialPort->isOpen(); }
    bool isSimulating() const { return m_isSimulating; }
    QString mergedFrameHeader() const { return m_mergedFrameHeader; }
    QString mergedFrameTrailer() const { return m_mergedFrameTrailer; }

    // Q_INVOKABLE方法(从QML可调用)
    Q_INVOKABLE bool openSerialPort(const QString& portName, int baudRate);
    Q_INVOKABLE void closeSerialPort();

    // 数据有效性检查
    bool isValidMotorValue(quint16 value) const;
    bool isValidGpsCoordinate(double lat, double lon) const;

public slots:
    void setIsSimulating(bool enabled);
    void setMergedFrameHeader(const QString& header);
    void setMergedFrameTrailer(const QString& trailer);
    void sendData(const std::vector<QString>& taskPointsData);
    void setPumpState(bool state);
    void setMotor1(quint16 value);
    void setMotor2(quint16 value);
    void updatePumpModeInDataSource(bool mode);
    void updateBoatModeInDataSource(bool mode);
signals:
    void sensorDataReceived(const QString& data);
    void vesselDataReceived(const QString& data);
    void deviceDataReceived(const QString& data);
    void mergedDataReceived(const QString& data);
    void error(const QString& message);
    void portOpenChanged();
    void availablePortsChanged();
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
    bool m_isSimulating = false;
    QString m_mergedFrameHeader;
    QString m_mergedFrameTrailer;
    bool m_pump_mode=false;
    bool m_boat_mode=false;
    // 私有对象
    QSerialPort* serialPort;
    QTimer* portUpdateTimer;
    QTimer* simulationTimer;
    QByteArray buffer;
    QElapsedTimer m_simulationElapsedTimer;

    // 模拟数据生成相关变量
    double m_simulatedLatitude;
    double m_simulatedLongitude;
    double m_simulatedHeading = 0.0;
    double m_simulatedSpeed = 0.0;
    uint16_t m_simulatedBattery = 100;
    bool m_simulatedMode = false;

    // 私有方法
    QByteArray parseHexString(const QString& hexStr);
    bool isValidFrame(const QByteArray& data);
    void processReceivedData(const QByteArray& data);
    void readSerialData();
    void handleSerialError(QSerialPort::SerialPortError error);
    void checkAvailablePorts();
    void generateFakeData();
    QByteArray generateMergedFrame();
    int calculateFrameSize(const QByteArray& data);

    // 数据转换方法
    double convertAirTemperature(uint8_t high, uint8_t low);
    double convertWaterTemperature(uint8_t high, uint8_t low);
    uint16_t convertFromLittleEndian(uint8_t low, uint8_t high);

    // 生成模拟传感器数据
    SensorData generateFakeSensorData();
    // 生成模拟船只数据
    BoatData generateFakeBoatData();
    // 生成模拟设备数据
    DeviceData generateFakeDeviceData();
    // 更新模拟移动轨迹
    void updateSimulatedPosition();
};
