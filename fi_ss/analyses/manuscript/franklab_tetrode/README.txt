View the results from the paper:

First download the appropriate files by doing:
prv-download results/ms2mn_tetrode.mv2 --server=http://datalaboratory.org:8005
prv-download results/ks64_tetrode.mv2 --server=http://datalaboratory.org:8005
prv-download results/sc_tetrode.mv2 --server=http://datalaboratory.org:8005

Then open the viewer
mountainview results/ms2mn_tetrode.mv2
mountainview results/ks64_tetrode.mv2
mountainview results/sc_tetrode.mv2

Or directly
mountainview --samplerate=30000 --raw=tetrode/raw.mda.prv --firings=results/firings_ms2mn.mda.prv --cluster_metrics=results/cluster_metrics_ms2mn.json --geom=tetrode/geom.csv --curation=curation.ms2mn.script
etc

Do the comparisons:
mountaincompare results/ms2mn_tetrode.mv2 results/ks64_tetrode.mv2 --exclude_rejected
