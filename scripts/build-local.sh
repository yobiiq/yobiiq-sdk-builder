#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
#
# Build YOBIIQ SDK Builder Docker image locally
#

set -e

# Default values
VERSION="${1:-$(grep NRF_CONNECT_SDK_VERSION "$(dirname "$0")/../VERSION.txt" | cut -d'=' -f2)}"
IMAGE_NAME="yobiiq-sdk-builder"
REGISTRY="${REGISTRY:-ghcr.io/yobiiq}"

echo "========================================="
echo "Building YOBIIQ SDK Builder Image"
echo "========================================="
echo "Version: ${VERSION}"
echo "Image: ${REGISTRY}/${IMAGE_NAME}:${VERSION}"
echo ""

# Extract major.minor version
MAJOR_MINOR=$(echo ${VERSION} | sed -E 's/(v[0-9]+\.[0-9]+).*/\1/')

echo "[1/3] Building Docker image..."
docker build \
  --build-arg "NCS_VERSION=${VERSION}" \
  --tag "${REGISTRY}/${IMAGE_NAME}:${VERSION}" \
  --tag "${REGISTRY}/${IMAGE_NAME}:${MAJOR_MINOR}" \
  --tag "${REGISTRY}/${IMAGE_NAME}:latest" \
  --progress=plain \
  .

echo ""
echo "[2/3] Verifying image..."
docker run --rm "${REGISTRY}/${IMAGE_NAME}:${VERSION}" /bin/bash -c "
  set -e
  echo 'West version:'
  west --version
  echo ''
  echo 'CMake version:'
  cmake --version | head -n1
  echo ''
  echo 'Environment check:'
  echo \"ZEPHYR_BASE: \${ZEPHYR_BASE}\"
  echo \"NCS installed: \$(ls -d /workdir/nrf 2>/dev/null && echo 'Yes' || echo 'No')\"
"

echo ""
echo "[3/3] Build complete!"
echo ""
echo "========================================="
echo "Available tags:"
echo "  ${REGISTRY}/${IMAGE_NAME}:${VERSION}"
echo "  ${REGISTRY}/${IMAGE_NAME}:${MAJOR_MINOR}"
echo "  ${REGISTRY}/${IMAGE_NAME}:latest"
echo "========================================="
echo ""
echo "To run the image:"
echo "  docker run -it ${REGISTRY}/${IMAGE_NAME}:${VERSION}"
echo ""
echo "To push to registry:"
echo "  docker push ${REGISTRY}/${IMAGE_NAME}:${VERSION}"
echo "  docker push ${REGISTRY}/${IMAGE_NAME}:${MAJOR_MINOR}"
echo "  docker push ${REGISTRY}/${IMAGE_NAME}:latest"
