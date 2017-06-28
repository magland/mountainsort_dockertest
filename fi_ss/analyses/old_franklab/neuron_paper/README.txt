Tetrode dataset
	Run mountainsort
		> kron-run ms2mn tetrode
		> kron-view results ms2mn tetrode
	Retrieve manual sortings
		> kron-run manual1 tetrode
		> kron-run manual2 tetrode
		> kron-run manual3 tetrode
	Compare results:
		e.g., > kron-view compare_results manual1,ms2mn tetrode


Probe dataset
	Run mountainsort
		> kron-run ms2mn probe

Neto-Kampff ground truth dataset
	Run mountainsort
		> kron-run ms2mn nk1_ch101-128
	Retrieve juxta (ground truth) extracted using ahb's script
		> kron-run juxta nk1_ch101-128
	Compare them:
		> kron-view compare_results juxta,ms2mn nk1_ch101-128
	The above can be repeated using the full 128 channels by replacing "nk1_ch101-128" by "nk1"
	Run kilosort
		> kron-run ks256 nk1
	Run spyking circus
		Make sure that spyking-circus is installed properly and in your path
		You may need to restart the processing daemon if there are path issues
		> kron-run sc nk1
	Pull up the static results (and export the confusion matrices)
		> kron-run juxta nk1
		> kron-run results_ms2mn nk1
		> kron-run results_ks256 nk1
		> kron-run results_sc nk1
		> kron-view compare_results juxta,results_ms2mn nk1
		> kron-view compare_results juxta,results_ks256 nk1
		> kron-view compare_results juxta,results_sc nk1

Timings:

ms2mn tetrode on jfm's home computer (12 threads)
	9.091 (mountainsort.bandpass_filter)
	6.011 (mask_out_artifacts)
	5.009 (mountainsort.whiten)
	40.049 (mountainsort.ms2_002_multineighborhood)
	2.008 (merge_across_channels_v2)
	3.011 (mountainsort.fit_stage)
	2.005 (mountainsort.compute_templates)
	1.008 (mountainsort.reorder_labels)
	1.005 (mountainsort.cluster_metrics)
	3.006 (mountainsort.isolation_metrics)
	1.026 (mountainsort.combine_cluster_metrics)
	Total: 73 seconds for 46 minutes of data == 38x real time

ms2mn nk1_ch101-128 on jfm's home computer (12 threads)
	10.439 (mountainsort.bandpass_filter)
	38.728 (mountainsort.whiten)
	67.072 (mountainsort.ms2_002_multineighborhood)
	7.013 (merge_across_channels_v2)
	19.255 (mountainsort.fit_stage)
	5.01 (mountainsort.compute_templates)
	1.01 (mountainsort.reorder_labels)
	1.045 (mountainsort.cluster_metrics)
	12.165 (mountainsort.isolation_metrics)
	1.007 (mountainsort.combine_cluster_metrics)

ks128 nk1_ch101-128 on jfm's home computer (NVIDIA Corporation GK104GL [Quadro K4200])
	234.281 (ml_kilosort)

ks256 nk1 on jfm's home computer (NVIDIA Corporation GK104GL [Quadro K4200])
	493.569 (ml_kilosort)

ms2mn nk1 on jfm's home computer (12 threads)
  63.687 (mountainsort.bandpass_filter)
  556.65 (mountainsort.whiten)
  426.425 (mountainsort.ms2_002_multineighborhood)
  348.43 (merge_across_channels_v2)
  350.95 (mountainsort.fit_stage)
  32.044 (mountainsort.compute_templates)
  1.008 (mountainsort.reorder_labels)
  2.013 (mountainsort.cluster_metrics)
  212.826 (mountainsort.isolation_metrics)
  1.006 (mountainsort.combine_cluster_metrics)

sc nk1_ch101-128 on jfm's home computer (12 threads)
  514.114 (ml_spyking_circus) -- that's using threshold of 8 and max_elts=1000
 
