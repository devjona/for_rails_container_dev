#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../vars.sh"

# invoke the Containerfile so we can build this image.
podman build \
  -t "${RAILS_CONTAINER_TAG}" \
  --build-arg RUBY_VERSION="${RUBY_VERSION}" \
  --build-arg DEBIAN_RELEASE="${DEBIAN_RELEASE}" \
  -f "${RAILS_PBR_DIR}/Containerfile" \
  "${RAILS_PBR_DIR}"

echo "Just built $(podman images --format '{{.Repository}}:{{.Tag}}' | head -n 1)"
