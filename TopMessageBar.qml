import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "." // 导入Theme单例

Rectangle {
    id: topMessageBar
    // color: primaryColor // 旧颜色，使用Theme.darkThemeCardColor 或 Theme.primaryColor (根据设计)
    color: Theme.darkThemeCardColor // 使用深色主题卡片颜色作为背景

    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 2
        radius: 8.0
        samples: 17
        color: Theme.shadowColor // 使用Theme中的阴影颜色
    }

    property string systemStatus: "系统运行正常" // 系统状态文本
    property bool isConnected: dataSource.isPortOpen // 是否已连接串口
    property bool isSimulating: dataSource.isSimulating // 是否正在模拟数据
    property bool pumpAutoMode: deviceModule ? deviceModule.pumpAutoMode : false // 水泵自动模式状态
    property bool boatAutoMode: deviceModule ? deviceModule.boatAutoMode : false // 船只自动模式状态

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.paddingLarge // 使用Theme中的大内边距
        anchors.rightMargin: Theme.paddingLarge
        spacing: Theme.paddingMedium // 使用Theme中的中间距

        // 系统标题
        Text {
            text: "水面环境监测与导航系统"
            color: Theme.textColorOnDark // 使用Theme中的深色背景文本颜色
            font.pixelSize: Theme.largeFontSize // 使用Theme中的大字号
            font.bold: true
        }

        // 分隔线
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: Theme.borderColor // 使用Theme中的边框颜色
            opacity: 0.5
        }

        // 连接状态
        RowLayout {
            spacing: Theme.paddingSmall // 使用Theme中的小间距

            Rectangle {
                id: connectionIndicator
                width: 10
                height: 10
                radius: 5
                Layout.alignment: Qt.AlignVCenter
                // color: isConnected ? successColor : dangerColor // 旧颜色
                color: isConnected ? Theme.secondaryColor : Theme.accentColor // 使用Theme的成功色和强调色

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
                color: Theme.textColorOnDark // 使用Theme中的深色背景文本颜色
                font.pixelSize: Theme.defaultFontSize // 使用Theme中的默认字号
                Layout.alignment: Qt.AlignVCenter
            }
        }
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: Theme.borderColor // 使用Theme中的边框颜色
            opacity: 0.5
        }

        // 水泵模式控制
        TopBarButton {
            text: pumpAutoMode ? "水泵[自动]" : "水泵[手动]"
            // color: pumpAutoMode ? accentColor : Qt.rgba(0.5, 0.5, 0.5, 0.7) // 旧颜色
            // TopBarButton 内部将使用Theme来定义其颜色
            onClicked: {
                pumpAutoMode = !pumpAutoMode
                if (deviceModule) deviceModule.setPumpAutoMode(pumpAutoMode)
            }
        }

        // 新增分隔线
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: Theme.borderColor // 使用Theme中的边框颜色
            opacity: 0.5
        }

        // 艇模式控制
        TopBarButton {
            text: boatAutoMode ? "航行[自动]" : "航行[手动]"
            // color: boatAutoMode ? accentColor : Qt.rgba(0.5, 0.5, 0.5, 0.7) // 旧颜色
            onClicked: {
                boatAutoMode = !boatAutoMode
                if (deviceModule) deviceModule.setBoatAutoMode(boatAutoMode)
            }
        }

        // 分隔线
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: Theme.borderColor // 使用Theme中的边框颜色
            opacity: 0.5
        }

        // 电池状态
        RowLayout {
            spacing: Theme.paddingSmall // 使用Theme中的小间距

            // 电池图标
            Item {
                width: 20
                height: 12
                Layout.alignment: Qt.AlignVCenter

                Rectangle { // 电池外壳
                    anchors.fill: parent
                    anchors.rightMargin: 2
                    color: "transparent"
                    border.color: Theme.textColorOnDark // 使用Theme中的深色背景文本颜色
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
                            if (batteryLevel > 50) return Theme.secondaryColor; // 成功色
                            if (batteryLevel > 20) return Theme.warningColor;   // 警告色
                            return Theme.accentColor;    // 危险/强调色
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
                    color: Theme.textColorOnDark // 使用Theme中的深色背景文本颜色
                    radius: 1
                }
            }

            // 电池百分比
            Text {
                text: (deviceModule ? deviceModule.battery : 0) + "%"
                color: {
                    var level = deviceModule ? deviceModule.battery : 0;
                    if (level > 50) return Theme.secondaryColor;
                    if (level > 20) return Theme.warningColor;
                    return Theme.accentColor;
                }
                font.pixelSize: Theme.defaultFontSize // 使用Theme中的默认字号
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // 分隔线
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: Theme.borderColor // 使用Theme中的边框颜色
            opacity: 0.5
        }

        // 运行模式
        RowLayout {
            spacing: Theme.paddingSmall

            Text {
                text: "模式:"
                color: Theme.textColorOnDark
                font.pixelSize: Theme.defaultFontSize
                Layout.alignment: Qt.AlignVCenter
            }

            Rectangle { // 模式指示背景
                width: 50
                height: 22
                radius: Theme.buttonCornerRadius
                // color: deviceModule && deviceModule.mode ? accentColor : Qt.rgba(0.5, 0.5, 0.5, 0.7) // 旧颜色
                // deviceModule.mode 已改为 deviceModule.operationalMode (QString)
                color: deviceModule && deviceModule.operationalMode === "自动" ? Theme.primaryColor : Qt.rgba(Theme.borderColor.r, Theme.borderColor.g, Theme.borderColor.b, 0.7)


                Text {
                    anchors.centerIn: parent
                    text: deviceModule ? deviceModule.operationalMode : "未知" // 使用operationalMode
                    font.pixelSize: Theme.smallFontSize // 使用Theme中的小字号
                    font.bold: true
                    color: Theme.textColorOnLight // 假设背景色较深，文本用浅色；若背景浅，则用textColorOnLight
                }
            }
        }

        // 分隔线
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: Theme.borderColor
            opacity: 0.5
            visible: isSimulating
        }

        // 模拟数据状态
        RowLayout {
            spacing: Theme.paddingSmall
            visible: isSimulating

            Rectangle {
                id: simulationIndicator
                width: 10
                height: 10
                radius: 5
                Layout.alignment: Qt.AlignVCenter
                color: Theme.warningColor // 使用Theme中的警告色

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
                color: Theme.warningColor // 使用Theme中的警告色
                font.pixelSize: Theme.defaultFontSize // 使用Theme中的默认字号
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // 分隔线
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: Theme.borderColor // 使用Theme中的边框颜色
            opacity: 0.5
        }

        // 传感器状态摘要
        RowLayout {
            spacing: Theme.paddingSmall

            Text {
                text: "CO₂:"
                color: Theme.textColorOnDark
                font.pixelSize: Theme.defaultFontSize
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: sensorModule ? sensorModule.co2.toFixed(0) + " ppm" : "N/A"
                color: {
                    var value = sensorModule ? sensorModule.co2 : 0;
                    // 使用Theme中定义的阈值属性
                    if (value >= sensorModule.co2CriticalLimit) return Theme.accentColor;
                    if (value >= sensorModule.co2WarningLimit) return Theme.warningColor;
                    return Theme.secondaryColor;
                }
                font.pixelSize: Theme.defaultFontSize
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // 分隔符
        Text {
            text: "|"
            color: Theme.borderColor
            font.pixelSize: Theme.defaultFontSize
            Layout.alignment: Qt.AlignVCenter
        }

        // 水质状态摘要
        RowLayout {
            spacing: Theme.paddingSmall

            Text {
                text: "pH:"
                color: Theme.textColorOnDark
                font.pixelSize: Theme.defaultFontSize
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: sensorModule ? sensorModule.ph.toFixed(1) : "N/A"
                color: {
                    var value = sensorModule ? sensorModule.ph : 0;
                    // pH值通常有上下限，这里简化为只检查上限
                    if (value >= sensorModule.phCriticalLimit) return Theme.accentColor;
                    if (value >= sensorModule.phWarningLimit) return Theme.warningColor;
                    return Theme.secondaryColor;
                }
                font.pixelSize: Theme.defaultFontSize
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // 分隔符
        Text {
            text: "|"
            color: Theme.borderColor
            font.pixelSize: Theme.defaultFontSize
            Layout.alignment: Qt.AlignVCenter
        }

        // 位置信息
        RowLayout {
            spacing: Theme.paddingSmall

            Text {
                text: "位置:"
                color: Theme.textColorOnDark
                font.pixelSize: Theme.defaultFontSize
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: vesselModule ?
                      vesselModule.latitude.toFixed(4) + "°, " +
                      vesselModule.longitude.toFixed(4) + "°" : "N/A"
                color: Theme.textColorOnDark
                font.pixelSize: Theme.defaultFontSize
                font.family: "Consolas, monospace"
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // 分隔符
        Text {
            text: "|"
            color: Theme.borderColor
            font.pixelSize: Theme.defaultFontSize
            Layout.alignment: Qt.AlignVCenter
        }

        // 速度信息
        RowLayout {
            spacing: Theme.paddingSmall

            Text {
                text: "速度:"
                color: Theme.textColorOnDark
                font.pixelSize: Theme.defaultFontSize
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: vesselModule ? vesselModule.speed.toFixed(1) + " m/s" : "N/A"
                color: Theme.textColorOnDark
                font.pixelSize: Theme.defaultFontSize
                font.family: "Consolas, monospace"
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // 状态信息
        Text {
            id: statusText
            Layout.fillWidth: true
            text: systemStatus
            color: Theme.textColorOnDark
            font.pixelSize: Theme.defaultFontSize
            elide: Text.ElideRight
        }

        // 历史数据按钮
        TopBarButton {
            text: "历史数据"
            iconText: "📊"
            // TopBarButton 内部将使用Theme
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
            // TopBarButton 内部将使用Theme
            onClicked: settingsDialog.open()
        }
    }

    // 顶部栏按钮组件
    component TopBarButton: Rectangle {
        property string text: ""
        property string iconText: ""
        signal clicked()

        width: 100 // 可考虑使用 Theme.controlHeight * N 或动态宽度
        height: Theme.controlHeight // 使用Theme中的标准控件高度
        radius: Theme.buttonCornerRadius // 使用Theme中的按钮圆角
        color: mouseArea.containsMouse ? Qt.rgba(Theme.textColorOnDark.r, Theme.textColorOnDark.g, Theme.textColorOnDark.b, 0.1) : "transparent"

        RowLayout {
            anchors.centerIn: parent
            spacing: Theme.paddingSmall

            Text {
                text: parent.parent.iconText
                color: Theme.textColorOnDark
                font.pixelSize: Theme.defaultFontSize
            }

            Text {
                text: parent.parent.text
                color: Theme.textColorOnDark
                font.pixelSize: Theme.defaultFontSize
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
