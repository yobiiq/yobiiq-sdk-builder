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

echo "[1/2] Building Docker image..."
docker build \
  --build-arg "NCS_VERSION=${VERSION}" \
  --tag "${REGISTRY}/${IMAGE_NAME}:${VERSION}" \
  --progress=plain \
  .

echo ""
echo "[2/2] Verifying image..."
"$(dirname "$0")/verify-image.sh" "${REGISTRY}/${IMAGE_NAME}:${VERSION}" "${VERSION}"

echo ""
echo "To run the image:"
echo "  docker run -it ${REGISTRY}/${IMAGE_NAME}:${VERSION}"
