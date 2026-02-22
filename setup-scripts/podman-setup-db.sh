#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../vars.sh"

echo "Checking for Postgres container: '${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}'..."

if podman container exists "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}"; then
  STATUS=$(podman container inspect "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}" --format '{{.State.Status}}')
  if [ "${STATUS}" != "running" ]; then
    echo "Container exists but is not running. Starting it..."
    podman start "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}"
  else
    echo "Postgres container is already running."
  fi
else
  echo "Creating Postgres container '${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}'..."
  podman run -d \
    -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
    -e POSTGRES_USER="${POSTGRES_USER_NAME}" \
    --name "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}" \
    --user "${POSTGRES_CONTAINER_USERNAME}" \
    --net "${NETWORK}" \
    -v "${POSTGRES_VOLUME}:/var/lib/postgresql/data" \
    postgres:17
  echo "Postgres container created."
fi

check_pgready
