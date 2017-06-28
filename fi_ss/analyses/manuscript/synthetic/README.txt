-- Outline of steps --
Step 1: Download the datasets
Step 2: Use mlconfig to ensure the datasets are in a prv search path
Step 3: Run the processing and view the results

Note: you can also generate new datasets. See the generate_datasets directory.
Note: the figures are generated using scripts in the analyze_results directory.

-- Detailed steps --

Step 1: Download the datasets

Choose a directory on your computer where you want to keep raw data.
Let's call that /path/to/raw

prv-download datasets/K15/raw.mda.prv /path/to/raw --server=river
prv-download datasets/K15/firings_true.mda.prv /path/to/raw --server=river
prv-download datasets/K15/waveforms_true.mda.prv /path/to/raw --server=river

Repeat for K30 and K60

Step 2: Use mlconfig to ensure the datasets are in a prv search path

Run mlconfig
Follow the instructions and be sure to add
/path/to/raw
to your prv search path

Step 3: Run the processing and view the results

kron-run ms3 K15 --_nodaemon
kron-view results ms2 K15

Repeat for K30 and K60
