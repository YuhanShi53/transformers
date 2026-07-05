MODEL_NAME="Qwen3.5-397B-A17B"
MODEL_REPO="Qwen/Qwen3.5-397B-A17B"

mkdir -p ./$MODEL_NAME

hf download $MODEL_REPO \
    --local-dir ./$MODEL_NAME \
    --exclude "*.safetensors" \
    --exclude "*.bin" \
    --exclude "*.pth"