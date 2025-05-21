// SerialControlPanel.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "." // 导入Theme单例

Rectangle {
    id: serialControlPanel
    // color: cardColor // 旧颜色
    color: Theme.darkThemeCardColor // 使用Theme中的深色卡片背景色

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.paddingLarge // 使用Theme中的大内边距
        spacing: Theme.paddingLarge

        // 面板标题
        Text {
            text: "串口通信" // 串口通信
            font.pixelSize: Theme.largeFontSize // 使用Theme中的大字号
            font.bold: true
            color: Theme.textColorOnDark // 使用Theme中的深色背景文本颜色
            Layout.fillWidth: true
        }

        // 分隔线
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.borderColor // 使用Theme中的边框颜色
            opacity: 0.5
        }

        // 串口设置区域
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: Theme.paddingMedium // 使用Theme中的中间距
            columnSpacing: Theme.paddingLarge

            // 串口选择
            Text {
                text: "串口:"
                color: Theme.textColorOnDark
                font.pixelSize: Theme.defaultFontSize // 使用Theme中的默认字号
            }

            ComboBox {
                id: portSelector
                Layout.fillWidth: true
                model: dataSource.availablePorts
                height: Theme.controlHeight // 使用Theme中的标准控件高度

                delegate: ItemDelegate { // 下拉列表项代理
                    width: parent.width
                    height: Theme.controlHeight / 1.5 // 调整项高度
                    contentItem: Text {
                        text: modelData
                        color: Theme.textColorOnDark
                        font.pixelSize: Theme.defaultFontSize
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: portSelector.highlightedIndex === index
                    background: Rectangle {
                        color: highlighted ? Qt.rgba(Theme.primaryColor.r, Theme.primaryColor.g, Theme.primaryColor.b, 0.2) : "transparent"
                    }
                }

                contentItem: Text { // ComboBox当前显示文本
                    text: portSelector.displayText
                    color: Theme.textColorOnDark
                    font.pixelSize: Theme.defaultFontSize
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    leftPadding: Theme.paddingMedium
                }

                background: Rectangle { // ComboBox背景
                    color: Qt.rgba(Theme.textColorOnDark.r, Theme.textColorOnDark.g, Theme.textColorOnDark.b, 0.1)
                    radius: Theme.buttonCornerRadius // 使用Theme中的按钮圆角
                    border.color: Theme.borderColor
                    border.width: 1
                }

                popup: Popup { // 下拉框样式
                    y: portSelector.height
                    width: portSelector.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1
                    background: Rectangle {
                        color: Theme.darkThemeBackgroundColor // 使用Theme的深色背景
                        border.color: Theme.borderColor
                        radius: Theme.buttonCornerRadius
                    }
                    contentItem: ListView {
                        clip: true
                        implicitHeight: Math.min(contentHeight, 200) // 限制最大高度
                        model: portSelector.popup.visible ? portSelector.delegateModel : null
                        ScrollBar.vertical: ScrollBar { active: true }
                    }
                }
            }

            // 波特率选择
            Text {
                text: "波特率:"
                color: Theme.textColorOnDark
                font.pixelSize: Theme.defaultFontSize
            }

            ComboBox {
                id: baudRateSelector
                Layout.fillWidth: true
                model: ["4800", "9600", "19200", "38400", "57600", "115200"]
                currentIndex: 5 // 默认115200
                height: Theme.controlHeight

                delegate: ItemDelegate {
                    width: parent.width
                    height: Theme.controlHeight / 1.5
                    contentItem: Text {
                        text: modelData
                        color: Theme.textColorOnDark
                        font.pixelSize: Theme.defaultFontSize
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: baudRateSelector.highlightedIndex === index
                    background: Rectangle {
                        color: highlighted ? Qt.rgba(Theme.primaryColor.r, Theme.primaryColor.g, Theme.primaryColor.b, 0.2) : "transparent"
                    }
                }
                contentItem: Text {
                    text: baudRateSelector.displayText
                    color: Theme.textColorOnDark
                    font.pixelSize: Theme.defaultFontSize
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    leftPadding: Theme.paddingMedium
                }
                background: Rectangle {
                    color: Qt.rgba(Theme.textColorOnDark.r, Theme.textColorOnDark.g, Theme.textColorOnDark.b, 0.1)
                    radius: Theme.buttonCornerRadius
                    border.color: Theme.borderColor
                    border.width: 1
                }
                popup: Popup { // 与portSelector的popup样式一致
                    y: baudRateSelector.height
                    width: baudRateSelector.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1
                    background: Rectangle {
                        color: Theme.darkThemeBackgroundColor
                        border.color: Theme.borderColor
                        radius: Theme.buttonCornerRadius
                    }
                    contentItem: ListView {
                        clip: true
                        implicitHeight: Math.min(contentHeight, 200)
                        model: baudRateSelector.popup.visible ? baudRateSelector.delegateModel : null
                        ScrollBar.vertical: ScrollBar { active: true }
                    }
                }
            }
        }

        // 模拟数据开关
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.paddingMedium

            Text {
                text: "模拟数据:"
                color: Theme.textColorOnDark
                font.pixelSize: Theme.defaultFontSize
            }

            Switch {
                id: simulateSwitch
                checked: dataSource.isSimulating

                indicator: Rectangle {
                    width: 36
                    height: 18
                    radius: 9
                    // color: simulateSwitch.checked ? accentColor : borderColor // 旧颜色
                    color: simulateSwitch.checked ? Theme.primaryColor : Theme.borderColor

                    Rectangle { // 滑块圆点
                        x: simulateSwitch.checked ? parent.width - width - 2 : 2
                        width: 14
                        height: 14
                        radius: 7
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.textColorOnLight // 使用浅色文本作为滑块圆点

                        Behavior on x {
                            NumberAnimation { duration: 200 }
                        }
                    }
                }

                contentItem: Text {
                    text: simulateSwitch.checked ? "已开启" : "已关闭"
                    font.pixelSize: Theme.defaultFontSize
                    color: Theme.textColorOnDark
                    leftPadding: simulateSwitch.indicator.width + Theme.paddingSmall
                }
                onCheckedChanged: {
                    dataSource.setIsSimulating(checked);
                }
            }
        }

        // 帧格式设置 (已移除)
        // GroupBox { ... }

        // 控制按钮
        Button {
            id: togglePortButton
            Layout.fillWidth: true
            text: dataSource.isPortOpen ? "关闭串口" : "打开串口" // 关闭串口 / 打开串口
            height: Theme.controlHeight

            contentItem: Text {
                text: parent.text
                color: Theme.textColorOnLight // 假设按钮背景深
                font.pixelSize: Theme.defaultFontSize
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: { // 根据状态使用Theme颜色
                    if (parent.down) {
                        return dataSource.isPortOpen ?
                               Qt.darker(Theme.accentColor, 1.2) : // 危险色按下
                               Qt.darker(Theme.secondaryColor, 1.2); // 成功色按下
                    }
                    if (parent.hovered) {
                        return dataSource.isPortOpen ? Theme.accentColor : Theme.secondaryColor;
                    }
                    return dataSource.isPortOpen ?
                           Qt.lighter(Theme.accentColor, 1.1) :
                           Qt.lighter(Theme.secondaryColor, 1.1);
                }
                radius: Theme.buttonCornerRadius // 使用Theme按钮圆角

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
                        // warningMessage.showWarning("串口打开失败", dangerColor); // 旧颜色
                        warningMessage.showWarning("串口打开失败", Theme.accentColor);
                    } else {
                        // warningMessage.showWarning("串口已打开", successColor); // 旧颜色
                        warningMessage.showWarning("串口已打开", Theme.secondaryColor);
                    }
                }
            }
        }

        // 数据显示区域
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.paddingMedium

            TabBar {
                id: dataTabBar
                Layout.fillWidth: true

                TabButton {
                    text: "接收数据" // 接收数据
                    width: implicitWidth

                    contentItem: Text {
                        text: parent.text
                        // color: parent.checked ? accentColor : textColor // 旧颜色
                        color: parent.checked ? Theme.primaryColor : Theme.textColorOnDark
                        font.pixelSize: Theme.defaultFontSize
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: "transparent"
                        Rectangle { // 选中指示器
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            // color: parent.parent.checked ? accentColor : "transparent" // 旧颜色
                            color: parent.parent.checked ? Theme.primaryColor : "transparent"
                        }
                    }
                }

                TabButton {
                    text: "发送数据" // 发送数据
                    width: implicitWidth
                    contentItem: Text {
                        text: parent.text
                        // color: parent.checked ? accentColor : textColor // 旧颜色
                        color: parent.checked ? Theme.primaryColor : Theme.textColorOnDark
                        font.pixelSize: Theme.defaultFontSize
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle { // 与接收数据TabButton样式一致
                        color: "transparent"
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            // color: parent.parent.checked ? accentColor : "transparent" // 旧颜色
                            color: parent.parent.checked ? Theme.primaryColor : "transparent"
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
                    spacing: Theme.paddingMedium

                    RowLayout {
                        Layout.fillWidth: true
                        Item { Layout.fillWidth: true } // 占位使按钮右对齐
                        Button {
                            text: "清空" // 清空
                            height: Theme.controlHeight / 1.2 // 稍小一点的按钮
                            contentItem: Text {
                                text: parent.text
                                color: Theme.textColorOnDark
                                font.pixelSize: Theme.smallFontSize // 使用小字号
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                // color: parent.down ? Qt.darker(accentColor, 1.2) : // 旧颜色
                                //        parent.hovered ? accentColor : Qt.darker(accentColor, 1.1)
                                color: parent.down ? Qt.darker(Theme.primaryColor, 1.2) :
                                       parent.hovered ? Theme.primaryColor : Qt.lighter(Theme.primaryColor, 1.1)
                                radius: Theme.buttonCornerRadius
                            }
                            onClicked: receivedData.text = ""
                        }
                    }

                    Rectangle { // TextArea 背景
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Qt.rgba(Theme.darkThemeBackgroundColor.r, Theme.darkThemeBackgroundColor.g, Theme.darkThemeBackgroundColor.b, 0.2) // 更深的背景
                        radius: Theme.buttonCornerRadius
                        border.color: Theme.borderColor
                        border.width: 1

                        ScrollView {
                            id: dataScrollView1
                            anchors.fill: parent
                            anchors.margins: Theme.paddingMedium
                            TextArea {
                                id: receivedData
                                readOnly: true
                                wrapMode: TextEdit.Wrap
                                textFormat: TextEdit.RichText
                                color: Theme.textColorOnDark // 使用Theme文本色
                                font.pixelSize: Theme.defaultFontSize // 使用Theme默认字号
                                font.family: "Consolas, monospace"
                                background: Rectangle { color: "transparent" }
                                onTextChanged: { cursorPosition = text.length; } // 自动滚动到底部
                            }
                        }
                    }
                }

                // 发送数据页 (与接收数据页样式类似)
                ColumnLayout {
                    spacing: Theme.paddingMedium
                    RowLayout {
                        Layout.fillWidth: true
                        Item { Layout.fillWidth: true }
                        Button {
                            text: "清空"
                            height: Theme.controlHeight / 1.2
                            contentItem: Text {
                                text: parent.text
                                color: Theme.textColorOnDark
                                font.pixelSize: Theme.smallFontSize
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: parent.down ? Qt.darker(Theme.primaryColor, 1.2) :
                                       parent.hovered ? Theme.primaryColor : Qt.lighter(Theme.primaryColor, 1.1)
                                radius: Theme.buttonCornerRadius
                            }
                            onClicked: sentData.text = ""
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Qt.rgba(Theme.darkThemeBackgroundColor.r, Theme.darkThemeBackgroundColor.g, Theme.darkThemeBackgroundColor.b, 0.2)
                        radius: Theme.buttonCornerRadius
                        border.color: Theme.borderColor
                        border.width: 1
                        ScrollView {
                            id: dataScrollView2
                            anchors.fill: parent
                            anchors.margins: Theme.paddingMedium
                            TextArea {
                                id: sentData
                                readOnly: true
                                wrapMode: TextEdit.Wrap
                                textFormat: TextEdit.RichText
                                color: Theme.textColorOnDark
                                font.pixelSize: Theme.defaultFontSize
                                font.family: "Consolas, monospace"
                                background: Rectangle { color: "transparent" }
                                onTextChanged: { cursorPosition = text.length; }
                            }
                        }
                    }
                }
            }
        }
    }

    // 数据源连接 (用于更新日志，颜色需要从Theme获取)
    Connections {
        target: dataSource
        // 注意: onSensorDataReceived 和 onVesselDataReceived 已被移除，
        // 因为数据现在通过C++信号槽直接传递给相应的模块。
        // 此Connections块主要用于错误和端口状态消息的UI反馈。

        function onPortOpenChanged() {
            if (dataSource.isPortOpen) {
                // warningMessage.showWarning("串口已连接", successColor); // 旧颜色
                warningMessage.showWarning("串口已连接", Theme.secondaryColor);
            } else {
                // warningMessage.showWarning("串口已断开", warningColor); // 旧颜色
                warningMessage.showWarning("串口已断开", Theme.warningColor);
            }
        }

        function onError(message) {
            // warningMessage.showWarning("错误: " + message, dangerColor); // 旧颜色
            warningMessage.showWarning("错误: " + message, Theme.accentColor);
            // 日志区域的错误消息颜色也应使用Theme
            receivedData.append("<span style='color:" + Theme.accentColor + ";'>[错误] " + formatTime() + " " + message + "</span><br>");
        }
    }

    // 格式化时间函数 (保持不变)
    function formatTime() {
        var now = new Date();
        return now.toLocaleTimeString(Qt.locale(), "hh:mm:ss.zzz");
    }
}
