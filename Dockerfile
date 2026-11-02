# SPDX-License-Identifier: Apache-2.0
#
# Dockerfile for YOBIIQ KiBi SDK Build Environment
# Installs the nRF Connect SDK toolchain of the NCS_VERSION build argument using nrfutil
# toolchain-manager. The workflows and scripts/build-local.sh pass it from VERSION.txt.
#

FROM ubuntu:22.04

LABEL org.opencontainers.image.title="YOBIIQ KiBi SDK Builder"
LABEL org.opencontainers.image.vendor="YOBIIQ"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.source="https://github.com/yobiiq/yobiiq-sdk-builder"

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Create ccache directory
RUN mkdir -p /var/cache/ccache && chmod 777 /var/cache/ccache
ENV CCACHE_DIR=/var/cache/ccache

# Install base dependencies (minimal set - nrfutil handles most toolchain needs)
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    python3-pip \
    python3-venv \
    unzip \
    jq \
    apt-utils \
    build-essential \
    gcc \
    gcc-multilib \
    g++-multilib \
    openssh-client \
    patch \
    ccache \
    dfu-util \
    device-tree-compiler \
    libsdl2-dev \
    lcov

# Install nRF Command Line Tools (optional - includes nrfjprog, mergehex, etc.)
# Note: This is not required for SDK builds, only for direct device programming
ARG NRF_COMMAND_LINE_TOOLS_VERSION=10.24.2
RUN wget -q https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-10-x-x/10-24-2/nrf-command-line-tools_10.24.2_amd64.deb \
    && apt-get install -y ./nrf-command-line-tools_10.24.2_amd64.deb \
    && rm nrf-command-line-tools_10.24.2_amd64.deb \
    && rm -rf /var/lib/apt/lists/*

# Install nrfutil
RUN wget -q "https://files.nordicsemi.com/ui/api/v1/download?repoKey=swtools&path=external/nrfutil/executables/x86_64-unknown-linux-gnu/nrfutil" -O /usr/local/bin/nrfutil \
    && chmod +x /usr/local/bin/nrfutil

# Install toolchain-manager and the nRF Connect SDK toolchain
ARG NCS_VERSION
ARG INSTALL_DIR=/opt/ncs
RUN test -n "${NCS_VERSION}" \
    && nrfutil install toolchain-manager \
    && nrfutil toolchain-manager install --ncs-version ${NCS_VERSION} --install-dir ${INSTALL_DIR}

LABEL org.opencontainers.image.description="Build environment for YOBIIQ KiBi SDK with nRF Connect SDK ${NCS_VERSION}"
LABEL org.opencontainers.image.version="${NCS_VERSION}"

# Get the toolchain environment dynamically
# This creates a script that sets all necessary environment variables
RUN nrfutil toolchain-manager env --as-script --install-dir ${INSTALL_DIR} > /opt/ncs_env.sh \
    && chmod +x /opt/ncs_env.sh

# Source the environment in every shell session
RUN echo 'source /opt/ncs_env.sh' >> /etc/bash.bashrc

# Set a few key variables that we know will be needed
# These are set dynamically via the sourced script, but we set some basics here for Docker
ENV NCS_INSTALL_DIR=${INSTALL_DIR}

# Clean up
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set working directory for builds
WORKDIR /workspace

# Default command - source environment and start bash
CMD ["/bin/bash", "-c", "source /opt/ncs_env.sh && exec /bin/bash"]
