#/bin/bash

if true; then
	mkdir raw
	RAW="/home/magland/dev/fi_ss/raw/7hr_nt19_full.mda"

	echo "1hr"
	mdaconvert extract_time_chunk $RAW raw/raw.probe_1hr.mda --t1=0 --t2=108e6

	echo "2hr"
	mdaconvert extract_time_chunk $RAW raw/raw.probe_2hr.mda --t1=0 --t2=216e6

	echo "3hr"
	mdaconvert extract_time_chunk $RAW raw/raw.probe_3hr.mda --t1=0 --t2=324e6

	echo "4hr"
	mdaconvert extract_time_chunk $RAW raw/raw.probe_4hr.mda --t1=0 --t2=432e6

	echo "5hr"
	mdaconvert extract_time_chunk $RAW raw/raw.probe_5hr.mda --t1=0 --t2=540e6

	echo "6hr"
	mdaconvert extract_time_chunk $RAW raw/raw.probe_6hr.mda --t1=0 --t2=648e6

	echo "7hr"
	mdaconvert extract_time_chunk $RAW raw/raw.probe_7hr.mda --t1=0 --t2=756e6
fi

if true; then
	prv-create raw/raw.probe_1hr.mda datasets/1hr/raw.mda.prv
	prv-create raw/raw.probe_2hr.mda datasets/2hr/raw.mda.prv
	prv-create raw/raw.probe_3hr.mda datasets/3hr/raw.mda.prv
	prv-create raw/raw.probe_4hr.mda datasets/4hr/raw.mda.prv
	prv-create raw/raw.probe_5hr.mda datasets/5hr/raw.mda.prv
	prv-create raw/raw.probe_6hr.mda datasets/6hr/raw.mda.prv
	prv-create raw/raw.probe_7hr.mda datasets/7hr/raw.mda.prv
fi
