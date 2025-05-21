#include "database.h"
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>
#include <QDebug>

Database::Database(QObject *parent) : QObject(parent) {
}

Database::~Database() {
    if (db.isOpen()) {
        db.close();
    }
}

bool Database::initialize() {
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName("historical_data.db");

    if (!db.open()) {
        qDebug() << "Cannot open database:" << db.lastError().text();
        return false;
    }

    QSqlQuery query;
    // Create sensor_data table
    QString createSensorTable = R"(
        CREATE TABLE IF NOT EXISTS sensor_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT,
            co2 INTEGER,
            ch2o INTEGER,
            tvoc INTEGER,
            pm25 INTEGER,
            pm10 INTEGER,
            air_temperature REAL,
            humidity REAL,
            turbidity INTEGER,
            ph REAL,
            tds INTEGER,
            water_temperature REAL,
            level_value INTEGER
        )
    )";

    if (!query.exec(createSensorTable)) {
        qDebug() << "Failed to create sensor_data table:" << query.lastError().text();
        return false;
    }

    // Create vessel_data table
    QString createVesselTable = R"(
        CREATE TABLE IF NOT EXISTS vessel_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT,
            latitude REAL,
            longitude REAL,
            speed REAL,
            heading REAL
        )
    )";

    if (!query.exec(createVesselTable)) {
        qDebug() << "Failed to create vessel_data table:" << query.lastError().text();
        return false;
    }

    // Create trajectory_data table
    QString createTrajectoryTable = R"(
        CREATE TABLE IF NOT EXISTS trajectory_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT,
            latitude REAL,
            longitude REAL
        )
    )";

    if (!query.exec(createTrajectoryTable)) {
        qDebug() << "Failed to create trajectory_data table:" << query.lastError().text();
        return false;
    }

    QString createDeviceTable = R"(
        CREATE TABLE IF NOT EXISTS device_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT,
            battery INTEGER,
            mode BOOLEAN
        )
    )";

    if (!query.exec(createDeviceTable)) {
        qDebug() << "Failed to create device_data table:" << query.lastError().text();
        return false;
    }

    return true;
}

bool Database::insertSensorData(const QString& timestamp,
                                int co2, int ch2o, int tvoc, int pm25, int pm10,
                                double airTemp, double humidity,
                                int turbidity, double ph, int tds, double waterTemp,
                                int levelValue) {
    QSqlQuery query;
    query.prepare(R"(
        INSERT INTO sensor_data (
            timestamp, co2, ch2o, tvoc, pm25, pm10,
            air_temperature, humidity,
            turbidity, ph, tds, water_temperature,
            level_value
        ) VALUES (
            :timestamp, :co2, :ch2o, :tvoc, :pm25, :pm10,
            :air_temperature, :humidity,
            :turbidity, :ph, :tds, :water_temperature,
            :level_value
        )
    )");

    query.bindValue(":timestamp", timestamp);
    query.bindValue(":co2", co2);
    query.bindValue(":ch2o", ch2o);
    query.bindValue(":tvoc", tvoc);
    query.bindValue(":pm25", pm25);
    query.bindValue(":pm10", pm10);
    query.bindValue(":air_temperature", airTemp);
    query.bindValue(":humidity", humidity);
    query.bindValue(":turbidity", turbidity);
    query.bindValue(":ph", ph);
    query.bindValue(":tds", tds);
    query.bindValue(":water_temperature", waterTemp);
    query.bindValue(":level_value", levelValue);

    if (!query.exec()) {
        qDebug() << "Failed to insert sensor data:" << query.lastError().text();
        return false;
    }

    return true;
}

bool Database::insertVesselData(const QString& timestamp,
                                double latitude, double longitude, double speed, double heading) {
    QSqlQuery query;
    query.prepare(R"(
        INSERT INTO vessel_data (
            timestamp, latitude, longitude, speed, heading
        ) VALUES (
            :timestamp, :latitude, :longitude, :speed, :heading
        )
    )");

    query.bindValue(":timestamp", timestamp);
    query.bindValue(":latitude", latitude);
    query.bindValue(":longitude", longitude);
    query.bindValue(":speed", speed);
    query.bindValue(":heading", heading);

    if (!query.exec()) {
        qDebug() << "Failed to insert vessel data:" << query.lastError().text();
        return false;
    }

    // Also insert into trajectory_data
    return insertTrajectoryData(timestamp, latitude, longitude);
}
bool Database::insertDeviceData(const QString& timestamp,
                                int battery,bool mode) {
    QSqlQuery query;
    query.prepare(R"(
        INSERT INTO vessel_data (
            timestamp,battery,mode
        ) VALUES (
            :timestamp, :battery, :mode
        )
    )");

    query.bindValue(":timestamp", timestamp);
    query.bindValue(":battery", battery);
    query.bindValue(":mode", mode);

    if (!query.exec()) {
        qDebug() << "Failed to insert device data:" << query.lastError().text();
        return false;
    }
    return true;
}

bool Database::insertTrajectoryData(const QString& timestamp,
                                    double latitude, double longitude) {
    QSqlQuery query;
    query.prepare(R"(
        INSERT INTO trajectory_data (
            timestamp, latitude, longitude
        ) VALUES (
            :timestamp, :latitude, :longitude
        )
    )");

    query.bindValue(":timestamp", timestamp);
    query.bindValue(":latitude", latitude);
    query.bindValue(":longitude", longitude);

    if (!query.exec()) {
        qDebug() << "Failed to insert trajectory data:" << query.lastError().text();
        return false;
    }

    return true;
}
