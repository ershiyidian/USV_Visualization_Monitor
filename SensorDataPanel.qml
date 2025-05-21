import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.15
import QtGraphicalEffects 1.15

Rectangle {
    id: sensorDataPanel
    color: darkColor

    // 属性定义
    property var selectedSensor: null
    property real startTime: 0

    // 传感器数据结构
    property var sensorGroups: [
        {
            name: "空气质量",
            sensors: [
                {
                    name: "CO₂浓度",
                    value: 0,
                    unit: "ppm",
                    type: "air",
                    dataKey: "co2",
                    status: 0,
                    warningThreshold: 1000,
                    criticalThreshold: 2000,
                    chartColor: accentColor,
                    dataArray: []
                },
                {
                    name: "甲醛浓度",
                    value: 0,
                    unit: "mg/m³",
                    type: "air",
                    dataKey: "ch2o",
                    status: 0,
                    warningThreshold: 0.08,
                    criticalThreshold: 0.1,
                    chartColor: accentColor,
                    dataArray: []
                },
                {
                    name: "TVOC",
                    value: 0,
                    unit: "ppb",
                    type: "air",
                    dataKey: "tvoc",
                    status: 0,
                    warningThreshold: 500,
                    criticalThreshold: 800,
                    chartColor: accentColor,
                    dataArray: []
                },
                {
                    name: "PM2.5",
                    value: 0,
                    unit: "μg/m³",
                    type: "air",
                    dataKey: "pm25",
                    status: 0,
                    warningThreshold: 75,
                    criticalThreshold: 150,
                    chartColor: accentColor,
                    dataArray: []
                },
                {
                    name: "PM10",
                    value: 0,
                    unit: "μg/m³",
                    type: "air",
                    dataKey: "pm10",
                    status: 0,
                    warningThreshold: 150,
                    criticalThreshold: 250,
                    chartColor: accentColor,
                    dataArray: []
                },
                {
                    name: "空气温度",
                    value: 0,
                    unit: "°C",
                    type: "air",
                    dataKey: "airTemperature",
                    status: 0,
                    warningThreshold: 0,
                    criticalThreshold: 0,
                    chartColor: accentColor,
                    dataArray: []
                },
                {
                    name: "湿度",
                    value: 0,
                    unit: "%",
                    type: "air",
                    dataKey: "humidity",
                    status: 0,
                    warningThreshold: 0,
                    criticalThreshold: 0,
                    chartColor: accentColor,
                    dataArray: []
                }
            ]
        },
        {
            name: "水质监测",
            sensors: [
                {
                    name: "浊度",
                    value: 0,
                    unit: "NTU",
                    type: "water",
                    dataKey: "turbidity",
                    status: 0,
                    warningThreshold: 5,
                    criticalThreshold: 20,
                    chartColor: "#3498DB",
                    dataArray: []
                },
                {
                    name: "pH值",
                    value: 0,
                    unit: "",
                    type: "water",
                    dataKey: "ph",
                    status: 0,
                    warningThreshold: 8.5,
                    criticalThreshold: 9.0,
                    chartColor: "#3498DB",
                    dataArray: []
                },
                {
                    name: "TDS",
                    value: 0,
                    unit: "ppm",
                    type: "water",
                    dataKey: "tds",
                    status: 0,
                    warningThreshold: 500,
                    criticalThreshold: 1000,
                    chartColor: "#3498DB",
                    dataArray: []
                },
                {
                    name: "水温",
                    value: 0,
                    unit: "°C",
                    type: "water",
                    dataKey: "waterTemperature",
                    status: 0,
                    warningThreshold: 0,
                    criticalThreshold: 0,
                    chartColor: "#3498DB",
                    dataArray: []
                },
                {
                    name: "液位",
                    value: 0,
                    unit: "mm",
                    type: "level",
                    dataKey: "levelValue",
                    status: 0,
                    warningThreshold: 0,
                    criticalThreshold: 0,
                    chartColor: "#2ECC71",
                    dataArray: []
                }
            ]
        }
    ]

    // 筛选不同类型的传感器数据
    property var currentSensors: []

    // 初始化函数，确保数据正确加载
    function initializeSensors() {
        startTime = new Date().getTime();
        updateCurrentSensors();

        // 确保在初始状态下有选中的传感器
        var allSensors = getAllSensors();
        if (allSensors.length > 0 && !selectedSensor) {
            selectedSensor = allSensors[0];
            // 更新图表
            if (chartStack.visible) {
                chartStack.updateChart();
            }
        }
    }

    // 更新当前显示的传感器列表
    function updateCurrentSensors() {
        var result = [];

        if (sensorTypeBar.currentIndex === 0) {
            // 所有传感器
            result = getAllSensors();
        } else if (sensorTypeBar.currentIndex === 1) {
            // 只显示空气相关
            var airGroup = sensorGroups.find(g => g.name === "空气质量");
            if (airGroup) result = airGroup.sensors;
        } else if (sensorTypeBar.currentIndex === 2) {
            // 只显示水质相关
            var waterGroup = sensorGroups.find(g => g.name === "水质监测");
            if (waterGroup) result = waterGroup.sensors;
        }

        currentSensors = result;
        return result;
    }

    // 检查传感器状态
    function checkSensorStatus(sensor) {
        if (sensor.criticalThreshold > 0 && sensor.value >= sensor.criticalThreshold) {
            if (sensor.status !== 2) {
                sensor.status = 2;
                if (warningMessage) {
                    warningMessage.showWarning(sensor.name + "严重超标: " + sensor.value.toFixed(2) + sensor.unit, dangerColor);
                }
            }
            return 2;
        } else if (sensor.warningThreshold > 0 && sensor.value >= sensor.warningThreshold) {
            if (sensor.status !== 1 && sensor.status !== 2) {
                sensor.status = 1;
                if (warningMessage) {
                    warningMessage.showWarning(sensor.name + "超标: " + sensor.value.toFixed(2) + sensor.unit, warningColor);
                }
            }
            return 1;
        } else {
            if (sensor.status !== 0) {
                sensor.status = 0;
            }
            return 0;
        }
    }

    // 递归查找所有传感器
    function getAllSensors() {
        var result = [];
        for (var i = 0; i < sensorGroups.length; i++) {
            var group = sensorGroups[i];
            for (var j = 0; j < group.sensors.length; j++) {
                result.push(group.sensors[j]);
            }
        }
        return result;
    }

    // 找到特定传感器
    function findSensor(dataKey) {
        var allSensors = getAllSensors();
        for (var i = 0; i < allSensors.length; i++) {
            if (allSensors[i].dataKey === dataKey) {
                return allSensors[i];
            }
        }
        return null;
    }

    // 初始化
    Component.onCompleted: {
        // 延迟初始化，确保所有绑定都已建立
        initTimer.start();
    }

    // 初始化定时器，确保组件完全加载后再初始化数据
    Timer {
        id: initTimer
        interval: 50
        repeat: false
        onTriggered: {
            initializeSensors();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        // 标题栏
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "传感器数据监测"
                font.pixelSize: largeFontSize
                font.bold: true
                color: textColor
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "显示全部图表"

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
                    // 打开独立的全部图表窗口，而不是切换视图
                    allChartsDialog.open();
                }
            }
        }

        // 主内容区
        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Horizontal
            handle: Rectangle {
                implicitWidth: 4
                implicitHeight: 4
                color: SplitHandle.pressed ? accentColor :
                       SplitHandle.hovered ? Qt.lighter(accentColor, 1.1) : borderColor
            }

            // 左侧传感器列表
            Rectangle {
                SplitView.preferredWidth: 260
                SplitView.minimumWidth: 150
                color: cardColor
                radius: 5

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 8

                    // 分类标签
                    TabBar {
                        id: sensorTypeBar
                        Layout.fillWidth: true

                        background: Rectangle {
                            color: Qt.rgba(0, 0, 0, 0.2)
                            radius: 4
                        }

                        // 全部传感器
                        TabButton {
                            text: "全部"
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

                        // 空气传感器
                        TabButton {
                            text: "空气"
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

                        // 水质传感器
                        TabButton {
                            text: "水质"
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

                        // 当索引变化时更新当前传感器列表
                        onCurrentIndexChanged: {
                            updateCurrentSensors();
                        }
                    }

                    // 传感器列表 - 使用高效网格
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        // 使用网格布局提高空间利用率
                        Grid {
                            id: sensorGrid
                            width: parent.width
                            // 根据宽度自动调整列数（优化空间利用率）
                            columns: calculateOptimalColumns(width)
                            spacing: 4

                            // 计算最佳列数
                            function calculateOptimalColumns(availableWidth) {
                                // 设置最小宽度为120
                                var minItemWidth = 120;
                                // 计算可容纳的最大列数
                                var maxColumns = Math.floor(availableWidth / minItemWidth);
                                // 返回最少1列，最多3列
                                return Math.max(1, Math.min(3, maxColumns));
                            }

                            // 直接使用currentSensors作为模型
                            Repeater {
                                id: sensorRepeater
                                model: currentSensors

                                // 精简的传感器显示项
                                Rectangle {
                                    id: sensorItem
                                    width: (sensorGrid.width - (sensorGrid.columns-1) * sensorGrid.spacing) / sensorGrid.columns
                                    height: 40  // 减小高度使显示更紧凑
                                    color: selectedSensor === modelData ?
                                           Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3) :
                                           (index % 2 === 0 ? Qt.rgba(1,1,1,0.03) : Qt.rgba(1,1,1,0.05))
                                    radius: 3  // 减小圆角

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 4
                                        anchors.rightMargin: 4
                                        spacing: 2  // 减小间距

                                        // 状态指示灯
                                        Rectangle {
                                            width: 6
                                            height: 6
                                            radius: 3
                                            Layout.alignment: Qt.AlignVCenter
                                            color: {
                                                if (modelData.status === 2) return dangerColor;
                                                if (modelData.status === 1) return warningColor;
                                                return successColor;
                                            }
                                        }

                                        // 传感器信息 - 更紧凑的布局
                                        Column {
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignVCenter
                                            spacing: 1  // 减小行间距

                                            Text {
                                                text: modelData.name
                                                color: textColor
                                                font.bold: true
                                                font.pixelSize: smallFontSize
                                                elide: Text.ElideRight
                                                width: parent.width
                                            }

                                            Text {
                                                text: modelData.value.toFixed(2) + " " + modelData.unit
                                                color: {
                                                    if (modelData.status === 2) return dangerColor;
                                                    if (modelData.status === 1) return warningColor;
                                                    return textColor;
                                                }
                                                font.pixelSize: smallFontSize
                                                font.family: "Consolas, monospace"
                                            }
                                        }
                                    }

                                    // 点击选择传感器
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            selectedSensor = modelData;
                                            // 直接更新图表，避免重复绑定
                                            if (chartStack.visible) {
                                                chartStack.updateChart();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 右侧图表区域
            Rectangle {
                SplitView.fillWidth: true
                color: Qt.rgba(0,0,0,0.2)
                radius: 5
                clip: true

                // 单传感器图表视图
                SensorChart {
                    id: chartStack
                    anchors.fill: parent
                    anchors.margins: 10
                    visible: true

                    // 绑定属性
                    title: selectedSensor ? selectedSensor.name : ""
                    unit: selectedSensor ? selectedSensor.unit : ""
                    chartColor: selectedSensor ? selectedSensor.chartColor : accentColor
                    warningThreshold: selectedSensor ? selectedSensor.warningThreshold : 0
                    criticalThreshold: selectedSensor ? selectedSensor.criticalThreshold : 0
                    value: selectedSensor ? selectedSensor.value : 0

                    // 更新图表数据
                    function updateChart() {
                        if (!selectedSensor) return;

                        // 清空原有数据
                        lineSeries.clear();

                        // 添加新数据
                        var dataArray = selectedSensor.dataArray || [];
                        for (var i = 0; i < dataArray.length; i++) {
                            lineSeries.append(dataArray[i].x, dataArray[i].y);
                        }
                    }
                }
            }
        }
    }

    // 全部图表对话框 - 改为独立窗口
    Dialog {
        id: allChartsDialog
        title: "全部传感器图表"
        width: Math.min(parent.width * 0.9, 1200)
        height: Math.min(parent.height * 0.9, 800)
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
                    text: allChartsDialog.title
                    color: textColor
                    font.pixelSize: largeFontSize
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                Button {
                    text: "×"
                    flat: true
                    onClicked: allChartsDialog.close()

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

        // 对话框内容
        ScrollView {
            id: allChartsView
            anchors.fill: parent
            clip: true

            GridLayout {
                width: allChartsView.width
                columns: width > 700 ? 2 : 1
                rowSpacing: 10
                columnSpacing: 10

                // 动态生成所有传感器的图表
                Repeater {
                    model: getAllSensors()

                    SensorChart {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 250

                        // 绑定传感器属性
                        title: modelData.name
                        unit: modelData.unit
                        chartColor: modelData.chartColor
                        warningThreshold: modelData.warningThreshold
                        criticalThreshold: modelData.criticalThreshold
                        value: modelData.value

                        // 组件完成加载后填充数据
                        Component.onCompleted: {
                            var dataArray = modelData.dataArray || [];
                            for (var i = 0; i < dataArray.length; i++) {
                                lineSeries.append(dataArray[i].x, dataArray[i].y);
                            }
                        }
                    }
                }
            }
        }
    }

    // 数据更新处理 - 优化性能，避免闪烁
    Connections {
        target: sensorModule
        function onDisplayDataChanged() {
            // 获取当前时间距离启动的秒数
            var currentTime = (new Date().getTime() - startTime) / 1000.0;

            // 遍历所有传感器，更新数据
            var allSensors = getAllSensors();
            for (var i = 0; i < allSensors.length; i++) {
                var sensor = allSensors[i];
                var value = sensorModule[sensor.dataKey];

                // 更新数值
                sensor.value = value;

                // 检查状态
                checkSensorStatus(sensor);

                // 添加新数据点
                if (!sensor.dataArray) {
                    sensor.dataArray = [];
                }

                // 添加新数据点
                sensor.dataArray.push({x: currentTime, y: value});

                // 限制数据点数量，保留最新的1000个点
                if (sensor.dataArray.length > 1000) {
                    sensor.dataArray.splice(0, sensor.dataArray.length - 1000);
                }
            }

            // 更新传感器列表 - 无需强制刷新
            sensorRepeater.model = null;
            sensorRepeater.model = currentSensors;

            // 如果有选中的传感器，更新主图表
            if (selectedSensor && chartStack.visible) {
                chartStack.updateChart();
            }

            // 如果全部图表对话框是打开的，需要更新所有图表
            if (allChartsDialog.visible) {
                // 对话框内的图表会自动更新，因为它们直接绑定到值
            }
        }
    }
}
