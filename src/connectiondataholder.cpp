#include "connectiondataholder.h"
#include "mozillavpn.h"
#include "networkrequest.h"

#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QSplineSeries>
#include <QValueAxis>

constexpr int MAX_POINTS = 30;

// Let's refresh the IP address any 10 seconds.
constexpr int IPADDRESS_TIMER_MSEC = 10000;

ConnectionDataHolder::ConnectionDataHolder() : m_ipAddress(tr("Unknown"))
{
    emit ipAddressChanged();

    m_ipAddressTimer.start(IPADDRESS_TIMER_MSEC);
    connect(&m_ipAddressTimer, &QTimer::timeout, [this]() { updateIpAddress(); });
}

void ConnectionDataHolder::add(uint32_t txBytes, uint32_t rxBytes)
{
    qDebug() << "New connection data:" << txBytes << rxBytes;

    if (!m_txSeries || !m_rxSeries) {
        return;
    }

    // This is the first time we receive data. We need at least 2 calls in order to count the delta.
    if (m_txBytes == -1) {
        Q_ASSERT(m_rxBytes == -1);
        m_txBytes = txBytes;
        m_rxBytes = rxBytes;
        return;
    }

    // Normalize the value and store the previous max.
    uint32_t tmpTxBytes = txBytes;
    uint32_t tmpRxBytes = rxBytes;
    txBytes -= m_txBytes;
    rxBytes -= m_rxBytes;
    m_txBytes = tmpTxBytes;
    m_rxBytes = tmpRxBytes;

    m_maxBytes = std::max(m_maxBytes, std::max(txBytes, rxBytes));

    if (m_data.length() > MAX_POINTS) {
        m_data.removeAt(0);
    }

    m_data.append(QPair(txBytes, rxBytes));

    // Let's be sure we have all the x/y points.
    while (m_txSeries->count() <= MAX_POINTS) {
        m_txSeries->append(m_txSeries->count(), 0);
        m_rxSeries->append(m_rxSeries->count(), 0);
    }

    int i = 0;
    for (; i < MAX_POINTS - m_data.length(); ++i) {
        m_txSeries->replace(i, i, 0);
    }

    for (int j = 0; j < m_data.length(); ++j) {
        m_txSeries->replace(i, i, m_data.at(j).first);
        m_rxSeries->replace(i, i, m_data.at(j).second);
        ++i;
    }

    computeAxes();
}

void ConnectionDataHolder::setComponents(const QVariant &a_txSeries,
                                         const QVariant &a_rxSeries,
                                         const QVariant &a_axisX,
                                         const QVariant &a_axisY)
{
    qDebug() << "Set components";

    QtCharts::QSplineSeries *txSeries = qobject_cast<QtCharts::QSplineSeries *>(
        a_txSeries.value<QObject *>());

    if (m_txSeries != txSeries) {
        if (m_txSeries && m_txSeries->parent() == this) {
            delete m_txSeries;
        }

        m_txSeries = txSeries;
    }

    QtCharts::QSplineSeries *rxSeries = qobject_cast<QtCharts::QSplineSeries *>(
        a_rxSeries.value<QObject *>());

    if (m_rxSeries != rxSeries) {
        if (m_rxSeries && m_rxSeries->parent() == this) {
            delete m_rxSeries;
        }

        m_rxSeries = rxSeries;
    }

    QtCharts::QValueAxis *axisX = qobject_cast<QtCharts::QValueAxis *>(a_axisX.value<QObject *>());

    if (m_axisX != axisX) {
        if (m_axisX && m_axisX->parent() == this) {
            delete m_axisX;
        }

        m_axisX = axisX;
    }

    QtCharts::QValueAxis *axisY = qobject_cast<QtCharts::QValueAxis *>(a_axisY.value<QObject *>());

    if (m_axisY != axisY) {
        if (m_axisY && m_axisY->parent() == this) {
            delete m_axisY;
        }

        m_axisY = axisY;
    }
}

void ConnectionDataHolder::computeAxes()
{
    if (!m_axisX || !m_axisY) {
        return;
    }

    m_axisY->setRange(0, m_maxBytes);
}

void ConnectionDataHolder::start()
{
    m_txBytes = -1;
    m_rxBytes = -1;
    m_maxBytes = 0;
    m_data.clear();

    updateIpAddress();
}

void ConnectionDataHolder::stop()
{
    updateIpAddress();
}

void ConnectionDataHolder::updateIpAddress()
{
    qDebug() << "Updating IP address";

    NetworkRequest *request = NetworkRequest::createForIpInfo(MozillaVPN::instance());
    connect(request, &NetworkRequest::requestFailed, [](QNetworkReply::NetworkError error) {
        qDebug() << "IP address request failed" << error;
    });

    connect(request, &NetworkRequest::requestCompleted, [this](const QByteArray &data) {
        qDebug() << "IP address request completed";

        QJsonDocument json = QJsonDocument::fromJson(data);
        Q_ASSERT(json.isObject());
        QJsonObject obj = json.object();

        Q_ASSERT(obj.contains("ip"));
        QJsonValue value = obj.take("ip");
        Q_ASSERT(value.isString());

        m_ipAddress = value.toString();
        emit ipAddressChanged();
    });
}