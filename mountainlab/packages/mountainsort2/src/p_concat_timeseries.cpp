#include "p_concat_timeseries.h"

#include <diskreadmda.h>
#include <diskreadmda32.h>
#include <diskwritemda.h>

bool p_concat_timeseries(QStringList timeseries_list, QString timeseries_out)
{
    if (timeseries_list.isEmpty()) {
        qWarning() << "timeseries_list is empty.";
        return false;
    }

    DiskReadMda32 X0(timeseries_list.value(0));
    bigint M = X0.N1();

    bigint NN = 0;
    for (bigint i = 0; i < timeseries_list.count(); i++) {
        DiskReadMda32 X1(timeseries_list.value(i));
        NN += X1.N2();
    }

    DiskWriteMda Y(X0.mdaioHeader().data_type, timeseries_out, M, NN);
    bigint n0 = 0;
    for (bigint i = 0; i < timeseries_list.count(); i++) {
        DiskReadMda32 X1(timeseries_list.value(i));
        Mda32 chunk;
        if (!X1.readChunk(chunk, 0, 0, M, X1.N2())) {
            qWarning() << "Problem reading chunk in concat_timeseries";
            return false;
        }
        if (!Y.writeChunk(chunk, 0, n0)) {
            qWarning() << "Problem writing chunk in concat_timeseries";
            return false;
        }
        n0 += X1.N2();
    }

    return true;
}
