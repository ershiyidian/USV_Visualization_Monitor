#pragma once
#include <QObject>
#include <QString>
#include <QVariantMap>

class VisualizationBase : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantMap displayData READ displayData NOTIFY displayDataChanged)

public:
    explicit VisualizationBase(QObject *parent = nullptr);
    virtual ~VisualizationBase() = default;

    QVariantMap displayData() const { return m_displayData; }

public slots:
    virtual void receiveData(const QString& data);
    virtual void updateData();

signals:
    void displayDataChanged();

protected:
    QVariantMap m_displayData;
    virtual void parseData(const QString& data) = 0;
};
