#include "vessel_module.h"
#include <QDebug>
#include <QtMath>

VesselModule::VesselModule(QObject *parent)
    : VisualizationBase(parent) {
    m_displayData = {
        {"latitude", 0.0},
        {"longitude", 0.0},
        {"speed", 0.0},
        {"heading", 0.0}
    };
}

void VesselModule::parseData(const QString& data) {
    if (data.length() < 14) { // 检查数据长度
        return;
    }

    QStringList bytes;
    for(int i = 0; i < data.length(); i += 2) {
        bytes.append(data.mid(i, 2));
    }

    if (bytes.size() < 7) { // 检查数据字节数
        return;
    }

    int offset = 0;
    bool ok;

    // Longitude (5 bytes) - 1字节整数部分(包含符号)，4字节小数部分
    int8_t lon_int = bytes[offset].toInt(&ok, 16);
    int lonsign = (lon_int < 0) ? -1 : 1;
    int lon_integer = abs(lon_int);
    uint32_t lon_decimal = 0;
    for (int i = 1; i <= 4; ++i) {
        lon_decimal = (lon_decimal << 8) | bytes[offset + i].toInt(&ok, 16);
    }
    double longitude = (lon_integer + lon_decimal / 10000.0) * lonsign;
    offset += 5;

    // Latitude (5 bytes) - 同上
    int8_t lat_int = bytes[offset].toInt(&ok, 16);
    int latsign = (lat_int < 0) ? -1 : 1;
    int lat_integer = abs(lat_int);
    uint32_t lat_decimal = 0;
    for (int i = 1; i <= 4; ++i) {
        lat_decimal = (lat_decimal << 8) | bytes[offset + i].toInt(&ok, 16);
    }
    double latitude = (lat_integer + lat_decimal / 10000.0) * latsign;
    offset += 5;

    // Speed (2 bytes) - 保留2位小数
    int speed_raw = (bytes[offset].toInt(&ok, 16) << 8) | bytes[offset + 1].toInt(&ok, 16);
    double speed = speed_raw / 100.0;
    offset += 2;

    // Heading (2 bytes) - 范围-180到180度
    // 修复：正确使用head_int而非lat_int确定符号
    int8_t head_int = bytes[offset].toInt(&ok, 16);
    int headsign = (head_int < 0) ? -1 : 1; // 修复：使用head_int变量
    int head_integer = abs(head_int);
    uint8_t head_decimal = bytes[offset + 1].toInt(&ok, 16);
    double heading = (head_integer + head_decimal / 100.0) * headsign;

    // 更新内部数据
    m_displayData["longitude"] = longitude;
    m_displayData["latitude"] = latitude;
    m_displayData["speed"] = speed;
    m_displayData["heading"] = heading;

    // 发送信号
    emit vesselDataParsed(latitude, longitude, speed, heading);
    emit displayDataChanged();
}


void VesselModule::updateData() {
    // Simulation data update is handled in DataSource
}
