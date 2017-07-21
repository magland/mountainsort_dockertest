# Download an example dataset and run processing
cd /work/fi_ss/analyses/manuscript/synthetic && prv-download datasets/K15/raw.mda.prv --server=river raw.mda && mp-run-process mountainsort.bandpass_filter --timeseries=raw.mda --timeseries_out=filt.mda --samplerate=30000 --freq_min=300 --freq_max=6000
