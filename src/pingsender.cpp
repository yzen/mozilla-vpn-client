/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "pingsender.h"
#include "logger.h"
#include "pingsendworker.h"

#if defined(MVPN_LINUX) || defined(MVPN_ANDROID)
#include "platforms/linux/linuxpingsendworker.h"
#elif defined(MVPN_MACOS) || defined(MVPN_IOS)
#include "platforms/macos/macospingsendworker.h"
#else
#include "platforms/dummy/dummypingsendworker.h"
#endif

#ifdef QT_DEBUG
#include "platforms/dummy/dummypingsendworker.h"
#endif

#include <QThread>

namespace {
Logger logger(LOG_NETWORKING, "PingSender");
}

PingSender::PingSender(QObject *parent, QThread *thread) : QObject(parent)
{
    m_time.start();

    PingSendWorker *worker =
#if defined(MVPN_LINUX) || defined(MVPN_ANDROID)
        new LinuxPingSendWorker();
#elif defined(MVPN_MACOS) || defined(MVPN_IOS)
        new MacOSPingSendWorker();
#else
        new DummyPingSendWorker();
#endif

    worker->moveToThread(thread);

    connect(thread, &QThread::finished, worker, &QObject::deleteLater);
    connect(this, &PingSender::sendPing, worker, &PingSendWorker::sendPing);
    connect(this, &QObject::destroyed, worker, &QObject::deleteLater);
    connect(worker, &PingSendWorker::pingFailed, this, &PingSender::pingFailed);
    connect(worker, &PingSendWorker::pingSucceeded, this, &PingSender::pingSucceeded);
}

void PingSender::send(const QString &destination)
{
    logger.log() << "PingSender send to" << destination;
    emit sendPing(destination);
}

void PingSender::pingFailed()
{
    logger.log() << "PingSender - Ping Failed";
    emit completed(this, m_time.elapsed());
}

void PingSender::pingSucceeded()
{
    logger.log() << "PingSender - Ping Succeded";
    emit completed(this, m_time.elapsed());
}
