#!/bin/bash
set -e

source ./vars.sh

echo ""
echo "============================================"
echo "  Rails Console"
echo "============================================"
echo ""

echo "Starting Postgres..."
ensure_container_running "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}"
check_pgready

echo "Starting dev container..."
ensure_container_running "${DEV_CONTAINER_NAME}"

echo ""
echo "Opening Rails console (type 'exit' or press Ctrl+D to quit)..."
echo ""

podman exec -it "${DEV_CONTAINER_NAME}" bash -c "cd /box/${RAILS_APP_NAME} && rails console"
