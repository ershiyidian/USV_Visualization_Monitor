// main.cpp
#include "device_module.h"
#include "sensor_module.h"
#include "vessel_module.h"
#include "datasource.h"
#include "database.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include <QDateTime>
#include <QApplication>

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    QQmlApplicationEngine engine;


    // qmlRegisterType<SensorModule>("Modules", 1, 0, "SensorModule");
    // qmlRegisterType<VesselModule>("Modules", 1, 0, "VesselModule");
    // qmlRegisterType<DeviceModule>("Modules", 1, 0, "DeviceModule");
    // qmlRegisterType<DataSource>("Modules", 1, 0, "DataSource");
    // qmlRegisterType<Database>("Modules", 1, 0, "Database");

    // 模块实例
    SensorModule sensorModule;
    VesselModule vesselModule;
    DeviceModule deviceModule;
    //DataSource dataSource;
    Database database;
    DataSource* dataSource =new DataSource();
    DeviceModule* deviceModuleWithDataSource = new DeviceModule(dataSource);


    if (!database.initialize()) {
        qDebug() << "Failed to initialize database.";
        return -1;
    }

    // 信号槽连接，解析传感器和船舶数据
    QObject::connect(dataSource, &DataSource::sensorDataReceived, &sensorModule, &SensorModule::receiveData);
    QObject::connect(dataSource, &::DataSource::vesselDataReceived, &vesselModule, &VesselModule::receiveData);
    QObject::connect(dataSource, &DataSource::deviceDataReceived, &deviceModule, &DeviceModule::receiveData);


    // 连接数据解析后插入数据库
    QObject::connect(&sensorModule, &SensorModule::sensorDataParsed, [&](int co2, int ch2o, int tvoc, int pm25, int pm10,
                                                                         double airTemp, double humidity, int turbidity, double ph, int tds, double waterTemp, int levelValue){
        QString timestamp = QDateTime::currentDateTime().toString(Qt::ISODate);
        database.insertSensorData(timestamp, co2, ch2o, tvoc, pm25, pm10,
                                  airTemp, humidity, turbidity, ph, tds, waterTemp, levelValue);
    });

    QObject::connect(&vesselModule, &VesselModule::vesselDataParsed, [&](double latitude, double longitude, double speed, double heading){
        QString timestamp = QDateTime::currentDateTime().toString(Qt::ISODate);
        database.insertVesselData(timestamp, latitude, longitude, speed, heading);
    });
    QObject::connect(&deviceModule, &DeviceModule::deviceDataParsed, [&](int battery,bool mode){
        QString timestamp = QDateTime::currentDateTime().toString(Qt::ISODate);
        database.insertDeviceData(timestamp, battery,mode);
    });

    // 注册到 QML
    engine.rootContext()->setContextProperty("sensorModule", &sensorModule);
    engine.rootContext()->setContextProperty("vesselModule", &vesselModule);
    engine.rootContext()->setContextProperty("deviceModule", &deviceModule);
    engine.rootContext()->setContextProperty("dataSource", dataSource);
    engine.rootContext()->setContextProperty("database", &database);
    engine.rootContext()->setContextProperty("deviceModuleWithDataSource", deviceModuleWithDataSource);



    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            QCoreApplication::exit(-1);
        }
    }, Qt::QueuedConnection);
    engine.load(url);



    return app.exec();
}
