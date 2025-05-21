// MapViewPanel.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtLocation 5.15
import QtPositioning 5.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "." // 导入Theme单例

Item {
    id: mapViewPanel

    // 属性定义
    property var homePoint: null
    property var timestamp: null
    property var trajectoryPoints: []
    property bool followBoat: true

    // 设置Home点
    function setHomePoint(lat, lon, timestamp) {
        timestamp = new Date().getTime();
        homePoint = {
            coordinate: QtPositioning.coordinate(lat, lon),
            timestamp: timestamp
        };

        if (warningMessage) { // warningMessage 是 main.qml 中的全局消息组件
            warningMessage.showWarning(qsTr("Home点已设置"), Theme.secondaryColor); // 使用Theme成功色
        }
    }

    // 更新任务点显示
    function updateTaskPointsDisplay(points, model) {
        // 更新连接线
        if (points && points.length > 0) {
            var path = [];
            for (var i = 0; i < points.length; i++) {
                var point = points[i];
                path.push(QtPositioning.coordinate(point.latitude, point.longitude));
            }
            taskPathLine.path = path;
        } else {
            taskPathLine.path = [];
        }

        // 更新标记
        if (model) {
            taskMarkersView.model = model;
            taskMarkersView.delegate = taskPointDelegate;
        }
    }

    // 背景地图
    Map {
        id: map
        anchors.fill: parent
        plugin: Plugin { name: "osm" }
        center {
            latitude: vesselModule.latitude
            longitude: vesselModule.longitude
        }
        zoomLevel: 15

        // 监听船只位置更新并更新轨迹
        Connections {
            target: vesselModule
            function onDisplayDataChanged() {
                // 更新船只位置
                boatMarker.coordinate = QtPositioning.coordinate(
                    vesselModule.latitude,
                    vesselModule.longitude
                );

                // 如果开启了跟随模式，让地图中心跟随船只
                if (followBoat) {
                    map.center = boatMarker.coordinate;
                }

                // 添加新的轨迹点
                var newPoint = QtPositioning.coordinate(
                    vesselModule.latitude,
                    vesselModule.longitude
                );

                // 检查点是否有效
                if (isValidCoordinate(newPoint)) {
                    trajectoryPoints.push(newPoint);

                    // 限制轨迹点数量
                    if (trajectoryPoints.length > 1000) {
                        trajectoryPoints.shift();
                    }

                    // 更新轨迹线 - 确保所有点都有效
                    var validTrajectory = [];
                    for (var i = 0; i < trajectoryPoints.length; i++) {
                        if (isValidCoordinate(trajectoryPoints[i])) {
                            validTrajectory.push(trajectoryPoints[i]);
                        }
                    }

                    // 只有在有有效点时才更新路径
                    if (validTrajectory.length > 0) {
                        trajectoryLine.path = validTrajectory;
                    }
                }
            }
        }

        // 检查坐标是否有效
        function isValidCoordinate(coord) {
            return coord &&
                   coord.latitude >= -90 && coord.latitude <= 90 &&
                   coord.longitude >= -180 && coord.longitude <= 180;
        }

        // 任务点点击处理
        MouseArea {
            anchors.fill: parent
            enabled: taskPointSelector.visible

            onClicked: {
                if (taskPointSelector.visible && !mapControlPanel.contains(
                    mapToItem(mapControlPanel, mouseX, mouseY))) {
                    var coord = map.toCoordinate(Qt.point(mouseX, mouseY));
                    taskPointSelector.addTaskPoint(coord.latitude, coord.longitude);
                }
            }
        }

        // Home点标记
        MapQuickItem {
            id: homeMarker
            visible: homePoint !== null
            coordinate: homePoint ? homePoint.coordinate : QtPositioning.coordinate(0, 0)
            anchorPoint.x: 20
            anchorPoint.y: 20

            sourceItem: Item {
                width: 40
                height: 40

                Rectangle {
                    id: homeIcon
                    anchors.centerIn: parent
                    width: 30
                    height: 30
                    color: Theme.secondaryColor // Home点使用Theme次要色 (绿色)
                    radius: 15
                    border.width: 2 // 边框略细一些
                    border.color: Theme.textColorOnDark // 边框颜色使用深色背景上的文本色

                    Text {
                        anchors.centerIn: parent
                        text: "H"
                        color: Theme.textColorOnDark // 文字颜色使用深色背景上的文本色
                        font.pixelSize: Theme.largeFontSize // 使用Theme大字号
                        font.bold: true
                    }
                }

                // 脉冲效果
                Rectangle {
                    anchors.centerIn: parent
                    width: 30
                    height: 30
                    color: "transparent"
                    radius: 15
                    border.width: 3
                    border.color: Theme.secondaryColor // 脉冲颜色与Home点一致
                    opacity: pulseAnim.running ? pulseAnim.opacity : 0
                    scale: pulseAnim.running ? pulseAnim.scale : 1

                    // 脉冲动画
                    SequentialAnimation {
                        id: pulseAnim
                        running: true
                        loops: Animation.Infinite

                        property real opacity: 0
                        property real scale: 1

                        // 扩散+淡出
                        ParallelAnimation {
                            NumberAnimation {
                                target: pulseAnim
                                property: "scale"
                                from: 1
                                to: 3
                                duration: 1500
                                easing.type: Easing.OutQuad
                            }
                            NumberAnimation {
                                target: pulseAnim
                                property: "opacity"
                                from: 0.7
                                to: 0
                                duration: 1500
                                easing.type: Easing.OutQuad
                            }
                        }

                        // 重置
                        PropertyAction {
                            target: pulseAnim
                            property: "scale"
                            value: 1
                        }
                        PropertyAction {
                            target: pulseAnim
                            property: "opacity"
                            value: 0.7
                        }
                    }
                }
            }

            z: 3
        }

        // 船只位置标记
        MapQuickItem {
            id: boatMarker
            coordinate: QtPositioning.coordinate(vesselModule.latitude, vesselModule.longitude)
            anchorPoint.x: 20
            anchorPoint.y: 20

            sourceItem: Item {
                width: 40
                height: 40

                // 船只图标
                Rectangle {
                    anchors.centerIn: parent
                    width: 30
                    height: 30
                    color: Theme.accentColor // 船只图标使用Theme强调色 (红色)
                    radius: 15
                    border.width: 2
                    border.color: Theme.textColorOnDark // 边框颜色

                    // 动态旋转，显示航向
                    transform: Rotation {
                        origin.x: 15
                        origin.y: 15
                        angle: vesselModule.heading
                    }

                    // 船头指示器 (箭头形状)
                    Path {
                        anchors.centerIn: parent
                        strokeColor: Theme.textColorOnDark // 箭头颜色
                        strokeWidth: 2
                        fillColor: "transparent" // 不填充，仅边框
                        pathElements: [
                            PathMove { x: 15; y: 5 }, // 调整点以适应30x30的矩形
                            PathLine { x: 15; y: 0 },
                            PathLine { x: 20; y: 7.5 },
                            PathMove { x: 15; y: 0 },
                            PathLine { x: 10; y: 7.5 }
                        ]
                        //向上平移箭头，使其在图标上半部分
                        y: -5
                    }
                }

                // 脉冲效果
                Rectangle {
                    anchors.centerIn: parent
                    width: 30
                    height: 30
                    color: "transparent"
                    radius: 15
                    border.width: 3
                    border.color: Theme.accentColor // 脉冲颜色与船只图标一致
                    opacity: boatPulseAnim.running ? boatPulseAnim.opacity : 0
                    scale: boatPulseAnim.running ? boatPulseAnim.scale : 1

                    // 脉冲动画
                    SequentialAnimation {
                        id: boatPulseAnim
                        running: true
                        loops: Animation.Infinite

                        property real opacity: 0
                        property real scale: 1

                        // 扩散+淡出
                        ParallelAnimation {
                            NumberAnimation {
                                target: boatPulseAnim
                                property: "scale"
                                from: 1
                                to: 3
                                duration: 1500
                                easing.type: Easing.OutQuad
                            }
                            NumberAnimation {
                                target: boatPulseAnim
                                property: "opacity"
                                from: 0.7
                                to: 0
                                duration: 1500
                                easing.type: Easing.OutQuad
                            }
                        }

                        // 重置
                        PropertyAction {
                            target: boatPulseAnim
                            property: "scale"
                            value: 1
                        }
                        PropertyAction {
                            target: boatPulseAnim
                            property: "opacity"
                            value: 0.7
                        }
                    }
                }
            }

            z: 3
        }

        // 船只轨迹线 - 使用MapPolyline
        MapPolyline { // 船只轨迹线
            id: trajectoryLine
            line.width: 3
            line.color: Theme.accentColor // 轨迹线使用Theme强调色
            opacity: 0.7
            path: []
            z: 1
        }

        // 任务点连线 - 使用MapPolyline
        MapPolyline { // 任务路径线
            id: taskPathLine
            line.width: 3
            line.color: Theme.primaryColor // 任务路径线使用Theme主色调
            opacity: 0.7
            // 初始化为空数组，而不是null或undefined
            path: []
            z: 1
        }

        // 任务点标记
        MapItemView {
            id: taskMarkersView
            z: 2
            model: [] // 初始化为空数组
        }
    }

    // 地图控制面板
    Rectangle {
        id: mapControlPanel
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 20
        }
        width: Theme.controlHeight * 1.5 // 基于Theme调整大小
        height: Theme.controlHeight * 5 // 基于Theme调整大小
        color: Theme.darkThemeCardColor // 使用Theme深色卡片背景
        radius: Theme.buttonCornerRadius // 使用Theme按钮圆角
        opacity: 0.9

        layer.enabled: true
        layer.effect: DropShadow { // 阴影效果
            horizontalOffset: 0
            verticalOffset: 2
            radius: 8.0
            samples: 17
            color: Theme.shadowColor // 使用Theme阴影色
        }

        function contains(point) { // 检查点是否在面板内
            return point.x >= 0 && point.y >= 0 &&
                   point.x <= width && point.y <= height;
        }

        Column {
            anchors.centerIn: parent
            spacing: 20

            // 放大按钮
            MapControlButton {
                text: "+"
                onClicked: if (map.zoomLevel < 20) map.zoomLevel += 1
            }

            // 缩小按钮
            MapControlButton {
                text: "−"
                onClicked: if (map.zoomLevel > 2) map.zoomLevel -= 1
            }

            // 跟随按钮
            MapControlButton {
                text: "⊙"
                isActive: followBoat
                onClicked: {
                    followBoat = !followBoat;
                    if (followBoat) {
                        map.center = QtPositioning.coordinate(
                            vesselModule.latitude,
                            vesselModule.longitude
                        );
                    }
                }
            }

            // 中心点按钮
            MapControlButton {
                text: "⌖"
                onClicked: {
                    map.center = QtPositioning.coordinate(
                        vesselModule.latitude,
                        vesselModule.longitude
                    );
                }
            }
        }
    }

    // 地图控制按钮
    // 地图控制按钮组件
    component MapControlButton: Rectangle {
        property string text: "" // 按钮文本 (图标)
        property bool isActive: false // 按钮是否处于激活状态 (例如跟随模式)
        signal clicked() // 点击信号

        width: Theme.controlHeight * 1.2 // 按钮宽度
        height: Theme.controlHeight * 1.2 // 按钮高度
        radius: width / 2 // 圆形按钮
        // color: mouseArea.pressed ? Qt.darker(accentColor, 1.3) : // 旧颜色逻辑
        //        mouseArea.containsMouse ? accentColor :
        //        isActive ? Qt.lighter(accentColor, 1.2) : Qt.rgba(1,1,1,0.2)
        color: mouseArea.pressed ? Qt.darker(Theme.primaryColor, 1.3) : // 按下时颜色变深
               mouseArea.containsMouse ? Theme.primaryColor : // 悬停时使用主色调
               isActive ? Qt.lighter(Theme.primaryColor, 1.2) : // 激活时颜色变浅
               Qt.rgba(Theme.textColorOnDark.r, Theme.textColorOnDark.g, Theme.textColorOnDark.b, 0.2) // 默认半透明背景

        Text {
            anchors.centerIn: parent
            text: parent.text
            color: Theme.textColorOnDark // 文本颜色
            font.pixelSize: Theme.defaultFontSize * 1.2 // 稍大一点的字体
            font.bold: true
        }

        MouseArea { // 鼠标交互区域
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: parent.clicked()
        }

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    // 任务点代理
    Component {
        id: taskPointDelegate

        MapQuickItem {
            coordinate: QtPositioning.coordinate(model.latitude, model.longitude) // 任务点坐标
            anchorPoint.x: 15 // 锚点调整，使数字居中
            anchorPoint.y: 15

            sourceItem: Item {
                width: 30 // 标记大小
                height: 30

                Rectangle { // 任务点背景圆
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    color: Theme.primaryColor // 使用Theme主色调
                    radius: width / 2 // 圆形
                    border.width: 2
                    border.color: Theme.textColorOnDark // 边框颜色

                    Text { // 任务点序号
                        anchors.centerIn: parent
                        text: index + 1 // 显示序号 (从1开始)
                        color: Theme.textColorOnDark // 文本颜色
                        font.pixelSize: Theme.defaultFontSize // 使用Theme默认字号
                        font.bold: true
                    }
                }
            }
        }
    } // End of taskPointDelegate
}
