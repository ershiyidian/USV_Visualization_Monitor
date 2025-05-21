import QtQuick 2.15
import QtQuick.Controls 2.15
import QtCharts 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Item {
    id: sensorChart

    // ========== 公共API（保持兼容） ==========
    property string title: ""                      // 图表标题
    property string unit: ""                       // 单位
    property color chartColor: accentColor         // 主图表颜色
    property alias lineSeries: lineSeriesObj       // 数据线对象
    property real value: 0                         // 当前值
    property bool showChart: true                  // 是否显示图表
    property bool autoScroll: true                 // 是否自动滚动

    // 警戒阈值
    property real warningThreshold: 0              // 警告阈值
    property real criticalThreshold: 0             // 严重阈值

    // 当前状态 (0=正常, 1=超标, 2=严重超标)
    property int currentStatus: 0

    // ========== 新增内部属性 ==========
    // 性能优化相关
    property bool suppressUpdates: false           // 是否暂停更新
    property bool needsAxisUpdate: false           // 是否需要更新坐标轴
    property int updateInterval: 100               // 更新间隔(ms)

    // 缓存颜色
    property color currentValueColor: chartColor
    property color currentBackgroundColor: Qt.rgba(chartColor.r, chartColor.g, chartColor.b, 0.2)

    // 图表配置
    property bool showDataLabels: false            // 是否显示数据点标签
    property bool showArea: false                  // 是否显示面积图
    property bool showStatistics: true             // 是否显示统计信息
    property bool showGrid: true                   // 是否显示网格线
    property bool showMinorGrid: true              // 是否显示次要网格线

    // 数据统计
    property var statistics: ({
        min: 0,
        max: 0,
        avg: 0,
        count: 0,
        lastUpdated: new Date()
    })

    // 图表类型选项
    readonly property var chartTypes: ["线图", "面积图"]

    // 布局尺寸
    Layout.preferredWidth: 320
    Layout.preferredHeight: 180

    // ========== 方法实现 ==========

    // 检查传感器状态 - 优化版本
    function checkStatus(val) {
        var newStatus = 0;

        if (criticalThreshold > 0 && val >= criticalThreshold) {
            newStatus = 2;
        } else if (warningThreshold > 0 && val >= warningThreshold) {
            newStatus = 1;
        }

        // 只在状态变化时更新
        if (newStatus !== currentStatus) {
            currentStatus = newStatus;

            // 更新颜色缓存
            if (currentStatus === 2) {
                lineSeriesObj.color = dangerColor;
                currentValueColor = dangerColor;
                currentBackgroundColor = Qt.rgba(dangerColor.r, dangerColor.g, dangerColor.b, 0.3);
                // 只在状态变化时发送警告
                if (warningMessage) {
                    warningMessage.showWarning(title + "严重超标: " + val.toFixed(2) + unit, dangerColor);
                }
            } else if (currentStatus === 1) {
                lineSeriesObj.color = warningColor;
                currentValueColor = warningColor;
                currentBackgroundColor = Qt.rgba(warningColor.r, warningColor.g, warningColor.b, 0.3);
                if (warningMessage) {
                    warningMessage.showWarning(title + "超标: " + val.toFixed(2) + unit, warningColor);
                }
            } else {
                lineSeriesObj.color = chartColor;
                currentValueColor = chartColor;
                currentBackgroundColor = Qt.rgba(chartColor.r, chartColor.g, chartColor.b, 0.2);
            }

            // 更新图表样式
            updateChartStyle();
        }

        return currentStatus;
    }

    // 更新图表样式
    function updateChartStyle() {
        // 根据显示模式切换图表类型
        if (showArea) {
            // 面积图模式
            areaSeriesObj.visible = true;
            lineSeriesObj.width = 2;
            lineSeriesObj.pointsVisible = false;

            // 更新面积图颜色
            var baseColor = lineSeriesObj.color;
            var gradientStart = Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.5);
            var gradientEnd = Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.05);

            // 设置渐变
            areaSeriesObj.color = gradientStart;
            areaSeriesObj.borderColor = baseColor;
            areaSeriesObj.borderWidth = 2;
        } else {
            // 线图模式
            areaSeriesObj.visible = false;
            lineSeriesObj.width = 2.5;
            lineSeriesObj.pointsVisible = showDataLabels;
        }

        // 设置网格线可见性
        xAxis.gridVisible = showGrid;
        yAxis.gridVisible = showGrid;
        xAxis.minorGridVisible = showMinorGrid;
        yAxis.minorGridVisible = showMinorGrid;
    }

    // 更新坐标轴范围 - 节流版本
    function updateAxisRanges() {
        if (suppressUpdates || lineSeriesObj.count === 0) return;

        // 设置更新抑制标记
        suppressUpdates = true;

        var latestX = lineSeriesObj.at(lineSeriesObj.count - 1).x;
        var timeWindow = calculateTimeWindow(latestX);

        // 自动滚动模式下更新X轴
        if (autoScroll) {
            xAxis.max = latestX;
            xAxis.min = Math.max(0, latestX - timeWindow);
        }

        // 计算可见数据范围内的统计信息
        var minY = Number.MAX_VALUE;
        var maxY = Number.MIN_VALUE;
        var sumY = 0;
        var visiblePoints = 0;

        // 只分析可见窗口内的数据点
        for (var i = 0; i < lineSeriesObj.count; i++) {
            var point = lineSeriesObj.at(i);
            if (point.x >= xAxis.min && point.x <= xAxis.max) {
                minY = Math.min(minY, point.y);
                maxY = Math.max(maxY, point.y);
                sumY += point.y;
                visiblePoints++;
            }
        }

        // 更新统计信息
        if (visiblePoints > 0) {
            statistics.min = minY;
            statistics.max = maxY;
            statistics.avg = sumY / visiblePoints;
            statistics.count = visiblePoints;
            statistics.lastUpdated = new Date();
        }

        // 计算Y轴范围
        if (minY !== Number.MAX_VALUE && maxY !== Number.MIN_VALUE) {
            var range = maxY - minY;

            // 确保有最小范围
            if (range < 1) range = 1;

            // 智能设置Y轴范围
            var paddingFactor = 0.15; // 上下留15%的空间
            yAxis.min = Math.max(0, minY - range * paddingFactor);
            yAxis.max = maxY + range * paddingFactor;

            // 确保警戒线在范围内
            if (warningThreshold > 0) {
                yAxis.max = Math.max(yAxis.max, warningThreshold * 1.1);

                // 更新警戒线，避免频繁重绘
                if (warningLine.count !== 2 ||
                    warningLine.at(0).x !== xAxis.min ||
                    warningLine.at(1).x !== xAxis.max) {
                    warningLine.clear();
                    warningLine.append(xAxis.min, warningThreshold);
                    warningLine.append(xAxis.max, warningThreshold);
                }
                warningLine.visible = true;
            } else {
                warningLine.visible = false;
            }

            // 更新严重警戒线
            if (criticalThreshold > 0) {
                yAxis.max = Math.max(yAxis.max, criticalThreshold * 1.1);

                if (criticalLine.count !== 2 ||
                    criticalLine.at(0).x !== xAxis.min ||
                    criticalLine.at(1).x !== xAxis.max) {
                    criticalLine.clear();
                    criticalLine.append(xAxis.min, criticalThreshold);
                    criticalLine.append(xAxis.max, criticalThreshold);
                }
                criticalLine.visible = true;
            } else {
                criticalLine.visible = false;
            }

            // 如果使用面积图，确保Y轴始终从0开始
            if (showArea) {
                yAxis.min = 0;
            }
        }

        // 智能设置刻度
        xAxis.tickCount = calculateTickCount();
        yAxis.tickCount = calculateYTickCount(yAxis.min, yAxis.max);

        // 更新区域图上边界
        upperLine.clear();
        for (var j = 0; j < lineSeriesObj.count; j++) {
            upperLine.append(lineSeriesObj.at(j).x, lineSeriesObj.at(j).y);
        }

        // 使用定时器控制更新频率
        resetTimer.restart();
    }

    // 计算合适的X轴刻度数
    function calculateTickCount() {
        var timeRange = xAxis.max - xAxis.min;
        if (timeRange <= 30) return 6;         // 30秒内
        else if (timeRange <= 60) return 7;    // 1分钟内
        else if (timeRange <= 300) return 6;   // 5分钟内
        else if (timeRange <= 600) return 7;   // 10分钟内
        else if (timeRange <= 1800) return 7;  // 30分钟内
        else if (timeRange <= 3600) return 7;  // 1小时内
        else return 8;                         // 更长时间
    }

    // 计算合适的Y轴刻度数
    function calculateYTickCount(min, max) {
        var range = max - min;
        if (range <= 10) return 6;      // 范围很小，使用更多刻度
        else if (range <= 50) return 6;  // 中等范围
        else if (range <= 100) return 6; // 较大范围
        else return 7;                   // 大范围，更多刻度
    }

    // 计算时间窗口
    function calculateTimeWindow(currentMaxX) {
        if (currentMaxX <= 60) return 60;        // 1分钟
        else if (currentMaxX <= 300) return 300;  // 5分钟
        else if (currentMaxX <= 600) return 600;  // 10分钟
        else if (currentMaxX <= 1800) return 1800; // 30分钟
        else if (currentMaxX <= 3600) return 3600; // 1小时
        else if (currentMaxX <= 10800) return 10800; // 3小时
        else return Math.ceil(currentMaxX / 3600) * 3600; // 按小时取整
    }

    // 格式化时间标签
    function formatTimeLabel(seconds) {
        var hours = Math.floor(seconds / 3600);
        var minutes = Math.floor((seconds % 3600) / 60);
        var secs = Math.floor(seconds % 60);

        if (hours > 0) {
            return hours + ":" +
                   (minutes < 10 ? "0" : "") + minutes + ":" +
                   (secs < 10 ? "0" : "") + secs;
        } else {
            return minutes + ":" + (secs < 10 ? "0" : "") + secs;
        }
    }

    // 导出图表数据到CSV
    function exportToCSV() {
        var csvContent = "时间,值\n";
        for (var i = 0; i < lineSeriesObj.count; i++) {
            var point = lineSeriesObj.at(i);
            csvContent += formatTimeLabel(point.x) + "," + point.y.toFixed(2) + "\n";
        }

        // 返回CSV内容，由外部处理保存
        return csvContent;
    }

    // 分析趋势并预测
    function analyzeTrend() {
        if (lineSeriesObj.count < 5) return { trend: "数据不足", prediction: 0 };

        // 计算简单线性回归
        var n = Math.min(30, lineSeriesObj.count); // 使用最近30个点
        var sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
        var startIdx = lineSeriesObj.count - n;

        for (var i = startIdx; i < lineSeriesObj.count; i++) {
            var point = lineSeriesObj.at(i);
            sumX += point.x;
            sumY += point.y;
            sumXY += point.x * point.y;
            sumXX += point.x * point.x;
        }

        var avgX = sumX / n;
        var avgY = sumY / n;
        var slope = (sumXY - sumX * avgY) / (sumXX - sumX * avgX);

        // 预测未来5个单位时间的值
        var lastX = lineSeriesObj.at(lineSeriesObj.count - 1).x;
        var prediction = avgY + slope * (lastX + 5 - avgX);

        // 判断趋势
        var trend = "稳定";
        if (slope > 0.1) trend = "上升";
        else if (slope < -0.1) trend = "下降";

        return {
            trend: trend,
            prediction: prediction,
            slope: slope
        };
    }

    // ========== 组件生命周期 ==========

    Component.onCompleted: {
        updateChartStyle();
    }

    // ========== UI实现 ==========
    // 图表容器
    Rectangle {
        anchors.fill: parent
        color: cardColor
        radius: 6

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 2
            radius: 6.0
            samples: 17
            color: Qt.rgba(0, 0, 0, 0.3)
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4

            // 头部工具栏
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                spacing: 5

                // 标题
                Text {
                    text: title
                    font.pixelSize: fontSize
                    font.bold: true
                    color: textColor
                }

                // 显示预测趋势 (只在有足够数据时显示)
                Rectangle {
                    visible: lineSeriesObj.count >= 5
                    Layout.preferredHeight: 22
                    Layout.preferredWidth: trendText.width + 14
                    radius: 3
                    color: {
                        var trend = analyzeTrend();
                        if (trend.trend === "上升") return Qt.rgba(dangerColor.r, dangerColor.g, dangerColor.b, 0.2);
                        else if (trend.trend === "下降") return Qt.rgba(successColor.r, successColor.g, successColor.b, 0.2);
                        return Qt.rgba(0.5, 0.5, 0.5, 0.2);
                    }

                    Text {
                        id: trendText
                        anchors.centerIn: parent
                        text: {
                            var trend = analyzeTrend();
                            return trend.trend + " (" + trend.prediction.toFixed(1) + unit + ")";
                        }
                        font.pixelSize: smallFontSize
                        color: {
                            var trend = analyzeTrend();
                            if (trend.trend === "上升") return dangerColor;
                            else if (trend.trend === "下降") return successColor;
                            return textColor;
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // 图表类型选择器
                ComboBox {
                    id: chartTypeCombo
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 24
                    model: chartTypes
                    currentIndex: showArea ? 1 : 0

                    contentItem: Text {
                        text: chartTypeCombo.displayText
                        color: textColor
                        font.pixelSize: smallFontSize
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 6
                    }

                    background: Rectangle {
                        color: Qt.rgba(1,1,1,0.1)
                        radius: 3
                    }

                    onCurrentIndexChanged: {
                        showArea = (currentIndex === 1);
                        updateChartStyle();
                    }

                    popup: Popup {
                        y: chartTypeCombo.height
                        width: chartTypeCombo.width
                        implicitHeight: contentItem.implicitHeight
                        padding: 1

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: chartTypeCombo.popup.visible ? chartTypeCombo.delegateModel : null

                            ScrollBar.vertical: ScrollBar {
                                active: true
                            }
                        }

                        background: Rectangle {
                            color: darkColor
                            border.color: borderColor
                            radius: 3
                        }
                    }
                }

                // 自动滚动开关
                Switch {
                    id: scrollSwitch
                    checked: autoScroll
                    scale: 0.7
                    padding: 0

                    onCheckedChanged: {
                        autoScroll = checked;
                        if (checked) {
                            needsAxisUpdate = true;
                            if (!suppressUpdates) {
                                updateAxisRanges();
                            }
                        }
                    }

                    indicator: Rectangle {
                        width: 36
                        height: 18
                        radius: 9
                        color: scrollSwitch.checked ? accentColor : borderColor

                        Rectangle {
                            x: scrollSwitch.checked ? parent.width - width - 2 : 2
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
                        text: "自动"
                        font.pixelSize: smallFontSize
                        color: textColor
                        leftPadding: scrollSwitch.indicator.width + 4
                    }
                }

                // 当前值显示
                Rectangle {
                    Layout.preferredWidth: valueText.width + 16
                    Layout.preferredHeight: 22
                    radius: 3
                    color: currentBackgroundColor

                    Text {
                        id: valueText
                        anchors.centerIn: parent
                        text: value.toFixed(2) + unit
                        font.pixelSize: fontSize
                        font.bold: currentStatus > 0
                        color: currentValueColor
                    }
                }
            }

            // 统计信息栏
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 22
                color: Qt.rgba(0, 0, 0, 0.2)
                radius: 3
                visible: showStatistics

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 12

                    Text {
                        text: "最小值: " + statistics.min.toFixed(2) + unit
                        font.pixelSize: smallFontSize
                        color: textColor
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "平均值: " + statistics.avg.toFixed(2) + unit
                        font.pixelSize: smallFontSize
                        color: textColor
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "最大值: " + statistics.max.toFixed(2) + unit
                        font.pixelSize: smallFontSize
                        color: textColor
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "数据点: " + statistics.count
                        font.pixelSize: smallFontSize
                        color: textColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // 主图表区域
            ChartView {
                id: chartView
                Layout.fillWidth: true
                Layout.fillHeight: true
                antialiasing: true
                legend.visible: false
                backgroundColor: "transparent"
                animationOptions: ChartView.NoAnimation // 禁用动画提高性能
                dropShadowEnabled: false // 禁用阴影提高性能

                // 精简边距，获得更大的绘图区域
                margins {
                    top: 5
                    bottom: 5
                    left: 5
                    right: 5
                }

                // X轴 - 专业配置
                ValueAxis {
                    id: xAxis
                    min: 0
                    max: 60
                    tickCount: 7
                    labelFormat: function(value) { return formatTimeLabel(value); }
                    visible: true
                    gridVisible: showGrid
                    minorGridVisible: showMinorGrid
                    minorTickCount: 1
                    color: borderColor
                    gridLineColor: Qt.rgba(chartGridColor.r, chartGridColor.g, chartGridColor.b, 0.3)
                    minorGridLineColor: Qt.rgba(chartGridColor.r, chartGridColor.g, chartGridColor.b, 0.15)
                    labelsColor: textColor
                    labelsFont.pixelSize: smallFontSize
                    titleText: "时间"
                    titleFont.pixelSize: smallFontSize
                    titleVisible: true
                }

                // Y轴 - 专业配置
                ValueAxis {
                    id: yAxis
                    min: 0
                    max: 100
                    tickCount: 6
                    labelFormat: "%.1f"
                    visible: true
                    gridVisible: showGrid
                    minorGridVisible: showMinorGrid
                    minorTickCount: 1
                    color: borderColor
                    gridLineColor: Qt.rgba(chartGridColor.r, chartGridColor.g, chartGridColor.b, 0.3)
                    minorGridLineColor: Qt.rgba(chartGridColor.r, chartGridColor.g, chartGridColor.b, 0.15)
                    labelsColor: textColor
                    labelsFont.pixelSize: smallFontSize
                    titleText: title + (unit ? " (" + unit + ")" : "")
                    titleFont.pixelSize: smallFontSize
                    titleVisible: true
                }

                // 数据线系列
                LineSeries {
                    id: lineSeriesObj
                    axisX: xAxis
                    axisY: yAxis
                    color: chartColor
                    width: 2.5
                    pointsVisible: showDataLabels
                    pointLabelsVisible: showDataLabels
                    pointLabelsFormat: "@yPoint"
                    pointLabelsColor: textColor
                    pointLabelsClipping: true
                    useOpenGL: true // 使用OpenGL加速

                    // 当点添加时触发更新，带节流
                    onPointAdded: {
                        checkStatus(value);
                        if (suppressUpdates) {
                            needsAxisUpdate = true;
                        } else {
                            updateAxisRanges();
                        }
                    }
                }

                // 面积图上边界
                LineSeries {
                    id: upperLine
                    axisX: xAxis
                    axisY: yAxis
                    visible: false
                }

                // 面积图系列
                AreaSeries {
                    id: areaSeriesObj
                    axisX: xAxis
                    axisY: yAxis
                    upperSeries: upperLine
                    color: Qt.rgba(chartColor.r, chartColor.g, chartColor.b, 0.3)
                    borderColor: chartColor
                    borderWidth: 2
                    visible: showArea
                    useOpenGL: true // 使用OpenGL加速
                }

                // 警戒线
                LineSeries {
                    id: warningLine
                    axisX: xAxis
                    axisY: yAxis
                    color: warningColor
                    width: 1.5
                    style: Qt.DashLine
                    visible: warningThreshold > 0
                    useOpenGL: true

                    // 警戒线标签
                    onVisibleChanged: {
                        if (visible && count > 0) {
                            var labelItem = warningLineLabel;
                            labelItem.text = "警告：" + warningThreshold.toFixed(1) + unit;
                            labelItem.visible = true;
                        } else {
                            warningLineLabel.visible = false;
                        }
                    }
                }

                // 严重警戒线
                LineSeries {
                    id: criticalLine
                    axisX: xAxis
                    axisY: yAxis
                    color: dangerColor
                    width: 1.5
                    style: Qt.DashLine
                    visible: criticalThreshold > 0
                    useOpenGL: true

                    // 严重警戒线标签
                    onVisibleChanged: {
                        if (visible && count > 0) {
                            var labelItem = criticalLineLabel;
                            labelItem.text = "危险：" + criticalThreshold.toFixed(1) + unit;
                            labelItem.visible = true;
                        } else {
                            criticalLineLabel.visible = false;
                        }
                    }
                }

                // 警戒线标签
                Rectangle {
                    id: warningLineLabel
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    y: {
                        if (warningThreshold <= 0) return 0;
                        return chartView.mapToPosition(Qt.point(0, warningThreshold), lineSeriesObj).y - height/2;
                    }
                    width: warningLabelText.width + 8
                    height: 18
                    radius: 2
                    color: Qt.rgba(warningColor.r, warningColor.g, warningColor.b, 0.8)
                    visible: warningLine.visible

                    Text {
                        id: warningLabelText
                        anchors.centerIn: parent
                        text: "警告：" + warningThreshold.toFixed(1) + unit
                        color: "white"
                        font.pixelSize: smallFontSize - 1
                    }
                }

                // 严重警戒线标签
                Rectangle {
                    id: criticalLineLabel
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    y: {
                        if (criticalThreshold <= 0) return 0;
                        return chartView.mapToPosition(Qt.point(0, criticalThreshold), lineSeriesObj).y - height/2;
                    }
                    width: criticalLabelText.width + 8
                    height: 18
                    radius: 2
                    color: Qt.rgba(dangerColor.r, dangerColor.g, dangerColor.b, 0.8)
                    visible: criticalLine.visible

                    Text {
                        id: criticalLabelText
                        anchors.centerIn: parent
                        text: "危险：" + criticalThreshold.toFixed(1) + unit
                        color: "white"
                        font.pixelSize: smallFontSize - 1
                    }
                }
            }

            // 底部工具栏
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 22
                spacing: 8
                visible: false  // 默认隐藏，可以通过属性控制显示

                // 网格线开关
                CheckBox {
                    text: "网格线"
                    checked: showGrid

                    indicator: Rectangle {
                        width: 16
                        height: 16
                        radius: 2
                        border.color: parent.checked ? accentColor : borderColor
                        border.width: 1
                        color: "transparent"

                        Rectangle {
                            anchors.centerIn: parent
                            width: 10
                            height: 10
                            radius: 1
                            color: accentColor
                            visible: parent.parent.checked
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: textColor
                        font.pixelSize: smallFontSize
                        leftPadding: parent.indicator.width + 4
                        verticalAlignment: Text.AlignVCenter
                    }

                    onCheckedChanged: {
                        showGrid = checked;
                        updateChartStyle();
                    }
                }

                // 数据点开关
                CheckBox {
                    text: "数据点"
                    checked: showDataLabels

                    indicator: Rectangle {
                        width: 16
                        height: 16
                        radius: 2
                        border.color: parent.checked ? accentColor : borderColor
                        border.width: 1
                        color: "transparent"

                        Rectangle {
                            anchors.centerIn: parent
                            width: 10
                            height: 10
                            radius: 1
                            color: accentColor
                            visible: parent.parent.checked
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: textColor
                        font.pixelSize: smallFontSize
                        leftPadding: parent.indicator.width + 4
                        verticalAlignment: Text.AlignVCenter
                    }

                    onCheckedChanged: {
                        showDataLabels = checked;
                        updateChartStyle();
                    }
                }

                // 统计信息开关
                CheckBox {
                    text: "统计信息"
                    checked: showStatistics

                    indicator: Rectangle {
                        width: 16
                        height: 16
                        radius: 2
                        border.color: parent.checked ? accentColor : borderColor
                        border.width: 1
                        color: "transparent"

                        Rectangle {
                            anchors.centerIn: parent
                            width: 10
                            height: 10
                            radius: 1
                            color: accentColor
                            visible: parent.parent.checked
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: textColor
                        font.pixelSize: smallFontSize
                        leftPadding: parent.indicator.width + 4
                        verticalAlignment: Text.AlignVCenter
                    }

                    onCheckedChanged: {
                        showStatistics = checked;
                    }
                }

                Item { Layout.fillWidth: true }

                // 导出按钮
                Button {
                    text: "导出数据"

                    contentItem: Text {
                        text: parent.text
                        color: textColor
                        font.pixelSize: smallFontSize
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.down ? Qt.darker(accentColor, 1.2) :
                               parent.hovered ? accentColor : Qt.darker(accentColor, 1.1)
                        radius: 3
                    }

                    onClicked: {
                        var csv = exportToCSV();
                        // 这里需要外部实现保存功能
                        console.log("导出数据:", csv.substring(0, 100) + "...");
                    }
                }
            }
}

        // 图表交互区域
        MouseArea {
            id: chartMouseArea
            x:chartView.x
            y:chartView.y
            width:chartView.width
            height:chartView.height
            //anchors.fill: chartView
            property real lastX: 0

            onPressed: {
                lastX = mouse.x;
                autoScroll = false;
                scrollSwitch.checked = false;
            }

            onPositionChanged: {
                if (pressed) {
                    var dx = (mouse.x - lastX) / width * (xAxis.max - xAxis.min);
                    xAxis.min -= dx;
                    xAxis.max -= dx;
                    lastX = mouse.x;
                    updateAxisRanges();
                }
            }

            onWheel: {
                var factor = wheel.angleDelta.y > 0 ? 0.8 : 1.2;
                var centerX = xAxis.min + (xAxis.max - xAxis.min) * mouse.x / width;
                var newSpan = (xAxis.max - xAxis.min) * factor;
                xAxis.min = centerX - newSpan * mouse.x / width;
                xAxis.max = xAxis.min + newSpan;
                autoScroll = false;
                scrollSwitch.checked = false;
                updateAxisRanges();
            }

            // 双击恢复自动滚动
            onDoubleClicked: {
                autoScroll = true;
                scrollSwitch.checked = true;
                updateAxisRanges();
            }
        }
    }

    // 数据点详情提示
    Rectangle {
        id: dataTooltip
        width: tooltipText.width + 12
        height: tooltipText.height + 8
        radius: 4
        color: Qt.rgba(0.1, 0.1, 0.1, 0.8)
        border.color: accentColor
        border.width: 1
        visible: false
        z: 10

        property real pointX: 0
        property real pointY: 0

        Text {
            id: tooltipText
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: smallFontSize
            text: value.toFixed(2) + unit + " @ " + formatTimeLabel(dataTooltip.pointX)
        }
    }

    // 更新控制定时器
    Timer {
        id: resetTimer
        interval: updateInterval
        repeat: false
        onTriggered: {
            suppressUpdates = false;
            if (needsAxisUpdate) {
                needsAxisUpdate = false;
                updateAxisRanges();
            }
        }
    }
}
