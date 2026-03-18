##!/bin/bash

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
RESULTS_FILE="$HOME/benchmarks/benchmark_result_$TIMESTAMP"
VRAM_LOG="$HOME/benchmarks/vram_log.csv"

echo -e "\n Benchmark has started, please wait. \n"

echo -e "---------- Benchmark Start ----------" >> "$VRAM_LOG"
echo -e "Timestamp: $TIMESTAMP" >> "$VRAM_LOG"


# run nvidia-smi in background and safe PID
nvidia-smi \
	--query-gpu=timestamp,index,power.draw,utilization.gpu,utilization.memory,memory.used \
	--loop 0.5 \
	--format=csv >> "$VRAM_LOG" &
MONITOR_PID=$!

# wait 0.5 seconds before benchmarking. Just to be sure
sleep 0.5


echo -e "---------- Benchmark Start ----------" >> "$RESULTS_FILE"

# run llama-bench
GGML_CUDA_GRAPH_OPT=1
~/llama.cpp/llama-bench \
	--model ~/models/DeepSeek-R1-UD-IQ1_S.gguf \
	--repetitions 5  \
	--threads 15 \
	--poll 100 \
	--n-gpu-layers 62 \
	--tensor-split 2/1.8/1.80/1.9 \
	--split-mode layer \
	--cache-type-k q4_0 \
        --cache-type-v f16 \
	--flash-attn 0 \
        -ot ".ffn_(down)_exps.=CPU" \
	--ubatch-size 416 \
	--n-cpu-moe 4 \
	--verbose \
	--progress \
	--output json | tee -a "$RESULTS_FILE"

echo -e "----------- Benchmark End -----------\n\n" >> "$RESULTS_FILE"
echo -e "----------- Benchmark End -----------\n\n" >> "$VRAM_LOG"

# terminate nvidia-smi PID
kill $MONITOR_PID


echo -e "\n Done. Results are in $RESULTS_FILE \n"
