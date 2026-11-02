#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
#
# Verify a YOBIIQ SDK Builder Docker image: the required tools run and the installed toolchain is
# the one of the expected NCS version. Used by the workflows before an image is published.
#
# Usage: verify-image.sh <image> [ncs-version]
# The NCS version defaults to the one in VERSION.txt.
#

set -e

IMAGE_NAME="${1:?Usage: verify-image.sh <image> [ncs-version]}"
NCS_VERSION="${2:-$(grep NRF_CONNECT_SDK_VERSION "$(dirname "$0")/../VERSION.txt" | cut -d'=' -f2)}"

echo "========================================="
echo "YOBIIQ SDK Builder Image Verification"
echo "========================================="
echo "Image: ${IMAGE_NAME}"
echo "Expected NCS version: ${NCS_VERSION}"
echo ""

docker run --rm -e "EXPECTED_NCS_VERSION=${NCS_VERSION}" "${IMAGE_NAME}" /bin/bash -c '
  source /opt/ncs_env.sh
  set -e

  echo "=== Checking the tools ==="
  nrfutil --version
  west --version
  cmake --version | head -n1
  echo "ninja $(ninja --version)"
  python3 --version
  arm-zephyr-eabi-gcc --version | head -n1

  echo "=== Checking the environment ==="
  echo "NCS_INSTALL_DIR: ${NCS_INSTALL_DIR:?not set}"
  echo "ZEPHYR_SDK_INSTALL_DIR: ${ZEPHYR_SDK_INSTALL_DIR:?not set}"

  echo "=== Checking the toolchain version ==="
  installed="$(jq -r ".[].toolchains[].ncs_versions[]" "${NCS_INSTALL_DIR}/toolchains/toolchains.json")"
  echo "Installed: ${installed}"
  if ! grep -qxF "${EXPECTED_NCS_VERSION}" <<< "${installed}"; then
    echo "ERROR: the image does not hold the toolchain of ${EXPECTED_NCS_VERSION}"
    exit 1
  fi
'

echo ""
echo "All verification checks passed"
