#!/bin/bash

# Stop and remove any existing container with the same name
echo "Cleaning up old container (if it exists)..."
docker stop comfyui-dev-01 2>/dev/null || true
docker rm comfyui-dev-01 2>/dev/null || true

echo "Starting new container..."
docker run -d --name comfyui-dev-01 --gpus all -p 8188:8188 \
  -v $HOME/AI/models:/opt/ComfyUI/models \
  -v $HOME/AI/comfyui-output:/opt/ComfyUI/output \
  -v $HOME/AI/custom_nodes:/opt/ComfyUI/custom_nodes \
  -v $HOME/AI/dk/sources:/opt/sources \
  comfyui-dev:01

echo "Container 'comfyui-dev-01' is running."

