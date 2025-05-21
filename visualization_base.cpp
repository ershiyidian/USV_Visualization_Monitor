//visualization_base.cpp
#include "visualization_base.h"

VisualizationBase::VisualizationBase(QObject *parent)
    : QObject(parent) {}

void VisualizationBase::receiveData(const QString& data) {
    parseData(data);
    emit displayDataChanged();
}

void VisualizationBase::updateData() {
    // 基类中为空实现，子类根据需要重写
}
