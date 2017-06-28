/******************************************************
** See the accompanying README and LICENSE files
** Author(s): Jeremy Magland
** Created: 8/24/2016
*******************************************************/

#include "clusterdetailplugin.h"

#include <clusterdetailview.h>
#include <sslvcontext.h>
#include <QMessageBox>

class ClusterDetailPluginPrivate {
public:
    ClusterDetailPlugin* q;
};

ClusterDetailPlugin::ClusterDetailPlugin()
{
    d = new ClusterDetailPluginPrivate;
    d->q = this;
}

ClusterDetailPlugin::~ClusterDetailPlugin()
{
    delete d;
}

QString ClusterDetailPlugin::name()
{
    return "ClusterDetail";
}

QString ClusterDetailPlugin::description()
{
    return "View the average waveform and other details for each cluster";
}

void ClusterDetailPlugin::initialize(MVMainWindow* mw)
{
    mw->registerViewFactory(new ClusterDetailFactory(mw));
}

ClusterDetailFactory::ClusterDetailFactory(MVMainWindow* mw, QObject* parent)
    : MVAbstractViewFactory(mw, parent)
{
}

QString ClusterDetailFactory::id() const
{
    return QStringLiteral("open-cluster-details");
}

QString ClusterDetailFactory::name() const
{
    return tr("Cluster Detail");
}

QString ClusterDetailFactory::title() const
{
    return tr("Detail");
}

MVAbstractView* ClusterDetailFactory::createView(MVAbstractContext* context)
{
    ClusterDetailView* X = new ClusterDetailView(context);
    SSLVContext* c = qobject_cast<SSLVContext*>(context);
    if (c->selectedClusters().isEmpty()) {
        QMessageBox::information(0, "Cluster detail view", "You must first select some clusters");
        return 0;
    }
    X->setClustersToView(c->selectedClusters());
    return X;
}
