import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.15
import QtGraphicalEffects 1.15
import "." // 确保Theme单例已导入

// SensorDataPanel.qml - 传感器数据显示面板
Rectangle {
    id: sensorDataPanel
    // color: darkColor // 旧的硬编码背景色
    color: Theme.darkThemeBackgroundColor // 使用Theme中的深色背景

    // 属性定义
    property var selectedSensor: null // 当前选中的传感器对象
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
                    // warningThreshold: 1000, // 旧的硬编码阈值，将被动态加载
                    // criticalThreshold: 2000, // 旧的硬编码阈值，将被动态加载
                    chartColor: Theme.primaryColor, // 使用Theme主色调
                    dataArray: []
                },
                {
                    name: "甲醛浓度",
                    value: 0,
                    unit: "mg/m³",
                    type: "air",
                    dataKey: "ch2o",
                    status: 0,
                    // warningThreshold: 0.08, // 旧的硬编码阈值
                    // criticalThreshold: 0.1,   // 旧的硬编码阈值
                    chartColor: Theme.primaryColor,
                    dataArray: []
                },
                {
                    name: "TVOC",
                    value: 0,
                    unit: "ppb", // 注意: 单位与DTO不一致，initializeSensors中做了转换
                    type: "air",
                    dataKey: "tvoc",
                    status: 0,
                    // warningThreshold: 500, // 旧的硬编码阈值 (ppb)
                    // criticalThreshold: 800, // 旧的硬编码阈值 (ppb)
                    chartColor: Theme.primaryColor,
                    dataArray: []
                },
                {
                    name: "PM2.5",
                    value: 0,
                    unit: "μg/m³",
                    type: "air",
                    dataKey: "pm25",
                    status: 0,
                    // warningThreshold: 75,  // 旧的硬编码阈值
                    // criticalThreshold: 150, // 旧的硬编码阈值
                    chartColor: Theme.primaryColor,
                    dataArray: []
                },
                {
                    name: "PM10",
                    value: 0,
                    unit: "μg/m³",
                    type: "air",
                    dataKey: "pm10",
                    status: 0,
                    // warningThreshold: 150, // 旧的硬编码阈值
                    // criticalThreshold: 250, // 旧的硬编码阈值
                    chartColor: Theme.primaryColor,
                    dataArray: []
                },
                {
                    name: "空气温度",
                    value: 0,
                    unit: "°C",
                    type: "air",
                    dataKey: "airTemperature",
                    status: 0,
                    warningThreshold: 0, // 通常温度没有固定阈值，或根据需求设定
                    criticalThreshold: 0,
                    chartColor: Theme.primaryColor,
                    dataArray: []
                },
                {
                    name: "湿度",
                    value: 0,
                    unit: "%",
                    type: "air",
                    dataKey: "humidity", // 对应DTO的airHumidity
                    status: 0,
                    warningThreshold: 0, // 湿度通常也没有固定阈值
                    criticalThreshold: 0,
                    chartColor: Theme.primaryColor,
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
                    dataKey: "turbidity", // DTO: waterTurbidity
                    status: 0,
                    // warningThreshold: 5,   // 旧的硬编码阈值
                    // criticalThreshold: 20,  // 旧的硬编码阈值
                    chartColor: Theme.secondaryColor, // 使用Theme次要色
                    dataArray: []
                },
                {
                    name: "pH值",
                    value: 0,
                    unit: "",
                    type: "water",
                    dataKey: "ph",
                    status: 0,
                    // warningThreshold: 8.5, // 旧的硬编码阈值
                    // criticalThreshold: 9.0, // 旧的硬编码阈值
                    chartColor: Theme.secondaryColor,
                    dataArray: []
                },
                {
                    name: "TDS",
                    value: 0,
                    unit: "ppm",
                    type: "water",
                    dataKey: "tds",
                    status: 0,
                    // warningThreshold: 500,  // 旧的硬编码阈值
                    // criticalThreshold: 1000, // 旧的硬编码阈值
                    chartColor: Theme.secondaryColor,
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
                    chartColor: Theme.secondaryColor,
                    dataArray: []
                },
                {
                    name: "液位",
                    value: 0,
                    unit: "mm", // QML中单位显示，DTO中是米
                    type: "level",
                    dataKey: "waterLevel", // 对应DTO的waterLevel
                    status: 0,
                    warningThreshold: 0, // 液位通常是范围
                    criticalThreshold: 0,
                    chartColor: Theme.secondaryColor, // 使用Theme次要色 (原为绿色)
                    dataArray: []
                }
            ]
        }
    ]

    // 筛选不同类型的传感器数据
    property var currentSensors: []

    // 初始化函数，确保数据正确加载并设置阈值
    function initializeSensors() {
        startTime = new Date().getTime();
        var allSensors = getAllSensors();

        // 从sensorModule加载阈值
        for (var i = 0; i < allSensors.length; i++) {
            var sensor = allSensors[i];
            var warningLimitProp = sensor.dataKey + "WarningLimit";
            var criticalLimitProp = sensor.dataKey + "CriticalLimit";

            if (sensorModule.hasOwnProperty(warningLimitProp)) {
                sensor.warningThreshold = sensorModule[warningLimitProp];
            } else {
                // console.warn("Warning limit for " + sensor.dataKey + " not found in sensorModule.");
                sensor.warningThreshold = 0; // 默认值或处理
            }

            if (sensorModule.hasOwnProperty(criticalLimitProp)) {
                sensor.criticalThreshold = sensorModule[criticalLimitProp];
            } else {
                // console.warn("Critical limit for " + sensor.dataKey + " not found in sensorModule.");
                sensor.criticalThreshold = 0; // 默认值或处理
            }

            // 特殊处理TVOC单位：SensorModule limit (ppb) vs DTO/display (mg/m³)
            // QML中value的单位是mg/m³ (来自DTO)，而FrameConstant中limit的单位是ppb
            // 因此，比较时需要统一单位。这里假设checkSensorStatus会基于mg/m³进行比较。
            // 所以，将ppb的limit转换为mg/m³。1 ppb TVOC (toluene) approx 0.00375 mg/m³
            if (sensor.dataKey === "tvoc") {
                // sensorModule.tvocWarningLimit 和 sensorModule.tvocCriticalLimit 是ppb
                sensor.warningThreshold = sensorModule.tvocWarningLimit * 0.00375; // ppb to mg/m³
                sensor.criticalThreshold = sensorModule.tvocCriticalLimit * 0.00375; // ppb to mg/m³
                // console.log("TVOC Limits (mg/m³): Warn=" + sensor.warningThreshold + ", Crit=" + sensor.criticalThreshold);
            }
        }

        updateCurrentSensors();

        // 确保在初始状态下有选中的传感器
        if (allSensors.length > 0 && !selectedSensor) {
            selectedSensor = allSensors[0];
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
        // 使用Theme中的颜色进行警告
        if (sensor.criticalThreshold > 0 && sensor.value >= sensor.criticalThreshold) {
            if (sensor.status !== 2) { // 状态未标记为严重
                sensor.status = 2; // 更新状态为严重
                if (warningMessage) { // warningMessage 是 main.qml 中的全局消息组件
                    warningMessage.showWarning(sensor.name + "严重超标: " + sensor.value.toFixed(2) + sensor.unit, Theme.accentColor); // 使用Theme危险色
                }
            }
            return 2; // 返回严重状态
        } else if (sensor.warningThreshold > 0 && sensor.value >= sensor.warningThreshold) { // 如果超出警告阈值
            if (sensor.status !== 1 && sensor.status !== 2) { // 状态未标记为警告或严重
                sensor.status = 1; // 更新状态为警告
                if (warningMessage) {
                    warningMessage.showWarning(sensor.name + "超标: " + sensor.value.toFixed(2) + sensor.unit, Theme.warningColor); // 使用Theme警告色
                }
            }
            return 1; // 返回警告状态
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

    // 主布局
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.paddingMedium // 使用Theme中内边距
        spacing: Theme.paddingSmall // 使用Theme中间距

        // 标题栏
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: qsTr("传感器数据监测") + " (Sensor Data Monitoring)" // 国际化和中文注释: 传感器数据监测
                font.pixelSize: Theme.largeFontSize // 使用Theme大字号
                font.bold: true
                color: Theme.textColorOnDark // 使用Theme深色背景文本颜色
            }

            Item { Layout.fillWidth: true } // 占位

            Button {
                text: qsTr("显示全部图表") + " (Show All Charts)" // 国际化和中文注释: 显示全部图表
                height: Theme.controlHeight // 使用Theme标准控件高度
                contentItem: Text {
                    text: parent.text
                    color: Theme.textColorOnLight // 假设按钮背景深，文本用浅色
                    font.pixelSize: Theme.defaultFontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: parent.down ? Qt.darker(Theme.primaryColor, 1.2) :
                           parent.hovered ? Theme.primaryColor : Qt.lighter(Theme.primaryColor, 1.1) // 使用Theme主色调
                    radius: Theme.buttonCornerRadius // 使用Theme按钮圆角
                }
                onClicked: {
                    allChartsDialog.open();
                }
            }
        }

        // 主内容区
        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Horizontal
            handle: Rectangle { // SplitView拖动条样式
                implicitWidth: Theme.paddingSmall
                implicitHeight: Theme.paddingSmall
                color: SplitHandle.pressed ? Theme.primaryColor :
                       SplitHandle.hovered ? Qt.lighter(Theme.primaryColor, 1.1) : Theme.borderColor
            }

            // 左侧传感器列表
            Rectangle {
                SplitView.preferredWidth: 260
                SplitView.minimumWidth: 150
                color: Theme.darkThemeCardColor // 使用Theme深色卡片背景
                radius: Theme.cardCornerRadius // 使用Theme卡片圆角

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.paddingSmall // 使用Theme小内边距
                    spacing: Theme.paddingMedium

                    // 分类标签
                    TabBar {
                        id: sensorTypeBar
                        Layout.fillWidth: true
                        background: Rectangle {
                            color: Qt.rgba(Theme.darkThemeBackgroundColor.r, Theme.darkThemeBackgroundColor.g, Theme.darkThemeBackgroundColor.b, 0.2) // TabBar背景
                            radius: Theme.buttonCornerRadius
                        }

                        // TabButton 样式统一调整
                        TabButton {
                            text: qsTr("全部") + " (All)" // 国际化: 全部
                            width: sensorTypeBar.width / 3 // 均分宽度
                            contentItem: Text {
                                text: parent.text
                                color: parent.checked ? Theme.primaryColor : Theme.textColorOnDark
                                font.pixelSize: Theme.defaultFontSize
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: parent.pressed ? Qt.rgba(Theme.primaryColor.r, Theme.primaryColor.g, Theme.primaryColor.b, 0.2) :
                                       parent.checked ? Qt.rgba(Theme.darkThemeBackgroundColor.r, Theme.darkThemeBackgroundColor.g, Theme.darkThemeBackgroundColor.b, 0.6) : "transparent"
                                Rectangle { // 选中指示器
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: 2
                                    color: parent.parent.checked ? Theme.primaryColor : "transparent"
                                }
                            }
                        }
                        TabButton { text: qsTr("空气") + " (Air)"; width: sensorTypeBar.width / 3; contentItem.font.pixelSize: Theme.defaultFontSize; contentItem.color: parent.checked ? Theme.primaryColor : Theme.textColorOnDark; background.children[0].color: parent.parent.checked ? Theme.primaryColor : "transparent" }
                        TabButton { text: qsTr("水质") + " (Water)"; width: sensorTypeBar.width / 3; contentItem.font.pixelSize: Theme.defaultFontSize; contentItem.color: parent.checked ? Theme.primaryColor : Theme.textColorOnDark; background.children[0].color: parent.parent.checked ? Theme.primaryColor : "transparent" }

                        onCurrentIndexChanged: { updateCurrentSensors(); }
                    }

                    // 传感器列表
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        Grid {
                            id: sensorGrid
                            width: parent.width
                            columns: calculateOptimalColumns(width)
                            spacing: Theme.paddingSmall // 使用Theme小间距

                            function calculateOptimalColumns(availableWidth) {
                                var minItemWidth = 120;
                                var maxColumns = Math.floor(availableWidth / minItemWidth);
                                return Math.max(1, Math.min(3, maxColumns));
                            }

                            Repeater {
                                id: sensorRepeater
                                model: currentSensors
                                Rectangle { // 精简的传感器显示项
                                    id: sensorItem
                                    width: (sensorGrid.width - (sensorGrid.columns-1) * sensorGrid.spacing) / sensorGrid.columns
                                    height: Theme.controlHeight * 1.2 // 适配Theme控件高度
                                    color: selectedSensor === modelData ? Qt.rgba(Theme.primaryColor.r, Theme.primaryColor.g, Theme.primaryColor.b, 0.3) :
                                           (index % 2 === 0 ? Qt.rgba(Theme.textColorOnDark.r, Theme.textColorOnDark.g, Theme.textColorOnDark.b, 0.03) : Qt.rgba(Theme.textColorOnDark.r, Theme.textColorOnDark.g, Theme.textColorOnDark.b, 0.05))
                                    radius: Theme.buttonCornerRadius / 2 // 使用Theme按钮圆角的一半

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: Theme.paddingSmall
                                        anchors.rightMargin: Theme.paddingSmall
                                        spacing: Theme.paddingSmall / 2

                                        Rectangle { // 状态指示灯
                                            width: 6; height: 6; radius: 3
                                            Layout.alignment: Qt.AlignVCenter
                                            color: { // 使用Theme颜色
                                                if (modelData.status === 2) return Theme.accentColor;  // 危险色
                                                if (modelData.status === 1) return Theme.warningColor; // 警告色
                                                return Theme.secondaryColor; // 成功色
                                            }
                                        }
                                        Column { // 传感器信息
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignVCenter
                                            spacing: 1
                                            Text {
                                                text: modelData.name
                                                color: Theme.textColorOnDark
                                                font.bold: true
                                                font.pixelSize: Theme.smallFontSize // 使用Theme小字号
                                                elide: Text.ElideRight
                                                width: parent.width
                                            }
                                            Text {
                                                text: modelData.value.toFixed(2) + " " + modelData.unit
                                                color: { // 使用Theme颜色
                                                    if (modelData.status === 2) return Theme.accentColor;
                                                    if (modelData.status === 1) return Theme.warningColor;
                                                    return Theme.textColorOnDark;
                                                }
                                                font.pixelSize: Theme.smallFontSize
                                                font.family: "Consolas, monospace"
                                            }
                                        }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            selectedSensor = modelData;
                                            if (chartStack.visible) chartStack.updateChart();
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
                color: Qt.rgba(Theme.darkThemeBackgroundColor.r, Theme.darkThemeBackgroundColor.g, Theme.darkThemeBackgroundColor.b, 0.2) // 使用Theme深色背景的透明变体
                radius: Theme.cardCornerRadius // 使用Theme卡片圆角
                clip: true

                SensorChart { // 单传感器图表视图
                    id: chartStack
                    anchors.fill: parent
                    anchors.margins: Theme.paddingMedium
                    visible: true
                    title: selectedSensor ? selectedSensor.name : ""
                    unit: selectedSensor ? selectedSensor.unit : ""
                    chartColor: selectedSensor ? selectedSensor.chartColor : Theme.primaryColor // 使用Theme主色调
                    warningThreshold: selectedSensor ? selectedSensor.warningThreshold : 0
                    criticalThreshold: selectedSensor ? selectedSensor.criticalThreshold : 0
                    value: selectedSensor ? selectedSensor.value : 0
                    function updateChart() {
                        if (!selectedSensor) return;
                        lineSeries.clear();
                        var dataArray = selectedSensor.dataArray || [];
                        for (var i = 0; i < dataArray.length; i++) {
                            lineSeries.append(dataArray[i].x, dataArray[i].y);
                        }
                    }
                }
            }
        }
    }

    // 全部图表对话框
    Dialog {
        id: allChartsDialog
        title: qsTr("全部传感器图表") + " (All Sensor Charts)" // 国际化: 全部传感器图表
        width: Math.min(parent.width * 0.9, 1200)
        height: Math.min(parent.height * 0.9, 800)
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle { // 自定义背景
            color: Theme.darkThemeBackgroundColor
            radius: Theme.cardCornerRadius // 使用Theme卡片圆角
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0; verticalOffset: 2; radius: 8.0; samples: 17
                color: Theme.shadowColor // 使用Theme阴影色
            }
        }

        header: Rectangle { // 自定义标题栏
            color: Theme.darkThemeCardColor // 使用Theme深色卡片背景
            height: Theme.controlHeight * 1.2 // 适配Theme控件高度
            radius: Theme.cardCornerRadius
            Rectangle { // 仅顶部圆角
                color: Theme.darkThemeCardColor
                anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                height: parent.height / 2
            }
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.paddingLarge
                anchors.rightMargin: Theme.paddingLarge
                Text {
                    text: allChartsDialog.title
                    color: Theme.textColorOnDark
                    font.pixelSize: Theme.largeFontSize
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                Button { // 关闭按钮
                    text: "×"
                    flat: true
                    onClicked: allChartsDialog.close()
                    contentItem: Text {
                        text: parent.text
                        color: Theme.textColorOnDark
                        font.pixelSize: Theme.largeFontSize
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: parent.hovered ? Qt.rgba(Theme.textColorOnDark.r, Theme.textColorOnDark.g, Theme.textColorOnDark.b, 0.1) : "transparent"
                        radius: Theme.buttonCornerRadius
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
                columns: width > 700 ? 2 : 1 // 响应式列数
                rowSpacing: Theme.paddingMedium
                columnSpacing: Theme.paddingMedium
                Repeater { // 动态生成图表
                    model: getAllSensors()
                    SensorChart {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 250
                        title: modelData.name
                        unit: modelData.unit
                        chartColor: modelData.chartColor // chartColor 已在 sensorGroups 中定义，可考虑也用Theme
                        warningThreshold: modelData.warningThreshold
                        criticalThreshold: modelData.criticalThreshold
                        value: modelData.value
                        Component.onCompleted: { // 填充数据
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

    // 数据更新处理
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

            // 检查状态 (checkSensorStatus 现在会使用 sensor.warningThreshold 和 sensor.criticalThreshold)
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
