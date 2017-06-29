#ifndef SSTIMESERIESVIEW_H
#define SSTIMESERIESVIEW_H

#include <QWidget>
#include "plotarea_prev.h" //for Vec2
#include "sscommon.h"
#include "sslabelsmodel1_prev.h"
#include "ssabstractview_prev.h"

class SSTimeSeriesViewPrivate;
class SSTimeSeriesView : public SSAbstractView {
    Q_OBJECT
public:
    friend class SSTimeSeriesViewPrivate;
    explicit SSTimeSeriesView(QWidget* parent = 0);
    ~SSTimeSeriesView();

    Q_INVOKABLE void setData(DiskArrayModel* data, bool is_owner = false);
    Q_INVOKABLE DiskArrayModel* data();
    //Q_INVOKABLE void setLabels(Mda *T,Mda *L);
    Q_INVOKABLE void setLabels(DiskReadMdaOld* TL, bool is_owner = false);
    Q_INVOKABLE void setCompareLabels(DiskReadMdaOld* TL, bool is_owner = false);
    //Q_INVOKABLE void setConnectZeros(bool val);
    Q_INVOKABLE void setClipMode(bool val);
    bool clipMode();

    void setChannelLabels(const QStringList& labels);
    void setUniformVerticalChannelSpacing(bool val);
    void setTimesLabels(const QList<int>& times, const QList<int>& labels);

    SSLabelsModel* getLabels();

    double currentValue();
    QString viewType();
    void setMarkerLinesVisible(bool val);

    SSTimeSeriesPlot* plot();

private slots:
    void slot_request_move_to_timepoint(int t0);

signals:
    void requestCenterOnCursor();

protected:
    void keyPressEvent(QKeyEvent*);

protected:
private:
    SSTimeSeriesViewPrivate* d;

signals:

private slots:
};

#endif // SSTIMESERIESVIEW_H
