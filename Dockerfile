########################  BASE PYTHON  ########################
# Leave this unpinned for now, JAX will only work with the OS that pinned it
FROM python:3.13-slim


########################  SYSTEM PACKAGES  ###################
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential cmake \
        libblas-dev liblapack-dev \
        libgl1 libglib2.0-0 \
        git unzip sudo \
    && rm -rf /var/lib/apt/lists/*


########################  PYTHON PACKAGES  ###################
# Lab Dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Universal Dependencies
RUN pip install --no-cache-dir \
    cvxopt~=1.3.2 \
    ipykernel~=6.29.0 \
    flake8~=7.3.0


# For now use this line, Volume 1a, Volume 4b
RUN pip install --no-cache-dir \
    jax==0.6.2 \
    jaxlib==0.6.2
# Don't uncomment this line until the JAX CPU only wheel is built, this will make it work for Macs
# RUN pip install --upgrade \
#     jax==0.4.38 \
#     "jaxlib==0.4.38+cpu" \
#     --find-links https://storage.googleapis.com/jax-releases/jax_releases.html

# Uncomment this line for Volume 1, 2, and 4 grading repos
RUN pip install --no-cache-dir "pandas>=2.3.1,<3"


########################  CONFIGURE GIT ########################
# Removes dubious ownership erro and terminal prompts not working warning
RUN git config --system core.askPass true \
 && git config --system credential.helper cache \
 && git config --system --add safe.directory /workspaces



########################  REMOVE VSCODE SIGNING TOOL ########################
# Some installations activate signing tool that uses a massive portion of the cpu for no reason
# I have found that these commands seem to do the trick
RUN rm -f /usr/bin/vsce-sign
RUN printf '#!/bin/sh\n# Disable rogue CPU-hungry VSCE signing processes\nfind /vscode/vscode-server -name vsce-sign -exec chmod -x {} + || true\n' > /usr/local/bin/disable-vsce-sign \
  && chmod +x /usr/local/bin/disable-vsce-sign
RUN mkdir -p /etc/sudoers.d && \
    echo "vscode ALL=(ALL) NOPASSWD: /usr/local/bin/disable-vsce-sign" | tee /etc/sudoers.d/disable-vsce-sign > /dev/null && \
    chmod 0440 /etc/sudoers.d/disable-vsce-sign


########################  NON‑ROOT USER  #####################
# This is the user that will be used to run the container
# Do not change this, vscode dev containers expects it and it's more secure
RUN useradd -m vscode
USER vscode
WORKDIR /workspaces