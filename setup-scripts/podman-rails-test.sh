#!/bin/bash
set -e

source ./vars.sh

echo ""
echo "============================================"
echo "  Rails Test Shell"
echo "============================================"
echo ""

echo "Starting Postgres..."
ensure_container_running "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}"
check_pgready

echo "Starting dev container..."
ensure_container_running "${DEV_CONTAINER_NAME}"

echo ""
echo "Entering test shell in '${RAILS_APP_NAME}'."
echo "Run whichever rspec or minitest commands you need."
echo "Type 'exit' or press Ctrl+D to leave."
echo ""

podman exec -it -w "/box/${RAILS_APP_NAME}" "${DEV_CONTAINER_NAME}" bash
