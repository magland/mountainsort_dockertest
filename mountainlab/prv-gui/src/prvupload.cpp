/******************************************************
** See the accompanying README and LICENSE files
** Author(s): Jeremy Magland
** Created: 10/1/2016
*******************************************************/

#include "prvupload.h"

#include <QFileInfo>
#include <QJsonDocument>
#include <QProcess>
#include <QUrl>
#include <QUrlQuery>
#include <taskprogress.h>
#include "cachemanager.h"
#include "mlcommon.h"
#include <QHostInfo>
#include <QJsonArray>
#include "mlnetwork.h"

namespace PrvUpload {
}

QString get_user_name_0()
{
#ifdef Q_OS_LINUX
    return qgetenv("USER");
#else
    return "user-name-not-supported-yet-in-non-linux";
// WW: not a standard way to fetch username
//QStringList home_path = QStandardPaths::standardLocations(QStandardPaths::HomeLocation);
//return home_path.first().split(QDir::separator()).last();
#endif
}

MLNetwork::PrvParallelUploader* PrvUpload::initiateUploadToServer(QString server_name, PrvRecord prv)
{
    QString local_path = prv.find_local_file();
    if (local_path.isEmpty()) {
        TaskProgress err;
        err.error() << "Unable to find local file corresponding to prv: " + prv.label;
        return 0;
    }
    QFileInfo finfo = local_path;
    int size0 = finfo.size();
    if (size0 == 0) {
        TaskProgress err;
        err.error() << "File is empty: " + local_path;
        return 0;
    }
    QString checksum00 = MLUtil::computeSha1SumOfFile(local_path);
    if (checksum00.isEmpty()) {
        TaskProgress err;
        err.error() << "Checksum is empty for: " + local_path;
        return 0;
    }

    QString fcs00 = "head1000-" + MLUtil::computeSha1SumOfFileHead(local_path, 1000);

    QString server_url = get_server_url_for_name(server_name);
    if (server_url.isEmpty()) {
        TaskProgress err;
        err.error() << "Unable to find server url in configuration for: " + server_name;
        return 0;
    }

    QJsonObject server0 = get_server_object_for_name(server_name);
    QString passcode = server0.value("passcode").toString();

    QUrl url(server_url);
    QUrlQuery query;
    query.addQueryItem("checksum", checksum00);
    query.addQueryItem("size", QString::number(size0));
    query.addQueryItem("fcs", fcs00);
    query.addQueryItem("passcode", passcode);

    QJsonObject info;
    info["src_path"] = local_path;
    info["server_url"] = server_url;
    info["user"] = get_user_name_0();
    info["local_host_name"] = QHostInfo::localHostName();
    info["date_uploaded"] = QDateTime::currentDateTime().toString("yyyy-MM-dd:hh-mm-ss");
    //info["params"] = QJsonObject::fromVariantMap(params);
    QString info_json = QJsonDocument(info).toJson();
    query.addQueryItem("info", QUrl::toPercentEncoding(info_json.toUtf8()));

    url.setQuery(query);

    MLNetwork::PrvParallelUploader* uploader = new MLNetwork::PrvParallelUploader;
    QObject::connect(uploader, SIGNAL(finished()), uploader, SLOT(deleteLater()));
    uploader->source_file_name = local_path;
    uploader->destination_url = url.toString();
    uploader->num_threads = 5;
    uploader->start();

    return uploader;

    /*
    QString tmp_fname = CacheManager::globalInstance()->makeLocalFile(MLUtil::makeRandomId(10) + ".PrvManagerdlg.prv");
    TextFile::write(tmp_fname, QJsonDocument(prv.original_object).toJson());

    Prv::ensure_remote(tmp_fname,server_name);

    QString cmd = "prv";
    QStringList args;
    args << "ensure-remote" << tmp_fname << "--server=" + server_name;

    execute_command_in_separate_thread(cmd, args);
    */
}

class ExecCmdThread : public QThread {
public:
    QString cmd;
    QStringList args;

    void run()
    {
        TaskProgress task("Running: " + cmd + " " + args.join(" "));
        task.log() << "Running: " + cmd + " " + args.join(" ");
        QProcess P;
        P.setReadChannelMode(QProcess::MergedChannels);
        P.start(cmd, args);
        P.waitForStarted();
        P.waitForFinished(-1);
        if (P.exitCode() != 0) {
            task.error() << "Error running: " + cmd + " " + args.join(" ");
        }
        task.log() << "Exit code: " + P.exitCode();
        task.log() << P.readAll();
    }
};

void execute_command_in_separate_thread(QString cmd, QStringList args, QObject* on_finished_receiver, const char* sig_or_slot)
{
    ExecCmdThread* thread = new ExecCmdThread;

    if (on_finished_receiver) {
        QObject::connect(thread, SIGNAL(finished()), on_finished_receiver, sig_or_slot);
    }

    /// Witold, is the following line okay?
    QObject::connect(thread, SIGNAL(finished()), thread, SLOT(deleteLater()));

    thread->cmd = cmd;
    thread->args = args;
    thread->start();
}
