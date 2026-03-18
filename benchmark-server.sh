#!/bin/bash

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
VRAM_LOG="$HOME/benchmarks-server/vram_log-${TIMESTAMP}.csv"
RESULTS_FILE_RAW="$HOME/benchmarks-server/benchmarks-results-server-raw-${TIMESTAMP}.json"
RESULTS_FILE_SUMMARY="$HOME/benchmarks-server/benchmarks-results-server-summary-${TIMESTAMP}.json"


# run nvidia-smi in background and safe PID
nvidia-smi \
        --query-gpu=timestamp,index,power.draw,utilization.gpu,utilization.memory,memory.used \
        --loop 0.5 \
        --format=csv >> "$VRAM_LOG" &
MONITOR_PID=$!

# wait 0.5 seconds before benchmarking. Just to be sure
sleep 0.5


echo -e "\n Benchmark has started, please wait. \n"

./k6 run script.js \
	--duration 7m \
 	--iterations 25 \
	--vus 1 \
	--out json="$RESULTS_FILE_RAW" \
	--summary-export="$RESULTS_FILE_SUMMARY" \

echo -e "\n------- Server Configuration --------" >> "$RESULTS_FILE_RAW"
echo -e "\n------- Server Configuration --------" >> "$RESULTS_FILE_SUMMARY"
# adds your server configuration at the end of the logging files
cat ./llama-server-for-benchmarking.sh >> "$RESULTS_FILE_RAW"
cat ./llama-server-for-benchmarking.sh >> "$RESULTS_FILE_SUMMARY"


# terminate nvidia-smi PID
kill $MONITOR_PID

echo -e "\n Done. Results are in ./results \n"
