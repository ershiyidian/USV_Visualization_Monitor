#ifndef DATATRANSFEROBJECTS_H
#define DATATRANSFEROBJECTS_H

#include <QString>
#include <QList>
#include <QMetaType> // Required for Q_DECLARE_METATYPE
#include <QGeoCoordinate> // For location data

// Forward declaration for MissionPointDto to be used in MissionCommandDto
struct MissionPointDto;

/**
 * @brief 传感器数据传输对象
 */
struct SensorDataDto {
    // 大气传感器数据
    int co2;            // CO2浓度 (ppm)
    double ch2o;        // 甲醛浓度 (mg/m³)
    double tvoc;        // 总挥发性有机物浓度 (mg/m³)
    int pm25;           // PM2.5颗粒物浓度 (µg/m³)
    int pm10;           // PM10颗粒物浓度 (µg/m³)
    double airTemperature; // 空气温度 (℃)
    double airHumidity;    // 空气湿度 (%RH)

    // 水质传感器数据
    double waterTurbidity; // 水体浊度 (NTU)
    double ph;             // pH值
    double tds;            // 总溶解固体 (ppm)
    double waterTemperature; // 水体温度 (℃)
    double waterLevel;     // 水位 (m)

    SensorDataDto() :
        co2(0), ch2o(0.0), tvoc(0.0), pm25(0), pm10(0),
        airTemperature(0.0), airHumidity(0.0),
        waterTurbidity(0.0), ph(0.0), tds(0.0),
        waterTemperature(0.0), waterLevel(0.0) {}
};
Q_DECLARE_METATYPE(SensorDataDto)

/**
 * @brief 船体状态数据传输对象
 */
struct VesselStateDto {
    double latitude;    // 纬度 (度)
    double longitude;   // 经度 (度)
    double speed;       // 速度 (m/s)
    double heading;     // 航向 (度)

    VesselStateDto() :
        latitude(0.0), longitude(0.0), speed(0.0), heading(0.0) {}
};
Q_DECLARE_METATYPE(VesselStateDto)

/**
 * @brief 设备状态数据传输对象
 */
struct DeviceStatusDto {
    int batteryLevel;   // 电池电量 (%)
    QString operationalMode; // 操作模式 (例如: "manual", "auto")

    DeviceStatusDto() :
        batteryLevel(0), operationalMode("") {}
};
Q_DECLARE_METATYPE(DeviceStatusDto)

/**
 * @brief 设备控制数据传输对象
 */
struct DeviceControlDto {
    /**
     * @brief 船只模式枚举
     */
    enum BoatMode {
        Manual,       // 手动模式
        Auto,         // 自动模式
        PositionHold  // 位置保持模式
    };
    Q_ENUM(BoatMode) // Register enum with meta-object system

    BoatMode boatMode;   // 船只模式
    bool pumpActive;     // 水泵是否激活
    bool pumpAuto;       // 水泵是否自动控制
    int motor1Value;     // 电机1输出值 (例如 675-1353, 1013为中立)
    int motor2Value;     // 电机2输出值 (例如 675-1353, 1013为中立)

    DeviceControlDto() :
        boatMode(Manual), pumpActive(false), pumpAuto(false),
        motor1Value(1013), motor2Value(1013) {} // 初始化电机为中立值
};
Q_DECLARE_METATYPE(DeviceControlDto)

/**
 * @brief 电机指令数据传输对象
 */
struct MotorCommandDto {
    int motor1Value;    // 电机1输出值
    int motor2Value;    // 电机2输出值

    MotorCommandDto() :
        motor1Value(0), motor2Value(0) {}
};
Q_DECLARE_METATYPE(MotorCommandDto)

/**
 * @brief 任务点数据传输对象
 */
struct MissionPointDto {
    double latitude;    // 纬度 (度)
    double longitude;   // 经度 (度)
    QString timestamp;  // 时间戳 (字符串格式 "yyyy-MM-dd hh:mm:ss")

    MissionPointDto() :
        latitude(0.0), longitude(0.0), timestamp("") {}

    MissionPointDto(double lat, double lon, QString ts = "") :
        latitude(lat), longitude(lon), timestamp(ts) {}

    // For QGeoCoordinate integration if needed later
    // QGeoCoordinate toCoordinate() const { return QGeoCoordinate(latitude, longitude); }
    // static MissionPointDto fromCoordinate(const QGeoCoordinate& coord) { return MissionPointDto(coord.latitude(), coord.longitude()); }
};
Q_DECLARE_METATYPE(MissionPointDto)

/**
 * @brief 任务指令数据传输对象
 */
struct MissionCommandDto {
    QList<MissionPointDto> waypoints; // 航点列表
    MissionPointDto homePoint;        // 返航点

    MissionCommandDto() {}
};
Q_DECLARE_METATYPE(MissionCommandDto)

#endif // DATATRANSFEROBJECTS_H
