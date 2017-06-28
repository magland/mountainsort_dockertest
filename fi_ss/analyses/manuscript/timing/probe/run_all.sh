#/bin/bash

kron-run ms3_16thr 1hr --_nodaemon --_force_run | tee output_1hr.txt
kron-run ms3_16thr 2hr --_nodaemon --_force_run | tee output_2hr.txt
kron-run ms3_16thr 3hr --_nodaemon --_force_run | tee output_3hr.txt
kron-run ms3_16thr 4hr --_nodaemon --_force_run | tee output_4hr.txt
kron-run ms3_16thr 5hr --_nodaemon --_force_run | tee output_5hr.txt
kron-run ms3_16thr 6hr --_nodaemon --_force_run | tee output_6hr.txt
kron-run ms3_16thr 7hr --_nodaemon --_force_run | tee output_7hr.txt
