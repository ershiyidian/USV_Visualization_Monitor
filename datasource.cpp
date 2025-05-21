#include "datasource.h"
#include <QDebug>
#include <QRandomGenerator>
#include <QDataStream>
#include <QSerialPortInfo>
#include <QDateTime>
#include <QElapsedTimer>
#include <sstream>
#include <iomanip>
#include <cmath>

using namespace FrameConstants;


DataSource::DataSource(QObject *parent)
    : QObject(parent)
    , m_pumpState(false)
    , m_motor1(MOTOR_NEUTRAL)
    , m_motor2(MOTOR_NEUTRAL)
    , m_isSimulating(false)
    , m_mergedFrameHeader(QString("%1").arg(FRAME_HEADER, 2, 16, QChar('0')).toUpper())
    , m_mergedFrameTrailer(QString("%1").arg(FRAME_TRAILER, 2, 16, QChar('0')).toUpper())
    , serialPort(new QSerialPort(this))
    , portUpdateTimer(new QTimer(this))
    , simulationTimer(new QTimer(this))
{
    // 连接串口信号
    connect(serialPort, &QSerialPort::readyRead, this, &DataSource::readSerialData);
    connect(serialPort, &QSerialPort::errorOccurred, this, &DataSource::handleSerialError);

    // 连接定时器信号
    connect(portUpdateTimer, &QTimer::timeout, this, &DataSource::checkAvailablePorts);
    connect(simulationTimer, &QTimer::timeout, this, &DataSource::generateFakeData);

    // 启动端口更新定时器
    portUpdateTimer->start(2000);

    // 设置模拟数据定时器间隔
    simulationTimer->setInterval(500);

    // 初始化模拟数据计时器
    m_simulationElapsedTimer.start();

    // 初始化模拟位置（上海）
    m_simulatedLatitude = 31.230416;
    m_simulatedLongitude = 121.473701;

    // 立即检查可用端口
    checkAvailablePorts();
}

DataSource::~DataSource()
{
    if (serialPort->isOpen()) {
        serialPort->close();
    }
}

QByteArray DataSource::parseHexString(const QString& hexStr)
{
    return QByteArray::fromHex(hexStr.toLatin1());
}

bool DataSource::isValidFrame(const QByteArray& data)
{
    if (data.size() < 2) return false;

    uint8_t header = static_cast<uint8_t>(data[0] & 0xFF);
    uint8_t trailer = static_cast<uint8_t>(data[1] & 0xFF);

    QString headerHex = QString("%1").arg(header, 2, 16, QChar('0')).toUpper();
    QString trailerHex = QString("%1").arg(trailer, 2, 16, QChar('0')).toUpper();

    return (headerHex == m_mergedFrameHeader && trailerHex == m_mergedFrameTrailer);
}

int DataSource::calculateFrameSize(const QByteArray& data)
{
    if (data.size() < 2) return -1;

    uint8_t header = static_cast<uint8_t>(data[0] & 0xFF);
    uint8_t trailer = static_cast<uint8_t>(data[1] & 0xFF);

    QString headerHex = QString("%1").arg(header, 2, 16, QChar('0')).toUpper();
    QString trailerHex = QString("%1").arg(trailer, 2, 16, QChar('0')).toUpper();

    if (headerHex == m_mergedFrameHeader && trailerHex == m_mergedFrameTrailer) {
        return RECEIVE_FRAME_SIZE;
    }

    return -1;
}

bool DataSource::openSerialPort(const QString& portName, int baudRate)
{
    if (serialPort->isOpen()) {
        serialPort->close();
    }

    serialPort->setPortName(portName);
    serialPort->setBaudRate(baudRate);
    serialPort->setDataBits(QSerialPort::Data8);
    serialPort->setParity(QSerialPort::NoParity);
    serialPort->setStopBits(QSerialPort::OneStop);
    serialPort->setFlowControl(QSerialPort::NoFlowControl);

    qDebug() << "尝试打开串口:" << portName << "波特率:" << baudRate;

    if (serialPort->open(QIODevice::ReadWrite)) {
        qDebug() << "串口已打开:" << portName;
        emit portOpenChanged();
        return true;
    } else {
        qDebug() << "串口打开失败:" << serialPort->errorString();
        emit error(serialPort->errorString());
        return false;
    }
}

void DataSource::closeSerialPort()
{
    if (serialPort->isOpen()) {
        serialPort->close();
        qDebug() << "串口已关闭";
        emit portOpenChanged();
    }
}

void DataSource::setIsSimulating(bool enabled)
{
    if (m_isSimulating == enabled) return;

    m_isSimulating = enabled;

    if (enabled) {
        // 重置模拟数据开始时间
        m_simulationElapsedTimer.restart();
        simulationTimer->start();
        qDebug() << "模拟开始";
    } else {
        simulationTimer->stop();
        qDebug() << "模拟停止";
    }

    emit isSimulatingChanged();
}

void DataSource::setMergedFrameHeader(const QString& header)
{
    if (m_mergedFrameHeader != header) {
        m_mergedFrameHeader = header;
        emit mergedFrameHeaderChanged();
    }
}

void DataSource::setMergedFrameTrailer(const QString& trailer)
{
    if (m_mergedFrameTrailer != trailer) {
        m_mergedFrameTrailer = trailer;
        emit mergedFrameTrailerChanged();
    }
}

bool DataSource::isValidMotorValue(quint16 value) const
{
    // 675~1353, 1013为静止
    return (value >= MOTOR_MIN_VALUE && value <= MOTOR_MAX_VALUE);
}

bool DataSource::isValidGpsCoordinate(double lat, double lon) const
{
    return (lat >= -90.0 && lat <= 90.0) && (lon >= -180.0 && lon <= 180.0);
}

void DataSource::processReceivedData(const QByteArray& data)
{
    buffer.append(data);

    // 保持缓冲区至少2字节用于检查帧头帧尾
    while (buffer.size() >= 2) {
        // 检查帧头帧尾
        uint8_t header = static_cast<uint8_t>(buffer[0] & 0xFF);
        uint8_t trailer = static_cast<uint8_t>(buffer[1] & 0xFF);

        if (header != FRAME_HEADER || trailer != FRAME_TRAILER) {
            buffer.remove(0, 1); // 移除一个字节并重新检查
            continue;
        }

        // 检查是否有足够的数据形成完整的帧
        if (buffer.size() < RECEIVE_FRAME_SIZE) {
            // 数据不足，等待更多数据
            qDebug() << "数据不足，等待更多数据. 当前:" << buffer.size() << "字节，需要:" << RECEIVE_FRAME_SIZE;
            break;
        }

        // 提取完整帧
        QByteArray frame = buffer.left(RECEIVE_FRAME_SIZE);
        qDebug() << "收到完整数据帧: " << frame.toHex().toUpper();

        // 提取关键数据段 - 包含所有传感器、船只和设备数据
        QByteArray mergedData = frame.mid(SENSOR_DATA_OFFSET, 47);
        QString hexData = mergedData.toHex().toUpper();

        // 发送合并数据信号
        emit mergedDataReceived(hexData);

        // 移除已处理的帧
        buffer.remove(0, RECEIVE_FRAME_SIZE);
    }
}

void DataSource::readSerialData()
{
    QByteArray data = serialPort->readAll();
    qDebug() << "读取到串口数据:" << data.toHex().toUpper();
    processReceivedData(data);
}

void DataSource::setPumpState(bool state)
{
    if (m_pumpState != state) {
        m_pumpState = state;
        emit pumpStateChanged();
        qDebug() << "水泵状态：" << (state ? "开启" : "关闭");
    }
}

void DataSource::setMotor1(quint16 value)
{
    // 验证电机值是否有效
    if (!isValidMotorValue(value)) {
        qWarning() << "电机1值无效:" << value;
        emit error(QString("电机1值无效: %1").arg(value));
        return;
    }

    if (m_motor1 != value) {
        m_motor1 = value;
        emit motor1Changed();
    }
}

void DataSource::setMotor2(quint16 value)
{
    // 验证电机值是否有效
    if (!isValidMotorValue(value)) {
        qWarning() << "电机2值无效:" << value;
        emit error(QString("电机2值无效: %1").arg(value));
        return;
    }

    if (m_motor2 != value) {
        m_motor2 = value;
        emit motor2Changed();
    }
}

void DataSource::updatePumpModeInDataSource(bool mode){
    if(m_pump_mode!=mode){
    m_pump_mode=mode;
    emit pump_modeChanged();
    }
}
void DataSource::updateBoatModeInDataSource(bool mode){
    if(m_boat_mode!=mode){
        m_boat_mode=mode;
        emit boat_modeChanged();
    }
}

void DataSource::sendData(const std::vector<QString>& taskPointsData)
{
    if (!serialPort->isOpen()) {
        qDebug() << "串口未打开，无法发送数据";
        emit error("串口未打开，无法发送数据");
        return;
    }

    try {
        // 检查任务点数据
        if (taskPointsData.empty()) {
            emit error("任务点数据为空");
            return;
        }

        // 创建数据包
        QByteArray data;
        // 设置帧头帧尾
        int minSize =FRAME_HEADER_SIZE+TIMESTAMP_LENGTH+HOME_POINT_SIZE+7;
        data.resize(minSize);
        data[0] = FRAME_HEADER;
        data[1] = FRAME_TRAILER;

        // 处理时间戳
        QString firstData = taskPointsData[0];
        QStringList list = firstData.split(",");
        if (list.size() < 3) {
            emit error("Home点数据格式不正确");
            return;
        }

        // 解析时间戳
        std::string timestampStr = list[2].toStdString();
        std::tm tm = {};
        std::istringstream ss(timestampStr);
        ss >> std::get_time(&tm, "%Y-%m-%d %H:%M:%S");
        if (ss.fail()) {
            emit error("时间戳解析失败");
            return;
        }
        std::time_t time = std::mktime(&tm);
        qint64 sec = static_cast<qint64>(time);

        // 写入时间戳(8字节, 偏移 2-9): uint64 类型
        QDataStream timeStream(&data, QIODevice::WriteOnly);
        timeStream.setByteOrder(QDataStream::LittleEndian);
        timeStream.device()->seek(FRAME_HEADER_SIZE);
        timeStream << sec;

        // 处理Home点和任务点数据
        int taskIndex = 0;
        for (const auto& dataStr : taskPointsData) {
            //根据任务点个数扩充data数组大小
            int taskCount=taskPointsData.size();
            int ValidTaskCount=taskCount>(MAX_TASK_POINTS+1) ? (MAX_TASK_POINTS+1):taskCount;
            int totalSize=minSize+(ValidTaskCount-1)*TASK_POINT_SIZE;
            data.resize(totalSize);

            if (taskIndex > MAX_TASK_POINTS) {
                qDebug() << "任务点数量超出限制，只处理前" << MAX_TASK_POINTS + 1 << "个点";
                break;
            }

            QStringList parts = dataStr.split(",");
            if (parts.size() < 2) {
                qWarning() << "任务点数据格式不正确: " << dataStr;
                continue;
            }

            // 解析经纬度
            bool ok1 = false, ok2 = false;
            double longitude = parts[0].toDouble(&ok1);
            double latitude = parts[1].toDouble(&ok2);

            if (!ok1 || !ok2 || !isValidGpsCoordinate(latitude, longitude)) {
                qWarning() << "无效的经纬度: " << longitude << "," << latitude;
                continue;
            }

            // 计算数据存储位置
            int pointOffset;
            if (taskIndex == 0) {
                // Home点
                pointOffset = FRAME_HEADER_SIZE+TIMESTAMP_LENGTH;
            } else {
                // 任务点 (索引从0开始)
                pointOffset =FRAME_HEADER_SIZE+TIMESTAMP_LENGTH+HOME_POINT_SIZE+ (taskIndex - 1) * TASK_POINT_SIZE;
            }
            // 写入经度
            int lonInt = static_cast<int>(longitude);
            data[pointOffset] = static_cast<char>(lonInt);

            float lonDecimal = longitude - lonInt;
            memcpy(data.data() + pointOffset + 1, &lonDecimal, 4);

            // 写入纬度
            int latInt = static_cast<int>(latitude);
            data[pointOffset + 5] = static_cast<char>(latInt);

            float latDecimal = latitude - latInt;
            memcpy(data.data() + pointOffset + 6, &latDecimal, 4);

            taskIndex++;
        }

    //处理控制指令块

        //水泵模式 ( pump_mode , 1字节): 0 = 手动，1 = 自动。
        qDebug()<<"水泵模式："<<m_pump_mode;
        data[FRAME_HEADER_SIZE+TIMESTAMP_LENGTH+HOME_POINT_SIZE+(taskIndex-1)*TASK_POINT_SIZE] = m_pump_mode ? 1 : 0;

        //水泵控制 ( m_pumpState , 1字节): 在手动模式下有效，0 = 关闭，1 = 开启。
        data[FRAME_HEADER_SIZE+TIMESTAMP_LENGTH+HOME_POINT_SIZE+(taskIndex-1)*TASK_POINT_SIZE+1] = m_pumpState ? 1 : 0;

        //艇模式 ( usv_mode , 1字节): 0 = 手动，1 = 自动，2 = 位置保持
        qDebug()<<"艇模式："<<m_boat_mode;
        data[FRAME_HEADER_SIZE+TIMESTAMP_LENGTH+HOME_POINT_SIZE+(taskIndex-1)*TASK_POINT_SIZE+2]=m_boat_mode;

        //艇控制 ( usv_ctrl , 4字节):
        QDataStream motorStream(&data, QIODevice::WriteOnly);
        motorStream.setByteOrder(QDataStream::LittleEndian);
        motorStream.device()->seek(FRAME_HEADER_SIZE+TIMESTAMP_LENGTH+HOME_POINT_SIZE+(taskIndex-1)*TASK_POINT_SIZE+3);
        motorStream << m_motor1;
        motorStream << m_motor2;

    //处理保留区(14字节): 暂时未使用，填充 0。
        data.resize(data.size()+RESERVED_SIZE);
        std::fill(data.end()-RESERVED_SIZE,data.end(),0);

        // 发送数据
        qint64 bytesWritten = serialPort->write(data);
        if (bytesWritten != data.size()) {
            emit error("数据发送不完整");
            return;
        }

        qDebug() << "发送数据成功，大小: " << bytesWritten << "字节";

    } catch (const std::exception& e) {
        QString errorMsg = QString("发送数据出错: %1").arg(e.what());
        qDebug() << errorMsg;
        emit error(errorMsg);
    }
}

void DataSource::handleSerialError(QSerialPort::SerialPortError error)
{
    if (error == QSerialPort::NoError) {
        return;
    }

    QString errorMessage = QString("串口错误: %1").arg(serialPort->errorString());
    emit this->error(errorMessage);
    qDebug() << errorMessage;

    if (error != QSerialPort::NotOpenError) {
        closeSerialPort();
    }
}

void DataSource::checkAvailablePorts()
{
    QStringList currentPorts = m_availablePorts;
    QStringList newPorts;

    const auto infos = QSerialPortInfo::availablePorts();
    for (const QSerialPortInfo &info : infos) {
        newPorts << info.portName();
    }

    if (newPorts != currentPorts) {
        m_availablePorts = newPorts;
        emit availablePortsChanged();
        qDebug() << "可用端口已更新:" << m_availablePorts;
    }
}

QByteArray DataSource::generateMergedFrame()
{
    QByteArray frame;
    frame.resize(RECEIVE_FRAME_SIZE);
    frame.fill(0);

    // 设置帧头帧尾
    frame[0] = FRAME_HEADER;
    frame[1] = FRAME_TRAILER;

    // 生成传感器数据
    SensorData sensorData = generateFakeSensorData();

    // 添加PWM值（电机值）
    uint16_t pwm1 = m_motor1;
    uint16_t pwm2 = m_motor2;

    // 转为字节数组，小端序
    frame[SENSOR_DATA_OFFSET] = pwm1 & 0xFF;
    frame[SENSOR_DATA_OFFSET + 1] = (pwm1 >> 8) & 0xFF;
    frame[SENSOR_DATA_OFFSET + 2] = pwm2 & 0xFF;
    frame[SENSOR_DATA_OFFSET + 3] = (pwm2 >> 8) & 0xFF;

    // 添加CO2数据 (2字节, 小端序)
    uint16_t co2 = sensorData.CO2;
    frame[SENSOR_DATA_OFFSET + 4] = co2 & 0xFF;
    frame[SENSOR_DATA_OFFSET + 5] = (co2 >> 8) & 0xFF;

    // 添加甲醛数据 (2字节, 小端序)
    uint16_t ch2o = sensorData.CH2O;
    frame[SENSOR_DATA_OFFSET + 6] = ch2o & 0xFF;
    frame[SENSOR_DATA_OFFSET + 7] = (ch2o >> 8) & 0xFF;

    // 添加TVOC数据 (2字节, 小端序)
    uint16_t tvoc = sensorData.TVOC;
    frame[SENSOR_DATA_OFFSET + 8] = tvoc & 0xFF;
    frame[SENSOR_DATA_OFFSET + 9] = (tvoc >> 8) & 0xFF;

    // 添加PM2.5数据 (2字节, 小端序)
    uint16_t pm25 = sensorData.PM2_5;
    frame[SENSOR_DATA_OFFSET + 10] = pm25 & 0xFF;
    frame[SENSOR_DATA_OFFSET + 11] = (pm25 >> 8) & 0xFF;

    // 添加PM10数据 (2字节, 小端序)
    uint16_t pm10 = sensorData.PM10;
    frame[SENSOR_DATA_OFFSET + 12] = pm10 & 0xFF;
    frame[SENSOR_DATA_OFFSET + 13] = (pm10 >> 8) & 0xFF;

    // 添加空气温度 (2字节分别表示整数和小数部分)
    frame[SENSOR_DATA_OFFSET + 14] = sensorData.temperature_air_High;
    frame[SENSOR_DATA_OFFSET + 15] = sensorData.temperature_air_Low;

    // 添加空气湿度 (2字节分别表示整数和小数部分)
    frame[SENSOR_DATA_OFFSET + 16] = sensorData.humidity_air_High;
    frame[SENSOR_DATA_OFFSET + 17] = sensorData.humidity_air_Low;

    // 添加浊度 (2字节, 小端序)
    uint16_t turbidity = sensorData.turbidity;
    frame[SENSOR_DATA_OFFSET + 18] = turbidity & 0xFF;
    frame[SENSOR_DATA_OFFSET + 19] = (turbidity >> 8) & 0xFF;

    // 添加pH值 (2字节, 小端序，实际值×100)
    uint16_t ph = sensorData.PH;
    frame[SENSOR_DATA_OFFSET + 20] = ph & 0xFF;
    frame[SENSOR_DATA_OFFSET + 21] = (ph >> 8) & 0xFF;

    // 添加TDS (2字节, 小端序)
    uint16_t tds = sensorData.TDS;
    frame[SENSOR_DATA_OFFSET + 22] = tds & 0xFF;
    frame[SENSOR_DATA_OFFSET + 23] = (tds >> 8) & 0xFF;

    // 添加水温 (2字节分别表示整数和小数部分)
    frame[SENSOR_DATA_OFFSET + 24] = sensorData.temperaturewater_High;
    frame[SENSOR_DATA_OFFSET + 25] = sensorData.temperaturewater_Low;

    // 添加液位 (2字节, 小端序)
    int16_t level = sensorData.dis;
    frame[SENSOR_DATA_OFFSET + 26] = level & 0xFF;
    frame[SENSOR_DATA_OFFSET + 27] = (level >> 8) & 0xFF;

    // 生成船只数据
    BoatData boatData = generateFakeBoatData();

    // 写入纬度数据 (5字节格式: 1字节整数部分 + 4字节小数部分)
    int latInt = static_cast<int>(boatData.latitude);
    float latDecimal = boatData.latitude - latInt;
    frame[LAT_OFFSET] = static_cast<char>(latInt);
    memcpy(frame.data() + LAT_OFFSET + 1, &latDecimal, 4);

    // 写入经度数据 (5字节格式: 1字节整数部分 + 4字节小数部分)
    int lonInt = static_cast<int>(boatData.longitude);
    float lonDecimal = boatData.longitude - lonInt;
    frame[LON_OFFSET] = static_cast<char>(lonInt);
    memcpy(frame.data() + LON_OFFSET + 1, &lonDecimal, 4);

    // 写入航向角 (2字节: 1字节整数+符号, 1字节小数部分)
    int headingInt = static_cast<int>(boatData.heading);
    uint8_t headingDec = static_cast<uint8_t>((std::abs(boatData.heading) - std::abs(headingInt)) * 100);
    frame[HEADING_OFFSET] = static_cast<char>(headingInt);
    frame[HEADING_OFFSET + 1] = headingDec;

    // 写入速度 (2字节: 1字节整数, 1字节小数)
    uint8_t speedInt = static_cast<uint8_t>(boatData.speed);
    uint8_t speedDec = static_cast<uint8_t>((boatData.speed - speedInt) * 100);
    frame[SPEED_OFFSET] = speedInt;
    frame[SPEED_OFFSET + 1] = speedDec;

    // 生成设备数据
    DeviceData deviceData = generateFakeDeviceData();

    // 写入电池电量 (2字节, 小端序)
    uint16_t battery = deviceData.battery;
    frame[BATTERY_OFFSET] = battery & 0xFF;
    frame[BATTERY_OFFSET + 1] = (battery >> 8) & 0xFF;

    // 写入模式 (1字节)
    frame[MODE_OFFSET] = deviceData.mode ? 1 : 0;

    return frame;
}

void DataSource::generateFakeData()
{
    QByteArray fakeFrame = generateMergedFrame();

    if (fakeFrame.size() == RECEIVE_FRAME_SIZE) {
        // 重要修改：使用完整字节范围，而不是只取部分
        QByteArray content = fakeFrame.mid(SENSOR_DATA_OFFSET, MODE_OFFSET + 1 - SENSOR_DATA_OFFSET);
        QString hexData = content.toHex().toUpper();

        // 调试信息 - 显示模拟数据内容和长度
        qDebug() << "生成模拟数据帧: " << hexData.left(40) << "... 长度:" << hexData.length();

        // 发送合并数据信号，传递完整数据
        emit mergedDataReceived(hexData);
    } else {
        qDebug() << "生成模拟数据帧失败，大小:" << fakeFrame.size() << " 应为:" << RECEIVE_FRAME_SIZE;
    }

    // 更新模拟位置
    updateSimulatedPosition();
}

DataSource::SensorData DataSource::generateFakeSensorData()
{
    SensorData data;
    auto rng = QRandomGenerator::global();

    using namespace SensorLimits;

    // 模拟PWM值 (当前电机值)
    data.PWM_SET1 = m_motor1;
    data.PWM_SET2 = m_motor2;

    // CO2: 400-2000 ppm 范围内合理波动
    data.CO2 = rng->bounded(CO2_MIN, CO2_MAX);

    // 甲醛: 0.01-0.15 mg/m³ (以整数表示，单位0.001 mg/m³)
    data.CH2O = static_cast<uint16_t>(rng->bounded(
        static_cast<int>(CH2O_MIN * 1000),
        static_cast<int>(CH2O_MAX * 1000)
        ));

    // TVOC: 50-1000 ppb
    data.TVOC = rng->bounded(TVOC_MIN, TVOC_MAX);

    // PM2.5: 0-250 μg/m³
    data.PM2_5 = rng->bounded(PM25_MIN, PM25_MAX);

    // PM10: 0-350 μg/m³
    data.PM10 = rng->bounded(PM10_MIN, PM10_MAX);

    // 空气温度: 5-40°C (带有周期性波动)
    double airTemp = AIR_TEMP_MIN + (AIR_TEMP_MAX - AIR_TEMP_MIN) * 0.5 +
                     sin(m_simulationElapsedTimer.elapsed() / 10000.0) * 5.0 +
                     rng->bounded(-100, 101) / 100.0; // 修复: 整数转换为浮点数
    data.temperature_air_High = static_cast<uint8_t>(airTemp);
    data.temperature_air_Low = static_cast<uint8_t>((airTemp - static_cast<int>(airTemp)) * 100);

    // 空气湿度: 20-90% (带有周期性波动)
    double humidity = HUMIDITY_MIN + (HUMIDITY_MAX - HUMIDITY_MIN) * 0.5 +
                      sin(m_simulationElapsedTimer.elapsed() / 15000.0) * 15.0 +
                      rng->bounded(-200, 201) / 100.0; // 修复: 整数转换为浮点数
    humidity = qBound(HUMIDITY_MIN, humidity, HUMIDITY_MAX);
    data.humidity_air_High = static_cast<uint8_t>(humidity);
    data.humidity_air_Low = static_cast<uint8_t>((humidity - static_cast<int>(humidity)) * 100);

    // 浊度: 0-25 NTU
    data.turbidity = rng->bounded(TURBIDITY_MIN, TURBIDITY_MAX);

    // pH值: 5.0-10.0 (整数部分*100)
    double ph = PH_MIN + rng->bounded(static_cast<int>((PH_MAX - PH_MIN) * 100)) / 100.0;
    data.PH = static_cast<uint16_t>(ph * 100);

    // TDS: 50-1500 ppm
    data.TDS = rng->bounded(TDS_MIN, TDS_MAX);

    // 水温: 5-35°C (带有周期性波动)
    double waterTemp = WATER_TEMP_MIN + (WATER_TEMP_MAX - WATER_TEMP_MIN) * 0.5 +
                       sin(m_simulationElapsedTimer.elapsed() / 20000.0) * 4.0 +
                       rng->bounded(-50, 51) / 100.0; // 修复: 整数转换为浮点数
    data.temperaturewater_High = static_cast<uint8_t>(waterTemp);
    data.temperaturewater_Low = static_cast<uint8_t>((waterTemp - static_cast<int>(waterTemp)) * 100);

    // 液位: 0-100 mm
    data.dis = rng->bounded(LEVEL_MIN, LEVEL_MAX);

    return data;
}

DataSource::BoatData DataSource::generateFakeBoatData()
{
    BoatData data;

    // 使用当前模拟位置
    data.latitude = m_simulatedLatitude;
    data.longitude = m_simulatedLongitude;
    data.heading = m_simulatedHeading;
    data.speed = m_simulatedSpeed;

    return data;
}

DataSource::DeviceData DataSource::generateFakeDeviceData()
{
    DeviceData data;
    auto rng = QRandomGenerator::global();

    // 电池电量: 随时间缓慢减少 (模拟实际电池消耗)
    if (m_simulatedBattery > 0) {
        // 每10分钟减少约1%
        int elapsedMinutes = m_simulationElapsedTimer.elapsed() / 60000;
        m_simulatedBattery = 100 - (elapsedMinutes / 10);
        m_simulatedBattery = qMax(0, qMin(100, static_cast<int>(m_simulatedBattery)));
    }
    data.battery = m_simulatedBattery;

    // 模式: 使用当前模式或随机切换
    if (rng->bounded(100) < 5) { // 5%概率切换模式
        m_simulatedMode = !m_simulatedMode;
    }
    data.mode = m_simulatedMode;

    return data;
}

void DataSource::updateSimulatedPosition()
{
    auto rng = QRandomGenerator::global();

    // 删除未使用的变量
    // double elapsedSec = m_simulationElapsedTimer.elapsed() / 1000.0;

    // 更新速度 (0-5 m/s)
    if (rng->bounded(100) < 10) { // 10%概率改变速度
        // 根据电机值计算速度
        double motor1Normalized = (m_motor1 - MOTOR_NEUTRAL) / static_cast<double>(MOTOR_MAX_VALUE - MOTOR_NEUTRAL);
        double motor2Normalized = (m_motor2 - MOTOR_NEUTRAL) / static_cast<double>(MOTOR_MAX_VALUE - MOTOR_NEUTRAL);

        // 计算平均速度因子 (-1.0 到 1.0)
        double speedFactor = (motor1Normalized + motor2Normalized) / 2.0;

        // 转换为速度 (0-5 m/s)
        m_simulatedSpeed = qAbs(speedFactor) * 5.0;
    }

    // 更新航向 (-180 到 180)
    if (rng->bounded(100) < 5) { // 5%概率改变航向
        // 根据电机差计算航向变化
        double motor1Normalized = (m_motor1 - MOTOR_NEUTRAL) / static_cast<double>(MOTOR_MAX_VALUE - MOTOR_NEUTRAL);
        double motor2Normalized = (m_motor2 - MOTOR_NEUTRAL) / static_cast<double>(MOTOR_MAX_VALUE - MOTOR_NEUTRAL);

        // 电机差异决定转向速率
        double turnRate = (motor2Normalized - motor1Normalized) * 10.0; // 每秒改变的度数

        // 更新航向
        m_simulatedHeading += turnRate;

        // 保持在-180到180范围内
        while (m_simulatedHeading > 180.0) m_simulatedHeading -= 360.0;
        while (m_simulatedHeading < -180.0) m_simulatedHeading += 360.0;
    }

    // 根据速度和航向更新位置
    if (m_simulatedSpeed > 0.1) { // 只有当速度足够大时才移动
        // 将航向转换为弧度，计算移动方向
        double headingRad = m_simulatedHeading * M_PI / 180.0;

        // 计算位置变化 (基于纬度的经纬度变化率约为111km每度)
        double metersPerDegree = 111000.0;
        double latChange = m_simulatedSpeed * cos(headingRad) / metersPerDegree;
        double lonChange = m_simulatedSpeed * sin(headingRad) / (metersPerDegree * cos(m_simulatedLatitude * M_PI / 180.0));

        // 更新位置
        m_simulatedLatitude += latChange * 0.01; // 缩放为合适的变化率
        m_simulatedLongitude += lonChange * 0.01;

        // 保证位置在有效范围内
        m_simulatedLatitude = qBound(-90.0, m_simulatedLatitude, 90.0);
        m_simulatedLongitude = qBound(-180.0, m_simulatedLongitude, 180.0);
    }
}

double DataSource::convertAirTemperature(uint8_t high, uint8_t low)
{
    return high + (low / 100.0);
}

double DataSource::convertWaterTemperature(uint8_t high, uint8_t low)
{
    return high + (low / 100.0);
}

uint16_t DataSource::convertFromLittleEndian(uint8_t low, uint8_t high)
{
    return (high << 8) | low;
}
