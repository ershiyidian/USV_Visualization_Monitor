import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import QtCharts 2.15
import QtQuick.Dialogs 1.3

// 使用Window而非Dialog，创建真正的独立窗口
Window {
    id: historyDataWindow
    title: "历史数据查询与分析"
    width: 900
    height: 700
    color: darkColor  // 使用应用的深色背景

    // 显示关闭、最小化按钮，但不显示最大化按钮
    flags: Qt.Window | Qt.WindowCloseButtonHint | Qt.WindowMinimizeButtonHint

    // // 设置窗口透明
    // color: "transparent"

    // 中心显示
    property bool initialized: false

    // 窗口初始化后居中显示
    Component.onCompleted: {
        x = Screen.width / 2 - width / 2
        y = Screen.height / 2 - height / 2
        initialized = true
    }

    // 主容器 - 带圆角和阴影
    Rectangle {
        anchors.fill: parent
        color: darkColor
        radius: 10

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12.0
            samples: 17
            color: Qt.rgba(0, 0, 0, 0.5)
        }

        // 自定义标题栏
        Rectangle {
            id: titleBar
            width: parent.width
            height: 40
            color: primaryColor
            radius: 10

            // 只有顶部圆角
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.height / 2
                color: primaryColor
            }

            // 窗口拖动区域
            MouseArea {
                anchors.fill: parent
                property point clickPos: "0,0"

                onPressed: {
                    clickPos = Qt.point(mouse.x, mouse.y)
                }

                onPositionChanged: {
                    if (pressed) {
                        var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                        historyDataWindow.x += delta.x
                        historyDataWindow.y += delta.y
                    }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 10

                // 标题和图标
                RowLayout {
                    spacing: 8

                    // 图标
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 4
                        color: accentColor

                        Text {
                            anchors.centerIn: parent
                            text: "📊"
                            color: "white"
                            font.pixelSize: smallFontSize
                        }
                    }

                    // 标题文本
                    Text {
                        text: historyDataWindow.title
                        color: textColor
                        font.pixelSize: largeFontSize
                        font.bold: true
                    }
                }

                Item { Layout.fillWidth: true }

                // 最小化按钮
                Button {
                    id: minimizeButton
                    implicitWidth: 30
                    implicitHeight: 30
                    flat: true

                    contentItem: Text {
                        text: "—"
                        color: textColor
                        font.pixelSize: fontSize
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.hovered ? Qt.rgba(1,1,1,0.1) : "transparent"
                        radius: 4
                    }

                    onClicked: {
                        historyDataWindow.visibility = Window.Minimized
                    }

                    ToolTip.visible: hovered
                    ToolTip.text: "最小化"
                    ToolTip.delay: 500
                }

                // 关闭按钮
                Button {
                    id: closeButton
                    implicitWidth: 30
                    implicitHeight: 30
                    flat: true

                    contentItem: Text {
                        text: "×"
                        color: closeButton.hovered ? dangerColor : textColor
                        font.pixelSize: largeFontSize
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.hovered ? Qt.rgba(1,0,0,0.1) : "transparent"
                        radius: 4
                    }

                    onClicked: {
                        historyDataWindow.close()
                    }

                    ToolTip.visible: hovered
                    ToolTip.text: "关闭"
                    ToolTip.delay: 500
                }
            }
        }

        // 主内容区域
        ColumnLayout {
            anchors.top: titleBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 15
            spacing: 15

            // 查询条件区域
            Rectangle {
                Layout.fillWidth: true
                height: 185
                color: cardColor
                radius: 8

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    // 顶部查询控件区域
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 6
                        rowSpacing: 10
                        columnSpacing: 12

                        // 日期选择器 - 开始日期
                        Text {
                            text: "开始日期:"
                            color: textColor
                            font.pixelSize: fontSize
                            Layout.row: 0
                            Layout.column: 0
                        }

                        Button {
                            id: startDateBtn
                            property date selectedDate: new Date()
                            text: Qt.formatDate(selectedDate, "yyyy-MM-dd")
                            Layout.row: 0
                            Layout.column: 1
                            Layout.fillWidth: true

                            contentItem: Text {
                                text: parent.text
                                color: textColor
                                font.pixelSize: fontSize
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: Qt.rgba(1,1,1,0.1)
                                radius: 4
                                border.color: startDateBtn.down ? accentColor : borderColor
                                border.width: 1
                            }

                            onClicked: {
                                calendarPopup.target = startDateBtn
                                calendarPopup.selectedDate = startDateBtn.selectedDate
                                calendarPopup.open()
                            }
                        }

                        // 日期选择器 - 结束日期
                        Text {
                            text: "结束日期:"
                            color: textColor
                            font.pixelSize: fontSize
                            Layout.row: 0
                            Layout.column: 2
                        }

                        Button {
                            id: endDateBtn
                            property date selectedDate: new Date()
                            text: Qt.formatDate(selectedDate, "yyyy-MM-dd")
                            Layout.row: 0
                            Layout.column: 3
                            Layout.fillWidth: true

                            contentItem: Text {
                                text: parent.text
                                color: textColor
                                font.pixelSize: fontSize
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: Qt.rgba(1,1,1,0.1)
                                radius: 4
                                border.color: endDateBtn.down ? accentColor : borderColor
                                border.width: 1
                            }

                            onClicked: {
                                calendarPopup.target = endDateBtn
                                calendarPopup.selectedDate = endDateBtn.selectedDate
                                calendarPopup.open()
                            }
                        }

                        // 快速日期选择
                        Text {
                            text: "快速选择:"
                            color: textColor
                            font.pixelSize: fontSize
                            Layout.row: 0
                            Layout.column: 4
                        }

                        ComboBox {
                            id: quickDateCombo
                            Layout.row: 0
                            Layout.column: 5
                            Layout.fillWidth: true
                            model: ["今天", "昨天", "过去7天", "过去30天", "本月", "上月", "自定义"]
                            currentIndex: 2

                            delegate: ItemDelegate {
                                width: quickDateCombo.width
                                contentItem: Text {
                                    text: modelData
                                    color: textColor
                                    font.pixelSize: fontSize
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                highlighted: quickDateCombo.highlightedIndex === index

                                background: Rectangle {
                                    color: highlighted ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2) : "transparent"
                                }
                            }

                            contentItem: Text {
                                text: quickDateCombo.displayText
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
                                y: quickDateCombo.height
                                width: quickDateCombo.width
                                implicitHeight: contentItem.implicitHeight
                                padding: 1

                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: quickDateCombo.popup.visible ? quickDateCombo.delegateModel : null

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

                            onCurrentIndexChanged: {
                                var today = new Date();
                                var start = new Date();
                                var end = new Date();

                                switch(currentIndex) {
                                    case 0: // 今天
                                        // 保持当天日期
                                        break;
                                    case 1: // 昨天
                                        start.setDate(today.getDate() - 1);
                                        end.setDate(today.getDate() - 1);
                                        break;
                                    case 2: // 过去7天
                                        start.setDate(today.getDate() - 6);
                                        break;
                                    case 3: // 过去30天
                                        start.setDate(today.getDate() - 29);
                                        break;
                                    case 4: // 本月
                                        start.setDate(1);
                                        break;
                                    case 5: // 上月
                                        start.setMonth(today.getMonth() - 1);
                                        start.setDate(1);
                                        end.setDate(0); // 上月最后一天
                                        break;
                                    case 6: // 自定义
                                        // 保持当前选择
                                        return;
                                }

                                // 更新日期按钮
                                startDateBtn.selectedDate = start;
                                startDateBtn.text = Qt.formatDate(start, "yyyy-MM-dd");
                                endDateBtn.selectedDate = end;
                                endDateBtn.text = Qt.formatDate(end, "yyyy-MM-dd");
                            }
                        }

                        // 数据类型选择
                        Text {
                            text: "数据类型:"
                            color: textColor
                            font.pixelSize: fontSize
                            Layout.row: 1
                            Layout.column: 0
                        }

                        ComboBox {
                            id: dataTypeCombo
                            Layout.row: 1
                            Layout.column: 1
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            model: ["全部数据", "传感器数据", "船只数据", "轨迹数据"]
                            currentIndex: 0

                            // 样式与其他ComboBox相同
                            delegate: ItemDelegate {
                                width: dataTypeCombo.width
                                contentItem: Text {
                                    text: modelData
                                    color: textColor
                                    font.pixelSize: fontSize
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                highlighted: dataTypeCombo.highlightedIndex === index

                                background: Rectangle {
                                    color: highlighted ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2) : "transparent"
                                }
                            }

                            contentItem: Text {
                                text: dataTypeCombo.displayText
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
                                y: dataTypeCombo.height
                                width: dataTypeCombo.width
                                implicitHeight: contentItem.implicitHeight
                                padding: 1

                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: dataTypeCombo.popup.visible ? dataTypeCombo.delegateModel : null

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

                        // 传感器选择
                        Text {
                            text: "传感器:"
                            color: textColor
                            font.pixelSize: fontSize
                            Layout.row: 1
                            Layout.column: 3
                            visible: dataTypeCombo.currentIndex === 1
                        }

                        ComboBox {
                            id: sensorCombo
                            Layout.row: 1
                            Layout.column: 4
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            visible: dataTypeCombo.currentIndex === 1
                            model: ["全部传感器", "CO₂", "甲醛", "TVOC", "PM2.5", "PM10", "空气温度",
                                    "湿度", "浊度", "pH值", "TDS", "水温", "液位"]
                            currentIndex: 0

                            // 样式与其他ComboBox相同
                            delegate: ItemDelegate {
                                width: sensorCombo.width
                                contentItem: Text {
                                    text: modelData
                                    color: textColor
                                    font.pixelSize: fontSize
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                highlighted: sensorCombo.highlightedIndex === index

                                background: Rectangle {
                                    color: highlighted ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2) : "transparent"
                                }
                            }

                            contentItem: Text {
                                text: sensorCombo.displayText
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
                                y: sensorCombo.height
                                width: sensorCombo.width
                                implicitHeight: contentItem.implicitHeight
                                padding: 1

                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: sensorCombo.popup.visible ? sensorCombo.delegateModel : null

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

                        // 船只区域（如果数据类型是船只数据）
                        Text {
                            text: "船只参数:"
                            color: textColor
                            font.pixelSize: fontSize
                            Layout.row: 1
                            Layout.column: 3
                            visible: dataTypeCombo.currentIndex === 2
                        }

                        ComboBox {
                            id: vesselParamCombo
                            Layout.row: 1
                            Layout.column: 4
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            visible: dataTypeCombo.currentIndex === 2
                            model: ["全部参数", "位置", "航速", "航向", "电池状态"]
                            currentIndex: 0

                            // 样式与其他ComboBox相同
                            delegate: ItemDelegate {
                                width: vesselParamCombo.width
                                contentItem: Text {
                                    text: modelData
                                    color: textColor
                                    font.pixelSize: fontSize
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                highlighted: vesselParamCombo.highlightedIndex === index

                                background: Rectangle {
                                    color: highlighted ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2) : "transparent"
                                }
                            }

                            contentItem: Text {
                                text: vesselParamCombo.displayText
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
                                y: vesselParamCombo.height
                                width: vesselParamCombo.width
                                implicitHeight: contentItem.implicitHeight
                                padding: 1

                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: vesselParamCombo.popup.visible ? vesselParamCombo.delegateModel : null

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

                        // 状态过滤
                        Text {
                            text: "数据状态:"
                            color: textColor
                            font.pixelSize: fontSize
                            Layout.row: 2
                            Layout.column: 0
                        }

                        ComboBox {
                            id: statusCombo
                            Layout.row: 2
                            Layout.column: 1
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            model: ["全部状态", "正常", "警告", "超标", "异常"]
                            currentIndex: 0

                            // 样式与其他ComboBox相同，但增加了状态颜色指示
                            delegate: ItemDelegate {
                                width: statusCombo.width

                                contentItem: RowLayout {
                                    spacing: 8

                                    Rectangle {
                                        width: 12
                                        height: 12
                                        radius: 6
                                        color: {
                                            if (modelData === "正常") return successColor;
                                            if (modelData === "警告") return warningColor;
                                            if (modelData === "超标") return dangerColor;
                                            if (modelData === "异常") return Qt.rgba(0.5, 0, 0.5, 1); // 紫色
                                            return "transparent";
                                        }
                                        visible: modelData !== "全部状态"
                                    }

                                    Text {
                                        text: modelData
                                        color: textColor
                                        font.pixelSize: fontSize
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                        Layout.fillWidth: true
                                    }
                                }

                                highlighted: statusCombo.highlightedIndex === index

                                background: Rectangle {
                                    color: highlighted ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2) : "transparent"
                                }
                            }

                            contentItem: RowLayout {
                                spacing: 8

                                Rectangle {
                                    width: 12
                                    height: 12
                                    radius: 6
                                    color: {
                                        var text = statusCombo.displayText;
                                        if (text === "正常") return successColor;
                                        if (text === "警告") return warningColor;
                                        if (text === "超标") return dangerColor;
                                        if (text === "异常") return Qt.rgba(0.5, 0, 0.5, 1);
                                        return "transparent";
                                    }
                                    visible: statusCombo.displayText !== "全部状态"
                                }

                                Text {
                                    text: statusCombo.displayText
                                    color: textColor
                                    font.pixelSize: fontSize
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            background: Rectangle {
                                color: Qt.rgba(1,1,1,0.1)
                                radius: 4
                                border.color: borderColor
                                border.width: 1
                            }

                            popup: Popup {
                                y: statusCombo.height
                                width: statusCombo.width
                                implicitHeight: contentItem.implicitHeight
                                padding: 1

                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: statusCombo.popup.visible ? statusCombo.delegateModel : null

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

                        // 高级搜索条件
                        Text {
                            text: "搜索条件:"
                            color: textColor
                            font.pixelSize: fontSize
                            Layout.row: 2
                            Layout.column: 3
                        }

                        TextField {
                            id: searchField
                            Layout.row: 2
                            Layout.column: 4
                            Layout.columnSpan: 2
                            Layout.fillWidth: true
                            placeholderText: "输入关键词搜索..."
                            color: textColor
                            font.pixelSize: fontSize

                            background: Rectangle {
                                color: Qt.rgba(1,1,1,0.1)
                                radius: 4
                                border.color: searchField.activeFocus ? accentColor : borderColor
                                border.width: 1
                            }

                            // 清除按钮
                            Rectangle {
                                visible: searchField.text.length > 0
                                anchors.right: parent.right
                                anchors.rightMargin: 5
                                anchors.verticalCenter: parent.verticalCenter
                                width: 16
                                height: 16
                                radius: 8
                                color: Qt.rgba(0.5, 0.5, 0.5, 0.5)

                                Text {
                                    anchors.centerIn: parent
                                    text: "×"
                                    color: "white"
                                    font.pixelSize: smallFontSize
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: searchField.text = ""
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }
                    }

                    // 操作按钮区域
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        // 查询按钮
                        Button {
                            text: "查询"
                            Layout.preferredWidth: 120

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
                                // 执行查询逻辑
                                historyResultTabs.currentIndex = 0; // 切换到表格视图
                                queryData();
                            }
                        }

                        // 重置按钮
                        Button {
                            text: "重置条件"
                            Layout.preferredWidth: 120

                            contentItem: Text {
                                text: parent.text
                                color: textColor
                                font.pixelSize: fontSize
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: parent.down ? Qt.rgba(0.3, 0.3, 0.3, 1) :
                                       parent.hovered ? Qt.rgba(0.25, 0.25, 0.25, 1) : Qt.rgba(0.2, 0.2, 0.2, 1)
                                radius: 4
                            }

                            onClicked: {
                                // 重置所有条件
                                var today = new Date();
                                var weekAgo = new Date();
                                weekAgo.setDate(today.getDate() - 6);

                                startDateBtn.selectedDate = weekAgo;
                                startDateBtn.text = Qt.formatDate(weekAgo, "yyyy-MM-dd");
                                endDateBtn.selectedDate = today;
                                endDateBtn.text = Qt.formatDate(today, "yyyy-MM-dd");

                                quickDateCombo.currentIndex = 2; // 过去7天
                                dataTypeCombo.currentIndex = 0; // 全部数据
                                statusCombo.currentIndex = 0; // 全部状态
                                searchField.text = "";
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // 导出按钮
                        Button {
                            text: "导出数据"
                            Layout.preferredWidth: 120

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
                                // 导出数据逻辑
                                exportDialog.open();
                            }
                        }

                        // 高级分析按钮
                        Button {
                            text: "高级分析"
                            Layout.preferredWidth: 120

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
                                // 打开高级分析面板
                                historyResultTabs.currentIndex = 2; // 切换到分析视图
                            }
                        }
                    }
                }
            }

            // 结果视图选择标签
            TabBar {
                id: historyResultTabs
                Layout.fillWidth: true

                background: Rectangle {
                    color: Qt.rgba(0, 0, 0, 0.2)
                    radius: 4
                }

                TabButton {
                    text: "表格视图"
                    width: implicitWidth

                    contentItem: Text {
                        text: parent.text
                        color: parent.checked ? accentColor : textColor
                        font.pixelSize: fontSize
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.pressed ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2) :
                               parent.checked ? Qt.rgba(0.1, 0.1, 0.1, 0.6) : "transparent"

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            color: parent.parent.checked ? accentColor : "transparent"
                        }
                    }
                }

                TabButton {
                    text: "图表视图"
                    width: implicitWidth

                    contentItem: Text {
                        text: parent.text
                        color: parent.checked ? accentColor : textColor
                        font.pixelSize: fontSize
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.pressed ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2) :
                               parent.checked ? Qt.rgba(0.1, 0.1, 0.1, 0.6) : "transparent"

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            color: parent.parent.checked ? accentColor : "transparent"
                        }
                    }
                }

                TabButton {
                    text: "数据分析"
                    width: implicitWidth

                    contentItem: Text {
                        text: parent.text
                        color: parent.checked ? accentColor : textColor
                        font.pixelSize: fontSize
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.pressed ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2) :
                               parent.checked ? Qt.rgba(0.1, 0.1, 0.1, 0.6) : "transparent"

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            color: parent.parent.checked ? accentColor : "transparent"
                        }
                    }
                }
            }

            // 结果显示区域
            StackLayout {
                currentIndex: historyResultTabs.currentIndex
                Layout.fillWidth: true
                Layout.fillHeight: true

                // 表格视图
                Rectangle {
                    color: cardColor
                    radius: 8

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5

                        // 表格工具栏
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "共 " + historyDataModel.count + " 条记录"
                                color: textColor
                                font.pixelSize: fontSize
                            }

                            Item { Layout.fillWidth: true }

                            // 刷新按钮
                            Button {
                                implicitWidth: 80
                                implicitHeight: 28
                                text: "刷新"

                                contentItem: Text {
                                    text: parent.text
                                    color: textColor
                                    font.pixelSize: fontSize
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    color: parent.down ? Qt.rgba(0.3, 0.3, 0.3, 1) :
                                           parent.hovered ? Qt.rgba(0.25, 0.25, 0.25, 1) : Qt.rgba(0.2, 0.2, 0.2, 1)
                                    radius: 3
                                }

                                onClicked: {
                                    queryData();
                                }
                            }

                            // 排序按钮
                            ComboBox {
                                id: sortCombo
                                implicitWidth: 120
                                implicitHeight: 28
                                model: ["默认排序", "时间降序", "时间升序", "数值降序", "数值升序"]
                                currentIndex: 0

                                contentItem: Text {
                                    text: sortCombo.displayText
                                    color: textColor
                                    font.pixelSize: fontSize
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignLeft
                                    leftPadding: 8
                                }

                                background: Rectangle {
                                    color: Qt.rgba(1,1,1,0.1)
                                    radius: 3
                                }

                                onCurrentIndexChanged: {
                                    // 应用排序
                                    sortData(currentIndex);
                                }
                            }
                        }

                        // 表格头部
                        Rectangle {
                            Layout.fillWidth: true
                            height: 40
                            color: primaryColor
                            radius: 4

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 1

                                // 时间戳列头
                                TableHeader {
                                    text: "时间戳"
                                    Layout.preferredWidth: 160
                                    onClicked: {
                                        if (sortCombo.currentIndex === 1)
                                            sortCombo.currentIndex = 2;
                                        else
                                            sortCombo.currentIndex = 1;
                                    }
                                }

                                // 数据类型列头
                                TableHeader {
                                    text: "数据类型"
                                    Layout.preferredWidth: 100
                                }

                                // 传感器/参数列头
                                TableHeader {
                                    text: "传感器/参数"
                                    Layout.preferredWidth: 120
                                }

                                // 数值列头
                                TableHeader {
                                    text: "数值"
                                    Layout.preferredWidth: 100
                                    onClicked: {
                                        if (sortCombo.currentIndex === 3)
                                            sortCombo.currentIndex = 4;
                                        else
                                            sortCombo.currentIndex = 3;
                                    }
                                }

                                // 单位列头
                                TableHeader {
                                    text: "单位"
                                    Layout.preferredWidth: 80
                                }

                                // 状态列头
                                TableHeader {
                                    text: "状态"
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        // 表格内容
                        ListView {
                            id: historyDataTable
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: historyDataModel

                            // 空白提示
                            Text {
                                anchors.centerIn: parent
                                text: "无符合条件的数据记录，请修改查询条件后重试"
                                color: Qt.rgba(textColor.r, textColor.g, textColor.b, 0.5)
                                font.pixelSize: fontSize
                                visible: historyDataModel.count === 0
                            }

                            // 数据行委托
                            delegate: Rectangle {
                                width: historyDataTable.width
                                height: 40
                                color: index % 2 == 0 ? Qt.rgba(0,0,0,0.2) : "transparent"

                                // 鼠标悬停高亮
                                Rectangle {
                                    anchors.fill: parent
                                    color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.1)
                                    visible: tableRowMouseArea.containsMouse
                                }

                                MouseArea {
                                    id: tableRowMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        // 选中行处理
                                        historyDataTable.currentIndex = index;
                                    }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 1

                                    // 时间戳单元格
                                    TableCell {
                                        text: model.timestamp
                                        Layout.preferredWidth: 160
                                    }

                                    // 数据类型单元格
                                    TableCell {
                                        text: model.dataType
                                        Layout.preferredWidth: 100
                                    }

                                    // 传感器/参数单元格
                                    TableCell {
                                        text: model.parameter
                                        Layout.preferredWidth: 120
                                    }

                                    // 数值单元格
                                    TableCell {
                                        text: model.value
                                        Layout.preferredWidth: 100
                                        font.family: "Consolas, monospace"
                                    }

                                    // 单位单元格
                                    TableCell {
                                        text: model.unit
                                        Layout.preferredWidth: 80
                                    }

                                    // 状态单元格
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "transparent"

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 5
                                            spacing: 5

                                            Rectangle {
                                                width: 10
                                                height: 10
                                                radius: 5
                                                color: {
                                                    if (model.status === "正常") return successColor;
                                                    if (model.status === "警告") return warningColor;
                                                    if (model.status === "超标") return dangerColor;
                                                    return Qt.rgba(0.5, 0.5, 0.5, 1);
                                                }
                                            }

                                            Text {
                                                text: model.status
                                                color: {
                                                    if (model.status === "正常") return successColor;
                                                    if (model.status === "警告") return warningColor;
                                                    if (model.status === "超标") return dangerColor;
                                                    return textColor;
                                                }
                                                font.pixelSize: fontSize
                                                Layout.fillWidth: true
                                            }
                                        }
                                    }
                                }
                            }

                            // 滚动条
                            ScrollBar.vertical: ScrollBar {
                                active: true
                            }
                        }
                    }
                }

                // 图表视图
                Rectangle {
                    color: cardColor
                    radius: 8

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        // 图表工具栏
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "选择传感器:"
                                color: textColor
                                font.pixelSize: fontSize
                            }

                            ComboBox {
                                id: chartSensorCombo
                                Layout.preferredWidth: 150
                                model: ["CO₂", "甲醛", "TVOC", "PM2.5", "PM10", "空气温度",
                                        "湿度", "浊度", "pH值", "TDS", "水温", "液位"]
                                currentIndex: 0

                                contentItem: Text {
                                    text: chartSensorCombo.displayText
                                    color: textColor
                                    font.pixelSize: fontSize
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignLeft
                                    leftPadding: 8
                                }

                                background: Rectangle {
                                    color: Qt.rgba(1,1,1,0.1)
                                    radius: 3
                                }

                                onCurrentIndexChanged: {
                                    updateChart();
                                }
                            }

                            Text {
                                text: "图表类型:"
                                color: textColor
                                font.pixelSize: fontSize
                            }

                            ComboBox {
                                id: chartTypeSelector
                                Layout.preferredWidth: 120
                                model: ["折线图", "面积图", "柱状图", "散点图"]
                                currentIndex: 0

                                contentItem: Text {
                                    text: chartTypeSelector.displayText
                                    color: textColor
                                    font.pixelSize: fontSize
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignLeft
                                    leftPadding: 8
                                }

                                background: Rectangle {
                                    color: Qt.rgba(1,1,1,0.1)
                                    radius: 3
                                }

                                onCurrentIndexChanged: {
                                    updateChart();
                                }
                            }

                            Item { Layout.fillWidth: true }

                            // 时间范围选择器
                            ComboBox {
                                id: timeRangeCombo
                                Layout.preferredWidth: 150
                                model: ["全部时间", "按小时分组", "按天分组", "按周分组", "按月分组"]
                                currentIndex: 0

                                contentItem: Text {
                                    text: timeRangeCombo.displayText
                                    color: textColor
                                    font.pixelSize: fontSize
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignLeft
                                    leftPadding: 8
                                }

                                background: Rectangle {
                                    color: Qt.rgba(1,1,1,0.1)
                                    radius: 3
                                }

                                onCurrentIndexChanged: {
                                    updateChart();
                                }
                            }

                            // 图表重置按钮
                            Button {
                                implicitWidth: 80
                                implicitHeight: 28
                                text: "重置缩放"

                                contentItem: Text {
                                    text: parent.text
                                    color: textColor
                                    font.pixelSize: fontSize
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    color: parent.down ? Qt.rgba(0.3, 0.3, 0.3, 1) :
                                           parent.hovered ? Qt.rgba(0.25, 0.25, 0.25, 1) : Qt.rgba(0.2, 0.2, 0.2, 1)
                                    radius: 3
                                }

                                onClicked: {
                                    // 重置图表缩放
                                    if (chartTypeSelector.currentIndex === 0 || chartTypeSelector.currentIndex === 1) {
                                        // 折线图或面积图
                                        timeAxis.min = chartData[0] ? chartData[0].x : new Date(2023, 0, 1);
                                        timeAxis.max = chartData[chartData.length-1] ? chartData[chartData.length-1].x : new Date(2023, 11, 31);
                                    }
                                }
                            }
                        }

                        // 图表区域
                        ChartView {
                            id: historyChart
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            antialiasing: true
                            legend.visible: true
                            backgroundColor: "transparent"

                            // 设置图例样式
                            legend {
                                color: textColor
                                labelColor: textColor
                                alignment: Qt.AlignBottom
                                font.pixelSize: smallFontSize
                            }

                            // 日期时间轴
                            DateTimeAxis {
                                id: timeAxis
                                min: new Date(2023, 0, 1)
                                max: new Date(2023, 11, 31)
                                format: "MM-dd hh:mm"
                                tickCount: 5
                                labelsColor: textColor
                                gridLineColor: Qt.rgba(chartGridColor.r, chartGridColor.g, chartGridColor.b, 0.3)
                                color: borderColor
                                titleText: "时间"
                                titleVisible: true
                            }

                            // 数值轴
                            ValueAxis {
                                id: valueAxis
                                min: 0
                                max: 1100
                                tickCount: 6
                                labelsColor: textColor
                                gridLineColor: Qt.rgba(chartGridColor.r, chartGridColor.g, chartGridColor.b, 0.3)
                                color: borderColor
                                titleText: getSensorValueAxisTitle()
                                titleVisible: true

                                // 根据选择的传感器返回适当的Y轴标题
                                function getSensorValueAxisTitle() {
                                    var sensor = chartSensorCombo.currentText;
                                    var unit = getSensorUnit(sensor);
                                    return sensor + (unit ? " (" + unit + ")" : "");
                                }
                            }

                            // 根据选择动态创建的数据系列
                            // 在updateChart函数中实现

                            // 警戒线 (仅为有阈值的传感器显示)
                            LineSeries {
                                id: warningThresholdLine
                                axisX: timeAxis
                                axisY: valueAxis
                                color: warningColor
                                style: Qt.DashLine
                                width: 2
                                name: "警戒阈值"
                                visible: false
                            }

                            // 严重警戒线
                            LineSeries {
                                id: criticalThresholdLine
                                axisX: timeAxis
                                axisY: valueAxis
                                color: dangerColor
                                style: Qt.DashLine
                                width: 2
                                name: "严重阈值"
                                visible: false
                            }
                        }
                    }
                }

                // 数据分析视图
                Rectangle {
                    color: cardColor
                    radius: 8

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        // 分析工具栏
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                text: "分析类型:"
                                color: textColor
                                font.pixelSize: fontSize
                            }

                            ComboBox {
                                id: analysisTypeCombo
                                Layout.preferredWidth: 150
                                model: ["基本统计", "趋势分析", "异常检测", "相关性分析"]
                                currentIndex: 0

                                contentItem: Text {
                                    text: analysisTypeCombo.displayText
                                    color: textColor
                                    font.pixelSize: fontSize
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignLeft
                                    leftPadding: 8
                                }

                                background: Rectangle {
                                    color: Qt.rgba(1,1,1,0.1)
                                    radius: 3
                                }

                                onCurrentIndexChanged: {
                                    updateAnalysis();
                                }
                            }

                            Text {
                                text: "传感器:"
                                color: textColor
                                font.pixelSize: fontSize
                                visible: analysisTypeCombo.currentIndex !== 3 // 相关性分析不需要
                            }

                            ComboBox {
                                id: analysisSensorCombo
                                Layout.preferredWidth: 150
                                model: ["CO₂", "甲醛", "TVOC", "PM2.5", "PM10", "空气温度",
                                        "湿度", "浊度", "pH值", "TDS", "水温", "液位"]
                                currentIndex: 0
                                visible: analysisTypeCombo.currentIndex !== 3 // 相关性分析不需要

                                contentItem: Text {
                                    text: analysisSensorCombo.displayText
                                    color: textColor
                                    font.pixelSize: fontSize
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignLeft
                                    leftPadding: 8
                                }

                                background: Rectangle {
                                    color: Qt.rgba(1,1,1,0.1)
                                    radius: 3
                                }

                                onCurrentIndexChanged: {
                                    updateAnalysis();
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Button {
                                text: "生成报告"
                                implicitWidth: 100
                                implicitHeight: 28

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
                                    radius: 3
                                }

                                onClicked: {
                                    // 生成报告逻辑
                                    reportDialog.open();
                                }
                            }
                        }

                        // 分析内容区域
                        StackLayout {
                            currentIndex: analysisTypeCombo.currentIndex
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            // 基本统计视图
                            Rectangle {
                                color: Qt.rgba(0,0,0,0.2)
                                radius: 5

                                GridLayout {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    columnSpacing: 20
                                    rowSpacing: 20
                                    columns: 2

                                    // 统计卡片 - 基本信息
                                    AnalysisCard {
                                        title: "数据基本信息"
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        content: GridLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            columns: 2
                                            rowSpacing: 10
                                            columnSpacing: 15

                                            Text {
                                                text: "传感器类型:"
                                                font.bold: true
                                                color: textColor
                                            }

                                            Text {
                                                text: analysisSensorCombo.currentText
                                                color: textColor
                                            }

                                            Text {
                                                text: "时间范围:"
                                                font.bold: true
                                                color: textColor
                                            }

                                            Text {
                                                text: startDateBtn.text + " 至 " + endDateBtn.text
                                                color: textColor
                                            }

                                            Text {
                                                text: "数据点数量:"
                                                font.bold: true
                                                color: textColor
                                            }

                                            Text {
                                                text: "1,246"
                                                color: textColor
                                            }

                                            Text {
                                                text: "数据完整度:"
                                                font.bold: true
                                                color: textColor
                                            }

                                            RowLayout {
                                                spacing: 5

                                                Rectangle {
                                                    width: 100
                                                    height: 10
                                                    radius: 5
                                                    color: Qt.rgba(0.2, 0.2, 0.2, 1)

                                                    Rectangle {
                                                        width: parent.width * 0.95
                                                        height: parent.height
                                                        radius: 5
                                                        color: successColor
                                                    }
                                                }

                                                Text {
                                                    text: "95%"
                                                    color: textColor
                                                }
                                            }

                                            Text {
                                                text: "单位:"
                                                font.bold: true
                                                color: textColor
                                            }

                                            Text {
                                                text: getSensorUnit(analysisSensorCombo.currentText)
                                                color: textColor
                                            }
                                        }
                                    }

                                    // 统计卡片 - 统计摘要
                                    AnalysisCard {
                                        title: "统计摘要"
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        content: GridLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            columns: 4
                                            rowSpacing: 15
                                            columnSpacing: 15

                                            // 最小值
                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 80
                                                color: Qt.rgba(0,0,0,0.15)
                                                radius: 5

                                                ColumnLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: 10
                                                    spacing: 5

                                                    Text {
                                                        text: "最小值"
                                                        color: textColor
                                                        font.pixelSize: smallFontSize
                                                    }

                                                    Text {
                                                        text: "412"
                                                        color: successColor
                                                        font.bold: true
                                                        font.pixelSize: largeFontSize
                                                    }

                                                    Text {
                                                        text: getSensorUnit(analysisSensorCombo.currentText)
                                                        color: Qt.rgba(textColor.r, textColor.g, textColor.b, 0.7)
                                                        font.pixelSize: smallFontSize
                                                    }
                                                }
                                            }

                                            // 平均值
                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 80
                                                color: Qt.rgba(0,0,0,0.15)
                                                radius: 5

                                                ColumnLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: 10
                                                    spacing: 5

                                                    Text {
                                                        text: "平均值"
                                                        color: textColor
                                                        font.pixelSize: smallFontSize
                                                    }

                                                    Text {
                                                        text: "682"
                                                        color: accentColor
                                                        font.bold: true
                                                        font.pixelSize: largeFontSize
                                                    }

                                                    Text {
                                                        text: getSensorUnit(analysisSensorCombo.currentText)
                                                        color: Qt.rgba(textColor.r, textColor.g, textColor.b, 0.7)
                                                        font.pixelSize: smallFontSize
                                                    }
                                                }
                                            }

                                            // 最大值
                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 80
                                                color: Qt.rgba(0,0,0,0.15)
                                                radius: 5

                                                ColumnLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: 10
                                                    spacing: 5

                                                    Text {
                                                        text: "最大值"
                                                        color: textColor
                                                        font.pixelSize: smallFontSize
                                                    }

                                                    Text {
                                                        text: "1052"
                                                        color: dangerColor
                                                        font.bold: true
                                                        font.pixelSize: largeFontSize
                                                    }

                                                    Text {
                                                        text: getSensorUnit(analysisSensorCombo.currentText)
                                                        color: Qt.rgba(textColor.r, textColor.g, textColor.b, 0.7)
                                                        font.pixelSize: smallFontSize
                                                    }
                                                }
                                            }

                                            // 标准差
                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 80
                                                color: Qt.rgba(0,0,0,0.15)
                                                radius: 5

                                                ColumnLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: 10
                                                    spacing: 5

                                                    Text {
                                                        text: "标准差"
                                                        color: textColor
                                                        font.pixelSize: smallFontSize
                                                    }

                                                    Text {
                                                        text: "112.6"
                                                        color: warningColor
                                                        font.bold: true
                                                        font.pixelSize: largeFontSize
                                                    }

                                                    Text {
                                                        text: getSensorUnit(analysisSensorCombo.currentText)
                                                        color: Qt.rgba(textColor.r, textColor.g, textColor.b, 0.7)
                                                        font.pixelSize: smallFontSize
                                                    }
                                                }
                                            }

                                            // 值分布柱状图
                                            Rectangle {
                                                Layout.columnSpan: 4
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                color: Qt.rgba(0,0,0,0.15)
                                                radius: 5

                                                ChartView {
                                                    anchors.fill: parent
                                                    anchors.margins: 10
                                                    title: "数值分布"
                                                    antialiasing: true
                                                    legend.visible: false
                                                    backgroundColor: "transparent"

                                                    BarSeries {
                                                        axisX: BarCategoryAxis {
                                                            categories: ["<500", "500-600", "600-700", "700-800", "800-900", "900-1000", ">1000"]
                                                            labelsColor: textColor
                                                            gridLineColor: Qt.rgba(chartGridColor.r, chartGridColor.g, chartGridColor.b, 0.3)
                                                            color: borderColor
                                                        }

                                                        axisY: ValueAxis {
                                                            min: 0
                                                            max: 500
                                                            tickCount: 6
                                                            labelsColor: textColor
                                                            gridLineColor: Qt.rgba(chartGridColor.r, chartGridColor.g, chartGridColor.b, 0.3)
                                                            color: borderColor
                                                            titleText: "数据点数量"
                                                            titleVisible: true
                                                        }

                                                        BarSet {
                                                            label: "数据点"
                                                            values: [120, 180, 280, 320, 215, 85, 46]
                                                            color: accentColor
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // 统计卡片 - 超标统计
                                    AnalysisCard {
                                        title: "超标统计"
                                        Layout.columnSpan: 2
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 200

                                        content: RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 20

                                            // 饼图
                                            ChartView {
                                                Layout.preferredWidth: parent.width / 2
                                                Layout.fillHeight: true
                                                antialiasing: true
                                                legend.visible: true
                                                backgroundColor: "transparent"

                                                PieSeries {
                                                    id: pieSeries

                                                    PieSlice {
                                                        label: "正常 (76%)"
                                                        value: 76
                                                        color: successColor
                                                        labelVisible: true
                                                        labelColor: textColor
                                                    }

                                                    PieSlice {
                                                        label: "警告 (18%)"
                                                        value: 18
                                                        color: warningColor
                                                        labelVisible: true
                                                        labelColor: textColor
                                                    }

                                                    PieSlice {
                                                        label: "超标 (6%)"
                                                        value: 6
                                                        color: dangerColor
                                                        labelVisible: true
                                                        labelColor: textColor
                                                        exploded: true
                                                        explodeDistanceFactor: 0.1
                                                    }
                                                }
                                            }

                                            // 超标详情
                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                spacing: 10

                                                Text {
                                                    text: "超标情况概述"
                                                    color: textColor
                                                    font.bold: true
                                                    font.pixelSize: fontSize
                                                }

                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    color: Qt.rgba(0,0,0,0.15)
                                                    radius: 4

                                                    ColumnLayout {
                                                        anchors.fill: parent
                                                        anchors.margins: 10
                                                        spacing: 8

                                                        Text {
                                                            text: "• 数据中有<b>76%</b>处于正常范围内，低于警戒阈值(1000 ppm)"
                                                            color: textColor
                                                            font.pixelSize: smallFontSize
                                                            wrapMode: Text.WordWrap
                                                            Layout.fillWidth: true
                                                        }

                                                        Text {
                                                            text: "• 有<b>18%</b>的数据处于警告区间(1000-2000 ppm)"
                                                            color: textColor
                                                            font.pixelSize: smallFontSize
                                                            wrapMode: Text.WordWrap
                                                            Layout.fillWidth: true
                                                        }

                                                        Text {
                                                            text: "• 有<b>6%</b>的数据超过严重阈值(2000 ppm)，主要集中在11月5日13:00-15:00时段"
                                                            color: textColor
                                                            font.pixelSize: smallFontSize
                                                            wrapMode: Text.WordWrap
                                                            Layout.fillWidth: true
                                                        }

                                                        Text {
                                                            text: "• 最严重超标发生在11月5日14:23，达到<b>2243 ppm</b>"
                                                            color: textColor
                                                            font.pixelSize: smallFontSize
                                                            wrapMode: Text.WordWrap
                                                            Layout.fillWidth: true
                                                        }

                                                        Item { Layout.fillHeight: true }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // 趋势分析视图
                            Rectangle {
                                color: Qt.rgba(0,0,0,0.2)
                                radius: 5

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    spacing: 15

                                    // 趋势图表
                                    AnalysisCard {
                                        title: "数据趋势图 - " + analysisSensorCombo.currentText
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: parent.height * 0.6

                                        content: ChartView {
                                            id: trendChart
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            antialiasing: true
                                            legend.visible: true
                                            backgroundColor: "transparent"

                                            // 日期时间轴
                                            DateTimeAxis {
                                                id: trendTimeAxis
                                                min: new Date(2023, 10, 1, 0, 0)
                                                max: new Date(2023, 10, 7, 23, 59)
                                                format: "MM-dd hh:mm"
                                                tickCount: 8
                                                labelsColor: textColor
                                                gridLineColor: Qt.rgba(chartGridColor.r, chartGridColor.g, chartGridColor.b, 0.3)
                                                color: borderColor
                                                titleText: "时间"
                                                titleVisible: true
                                            }

                                            // 数值轴
                                            ValueAxis {
                                                id: trendValueAxis
                                                min: 0
                                                max: 1200
                                                tickCount: 7
                                                labelsColor: textColor
                                                gridLineColor: Qt.rgba(chartGridColor.r, chartGridColor.g, chartGridColor.b, 0.3)
                                                color: borderColor
                                                titleText: analysisSensorCombo.currentText + " (" + getSensorUnit(analysisSensorCombo.currentText) + ")"
                                                titleVisible: true
                                            }

                                            // 原始数据线
                                            LineSeries {
                                                name: "原始数据"
                                                axisX: trendTimeAxis
                                                axisY: trendValueAxis
                                                color: accentColor
                                                width: 1.5
                                                pointsVisible: false

                                                // 动态生成的示例数据点
                                                Component.onCompleted: {
                                                    generateTrendData();
                                                }
                                            }

                                            // 移动平均线
                                            LineSeries {
                                                name: "移动平均 (24小时)"
                                                axisX: trendTimeAxis
                                                axisY: trendValueAxis
                                                color: successColor
                                                width: 2.5
                                                style: Qt.SolidLine
                                                pointsVisible: false

                                                // 动态生成的平滑数据
                                                Component.onCompleted: {
                                                    generateMovingAverageData();
                                                }
                                            }

                                            // 趋势线
                                            LineSeries {
                                                name: "线性趋势"
                                                axisX: trendTimeAxis
                                                axisY: trendValueAxis
                                                color: "#E74C3C"
                                                width: 2
                                                style: Qt.DashLine
                                                pointsVisible: false

                                                // 线性趋势数据
                                                Component.onCompleted: {
                                                    generateTrendLineData();
                                                }
                                            }

                                            // 警戒阈值线
                                            LineSeries {
                                                name: "警戒阈值"
                                                axisX: trendTimeAxis
                                                axisY: trendValueAxis
                                                color: warningColor
                                                width: 1.5
                                                style: Qt.DashLine

                                                // 固定的警戒线
                                                XYPoint { x: new Date(2023, 10, 1, 0, 0).getTime(); y: 1000 }
                                                XYPoint { x: new Date(2023, 10, 7, 23, 59).getTime(); y: 1000 }
                                            }
                                        }
                                    }

                                    // 趋势分析结果
                                    AnalysisCard {
                                        title: "趋势分析结果"
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        content: GridLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            columns: 2
                                            columnSpacing: 20
                                            rowSpacing: 10

                                            // 趋势指标
                                            Column {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                spacing: 15

                                                Text {
                                                    text: "趋势指标"
                                                    color: textColor
                                                    font.bold: true
                                                    font.pixelSize: fontSize
                                                    width: parent.width
                                                }

                                                GridLayout {
                                                    width: parent.width
                                                    columns: 2
                                                    rowSpacing: 10
                                                    columnSpacing: 15

                                                    Text {
                                                        text: "趋势方向:"
                                                        font.bold: true
                                                        color: textColor
                                                    }

                                                    RowLayout {
                                                        spacing: 5

                                                        Rectangle {
                                                            width: 16
                                                            height: 16
                                                            radius: 8
                                                            color: dangerColor
                                                        }

                                                        Text {
                                                            text: "上升 (+2.3%/天)"
                                                            color: dangerColor
                                                            font.bold: true
                                                        }
                                                    }

                                                    Text {
                                                        text: "变化率:"
                                                        font.bold: true
                                                        color: textColor
                                                    }

                                                    Text {
                                                        text: "+14.8 ppm/天"
                                                        color: textColor
                                                    }

                                                    Text {
                                                        text: "周期性波动:"
                                                        font.bold: true
                                                        color: textColor
                                                    }

                                                    Text {
                                                        text: "检测到每日波动模式"
                                                        color: textColor
                                                    }

                                                    Text {
                                                        text: "波动峰值:"
                                                        font.bold: true
                                                        color: textColor
                                                    }

                                                    Text {
                                                        text: "通常在14:00-16:00"
                                                        color: textColor
                                                    }

                                                    Text {
                                                        text: "波动谷值:"
                                                        font.bold: true
                                                        color: textColor
                                                    }

                                                    Text {
                                                        text: "通常在03:00-05:00"
                                                        color: textColor
                                                    }

                                                    Text {
                                                        text: "预测信度:"
                                                        font.bold: true
                                                        color: textColor
                                                    }

                                                    RowLayout {
                                                        spacing: 5

                                                        Rectangle {
                                                            width: 80
                                                            height: 8
                                                            radius: 4
                                                            color: Qt.rgba(0.2, 0.2, 0.2, 1)

                                                            Rectangle {
                                                                width: parent.width * 0.85
                                                                height: parent.height
                                                                radius: 4
                                                                color: accentColor
                                                            }
                                                        }

                                                        Text {
                                                            text: "85%"
                                                            color: textColor
                                                        }
                                                    }
                                                }
                                            }

                                            // 趋势分析解读
                                            Column {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                spacing: 15

                                                Text {
                                                    text: "趋势解读与建议"
                                                    color: textColor
                                                    font.bold: true
                                                    font.pixelSize: fontSize
                                                    width: parent.width
                                                }

                                                Rectangle {
                                                    width: parent.width
                                                    height: parent.height - 35
                                                    color: Qt.rgba(0,0,0,0.15)
                                                    radius: 4

                                                    ColumnLayout {
                                                        anchors.fill: parent
                                                        anchors.margins: 10
                                                        spacing: 10

                                                        Text {
                                                            text: "• 数据显示<b>明显的上升趋势</b>，若继续此趋势，预计3天后将持续超过警戒阈值"
                                                            color: textColor
                                                            font.pixelSize: smallFontSize
                                                            wrapMode: Text.WordWrap
                                                            Layout.fillWidth: true
                                                        }

                                                        Text {
                                                            text: "• 检测到<b>明显的每日周期性变化</b>，峰值出现在下午(14:00-16:00)，符合典型的工作时间模式"
                                                            color: textColor
                                                            font.pixelSize: smallFontSize
                                                            wrapMode: Text.WordWrap
                                                            Layout.fillWidth: true
                                                        }

                                                        Text {
                                                            text: "• 波动幅度逐日增大，表明环境稳定性<b>正在下降</b>"
                                                            color: textColor
                                                            font.pixelSize: smallFontSize
                                                            wrapMode: Text.WordWrap
                                                            Layout.fillWidth: true
                                                        }

                                                        Text {
                                                            text: "• <b>建议</b>: 检查通风系统是否正常工作，考虑在14:00-16:00增加换气频率"
                                                            color: textColor
                                                            font.pixelSize: smallFontSize
                                                            wrapMode: Text.WordWrap
                                                            Layout.fillWidth: true
                                                        }

                                                        Text {
                                                            text: "• <b>建议</b>: 设置预警系统，当浓度达到900ppm时提前预警"
                                                            color: textColor
                                                            font.pixelSize: smallFontSize
                                                            wrapMode: Text.WordWrap
                                                            Layout.fillWidth: true
                                                        }

                                                        Item { Layout.fillHeight: true }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // 异常检测视图
                            Rectangle {
                                color: Qt.rgba(0,0,0,0.2)
                                radius: 5

                                GridLayout {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    columns: 2
                                    rowSpacing: 15
                                    columnSpacing: 20

                                    // 异常检测图表
                                    AnalysisCard {
                                        title: "异常检测 - " + analysisSensorCombo.currentText
                                        Layout.columnSpan: 2
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: parent.height * 0.5

                                        content: ChartView {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            antialiasing: true
                                            legend.visible: true
                                            backgroundColor: "transparent"

                                            // 时间轴
                                            DateTimeAxis {
                                                id: anomalyTimeAxis
                                                min: new Date(2023, 10, 1, 0, 0)
                                                max: new Date(2023, 10, 7, 23, 59)
                                                format: "MM-dd hh:mm"
                                                tickCount: 8
                                                labelsColor: textColor
                                                gridLineColor: Qt.rgba(chartGridColor.r, chartGridColor.g, chartGridColor.b, 0.3)
                                                color: borderColor
                                                titleText: "时间"
                                                titleVisible: true
                                            }

                                            // 数值轴
                                            ValueAxis {
                                                id: anomalyValueAxis
                                                min: 0
                                                max: 1200
                                                tickCount: 7
                                                labelsColor: textColor
                                                gridLineColor: Qt.rgba(chartGridColor.r, chartGridColor.g, chartGridColor.b, 0.3)
                                                color: borderColor
                                                titleText: analysisSensorCombo.currentText + " (" + getSensorUnit(analysisSensorCombo.currentText) + ")"
                                                titleVisible: true
                                            }

                                            // 原始数据线
                                            LineSeries {
                                                name: "原始数据"
                                                axisX: anomalyTimeAxis
                                                axisY: anomalyValueAxis
                                                color: accentColor
                                                width: 1.5
                                                pointsVisible: false

                                                // 使用与趋势分析相同的数据生成
                                                Component.onCompleted: {
                                                    generateAnomalyData();
                                                }
                                            }

                                            // 预期范围上边界
                                            LineSeries {
                                                name: "正常范围上限"
                                                axisX: anomalyTimeAxis
                                                axisY: anomalyValueAxis
                                                color: successColor
                                                width: 1
                                                style: Qt.DashLine

                                                // 动态生成的上限
                                                Component.onCompleted: {
                                                    generateUpperBoundData();
                                                }
                                            }

                                            // 预期范围下边界
                                            LineSeries {
                                                name: "正常范围下限"
                                                axisX: anomalyTimeAxis
                                                axisY: anomalyValueAxis
                                                color: successColor
                                                width: 1
                                                style: Qt.DashLine

                                                // 动态生成的下限
                                                Component.onCompleted: {
                                                    generateLowerBoundData();
                                                }
                                            }

                                            // 异常点
                                            ScatterSeries {
                                                name: "检测到的异常"
                                                axisX: anomalyTimeAxis
                                                axisY: anomalyValueAxis
                                                color: dangerColor
                                                markerSize: 12

                                                // 预设的异常点
                                                XYPoint { x: new Date(2023, 10, 2, 15, 45).getTime(); y: 1102 }
                                                XYPoint { x: new Date(2023, 10, 4, 9, 30).getTime(); y: 342 }
                                                XYPoint { x: new Date(2023, 10, 5, 14, 23).getTime(); y: 1198 }
                                                XYPoint { x: new Date(2023, 10, 6, 21, 10).getTime(); y: 978 }
                                            }
                                        }
                                    }

                                    // 异常统计卡片
                                    AnalysisCard {
                                        title: "异常统计"
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        content: ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 15

                                            // 异常概述
                                            GridLayout {
                                                Layout.fillWidth: true
                                                columns: 2
                                                rowSpacing: 8
                                                columnSpacing: 15

                                                Text {
                                                    text: "检测到的异常:"
                                                    font.bold: true
                                                    color: textColor
                                                }

                                                Text {
                                                    text: "4个"
                                                    color: textColor
                                                }

                                                Text {
                                                    text: "异常率:"
                                                    font.bold: true
                                                    color: textColor
                                                }

                                                Text {
                                                    text: "0.32%"
                                                    color: textColor
                                                }

                                                Text {
                                                    text: "最严重异常:"
                                                    font.bold: true
                                                    color: textColor
                                                }

                                                Text {
                                                    text: "11月5日 14:23 (1198 ppm)"
                                                    color: dangerColor
                                                }

                                                Text {
                                                    text: "检测算法:"
                                                    font.bold: true
                                                    color: textColor
                                                }

                                                Text {
                                                    text: "季节性分解+IQR"
                                                    color: textColor
                                                }

                                                Text {
                                                    text: "置信度:"
                                                    font.bold: true
                                                    color: textColor
                                                }

                                                RowLayout {
                                                    spacing: 5

                                                    Rectangle {
                                                        width: 80
                                                        height: 8
                                                        radius: 4
                                                        color: Qt.rgba(0.2, 0.2, 0.2, 1)

                                                        Rectangle {
                                                            width: parent.width * 0.92
                                                            height: parent.height
                                                            radius: 4
                                                            color: accentColor
                                                        }
                                                    }

                                                    Text {
                                                        text: "92%"
                                                        color: textColor
                                                    }
                                                }
                                            }

                                            // 异常列表
                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                color: Qt.rgba(0,0,0,0.15)
                                                radius: 4

                                                ListView {
                                                    anchors.fill: parent
                                                    anchors.margins: 5
                                                    model: 4
                                                    clip: true

                                                    delegate: Rectangle {
                                                        width: parent.width
                                                        height: 60
                                                        color: index % 2 ? Qt.rgba(0,0,0,0.1) : "transparent"
                                                        radius: 3

                                                        RowLayout {
                                                            anchors.fill: parent
                                                            anchors.margins: 5
                                                            spacing: 10

                                                            // 警告图标
                                                            Rectangle {
                                                                width: 24
                                                                height: 24
                                                                radius: 12
                                                                color: dangerColor

                                                                Text {
                                                                    anchors.centerIn: parent
                                                                    text: "!"
                                                                    color: "white"
                                                                    font.bold: true
                                                                }
                                                            }

                                                            // 异常信息
                                                            ColumnLayout {
                                                                Layout.fillWidth: true
                                                                spacing: 2

                                                                Text {
                                                                    text: {
                                                                        if (index === 0) return "11月5日 14:23 - 数值异常高 (1198 ppm)";
                                                                        if (index === 1) return "11月6日 21:10 - 超出预期模式 (978 ppm)";
                                                                        if (index === 2) return "11月2日 15:45 - 数值异常高 (1102 ppm)";
                                                                        return "11月4日 9:30 - 数值异常低 (342 ppm)";
                                                                    }
                                                                    color: textColor
                                                                    font.pixelSize: fontSize
                                                                }

                                                                Text {
                                                                    text: {
                                                                        if (index === 0) return "偏离预期: +45.3%, 可能原因: 通风系统故障";
                                                                        if (index === 1) return "偏离预期: +22.8%, 可能原因: 非工作时间活动";
                                                                        if (index === 2) return "偏离预期: +38.2%, 可能原因: 人员密度异常";
                                                                        return "偏离预期: -48.7%, 可能原因: 传感器故障或校准错误";
                                                                    }
                                                                    color: Qt.rgba(textColor.r, textColor.g, textColor.b, 0.7)
                                                                    font.pixelSize: smallFontSize
                                                                }
                                                            }

                                                            // 置信度
                                                            Text {
                                                                text: {
                                                                    if (index === 0) return "98%";
                                                                    if (index === 1) return "85%";
                                                                    if (index === 2) return "95%";
                                                                    return "92%";
                                                                }
                                                                color: accentColor
                                                                font.bold: true
                                                            }
                                                        }
                                                    }

                                                    // 滚动条
                                                    ScrollBar.vertical: ScrollBar {
                                                        active: true
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // 异常解读卡片
                                    AnalysisCard {
                                        title: "异常解读与建议"
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        content: Rectangle {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            color: Qt.rgba(0,0,0,0.15)
                                            radius: 4

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 10
                                                spacing: 10

                                                Text {
                                                    text: "• 检测到的异常点主要分为<b>异常高值</b>和<b>异常低值</b>两类"
                                                    color: textColor
                                                    font.pixelSize: smallFontSize
                                                    wrapMode: Text.WordWrap
                                                    Layout.fillWidth: true
                                                }

                                                Text {
                                                    text: "• 异常高值主要出现在<b>工作日的下午时段</b>，可能与人员活动和空间利用相关"
                                                    color: textColor
                                                    font.pixelSize: smallFontSize
                                                    wrapMode: Text.WordWrap
                                                    Layout.fillWidth: true
                                                }

                                                Text {
                                                    text: "• 异常低值(11月4日)可能是<b>传感器故障</b>或校准问题，建议检查传感器"
                                                    color: textColor
                                                    font.pixelSize: smallFontSize
                                                    wrapMode: Text.WordWrap
                                                    Layout.fillWidth: true
                                                }

                                                Text {
                                                    text: "• <b>建议</b>: 对异常高发时段进行实地考察，确认可能的环境因素"
                                                    color: textColor
                                                    font.pixelSize: smallFontSize
                                                    wrapMode: Text.WordWrap
                                                    Layout.fillWidth: true
                                                }

                                                Text {
                                                    text: "• <b>建议</b>: 检查并校准CO₂传感器，排除设备故障可能"
                                                    color: textColor
                                                    font.pixelSize: smallFontSize
                                                    wrapMode: Text.WordWrap
                                                    Layout.fillWidth: true
                                                }

                                                Text {
                                                    text: "• <b>建议</b>: 考虑增加11月5日14:00-15:00的异常高值时段的采样频率"
                                                    color: textColor
                                                    font.pixelSize: smallFontSize
                                                    wrapMode: Text.WordWrap
                                                    Layout.fillWidth: true
                                                }

                                                Item { Layout.fillHeight: true }
                                            }
                                        }
                                    }
                                }
                            }

                            // 相关性分析视图
                            Rectangle {
                                color: Qt.rgba(0,0,0,0.2)
                                radius: 5

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    spacing: 15

                                    // 相关性选择控件
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            text: "选择传感器对比:"
                                            color: textColor
                                            font.pixelSize: fontSize
                                        }

                                        ComboBox {
                                            id: sensor1Combo
                                            Layout.preferredWidth: 120
                                            model: ["CO₂", "甲醛", "TVOC", "PM2.5", "PM10", "空气温度",
                                                    "湿度", "浊度", "pH值", "TDS", "水温", "液位"]
                                            currentIndex: 0

                                            contentItem: Text {
                                                text: sensor1Combo.displayText
                                                color: textColor
                                                font.pixelSize: fontSize
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignLeft
                                                leftPadding: 8
                                            }

                                            background: Rectangle {
                                                color: Qt.rgba(1,1,1,0.1)
                                                radius: 3
                                            }

                                            onCurrentIndexChanged: {
                                                updateCorrelationAnalysis();
                                            }
                                        }

                                        Text {
                                            text: "vs"
                                            color: textColor
                                            font.pixelSize: fontSize
                                            font.bold: true
                                        }

                                        ComboBox {
                                            id: sensor2Combo
                                            Layout.preferredWidth: 120
                                            model: ["CO₂", "甲醛", "TVOC", "PM2.5", "PM10", "空气温度",
                                                    "湿度", "浊度", "pH值", "TDS", "水温", "液位"]
                                            currentIndex: 5

                                            contentItem: Text {
                                                text: sensor2Combo.displayText
                                                color: textColor
                                                font.pixelSize: fontSize
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignLeft
                                                leftPadding: 8
                                            }

                                            background: Rectangle {
                                                color: Qt.rgba(1,1,1,0.1)
                                                radius: 3
                                            }

                                            onCurrentIndexChanged: {
                                                updateCorrelationAnalysis();
                                            }
                                        }

                                        Item { Layout.fillWidth: true }

                                        // 相关性计算方法
                                        Text {
                                            text: "相关性方法:"
                                            color: textColor
                                            font.pixelSize: fontSize
                                        }

                                        ComboBox {
                                            id: correlationMethodCombo
                                            Layout.preferredWidth: 150
                                            model: ["皮尔逊相关系数", "斯皮尔曼等级相关", "肯德尔秩相关"]
                                            currentIndex: 0

                                            contentItem: Text {
                                                text: correlationMethodCombo.displayText
                                                color: textColor
                                                font.pixelSize: fontSize
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignLeft
                                                leftPadding: 8
                                            }

                                            background: Rectangle {
                                                color: Qt.rgba(1,1,1,0.1)
                                                radius: 3
                                            }

                                            onCurrentIndexChanged: {
                                                updateCorrelationAnalysis();
                                            }
                                        }
                                    }

                                    // 散点图
                                    AnalysisCard {
                                        title: "相关性散点图"
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: parent.height * 0.45

                                        content: ChartView {
                                            id: correlationChart
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            antialiasing: true
                                            legend.visible: false
                                            backgroundColor: "transparent"

                                            ValueAxis {
                                                id: xCorrelationAxis
                                                min: 300
                                                max: 1200
                                                tickCount: 7
                                                labelsColor: textColor
                                                gridLineColor: Qt.rgba(chartGridColor.r, chartGridColor.g, chartGridColor.b, 0.3)
                                                color: borderColor
                                                titleText: sensor1Combo.currentText + " (" + getSensorUnit(sensor1Combo.currentText) + ")"
                                                titleVisible: true
                                            }

                                            ValueAxis {
                                                id: yCorrelationAxis
                                                min: 18
                                                max: 30
                                                tickCount: 7
                                                labelsColor: textColor
                                                gridLineColor: Qt.rgba(chartGridColor.r, chartGridColor.g, chartGridColor.b, 0.3)
                                                color: borderColor
                                                titleText: sensor2Combo.currentText + " (" + getSensorUnit(sensor2Combo.currentText) + ")"
                                                titleVisible: true
                                            }

                                            // 散点图数据
                                            ScatterSeries {
                                                id: correlationScatter
                                                name: "数据点"
                                                axisX: xCorrelationAxis
                                                axisY: yCorrelationAxis
                                                markerSize: 8
                                                borderWidth: 0
                                                color: accentColor

                                                // 在组件加载时生成散点数据
                                                Component.onCompleted: {
                                                    generateCorrelationData();
                                                }
                                            }

                                            // 趋势线
                                            LineSeries {
                                                id: correlationTrendLine
                                                axisX: xCorrelationAxis
                                                axisY: yCorrelationAxis
                                                color: dangerColor
                                                width: 2

                                                // 在组件加载时生成趋势线
                                                Component.onCompleted: {
                                                    generateCorrelationTrendLine();
                                                }
                                            }
                                        }
                                    }

                                    // 相关性结果
                                    GridLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        columns: 2
                                        rowSpacing: 15
                                        columnSpacing: 20

                                        // 相关性指标
                                        AnalysisCard {
                                            title: "相关性指标"
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            content: ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 10
                                                spacing: 15

                                                // 相关系数显示
                                                Rectangle {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 80
                                                    color: Qt.rgba(0,0,0,0.15)
                                                    radius: 5

                                                    ColumnLayout {
                                                        anchors.centerIn: parent
                                                        spacing: 5

                                                        Text {
                                                            text: "相关系数 (Pearson's r)"
                                                            color: textColor
                                                            font.pixelSize: fontSize
                                                            horizontalAlignment: Text.AlignHCenter
                                                            Layout.alignment: Qt.AlignHCenter
                                                        }

                                                        Text {
                                                            id: correlationValueText
                                                            text: "+0.74"
                                                            color: accentColor
                                                            font.bold: true
                                                            font.pixelSize: 32
                                                            horizontalAlignment: Text.AlignHCenter
                                                            Layout.alignment: Qt.AlignHCenter
                                                        }

                                                        Text {
                                                            text: "强正相关"
                                                            color: textColor
                                                            font.pixelSize: fontSize
                                                            horizontalAlignment: Text.AlignHCenter
                                                            Layout.alignment: Qt.AlignHCenter
                                                        }
                                                    }
                                                }

                                                // 其他指标
                                                GridLayout {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    columns: 2
                                                    rowSpacing: 10
                                                    columnSpacing: 15

                                                    Text {
                                                        text: "显著性 (p值):"
                                                        font.bold: true
                                                        color: textColor
                                                    }

                                                    Text {
                                                        text: "p < 0.001 (高度显著)"
                                                        color: successColor
                                                    }

                                                    Text {
                                                        text: "决定系数 (R²):"
                                                        font.bold: true
                                                        color: textColor
                                                    }

                                                    Text {
                                                        text: "0.55"
                                                        color: textColor
                                                    }

                                                    Text {
                                                        text: "回归方程:"
                                                        font.bold: true
                                                        color: textColor
                                                    }

                                                    Text {
                                                        text: "Y = 0.012X + 14.82"
                                                        color: textColor
                                                        font.family: "Consolas, monospace"
                                                    }

                                                    Text {
                                                        text: "样本数:"
                                                        font.bold: true
                                                        color: textColor
                                                    }

                                                    Text {
                                                        text: "1,246"
                                                        color: textColor
                                                    }
                                                }
                                            }
                                        }

                                        // 相关性解读
                                        AnalysisCard {
                                            title: "相关性解读"
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            content: Rectangle {
                                                anchors.fill: parent
                                                anchors.margins: 10
                                                color: Qt.rgba(0,0,0,0.15)
                                                radius: 4

                                                ColumnLayout {
                                                    anchors.fill: parent
                                                    anchors.margins: 10
                                                    spacing: 10

                                                    Text {
                                                        text: "• CO₂与空气温度显示<b>强正相关(r = +0.74)</b>，表明两者有显著关联"
                                                        color: textColor
                                                        font.pixelSize: smallFontSize
                                                        wrapMode: Text.WordWrap
                                                        Layout.fillWidth: true
                                                    }

                                                    Text {
                                                        text: "• 相关性<b>高度显著</b> (p < 0.001)，证明此关联不是随机发生的"
                                                        color: textColor
                                                        font.pixelSize: smallFontSize
                                                        wrapMode: Text.WordWrap
                                                        Layout.fillWidth: true
                                                    }

                                                    Text {
                                                        text: "• R² = 0.55表示CO₂浓度变化可解释约<b>55%</b>的空气温度变化"
                                                        color: textColor
                                                        font.pixelSize: smallFontSize
                                                        wrapMode: Text.WordWrap
                                                        Layout.fillWidth: true
                                                    }

                                                    Text {
                                                        text: "• 关联可能反映了<b>人类活动</b>同时影响两个参数：人员活动增加了CO₂排放并提高了室内温度"
                                                        color: textColor
                                                        font.pixelSize: smallFontSize
                                                        wrapMode: Text.WordWrap
                                                        Layout.fillWidth: true
                                                    }

                                                    Text {
                                                        text: "• <b>建议</b>: 考虑温度作为CO₂浓度变化的辅助指标，或将两者结合用于环境质量评估"
                                                        color: textColor
                                                        font.pixelSize: smallFontSize
                                                        wrapMode: Text.WordWrap
                                                        Layout.fillWidth: true
                                                    }

                                                    Text {
                                                        text: "• <b>建议</b>: 进一步调查是否存在共同的外部因素同时影响这两个参数"
                                                        color: textColor
                                                        font.pixelSize: smallFontSize
                                                        wrapMode: Text.WordWrap
                                                        Layout.fillWidth: true
                                                    }

                                                    Item { Layout.fillHeight: true }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // 日期选择日历弹出框
    Popup {
        id: calendarPopup
        width: 300
        height: 350
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property var target: null
        property date selectedDate: new Date()

        background: Rectangle {
            color: darkColor
            radius: 8
            border.color: borderColor
            border.width: 1
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            // 日历标题
            Text {
                text: "选择日期"
                color: textColor
                font.pixelSize: fontSize
                font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            // 日历控件
            // Calendar {
            //     id: calendar
            //     Layout.fillWidth: true
            //     Layout.fillHeight: true
            //     selectedDate: calendarPopup.selectedDate

            //     // 样式定制
            //     dayOfWeekFormat: Grid.AlphabeticalShort

            //     // 日头
            //     dayDelegate: Rectangle {
            //         color: {
            //             if (model.date.getTime() === calendar.selectedDate.getTime()) {
            //                 return accentColor;
            //             } else if (model.today) {
            //                 return Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3);
            //             } else {
            //                 return "transparent";
            //             }
            //         }

            //         border.color: model.today ? accentColor : "transparent"
            //         radius: 4

            //         Text {
            //             text: model.day
            //             anchors.centerIn: parent
            //             color: {
            //                 if (model.date.getTime() === calendar.selectedDate.getTime()) {
            //                     return "white";
            //                 } else if (model.month === calendar.visibleMonth) {
            //                     return textColor;
            //                 } else {
            //                     return Qt.rgba(textColor.r, textColor.g, textColor.b, 0.4);
            //                 }
            //             }
            //             font.bold: model.today || model.date.getTime() === calendar.selectedDate.getTime()
            //         }
            //     }

            //     // 周头样式
            //     dayOfWeekDelegate: Rectangle {
            //         color: "transparent"
            //         height: 30

            //         Text {
            //             text: model.shortName
            //             color: textColor
            //             anchors.centerIn: parent
            //             font.bold: true
            //         }
            //     }

            //     // 月份视图标题
            //     navigationBar: Rectangle {
            //         color: "transparent"
            //         height: 40

            //         RowLayout {
            //             anchors.fill: parent

            //             // 前一月按钮
            //             Button {
            //                 text: "<"
            //                 Layout.preferredWidth: 40

            //                 contentItem: Text {
            //                     text: parent.text
            //                     color: textColor
            //                     font.pixelSize: fontSize
            //                     horizontalAlignment: Text.AlignHCenter
            //                     verticalAlignment: Text.AlignVCenter
            //                 }

            //                 background: Rectangle {
            //                     color: parent.down ? Qt.rgba(0.3, 0.3, 0.3, 1) :
            //                            parent.hovered ? Qt.rgba(0.25, 0.25, 0.25, 1) : "transparent"
            //                     radius: 4
            //                 }

            //                 onClicked: calendar.showPreviousMonth()
            //             }

            //             // 月份标题
            //             Text {
            //                 text: calendar.visibleMonth + "月 " + calendar.visibleYear
            //                 color: textColor
            //                 font.bold: true
            //                 font.pixelSize: fontSize
            //                 Layout.fillWidth: true
            //                 horizontalAlignment: Text.AlignHCenter
            //             }

            //             // 下一月按钮
            //             Button {
            //                 text: ">"
            //                 Layout.preferredWidth: 40

            //                 contentItem: Text {
            //                     text: parent.text
            //                     color: textColor
            //                     font.pixelSize: fontSize
            //                     horizontalAlignment: Text.AlignHCenter
            //                     verticalAlignment: Text.AlignVCenter
            //                 }

            //                 background: Rectangle {
            //                     color: parent.down ? Qt.rgba(0.3, 0.3, 0.3, 1) :
            //                            parent.hovered ? Qt.rgba(0.25, 0.25, 0.25, 1) : "transparent"
            //                     radius: 4
            //                 }

            //                 onClicked: calendar.showNextMonth()
            //             }
            //         }
            //     }
            // }

            // 按钮区域
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item { Layout.fillWidth: true }

                // 当前日期按钮
                Button {
                    text: "今天"

                    contentItem: Text {
                        text: parent.text
                        color: textColor
                        font.pixelSize: fontSize
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.down ? Qt.rgba(0.3, 0.3, 0.3, 1) :
                               parent.hovered ? Qt.rgba(0.25, 0.25, 0.25, 1) : Qt.rgba(0.2, 0.2, 0.2, 1)
                        radius: 4
                    }

                    onClicked: {
                        calendar.selectedDate = new Date();
                    }
                }

                // 确认按钮
                Button {
                    text: "确定"

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
                        // 更新目标按钮的日期
                        if (calendarPopup.target) {
                            calendarPopup.target.selectedDate = calendar.selectedDate;
                            calendarPopup.target.text = Qt.formatDate(calendar.selectedDate, "yyyy-MM-dd");

                            // 设置自定义日期选项
                            quickDateCombo.currentIndex = 6; // 自定义
                        }
                        calendarPopup.close();
                    }
                }

                // 取消按钮
                Button {
                    text: "取消"

                    contentItem: Text {
                        text: parent.text
                        color: textColor
                        font.pixelSize: fontSize
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.down ? Qt.rgba(0.3, 0.3, 0.3, 1) :
                               parent.hovered ? Qt.rgba(0.25, 0.25, 0.25, 1) : Qt.rgba(0.2, 0.2, 0.2, 1)
                        radius: 4
                    }

                    onClicked: {
                        calendarPopup.close();
                    }
                }
            }
        }
    }

    // 导出对话框
    Dialog {
        id: exportDialog
        title: "导出数据"
        width: 400
        height: 300
        // modal: true

        // background: Rectangle {
        //     color: darkColor
        //     radius: 8
        //     border.color: borderColor
        //     border.width: 1
        // }

        // header: Rectangle {
        //     color: primaryColor
        //     height: 40
        //     radius: 8

        //     // 只有顶部圆角
        //     Rectangle {
        //         color: primaryColor
        //         anchors.bottom: parent.bottom
        //         anchors.left: parent.left
        //         anchors.right: parent.right
        //         height: parent.height / 2
        //     }

        //     RowLayout {
        //         anchors.fill: parent
        //         anchors.leftMargin: 15
        //         anchors.rightMargin: 15

        //         Text {
        //             text: exportDialog.title
        //             color: textColor
        //             font.pixelSize: fontSize
        //             font.bold: true
        //         }

        //         Item { Layout.fillWidth: true }

        //         Button {
        //             text: "×"
        //             flat: true
        //             onClicked: exportDialog.close()

        //             contentItem: Text {
        //                 text: parent.text
        //                 color: textColor
        //                 font.pixelSize: largeFontSize
        //                 horizontalAlignment: Text.AlignHCenter
        //                 verticalAlignment: Text.AlignVCenter
        //             }

        //             background: Rectangle {
        //                 color: parent.hovered ? Qt.rgba(1,1,1,0.1) : "transparent"
        //                 radius: 4
        //             }
        //         }
        //     }
        // }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15

            Text {
                text: "请选择导出选项："
                color: textColor
                font.pixelSize: fontSize
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 10
                columnSpacing: 15

                Text {
                    text: "导出格式:"
                    color: textColor
                    font.pixelSize: fontSize
                }

                ComboBox {
                    id: exportFormatCombo
                    Layout.fillWidth: true
                    model: ["CSV格式 (.csv)", "Excel格式 (.xlsx)", "JSON格式 (.json)"]
                    currentIndex: 0

                    contentItem: Text {
                        text: exportFormatCombo.displayText
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
                    text: "导出范围:"
                    color: textColor
                    font.pixelSize: fontSize
                }

                ComboBox {
                    id: exportRangeCombo
                    Layout.fillWidth: true
                    model: ["当前查询结果", "包含图表数据", "全部历史数据"]
                    currentIndex: 0

                    contentItem: Text {
                        text: exportRangeCombo.displayText
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
                    text: "包含字段:"
                    color: textColor
                    font.pixelSize: fontSize
                    Layout.alignment: Qt.AlignTop
                }

                Column {
                    Layout.fillWidth: true
                    spacing: 5

                    CheckBox {
                        id: includeTimestampCheck
                        text: "时间戳"
                        checked: true

                        indicator: Rectangle {
                            width: 20
                            height: 20
                            radius: 4
                            border.color: includeTimestampCheck.checked ? accentColor : borderColor
                            border.width: 1
                            color: "transparent"

                            Rectangle {
                                anchors.centerIn: parent
                                width: 12
                                height: 12
                                radius: 2
                                color: accentColor
                                visible: includeTimestampCheck.checked
                            }
                        }

                        contentItem: Text {
                            text: includeTimestampCheck.text
                            color: textColor
                            font.pixelSize: fontSize
                            leftPadding: includeTimestampCheck.indicator.width + 8
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    CheckBox {
                        id: includeValueCheck
                        text: "数值和单位"
                        checked: true

                        indicator: Rectangle {
                            width: 20
                            height: 20
                            radius: 4
                            border.color: includeValueCheck.checked ? accentColor : borderColor
                            border.width: 1
                            color: "transparent"

                            Rectangle {
                                anchors.centerIn: parent
                                width: 12
                                height: 12
                                radius: 2
                                color: accentColor
                                visible: includeValueCheck.checked
                            }
                        }

                        contentItem: Text {
                            text: includeValueCheck.text
                            color: textColor
                            font.pixelSize: fontSize
                            leftPadding: includeValueCheck.indicator.width + 8
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    CheckBox {
                        id: includeStatusCheck
                        text: "状态信息"
                        checked: true

                        indicator: Rectangle {
                            width: 20
                            height: 20
                            radius: 4
                            border.color: includeStatusCheck.checked ? accentColor : borderColor
                            border.width: 1
                            color: "transparent"

                            Rectangle {
                                anchors.centerIn: parent
                                width: 12
                                height: 12
                                radius: 2
                                color: accentColor
                                visible: includeStatusCheck.checked
                            }
                        }

                        contentItem: Text {
                            text: includeStatusCheck.text
                            color: textColor
                            font.pixelSize: fontSize
                            leftPadding: includeStatusCheck.indicator.width + 8
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    CheckBox {
                        id: includeMetadataCheck
                        text: "元数据和附加信息"
                        checked: false

                        indicator: Rectangle {
                            width: 20
                            height: 20
                            radius: 4
                            border.color: includeMetadataCheck.checked ? accentColor : borderColor
                            border.width: 1
                            color: "transparent"

                            Rectangle {
                                anchors.centerIn: parent
                                width: 12
                                height: 12
                                radius: 2
                                color: accentColor
                                visible: includeMetadataCheck.checked
                            }
                        }

                        contentItem: Text {
                            text: includeMetadataCheck.text
                            color: textColor
                            font.pixelSize: fontSize
                            leftPadding: includeMetadataCheck.indicator.width + 8
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    id: exportCancelButton
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
                        color: parent.down ? Qt.rgba(0.3, 0.3, 0.3, 1) :
                               parent.hovered ? Qt.rgba(0.25, 0.25, 0.25, 1) : Qt.rgba(0.2, 0.2, 0.2, 1)
                        radius: 4
                    }

                    onClicked: {
                        exportDialog.close();
                    }
                }

                Item { Layout.fillWidth: true }

                Button {
                    id: exportConfirmButton
                    text: "导出"
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
                        // 导出数据
                        exportDialog.close();
                        exportData();
                    }
                }
            }
        }
    }

    // 报告生成对话框
    Dialog {
        id: reportDialog
        title: "生成分析报告"
        width: 400
        height: 350
        // modal: true

        // background: Rectangle {
        //     color: darkColor
        //     radius: 8
        //     border.color: borderColor
        //     border.width: 1
        // }

        // header: Rectangle {
        //     color: primaryColor
        //     height: 40
        //     radius: 8

        //     // 只有顶部圆角
        //     Rectangle {
        //         color: primaryColor
        //         anchors.bottom: parent.bottom
        //         anchors.left: parent.left
        //         anchors.right: parent.right
        //         height: parent.height / 2
        //     }

        //     RowLayout {
        //         anchors.fill: parent
        //         anchors.leftMargin: 15
        //         anchors.rightMargin: 15

        //         Text {
        //             text: reportDialog.title
        //             color: textColor
        //             font.pixelSize: fontSize
        //             font.bold: true
        //         }

        //         Item { Layout.fillWidth: true }

        //         Button {
        //             text: "×"
        //             flat: true
        //             onClicked: reportDialog.close()

        //             contentItem: Text {
        //                 text: parent.text
        //                 color: textColor
        //                 font.pixelSize: largeFontSize
        //                 horizontalAlignment: Text.AlignHCenter
        //                 verticalAlignment: Text.AlignVCenter
        //             }

        //             background: Rectangle {
        //                 color: parent.hovered ? Qt.rgba(1,1,1,0.1) : "transparent"
        //                 radius: 4
        //             }
        //         }
        //     }
        // }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15

            Text {
                text: "请选择报告选项："
                color: textColor
                font.pixelSize: fontSize
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 10
                columnSpacing: 15

                Text {
                    text: "报告格式:"
                    color: textColor
                    font.pixelSize: fontSize
                }

                ComboBox {
                    id: reportFormatCombo
                    Layout.fillWidth: true
                    model: ["PDF报告 (.pdf)", "Word文档 (.docx)", "HTML报告 (.html)"]
                    currentIndex: 0

                    contentItem: Text {
                        text: reportFormatCombo.displayText
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
                    text: "报告内容:"
                    color: textColor
                    font.pixelSize: fontSize
                }

                ComboBox {
                    id: reportContentCombo
                    Layout.fillWidth: true
                    model: ["当前分析结果", "数据综合分析", "完整传感器报告"]
                    currentIndex: 0

                    contentItem: Text {
                        text: reportContentCombo.displayText
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
                    text: "报告选项:"
                    color: textColor
                    font.pixelSize: fontSize
                    Layout.alignment: Qt.AlignTop
                }

                Column {
                    Layout.fillWidth: true
                    spacing: 5

                    CheckBox {
                        id: includeChartCheck
                        text: "包含图表"
                        checked: true

                        indicator: Rectangle {
                            width: 20
                            height: 20
                            radius: 4
                            border.color: includeChartCheck.checked ? accentColor : borderColor
                            border.width: 1
                            color: "transparent"

                            Rectangle {
                                anchors.centerIn: parent
                                width: 12
                                height: 12
                                radius: 2
                                color: accentColor
                                visible: includeChartCheck.checked
                            }
                        }

                        contentItem: Text {
                            text: includeChartCheck.text
                            color: textColor
                            font.pixelSize: fontSize
                            leftPadding: includeChartCheck.indicator.width + 8
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    CheckBox {
                        id: includeAnalysisCheck
                        text: "包含分析解读"
                        checked: true

                        indicator: Rectangle {
                            width: 20
                            height: 20
                            radius: 4
                            border.color: includeAnalysisCheck.checked ? accentColor : borderColor
                            border.width: 1
                            color: "transparent"

                            Rectangle {
                                anchors.centerIn: parent
                                width: 12
                                height: 12
                                radius: 2
                                color: accentColor
                                visible: includeAnalysisCheck.checked
                            }
                        }

                        contentItem: Text {
                            text: includeAnalysisCheck.text
                            color: textColor
                            font.pixelSize: fontSize
                            leftPadding: includeAnalysisCheck.indicator.width + 8
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    CheckBox {
                        id: includeRecommendationCheck
                        text: "包含建议措施"
                        checked: true

                        indicator: Rectangle {
                            width: 20
                            height: 20
                            radius: 4
                            border.color: includeRecommendationCheck.checked ? accentColor : borderColor
                            border.width: 1
                            color: "transparent"

                            Rectangle {
                                anchors.centerIn: parent
                                width: 12
                                height: 12
                                radius: 2
                                color: accentColor
                                visible: includeRecommendationCheck.checked
                            }
                        }

                        contentItem: Text {
                            text: includeRecommendationCheck.text
                            color: textColor
                            font.pixelSize: fontSize
                            leftPadding: includeRecommendationCheck.indicator.width + 8
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    CheckBox {
                        id: includeRawDataCheck
                        text: "附加原始数据"
                        checked: false

                        indicator: Rectangle {
                            width: 20
                            height: 20
                            radius: 4
                            border.color: includeRawDataCheck.checked ? accentColor : borderColor
                            border.width: 1
                            color: "transparent"

                            Rectangle {
                                anchors.centerIn: parent
                                width: 12
                                height: 12
                                radius: 2
                                color: accentColor
                                visible: includeRawDataCheck.checked
                            }
                        }

                        contentItem: Text {
                            text: includeRawDataCheck.text
                            color: textColor
                            font.pixelSize: fontSize
                            leftPadding: includeRawDataCheck.indicator.width + 8
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Text {
                    text: "报告标题:"
                    color: textColor
                    font.pixelSize: fontSize
                }

                TextField {
                    id: reportTitleField
                    Layout.fillWidth: true
                    placeholderText: "输入报告标题..."
                    text: "环境传感器数据分析报告 - " + Qt.formatDate(new Date(), "yyyy-MM-dd")
                    color: textColor
                    font.pixelSize: fontSize

                    background: Rectangle {
                        color: Qt.rgba(1,1,1,0.1)
                        radius: 4
                        border.color: reportTitleField.activeFocus ? accentColor : borderColor
                        border.width: 1
                    }
                }
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    id: reportCancelButton
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
                        color: parent.down ? Qt.rgba(0.3, 0.3, 0.3, 1) :
                               parent.hovered ? Qt.rgba(0.25, 0.25, 0.25, 1) : Qt.rgba(0.2, 0.2, 0.2, 1)
                        radius: 4
                    }

                    onClicked: {
                        reportDialog.close();
                    }
                }

                Item { Layout.fillWidth: true }

                Button {
                    id: reportGenerateButton
                    text: "生成报告"
                    Layout.preferredWidth: 120

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
                        // 生成报告
                        reportDialog.close();
                        generateReport();
                    }
                }
            }
        }
    }

    // ========== 数据与辅助函数 ==========

    // 数据模型
    ListModel {
        id: historyDataModel

        // 示例数据
        Component.onCompleted: {
            addExampleData();
        }
    }

    // 图表数据数组
    property var chartData: []

    // 添加示例数据
    function addExampleData() {
        // 清空现有数据
        historyDataModel.clear();

        // 添加多种传感器的示例数据
        var startDate = new Date(2023, 10, 1);
        var sensors = ["CO₂", "甲醛", "TVOC", "PM2.5", "空气温度"];
        var units = ["ppm", "mg/m³", "ppb", "μg/m³", "°C"];
        var sensorTypes = ["传感器数据", "传感器数据", "传感器数据", "传感器数据", "传感器数据"];

        for (var i = 0; i < 10; i++) {
            var date = new Date(startDate);
            date.setHours(date.getHours() + i * 2);

            for (var j = 0; j < sensors.length; j++) {
                var baseValue = 0;
                var status = "正常";

                // 根据传感器类型设置基础值和状态
                switch(sensors[j]) {
                    case "CO₂":
                        baseValue = 500 + Math.random() * 600;
                        if (baseValue > 1000) status = "警告";
                        if (baseValue > 2000) status = "超标";
                        break;
                    case "甲醛":
                        baseValue = 0.05 + Math.random() * 0.06;
                        if (baseValue > 0.08) status = "警告";
                        if (baseValue > 0.1) status = "超标";
                        break;
                    case "TVOC":
                        baseValue = 300 + Math.random() * 600;
                        if (baseValue > 500) status = "警告";
                        if (baseValue > 800) status = "超标";
                        break;
                    case "PM2.5":
                        baseValue = 30 + Math.random() * 120;
                        if (baseValue > 75) status = "警告";
                        if (baseValue > 150) status = "超标";
                        break;
                    case "空气温度":
                        baseValue = 20 + Math.random() * 10;
                        break;
                }

                historyDataModel.append({
                    timestamp: Qt.formatDateTime(date, "yyyy-MM-dd hh:mm:ss"),
                    dataType: sensorTypes[j],
                    parameter: sensors[j],
                    value: baseValue.toFixed(2),
                    unit: units[j],
                    status: status
                });
            }
        }
    }

    // 查询数据函数
    function queryData() {
        // 这里应实现实际查询逻辑，现在仅显示示例数据
        addExampleData();

        // 显示提示信息
        if (warningMessage) {
            warningMessage.showWarning("查询完成，共找到 " + historyDataModel.count + " 条记录", successColor);
        }
    }

    // 排序数据函数
    function sortData(sortType) {
        // 实际项目中应实现实际排序逻辑
        // 这里仅为示例，模拟排序效果
        var tempArray = [];

        // 将模型数据复制到数组
        for (var i = 0; i < historyDataModel.count; i++) {
            tempArray.push(historyDataModel.get(i));
        }

        // 根据排序类型排序
        switch(sortType) {
            case 1: // 时间降序
                tempArray.sort(function(a, b) {
                    return new Date(b.timestamp) - new Date(a.timestamp);
                });
                break;
            case 2: // 时间升序
                tempArray.sort(function(a, b) {
                    return new Date(a.timestamp) - new Date(b.timestamp);
                });
                break;
            case 3: // 数值降序
                tempArray.sort(function(a, b) {
                    return parseFloat(b.value) - parseFloat(a.value);
                });
                break;
            case 4: // 数值升序
                tempArray.sort(function(a, b) {
                    return parseFloat(a.value) - parseFloat(b.value);
                });
                break;
            default: // 默认排序（时间降序）
                tempArray.sort(function(a, b) {
                    return new Date(b.timestamp) - new Date(a.timestamp);
                });
                break;
        }

        // 清空模型并重新添加排序后的数据
        historyDataModel.clear();
        for (var j = 0; j < tempArray.length; j++) {
            historyDataModel.append(tempArray[j]);
        }
    }

    // 导出数据函数
    function exportData() {
        // 实际项目中应实现导出逻辑
        // 这里仅为示例，显示成功消息

        if (warningMessage) {
            var format = exportFormatCombo.currentText.split(" ")[0];
            warningMessage.showWarning("数据已成功导出为" + format + "格式", successColor);
        }
    }

    // 生成报告函数
    function generateReport() {
        // 实际项目中应实现报告生成逻辑
        // 这里仅为示例，显示成功消息

        if (warningMessage) {
            var format = reportFormatCombo.currentText.split(" ")[0];
            warningMessage.showWarning(format + "报告已生成: " + reportTitleField.text, successColor);
        }
    }

    // 更新图表函数
    function updateChart() {
        // 清空图表
        if (historyChart.series.length > 2) { // 保留警戒线
            for (var i = historyChart.series.length - 1; i >= 2; i--) {
                historyChart.removeSeries(historyChart.series[i]);
            }
        }

        // 根据选择的传感器和图表类型创建数据系列
        var sensor = chartSensorCombo.currentText;
        var chartType = chartTypeSelector.currentIndex;
        var sensorUnit = getSensorUnit(sensor);

        // 更新Y轴标题
        valueAxis.titleText = sensor + (sensorUnit ? " (" + sensorUnit + ")" : "");

        // 生成或加载数据
        generateChartData(sensor);

        // 根据图表类型创建数据系列
        switch(chartType) {
            case 0: // 折线图
                createLineSeries(sensor, chartData);
                break;
            case 1: // 面积图
                createAreaSeries(sensor, chartData);
                break;
            case 2: // 柱状图
                createBarSeries(sensor, chartData);
                break;
            case 3: // 散点图
                createScatterSeries(sensor, chartData);
                break;
            default:
                createLineSeries(sensor, chartData);
                break;
        }

        // 更新警戒线
        updateThresholdLines(sensor);
    }

    // 更新相关性分析
    function updateCorrelationAnalysis() {
        // 在实际项目中，应基于真实数据计算相关性
        // 这里仅为示例，显示预设的相关性值

        // 更新轴标题
        xCorrelationAxis.titleText = sensor1Combo.currentText + " (" + getSensorUnit(sensor1Combo.currentText) + ")";
        yCorrelationAxis.titleText = sensor2Combo.currentText + " (" + getSensorUnit(sensor2Combo.currentText) + ")";

        // 更新相关系数显示值
        correlationValueText.text = getCorrelationValue(sensor1Combo.currentIndex, sensor2Combo.currentIndex);

        // 重新生成数据
        generateCorrelationData();
        generateCorrelationTrendLine();
    }

    // 更新趋势分析
    function updateAnalysis() {
        // 在实际项目中，应实现真实的分析逻辑
        // 这里仅作为UI演示
    }

    // 生成图表数据
    function generateChartData(sensor) {
        // 这里应从数据模型或数据库中获取数据
        // 现在仅生成示例数据

        chartData = [];
        var baseDate = new Date(2023, 10, 1);
        var baseValue = 0;

        // 根据传感器类型设置适当的基础值
        switch(sensor) {
            case "CO₂":
                baseValue = 500;
                break;
            case "甲醛":
                baseValue = 0.05;
                break;
            case "TVOC":
                baseValue = 300;
                break;
            case "PM2.5":
                baseValue = 50;
                break;
            case "PM10":
                baseValue = 80;
                break;
            case "空气温度":
                baseValue = 20;
                break;
            case "湿度":
                baseValue = 60;
                break;
            default:
                baseValue = 100;
                break;
        }

        // 生成48小时的数据，每小时一个点
        for (var i = 0; i < 48; i++) {
            var date = new Date(baseDate);
            date.setHours(date.getHours() + i);

            var variation = Math.sin(i / 12 * Math.PI) * 0.3 + Math.random() * 0.2;
            var value = baseValue * (1 + variation);

            chartData.push({
                x: date,
                y: value
            });
        }

        // 设置轴范围
        timeAxis.min = chartData[0].x;
        timeAxis.max = chartData[chartData.length-1].x;

        // 根据数据设置Y轴范围
        var min = Number.MAX_VALUE;
        var max = Number.MIN_VALUE;

        for (var j = 0; j < chartData.length; j++) {
            min = Math.min(min, chartData[j].y);
            max = Math.max(max, chartData[j].y);
        }

        var range = max - min;
        valueAxis.min = Math.max(0, min - range * 0.1);
        valueAxis.max = max + range * 0.1;
    }

    // 创建折线图系列
    function createLineSeries(sensor, data) {
        var series = historyChart.createSeries(ChartView.SeriesTypeLine, sensor, timeAxis, valueAxis);
        series.width = 2;
        series.color = accentColor;

        // 添加数据点
        for (var i = 0; i < data.length; i++) {
            series.append(data[i].x.getTime(), data[i].y);
        }
    }

    // 创建面积图系列
    function createAreaSeries(sensor, data) {
        // 创建上边界线
        var upperSeries = historyChart.createSeries(ChartView.SeriesTypeLine, "upper", timeAxis, valueAxis);
        upperSeries.visible = false;

        // 添加数据点
        for (var i = 0; i < data.length; i++) {
            upperSeries.append(data[i].x.getTime(), data[i].y);
        }

        // 创建面积图
        var areaSeries = historyChart.createSeries(ChartView.SeriesTypeArea, sensor, timeAxis, valueAxis);
        areaSeries.color = Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3);
        areaSeries.borderColor = accentColor;
        areaSeries.borderWidth = 2;
        areaSeries.upperSeries = upperSeries;
    }

    // 创建柱状图系列
    function createBarSeries(sensor, data) {
        // 因为DateTimeAxis不支持BarSeries，需要使用特殊处理
        // 这里使用较少的数据点，以每6小时为一个柱

        var barSets = [];
        var barSet = historyChart.createSeries(ChartView.SeriesTypeBar, sensor, timeAxis, valueAxis);

        // 添加数据点（每6小时一个）
        for (var i = 0; i < data.length; i += 6) {
            if (i < data.length) {
                barSet.append(data[i].x.getTime(), data[i].y);
            }
        }
    }

    // 创建散点图系列
    function createScatterSeries(sensor, data) {
        var series = historyChart.createSeries(ChartView.SeriesTypeScatter, sensor, timeAxis, valueAxis);
        series.markerSize = 10;
        series.color = accentColor;

        // 添加数据点
        for (var i = 0; i < data.length; i++) {
            series.append(data[i].x.getTime(), data[i].y);
        }
    }

    // 更新警戒线
    function updateThresholdLines(sensor) {
        // 获取传感器的警戒阈值
        var warningValue = getSensorWarningThreshold(sensor);
        var criticalValue = getSensorCriticalThreshold(sensor);

        // 更新警戒线
        warningThresholdLine.clear();
        criticalThresholdLine.clear();

        if (warningValue > 0) {
            warningThresholdLine.append(timeAxis.min.getTime(), warningValue);
            warningThresholdLine.append(timeAxis.max.getTime(), warningValue);
            warningThresholdLine.visible = true;
        } else {
            warningThresholdLine.visible = false;
        }

        if (criticalValue > 0) {
            criticalThresholdLine.append(timeAxis.min.getTime(), criticalValue);
            criticalThresholdLine.append(timeAxis.max.getTime(), criticalValue);
            criticalThresholdLine.visible = true;
        } else {
            criticalThresholdLine.visible = false;
        }
    }

    // 获取传感器单位
    function getSensorUnit(sensor) {
        switch(sensor) {
            case "CO₂":
                return "ppm";
            case "甲醛":
                return "mg/m³";
            case "TVOC":
                return "ppb";
            case "PM2.5":
            case "PM10":
                return "μg/m³";
            case "空气温度":
            case "水温":
                return "°C";
            case "湿度":
                return "%";
            case "浊度":
                return "NTU";
            case "pH值":
                return "";
            case "TDS":
                return "ppm";
            case "液位":
                return "mm";
            default:
                return "";
        }
    }

    // 获取传感器警戒阈值
    function getSensorWarningThreshold(sensor) {
        switch(sensor) {
            case "CO₂":
                return 1000;
            case "甲醛":
                return 0.08;
            case "TVOC":
                return 500;
            case "PM2.5":
                return 75;
            case "PM10":
                return 150;
            case "浊度":
                return 5;
            case "pH值":
                return 8.5;
            case "TDS":
                return 500;
            default:
                return 0;
        }
    }

    // 获取传感器严重阈值
    function getSensorCriticalThreshold(sensor) {
        switch(sensor) {
            case "CO₂":
                return 2000;
            case "甲醛":
                return 0.1;
            case "TVOC":
                return 800;
            case "PM2.5":
                return 150;
            case "PM10":
                return 250;
            case "浊度":
                return 20;
            case "pH值":
                return 9.0;
            case "TDS":
                return 1000;
            default:
                return 0;
        }
    }

    // 获取预设的相关性值
    function getCorrelationValue(sensor1, sensor2) {
        // 预设的相关性矩阵
        var correlations = [
            // CO₂  甲醛  TVOC  PM2.5 PM10  温度  湿度  浊度  pH   TDS   水温  液位
            [1.00, 0.65, 0.72, 0.58, 0.52, 0.74, 0.48, 0.12, 0.05, 0.08, 0.31, 0.03], // CO₂
            [0.65, 1.00, 0.81, 0.43, 0.38, 0.29, 0.59, 0.14, 0.08, 0.11, 0.18, 0.04], // 甲醛
            [0.72, 0.81, 1.00, 0.62, 0.57, 0.41, 0.53, 0.09, 0.07, 0.06, 0.22, 0.02], // TVOC
            [0.58, 0.43, 0.62, 1.00, 0.91, 0.36, 0.42, 0.15, 0.04, 0.07, 0.25, 0.01], // PM2.5
            [0.52, 0.38, 0.57, 0.91, 1.00, 0.33, 0.37, 0.18, 0.06, 0.08, 0.21, 0.03], // PM10
            [0.74, 0.29, 0.41, 0.36, 0.33, 1.00, 0.63, 0.25, 0.22, 0.28, 0.76, 0.12], // 温度
            [0.48, 0.59, 0.53, 0.42, 0.37, 0.63, 1.00, 0.31, 0.18, 0.23, 0.45, 0.08], // 湿度
            [0.12, 0.14, 0.09, 0.15, 0.18, 0.25, 0.31, 1.00, 0.42, 0.68, 0.37, 0.55], // 浊度
            [0.05, 0.08, 0.07, 0.04, 0.06, 0.22, 0.18, 0.42, 1.00, 0.59, 0.31, 0.17], // pH
            [0.08, 0.11, 0.06, 0.07, 0.08, 0.28, 0.23, 0.68, 0.59, 1.00, 0.42, 0.39], // TDS
            [0.31, 0.18, 0.22, 0.25, 0.21, 0.76, 0.45, 0.37, 0.31, 0.42, 1.00, 0.25], // 水温
            [0.03, 0.04, 0.02, 0.01, 0.03, 0.12, 0.08, 0.55, 0.17, 0.39, 0.25, 1.00]  // 液位
        ];

        var corr = correlations[sensor1][sensor2];
        if (corr < 0) return corr.toFixed(2);
        return "+" + corr.toFixed(2);
    }

    // 生成相关性散点图数据
    function generateCorrelationData() {
        // 清空现有数据
        correlationScatter.clear();

        // 获取当前选择的传感器
        var sensor1 = sensor1Combo.currentText;
        var sensor2 = sensor2Combo.currentText;

        // 获取基础值
        var baseValue1 = 0;
        var baseValue2 = 0;

        switch(sensor1) {
            case "CO₂": baseValue1 = 500; break;
            case "甲醛": baseValue1 = 0.05; break;
            case "TVOC": baseValue1 = 300; break;
            case "PM2.5": baseValue1 = 50; break;
            case "空气温度": baseValue1 = 20; break;
            default: baseValue1 = 100; break;
        }

        switch(sensor2) {
            case "CO₂": baseValue2 = 500; break;
            case "甲醛": baseValue2 = 0.05; break;
            case "TVOC": baseValue2 = 300; break;
            case "PM2.5": baseValue2 = 50; break;
            case "空气温度": baseValue2 = 20; break;
            default: baseValue2 = 100; break;
        }

        // 获取相关系数
        var correlation = parseFloat(correlationValueText.text);

        // 设置轴范围
        xCorrelationAxis.min = baseValue1 * 0.7;
        xCorrelationAxis.max = baseValue1 * 1.5;
        yCorrelationAxis.min = baseValue2 * 0.7;
        yCorrelationAxis.max = baseValue2 * 1.5;

        // 生成散点数据
        for (var i = 0; i < 50; i++) {
            // 生成具有指定相关性的随机值
            var x = baseValue1 * (0.8 + Math.random() * 0.5);
            var y = baseValue2 * (0.8 + correlation * (x/baseValue1 - 1) + Math.random() * 0.2);

            correlationScatter.append(x, y);
        }
    }

    // 生成相关性趋势线
    function generateCorrelationTrendLine() {
        // 清空现有数据
        correlationTrendLine.clear();

        // 简单线性回归
        correlationTrendLine.append(xCorrelationAxis.min, yCorrelationAxis.min + (yCorrelationAxis.max - yCorrelationAxis.min) * 0.1);
        correlationTrendLine.append(xCorrelationAxis.max, yCorrelationAxis.min + (yCorrelationAxis.max - yCorrelationAxis.min) * 0.9);
    }

    // 生成趋势分析图表数据
    function generateTrendData() {
        // 实际项目中应使用真实数据
    }

    // 生成异常检测数据
    function generateAnomalyData() {
        // 实际项目中应使用真实数据
    }

    // 生成移动平均数据
    function generateMovingAverageData() {
        // 实际项目中应使用真实数据
    }

    // 生成趋势线数据
    function generateTrendLineData() {
        // 实际项目中应使用真实数据
    }

    // 生成上边界数据
    function generateUpperBoundData() {
        // 实际项目中应使用真实数据
    }

    // 生成下边界数据
    function generateLowerBoundData() {
        // 实际项目中应使用真实数据
    }

    // ========== 组件库 ==========

    // 表格头部单元格组件
    component TableHeader: Rectangle {
        property string text: ""
        signal clicked()

        color: "transparent"
        height: parent.height

        RowLayout {
            anchors.fill: parent
            spacing: 5

            Text {
                text: parent.parent.text
                color: textColor
                font.pixelSize: fontSize
                font.bold: true
                Layout.fillWidth: true
            }

            // 排序图标（可选）
            Text {
                text: "⇵"
                color: Qt.rgba(textColor.r, textColor.g, textColor.b, 0.5)
                font.pixelSize: fontSize
                visible: parent.parent.text === "时间戳" || parent.parent.text === "数值"
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: parent.clicked()
        }
    }

    // 表格内容单元格组件
    component TableCell: Rectangle {
        property string text: ""
        property alias font: cellText.font

        color: "transparent"
        Layout.fillHeight: true

        Text {
            id: cellText
            anchors.verticalCenter: parent.verticalCenter
            text: parent.text
            color: textColor
            font.pixelSize: fontSize
            elide: Text.ElideRight
            width: parent.width - 10
            clip: true
        }
    }

    // 分析卡片组件
    component AnalysisCard: Rectangle {
        property string title: ""
        property alias content: contentArea.children

        color: cardColor
        radius: 5

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 2
            radius: 6.0
            samples: 17
            color: Qt.rgba(0, 0, 0, 0.2)
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // 卡片标题栏
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                color: Qt.rgba(1,1,1,0.05)
                radius: 5

                // 只保留顶部圆角
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: parent.height / 2
                    color: parent.color
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    Text {
                        text: title
                        color: textColor
                        font.pixelSize: fontSize
                        font.bold: true
                    }

                    Item { Layout.fillWidth: true }

                    // 可选的操作按钮
                    Row {
                        spacing: 5
                        visible: false

                        Text {
                            text: "⟳"
                            color: textColor
                            font.pixelSize: fontSize
                        }

                        Text {
                            text: "⋮"
                            color: textColor
                            font.pixelSize: fontSize
                        }
                    }
                }
            }

            // 内容区域
            Item {
                id: contentArea
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}
