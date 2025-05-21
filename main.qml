// main.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15
import "." // 导入包含Theme.qml的目录，使其可作为Theme单例访问

ApplicationWindow {
    id: appWindow
    visible: true
    width: 1280
    height: 800
    title: "水面环境监测与导航系统"

    // 旧的全局样式常量已移除，将使用Theme.qml中的属性

    // 设置全局样式
    background: Rectangle {
        color: Theme.darkThemeBackgroundColor // 使用Theme中的深色背景
    }

    // 顶部消息栏
    TopMessageBar {
        id: topMessageBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 40
        // TopMessageBar 内部也需要更新以使用 Theme 属性 (此部分将在其各自的文件中处理)
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
        radius: Theme.cardCornerRadius // 使用Theme中的圆角属性
        color: Theme.accentColor // 使用Theme中的危险/强调色
        opacity: 0
        visible: opacity > 0
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: topMessageBar.bottom
            topMargin: 20
        }

        property string message: ""
        property color messageColor: Theme.accentColor // 默认使用Theme中的危险/强调色

        function showWarning(text, color) {
            message = text;
            messageColor = color || Theme.accentColor; // 如果未提供颜色，则使用Theme的危险色
            warningAnimation.start();
        }

        Text {
            id: warningText
            anchors.centerIn: parent
            text: warningMessage.message
            color: Theme.textColorOnDark // 使用Theme中的深色背景文本颜色
            font.pixelSize: Theme.defaultFontSize // 使用Theme中的默认字号
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
