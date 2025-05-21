// BoatStatusPanel.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import "." // 导入Theme单例

Rectangle {
    id: boatStatusPanel
    // color: cardColor // 旧颜色
    color: Theme.darkThemeCardColor // 使用Theme中的深色卡片背景色

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.paddingLarge // 使用Theme中的大内边距
        spacing: Theme.paddingLarge

        // 面板标题
        Text {
            text: "船只状态" // 船只状态
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

        // 主要内容区域 - 罗盘和数据并排
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 260 // 高度可根据需要调整
            color: Qt.rgba(Theme.textColorOnDark.r, Theme.textColorOnDark.g, Theme.textColorOnDark.b, 0.05) // 轻微调整背景以区分
            radius: Theme.cardCornerRadius // 使用Theme中的卡片圆角

            RowLayout {
                anchors.fill: parent
                anchors.margins: Theme.paddingMedium // 使用Theme中的中内边距
                spacing: Theme.paddingMedium

                // 左侧罗盘
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 0.6
                    color: Qt.rgba(Theme.darkThemeBackgroundColor.r, Theme.darkThemeBackgroundColor.g, Theme.darkThemeBackgroundColor.b, 0.1) // 更深的背景
                    radius: Theme.cardCornerRadius / 2

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.paddingMedium
                        spacing: Theme.paddingSmall

                        Text {
                            text: "航向罗盘" // 航向罗盘
                            font.pixelSize: Theme.defaultFontSize // 使用Theme中的默认字号
                            font.bold: true
                            color: Theme.textColorOnDark
                            Layout.alignment: Qt.AlignCenter
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Canvas {
                                id: compassCanvas
                                anchors.centerIn: parent
                                width: Math.min(parent.width, parent.height) - Theme.paddingMedium
                                height: width

                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.reset();

                                    var centerX = width / 2;
                                    var centerY = height / 2;
                                    var radius = Math.min(width, height) / 2 - Theme.paddingSmall;

                                    // 绘制外圈
                                    ctx.beginPath();
                                    ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
                                    ctx.strokeStyle = Theme.borderColor; // 使用Theme边框色
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
                                        ctx.moveTo(centerX + Math.cos(angle) * start, centerY + Math.sin(angle) * start);
                                        ctx.lineTo(centerX + Math.cos(angle) * end, centerY + Math.sin(angle) * end);
                                        ctx.strokeStyle = Theme.textColorOnDark; // 使用Theme文本色
                                        ctx.lineWidth = isMajor ? 2 : 1;
                                        ctx.stroke();

                                        if (isMajor) {
                                            var dirIndex = (i / 90) % 4;
                                            ctx.fillStyle = Theme.textColorOnDark;
                                            ctx.font = "bold " + Theme.defaultFontSize + "px sans-serif"; // 使用Theme字号
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
                                    ctx.strokeStyle = Theme.primaryColor; // 使用Theme主色调作为指针颜色
                                    ctx.lineWidth = 3;
                                    ctx.stroke();

                                    // 绘制中心点
                                    ctx.beginPath();
                                    ctx.arc(centerX, centerY, 4, 0, Math.PI * 2);
                                    ctx.fillStyle = Theme.primaryColor; // 使用Theme主色调
                                    ctx.fill();

                                    // 绘制当前航向文本
                                    ctx.fillStyle = Theme.textColorOnDark;
                                    ctx.font = "bold " + Theme.titleFontSize + "px sans-serif"; // 使用Theme标题字号
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
                    color: Qt.rgba(Theme.darkThemeBackgroundColor.r, Theme.darkThemeBackgroundColor.g, Theme.darkThemeBackgroundColor.b, 0.1) // 更深的背景
                    radius: Theme.cardCornerRadius / 2

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.paddingMedium
                        spacing: Theme.paddingLarge // 增大内部块间距

                        // 位置信息
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Theme.paddingSmall

                            Text {
                                text: "位置信息" // 位置信息
                                font.pixelSize: Theme.defaultFontSize
                                font.bold: true
                                color: Theme.textColorOnDark
                            }

                            Rectangle { // 数据背景块
                                Layout.fillWidth: true
                                height: 70
                                color: Qt.rgba(Theme.darkThemeBackgroundColor.r, Theme.darkThemeBackgroundColor.g, Theme.darkThemeBackgroundColor.b, 0.2) // 更深的背景
                                radius: Theme.buttonCornerRadius // 使用Theme按钮圆角

                                GridLayout {
                                    anchors.fill: parent
                                    anchors.margins: Theme.paddingMedium
                                    columns: 2
                                    rowSpacing: Theme.paddingSmall
                                    columnSpacing: Theme.paddingMedium

                                    Text {
                                        text: "纬度:"
                                        color: Theme.textColorOnDark
                                        font.pixelSize: Theme.defaultFontSize
                                    }

                                    Text {
                                        text: vesselModule.latitude.toFixed(6) + "°"
                                        color: Theme.primaryColor // 使用Theme主色调显示数据
                                        font.pixelSize: Theme.defaultFontSize
                                        font.family: "Consolas, monospace"
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "经度:"
                                        color: Theme.textColorOnDark
                                        font.pixelSize: Theme.defaultFontSize
                                    }

                                    Text {
                                        text: vesselModule.longitude.toFixed(6) + "°"
                                        color: Theme.primaryColor
                                        font.pixelSize: Theme.defaultFontSize
                                        font.family: "Consolas, monospace"
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }

                        // 航行数据
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Theme.paddingSmall

                            Text {
                                text: "航行数据" // 航行数据
                                font.pixelSize: Theme.defaultFontSize
                                font.bold: true
                                color: Theme.textColorOnDark
                            }

                            Rectangle { // 数据背景块
                                Layout.fillWidth: true
                                height: 70
                                color: Qt.rgba(Theme.darkThemeBackgroundColor.r, Theme.darkThemeBackgroundColor.g, Theme.darkThemeBackgroundColor.b, 0.2)
                                radius: Theme.buttonCornerRadius

                                GridLayout {
                                    anchors.fill: parent
                                    anchors.margins: Theme.paddingMedium
                                    columns: 2
                                    rowSpacing: Theme.paddingSmall
                                    columnSpacing: Theme.paddingMedium

                                    Text {
                                        text: "航速:"
                                        color: Theme.textColorOnDark
                                        font.pixelSize: Theme.defaultFontSize
                                    }

                                    Text {
                                        text: vesselModule.speed.toFixed(2) + " m/s"
                                        color: Theme.primaryColor
                                        font.pixelSize: Theme.defaultFontSize
                                        font.family: "Consolas, monospace"
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: "航向:"
                                        color: Theme.textColorOnDark
                                        font.pixelSize: Theme.defaultFontSize
                                    }

                                    Text {
                                        text: vesselModule.heading.toFixed(1) + "°"
                                        color: Theme.primaryColor
                                        font.pixelSize: Theme.defaultFontSize
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
            height: 220 // 高度可根据需要调整
            color: Qt.rgba(Theme.textColorOnDark.r, Theme.textColorOnDark.g, Theme.textColorOnDark.b, 0.05) // 轻微调整背景以区分
            radius: Theme.cardCornerRadius

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.paddingMedium
                spacing: Theme.paddingMedium

                // 标题
                Text {
                    text: "控制面板" // 控制面板
                    font.pixelSize: Theme.defaultFontSize
                    font.bold: true
                    color: Theme.textColorOnDark
                }

                // 水泵控制
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "水泵控制:"
                        color: Theme.textColorOnDark
                        font.pixelSize: Theme.defaultFontSize
                    }

                    Item { Layout.fillWidth: true }

                    Switch {
                        checked: deviceModule.pumpActive

                        indicator: Rectangle {
                            width: 50
                            height: 26
                            radius: 13
                            // color: parent.checked ? successColor : Qt.rgba(0.3, 0.3, 0.3, 1) // 旧颜色
                            color: parent.checked ? Theme.secondaryColor : Qt.rgba(Theme.borderColor.r, Theme.borderColor.g, Theme.borderColor.b, 0.7)

                            Rectangle { // 滑块圆点
                                x: parent.parent.checked ? parent.width - width - 3 : 3
                                y: 3
                                width: 20
                                height: 20
                                radius: 10
                                color: Theme.textColorOnLight // 使用浅色文本色作为滑块圆点颜色

                                Behavior on x {
                                    NumberAnimation { duration: 200 }
                                }
                            }
                        }

                        contentItem: Text {
                            text: parent.checked ? "开启" : "关闭"
                            color: Theme.textColorOnDark
                            font.pixelSize: Theme.defaultFontSize
                            leftPadding: 0
                            rightPadding: 60
                        }
                        onCheckedChanged: deviceModule.setPumpActive(checked)
                    }
                }

                // 电机1控制
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.paddingSmall

                    Text {
                        text: "电机1控制:"
                        color: Theme.textColorOnDark
                        font.pixelSize: Theme.defaultFontSize
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.paddingMedium

                        // 电机1滑块
                        Slider {
                            id: motor1Slider
                            Layout.fillWidth: true
                            from: 675
                            to: 1353
                            stepSize: 1
                            value: deviceModule.motor1Value

                            background: Rectangle { // 滑块背景条
                                x: motor1Slider.leftPadding
                                y: motor1Slider.topPadding + motor1Slider.availableHeight / 2 - height / 2
                                width: motor1Slider.availableWidth
                                height: 4
                                radius: 2
                                color: Qt.rgba(Theme.borderColor.r, Theme.borderColor.g, Theme.borderColor.b, 0.5) // 使用边框色的半透明

                                Rectangle { // 滑块已填充部分
                                    width: motor1Slider.visualPosition * parent.width
                                    height: parent.height
                                    color: Theme.primaryColor // 使用Theme主色调
                                    radius: 2
                                }
                            }

                            handle: Rectangle { // 滑块句柄
                                x: motor1Slider.leftPadding + motor1Slider.visualPosition * (motor1Slider.availableWidth - width)
                                y: motor1Slider.topPadding + motor1Slider.availableHeight / 2 - height / 2
                                width: 20
                                height: 20
                                radius: 10
                                color: motor1Slider.pressed ? Qt.darker(Theme.primaryColor, 1.2) : Theme.primaryColor
                                border.color: Theme.textColorOnLight // 句柄边框色
                                border.width: 1
                            }
                            onValueChanged: {
                                if (Math.abs(value - 1013) < 10) { value = 1013; }
                                deviceModule.setMotor1Value(value);
                            }
                        }

                        // 电机1数值显示
                        Text {
                            text: motor1Slider.value.toFixed(0)
                            color: Theme.primaryColor
                            font.pixelSize: Theme.defaultFontSize
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
                                color: Theme.textColorOnDark
                                font.pixelSize: Theme.defaultFontSize
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: { deviceModule.setMotor1Value(1013); }
                            background: Rectangle {
                                color: parent.hovered ? Qt.rgba(Theme.textColorOnDark.r, Theme.textColorOnDark.g, Theme.textColorOnDark.b, 0.1) : "transparent"
                                radius: 12
                            }
                        }
                    }

                    // 电机2控制
                    Text {
                        text: "电机2控制:"
                        color: Theme.textColorOnDark
                        font.pixelSize: Theme.defaultFontSize
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.paddingMedium

                        // 电机2滑块
                        Slider {
                            id: motor2Slider
                            Layout.fillWidth: true
                            from: 675
                            to: 1353
                            stepSize: 1
                            value: deviceModule.motor2Value

                            background: Rectangle { // 滑块背景条
                                x: motor2Slider.leftPadding
                                y: motor2Slider.topPadding + motor2Slider.availableHeight / 2 - height / 2
                                width: motor2Slider.availableWidth
                                height: 4
                                radius: 2
                                color: Qt.rgba(Theme.borderColor.r, Theme.borderColor.g, Theme.borderColor.b, 0.5)

                                Rectangle { // 滑块已填充部分
                                    width: motor2Slider.visualPosition * parent.width
                                    height: parent.height
                                    color: Theme.primaryColor
                                    radius: 2
                                }
                            }

                            handle: Rectangle { // 滑块句柄
                                x: motor2Slider.leftPadding + motor2Slider.visualPosition * (motor2Slider.availableWidth - width)
                                y: motor2Slider.topPadding + motor2Slider.availableHeight / 2 - height / 2
                                width: 20
                                height: 20
                                radius: 10
                                color: motor2Slider.pressed ? Qt.darker(Theme.primaryColor, 1.2) : Theme.primaryColor
                                border.color: Theme.textColorOnLight
                                border.width: 1
                            }
                            onValueChanged: {
                                if (Math.abs(value - 1013) < 10) { value = 1013; }
                                deviceModule.setMotor2Value(value);
                            }
                        }

                        // 电机2数值显示
                        Text {
                            text: motor2Slider.value.toFixed(0)
                            color: Theme.primaryColor
                            font.pixelSize: Theme.defaultFontSize
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
                                color: Theme.textColorOnDark
                                font.pixelSize: Theme.defaultFontSize
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: { deviceModule.setMotor2Value(1013); }
                            background: Rectangle {
                                color: parent.hovered ? Qt.rgba(Theme.textColorOnDark.r, Theme.textColorOnDark.g, Theme.textColorOnDark.b, 0.1) : "transparent"
                                radius: 12
                            }
                        }
                    }
                }

                // 控制按钮（全部停止/全速前进）
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.paddingMedium

                    Button {
                        text: "全部停止"
                        Layout.fillWidth: true
                        contentItem: Text {
                            text: parent.text
                            color: Theme.textColorOnLight // 假设按钮背景深
                            font.pixelSize: Theme.defaultFontSize
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            // color: parent.down ? Qt.darker(dangerColor, 1.2) : // 旧颜色
                            //        parent.hovered ? dangerColor : Qt.rgba(0.7, 0.2, 0.2, 1)
                            color: parent.down ? Qt.darker(Theme.accentColor, 1.2) :
                                   parent.hovered ? Theme.accentColor : Qt.lighter(Theme.accentColor, 1.1) // 使用Theme强调色
                            radius: Theme.buttonCornerRadius
                        }
                        onClicked: {
                            deviceModule.setMotor1Value(1013);
                            deviceModule.setMotor2Value(1013);
                        }
                    }

                    Button {
                        text: "全速前进"
                        Layout.fillWidth: true
                        contentItem: Text {
                            text: parent.text
                            color: Theme.textColorOnLight // 假设按钮背景深
                            font.pixelSize: Theme.defaultFontSize
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            // color: parent.down ? Qt.darker(successColor, 1.2) : // 旧颜色
                            //        parent.hovered ? successColor : Qt.rgba(0.2, 0.7, 0.2, 1)
                            color: parent.down ? Qt.darker(Theme.secondaryColor, 1.2) :
                                   parent.hovered ? Theme.secondaryColor : Qt.lighter(Theme.secondaryColor, 1.1) // 使用Theme次要色
                            radius: Theme.buttonCornerRadius
                        }
                        onClicked: {
                            deviceModule.setMotor1Value(1353);
                            deviceModule.setMotor2Value(1353);
                        }
                    }
                }
            }
        }
    }
}
