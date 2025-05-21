#ifndef DATABASE_H
#define DATABASE_H

#include <QObject>
#include <QtSql/QSqlDatabase>
#include <QString>

class Database : public QObject {
    Q_OBJECT
public:
    explicit Database(QObject *parent = nullptr);
    ~Database();

    bool initialize();
    bool insertSensorData(const QString& timestamp,
                          int co2, int ch2o, int tvoc, int pm25, int pm10,
                          double airTemp, double humidity,
                          int turbidity, double ph, int tds, double waterTemp,
                          int levelValue);
    bool insertVesselData(const QString& timestamp,
                          double latitude, double longitude, double speed, double heading);
    bool insertDeviceData(const QString& timestamp,
                          int battery,bool mode);
    bool insertTrajectoryData(const QString& timestamp,
                              double latitude, double longitude);

private:
    QSqlDatabase db;
};

#endif // DATABASE_H
