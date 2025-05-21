// main.cpp
#include "device_module.h"
#include "sensor_module.h"
#include "vessel_module.h"
#include "datasource.h"
#include "database.h"
#include "DataTransferObjects.h" // 新增: 包含DTO头文件
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

    // --- 模块实例化 ---
    // 数据源 (通常作为指针，因为它可能被多个模块共享或传递，且生命周期由main管理)
    DataSource* dataSource = new DataSource();

    // UI模块 (通常作为栈对象，生命周期随main)
    SensorModule sensorModule;
    VesselModule vesselModule;
    DeviceModule deviceModule; // 标准DeviceModule实例
    Database database;

    // DeviceModule* deviceModuleWithDataSource = new DeviceModule(dataSource); // 此旧实例已移除

    // --- 初始化数据库 ---
    if (!database.initialize()) {
        qDebug() << "数据库初始化失败。"; // 更新为中文
        return -1;
    }

    // --- 信号槽连接 ---

    // DTO信号槽连接 (DataSource -> UI模块)
    QObject::connect(dataSource, &DataSource::vesselStateUpdated, &vesselModule, &VesselModule::handleVesselStateUpdated); // 船体状态更新
    QObject::connect(dataSource, &DataSource::sensorDataUpdated, &sensorModule, &SensorModule::handleSensorDataUpdated);   // 传感器数据更新
    QObject::connect(dataSource, &DataSource::deviceStatusUpdated, &deviceModule, &DeviceModule::handleDeviceStatusUpdated); // 新增: 设备状态更新

    // 新增: 设备控制请求的信号槽连接
    QObject::connect(&deviceModule, &DeviceModule::deviceControlRequested, dataSource, &DataSource::handleDeviceControl);
    // 新增: 任务指令请求的信号槽连接
    QObject::connect(&deviceModule, &DeviceModule::missionCommandRequested, dataSource, &DataSource::handleMissionCommand);


    // 连接数据更新后插入数据库的信号槽

    // 传感器数据日志记录 (已更新为DTO)
    QObject::connect(&sensorModule, &SensorModule::sensorDataReadyForLog, [&](const SensorDataDto& sensorDto){
        QString timestamp = QDateTime::currentDateTime().toString(Qt::ISODate);
        database.insertSensorData(timestamp, sensorDto.co2, static_cast<int>(sensorDto.ch2o * 1000),
                                  static_cast<int>(sensorDto.tvoc * 1000),
                                  sensorDto.pm25, sensorDto.pm10,
                                  sensorDto.airTemperature, sensorDto.airHumidity,
                                  static_cast<int>(sensorDto.waterTurbidity),
                                  sensorDto.ph,
                                  static_cast<int>(sensorDto.tds),
                                  sensorDto.waterTemperature,
                                  static_cast<int>(sensorDto.waterLevel * 1000));
    });

    // 船体数据日志记录 (已更新为DTO)
    QObject::connect(&vesselModule, &VesselModule::vesselStateReadyForLog, [&](const VesselStateDto& vesselDto){
        QString timestamp = QDateTime::currentDateTime().toString(Qt::ISODate);
        database.insertVesselData(timestamp, vesselDto.latitude, vesselDto.longitude, vesselDto.speed, vesselDto.heading);
    });

    // 更新设备数据日志记录，使用新的DTO信号
    QObject::connect(&deviceModule, &DeviceModule::deviceStatusReadyForLog, [&](const DeviceStatusDto& deviceDto){
        QString timestamp = QDateTime::currentDateTime().toString(Qt::ISODate); // 获取当前时间戳
        // 将DeviceStatusDto中的operationalMode (QString) 转换为bool以匹配insertDeviceData的旧接口
        bool modeForDb = (deviceDto.operationalMode == "自动"); // 假设 "自动" 映射为 true, "手动" 为 false
        database.insertDeviceData(timestamp, deviceDto.batteryLevel, modeForDb); // 使用DTO数据插入数据库
    });

    // 注册C++模块到QML上下文，使其可以在QML中被访问
    engine.rootContext()->setContextProperty("sensorModule", &sensorModule); // 传感器模块
    engine.rootContext()->setContextProperty("vesselModule", &vesselModule); // 船体模块
    engine.rootContext()->setContextProperty("deviceModule", &deviceModule); // 设备模块 (统一使用此实例)
    engine.rootContext()->setContextProperty("dataSource", dataSource);     // 数据源
    engine.rootContext()->setContextProperty("database", &database);         // 数据库访问对象
    // engine.rootContext()->setContextProperty("deviceModuleWithDataSource", deviceModuleWithDataSource); // 移除对旧实例的注册

    // --- 加载QML ---
    const QUrl url(QStringLiteral("qrc:/main.qml")); // QML主文件路径
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) { // 如果QML对象创建失败且URL匹配，则退出应用
            QCoreApplication::exit(-1); // 退出程序
        }
    }, Qt::QueuedConnection);
    engine.load(url); // 加载QML界面



    return app.exec();
}
