#include "device_module.h"
#include<datasource.h>
#include <QDebug>
#include <QtMath>

DeviceModule::DeviceModule(QObject *parent)
    : VisualizationBase(parent),m_dataSource(nullptr)
    {
    m_displayData = {
        {"battery", 0},
        {"mode", 0},
    };
    m_pumpAutoMode=false;
}

DeviceModule::DeviceModule(DataSource* dataSource,QObject *parent)
    : VisualizationBase(parent),m_dataSource(dataSource)
    {
    m_displayData = {
        {"battery", 0},
        {"mode", 0},
    };
    m_pumpAutoMode=false;
}

void DeviceModule::parseData(const QString& data) {
    if (data.length() < 3) {
        return;
    }

    QStringList bytes;
    for(int i = 0; i < data.length(); i += 2) {
        bytes.append(data.mid(i, 2));
    }

    if (bytes.size() < 2) { // 检查数据字节数
        return;
    }

    int offset = 0;
    bool ok;

    // Battery (2 bytes) - integer value
    int battery_raw = (bytes[offset].toInt(&ok, 16) << 8) | bytes[offset + 1].toInt(&ok, 16);
    int battery = battery_raw; // 直接将两个字节合并为一个整数
    offset += 2;

    // Mode (1 byte) - 0 or 1
    bool mode = bytes[offset].toInt(&ok, 16) == 1;

    // Update internal data structure
    m_displayData["battery"] = battery;
    m_displayData["mode"] = mode;

    // Emit signals (maintaining the same interface)
    emit deviceDataParsed(battery,mode);
    emit displayDataChanged();
}

void DeviceModule::updateData() {
    // Simulation data update is handled in DataSource
}

bool DeviceModule::pumpAutoMode()const{
    return m_pumpAutoMode;
}

void DeviceModule::setPumpAutoMode(bool mode){
    if(m_pumpAutoMode!=mode){
        m_pumpAutoMode=mode;
        emit pumpAutoModeChanged(mode);
        if(m_dataSource){
            m_dataSource->updatePumpModeInDataSource(mode);}
    }
}
bool DeviceModule::boatAutoMode()const{
    return m_boatAutoMode;
}

void DeviceModule::setBoatAutoMode(bool mode){
    if(m_boatAutoMode!=mode){
        m_boatAutoMode=mode;
        emit boatAutoModeChanged(mode);
        if(m_dataSource){
            m_dataSource->updateBoatModeInDataSource(mode);}
    }
}
