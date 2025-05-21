#ifndef DEVICE_MODULE_H
#define DEVICE_MODULE_H
#include "visualization_base.h"
#include"datasource.h"
class DeviceModule: public VisualizationBase {
    Q_OBJECT
    Q_PROPERTY(int battery READ battery NOTIFY displayDataChanged)
    Q_PROPERTY(bool mode READ mode NOTIFY displayDataChanged)
    Q_PROPERTY(bool pumpAutoMode READ pumpAutoMode WRITE setPumpAutoMode NOTIFY pumpAutoModeChanged)
     Q_PROPERTY(bool boatAutoMode READ boatAutoMode WRITE setBoatAutoMode NOTIFY boatAutoModeChanged)
public:
    explicit DeviceModule(DataSource* dataSource,QObject *parent = nullptr);
    explicit DeviceModule(QObject *parent = nullptr);
    // Getter methods
    int battery() const { return m_displayData["battery"].toInt(); }
    bool mode() const { return m_displayData["mode"].toBool(); }
    bool pumpAutoMode()const;
     bool boatAutoMode()const;
signals:
    void deviceDataParsed(int battery,bool mode);
    void pumpAutoModeChanged(bool mode);
    void boatAutoModeChanged(bool mode);
protected:
    void parseData(const QString& data) override;
    bool m_pumpAutoMode;
    bool m_boatAutoMode;
    DataSource* m_dataSource=nullptr;

public slots:
    void updateData() override;
    void setPumpAutoMode(bool mode);
    void setBoatAutoMode(bool mode);
};

#endif // VESSEL_MODULE_H

