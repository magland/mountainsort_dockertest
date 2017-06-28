#include "p_detect_events.h"

#include <diskreadmda32.h>
#include <mda.h>
#include "mlcommon.h"

namespace P_detect_events {
QVector<double> detect_events(const QVector<double>& X, double detect_threshold, double detect_interval, int sign);
QVector<double> subsample_events(const QVector<double>& X, double subsample_factor);
}

bool p_detect_events(QString timeseries, QString event_times_out, P_detect_events_opts opts)
{
    DiskReadMda32 X(timeseries);
    bigint M = X.N1();
    bigint N = X.N2();

    QVector<double> data(N);
    printf("Collecting data vector...\n");
    if (opts.detect_rms_window > 0) {
        printf("Collecting data vector & computing RMS...\n");
        /*assert (M == 1) * not for multichannel */
        for (bigint i = 0; i < N; i++) {
            double val = 0;
            for (int wind = 0; wind < opts.detect_rms_window; wind++) {
                val += X.value(1, i + wind) * X.value(1, i + wind);
            }
            data[i] = sqrt(val);
        }
        double datamean = MLCompute::mean(data); /*zero mean*/
        for (bigint i = 0; i < N; i++) {
            data[i] = data[i] - datamean;
        }
    }
    else {
        if (opts.central_channel > 0) {
            if (opts.central_channel - 1 >= M) {
                qWarning() << "Central channel is out of range:" << opts.central_channel << M;
                return false;
            }
            for (bigint i = 0; i < N; i++) {
                data[i] = X.value(opts.central_channel - 1, i);
            }
        }
        else {
            for (bigint i = 0; i < N; i++) {
                double best_value = 0;
                bigint best_m = 0;
                for (bigint m = 0; m < M; m++) {
                    double val = X.value(m, i);
                    if (opts.sign < 0)
                        val = -val;
                    if (opts.sign == 0)
                        val = fabs(val);
                    if (val > best_value) {
                        best_value = val;
                        best_m = m;
                    }
                }
                data[i] = X.value(best_m, i);
            }
        }
    }

    printf("Detecting events...\n");
    QVector<double> event_times = P_detect_events::detect_events(data, opts.detect_threshold, opts.detect_interval, opts.sign);

    printf("%d events detected.\n", event_times.count());

    if ((opts.subsample_factor) && (opts.subsample_factor < 1)) {
        printf("Subsampling by factor %g...\n", opts.subsample_factor);
        event_times = P_detect_events::subsample_events(event_times, opts.subsample_factor);
    }

    printf("Creating result array...\n");
    Mda ret(1, event_times.count());
    for (bigint j = 0; j < event_times.count(); j++) {
        ret.setValue(event_times[j], j);
    }
    printf("Writing result...\n");
    return ret.write64(event_times_out);
}

namespace P_detect_events {
QVector<double> detect_events(const QVector<double>& X, double detect_threshold, double detect_interval, int sign)
{
    double mean = MLCompute::mean(X);
    double stdev = MLCompute::stdev(X);
    double threshold2 = detect_threshold * stdev;

    bigint N = X.count();
    QVector<bigint> to_use(N);
    to_use.fill(0);
    bigint last_best_ind = 0;
    double last_best_val = 0;
    for (bigint n = 0; n < N; n++) {
        double val = (X[n] - mean);
        if (sign < 0)
            val = -val;
        else if (sign == 0)
            val = fabs(val);
        if (n - last_best_ind > detect_interval)
            last_best_val = 0;
        if (val >= threshold2) {
            if (last_best_val > 0) {
                if (val > last_best_val) {
                    to_use[n] = 1;
                    to_use[last_best_ind] = 0;
                    last_best_ind = n;
                    last_best_val = val;
                }
            }
            else {
                if (val > 0) {
                    to_use[n] = 1;
                    last_best_ind = n;
                    last_best_val = val;
                }
            }
        }
    }
    QVector<double> times;
    for (bigint n = 0; n < N; n++) {
        if (to_use[n]) {
            times << n;
        }
    }
    return times;
}

double pseudorandomnumber(double i)
{
    double ret = sin(i + cos(i));
    ret = (ret + 5) - (bigint)(ret + 5);
    return ret;
}

QVector<double> subsample_events(const QVector<double>& X, double subsample_factor)
{
    QVector<double> ret;
    for (bigint i = 0; i < X.count(); i++) {
        double randnum = pseudorandomnumber(i);
        if (randnum <= subsample_factor)
            ret << X[i];
    }
    return ret;
}
}
