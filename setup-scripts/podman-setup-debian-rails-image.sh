#!/bin/bash
set -e

source ./vars.sh

# Build the container image
# docker build --build-arg VAR1="$VAR1" --build-arg VAR2="$VAR2" -t my-container .


# invoke the Containerfile so we can build this image.
podman build -t "$RAILS_CONTAINER_TAG" -f Containerfile

echo "Just built $(podman images --format '{{.Repository}}:{{.Tag}}' | head -n 1)"
