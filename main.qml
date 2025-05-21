// main.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1280
    height: 800
    title: "水面环境监测与导航系统"

    // 全局样式常量
    readonly property color primaryColor: "#2C3E50"      // 主色调
    readonly property color accentColor: "#3498DB"       // 强调色
    readonly property color dangerColor: "#E74C3C"       // 警告色
    readonly property color warningColor: "#F39C12"      // 注意色
    readonly property color successColor: "#2ECC71"      // 成功色
    readonly property color cardColor: "#34495E"         // 卡片背景色
    readonly property color darkColor: "#1E2A38"         // 深色背景
    readonly property color textColor: "#ECF0F1"         // 文本色
    readonly property color borderColor: "#7F8C8D"       // 边框色
    readonly property color chartGridColor: "#3E4D5C"    // 图表网格线色

    readonly property int fontSize: 13                   // 基础字号
    readonly property int smallFontSize: 11              // 小字号
    readonly property int largeFontSize: 15              // 大字号

    // 设置全局样式
    background: Rectangle {
        color: darkColor
    }

    // 顶部消息栏
    TopMessageBar {
        id: topMessageBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 40
    }

    // 主内容区域
    Item {
        id: contentArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: topMessageBar.bottom
        anchors.bottom: parent.bottom

        // 中心地图区
        MapViewPanel {
            id: mapViewPanel
            anchors.fill: parent
            anchors.leftMargin: taskPointSelector.visible ? taskPointSelector.width : 0
            anchors.rightMargin: serialControlPanel.visible ? serialControlPanel.width : 0
            anchors.bottomMargin: sensorDataPanel.visible ? sensorDataPanel.height : 0
            visible: true
        }

        // 左侧任务点选择器（左上角停靠）
        TaskPointSelector {
            id: taskPointSelector
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: sensorDataPanel.top
            width: 300
            visible: true
        }

        // 传感器数据面板（左下停靠）
        SensorDataPanel {
            id: sensorDataPanel
            anchors.left: parent.left
            anchors.right: boatStatusPanel.left
            anchors.bottom: parent.bottom
            height: parent.height * 0.35
            visible: true
        }

        // 船只状态面板（右下停靠）
        BoatStatusPanel {
            id: boatStatusPanel
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: serialControlPanel.bottom
            width: 300
            visible: true
        }

        // 串口控制面板（右上停靠）
        SerialControlPanel {
            id: serialControlPanel
            anchors.right: parent.right
            anchors.top: parent.top
            width: 300
            height: parent.height * 0.5
            visible: true
        }
    }

    // 对话框组件
    HistoryDataWindow {
        id: historyDataWindow
        // anchors.centerIn: parent
        visible: false
    }

    SettingsDialog {
        id: settingsDialog
        anchors.centerIn: parent
        visible: false
    }

    // 警告消息组件
    Rectangle {
        id: warningMessage
        width: warningText.width + 40
        height: 40
        radius: 6
        color: dangerColor
        opacity: 0
        visible: opacity > 0
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: topMessageBar.bottom
            topMargin: 20
        }

        property string message: ""
        property color messageColor: dangerColor

        function showWarning(text, color) {
            message = text;
            messageColor = color || dangerColor;
            warningAnimation.start();
        }

        Text {
            id: warningText
            anchors.centerIn: parent
            text: warningMessage.message
            color: textColor
            font.pixelSize: fontSize
            font.bold: true
        }

        SequentialAnimation {
            id: warningAnimation

            NumberAnimation {
                target: warningMessage
                property: "opacity"
                to: 1.0
                duration: 300
                easing.type: Easing.OutCubic
            }

            PauseAnimation { duration: 4000 }

            NumberAnimation {
                target: warningMessage
                property: "opacity"
                to: 0.0
                duration: 300
                easing.type: Easing.InCubic
            }
        }
    }

    // 旧的数据分发逻辑，已由C++后端DTO信号槽机制取代 (原Connections对象已移除)
    // Connections {
    //     target: dataSource
    //     function onMergedDataReceived(data) {
    //         // ... (旧逻辑)
    //     }
    // }
}
