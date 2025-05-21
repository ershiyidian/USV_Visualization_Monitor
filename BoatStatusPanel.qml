// BoatStatusPanel.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Rectangle {
    id: boatStatusPanel
    color: cardColor

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // 面板标题
        Text {
            text: "船只状态"
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

        // 主要内容区域 - 罗盘和数据并排
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 260
            color: Qt.rgba(1,1,1,0.05)
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                // 左侧罗盘
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 0.6
                    color: Qt.rgba(0,0,0,0.1)
                    radius: 5

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 5

                        Text {
                            text: "航向罗盘"
                            font.pixelSize: fontSize
                            font.bold: true
                            color: textColor
                            Layout.alignment: Qt.AlignCenter
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Canvas {
                                id: compassCanvas
                                anchors.centerIn: parent
                                width: Math.min(parent.width, parent.height) - 10
                                height: width

                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.reset();

                                    var centerX = width / 2;
                                    var centerY = height / 2;
                                    var radius = Math.min(width, height) / 2 - 8;

                                    // 绘制外圈
                                    ctx.beginPath();
                                    ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
                                    ctx.strokeStyle = borderColor;
                                    ctx.lineWidth = 2;
                                    ctx.stroke();

                                    // 绘制刻度和方向文字
                                    var directions = ["N", "E", "S", "W"];
                                    for (var i = 0; i < 360; i += 15) {
                                        var angle = (i - 90) * Math.PI / 180;
                                        var isMajor = i % 90 === 0;
                                        var start = isMajor ? radius - 15 : (i % 45 === 0 ? radius - 12 : radius - 8);
                                        var end = radius;

                                        ctx.beginPath();
                                        ctx.moveTo(
                                            centerX + Math.cos(angle) * start,
                                            centerY + Math.sin(angle) * start
                                        );
                                        ctx.lineTo(
                                            centerX + Math.cos(angle) * end,
                                            centerY + Math.sin(angle) * end
                                        );
                                        ctx.strokeStyle = textColor;
                                        ctx.lineWidth = isMajor ? 2 : 1;
                                        ctx.stroke();

                                        if (isMajor) {
                                            var dirIndex = (i / 90) % 4;
                                            ctx.fillStyle = textColor;
                                            ctx.font = "bold 16px sans-serif";
                                            ctx.textAlign = "center";
                                            ctx.textBaseline = "middle";
                                            ctx.fillText(
                                                directions[dirIndex],
                                                centerX + Math.cos(angle) * (radius - 30),
                                                centerY + Math.sin(angle) * (radius - 30)
                                            );
                                        }
                                    }

                                    // 绘制指针
                                    var heading = vesselModule.heading * Math.PI / 180;
                                    ctx.beginPath();
                                    ctx.moveTo(centerX, centerY);
                                    ctx.lineTo(
                                        centerX + Math.cos(heading - Math.PI / 2) * (radius - 25),
                                        centerY + Math.sin(heading - Math.PI / 2) * (radius - 25)
                                    );
                                    ctx.strokeStyle = accentColor;
                                    ctx.lineWidth = 3;
                                    ctx.stroke();

                                    // 绘制中心点
                                    ctx.beginPath();
                                    ctx.arc(centerX, centerY, 4, 0, Math.PI * 2);
                                    ctx.fillStyle = accentColor;
                                    ctx.fill();

                                    // 绘制当前航向文本
                                    ctx.fillStyle = textColor;
                                    ctx.font = "bold 20px sans-serif";
                                    ctx.textAlign = "center";
                                    ctx.textBaseline = "middle";
                                    ctx.fillText(
                                        vesselModule.heading.toFixed(1) + "°",
                                        centerX,
                                        centerY + radius / 2
                                    );
                                }

                                Timer {
                                    interval: 50
                                    running: true
                                    repeat: true
                                    onTriggered: compassCanvas.requestPaint()
                                }
                            }
                        }
                    }
                }

                // 右侧数据面板
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: Qt.rgba(0,0,0,0.1)
                    radius: 5

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15

                        // 位置信息
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: "位置信息"
                                font.pixelSize: fontSize
                                font.bold: true
                                color: textColor
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 70
                                color: Qt.rgba(0,0,0,0.1)
                                radius: 4

                                GridLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    columns: 2
                                    rowSpacing: 6
                                    columnSpacing: 8

                                    Text {
                                        text: "纬度:"
                                        color: textColor
                                        font.pixelSize: fontSize
                                    }

                                    Text {
                                        text: vesselModule.latitude.toFixed(6) + "°"
                                        color: accentColor
                                        font.pixelSize: fontSize
                                        font.family: "Consolas, monospace"
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "经度:"
                                        color: textColor
                                        font.pixelSize: fontSize
                                    }

                                    Text {
                                        text: vesselModule.longitude.toFixed(6) + "°"
                                        color: accentColor
                                        font.pixelSize: fontSize
                                        font.family: "Consolas, monospace"
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }

                        // 航行数据
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                text: "航行数据"
                                font.pixelSize: fontSize
                                font.bold: true
                                color: textColor
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 70
                                color: Qt.rgba(0,0,0,0.1)
                                radius: 4

                                GridLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    columns: 2
                                    rowSpacing: 6
                                    columnSpacing: 8

                                    Text {
                                        text: "航速:"
                                        color: textColor
                                        font.pixelSize: fontSize
                                    }

                                    Text {
                                        text: vesselModule.speed.toFixed(2) + " m/s"
                                        color: accentColor
                                        font.pixelSize: fontSize
                                        font.family: "Consolas, monospace"
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "航向:"
                                        color: textColor
                                        font.pixelSize: fontSize
                                    }

                                    Text {
                                        text: vesselModule.heading.toFixed(1) + "°"
                                        color: accentColor
                                        font.pixelSize: fontSize
                                        font.family: "Consolas, monospace"
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // 水泵控制和电机值显示
        Rectangle {
            Layout.fillWidth: true
            height: 220
            color: Qt.rgba(1,1,1,0.05)
            radius: 6

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                // 标题
                Text {
                    text: "控制面板"
                    font.pixelSize: fontSize
                    font.bold: true
                    color: textColor
                }

                // 水泵控制
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "水泵控制:"
                        color: textColor
                        font.pixelSize: fontSize
                    }

                    Item { Layout.fillWidth: true }

                    Switch {
                        checked: dataSource.pumpState

                        indicator: Rectangle {
                            width: 50
                            height: 26
                            radius: 13
                            color: parent.checked ? successColor : Qt.rgba(0.3, 0.3, 0.3, 1)

                            Rectangle {
                                x: parent.parent.checked ? parent.width - width - 3 : 3
                                y: 3
                                width: 20
                                height: 20
                                radius: 10
                                color: "white"

                                Behavior on x {
                                    NumberAnimation { duration: 200 }
                                }
                            }
                        }

                        contentItem: Text {
                            text: parent.checked ? "开启" : "关闭"
                            color: textColor
                            font.pixelSize: fontSize
                            leftPadding: 0
                            rightPadding: 60
                        }

                        onCheckedChanged: dataSource.pumpState = checked
                    }
                }

                // 电机1控制
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Text {
                        text: "电机1控制:"
                        color: textColor
                        font.pixelSize: fontSize
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        // 电机1滑块
                        Slider {
                            id: motor1Slider
                            Layout.fillWidth: true
                            from: 675
                            to: 1353
                            stepSize: 1
                            value: dataSource.motor1

                            background: Rectangle {
                                x: motor1Slider.leftPadding
                                y: motor1Slider.topPadding + motor1Slider.availableHeight / 2 - height / 2
                                width: motor1Slider.availableWidth
                                height: 4
                                radius: 2
                                color: Qt.rgba(0.2, 0.2, 0.2, 1)

                                Rectangle {
                                    width: motor1Slider.visualPosition * parent.width
                                    height: parent.height
                                    color: accentColor
                                    radius: 2
                                }
                            }

                            handle: Rectangle {
                                x: motor1Slider.leftPadding + motor1Slider.visualPosition * (motor1Slider.availableWidth - width)
                                y: motor1Slider.topPadding + motor1Slider.availableHeight / 2 - height / 2
                                width: 20
                                height: 20
                                radius: 10
                                color: motor1Slider.pressed ? Qt.darker(accentColor, 1.2) : accentColor
                                border.color: "white"
                                border.width: 1
                            }

                            onValueChanged: {
                                // 在中值附近时自动对齐到中值
                                if (Math.abs(value - 1013) < 10) {
                                    value = 1013;
                                }
                                dataSource.motor1 = value;
                            }
                        }

                        // 电机1数值显示
                        Text {
                            text: motor1Slider.value.toFixed(0)
                            color: accentColor
                            font.pixelSize: fontSize
                            font.family: "Consolas, monospace"
                            Layout.preferredWidth: 50
                            horizontalAlignment: Text.AlignRight
                        }

                        // 重置按钮
                        Button {
                            width: 24
                            height: 24
                            flat: true

                            contentItem: Text {
                                text: "⟲"
                                color: textColor
                                font.pixelSize: fontSize
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                motor1Slider.value = 1013;
                            }

                            background: Rectangle {
                                color: parent.hovered ? Qt.rgba(1,1,1,0.1) : "transparent"
                                radius: 12
                            }
                        }
                    }

                    // 电机2控制
                    Text {
                        text: "电机2控制:"
                        color: textColor
                        font.pixelSize: fontSize
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        // 电机2滑块
                        Slider {
                            id: motor2Slider
                            Layout.fillWidth: true
                            from: 675
                            to: 1353
                            stepSize: 1
                            value: dataSource.motor2

                            background: Rectangle {
                                x: motor2Slider.leftPadding
                                y: motor2Slider.topPadding + motor2Slider.availableHeight / 2 - height / 2
                                width: motor2Slider.availableWidth
                                height: 4
                                radius: 2
                                color: Qt.rgba(0.2, 0.2, 0.2, 1)

                                Rectangle {
                                    width: motor2Slider.visualPosition * parent.width
                                    height: parent.height
                                    color: accentColor
                                    radius: 2
                                }
                            }

                            handle: Rectangle {
                                x: motor2Slider.leftPadding + motor2Slider.visualPosition * (motor2Slider.availableWidth - width)
                                y: motor2Slider.topPadding + motor2Slider.availableHeight / 2 - height / 2
                                width: 20
                                height: 20
                                radius: 10
                                color: motor2Slider.pressed ? Qt.darker(accentColor, 1.2) : accentColor
                                border.color: "white"
                                border.width: 1
                            }

                            onValueChanged: {
                                // 中值对齐
                                if (Math.abs(value - 1013) < 10) {
                                    value = 1013;
                                }
                                dataSource.motor2 = value;
                            }
                        }

                        // 电机2数值显示
                        Text {
                            text: motor2Slider.value.toFixed(0)
                            color: accentColor
                            font.pixelSize: fontSize
                            font.family: "Consolas, monospace"
                            Layout.preferredWidth: 50
                            horizontalAlignment: Text.AlignRight
                        }

                        // 重置按钮
                        Button {
                            width: 24
                            height: 24
                            flat: true

                            contentItem: Text {
                                text: "⟲"
                                color: textColor
                                font.pixelSize: fontSize
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                motor2Slider.value = 1013;
                            }

                            background: Rectangle {
                                color: parent.hovered ? Qt.rgba(1,1,1,0.1) : "transparent"
                                radius: 12
                            }
                        }
                    }
                }

                // 控制按钮（全部停止/全速前进）
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Button {
                        text: "全部停止"
                        Layout.fillWidth: true

                        contentItem: Text {
                            text: parent.text
                            color: textColor
                            font.pixelSize: fontSize
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            color: parent.down ? Qt.darker(dangerColor, 1.2) :
                                   parent.hovered ? dangerColor : Qt.rgba(0.7, 0.2, 0.2, 1)
                            radius: 4
                        }

                        onClicked: {
                            motor1Slider.value = 1013;
                            motor2Slider.value = 1013;
                        }
                    }

                    Button {
                        text: "全速前进"
                        Layout.fillWidth: true

                        contentItem: Text {
                            text: parent.text
                            color: textColor
                            font.pixelSize: fontSize
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            color: parent.down ? Qt.darker(successColor, 1.2) :
                                   parent.hovered ? successColor : Qt.rgba(0.2, 0.7, 0.2, 1)
                            radius: 4
                        }

                        onClicked: {
                            motor1Slider.value = 1353;
                            motor2Slider.value = 1353;
                        }
                    }
                }
            }
        }
    }
}
