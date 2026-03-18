~/llama.cpp/llama-cli \
        --model ~/models/llama-4-scout-q4_k_s.gguf \
        --threads 15 \
	--tensor-split 1/1/1/1 \
        --poll 100 \
        --n-gpu-layers 999 \
        --cache-type-k q4_0 \
        --cache-type-v f16 \
        --flash-attn 1 \
	--ctx-size 16384 \
