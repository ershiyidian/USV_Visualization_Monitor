// Theme.qml
// 该文件定义了应用程序的全局主题样式，包括颜色、字体大小等。
// 使用 pragma Singleton 确保在整个QML环境中只有一个实例。
pragma Singleton
import QtQuick 2.15

QtObject {
    id: theme // 为单例的根QtObject提供一个id，虽然通常通过文件名访问

    // 主要色彩定义 (色彩定义)
    property color primaryColor: "#3498DB"      // 主色调 (例如: 导航栏背景, 主要按钮) - 蓝色
    property color secondaryColor: "#2ECC71"    // 次要色调 (例如: 成功提示, 完成状态) - 绿色
    property color accentColor: "#E74C3C"       // 强调/危险色 (例如: 警告, 错误提示, 删除按钮) - 红色
    property color warningColor: "#F39C12"      // 警告色 (用于不太严重但需要注意的提示) - 橙色

    // 背景色系 (背景色系)
    property color backgroundColor: "#ECF0F1"    // 应用主背景色 - 浅灰色
    property color cardColor: "#FFFFFF"         // 卡片/面板背景色 - 白色
    property color darkThemeBackgroundColor: "#1E2A38" // 深色主题背景色 (若main.qml继续使用深色主题)
    property color darkThemeCardColor: "#2C3E50"      // 深色主题卡片背景色

    // 文本颜色 (文本颜色)
    property color textColorOnLight: "#2C3E50"  // 浅色背景上的文本颜色 - 深灰蓝
    property color textColorOnDark: "#ECF0F1"   // 深色背景上的文本颜色 - 浅灰
    property color subtitleColor: "#7F8C8D"     // 副标题/提示性文本颜色 - 灰色

    // 其他颜色 (其他颜色)
    property color borderColor: "#BDC3C7"       // 边框颜色 - 浅灰色
    property color shadowColor: "rgba(0,0,0,0.1)" // 阴影颜色 (更柔和)
    property color chartGridColor: "#D5D8DC"    // 图表网格线颜色 (浅色背景用)
    property color darkThemeChartGridColor: "#3E4D5C" // 图表网格线颜色 (深色背景用)


    // 字体大小定义 (字体大小定义)
    property int titleFontSize: 20        // 标题字号
    property int largeFontSize: 16        // 大号字体 (例如副标题，重要标签)
    property int defaultFontSize: 14      // 默认/正文字号
    property int smallFontSize: 12        // 小号字体 (例如次要信息)
    property int tinyFontSize: 10         // 微小字体 (例如图例中的额外注释)

    // 控件属性 (控件属性)
    property real cardCornerRadius: 6     // 卡片圆角半径
    property real buttonCornerRadius: 4   // 按钮圆角半径
    property real controlHeight: 36       // 标准控件高度 (例如 Button, ComboBox)
    property real paddingSmall: 4         // 小内边距
    property real paddingMedium: 8        // 中内边距
    property real paddingLarge: 12        // 大内边距
}
