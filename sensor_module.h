#pragma once
#include "visualization_base.h"

class SensorModule : public VisualizationBase {
    Q_OBJECT
    Q_PROPERTY(int co2 READ co2 NOTIFY displayDataChanged)
    Q_PROPERTY(int ch2o READ ch2o NOTIFY displayDataChanged)
    Q_PROPERTY(int tvoc READ tvoc NOTIFY displayDataChanged)
    Q_PROPERTY(int pm25 READ pm25 NOTIFY displayDataChanged)
    Q_PROPERTY(int pm10 READ pm10 NOTIFY displayDataChanged)
    Q_PROPERTY(double airTemperature READ airTemperature NOTIFY displayDataChanged)
    Q_PROPERTY(double humidity READ humidity NOTIFY displayDataChanged)
    Q_PROPERTY(int turbidity READ turbidity NOTIFY displayDataChanged)
    Q_PROPERTY(double ph READ ph NOTIFY displayDataChanged)
    Q_PROPERTY(int tds READ tds NOTIFY displayDataChanged)
    Q_PROPERTY(double waterTemperature READ waterTemperature NOTIFY displayDataChanged)
    Q_PROPERTY(int levelValue READ levelValue NOTIFY displayDataChanged)

public:
    explicit SensorModule(QObject *parent = nullptr);

    // Getter methods
    int co2() const { return m_displayData["air"].toMap()["co2"].toInt(); }
    int ch2o() const { return m_displayData["air"].toMap()["ch2o"].toInt(); }
    int tvoc() const { return m_displayData["air"].toMap()["tvoc"].toInt(); }
    int pm25() const { return m_displayData["air"].toMap()["pm25"].toInt(); }
    int pm10() const { return m_displayData["air"].toMap()["pm10"].toInt(); }
    double airTemperature() const { return m_displayData["air"].toMap()["temperature"].toDouble(); }
    double humidity() const { return m_displayData["air"].toMap()["humidity"].toDouble(); }
    int turbidity() const { return m_displayData["water"].toMap()["turbidity"].toInt(); }
    double ph() const { return m_displayData["water"].toMap()["ph"].toDouble(); }
    int tds() const { return m_displayData["water"].toMap()["tds"].toInt(); }
    double waterTemperature() const { return m_displayData["water"].toMap()["temperature"].toDouble(); }
    int levelValue() const { return m_displayData["level"].toMap()["value"].toInt(); }

signals:
    void sensorDataParsed(int co2, int ch2o, int tvoc, int pm25, int pm10,
                          double airTemp, double humidity,
                          int turbidity, double ph, int tds, double waterTemp,
                          int levelValue);

protected:
    void parseData(const QString& data) override;

private:
    void parseAirQuality(const QStringList& data, int& offset);
    void parseWaterQuality(const QStringList& data, int& offset);
    void parseWaterLevel(const QStringList& data, int& offset);
    bool validateFrame(const QStringList& data);

};
