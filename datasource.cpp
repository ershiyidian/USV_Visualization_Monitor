#include "datasource.h" // 包含头文件
#include <QDebug> // 用于调试输出
#include <QRandomGenerator> // 用于生成随机数 (模拟数据)
#include <QDataStream> // 用于数据流操作 (发送数据)
#include <QSerialPortInfo> // 用于获取可用串口信息
#include <QDateTime> // 用于时间戳处理 (发送数据)
#include <QElapsedTimer> // 用于模拟数据的时间控制
#include <sstream> // 用于字符串流转换 (发送数据 - 时间戳解析)
#include <iomanip> // 用于流格式化 (发送数据 - 时间戳解析)
#include <cmath> // 用于数学计算 (模拟数据，例如sin, abs, M_PI)

using namespace FrameConstants; // 使用FrameConstants命名空间中的常量

// 构造函数
DataSource::DataSource(QObject *parent)
    : QObject(parent)
    , m_pumpState(false) // 初始化水泵状态为关闭
    , m_motor1(MOTOR_NEUTRAL) // 初始化电机1为中立值
    , m_motor2(MOTOR_NEUTRAL) // 初始化电机2为中立值
    , m_isSimulating(false) // 初始化为非模拟模式
    , m_mergedFrameHeader(QString("%1").arg(FRAME_HEADER, 2, 16, QChar('0')).toUpper()) // 初始化帧头字符串 (十六进制)
    , m_mergedFrameTrailer(QString("%1").arg(FRAME_TRAILER, 2, 16, QChar('0')).toUpper()) // 初始化帧尾字符串 (十六进制)
    , serialPort(new QSerialPort(this)) // 创建串口对象
    , portUpdateTimer(new QTimer(this)) // 创建串口列表更新定时器
    , simulationTimer(new QTimer(this)) // 创建数据模拟定时器
{
    // 连接串口相关的信号和槽
    connect(serialPort, &QSerialPort::readyRead, this, &DataSource::readSerialData); // 当有数据可读时，调用readSerialData
    connect(serialPort, &QSerialPort::errorOccurred, this, &DataSource::handleSerialError); // 当串口发生错误时，调用handleSerialError

    // 连接定时器相关的信号和槽
    connect(portUpdateTimer, &QTimer::timeout, this, &DataSource::checkAvailablePorts); // 定时检查可用串口
    connect(simulationTimer, &QTimer::timeout, this, &DataSource::generateFakeData); // 定时生成模拟数据

    // 启动端口更新定时器 (每2秒检查一次)
    portUpdateTimer->start(2000);

    // 设置模拟数据定时器间隔 (每0.5秒生成一次)
    simulationTimer->setInterval(500);

    // 初始化并启动模拟用时计时器
    m_simulationElapsedTimer.start();

    // 初始化模拟的地理位置 (例如：上海市中心附近)
    m_simulatedLatitude = 31.230416;
    m_simulatedLongitude = 121.473701;

    // 程序启动时立即检查一次可用串口
    checkAvailablePorts();
}

// 析构函数
DataSource::~DataSource()
{
    if (serialPort->isOpen()) {
        serialPort->close(); // 关闭串口
    }
    // QSerialPort, QTimer等对象会自动被Qt的父子对象机制管理和释放
}

// 将十六进制字符串转换为字节数组
QByteArray DataSource::parseHexString(const QString& hexStr)
{
    return QByteArray::fromHex(hexStr.toLatin1());
}

// 校验数据帧的帧头和帧尾是否与设定的值匹配
bool DataSource::isValidFrame(const QByteArray& data)
{
    if (data.size() < 2) return false; // 数据长度不足，无法判断

    // 从数据中提取帧头和帧尾
    uint8_t headerByte = static_cast<uint8_t>(data[0] & 0xFF);
    uint8_t trailerByte = static_cast<uint8_t>(data[1] & 0xFF); // 注意：此处假设帧尾在第二个字节，实际帧尾在末尾

    // 转换为十六进制字符串进行比较
    QString headerHex = QString("%1").arg(headerByte, 2, 16, QChar('0')).toUpper();
    // QString trailerHex = QString("%1").arg(trailerByte, 2, 16, QChar('0')).toUpper(); // 帧尾校验逻辑需要调整

    // 实际校验应为 data[0] 和 data[data.size()-1]
    // return (headerHex == m_mergedFrameHeader && trailerHex == m_mergedFrameTrailer);
    // 鉴于当前 processReceivedData 的逻辑，此函数主要检查前两个字节是否为预期的帧头和帧同步字节
    return (headerByte == FRAME_HEADER && trailerByte == FRAME_TRAILER);
}

// 计算预期的数据帧大小
// 注意：此函数在当前代码中主要用于检查接收帧的帧头和同步字节，并返回固定接收帧大小
// 如果有多种帧类型，此逻辑需要扩展
int DataSource::calculateFrameSize(const QByteArray& data)
{
    if (data.size() < 2) return -1; // 数据不足

    uint8_t header = static_cast<uint8_t>(data[0] & 0xFF);
    uint8_t sync_byte_or_trailer_part = static_cast<uint8_t>(data[1] & 0xFF); // 根据当前帧结构，第二个字节是同步/帧尾的一部分

    // 实际应用中，帧大小可能由帧类型字段决定，或固定
    // 当前实现假设第二个字节也是帧头的一部分（或一个同步字节），并返回固定大小
    if (header == FRAME_HEADER && sync_byte_or_trailer_part == FRAME_TRAILER) { // 实际帧尾在末尾
        return RECEIVE_FRAME_SIZE;
    }
    return -1; // 不是预期的帧格式
}

// 打开指定的串口
bool DataSource::openSerialPort(const QString& portName, int baudRate)
{
    if (serialPort->isOpen()) {
        serialPort->close(); // 如果已打开，先关闭
    }

    serialPort->setPortName(portName); // 设置串口名
    serialPort->setBaudRate(baudRate); // 设置波特率
    serialPort->setDataBits(QSerialPort::Data8); // 数据位8
    serialPort->setParity(QSerialPort::NoParity); // 无校验
    serialPort->setStopBits(QSerialPort::OneStop); // 1位停止位
    serialPort->setFlowControl(QSerialPort::NoFlowControl); // 无流控

    qDebug() << "尝试打开串口:" << portName << "波特率:" << baudRate;

    if (serialPort->open(QIODevice::ReadWrite)) { // 以读写模式打开
        qDebug() << "串口已打开:" << portName;
        emit portOpenChanged(); // 发送串口状态变更信号
        return true;
    } else {
        qDebug() << "串口打开失败:" << serialPort->errorString();
        emit error(serialPort->errorString()); // 发送错误信号
        return false;
    }
}

// 关闭串口
void DataSource::closeSerialPort()
{
    if (serialPort->isOpen()) {
        serialPort->close();
        qDebug() << "串口已关闭";
        emit portOpenChanged(); // 发送串口状态变更信号
    }
}

// 设置是否启用数据模拟
void DataSource::setIsSimulating(bool enabled)
{
    if (m_isSimulating == enabled) return; // 状态未改变则不执行

    m_isSimulating = enabled;

    if (enabled) {
        m_simulationElapsedTimer.restart(); // 重启模拟计时器
        simulationTimer->start(); // 启动模拟数据生成定时器
        qDebug() << "数据模拟已启动";
    } else {
        simulationTimer->stop(); // 停止模拟数据生成定时器
        qDebug() << "数据模拟已停止";
    }
    emit isSimulatingChanged(); // 发送模拟状态变更信号
}

// 设置合并帧的帧头 (十六进制字符串)
void DataSource::setMergedFrameHeader(const QString& header)
{
    if (m_mergedFrameHeader != header) {
        m_mergedFrameHeader = header;
        emit mergedFrameHeaderChanged(); // 发送帧头变更信号
    }
}

// 设置合并帧的帧尾 (十六进制字符串)
void DataSource::setMergedFrameTrailer(const QString& trailer)
{
    if (m_mergedFrameTrailer != trailer) {
        m_mergedFrameTrailer = trailer;
        emit mergedFrameTrailerChanged(); // 发送帧尾变更信号
    }
}

// 校验电机值是否在有效范围内
bool DataSource::isValidMotorValue(quint16 value) const
{
    // 电机值范围: 675 (反向最大) ~ 1013 (静止) ~ 1353 (正向最大)
    return (value >= MOTOR_MIN_VALUE && value <= MOTOR_MAX_VALUE);
}

// 校验GPS坐标是否有效
bool DataSource::isValidGpsCoordinate(double lat, double lon) const
{
    // 纬度范围: -90 到 +90 度; 经度范围: -180 到 +180 度
    return (lat >= -90.0 && lat <= 90.0) && (lon >= -180.0 && lon <= 180.0);
}

// 处理从串口接收到的数据
void DataSource::processReceivedData(const QByteArray& data)
{
    buffer.append(data); // 将新数据追加到缓冲区

    // 循环处理缓冲区中的数据，直到数据不足以构成一个完整的帧
    // 至少需要2个字节来检查帧头和同步字节(根据当前逻辑)
    while (buffer.size() >= 2) { // 修改：至少需要帧头和同步字节
        // 检查帧头和同步字节 (注意：这里的FRAME_TRAILER实际用作了第二个同步字节)
        uint8_t header = static_cast<uint8_t>(buffer[0] & 0xFF);
        uint8_t sync_byte = static_cast<uint8_t>(buffer[1] & 0xFF);

        if (header != FRAME_HEADER || sync_byte != FRAME_TRAILER) { // 如果不是预期的帧起始
            buffer.remove(0, 1); // 移除缓冲区头部的一个字节，继续寻找帧头
            continue;
        }

        // 检查缓冲区中是否有足够的数据构成一个完整的接收帧
        if (buffer.size() < RECEIVE_FRAME_SIZE) {
            qDebug() << "数据不足，等待更多数据. 当前:" << buffer.size() << "字节，需要:" << RECEIVE_FRAME_SIZE;
            break; // 数据不足，退出循环，等待更多数据到达
        }

        // 提取一个完整的帧数据
        QByteArray frame = buffer.left(RECEIVE_FRAME_SIZE);
        qDebug() << "收到并准备解析完整数据帧: " << frame.toHex().toUpper();

        // --- 开始 DTO 数据解析 ---
        SensorDataDto sensorDto;     // 创建传感器数据DTO实例
        VesselStateDto vesselDto;    // 创建船体状态DTO实例
        DeviceStatusDto deviceDto;   // 创建设备状态DTO实例

        // 解析传感器数据 (填充 SensorDataDto)
        // 注意: 原始帧数据为小端字节序，使用 convertFromLittleEndian 和 memcpy 进行转换

        // CO2浓度 (ppm), 2字节小端
        sensorDto.co2 = convertFromLittleEndian(frame[SENSOR_DATA_OFFSET + 4], frame[SENSOR_DATA_OFFSET + 5]);
        
        // 甲醛 (CH2O): 原始单位ppb, DTO单位mg/m³. 转换因子: 1 ppb CH2O ≈ 1.228 µg/m³ = 0.001228 mg/m³
        uint16_t rawCh2o_ppb = convertFromLittleEndian(frame[SENSOR_DATA_OFFSET + 6], frame[SENSOR_DATA_OFFSET + 7]);
        sensorDto.ch2o = static_cast<double>(rawCh2o_ppb) * 0.001228; 
        
        // TVOC: 原始单位ppb, DTO单位mg/m³. 转换因子 (以甲苯计): 1 ppb TVOC ≈ 3.75 µg/m³ = 0.00375 mg/m³
        uint16_t rawTvoc_ppb = convertFromLittleEndian(frame[SENSOR_DATA_OFFSET + 8], frame[SENSOR_DATA_OFFSET + 9]);
        sensorDto.tvoc = static_cast<double>(rawTvoc_ppb) * 0.00375;

        // PM2.5 (µg/m³), 2字节小端
        sensorDto.pm25 = convertFromLittleEndian(frame[SENSOR_DATA_OFFSET + 10], frame[SENSOR_DATA_OFFSET + 11]);
        // PM10 (µg/m³), 2字节小端
        sensorDto.pm10 = convertFromLittleEndian(frame[SENSOR_DATA_OFFSET + 12], frame[SENSOR_DATA_OFFSET + 13]);
        
        // 空气温度 (℃), 高低字节表示
        sensorDto.airTemperature = convertAirTemperature(frame[SENSOR_DATA_OFFSET + 14], frame[SENSOR_DATA_OFFSET + 15]);
        // 空气湿度 (%RH), 高低字节表示 (使用与空气温度相同的转换函数)
        sensorDto.airHumidity = convertAirTemperature(frame[SENSOR_DATA_OFFSET + 16], frame[SENSOR_DATA_OFFSET + 17]);

        // 水体浊度 (NTU), 2字节小端
        sensorDto.waterTurbidity = convertFromLittleEndian(frame[SENSOR_DATA_OFFSET + 18], frame[SENSOR_DATA_OFFSET + 19]);
        
        // pH值: 原始值 = 实际pH * 100, DTO为实际pH
        uint16_t rawPh = convertFromLittleEndian(frame[SENSOR_DATA_OFFSET + 20], frame[SENSOR_DATA_OFFSET + 21]);
        sensorDto.ph = static_cast<double>(rawPh) / 100.0;

        // 总溶解固体 (TDS, ppm), 2字节小端
        sensorDto.tds = convertFromLittleEndian(frame[SENSOR_DATA_OFFSET + 22], frame[SENSOR_DATA_OFFSET + 23]);
        // 水体温度 (℃), 高低字节表示
        sensorDto.waterTemperature = convertWaterTemperature(frame[SENSOR_DATA_OFFSET + 24], frame[SENSOR_DATA_OFFSET + 25]);

        // 水位: 原始单位mm, DTO单位m. 转换: 1 mm = 0.001 m
        int16_t rawLevel_mm = static_cast<int16_t>(convertFromLittleEndian(frame[SENSOR_DATA_OFFSET + 26], frame[SENSOR_DATA_OFFSET + 27]));
        sensorDto.waterLevel = static_cast<double>(rawLevel_mm) / 1000.0;

        emit sensorDataUpdated(sensorDto); // 发送传感器数据更新信号

        // 解析船体状态数据 (填充 VesselStateDto)
        // 纬度: 1字节有符号整数 + 4字节浮点小数
        int latIntPart = static_cast<int8_t>(frame[LAT_OFFSET]);
        float latDecimalPart;
        memcpy(&latDecimalPart, frame.constData() + LAT_OFFSET + 1, 4);
        vesselDto.latitude = static_cast<double>(latIntPart) + latDecimalPart;

        // 经度: 1字节有符号整数 + 4字节浮点小数
        int lonIntPart = static_cast<int8_t>(frame[LON_OFFSET]);
        float lonDecimalPart;
        memcpy(&lonDecimalPart, frame.constData() + LON_OFFSET + 1, 4);
        vesselDto.longitude = static_cast<double>(lonIntPart) + lonDecimalPart;

        // 航向: 1字节有符号整数 + 1字节无符号小数 (代表实际值 * 100的小数部分)
        int8_t headingInt = static_cast<int8_t>(frame[HEADING_OFFSET]);
        uint8_t headingDec = static_cast<uint8_t>(frame[HEADING_OFFSET + 1]);
        vesselDto.heading = static_cast<double>(headingInt) + (headingInt < 0 ? -1.0 : 1.0) * (static_cast<double>(headingDec) / 100.0);

        // 速度: 1字节无符号整数 + 1字节无符号小数 (代表实际值 * 100的小数部分)
        uint8_t speedInt = static_cast<uint8_t>(frame[SPEED_OFFSET]);
        uint8_t speedDec = static_cast<uint8_t>(frame[SPEED_OFFSET + 1]);
        vesselDto.speed = static_cast<double>(speedInt) + (static_cast<double>(speedDec) / 100.0);

        emit vesselStateUpdated(vesselDto); // 发送船体状态更新信号

        // 解析设备状态数据 (填充 DeviceStatusDto)
        // 电池电量 (%), 2字节小端
        deviceDto.batteryLevel = convertFromLittleEndian(frame[BATTERY_OFFSET], frame[BATTERY_OFFSET + 1]);
        
        // 操作模式: 0=手动, 1=自动. DTO中使用QString表示
        bool rawMode = static_cast<bool>(frame[MODE_OFFSET]); // 原始模式值 (0或1)
        deviceDto.operationalMode = rawMode ? "自动" : "手动"; //转换为中文描述

        emit deviceStatusUpdated(deviceDto); // 发送设备状态更新信号
        // --- DTO 数据解析结束 ---

        // 从缓冲区移除已处理的帧数据
        buffer.remove(0, RECEIVE_FRAME_SIZE);
    }
}

// 当串口有数据可读时调用此槽函数
void DataSource::readSerialData()
{
    QByteArray data = serialPort->readAll(); // 读取所有可读数据
    qDebug() << "读取到原始串口数据:" << data.toHex().toUpper();
    processReceivedData(data); // 处理读取到的数据
}

// 设置水泵状态 (开启/关闭)
void DataSource::setPumpState(bool state)
{
    if (m_pumpState != state) {
        m_pumpState = state;
        emit pumpStateChanged(); // 发送水泵状态变更信号
        qDebug() << "水泵状态已更新为：" << (state ? "开启" : "关闭");
    }
}

// 设置电机1的输出值
void DataSource::setMotor1(quint16 value)
{
    if (!isValidMotorValue(value)) { // 校验电机值
        qWarning() << "尝试设置的电机1值无效:" << value;
        emit error(QString("电机1值无效: %1").arg(value));
        return;
    }
    if (m_motor1 != value) {
        m_motor1 = value;
        emit motor1Changed(); // 发送电机1值变更信号
    }
}

// 设置电机2的输出值
void DataSource::setMotor2(quint16 value)
{
    if (!isValidMotorValue(value)) { // 校验电机值
        qWarning() << "尝试设置的电机2值无效:" << value;
        emit error(QString("电机2值无效: %1").arg(value));
        return;
    }
    if (m_motor2 != value) {
        m_motor2 = value;
        emit motor2Changed(); // 发送电机2值变更信号
    }
}

// 更新水泵的工作模式 (手动/自动)
void DataSource::updatePumpModeInDataSource(bool mode){
    if(m_pump_mode != mode){
        m_pump_mode = mode;
        emit pump_modeChanged(); // 发送水泵模式变更信号
    }
}

// 更新船只的工作模式 (手动/自动)
void DataSource::updateBoatModeInDataSource(bool mode){
    if(m_boat_mode != mode){
        m_boat_mode = mode;
        emit boat_modeChanged(); // 发送船只模式变更信号
    }
}

// @deprecated 旧的发送任务点数据接口，将由handleMissionCommand取代
// 此函数将被新的 handleMissionCommand(const MissionCommandDto& missionCmd) 取代。
// 为平稳过渡，暂时保留，但其逻辑将被迁移。
void DataSource::sendData(const std::vector<QString>& taskPointsData)
{
    qDebug() << "DataSource::sendData (deprecated) called. This function will be removed. Use missionCommandRequested signal from DeviceModule instead.";
    if (!serialPort->isOpen()) { // 检查串口是否打开
        qDebug() << "串口未打开，无法发送数据";
        emit error("串口未打开，无法发送数据");
        return;
    }

    try {
        if (taskPointsData.empty()) { // 检查任务点数据是否为空
            emit error("任务点数据为空，无法发送");
            return;
        }

        // 创建数据包字节数组
        QByteArray data;
        // 预设最小大小 (帧头+时间戳+Home点+控制块基本大小)
        int minSize = FRAME_HEADER_SIZE + TIMESTAMP_LENGTH + HOME_POINT_SIZE + CONTROL_BLOCK_SIZE; // CONTROL_BLOCK_SIZE为7
        data.resize(minSize); // 初始化大小
        data[0] = FRAME_HEADER; // 设置帧头
        data[1] = FRAME_TRAILER; // 设置帧同步/部分帧尾 (注意：实际完整帧尾通常在数据包末尾)

        // 处理时间戳 (从第一个任务点数据中提取)
        QString firstData = taskPointsData[0]; // 第一个点通常包含时间戳信息
        QStringList list = firstData.split(",");
        if (list.size() < 3) { // 假设格式为 "经度,纬度,时间戳"
            emit error("Home点数据格式不正确 (缺少时间戳)");
            return;
        }

        // 解析时间戳字符串 ("YYYY-MM-DD HH:MM:SS")
        std::string timestampStr = list[2].toStdString();
        std::tm tm = {};
        std::istringstream ss(timestampStr);
        ss >> std::get_time(&tm, "%Y-%m-%d %H:%M:%S");
        if (ss.fail()) {
            emit error("时间戳解析失败");
            return;
        }
        std::time_t time = std::mktime(&tm); // 转换为time_t
        qint64 sec = static_cast<qint64>(time); // 转换为qint64 (秒数)

        // 将时间戳写入数据包 (8字节, 小端序, 偏移量2)
        QDataStream timeStream(&data, QIODevice::WriteOnly);
        timeStream.setByteOrder(QDataStream::LittleEndian); // 设置小端字节序
        timeStream.device()->seek(FRAME_HEADER_SIZE); // 定位到时间戳写入位置
        timeStream << sec; // 写入时间戳

        // 处理Home点和任务点数据
        int taskIndex = 0; // 任务点计数器 (0为Home点)
        for (const auto& dataStr : taskPointsData) {
            // 根据任务点数量调整数据包大小
            int taskCount = taskPointsData.size();
            // 限制最大任务点数量 (MAX_TASK_POINTS个任务点 + 1个Home点)
            int validTaskCount = taskCount > (MAX_TASK_POINTS + 1) ? (MAX_TASK_POINTS + 1) : taskCount;
            // 总大小 = 最小大小 + (有效任务点数-1) * 每个任务点大小
            int totalSize = minSize + (validTaskCount - 1) * TASK_POINT_SIZE; // 减1因为minSize已包含一个点(Home点)
            data.resize(totalSize); // 调整数据包大小

            if (taskIndex > MAX_TASK_POINTS) { // 如果当前点是任务点且超出最大数量
                qDebug() << "任务点数量超出限制，只处理前" << MAX_TASK_POINTS + 1 << "个点 (含Home点)";
                break; // 跳出循环，不再处理更多点
            }

            QStringList parts = dataStr.split(","); // 按逗号分割经纬度数据
            if (parts.size() < 2) { // 至少需要经度和纬度
                qWarning() << "任务点数据格式不正确: " << dataStr;
                continue; // 跳过此无效数据点
            }

            // 解析经纬度字符串为double
            bool okLon = false, okLat = false;
            double longitude = parts[0].toDouble(&okLon);
            double latitude = parts[1].toDouble(&okLat);

            if (!okLon || !okLat || !isValidGpsCoordinate(latitude, longitude)) { // 校验GPS坐标有效性
                qWarning() << "无效的经纬度坐标: " << longitude << "," << latitude;
                continue; // 跳过此无效数据点
            }

            // 计算当前点在数据包中的偏移量
            int pointOffset;
            if (taskIndex == 0) { // Home点
                pointOffset = FRAME_HEADER_SIZE + TIMESTAMP_LENGTH;
            } else { // 普通任务点 (taskIndex从1开始计数任务点)
                pointOffset = FRAME_HEADER_SIZE + TIMESTAMP_LENGTH + HOME_POINT_SIZE + (taskIndex - 1) * TASK_POINT_SIZE;
            }

            // 写入经度 (1字节整数部分 + 4字节小数部分)
            int lonInt = static_cast<int>(longitude); // 取整数部分
            data[pointOffset] = static_cast<char>(lonInt); // 写入整数部分
            float lonDecimal = static_cast<float>(longitude - lonInt); // 计算小数部分 (float类型)
            memcpy(data.data() + pointOffset + 1, &lonDecimal, 4); // 写入小数部分 (4字节)

            // 写入纬度 (1字节整数部分 + 4字节小数部分)
            int latInt = static_cast<int>(latitude); // 取整数部分
            data[pointOffset + COORD_TOTAL_SIZE] = static_cast<char>(latInt); // 写入整数部分 (偏移5字节)
            float latDecimal = static_cast<float>(latitude - latInt); // 计算小数部分 (float类型)
            memcpy(data.data() + pointOffset + COORD_TOTAL_SIZE + 1, &latDecimal, 4); // 写入小数部分 (偏移6字节, 共4字节)
            
            taskIndex++; // 任务点计数器递增
        }

        // --- 处理控制指令块 ---
        // 控制指令块的起始偏移量
        int controlBlockOffset = FRAME_HEADER_SIZE + TIMESTAMP_LENGTH + HOME_POINT_SIZE + (taskIndex > 0 ? (taskIndex -1) : 0) * TASK_POINT_SIZE;
        if (taskIndex == 0 && !taskPointsData.empty()) { // 如果只有Home点，taskIndex会是1，但实际写入点数是1
             controlBlockOffset = FRAME_HEADER_SIZE + TIMESTAMP_LENGTH + HOME_POINT_SIZE; // Home点之后就是控制块
        } else if (taskIndex == 0 && taskPointsData.empty()){ // 不应该发生，但做保护
            emit error("无任务点数据，无法定位控制块");
            return;
        }


        // 水泵模式 (1字节): 0=手动, 1=自动
        data[controlBlockOffset] = m_pump_mode ? 1 : 0;
        qDebug() << "发送的水泵模式：" << (m_pump_mode ? "自动" : "手动");

        // 水泵控制 (1字节): 手动模式下有效, 0=关闭, 1=开启
        data[controlBlockOffset + 1] = m_pumpState ? 1 : 0;

        // 船只模式 (1字节): 0=手动, 1=自动, 2=位置保持
        // 注意：m_boat_mode是bool (false=手动, true=自动). 需要映射到0,1,2.
        // 假设这里 m_boat_mode=true (自动) 对应协议的 1 (自动). 位置保持模式需要额外逻辑.
        // 为简化，当前 m_boat_mode=true 映射为1 (自动)，false 映射为0 (手动).
        uint8_t boatModeProtocol = m_boat_mode ? 1 : 0; // 默认为自动或手动
        // if (m_isPositionHoldActive) boatModeProtocol = 2; // 位置保持模式的逻辑 (本期未实现)
        data[controlBlockOffset + 2] = boatModeProtocol;
        qDebug() << "发送的船只模式：" << boatModeProtocol;


        // 船只控制 - 电机值 (4字节): 2字节m_motor1 + 2字节m_motor2 (小端序)
        QDataStream motorStream(&data, QIODevice::WriteOnly);
        motorStream.setByteOrder(QDataStream::LittleEndian); // 设置小端字节序
        motorStream.device()->seek(controlBlockOffset + 3); // 定位到电机值写入位置
        motorStream << m_motor1; // 写入电机1值
        motorStream << m_motor2; // 写入电机2值

        // --- 处理保留区 --- (14字节, 填充0)
        // 保留区的起始位置在控制指令块之后
        int reservedAreaOffset = controlBlockOffset + CONTROL_BLOCK_SIZE;
        data.resize(reservedAreaOffset + RESERVED_SIZE); // 扩展data以包含保留区
        std::fill(data.begin() + reservedAreaOffset, data.end(), 0); // 用0填充保留区

        // 发送最终组装好的数据包
        qint64 bytesWritten = serialPort->write(data);
        if (bytesWritten != data.size()) { // 检查是否完整发送
            emit error("数据发送不完整");
            return;
        }
        qDebug() << "发送任务指令数据成功，总大小: " << bytesWritten << "字节, 内容: " << data.toHex().toUpper();

    } catch (const std::exception& e) { // 捕获标准异常
        QString errorMsg = QString("发送数据时发生异常: %1").arg(e.what());
        qDebug() << errorMsg;
        emit error(errorMsg);
    }
}


// 处理串口发生的错误
void DataSource::handleSerialError(QSerialPort::SerialPortError serialError)
{
    if (serialError == QSerialPort::NoError) { // 如果没有错误，则忽略
        return;
    }

    QString errorMessage = QString("串口发生错误: %1 (代码: %2)").arg(serialPort->errorString()).arg(serialError);
    emit error(errorMessage); // 发送错误信号
    qDebug() << errorMessage;

    // 如果不是 "串口未打开" 的错误，则尝试关闭串口以清理状态
    if (serialError != QSerialPort::NotOpenError && serialPort->isOpen()) {
        closeSerialPort();
    }
}

// 定期检查系统中的可用串口列表
void DataSource::checkAvailablePorts()
{
    QStringList currentPorts = m_availablePorts; // 保存当前已知的端口列表
    QStringList newPorts; // 用于存储新发现的端口列表

    const auto infos = QSerialPortInfo::availablePorts(); // 获取所有可用串口信息
    for (const QSerialPortInfo &info : infos) {
        newPorts << info.portName(); // 将串口名添加到新列表中
    }

    if (newPorts != currentPorts) { // 如果新旧列表不同
        m_availablePorts = newPorts; // 更新可用端口列表
        emit availablePortsChanged(); // 发送可用端口列表变更信号
        qDebug() << "可用串口列表已更新:" << m_availablePorts;
    }
}

// generateMergedFrame 函数已被移除，因为它不再被使用。
// 模拟数据现在直接生成DTO并发送。

// 生成并发送模拟的传感器、船体和设备数据 (使用DTO)
void DataSource::generateFakeData()
{
    // --- 更新模拟数据生成逻辑以使用DTO --- // 更新模拟数据生成逻辑以使用DTO
    SensorDataDto sensorDto = generateFakeSensorDataDto(); // 生成模拟传感器数据DTO
    VesselStateDto vesselDto = generateFakeVesselStateDto(); // 生成模拟船体状态DTO
    DeviceStatusDto deviceDto = generateFakeDeviceStatusDto(); // 生成模拟设备状态DTO

    emit sensorDataUpdated(sensorDto); // 发送传感器数据更新信号
    emit vesselStateUpdated(vesselDto); // 发送船体状态更新信号
    emit deviceStatusUpdated(deviceDto); // 发送设备状态更新信号
    
    qDebug() << "已生成并发送模拟DTO数据包";

    // 更新模拟的船只位置和状态，为下一次生成数据做准备
    updateSimulatedPosition();
}

// 生成模拟的传感器数据DTO
SensorDataDto DataSource::generateFakeSensorDataDto()
{
    SensorDataDto data; // 创建DTO实例
    auto rng = QRandomGenerator::global(); // 获取全局随机数生成器

    using namespace SensorLimits; // 使用传感器限制常量

    // CO2浓度 (ppm): 在预设范围内随机波动
    data.co2 = rng->bounded(CO2_MIN, CO2_MAX + 1); // +1确保上限可达到

    // 甲醛 (mg/m³): 模拟范围 0.01-0.15 mg/m³
    data.ch2o = rng->bounded(static_cast<int>(CH2O_MIN * 1000), static_cast<int>(CH2O_MAX * 1000) + 1) / 1000.0;

    // TVOC (mg/m³): 模拟范围 (ppb转换为mg/m³)
    // 转换因子 (以甲苯计): 1 ppb TVOC ≈ 0.00375 mg/m³
    double tvoc_min_mg_m3 = static_cast<double>(TVOC_MIN) * 0.00375;
    double tvoc_max_mg_m3 = static_cast<double>(TVOC_MAX) * 0.00375;
    // 生成微克/立方米级别的随机数再转换，以提高精度
    data.tvoc = rng->bounded(static_cast<int>(tvoc_min_mg_m3 * 1000000), static_cast<int>(tvoc_max_mg_m3 * 1000000) + 1) / 1000000.0;

    // PM2.5 (µg/m³): 在预设范围内随机波动
    data.pm25 = rng->bounded(PM25_MIN, PM25_MAX + 1);
    // PM10 (µg/m³): 在预设范围内随机波动
    data.pm10 = rng->bounded(PM10_MIN, PM10_MAX + 1);

    // 空气温度 (℃): 基础值 + 周期性波动 + 小幅随机扰动
    data.airTemperature = AIR_TEMP_MIN + (AIR_TEMP_MAX - AIR_TEMP_MIN) * 0.5 + // 中心值
                         sin(m_simulationElapsedTimer.elapsed() / 10000.0) * 5.0 + // 周期波动
                         rng->bounded(-100, 101) / 100.0; // 随机扰动 ±1.00°C
    data.airTemperature = qBound(AIR_TEMP_MIN, data.airTemperature, AIR_TEMP_MAX); // 限制在范围内

    // 空气湿度 (%RH): 基础值 + 周期性波动 + 小幅随机扰动
    double humidity_sim = HUMIDITY_MIN + (HUMIDITY_MAX - HUMIDITY_MIN) * 0.5 + // 中心值
                          sin(m_simulationElapsedTimer.elapsed() / 15000.0) * 15.0 + // 周期波动
                          rng->bounded(-200, 201) / 100.0; // 随机扰动 ±2.00%
    data.airHumidity = qBound(HUMIDITY_MIN, humidity_sim, HUMIDITY_MAX); // 限制在范围内

    // 水体浊度 (NTU): 在预设范围内随机波动
    data.waterTurbidity = rng->bounded(TURBIDITY_MIN, TURBIDITY_MAX + 1);

    // pH值: 在预设范围内随机波动
    data.ph = PH_MIN + rng->bounded(static_cast<int>((PH_MAX - PH_MIN) * 100) + 1) / 100.0;
    data.ph = qBound(PH_MIN, data.ph, PH_MAX);

    // 总溶解固体 (TDS, ppm): 在预设范围内随机波动
    data.tds = rng->bounded(TDS_MIN, TDS_MAX + 1);

    // 水体温度 (℃): 基础值 + 周期性波动 + 小幅随机扰动
    data.waterTemperature = WATER_TEMP_MIN + (WATER_TEMP_MAX - WATER_TEMP_MIN) * 0.5 + // 中心值
                           sin(m_simulationElapsedTimer.elapsed() / 20000.0) * 4.0 + // 周期波动
                           rng->bounded(-50, 51) / 100.0; // 随机扰动 ±0.50°C
    data.waterTemperature = qBound(WATER_TEMP_MIN, data.waterTemperature, WATER_TEMP_MAX);


    // 水位 (m): 模拟范围 0-100 mm -> 0-0.1 m
    data.waterLevel = rng->bounded(LEVEL_MIN, LEVEL_MAX + 1) / 1000.0;

    return data;
}

// 生成模拟的船体状态DTO
VesselStateDto DataSource::generateFakeVesselStateDto()
{
    VesselStateDto data; // 创建DTO实例

    // 使用当前模拟的船只状态值
    data.latitude = m_simulatedLatitude;
    data.longitude = m_simulatedLongitude;
    data.heading = m_simulatedHeading;
    data.speed = m_simulatedSpeed;

    return data;
}

// 生成模拟的设备状态DTO
DeviceStatusDto DataSource::generateFakeDeviceStatusDto()
{
    DeviceStatusDto data; // 创建DTO实例
    auto rng = QRandomGenerator::global(); // 获取全局随机数生成器

    // 电池电量 (%): 随模拟时间缓慢减少
    if (m_simulatedBattery > 0) {
        int elapsedMinutes = m_simulationElapsedTimer.elapsed() / 60000; // 已过去的模拟分钟数
        int batteryReduction = elapsedMinutes / 10; // 每10分钟电量减少1% (示例逻辑)
        m_simulatedBattery = 100 - batteryReduction; // 计算当前电量
        m_simulatedBattery = qMax(0, qMin(100, static_cast<int>(m_simulatedBattery))); // 确保电量在0-100%
    }
    data.batteryLevel = m_simulatedBattery;

    // 操作模式: 5%的概率随机切换模式 (自动/手动)
    if (rng->bounded(100) < 5) { 
        m_simulatedMode = !m_simulatedMode; // 切换模拟的模式状态
    }
    data.operationalMode = m_simulatedMode ? "自动" : "手动"; // 根据模拟状态设置模式描述

    return data;
}

// 更新模拟的船只位置、航向、速度等状态
void DataSource::updateSimulatedPosition()
{
    auto rng = QRandomGenerator::global(); // 获取全局随机数生成器

    // 更新速度 (0-5 m/s)
    if (rng->bounded(100) < 10) { // 10%的概率调整速度
        // 根据电机当前设定值估算速度因子
        double motor1Normalized = (m_motor1 - MOTOR_NEUTRAL) / static_cast<double>(MOTOR_MAX_VALUE - MOTOR_NEUTRAL);
        double motor2Normalized = (m_motor2 - MOTOR_NEUTRAL) / static_cast<double>(MOTOR_MAX_VALUE - MOTOR_NEUTRAL);
        double speedFactor = (motor1Normalized + motor2Normalized) / 2.0; // 平均归一化电机值
        m_simulatedSpeed = qAbs(speedFactor) * 5.0; // 转换为0-5 m/s的速度
        m_simulatedSpeed = qBound(0.0, m_simulatedSpeed, 5.0); // 限制速度范围
    }

    // 更新航向 (-180 到 180 度)
    if (rng->bounded(100) < 5) { // 5%的概率调整航向
        // 根据电机差值估算转向速率
        double motor1Normalized = (m_motor1 - MOTOR_NEUTRAL) / static_cast<double>(MOTOR_MAX_VALUE - MOTOR_NEUTRAL);
        double motor2Normalized = (m_motor2 - MOTOR_NEUTRAL) / static_cast<double>(MOTOR_MAX_VALUE - MOTOR_NEUTRAL);
        double turnRate = (motor2Normalized - motor1Normalized) * 10.0; // 转向速率因子 (度/调用周期)
        m_simulatedHeading += turnRate;

        // 将航向规范化到 -180 到 +180 度
        while (m_simulatedHeading > 180.0) m_simulatedHeading -= 360.0;
        while (m_simulatedHeading < -180.0) m_simulatedHeading += 360.0;
    }

    // 根据速度和航向更新模拟的地理位置
    if (m_simulatedSpeed > 0.05) { // 仅当速度大于阈值时才移动，避免微小漂移
        double headingRad = m_simulatedHeading * M_PI / 180.0; // 航向转换为弧度
        double distanceMoved = m_simulatedSpeed * (simulationTimer->interval() / 1000.0); // 移动距离 = 速度 * 时间间隔(秒)

        // 估算每度的米数 (简化模型，未考虑地球椭球模型)
        double metersPerDegreeLat = 111000.0; // 纬度方向上每度大约111公里
        double metersPerDegreeLon = metersPerDegreeLat * cos(m_simulatedLatitude * M_PI / 180.0); // 经度方向

        // 计算纬度和经度的变化量
        double latChange = distanceMoved * cos(headingRad) / metersPerDegreeLat;
        double lonChange = distanceMoved * sin(headingRad) / metersPerDegreeLon;

        // 更新模拟的纬度和经度
        m_simulatedLatitude += latChange;
        m_simulatedLongitude += lonChange;

        // 保证纬度和经度在有效范围内
        m_simulatedLatitude = qBound(-90.0, m_simulatedLatitude, 90.0);
        m_simulatedLongitude = qBound(-180.0, m_simulatedLongitude, 180.0);
    }
}

// 将高低字节组合为空气温度值 (℃)
double DataSource::convertAirTemperature(uint8_t high, uint8_t low)
{
    // 假设高位代表整数部分，低位代表小数部分 (乘以0.01)
    return static_cast<double>(high) + (static_cast<double>(low) / 100.0);
}

// 将高低字节组合为水体温度值 (℃)
double DataSource::convertWaterTemperature(uint8_t high, uint8_t low)
{
    // 假设高位代表整数部分，低位代表小数部分 (乘以0.01)
    // 与空气温度转换逻辑相同
    return static_cast<double>(high) + (static_cast<double>(low) / 100.0);
}

// 将小端序的两个字节 (低字节在前, 高字节在后) 转换为uint16_t
uint16_t DataSource::convertFromLittleEndian(uint8_t low, uint8_t high)
{
    return (static_cast<uint16_t>(high) << 8) | static_cast<uint16_t>(low);
}

// 新增：处理来自DeviceModule的设备控制指令的槽函数
void DataSource::handleDeviceControl(const DeviceControlDto& controlCmd)
{
    qDebug() << "DataSource: Received device control DTO. Updating internal state.";
    qDebug() << "  PumpActive:" << controlCmd.pumpActive << "(current:" << m_pumpState << ")";
    qDebug() << "  PumpAuto:" << controlCmd.pumpAuto << "(current:" << m_pump_mode << ")";
    qDebug() << "  BoatMode:" << controlCmd.boatMode << "(current m_boat_mode bool:" << m_boat_mode << ")";
    qDebug() << "  Motor1:" << controlCmd.motor1Value << "(current:" << m_motor1 << ")";
    qDebug() << "  Motor2:" << controlCmd.motor2Value << "(current:" << m_motor2 << ")";

    // 更新水泵自动模式状态
    if (m_pump_mode != controlCmd.pumpAuto) {
        m_pump_mode = controlCmd.pumpAuto;
        emit pump_modeChanged(); // 发送水泵模式变更信号
        qDebug() << "  m_pump_mode updated to:" << m_pump_mode;
    }

    // 更新水泵激活状态 (使用setPumpState为了封装可能存在的额外逻辑)
    // 直接调用setPumpState会再次触发pumpStateChanged，这是期望的行为
    setPumpState(controlCmd.pumpActive); // setPumpState内部会处理m_pumpState和pumpStateChanged

    // 更新船只操作模式
    // 将DeviceControlDto::BoatMode枚举映射到m_boat_mode (bool)
    // 假设 m_boat_mode: false=手动, true=自动. PositionHold可能也映射为true(自动)或特定逻辑。
    // 当前简单映射：Auto -> true, Manual/PositionHold -> false (或根据sendData需求调整)
    bool new_boat_mode_bool = false; // 默认为手动
    if (controlCmd.boatMode == DeviceControlDto::Auto) {
        new_boat_mode_bool = true;
    } else if (controlCmd.boatMode == DeviceControlDto::Manual) {
        new_boat_mode_bool = false;
    } else if (controlCmd.boatMode == DeviceControlDto::PositionHold) {
        // 如何将PositionHold映射到旧的m_boat_mode (bool)取决于sendData如何解释它。
        // 假设PositionHold在旧协议中也算一种“自动”或特殊手动模式。
        // 为保持与旧m_boat_mode兼容，可能需要更复杂的映射或调整sendData逻辑。
        // 当前简单处理：PositionHold视为非自动(手动)。
        new_boat_mode_bool = false; // 或者 true，取决于旧协议如何处理
        qDebug() << "  PositionHold mode received, mapped to m_boat_mode=false (Manual-like for legacy sendData)";
    }

    if (m_boat_mode != new_boat_mode_bool) {
        m_boat_mode = new_boat_mode_bool;
        emit boat_modeChanged(); // 发送船只模式变更信号
        qDebug() << "  m_boat_mode (bool) updated to:" << m_boat_mode;
    }

    // 更新电机1的值 (使用setMotor1为了封装校验逻辑和信号发送)
    // 直接调用setMotor1会再次触发motor1Changed，这是期望的行为
    setMotor1(static_cast<quint16>(controlCmd.motor1Value));

    // 更新电机2的值 (使用setMotor2为了封装校验逻辑和信号发送)
    setMotor2(static_cast<quint16>(controlCmd.motor2Value));

    // 注意: 此处不直接调用 sendData()。
    // sendData()的调用由其他逻辑触发 (例如TaskPointSelector.qml中的“发送航点”按钮)。
    // 当sendData被调用时，它将使用这里更新的m_pumpState, m_pump_mode, m_boat_mode, m_motor1, m_motor2成员变量
    // 来构建发送给硬件的串口数据包。
    qDebug() << "DataSource: Internal state updated by DTO. Ready for next sendData call.";
}
