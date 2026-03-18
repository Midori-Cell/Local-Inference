# Local-Inference

## Environment
I recommend using a separate conda environment for every inference software: https://docs.conda.io/projects/conda/en/latest/user-guide/install/linux.html 
<br /> You can set them up with `conda create -n NAME` and `conda activate NAME`.
<br /> 
<br /> For installing k6, which is needed for benchmarking llama-server, you need to download Go: https://go.dev/doc/install
<br /> (you can use `conda install -c conda-forge go` to install Go only in your environment)
<br /> You also need a dataset. For further instructions with benchmarking llama-server see https://github.com/ggml-org/llama.cpp/tree/master/tools/server/bench

## Llama.cpp
Notes:
+ This worked for my setup. If you encounter some errors, you may have to adjust some of the commands (like using a different CUDA version or specifying your Nvidia architecture with -DCMAKE_CUDA_ARCHITECTURES=XYZ). It is also worth checking out ik_llama.cpp: https://github.com/ikawrakow/ik_llama.cpp/
+ If you did not set your $GOPATH, you can direct to your xk6 folder manually at the end and run `./xk6 build master --with github.com/phymbert/xk6-sse`

<br /> To set up Llama.cpp you can run the following commands. They will install CUDA, clone Llama.cpp, build it with Nvidia GPU support, build some llama programs (llama-cli, llama-server, llama-bench, llama-speculative, ...), copy them into the llama.cpp main directory and install k6.

Installation Commands:
```
conda install cmake git cuda -c nvidia/label/cuda=17.0.0 -y
git clone https://github.com/ggerganov/llama.cpp
cmake llama.cpp -B llama.cpp/build -DBUILD_SHARED_LIBS=ON -DGGML_CUDA=ON -DCMAKE_CUDA_COMPILER=$(which nvcc)
cmake --build llama.cpp/build --config Release -j --clean-first --target llama-quantize llama-cli llama-gguf-split llama-bench llama-server llama-speculative
cp llama.cpp/build/bin/llama-* llama.cpp
go install go.k6.io/xk6/cmd/xk6@latest
$GOPATH/bin/xk6 build master --with github.com/phymbert/xk6-sse
```

## Scripts
Note:
+ You need to adjust all paths in these scripts (model paths, benchmarking paths, etc.). Also: you need to manually create the "benchmarks" and "benchmarks-server" folders for logging.

I have provided some example scripts in this repo. 

### llama-cli.sh
This starts llama-cli (command-line inference) with a specific model and some options.
<br /> You find information about the options here: https://github.com/ggml-org/llama.cpp/blob/master/tools/completion/README.md

### llama-server.sh
Starts the HTTP server. Meant for inference. With this version you can dynamically select the models in the integrated web UI. You can access it at http://localhost:8080/ in your browser.
<br /> Options: https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md

### llama-bench.sh
Starts the benchmarking tool for llama-cli. These options gave me a nice speedup for my system with the 1.58b DeepSeek-R1 model from Unsloth AI.
<br /> Specific llama-bench options: https://github.com/ggml-org/llama.cpp/tree/master/tools/llama-bench

### llama-server-for-benchmarking.sh
Also starts the HTTP server but this one is meant for benchmarking and not chatting.

### benchmark-server.sh
Starts k6 with your dataset (make sure the k6 file is in the same directory, or adjust the path accordingly). You need to start the HTTP server before running this script. It also adds your server configuration at the end of your logging files.
<br /> I have also provided the dataset I was using (ShareGPT...) and my script.js, but it may be better if you set this up yourself.

