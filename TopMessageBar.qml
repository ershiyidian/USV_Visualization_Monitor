import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Rectangle {
    id: topMessageBar
    color: primaryColor

    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 2
        radius: 8.0
        samples: 17
        color: Qt.rgba(0, 0, 0, 0.5)
    }

    property string systemStatus: "系统运行正常"
    property bool isConnected: dataSource.isPortOpen
    property bool isSimulating: dataSource.isSimulating
    property bool pumpAutoMode: deviceModule ? deviceModule.pumpAutoMode : false
    property bool boatAutoMode: deviceModule ? deviceModule.boatAutoMode : false

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10

        // 系统标题
        Text {
            text: "水面环境监测与导航系统"
            color: textColor
            font.pixelSize: largeFontSize
            font.bold: true
        }

        // 分隔线
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: borderColor
            opacity: 0.5
        }

        // 连接状态
        RowLayout {
            spacing: 5

            Rectangle {
                id: connectionIndicator
                width: 10
                height: 10
                radius: 5
                Layout.alignment: Qt.AlignVCenter
                color: isConnected ? successColor : dangerColor

                // 闪烁动画
                SequentialAnimation {
                    running: isConnected
                    loops: Animation.Infinite

                    NumberAnimation {
                        target: connectionIndicator
                        property: "opacity"
                        from: 1.0
                        to: 0.5
                        duration: 1000
                    }

                    NumberAnimation {
                        target: connectionIndicator
                        property: "opacity"
                        from: 0.5
                        to: 1.0
                        duration: 1000
                    }
                }
            }

            Text {
                text: isConnected ? "已连接" : "未连接"
                color: textColor
                font.pixelSize: fontSize
                Layout.alignment: Qt.AlignVCenter
            }
        }
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: borderColor
            opacity: 0.5
        }

        // 水泵模式控制 ▼▼▼
        TopBarButton {
            text: pumpAutoMode ? "水泵[自动]" : "水泵[手动]"
            color: pumpAutoMode ? accentColor : Qt.rgba(0.5, 0.5, 0.5, 0.7)
            onClicked: {
                pumpAutoMode = !pumpAutoMode
                if (deviceModuleWithDataSource) deviceModuleWithDataSource.setPumpAutoMode(pumpAutoMode)
            }
        }

        // 新增分隔线 ▼▼▼
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: borderColor
            opacity: 0.5
        }

        // 艇模式控制 ▼▼▼
        TopBarButton {
            text: boatAutoMode ? "航行[自动]" : "航行[手动]"
            color: boatAutoMode ? accentColor : Qt.rgba(0.5, 0.5, 0.5, 0.7)
            onClicked: {
                boatAutoMode = !boatAutoMode
                if (deviceModuleWithDataSource) deviceModuleWithDataSource.setBoatAutoMode(boatAutoMode)
            }
        }

        // 分隔线
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: borderColor
            opacity: 0.5
        }

        // 电池状态
        RowLayout {
            spacing: 5

            // 电池图标
            Item {
                width: 20
                height: 12
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    anchors.fill: parent
                    anchors.rightMargin: 2
                    color: "transparent"
                    border.color: textColor
                    border.width: 1
                    radius: 2

                    // 电量填充
                    Rectangle {
                        property int batteryLevel: deviceModule ? deviceModule.battery : 0
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 2
                        width: Math.max(1, (parent.width - 4) * (batteryLevel / 100))
                        radius: 1

                        // 根据电量改变颜色
                        color: {
                            if (batteryLevel > 50) return successColor;
                            if (batteryLevel > 20) return warningColor;
                            return dangerColor;
                        }
                    }
                }

                // 电池正极
                Rectangle {
                    anchors.left: parent.right
                    anchors.leftMargin: -2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 2
                    height: 6
                    color: textColor
                    radius: 1
                }
            }

            // 电池百分比
            Text {
                text: (deviceModule ? deviceModule.battery : 0) + "%"
                color: {
                    var level = deviceModule ? deviceModule.battery : 0;
                    if (level > 50) return successColor;
                    if (level > 20) return warningColor;
                    return dangerColor;
                }
                font.pixelSize: fontSize
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // 分隔线
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: borderColor
            opacity: 0.5
        }

        // 运行模式
        RowLayout {
            spacing: 5

            Text {
                text: "模式:"
                color: textColor
                font.pixelSize: fontSize
                Layout.alignment: Qt.AlignVCenter
            }

            Rectangle {
                width: 50
                height: 22
                radius: 3
                color: deviceModule && deviceModule.mode ? accentColor : Qt.rgba(0.5, 0.5, 0.5, 0.7)

                Text {
                    anchors.centerIn: parent
                    text: deviceModule && deviceModule.mode ? "自动" : "手动"
                    font.pixelSize: smallFontSize
                    font.bold: true
                    color: "white"
                }
            }
        }

        // 分隔线
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: borderColor
            opacity: 0.5
            visible: isSimulating
        }

        // 模拟数据状态
        RowLayout {
            spacing: 5
            visible: isSimulating

            Rectangle {
                id: simulationIndicator
                width: 10
                height: 10
                radius: 5
                Layout.alignment: Qt.AlignVCenter
                color: warningColor

                // 闪烁动画
                SequentialAnimation {
                    running: true
                    loops: Animation.Infinite

                    NumberAnimation {
                        target: simulationIndicator
                        property: "opacity"
                        from: 1.0
                        to: 0.3
                        duration: 500
                    }

                    NumberAnimation {
                        target: simulationIndicator
                        property: "opacity"
                        from: 0.3
                        to: 1.0
                        duration: 500
                    }
                }
            }

            Text {
                text: "模拟数据中"
                color: warningColor
                font.pixelSize: fontSize
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // 分隔线
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: borderColor
            opacity: 0.5
        }

        // 传感器状态摘要
        RowLayout {
            spacing: 5

            Text {
                text: "CO₂:"
                color: textColor
                font.pixelSize: fontSize
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: sensorModule ? sensorModule.co2.toFixed(0) + " ppm" : "N/A"
                color: {
                    var value = sensorModule ? sensorModule.co2 : 0;
                    if (value >= 2000) return dangerColor;
                    if (value >= 1000) return warningColor;
                    return successColor;
                }
                font.pixelSize: fontSize
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // 分隔符
        Text {
            text: "|"
            color: borderColor
            font.pixelSize: fontSize
            Layout.alignment: Qt.AlignVCenter
        }

        // 水质状态摘要
        RowLayout {
            spacing: 5

            Text {
                text: "pH:"
                color: textColor
                font.pixelSize: fontSize
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: sensorModule ? sensorModule.ph.toFixed(1) : "N/A"
                color: {
                    var value = sensorModule ? sensorModule.ph : 0;
                    if (value >= 9.0) return dangerColor;
                    if (value >= 8.5) return warningColor;
                    return successColor;
                }
                font.pixelSize: fontSize
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // 分隔符
        Text {
            text: "|"
            color: borderColor
            font.pixelSize: fontSize
            Layout.alignment: Qt.AlignVCenter
        }

        // 位置信息
        RowLayout {
            spacing: 5

            Text {
                text: "位置:"
                color: textColor
                font.pixelSize: fontSize
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: vesselModule ?
                      vesselModule.latitude.toFixed(4) + "°, " +
                      vesselModule.longitude.toFixed(4) + "°" : "N/A"
                color: textColor
                font.pixelSize: fontSize
                font.family: "Consolas, monospace"
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // 分隔符
        Text {
            text: "|"
            color: borderColor
            font.pixelSize: fontSize
            Layout.alignment: Qt.AlignVCenter
        }

        // 速度信息
        RowLayout {
            spacing: 5

            Text {
                text: "速度:"
                color: textColor
                font.pixelSize: fontSize
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: vesselModule ? vesselModule.speed.toFixed(1) + " m/s" : "N/A"
                color: textColor
                font.pixelSize: fontSize
                font.family: "Consolas, monospace"
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // 状态信息
        Text {
            id: statusText
            Layout.fillWidth: true
            text: systemStatus
            color: textColor
            font.pixelSize: fontSize
            elide: Text.ElideRight
        }

        // 历史数据按钮
        TopBarButton {
            text: "历史数据"
            iconText: "📊"
            onClicked: {
                var component = Qt.createComponent("HistoryDataWindow.qml");
                if (component.status === Component.Ready) {
                    var window = component.createObject(appWindow);
                    window.show();
                } else {
                    console.error("Error loading component:", component.errorString());
                }
            }
        }

        // 设置按钮
        TopBarButton {
            text: "设置"
            iconText: "⚙"
            onClicked: settingsDialog.open()
        }
    }

    // 顶部栏按钮组件
    component TopBarButton: Rectangle {
        property string text: ""
        property string iconText: ""
        signal clicked()

        width: 100
        height: 30
        radius: 4
        color: mouseArea.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"

        RowLayout {
            anchors.centerIn: parent
            spacing: 5

            Text {
                text: parent.parent.iconText
                color: textColor
                font.pixelSize: fontSize
            }

            Text {
                text: parent.parent.text
                color: textColor
                font.pixelSize: fontSize
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: parent.clicked()
        }

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
}
