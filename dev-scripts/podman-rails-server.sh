#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../vars.sh"

echo ""
echo "============================================"
echo "  Rails Server"
echo "============================================"
echo ""

echo "Starting Postgres..."
ensure_container_running "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}"
check_pgready

echo ""
echo "Attempting to launch Rails Server..."
echo ""

# In bind-mount mode, the dev container holds the port even at idle.
# Stop it so the bind-mount run can claim the port.
if [ "${BIND_MOUNT}" = "true" ]; then
  if [ "$(podman container inspect "${DEV_CONTAINER_NAME}" --format '{{.State.Status}}' 2>/dev/null)" = "running" ]; then
    echo "Stopping dev container to free port ${PORT_RAILS}..."
    podman stop "${DEV_CONTAINER_NAME}"
  fi
fi

run_in_container "rails server -b 0.0.0.0" "-p ${PORT_RAILS}:${PORT_RAILS}"
