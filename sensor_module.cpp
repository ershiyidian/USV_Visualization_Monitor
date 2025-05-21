#include "sensor_module.h"

SensorModule::SensorModule(QObject *parent)
    : VisualizationBase(parent)
{
    m_displayData = {
        {"air", QVariantMap{
                    {"co2", 0},
                    {"ch2o", 0},
                    {"tvoc", 0},
                    {"pm25", 0},
                    {"pm10", 0},
                    {"temperature", 0.0},
                    {"humidity", 0.0}
                }},
        {"water", QVariantMap{
                      {"turbidity", 0},
                      {"ph", 0.0},
                      {"tds", 0},
                      {"temperature", 0.0}
                  }},
        {"level", QVariantMap{
                      {"value", 0}
                  }}
    };
}

void SensorModule::parseData(const QString& data) {
    QStringList bytes;
    for(int i = 0; i < data.length(); i += 2) {
        bytes.append(data.mid(i, 2));
    }

    if (bytes.size() < 28) return; // 总长度减去帧头帧尾后的长度

    int offset = 0;

    // 跳过PWM设置值
    offset += 4; // 跳过PWM_SET1和PWM_SET2 (各2字节)

    parseAirQuality(bytes, offset);
    parseWaterQuality(bytes, offset);
    parseWaterLevel(bytes, offset);

    emit sensorDataParsed(
        co2(), ch2o(), tvoc(), pm25(), pm10(),
        airTemperature(), humidity(),
        turbidity(), ph(), tds(), waterTemperature(),
        levelValue()
        );
    emit displayDataChanged();
}

void SensorModule::parseAirQuality(const QStringList& data, int& offset) {
    QVariantMap air = m_displayData["air"].toMap();
    bool ok;

    // CO2 (2字节，低位在前)
    int low = data[offset++].toInt(&ok, 16);
    int high = data[offset++].toInt(&ok, 16);
    air["co2"] = (high << 8) + low;

    // CH2O (2字节，低位在前)
    low = data[offset++].toInt(&ok, 16);
    high = data[offset++].toInt(&ok, 16);
    air["ch2o"] = (high << 8) + low;

    // TVOC (2字节，低位在前)
    low = data[offset++].toInt(&ok, 16);
    high = data[offset++].toInt(&ok, 16);
    air["tvoc"] = (high << 8) + low;

    // PM2.5 (2字节，低位在前)
    low = data[offset++].toInt(&ok, 16);
    high = data[offset++].toInt(&ok, 16);
    air["pm25"] = (high << 8) + low;

    // PM10 (2字节，低位在前)
    low = data[offset++].toInt(&ok, 16);
    high = data[offset++].toInt(&ok, 16);
    air["pm10"] = (high << 8) + low;

    // 空气温度 (2字节分开处理)
    int tempHigh = data[offset++].toInt(&ok, 16);
    int tempLow = data[offset++].toInt(&ok, 16);
    air["temperature"] = tempHigh + 0.01 * tempLow;

    // 空气湿度 (2字节分开处理)
    int humHigh = data[offset++].toInt(&ok, 16);
    int humLow = data[offset++].toInt(&ok, 16);
    air["humidity"] = humHigh + 0.01 * humLow;

    m_displayData["air"] = air;
}

void SensorModule::parseWaterQuality(const QStringList& data, int& offset) {
    QVariantMap water = m_displayData["water"].toMap();
    bool ok;

    // 浊度 (2字节，低位在前)
    int low = data[offset++].toInt(&ok, 16);
    int high = data[offset++].toInt(&ok, 16);
    water["turbidity"] = (high << 8) + low;

    // pH值 (2字节，低位在前)
    low = data[offset++].toInt(&ok, 16);
    high = data[offset++].toInt(&ok, 16);
    water["ph"] = ((high << 8) + low) / 100.0;

    // TDS (2字节，低位在前)
    low = data[offset++].toInt(&ok, 16);
    high = data[offset++].toInt(&ok, 16);
    water["tds"] = (high << 8) + low;

    // 水温 (2字节分开处理)
    int tempHigh = data[offset++].toInt(&ok, 16);
    int tempLow = data[offset++].toInt(&ok, 16);
    water["temperature"] = tempHigh + 0.01 * tempLow;

    m_displayData["water"] = water;
}

void SensorModule::parseWaterLevel(const QStringList& data, int& offset) {
    QVariantMap level = m_displayData["level"].toMap();
    bool ok;

    // 液位值 (2字节，低位在前)
    int low = data[offset++].toInt(&ok, 16);
    int high = data[offset++].toInt(&ok, 16);
    level["value"] = (high << 8) + low;

    m_displayData["level"] = level;
}
