// SettingsDialog.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Dialog {
    id: settingsDialog
    title: "系统设置"
    width: 600
    height: 500
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // 自定义标题栏和内容
    background: Rectangle {
        color: darkColor
        radius: 8

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 2
            radius: 8.0
            samples: 17
            color: Qt.rgba(0, 0, 0, 0.5)
        }
    }

    header: Rectangle {
        color: primaryColor
        height: 40
        radius: 8

        // 只有顶部圆角
        Rectangle {
            color: primaryColor
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height / 2
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            anchors.rightMargin: 15

            Text {
                text: settingsDialog.title
                color: textColor
                font.pixelSize: largeFontSize
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "×"
                flat: true
                onClicked: settingsDialog.close()

                contentItem: Text {
                    text: parent.text
                    color: textColor
                    font.pixelSize: largeFontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.hovered ? Qt.rgba(1,1,1,0.1) : "transparent"
                    radius: 4
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        TabBar {
            id: settingsTabBar
            Layout.fillWidth: true

            TabButton {
                text: "常规设置"
                width: implicitWidth

                contentItem: Text {
                    text: parent.text
                    color: parent.checked ? accentColor : textColor
                    font.pixelSize: fontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 2
                        color: parent.parent.checked ? accentColor : "transparent"
                    }
                }
            }

            TabButton {
                text: "通信设置"
                width: implicitWidth

                contentItem: Text {
                    text: parent.text
                    color: parent.checked ? accentColor : textColor
                    font.pixelSize: fontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 2
                        color: parent.parent.checked ? accentColor : "transparent"
                    }
                }
            }

            TabButton {
                text: "地图设置"
                width: implicitWidth

                contentItem: Text {
                    text: parent.text
                    color: parent.checked ? accentColor : textColor
                    font.pixelSize: fontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 2
                        color: parent.parent.checked ? accentColor : "transparent"
                    }
                }
            }

            TabButton {
                text: "报警设置"
                width: implicitWidth

                contentItem: Text {
                    text: parent.text
                    color: parent.checked ? accentColor : textColor
                    font.pixelSize: fontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 2
                        color: parent.parent.checked ? accentColor : "transparent"
                    }
                }
            }
        }

        // 选项卡内容
        StackLayout {
            currentIndex: settingsTabBar.currentIndex
            Layout.fillWidth: true
            Layout.fillHeight: true

            // 常规设置面板
            Rectangle {
                color: cardColor
                radius: 8

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 15
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 15

                        GroupBox {
                            title: "界面设置"
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: Qt.rgba(1,1,1,0.05)
                                radius: 4
                                border.color: borderColor
                                border.width: 1
                                y: parent.label.height / 2
                            }

                            label: Label {
                                text: parent.title
                                color: textColor
                                font.pixelSize: fontSize
                                font.bold: true
                                background: Rectangle {
                                    color: cardColor
                                    x: -4
                                    width: parent.width + 8
                                }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 10

                                CheckBox {
                                    text: "启动时自动显示所有面板"
                                    checked: true

                                    indicator: Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 4
                                        border.color: parent.checked ? accentColor : borderColor
                                        border.width: 1
                                        color: "transparent"

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 12
                                            height: 12
                                            radius: 2
                                            color: accentColor
                                            visible: parent.parent.checked
                                        }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: textColor
                                        font.pixelSize: fontSize
                                        leftPadding: parent.indicator.width + 8
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                CheckBox {
                                    text: "启用地图自动跟随船只"
                                    checked: true

                                    indicator: Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 4
                                        border.color: parent.checked ? accentColor : borderColor
                                        border.width: 1
                                        color: "transparent"

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 12
                                            height: 12
                                            radius: 2
                                            color: accentColor
                                            visible: parent.parent.checked
                                        }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: textColor
                                        font.pixelSize: fontSize
                                        leftPadding: parent.indicator.width + 8
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                CheckBox {
                                    text: "启用图表自动缩放"
                                    checked: true

                                    indicator: Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 4
                                        border.color: parent.checked ? accentColor : borderColor
                                        border.width: 1
                                        color: "transparent"

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 12
                                            height: 12
                                            radius: 2
                                            color: accentColor
                                            visible: parent.parent.checked
                                        }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: textColor
                                        font.pixelSize: fontSize
                                        leftPadding: parent.indicator.width + 8
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }

                        GroupBox {
                            title: "数据设置"
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: Qt.rgba(1,1,1,0.05)
                                radius: 4
                                border.color: borderColor
                                border.width: 1
                                y: parent.label.height / 2
                            }

                            label: Label {
                                text: parent.title
                                color: textColor
                                font.pixelSize: fontSize
                                font.bold: true
                                background: Rectangle {
                                    color: cardColor
                                    x: -4
                                    width: parent.width + 8
                                }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 10

                                GridLayout {
                                    columns: 2
                                    columnSpacing: 15
                                    rowSpacing: 10
                                    Layout.fillWidth: true

                                    Text {
                                        text: "数据保存间隔:"
                                        color: textColor
                                        font.pixelSize: fontSize
                                    }

                                    ComboBox {
                                        Layout.fillWidth: true
                                        model: ["1秒", "5秒", "10秒", "30秒", "1分钟"]
                                        currentIndex: 2

                                        contentItem: Text {
                                            text: parent.displayText
                                            color: textColor
                                            font.pixelSize: fontSize
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignLeft
                                            leftPadding: 8
                                        }

                                        background: Rectangle {
                                            color: Qt.rgba(1,1,1,0.1)
                                            radius: 4
                                            border.color: borderColor
                                            border.width: 1
                                        }
                                    }

                                    Text {
                                        text: "历史数据保留天数:"
                                        color: textColor
                                        font.pixelSize: fontSize
                                    }

                                    SpinBox {
                                        Layout.fillWidth: true
                                        from: 7
                                        to: 365
                                        value: 30
                                        stepSize: 1
                                        editable: true

                                        contentItem: TextInput {
                                            text: parent.textFromValue(parent.value, parent.locale)
                                            color: textColor
                                            font.pixelSize: fontSize
                                            horizontalAlignment: Qt.AlignHCenter
                                            verticalAlignment: Qt.AlignVCenter
                                            readOnly: !parent.editable
                                            validator: parent.validator
                                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                                            selectByMouse: true
                                        }

                                        background: Rectangle {
                                            color: Qt.rgba(1,1,1,0.1)
                                            radius: 4
                                            border.color: borderColor
                                            border.width: 1
                                        }

                                        up.indicator: Rectangle {
                                            x: parent.width - width
                                            height: parent.height / 2
                                            width: 20
                                            color: parent.up.pressed ? Qt.darker(accentColor, 1.2) : "transparent"

                                            Text {
                                                text: "+"
                                                color: textColor
                                                font.pixelSize: fontSize
                                                anchors.centerIn: parent
                                            }
                                        }

                                        down.indicator: Rectangle {
                                            x: parent.width - width
                                            y: parent.height / 2
                                            height: parent.height / 2
                                            width: 20
                                            color: parent.down.pressed ? Qt.darker(accentColor, 1.2) : "transparent"

                                            Text {
                                                text: "−"
                                                color: textColor
                                                font.pixelSize: fontSize
                                                anchors.centerIn: parent
                                            }
                                        }
                                    }
                                }

                                Button {
                                    text: "清空所有历史数据"
                                    Layout.alignment: Qt.AlignRight

                                    contentItem: Text {
                                        text: parent.text
                                        color: textColor
                                        font.pixelSize: fontSize
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    background: Rectangle {
                                        color: parent.down ? Qt.darker(dangerColor, 1.2) :
                                               parent.hovered ? dangerColor : Qt.lighter(dangerColor, 1.1)
                                        radius: 4
                                    }

                                    onClicked: {
                                        // 清空历史数据操作
                                        warningMessage.showWarning("历史数据已清空", warningColor);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 通信设置面板
            Rectangle {
                color: cardColor
                radius: 8

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 15
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 15

                        GroupBox {
                            title: "自动重连设置"
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: Qt.rgba(1,1,1,0.05)
                                radius: 4
                                border.color: borderColor
                                border.width: 1
                                y: parent.label.height / 2
                            }

                            label: Label {
                                text: parent.title
                                color: textColor
                                font.pixelSize: fontSize
                                font.bold: true
                                background: Rectangle {
                                    color: cardColor
                                    x: -4
                                    width: parent.width + 8
                                }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 10

                                CheckBox {
                                    id: autoReconnectCheck
                                    text: "断开连接后自动重连"
                                    checked: false

                                    indicator: Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 4
                                        border.color: parent.checked ? accentColor : borderColor
                                        border.width: 1
                                        color: "transparent"

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 12
                                            height: 12
                                            radius: 2
                                            color: accentColor
                                            visible: parent.parent.checked
                                        }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: textColor
                                        font.pixelSize: fontSize
                                        leftPadding: parent.indicator.width + 8
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                RowLayout {
                                    spacing: 10
                                    enabled: autoReconnectCheck.checked
                                    opacity: enabled ? 1.0 : 0.5

                                    Text {
                                        text: "重连间隔:"
                                        color: textColor
                                        font.pixelSize: fontSize
                                    }

                                    SpinBox {
                                        from: 1
                                        to: 60
                                        value: 5
                                        stepSize: 1
                                        editable: true

                                        contentItem: TextInput {
                                            text: parent.textFromValue(parent.value, parent.locale)
                                            color: textColor
                                            font.pixelSize: fontSize
                                            horizontalAlignment: Qt.AlignHCenter
                                            verticalAlignment: Qt.AlignVCenter
                                            readOnly: !parent.editable
                                            validator: parent.validator
                                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                                            selectByMouse: true
                                        }

                                        background: Rectangle {
                                            color: Qt.rgba(1,1,1,0.1)
                                            radius: 4
                                            border.color: borderColor
                                            border.width: 1
                                        }
                                    }

                                    Text {
                                        text: "秒"
                                        color: textColor
                                        font.pixelSize: fontSize
                                    }

                                    Item { Layout.fillWidth: true }
                                }

                                CheckBox {
                                    text: "启动时自动连接上次使用的串口"
                                    checked: true

                                    indicator: Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 4
                                        border.color: parent.checked ? accentColor : borderColor
                                        border.width: 1
                                        color: "transparent"

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 12
                                            height: 12
                                            radius: 2
                                            color: accentColor
                                            visible: parent.parent.checked
                                        }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: textColor
                                        font.pixelSize: fontSize
                                        leftPadding: parent.indicator.width + 8
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }

                        GroupBox {
                            title: "数据缓冲设置"
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: Qt.rgba(1,1,1,0.05)
                                radius: 4
                                border.color: borderColor
                                border.width: 1
                                y: parent.label.height / 2
                            }

                            label: Label {
                                text: parent.title
                                color: textColor
                                font.pixelSize: fontSize
                                font.bold: true
                                background: Rectangle {
                                    color: cardColor
                                    x: -4
                                    width: parent.width + 8
                                }
                            }

                            GridLayout {
                                anchors.fill: parent
                                columns: 2
                                columnSpacing: 15
                                rowSpacing: 10

                                Text {
                                    text: "最大接收缓冲区(KB):"
                                    color: textColor
                                    font.pixelSize: fontSize
                                }

                                SpinBox {
                                    Layout.fillWidth: true
                                    from: 1
                                    to: 10240
                                    value: 1024
                                    stepSize: 1
                                    editable: true

                                    contentItem: TextInput {
                                        text: parent.textFromValue(parent.value, parent.locale)
                                        color: textColor
                                        font.pixelSize: fontSize
                                        horizontalAlignment: Qt.AlignHCenter
                                        verticalAlignment: Qt.AlignVCenter
                                        readOnly: !parent.editable
                                        validator: parent.validator
                                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                                        selectByMouse: true
                                    }

                                    background: Rectangle {
                                        color: Qt.rgba(1,1,1,0.1)
                                        radius: 4
                                        border.color: borderColor
                                        border.width: 1
                                    }
                                }

                                Text {
                                    text: "串口超时(毫秒):"
                                    color: textColor
                                    font.pixelSize: fontSize
                                }

                                SpinBox {
                                    Layout.fillWidth: true
                                    from: 100
                                    to: 10000
                                    value: 1000
                                    stepSize: 100
                                    editable: true

                                    contentItem: TextInput {
                                        text: parent.textFromValue(parent.value, parent.locale)
                                        color: textColor
                                        font.pixelSize: fontSize
                                        horizontalAlignment: Qt.AlignHCenter
                                        verticalAlignment: Qt.AlignVCenter
                                        readOnly: !parent.editable
                                        validator: parent.validator
                                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                                        selectByMouse: true
                                    }

                                    background: Rectangle {
                                        color: Qt.rgba(1,1,1,0.1)
                                        radius: 4
                                        border.color: borderColor
                                        border.width: 1
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 地图设置面板
            Rectangle {
                color: cardColor
                radius: 8

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 15
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 15

                        GroupBox {
                            title: "显示设置"
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: Qt.rgba(1,1,1,0.05)
                                radius: 4
                                border.color: borderColor
                                border.width: 1
                                y: parent.label.height / 2
                            }

                            label: Label {
                                text: parent.title
                                color: textColor
                                font.pixelSize: fontSize
                                font.bold: true
                                background: Rectangle {
                                    color: cardColor
                                    x: -4
                                    width: parent.width + 8
                                }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 10

                                CheckBox {
                                    text: "显示轨迹线"
                                    checked: true

                                    indicator: Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 4
                                        border.color: parent.checked ? accentColor : borderColor
                                        border.width: 1
                                        color: "transparent"

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 12
                                            height: 12
                                            radius: 2
                                            color: accentColor
                                            visible: parent.parent.checked
                                        }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: textColor
                                        font.pixelSize: fontSize
                                        leftPadding: parent.indicator.width + 8
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                CheckBox {
                                    text: "显示任务点连线"
                                    checked: true

                                    indicator: Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 4
                                        border.color: parent.checked ? accentColor : borderColor
                                        border.width: 1
                                        color: "transparent"

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 12
                                            height: 12
                                            radius: 2
                                            color: accentColor
                                            visible: parent.parent.checked
                                        }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: textColor
                                        font.pixelSize: fontSize
                                        leftPadding: parent.indicator.width + 8
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                RowLayout {
                                    spacing: 10

                                    Text {
                                        text: "轨迹点最大数量:"
                                        color: textColor
                                        font.pixelSize: fontSize
                                    }

                                    SpinBox {
                                        from: 100
                                        to: 10000
                                        value: 1000
                                        stepSize: 100
                                        editable: true

                                        contentItem: TextInput {
                                            text: parent.textFromValue(parent.value, parent.locale)
                                            color: textColor
                                            font.pixelSize: fontSize
                                            horizontalAlignment: Qt.AlignHCenter
                                            verticalAlignment: Qt.AlignVCenter
                                            readOnly: !parent.editable
                                            validator: parent.validator
                                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                                            selectByMouse: true
                                        }

                                        background: Rectangle {
                                            color: Qt.rgba(1,1,1,0.1)
                                            radius: 4
                                            border.color: borderColor
                                            border.width: 1
                                        }
                                    }

                                    Item { Layout.fillWidth: true }
                                }

                                Button {
                                    text: "清空当前轨迹"
                                    Layout.alignment: Qt.AlignRight

                                    contentItem: Text {
                                        text: parent.text
                                        color: textColor
                                        font.pixelSize: fontSize
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    background: Rectangle {
                                        color: parent.down ? Qt.darker(accentColor, 1.2) :
                                               parent.hovered ? accentColor : Qt.darker(accentColor, 1.1)
                                        radius: 4
                                    }
                                }
                            }
                        }

                        GroupBox {
                            title: "地图源设置"
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: Qt.rgba(1,1,1,0.05)
                                radius: 4
                                border.color: borderColor
                                border.width: 1
                                y: parent.label.height / 2
                            }

                            label: Label {
                                text: parent.title
                                color: textColor
                                font.pixelSize: fontSize
                                font.bold: true
                                background: Rectangle {
                                    color: cardColor
                                    x: -4
                                    width: parent.width + 8
                                }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 10

                                RowLayout {
                                    spacing: 10
                                    Layout.fillWidth: true

                                    Text {
                                        text: "地图提供商:"
                                        color: textColor
                                        font.pixelSize: fontSize
                                    }

                                    ComboBox {
                                        Layout.fillWidth: true
                                        model: ["OpenStreetMap", "Google Maps", "Bing Maps", "Mapbox"]
                                        currentIndex: 0

                                        contentItem: Text {
                                            text: parent.displayText
                                            color: textColor
                                            font.pixelSize: fontSize
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignLeft
                                            leftPadding: 8
                                        }

                                        background: Rectangle {
                                            color: Qt.rgba(1,1,1,0.1)
                                            radius: 4
                                            border.color: borderColor
                                            border.width: 1
                                        }
                                    }
                                }

                                CheckBox {
                                    text: "启用离线地图"
                                    checked: false

                                    indicator: Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 4
                                        border.color: parent.checked ? accentColor : borderColor
                                        border.width: 1
                                        color: "transparent"

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 12
                                            height: 12
                                            radius: 2
                                            color: accentColor
                                            visible: parent.parent.checked
                                        }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: textColor
                                        font.pixelSize: fontSize
                                        leftPadding: parent.indicator.width + 8
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Button {
                                    text: "下载离线地图数据"
                                    Layout.alignment: Qt.AlignRight

                                    contentItem: Text {
                                        text: parent.text
                                        color: textColor
                                        font.pixelSize: fontSize
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    background: Rectangle {
                                        color: parent.down ? Qt.darker(accentColor, 1.2) :
                                               parent.hovered ? accentColor : Qt.darker(accentColor, 1.1)
                                        radius: 4
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 报警设置面板
            Rectangle {
                color: cardColor
                radius: 8

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 15
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 15

                        GroupBox {
                            title: "报警提示设置"
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: Qt.rgba(1,1,1,0.05)
                                radius: 4
                                border.color: borderColor
                                border.width: 1
                                y: parent.label.height / 2
                            }

                            label: Label {
                                text: parent.title
                                color: textColor
                                font.pixelSize: fontSize
                                font.bold: true
                                background: Rectangle {
                                    color: cardColor
                                    x: -4
                                    width: parent.width + 8
                                }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 10

                                CheckBox {
                                    text: "启用视觉报警提示"
                                    checked: true

                                    indicator: Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 4
                                        border.color: parent.checked ? accentColor : borderColor
                                        border.width: 1
                                        color: "transparent"

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 12
                                            height: 12
                                            radius: 2
                                            color: accentColor
                                            visible: parent.parent.checked
                                        }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: textColor
                                        font.pixelSize: fontSize
                                        leftPadding: parent.indicator.width + 8
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                CheckBox {
                                    text: "启用声音报警"
                                    checked: false

                                    indicator: Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 4
                                        border.color: parent.checked ? accentColor : borderColor
                                        border.width: 1
                                        color: "transparent"

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 12
                                            height: 12
                                            radius: 2
                                            color: accentColor
                                            visible: parent.parent.checked
                                        }
                                    }

                                    contentItem: Text {
                                        text: parent.text
                                        color: textColor
                                        font.pixelSize: fontSize
                                        leftPadding: parent.indicator.width + 8
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }

                        GroupBox {
                            title: "传感器报警阈值设置"
                            Layout.fillWidth: true

                            background: Rectangle {
                                color: Qt.rgba(1,1,1,0.05)
                                radius: 4
                                border.color: borderColor
                                border.width: 1
                                y: parent.label.height / 2
                            }

                            label: Label {
                                text: parent.title
                                color: textColor
                                font.pixelSize: fontSize
                                font.bold: true
                                background: Rectangle {
                                    color: cardColor
                                    x: -4
                                    width: parent.width + 8
                                }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 10

                                // CO2设置
                                ThresholdSetting {
                                    name: "CO₂浓度(ppm)"
                                    warningValue: 1000
                                    criticalValue: 2000
                                    unit: "ppm"
                                    min: 0
                                    max: 5000
                                }

                                // 甲醛设置
                                ThresholdSetting {
                                    name: "甲醛浓度(mg/m³)"
                                    warningValue: 0.08
                                    criticalValue: 0.1
                                    unit: "mg/m³"
                                    min: 0
                                    max: 1
                                    decimals: 2
                                }

                                // TVOC设置
                                ThresholdSetting {
                                    name: "TVOC(ppb)"
                                    warningValue: 500
                                    criticalValue: 800
                                    unit: "ppb"
                                    min: 0
                                    max: 2000
                                }

                                // PM2.5设置
                                ThresholdSetting {
                                    name: "PM2.5(μg/m³)"
                                    warningValue: 75
                                    criticalValue: 150
                                    unit: "μg/m³"
                                    min: 0
                                    max: 500
                                }

                                // PM10设置
                                ThresholdSetting {
                                    name: "PM10(μg/m³)"
                                    warningValue: 150
                                    criticalValue: 250
                                    unit: "μg/m³"
                                    min: 0
                                    max: 600
                                }

                                // 浊度设置
                                ThresholdSetting {
                                    name: "浊度(NTU)"
                                    warningValue: 5
                                    criticalValue: 20
                                    unit: "NTU"
                                    min: 0
                                    max: 100
                                }

                                // pH值设置
                                ThresholdSetting {
                                    name: "pH值"
                                    warningValue: 8.5
                                    criticalValue: 9.0
                                    unit: ""
                                    min: 0
                                    max: 14
                                    decimals: 1
                                }

                                // TDS设置
                                ThresholdSetting {
                                    name: "TDS(ppm)"
                                    warningValue: 500
                                    criticalValue: 1000
                                    unit: "ppm"
                                    min: 0
                                    max: 2000
                                }

                                Button {
                                    text: "恢复默认值"
                                    Layout.alignment: Qt.AlignRight

                                    contentItem: Text {
                                        text: parent.text
                                        color: textColor
                                        font.pixelSize: fontSize
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    background: Rectangle {
                                        color: parent.down ? Qt.darker(accentColor, 1.2) :
                                               parent.hovered ? accentColor : Qt.darker(accentColor, 1.1)
                                        radius: 4
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // 底部按钮
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                text: "应用"
                Layout.preferredWidth: 100

                contentItem: Text {
                    text: parent.text
                    color: textColor
                    font.pixelSize: fontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.down ? Qt.darker(accentColor, 1.2) :
                           parent.hovered ? accentColor : Qt.darker(accentColor, 1.1)
                    radius: 4
                }

                onClicked: {
                    warningMessage.showWarning("设置已应用", successColor);
                    settingsDialog.close();
                }
            }

            Button {
                text: "确定"
                Layout.preferredWidth: 100

                contentItem: Text {
                    text: parent.text
                    color: textColor
                    font.pixelSize: fontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.down ? Qt.darker(successColor, 1.2) :
                           parent.hovered ? successColor : Qt.darker(successColor, 1.1)
                    radius: 4
                }

                onClicked: {
                    warningMessage.showWarning("设置已保存", successColor);
                    settingsDialog.close();
                }
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "取消"
                Layout.preferredWidth: 100

                contentItem: Text {
                    text: parent.text
                    color: textColor
                    font.pixelSize: fontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.down ? Qt.rgba(0.5,0.5,0.5,0.3) :
                           parent.hovered ? Qt.rgba(0.5,0.5,0.5,0.2) : Qt.rgba(0.5,0.5,0.5,0.1)
                    radius: 4
                }

                onClicked: settingsDialog.close()
            }
        }
    }

    // 阈值设置组件
    component ThresholdSetting: RowLayout {
        property string name: ""
        property real warningValue: 0
        property real criticalValue: 0
        property string unit: ""
        property real min: 0
        property real max: 100
        property int decimals: 0

        Layout.fillWidth: true
        spacing: 10

        Text {
            text: name + ":"
            color: textColor
            font.pixelSize: fontSize
            Layout.preferredWidth: 150
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            RowLayout {
                Layout.fillWidth: true
                spacing: 5

                Text {
                    text: "警告阈值:"
                    color: warningColor
                    font.pixelSize: fontSize
                }

                SpinBox {
                    id: warningSpinBox
                    Layout.fillWidth: true
                    from: min * Math.pow(10, decimals)
                    to: max * Math.pow(10, decimals)
                    value: warningValue * Math.pow(10, decimals)
                    stepSize: Math.pow(10, decimals) / 10
                    editable: true

                    property int decimals: parent.parent.decimals

                    validator: DoubleValidator {
                        bottom: Math.min(warningSpinBox.from, warningSpinBox.to)
                        top: Math.max(warningSpinBox.from, warningSpinBox.to)
                    }

                    textFromValue: function(value, locale) {
                        return Number(value / Math.pow(10, decimals)).toLocaleString(locale, 'f', decimals);
                    }

                    valueFromText: function(text, locale) {
                        return Number.fromLocaleString(locale, text) * Math.pow(10, decimals);
                    }

                    contentItem: TextInput {
                        text: warningSpinBox.textFromValue(warningSpinBox.value, warningSpinBox.locale)
                        color: textColor
                        font.pixelSize: fontSize
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        readOnly: !warningSpinBox.editable
                        validator: warningSpinBox.validator
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        selectByMouse: true
                    }

                    background: Rectangle {
                        color: Qt.rgba(1,1,1,0.1)
                        radius: 4
                        border.color: borderColor
                        border.width: 1
                    }
                }

                Text {
                    text: unit
                    color: textColor
                    font.pixelSize: fontSize
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 5

                Text {
                    text: "严重阈值:"
                    color: dangerColor
                    font.pixelSize: fontSize
                }

                SpinBox {
                    id: criticalSpinBox
                    Layout.fillWidth: true
                    from: min * Math.pow(10, decimals)
                    to: max * Math.pow(10, decimals)
                    value: criticalValue * Math.pow(10, decimals)
                    stepSize: Math.pow(10, decimals) / 10
                    editable: true

                    property int decimals: parent.parent.decimals

                    validator: DoubleValidator {
                        bottom: Math.min(criticalSpinBox.from, criticalSpinBox.to)
                        top: Math.max(criticalSpinBox.from, criticalSpinBox.to)
                    }

                    textFromValue: function(value, locale) {
                        return Number(value / Math.pow(10, decimals)).toLocaleString(locale, 'f', decimals);
                    }

                    valueFromText: function(text, locale) {
                        return Number.fromLocaleString(locale, text) * Math.pow(10, decimals);
                    }

                    contentItem: TextInput {
                        text: criticalSpinBox.textFromValue(criticalSpinBox.value, criticalSpinBox.locale)
                        color: textColor
                        font.pixelSize: fontSize
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        readOnly: !criticalSpinBox.editable
                        validator: criticalSpinBox.validator
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        selectByMouse: true
                    }

                    background: Rectangle {
                        color: Qt.rgba(1,1,1,0.1)
                        radius: 4
                        border.color: borderColor
                        border.width: 1
                    }
                }

                Text {
                    text: unit
                    color: textColor
                    font.pixelSize: fontSize
                }
            }
        }
    }
}
