/******************************************************
** See the accompanying README and LICENSE files
** Author(s): Jeremy Magland
** Created: 3/30/2016
*******************************************************/

#include "diskreadmda.h"
#include "mda.h"
#include <QDateTime>
#include <QDir>
#include <QString>
#include <QStringList>
#include <mlcommon.h>

#include "cachemanager.h"
#include "mlcommon.h"

void usage();
QString get_chunk_code(const QString& fname, const QString& datatype, int index, int size);
QString get_sha1_code(const QString& fname);

Mda quantize8(Mda& X); //returns array of size 1x2 containing the min/max dynamic range

int main(int argc, char* argv[])
{
    CLParams CLP(argc, argv);
    QString arg0 = CLP.unnamed_parameters.value(0);
    QString arg1 = CLP.unnamed_parameters.value(1);

    if (arg0.isEmpty()) {
        usage();
        return 0;
    }

    if (arg0 == "size") {
        if (arg1.isEmpty()) {
            printf("Problem with second argument\n");
            return -1;
        }
        if (!QFile::exists(arg1)) {
            printf("Input path does not exist: %s\n", arg1.toLatin1().data());
            return -1;
        }
        DiskReadMda X(arg1);
        printf("%d,%d,%d,%d,%d,%d\n", X.N1(), X.N2(), X.N3(), X.N4(), X.N5(), X.N6());
        return 0;
    }
    else if (arg0 == "info") {
        if (arg1.isEmpty()) {
            printf("Problem with second argument\n");
            return -1;
        }
        if (!QFile::exists(arg1)) {
            printf("Input path does not exist: %s\n", arg1.toLatin1().data());
            return -1;
        }
        DiskReadMda X(arg1);
        printf("%d,%d,%d,%d,%d,%d\n", X.N1(), X.N2(), X.N3(), X.N4(), X.N5(), X.N6());
        QString sha1_code = get_sha1_code(arg1);
        printf("%s\n", sha1_code.toLatin1().data());
        printf("%d\n", (int)QFileInfo(arg1).lastModified().toMSecsSinceEpoch());
        return 0;
    }
    else if (arg0 == "readChunk") {
        if (arg1.isEmpty()) {
            printf("Problem with second argument\n");
            return -1;
        }
        if (!QFile::exists(arg1)) {
            printf("Input path does not exist: %s\n", arg1.toLatin1().data());
            return -1;
        }
        QString outpath = CLP.named_parameters["outpath"].toString();
        ;
        if (outpath.isEmpty()) {
            printf("outpath is empty\n");
            return -1;
        }
        QString index_string = CLP.named_parameters["index"].toString();
        int index = index_string.toLong();
        QString size_string = CLP.named_parameters["size"].toString();
        int size = size_string.toLong();
        QString datatype = CLP.named_parameters["datatype"].toString();
        if (datatype.isEmpty()) {
            printf("datatype is empty\n");
            return -1;
        }
        QString code = get_chunk_code(arg1, datatype, index, size);
        if (code.isEmpty()) {
            printf("Error computing chunk code.\n");
            return -1;
        }
        CacheManager::globalInstance()->setLocalBasePath(outpath);
        QString fname = CacheManager::globalInstance()->makeLocalFile(code + ".mda");
        QString relative_fname = fname.mid(outpath.count());
        //QString fname = outpath + "/" + code + ".mda";
        if (!QFile::exists(fname)) {
            DiskReadMda X(arg1);
            Mda chunk;
            X.readChunk(chunk, index, size);

            if (datatype == "float32") {
                if (!chunk.write32(fname + ".tmp")) {
                    printf("Error writing file: %s.tmp\n", fname.toLatin1().data());
                    return -1;
                }
            }
            else if (datatype == "float64") {
                if (!chunk.write64(fname + ".tmp")) {
                    printf("Error writing file: %s.tmp\n", fname.toLatin1().data());
                    return -1;
                }
            }
            else if (datatype == "float32_q8") {
                Mda dynamic_range = quantize8(chunk);
                if (!chunk.write8(fname + ".tmp")) {
                    printf("Error writing file: %s.tmp\n", fname.toLatin1().data());
                    return -1;
                }
                if (!dynamic_range.write32(fname + ".q8")) {
                    printf("Error writing file: %s.q8\n", fname.toLatin1().data());
                    return -1;
                }
            }
            else {
                printf("Unsupported data type: %s\n", datatype.toLatin1().data());
                return -1;
            }
            DiskReadMda check(fname + ".tmp");
            if (check.totalSize() != size) {
                printf("Unexpected dimension of output file: %ld<>%ld (%ldx%ldx%ld)\n", check.totalSize(), size, X.N1(), X.N2(), X.N3());
                QFile::remove(fname + ".tmp");
                return -1;
            }
            if (!QFile::rename(fname + ".tmp", fname)) {
                printf("Error renaming file to %s\n", fname.toLatin1().data());
                return -1;
            }
        }
        else {
            DiskReadMda check(fname);
            if (check.totalSize() != size) {
                printf("Unexpected dimensions of existing output file: %d<>%d\n", check.totalSize(), size);
                QFile::remove(fname);
                return -1;
            }
            if (datatype == "float32_q8") {
                DiskReadMda check_q8(fname + ".q8");
                if (check_q8.totalSize() != 2L) {
                    printf("Unexpected dimensions of existing output.q8 file: %d<>%d\n", check_q8.totalSize(), 2L);
                    QFile::remove(fname);
                    QFile::remove(fname + ".q8");
                    return -1;
                }
            }
        }

        printf("%s\n", relative_fname.toLatin1().data());
        //printf("%s.mda\n", code.toLatin1().data());
        return 0;
    }
    else {
        printf("unexpected command\n");
        return -1;
    }
}

void usage()
{
    printf("mdachunk size fname.mda\n");
    printf("mdachunk readChunk fname.mda --index=0 --size=5000 --outpath=/output/path --datatype=float32|float64|float32_q8\n");
}

QString get_file_info(const QString& fname)
{
    QString format = "yyyy-MM-dd.hh.mm.ss.zzz";
    QString created = QFileInfo(fname).created().toString(format);
    QString modified = QFileInfo(fname).lastModified().toString(format);
    qint64 size = QFileInfo(fname).size();
    return QString("created=%1;modified=%2;size=%3").arg(created).arg(modified).arg(size);
}

bool is_out_of_date(const QString& sha1_fname, const QString& fname)
{
    QString str = TextFile::read(sha1_fname).split("\n").value(1); //the second line
    if (str.isEmpty())
        return true;
    return (str != get_file_info(fname));
}

QString get_sha1_code(const QString& fname)
{
    return MLUtil::computeSha1SumOfFile(fname);
    /*
    QString sha1_fname = fname + ".sha1";
    QString sha1;
    if ((!QFile::exists(sha1_fname)) || (is_out_of_date(sha1_fname, fname))) {
        QString cmd = QString("sha1sum %1 > %2").arg(fname).arg(sha1_fname);
        if (system(cmd.toLatin1().data()) != 0) {
            printf("Problem in system call: %s\n", cmd.toLatin1().data());
            return "";
        }
        QString content = TextFile::read(sha1_fname);
        content = content.trimmed() + "\n" + get_file_info(fname);
        TextFile::write(sha1_fname, content);
    }
    if (QFile::exists(sha1_fname)) {
        sha1 = TextFile::read(sha1_fname).trimmed();
        int ind = sha1.indexOf(" ");
        sha1 = sha1.mid(0, ind);
    }
    if (sha1.count() != 40) {
        if (QFile::exists(sha1_fname))
            QFile::remove(sha1_fname); //must be corrupted
        sha1 = "";
    }
    return sha1;
    */
}

QString get_chunk_code(const QString& fname, const QString& datatype, int index, int size)
{
    QString sha1 = get_sha1_code(fname);
    return QString("%1.%2.%3.%4").arg(sha1).arg(datatype).arg(index).arg(size);
}

Mda quantize8(Mda& X)
{
    double minval = MLCompute::min(X.totalSize(), X.dataPtr());
    double maxval = MLCompute::max(X.totalSize(), X.dataPtr());
    Mda dynamic_range(1, 2);
    dynamic_range.setValue(minval, 0);
    dynamic_range.setValue(maxval, 1);
    int N = X.totalSize();
    double* Xptr = X.dataPtr();
    for (int i = 0; i < N; i++) {
        Xptr[i] = (int)((Xptr[i] - minval) / (maxval - minval) * 255);
    }
    return dynamic_range;
}
