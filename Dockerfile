########################  BASE PYTHON  ########################
FROM python:3.13-slim@sha256:6544e0e002b40ae0f59bc3618b07c1e48064c4faed3a15ae2fbd2e8f663e8283

########################  SYSTEM PACKAGES  ###################
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential cmake \
        libblas-dev liblapack-dev \
        libgl1 libglib2.0-0 \
        git unzip \
    && rm -rf /var/lib/apt/lists/*


########################  PYTHON PACKAGES  ###################
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt
RUN pip install --no-cache-dir \
    cvxopt~=1.3.2 \
    ipykernel~=6.29.0 \

########################  NON‑ROOT USER  #####################
RUN useradd -m vscode
USER vscode
WORKDIR /workspaces