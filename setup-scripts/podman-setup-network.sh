#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../vars.sh"

echo "Checking for network: ${NETWORK}…"

#1. Check if the network exists; if not, create it
if ! podman network exists ${NETWORK}; then
  podman network create ${NETWORK}
  echo "Network ${NETWORK} created."
else
  echo "Network: ${NETWORK} already exists."
fi
