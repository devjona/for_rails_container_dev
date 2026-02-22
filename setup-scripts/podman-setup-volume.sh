#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../vars.sh"

echo "Checking for volume: ${POSTGRES_VOLUME}…"

#1. Check if the volume exists; if not, create it
if ! podman volume exists ${POSTGRES_VOLUME}; then
  podman volume create ${POSTGRES_VOLUME}
  echo "volume ${POSTGRES_VOLUME} created."
else
  echo "volume: ${POSTGRES_VOLUME} already exists."
fi
