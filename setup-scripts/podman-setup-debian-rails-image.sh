#!/bin/bash
set -e

source ../vars.sh

# invoke the Containerfile so we can build this image.
podman build -t ${RAILS_CONTAINER_TAG} --build-arg RUBY_VERSION=${RUBY_VERSION} --build-arg DEBIAN_RELEASE=${DEBIAN_RELEASE} -f ../Containerfile

echo "Just built $(podman images --format '{{.Repository}}:{{.Tag}}' | head -n 1)"
