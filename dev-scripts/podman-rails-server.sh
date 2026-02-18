#!/bin/bash
set -e

source ../vars.sh

echo ""
echo "============================================"
echo "  Rails Server"
echo "============================================"
echo ""

echo "Starting Postgres..."
ensure_container_running "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}"
check_pgready

echo ""
echo "Attempting to launch Rails Server…"
echo ""

if [ "${BIND_MOUNT}" = "true" ]; then
  # The dev container was created with -p ${PORT_RAILS}:${PORT_RAILS} and holds
  # the port even at idle. Stop it so the bind-mount run can claim the port.
  if [ "$(podman container inspect "${DEV_CONTAINER_NAME}" --format '{{.State.Status}}' 2>/dev/null)" = "running" ]; then
    echo "Stopping dev container to free port ${PORT_RAILS}..."
    podman stop "${DEV_CONTAINER_NAME}"
  fi
  podman run --rm -it \
    --net "${NETWORK}" \
    -p "${PORT_RAILS}:${PORT_RAILS}" \
    -v "$(cd .. && pwd):/box/${RAILS_APP_NAME}:z" \
    "${RAILS_APP_IMAGE_NAME}" \
    bash -c "cd /box/${RAILS_APP_NAME} && rails server -b 0.0.0.0"
else
  echo "Starting dev container..."
  ensure_container_running "${DEV_CONTAINER_NAME}"
  podman exec -it "${DEV_CONTAINER_NAME}" bash -c "cd /box/${RAILS_APP_NAME} && rails server -b 0.0.0.0"
fi
