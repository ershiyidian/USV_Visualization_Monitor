#ifndef VESSEL_MODULE_H
#define VESSEL_MODULE_H

#include "visualization_base.h"

class VesselModule : public VisualizationBase {
    Q_OBJECT
    Q_PROPERTY(double latitude READ latitude NOTIFY displayDataChanged)
    Q_PROPERTY(double longitude READ longitude NOTIFY displayDataChanged)
    Q_PROPERTY(double speed READ speed NOTIFY displayDataChanged)
    Q_PROPERTY(double heading READ heading NOTIFY displayDataChanged)

public:
    explicit VesselModule(QObject *parent = nullptr);

    // Getter methods
    double latitude() const { return m_displayData["latitude"].toDouble(); }
    double longitude() const { return m_displayData["longitude"].toDouble(); }
    double speed() const { return m_displayData["speed"].toDouble(); }
    double heading() const { return m_displayData["heading"].toDouble(); }


signals:
    void vesselDataParsed(double latitude, double longitude, double speed, double heading);

protected:
    void parseData(const QString& data) override;

public slots:
    void updateData() override;


};

#endif // VESSEL_MODULE_H
