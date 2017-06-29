/******************************************************
** See the accompanying README and LICENSE files
** Author(s): Jeremy Magland
** Created: 4/7/2016
*******************************************************/

#include "mbcontroller.h"
#include <QCoreApplication>
#include <QProcess>
#include "mlcommon.h"
#include "mlcommon.h"
#include "mlnetwork.h"

#include <QJsonDocument>
#include <QDebug>

class MBControllerPrivate {
public:
    MBController* q;

    QString m_mountainbrowser_url;
    //QString m_mscmdserver_url;
    QString m_mlproxy_url;
    QList<QProcess*> m_processes;
};

MBController::MBController()
{
    d = new MBControllerPrivate;
    d->q = this;
}

MBController::~MBController()
{
    foreach (QProcess* P, d->m_processes) {
        P->terminate(); //I think it's okay to terminate a process. It won't cause this program to crash.
        delete P;
    }

    delete d;
}

void MBController::setMLProxyUrl(const QString& url)
{
    d->m_mlproxy_url = url;
}

QString MBController::mlProxyUrl() const
{
    return d->m_mlproxy_url;
}

QString MBController::getJson(QString url_or_path)
{
    if (url_or_path.startsWith("http")) {
        return MLNetwork::httpGetText(url_or_path);
    }
    else {
        return TextFile::read(url_or_path);
    }
}

QString MBController::getText(QString url_or_path)
{
    if (url_or_path.startsWith("http")) {
        return MLNetwork::httpGetText(url_or_path);
    }
    else {
        return TextFile::read(url_or_path);
    }
}

void MBController::openSortingResult(QString json)
{
    MBExperiment E;
    E.json = QJsonDocument::fromJson(json.toUtf8()).object();
    E.exp_id = E.json["exp_id"].toString();
    QString exp_type = E.json["exp_type"].toString();
    QString basepath = E.json["basepath"].toString();
    basepath = d->m_mlproxy_url + "/mdaserver/" + basepath;
    if ((!basepath.isEmpty()) && (!basepath.endsWith("/")))
        basepath += "/";
    if (exp_type == "sorting_result") {
        QString pre = basepath + E.json["pre"].toString();
        QString filt = basepath + E.json["filt"].toString();
        QString raw = basepath + E.json["raw"].toString();
        QString firings = basepath + E.json["firings"].toString();
        QStringList args;
        args << "--mlproxy_url=" + d->m_mlproxy_url;
        args << "--mode=overview2"
             << "--pre=" + pre << "--filt=" + filt << "--raw=" + raw << "--firings=" + firings << "--window_title=" + firings;
        double samplerate = E.json["samplerate"].toDouble();
        if (!samplerate) {
            qWarning() << "Sample rate defaulting to 30000";
            samplerate = 30000;
        }
        args << QString("--samplerate=%1").arg(samplerate);
        QString mv_exe = MLUtil::mountainlabBasePath() + "/mountainview/bin/mountainview";
        QProcess* process = new QProcess;
        process->setProcessChannelMode(QProcess::MergedChannels);
        connect(process, SIGNAL(readyRead()), this, SLOT(slot_ready_read()));
        qDebug().noquote() << "EXECUTING" << mv_exe + " " + args.join(" "); // okay
        process->start(mv_exe, args);
        d->m_processes << process;
    }
}

void MBController::slot_ready_read()
{
    QProcess* P = qobject_cast<QProcess*>(sender());
    if (!P) {
        qWarning() << "Unexpected problem in slot_ready_read";
        return;
    }
    while (P->canReadLine()) {
        QByteArray str = P->readLine();
        printf("%s", str.constData());
        fflush(stdout);
    }
}
