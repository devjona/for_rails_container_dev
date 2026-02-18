#!/bin/bash
set -e

source ../vars.sh

echo ""
echo "============================================"
echo "  Rails Console"
echo "============================================"
echo ""

echo "Starting Postgres..."
ensure_container_running "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}"
check_pgready

echo ""
echo "Opening Rails console (type 'exit' or press Ctrl+D to quit)..."
echo ""

if [ "${BIND_MOUNT}" = "true" ]; then
  podman run --rm -it \
    --net "${NETWORK}" \
    -v "$(cd .. && pwd):/box/${RAILS_APP_NAME}:z" \
    "${RAILS_APP_IMAGE_NAME}" \
    bash -c "cd /box/${RAILS_APP_NAME} && rails console"
else
  echo "Starting dev container..."
  ensure_container_running "${DEV_CONTAINER_NAME}"
  podman exec -it "${DEV_CONTAINER_NAME}" bash -c "cd /box/${RAILS_APP_NAME} && rails console"
fi
