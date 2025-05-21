// SerialControlPanel.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Rectangle {
    id: serialControlPanel
    color: cardColor

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // 面板标题
        Text {
            text: "串口通信"
            font.pixelSize: largeFontSize
            font.bold: true
            color: textColor
            Layout.fillWidth: true
        }

        // 分隔线
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: borderColor
            opacity: 0.5
        }

        // 串口设置区域
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 8
            columnSpacing: 12

            // 串口选择
            Text {
                text: "串口:"
                color: textColor
                font.pixelSize: fontSize
            }

            ComboBox {
                id: portSelector
                Layout.fillWidth: true
                model: dataSource.availablePorts

                // 样式设置
                delegate: ItemDelegate {
                    width: parent.width
                    contentItem: Text {
                        text: modelData
                        color: textColor
                        font.pixelSize: fontSize
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: portSelector.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2) : "transparent"
                    }
                }

                contentItem: Text {
                    text: portSelector.displayText
                    color: textColor
                    font.pixelSize: fontSize
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    leftPadding: 8
                }

                background: Rectangle {
                    color: Qt.rgba(1,1,1,0.1)
                    radius: 4
                    border.color: borderColor
                    border.width: 1
                }

                popup: Popup {
                    y: portSelector.height
                    width: portSelector.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: portSelector.popup.visible ? portSelector.delegateModel : null

                        ScrollBar.vertical: ScrollBar {
                            active: true
                        }
                    }

                    background: Rectangle {
                        color: darkColor
                        border.color: borderColor
                        radius: 4
                    }
                }
            }

            // 波特率选择
            Text {
                text: "波特率:"
                color: textColor
                font.pixelSize: fontSize
            }

            ComboBox {
                id: baudRateSelector
                Layout.fillWidth: true
                model: ["4800", "9600", "19200", "38400", "57600", "115200"]
                currentIndex: 5

                // 样式设置
                delegate: ItemDelegate {
                    width: parent.width
                    contentItem: Text {
                        text: modelData
                        color: textColor
                        font.pixelSize: fontSize
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: baudRateSelector.highlightedIndex === index

                    background: Rectangle {
                        color: highlighted ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2) : "transparent"
                    }
                }

                contentItem: Text {
                    text: baudRateSelector.displayText
                    color: textColor
                    font.pixelSize: fontSize
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    leftPadding: 8
                }

                background: Rectangle {
                    color: Qt.rgba(1,1,1,0.1)
                    radius: 4
                    border.color: borderColor
                    border.width: 1
                }

                popup: Popup {
                    y: baudRateSelector.height
                    width: baudRateSelector.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: baudRateSelector.popup.visible ? baudRateSelector.delegateModel : null

                        ScrollBar.vertical: ScrollBar {
                            active: true
                        }
                    }

                    background: Rectangle {
                        color: darkColor
                        border.color: borderColor
                        radius: 4
                    }
                }
            }
        }

        // 模拟数据开关
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "模拟数据:"
                color: textColor
                font.pixelSize: fontSize
            }

            Switch {
                id: simulateSwitch
                checked: dataSource.isSimulating

                indicator: Rectangle {
                    width: 36
                    height: 18
                    radius: 9
                    color: simulateSwitch.checked ? accentColor : borderColor

                    Rectangle {
                        x: simulateSwitch.checked ? parent.width - width - 2 : 2
                        width: 14
                        height: 14
                        radius: 7
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"

                        Behavior on x {
                            NumberAnimation { duration: 200 }
                        }
                    }
                }

                contentItem: Text {
                    text: simulateSwitch.checked ? "已开启" : "已关闭"
                    font.pixelSize: fontSize
                    color: textColor
                    leftPadding: simulateSwitch.indicator.width + 4
                }

                onCheckedChanged: {
                    dataSource.setIsSimulating(checked);
                }
            }
        }

        // 帧格式设置
        GroupBox {
            Layout.fillWidth: true
            title: "帧格式设置"

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
                rowSpacing: 8
                columnSpacing: 12

                Text {
                    text: "传感器帧头:"
                    color: textColor
                    font.pixelSize: fontSize
                }

                TextField {
                    id: sensorFrameHeaderField
                    Layout.fillWidth: true
                    text: dataSource.sensorFrameHeader
                    placeholderText: "FF"
                    validator: RegExpValidator { regExp: /^[0-9A-Fa-f]{2}$/ }
                    color: textColor
                    font.pixelSize: fontSize
                    font.family: "Consolas, monospace"

                    background: Rectangle {
                        color: Qt.rgba(1,1,1,0.1)
                        radius: 4
                        border.color: sensorFrameHeaderField.activeFocus ? accentColor : borderColor
                        border.width: sensorFrameHeaderField.activeFocus ? 2 : 1
                    }

                    onTextChanged: {
                        if (acceptableInput) {
                            dataSource.sensorFrameHeader = text.toUpperCase();
                        }
                    }
                }

                Text {
                    text: "传感器帧尾:"
                    color: textColor
                    font.pixelSize: fontSize
                }

                TextField {
                    id: sensorFrameTrailerField
                    Layout.fillWidth: true
                    text: dataSource.sensorFrameTrailer
                    placeholderText: "FE"
                    validator: RegExpValidator { regExp: /^[0-9A-Fa-f]{2}$/ }
                    color: textColor
                    font.pixelSize: fontSize
                    font.family: "Consolas, monospace"

                    background: Rectangle {
                        color: Qt.rgba(1,1,1,0.1)
                        radius: 4
                        border.color: sensorFrameTrailerField.activeFocus ? accentColor : borderColor
                        border.width: sensorFrameTrailerField.activeFocus ? 2 : 1
                    }

                    onTextChanged: {
                        if (acceptableInput) {
                            dataSource.sensorFrameTrailer = text.toUpperCase();
                        }
                    }
                }

                Text {
                    text: "艇数据帧头:"
                    color: textColor
                    font.pixelSize: fontSize
                }

                TextField {
                    id: boatFrameHeaderField
                    Layout.fillWidth: true
                    text: dataSource.boatFrameHeader
                    placeholderText: "AA"
                    validator: RegExpValidator { regExp: /^[0-9A-Fa-f]{2}$/ }
                    color: textColor
                    font.pixelSize: fontSize
                    font.family: "Consolas, monospace"

                    background: Rectangle {
                        color: Qt.rgba(1,1,1,0.1)
                        radius: 4
                        border.color: boatFrameHeaderField.activeFocus ? accentColor : borderColor
                        border.width: boatFrameHeaderField.activeFocus ? 2 : 1
                    }

                    onTextChanged: {
                        if (acceptableInput) {
                            dataSource.boatFrameHeader = text.toUpperCase();
                        }
                    }
                }

                Text {
                    text: "艇数据帧尾:"
                    color: textColor
                    font.pixelSize: fontSize
                }

                TextField {
                    id: boatFrameTrailerField
                    Layout.fillWidth: true
                    text: dataSource.boatFrameTrailer
                    placeholderText: "BB"
                    validator: RegExpValidator { regExp: /^[0-9A-Fa-f]{2}$/ }
                    color: textColor
                    font.pixelSize: fontSize
                    font.family: "Consolas, monospace"

                    background: Rectangle {
                        color: Qt.rgba(1,1,1,0.1)
                        radius: 4
                        border.color: boatFrameTrailerField.activeFocus ? accentColor : borderColor
                        border.width: boatFrameTrailerField.activeFocus ? 2 : 1
                    }

                    onTextChanged: {
                        if (acceptableInput) {
                            dataSource.boatFrameTrailer = text.toUpperCase();
                        }
                    }
                }
            }
        }

        // 控制按钮
        Button {
            id: togglePortButton
            Layout.fillWidth: true
            text: dataSource.isPortOpen ? "关闭串口" : "打开串口"

            contentItem: Text {
                text: parent.text
                color: textColor
                font.pixelSize: fontSize
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: {
                    if (parent.down) {
                        return dataSource.isPortOpen ?
                               Qt.darker(dangerColor, 1.2) :
                               Qt.darker(successColor, 1.2);
                    }
                    if (parent.hovered) {
                        return dataSource.isPortOpen ? dangerColor : successColor;
                    }
                    return dataSource.isPortOpen ?
                           Qt.lighter(dangerColor, 1.1) :
                           Qt.lighter(successColor, 1.1);
                }
                radius: 4

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }

            onClicked: {
                if (dataSource.isPortOpen) {
                    dataSource.closeSerialPort();
                } else {
                    var baudRate = parseInt(baudRateSelector.currentText);
                    var success = dataSource.openSerialPort(
                        portSelector.currentText,
                        baudRate
                    );

                    if (!success) {
                        warningMessage.showWarning("串口打开失败", dangerColor);
                    } else {
                        warningMessage.showWarning("串口已打开", successColor);
                    }
                }
            }
        }

        // 数据显示区域
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            TabBar {
                id: dataTabBar
                Layout.fillWidth: true

                TabButton {
                    text: "接收数据"
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
                    text: "发送数据"
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

            StackLayout {
                currentIndex: dataTabBar.currentIndex
                Layout.fillWidth: true
                Layout.fillHeight: true

                // 接收数据页
                ColumnLayout {
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true

                        Item { Layout.fillWidth: true }

                        Button {
                            text: "清空"

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

                            onClicked: receivedData.text = ""
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Qt.rgba(0,0,0,0.2)
                        radius: 4
                        border.color: borderColor
                        border.width: 1

                        ScrollView {
                            id: dataScrollView1
                            anchors.fill: parent
                            anchors.margins: 8

                            TextArea {
                                id: receivedData
                                readOnly: true
                                wrapMode: TextEdit.Wrap
                                textFormat: TextEdit.RichText
                                color: textColor
                                font.pixelSize: fontSize
                                font.family: "Consolas, monospace"

                                background: Rectangle {
                                    color: "transparent"
                                }

                                // 自动滚动到底部
                                onTextChanged: {
                                    cursorPosition = text.length;
                                }
                            }
                        }
                    }
                }

                // 发送数据页
                ColumnLayout {
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true

                        Item { Layout.fillWidth: true }

                        Button {
                            text: "清空"

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

                            onClicked: sentData.text = ""
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Qt.rgba(0,0,0,0.2)
                        radius: 4
                        border.color: borderColor
                        border.width: 1

                        ScrollView {
                            id: dataScrollView2
                            anchors.fill: parent
                            anchors.margins: 8

                            TextArea {
                                id: sentData
                                readOnly: true
                                wrapMode: TextEdit.Wrap
                                textFormat: TextEdit.RichText
                                color: textColor
                                font.pixelSize: fontSize
                                font.family: "Consolas, monospace"

                                background: Rectangle {
                                    color: "transparent"
                                }

                                // 自动滚动到底部
                                onTextChanged: {
                                    cursorPosition = text.length;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // 数据源连接
    Connections {
        target: dataSource

        function onSensorDataReceived(data) {
            receivedData.append("<span style='color: #3498DB;'>[传感器] " + formatTime() + "</span><br>" +
                               "<span style='color: #ECF0F1;'>" + data + "</span><br>");
        }

        function onVesselDataReceived(data) {
            receivedData.append("<span style='color: #E74C3C;'>[船只] " + formatTime() + "</span><br>" +
                               "<span style='color: #ECF0F1;'>" + data + "</span><br>");
        }

        function onPortOpenChanged() {
            if (dataSource.isPortOpen) {
                warningMessage.showWarning("串口已连接", successColor);
            } else {
                warningMessage.showWarning("串口已断开", warningColor);
            }
        }

        function onError(message) {
            warningMessage.showWarning("错误: " + message, dangerColor);
            receivedData.append("<span style='color: #E74C3C;'>[错误] " + formatTime() + " " + message + "</span><br>");
        }
    }

    // 格式化时间函数
    function formatTime() {
        var now = new Date();
        return now.toLocaleTimeString(Qt.locale(), "hh:mm:ss.zzz");
    }
}
