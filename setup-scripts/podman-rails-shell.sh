#!/bin/bash
set -e

source ./vars.sh

echo ""
echo "============================================"
echo "  Rails Shell"
echo "============================================"
echo ""

echo "Starting Postgres..."
ensure_container_running "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}"
check_pgready

echo "Starting dev container..."
ensure_container_running "${DEV_CONTAINER_NAME}"

echo ""
echo "Entering '${RAILS_APP_NAME}'. Run any Rails command you need."
echo "Type 'exit' or press Ctrl+D to leave."
echo ""

podman exec -it -w "/box/${RAILS_APP_NAME}" "${DEV_CONTAINER_NAME}" bash
