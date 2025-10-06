#!/usr/bin/env bash
# ==========================================================
# ComfyUI Custom Nodes Updater & Dependency Manager
# Pop!_OS 24.04 | NVIDIA RTX 5070 Ti | CUDA 12.8 | Torch 2.8
# ==========================================================
set -euo pipefail
IFS=$'\n\t'

# ---------- CONFIGURATION ----------
TARGET_DIR="${HOME}/AI/custom_nodes"
LOG_FILE="${HOME}/AI/dk/update_nodes_log.txt"
PIP_CACHE_DIR="/opt/sources/pip-packages"
VENV_PATH="/opt/venv"
COMFYUI_DIR="/opt/ComfyUI"
RUN_SCRIPT="${HOME}/AI/dk/run.sh"

# ---------- GITHUB CREDENTIALS ----------
: "${GITHUB_USER:?GITHUB_USER not set}"
: "${GITHUB_PASS_OR_TOKEN:?GITHUB_PASS_OR_TOKEN not set}"

# ---------- REPOSITORIES ----------
declare -a REPOS=(
  "ComfyUI-Easy-Use:yolain/ComfyUI-Easy-Use"
  "ComfyUI-KJNodes:kijai/ComfyUI-KJNodes"
  "ComfyUI-WanVideoWrapper:kijai/ComfyUI-WanVideoWrapper"
  "ComfyUI-Impact-Pack:ltdrdata/ComfyUI-Impact-Pack"
  "ComfyUI-VideoHelperSuite:Kosinkadink/ComfyUI-VideoHelperSuite"
  "ComfyUI-GGUF:city96/ComfyUI-GGUF"
  "ComfyUI-WanMoeKSampler:stduhpf/ComfyUI-WanMoeKSampler"
  "ComfyUI-MagCache:Zehong-Ma/ComfyUI-MagCache"
  "ComfyUI-MediaMixer:DoctorDiffusion/ComfyUI-MediaMixer"
  "ComfyUI-mxToolkit:Smirnov75/comfyui-mxtoolkit"
  "ComfyUI-vrgamedevgirl:vrgamegirl19/comfyui-vrgamedevgirl"
  "rgthree-comfy:rgthree/rgthree-comfy"
  "ComfyUI-wanBlockswap:orssorbit/ComfyUI-wanBlockswap"
  "ComfyUI-Frame-Interpolation:Fannovel16/ComfyUI-Frame-Interpolation"
  "ComfyUI-pause:wywywywy/ComfyUI-pause"
)

# ---------- EXTRA DEPENDENCIES ----------
declare -a EXTRA_DEPS=(
  "git+https://github.com/facebookresearch/segment-anything.git"
  "yt_dlp"
  "librosa"
  "opencv-python"
  "imageio[ffmpeg]"
  "scikit-image"
  "moviepy"
)

# ---------- LOGGING ----------
mkdir -p "$(dirname "$LOG_FILE")"
echo -e "\n==================================================" | tee "$LOG_FILE"
echo "Starting custom node update process at $(date)" | tee -a "$LOG_FILE"
echo "==================================================" | tee -a "$LOG_FILE"
echo "Target directory: $TARGET_DIR" | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo "==================================================" | tee -a "$LOG_FILE"

# ---------- CLONE OR UPDATE NODES ----------
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

for entry in "${REPOS[@]}"; do
  IFS=":" read -r FOLDER REPO <<< "$entry"
  echo "--------------------------------------------------" | tee -a "$LOG_FILE"
  echo "Processing: $FOLDER" | tee -a "$LOG_FILE"
  rm -rf "$FOLDER"

  CLONE_URL="https://${GITHUB_USER}:${GITHUB_PASS_OR_TOKEN}@github.com/${REPO}"
  if git clone --depth=1 "$CLONE_URL" "$FOLDER" >> "$LOG_FILE" 2>&1; then
    echo "✅ Successfully updated $FOLDER." | tee -a "$LOG_FILE"
  else
    echo "❌ Failed to update $FOLDER!" | tee -a "$LOG_FILE"
    echo "🔗 Attempted URL: https://github.com/${REPO}" >> "$LOG_FILE"
  fi
done

echo "==================================================" | tee -a "$LOG_FILE"
echo "All custom nodes have been updated!" | tee -a "$LOG_FILE"

# ---------- INSTALL DEPENDENCIES ----------
if [ -f "${VENV_PATH}/bin/activate" ]; then
  source "${VENV_PATH}/bin/activate"
fi

echo "Installing system-level dependencies..." | tee -a "$LOG_FILE"
sudo apt-get update && sudo apt-get install -y ffmpeg libgl1 >> "$LOG_FILE" 2>&1

echo "Installing extra Python dependencies..." | tee -a "$LOG_FILE"
for dep in "${EXTRA_DEPS[@]}"; do
  pip install --no-cache-dir "$dep" >> "$LOG_FILE" 2>&1 || echo "Failed to install $dep" | tee -a "$LOG_FILE"
done

echo "Installing repo-specific requirements..." | tee -a "$LOG_FILE"
find "$TARGET_DIR" -name "requirements.txt" -print0 | while IFS= read -r -d '' req; do
  echo "--- Installing dependencies from: $req" | tee -a "$LOG_FILE"
  pip install -r "$req" >> "$LOG_FILE" 2>&1 || echo "Failed: $req" | tee -a "$LOG_FILE"
done

# ---------- RESTART CONTAINER ----------
echo "--------------------------------------------------" | tee -a "$LOG_FILE"
echo "Restarting container using run.sh..." | tee -a "$LOG_FILE"

if [ -x "$RUN_SCRIPT" ]; then
  "$RUN_SCRIPT" | tee -a "$LOG_FILE"
else
  echo "⚠️ run.sh not found or not executable at $RUN_SCRIPT" | tee -a "$LOG_FILE"
fi

echo "==================================================" | tee -a "$LOG_FILE"
echo "Update completed successfully at $(date)" | tee -a "$LOG_FILE"
echo "==================================================" | tee -a "$LOG_FILE"

