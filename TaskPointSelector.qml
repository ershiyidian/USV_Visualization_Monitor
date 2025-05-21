// TaskPointSelector.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import QtPositioning 5.15

Rectangle {
    id: taskPointSelector
    color: cardColor

    // 属性定义
    property bool isSettingHomePoint: false
    property var taskPoints: []
    property alias taskPointsModel: taskPointsModel

    // 移除重复的信号声明，使用model的onCountChanged替代
    // 注意：删除了原来的 signal taskPointsChanged() 声明

    // 任务点模型
    ListModel {
        id: taskPointsModel
        // 当模型内容变化时触发任务点更新
        onCountChanged: updateTaskPoints()
    }

    // 添加内部函数来处理任务点更新
    function updateTaskPoints() {
        // 这会通知地图面板更新任务点显示
        if (mapViewPanel) {
            // 调用地图视图的更新函数
            mapViewPanel.updateTaskPointsDisplay(taskPoints, taskPointsModel)
        }
    }

    // 添加任务点
    function addTaskPoint(lat, lon) {
        // 获取当前时间戳（毫秒级）
        let timestamp = Date.now();

        if (isSettingHomePoint) {
            // 设置Home点
            if (mapViewPanel) {
                mapViewPanel.setHomePoint(lat, lon, timestamp);
            }
            isSettingHomePoint = false;
            console.log("Home点已设置：", lat, lon, timestamp);
        } else {
            // 添加普通任务点
            var newPoint = {
                latitude: lat,
                longitude: lon,
                timestamp: new Date().toISOString()
            };

            taskPoints.push(newPoint);
            taskPointsModel.append(newPoint);
            warningMessage.showWarning("已添加任务点 #" + taskPoints.length, accentColor);
        }
    }

    // 删除任务点
    function removeTaskPoint(index) {
        if (index >= 0 && index < taskPoints.length) {
            taskPoints.splice(index, 1);
            taskPointsModel.remove(index);
            warningMessage.showWarning("已删除任务点", accentColor);
        }
    }

    // 清空任务点
    function clearTaskPoints() {
        taskPoints = [];
        taskPointsModel.clear();
        warningMessage.showWarning("已清空所有任务点", accentColor);
    }

    // 设置Home点模式
    function setHomePointMode() {
        isSettingHomePoint = true;
        warningMessage.showWarning("请在地图上点击以设置Home点", accentColor);
    }

    // 面板布局
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // 面板标题
        Text {
            text: "任务点管理"
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

        // 输入区域
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 8
            columnSpacing: 12

            // 纬度输入
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "纬度:"
                    color: textColor
                    font.pixelSize: fontSize
                }

                TextField {
                    id: latInput
                    Layout.fillWidth: true
                    placeholderText: "例如: 31.2345"
                    color: textColor
                    font.pixelSize: fontSize
                    validator: DoubleValidator {
                        bottom: -90
                        top: 90
                        decimals: 6
                    }

                    background: Rectangle {
                        color: Qt.rgba(1,1,1,0.1)
                        radius: 4
                        border.color: latInput.activeFocus ? accentColor : borderColor
                        border.width: latInput.activeFocus ? 2 : 1
                    }
                }
            }

            // 经度输入
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "经度:"
                    color: textColor
                    font.pixelSize: fontSize
                }

                TextField {
                    id: lonInput
                    Layout.fillWidth: true
                    placeholderText: "例如: 121.4567"
                    color: textColor
                    font.pixelSize: fontSize
                    validator: DoubleValidator {
                        bottom: -180
                        top: 180
                        decimals: 6
                    }

                    background: Rectangle {
                        color: Qt.rgba(1,1,1,0.1)
                        radius: 4
                        border.color: lonInput.activeFocus ? accentColor : borderColor
                        border.width: lonInput.activeFocus ? 2 : 1
                    }
                }
            }
        }

        // 操作按钮
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                text: "添加点"
                Layout.fillWidth: true
                onClicked: {
                    if (latInput.acceptableInput && lonInput.acceptableInput) {
                        addTaskPoint(parseFloat(latInput.text), parseFloat(lonInput.text));
                        latInput.text = "";
                        lonInput.text = "";
                    }
                }

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

            Button {
                text: "设置Home"
                Layout.fillWidth: true
                onClicked: setHomePointMode()

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
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                text: "清空所有点"
                Layout.fillWidth: true
                onClicked: clearTaskPoints()

                contentItem: Text {
                    text: parent.text
                    color: textColor
                    font.pixelSize: fontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.down ? Qt.darker(dangerColor, 1.2) :
                           parent.hovered ? dangerColor : Qt.darker(dangerColor, 1.1)
                    radius: 4
                }
            }

            // 发送任务点按钮
            Button {
                text: "发送任务点"
                Layout.fillWidth: true

                // 只有当存在Home点和至少一个任务点时才启用
                enabled: mapViewPanel.homePoint !== null && taskPoints.length > 0

                contentItem: Text {
                    text: parent.text
                    color: textColor
                    font.pixelSize: fontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    opacity: parent.enabled ? 1.0 : 0.5
                }

                background: Rectangle {
                    color: parent.enabled ? (parent.down ? Qt.darker(accentColor, 1.2) :
                                          parent.hovered ? accentColor : Qt.darker(accentColor, 1.1)) :
                                          Qt.rgba(0.3, 0.3, 0.3, 1)
                    radius: 4
                }

                onClicked: {
                    // 准备发送数据
                    var stringArray = [];

                    // 首先添加Home点数据
                    if (mapViewPanel.homePoint) {
                        var home = mapViewPanel.homePoint;

                        // 格式化时间戳
                        var timestamp = Qt.formatDateTime(new Date(home.timestamp), "yyyy-MM-dd hh:mm:ss");
                        var homeStr = home.coordinate.latitude.toFixed(6) + "," +
                                    home.coordinate.longitude.toFixed(6) + "," +
                                    timestamp;

                        stringArray.push(homeStr);
                        console.log("Home点数据：", homeStr);
                    } else {
                        warningMessage.showWarning("未设置Home点！", warningColor);
                        return;
                    }

                    // 然后添加任务点数据
                    for (var i = 0; i < taskPoints.length; i++) {
                        var point = taskPoints[i];

                        // 确保时间戳的正确格式
                        var pointTimestamp = "";
                        if (typeof point.timestamp === 'string') {
                            pointTimestamp = point.timestamp;
                        } else if (point.timestamp instanceof Date) {
                            pointTimestamp = Qt.formatDateTime(point.timestamp, "yyyy-MM-dd hh:mm:ss");
                        } else {
                            // 使用当前时间作为默认值
                            pointTimestamp = Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm:ss");
                        }

                        var pointStr = point.latitude.toFixed(6) + "," +
                                     point.longitude.toFixed(6) + "," +
                                     pointTimestamp;

                        stringArray.push(pointStr);
                    }

                    // 任务点数量限制检查
                    var maxPoints = 50; // 与后端常量保持一致
                    if (taskPoints.length > maxPoints) {
                        warningMessage.showWarning("任务点数量超出上限(" + maxPoints + ")，将只发送前" + maxPoints + "个点", warningColor);
                    }

                    console.log("准备发送点的数据：", stringArray);

                    // 调用数据源发送数据
                    try {
                        if (dataSource && stringArray.length > 0) {
                            dataSource.sendData(stringArray);
                            warningMessage.showWarning("任务点已发送 (" + Math.min(taskPoints.length, maxPoints) + " 个点)", successColor);
                        }
                    } catch (e) {
                        warningMessage.showWarning("发送失败: " + e, dangerColor);
                        console.error("发送任务点时出错:", e);
                    }
                }

                // 提示信息
                ToolTip.visible: hovered && !enabled
                ToolTip.text: mapViewPanel.homePoint === null ? "请先设置Home点" : "请添加至少一个任务点"
                ToolTip.delay: 500
            }
            }

        // 任务点列表标题
        Text {
            text: "已添加任务点 (" + taskPointsModel.count + ")"
            color: textColor
            font.pixelSize: fontSize
            font.bold: true
        }

        // 任务点列表
        ListView {
            id: taskPointListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: taskPointsModel
            clip: true
            spacing: 4

            // 空列表提示
            Text {
                anchors.centerIn: parent
                text: "尚未添加任务点"
                color: Qt.rgba(1,1,1,0.5)
                font.pixelSize: fontSize
                visible: taskPointsModel.count === 0
            }

            // 任务点列表项
            delegate: Rectangle {
                width: taskPointListView.width
                height: 60
                color: index % 2 === 0 ? Qt.rgba(0,0,0,0.2) : Qt.rgba(0,0,0,0.1)
                radius: 4

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    // 序号显示
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: accentColor

                        Text {
                            anchors.centerIn: parent
                            text: index + 1
                            color: "white"
                            font.pixelSize: fontSize
                            font.bold: true
                        }
                    }

                    // 坐标信息
                    Column {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "纬度: " + model.latitude.toFixed(6)
                            color: textColor
                            font.pixelSize: smallFontSize
                            font.family: "Consolas, monospace"
                        }

                        Text {
                            text: "经度: " + model.longitude.toFixed(6)
                            color: textColor
                            font.pixelSize: smallFontSize
                            font.family: "Consolas, monospace"
                        }
                    }

                    // 删除按钮
                    Button {
                        width: 30
                        height: 30
                        flat: true

                        contentItem: Text {
                            text: "×"
                            color: "white"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            color: parent.hovered ? dangerColor : Qt.rgba(1,0,0,0.3)
                            radius: 15
                        }

                        onClicked: removeTaskPoint(index)
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
