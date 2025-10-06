# ComfyUI-SageAttention-Blackwell-Docker

A streamlined Dockerized environment for **ComfyUI** tailored to NVIDIA Blackwell GPUs.  
This project focuses on **reproducibility, maintainability, and automation** for advanced AI workflows.

## Features

- **Automated Node Updates**  
  A single script (`update_nodes.sh`) fetches the latest versions of selected custom nodes from GitHub.

- **Dependency Management Inside Container**  
  All required Python and system packages are installed directly into the container’s virtual environment, ensuring consistency across runs.

- **Container Lifecycle Control**  
  The `run.sh` script handles stopping, removing, and starting the ComfyUI container cleanly.

- **Minimal Repository Footprint**  
  Only essential scripts and configuration are tracked. Large folders (models, sources, outputs) remain local and are mounted into the container at runtime.

- **Optimized for SageAttention**  
  Designed with workflows that leverage SageAttention and CUDA 12.8 / Torch 2.8 for NVIDIA Blackwell GPUs.

## Usage

Clone the repository and run:

```bash
./update_nodes.sh   # update nodes and dependencies
./run.sh            # start container

Ensure Docker with GPU support (NVIDIA Container Toolkit) is installed.
Project Structure

    update_nodes.sh — Updates custom nodes, installs dependencies inside the container, and restarts it.

    run.sh — Manages container lifecycle.

    README.md — Project overview and usage guide.

    .gitignore — Ensures only essential files are tracked.

