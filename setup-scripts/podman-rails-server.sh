#!/bin/bash
set -e

source ./vars.sh

echo ""
echo "============================================"
echo "  Rails Server"
echo "============================================"
echo ""

echo "Starting Postgres..."
ensure_container_running "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}"
check_pgready

echo "Starting dev container..."
ensure_container_running "${DEV_CONTAINER_NAME}"

echo ""
echo "Rails server running at http://localhost:${PORT_RAILS}"
echo "Press Ctrl+C to stop."
echo ""

podman exec -it "${DEV_CONTAINER_NAME}" bash -c "cd /box/${RAILS_APP_NAME} && rails server -b 0.0.0.0"
