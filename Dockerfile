########################  BASE PYTHON  ########################
# Torch 1.13, PyQt6 6.5, and some wheels in your list still target Python 3.10.
FROM python:3.13-slim@sha256:6544e0e002b40ae0f59bc3618b07c1e48064c4faed3a15ae2fbd2e8f663e8283

########################  SYSTEM PACKAGES  ###################
# - build-essential, cmake → compile any C/C++ wheels that don’t ship pre‑built
# - openmpi + dev headers → mpi4py
# - ffmpeg → librosa, video labs
# - graphviz → graphviz Python bindings
# - default-jdk-headless → PySpark
# - python3-tk, libgl1, libglib2.0-0 → GUI back‑ends for matplotlib / PyQt6
# - git, unzip → handy in‑container utilities
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential cmake \
        libgl1 libglib2.0-0 \
        git unzip \
    && rm -rf /var/lib/apt/lists/*


########################  PYTHON PACKAGES  ###################
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

########################  NON‑ROOT USER  #####################
RUN useradd -m vscode
USER vscode
WORKDIR /workspaces

########################  METADATA  ##########################
# LABEL org.opencontainers.image.source="https://github.com/<ORG>/template_repo" \
#       org.opencontainers.image.description="ACME Applied‑Math lab env 2025‑26" \
#       org.opencontainers.image.licenses="MIT"