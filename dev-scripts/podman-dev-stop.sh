#!/bin/bash
set -e

source ../vars.sh

echo ""
echo "============================================"
echo "  Stopping Dev Environment"
echo "============================================"
echo ""

podman stop "${DEV_CONTAINER_NAME}" 2>/dev/null &&
  echo "'${DEV_CONTAINER_NAME}' stopped." ||
  echo "'${DEV_CONTAINER_NAME}' was not running."

podman stop "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}" 2>/dev/null &&
  echo "'${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}' stopped." ||
  echo "'${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}' was not running."

echo ""
echo "Dev environment stopped."
echo "Run './podman-rails-server.sh' (or any dev script) to start again."
echo ""
