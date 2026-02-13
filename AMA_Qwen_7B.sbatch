#!/bin/bash
#SBATCH --job-name=ama_qwen          # Job name
#SBATCH --output=ama%j.out                # Standard output file
#SBATCH --error=ama%j.err                 # Error file
#SBATCH --partition=ice-gpu              # Partition name
#SBATCH -N1 --gres=gpu:2                 # Request 1 GPU (not used, but kept as requested)
#SBATCH --cpus-per-task=4                # Request 4 CPU cores
#SBATCH --mem=16G                        # Request 16GB RAM
#SBATCH --time=02:00:00                  # Max job runtime
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=ychauhan9@gatech.edu

set -euo pipefail

module load python/3.11
module load anaconda3
module load uv || true

# ===== SCRATCH REDIRECT (DO NOT REMOVE) =====
export SCRATCH_ROOT="/home/hice1/ychauhan9/scratch/AMA"

export HF_HOME="$SCRATCH_ROOT/hf"
export TRANSFORMERS_CACHE="$HF_HOME/transformers"
export HUGGINGFACE_HUB_CACHE="$HF_HOME/hub"
export HF_DATASETS_CACHE="$HF_HOME/datasets"

export XINFERENCE_HOME="$SCRATCH_ROOT/xinference"
export VLLM_CACHE_ROOT="$SCRATCH_ROOT/vllm"

export TORCH_HOME="$SCRATCH_ROOT/torch"
export TORCH_EXTENSIONS_DIR="$SCRATCH_ROOT/torch_extensions"

export XDG_CACHE_HOME="$SCRATCH_ROOT/.cache"
export PYTHONPYCACHEPREFIX="$SCRATCH_ROOT/pycache"
export PIP_CACHE_DIR="$SCRATCH_ROOT/pip"

export HF_HUB_DISABLE_TELEMETRY=1

mkdir -p \
  "$SCRATCH_ROOT"/{hf,xinference,vllm,torch,torch_extensions,.cache,pip,runs}

# ===== Activate environment =====
cd "$SCRATCH_ROOT"
source .venv/bin/activate

# ===== AMA → Xinference config =====
export XINFERENCE_API_BASE="http://127.0.0.1:9997/v1"
export XINFERENCE_API_KEY="sk-local-anything"

# ===== Start Xinference =====
xinference-local \
  --host 127.0.0.1 \
  --port 9997 \
  --log-level info \
  > "$SCRATCH_ROOT/runs/xinference_${SLURM_JOB_ID}.log" 2>&1 &

XINF_PID=$!

cleanup() {
  kill $XINF_PID 2>/dev/null || true
}
trap cleanup EXIT

# Wait for server
for i in {1..60}; do
  curl -sf http://127.0.0.1:9997/docs && break
  sleep 20
done

# ===== Launch Qwen2.5-7B =====
xinference launch \
  --endpoint http://127.0.0.1:9997 \
  --model-engine vllm \
  --model-name qwen3 \
  --model-uid qwen3 \
  --model-path /home/hice1/ychauhan9/scratch/AMA/hf/hub/models--Qwen--Qwen3-14B/snapshots/40c069824f4251a91eefaf281ebe4c544efd3e18 \
  --model-format pytorch \
  --trust-remote-code true \
  
curl -s http://127.0.0.1:9997/v1/models | python -m json.tool

# ===== AMA pipeline =====
cd "$SCRATCH_ROOT/repo"
#python3 -m construct_privacy_info.construct_memory
#echo "Memory Constructed"
#python3 -m construct_privacy_info.generate_privacy_parameter \
#  --llm_name qwen3

#python3 generate_tool_metadata.py \
#  --llm_name qwen3 \
#  --attack_type target \
#  -t 0.95 \
#  --lambda_weight 0.5
#echo "Generating tools"

echo "Starting Attack"
python3 scripts/run.py --cfg_path config/qwen3.yml
echo "Finished Attack"

echo "AMA run complete. Outputs in $SCRATCH_ROOT/runs"