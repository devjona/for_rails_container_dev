#!/bin/bash
set -e

source ../vars.sh

echo ""
echo "============================================"
echo "  Rails Shell"
echo "============================================"
echo ""

echo "Starting Postgres..."
ensure_container_running "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}"
check_pgready

echo ""
echo "Entering '${RAILS_APP_NAME}'. Run any Rails command you need."
echo "Type 'exit' or press Ctrl+D to leave."
echo ""

if [ "${BIND_MOUNT}" = "true" ]; then
  podman run --rm -it \
    --net "${NETWORK}" \
    -w "/box/${RAILS_APP_NAME}" \
    -v "$(cd .. && pwd):/box/${RAILS_APP_NAME}:z" \
    "${RAILS_APP_IMAGE_NAME}" \
    bash
else
  echo "Starting dev container..."
  ensure_container_running "${DEV_CONTAINER_NAME}"
  podman exec -it -w "/box/${RAILS_APP_NAME}" "${DEV_CONTAINER_NAME}" bash
fi
