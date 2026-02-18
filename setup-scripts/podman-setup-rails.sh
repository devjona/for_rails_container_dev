#!/bin/bash
set -e

source ./vars.sh

echo ""
echo "============================================"
echo "  Setting Up Rails Container"
echo "============================================"
echo ""

# Guard: don't clobber an existing setup container
if podman container exists "${RAILS_APP_NAME}"; then
  echo "ERROR: Container '${RAILS_APP_NAME}' already exists."
  echo "If you want to start fresh, remove it with:"
  echo "  podman rm ${RAILS_APP_NAME}"
  exit 1
fi

# Create the container (but don't start it yet) so we can copy the
# entrypoint script in before the interactive session begins.
echo "Creating Rails setup container '${RAILS_APP_NAME}'..."
podman create \
  -it \
  --name "${RAILS_APP_NAME}" \
  --net "${NETWORK}" \
  -p "${PORT_RAILS}:${PORT_RAILS}" \
  -e "RAILS_APP_NAME=${RAILS_APP_NAME}" \
  -e "POSTGRES_USER_NAME=${POSTGRES_USER_NAME}" \
  -e "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}" \
  -e "POSTGRES_HOST_FOR_RAILS_CONFIG_DB=${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}" \
  -e "PORT_POSTGRES=${PORT_POSTGRES}" \
  "${RAILS_CONTAINER_TAG}" \
  bash /box/rails-new-entrypoint.sh

# Copy the entrypoint script into the container before starting
echo "Copying entrypoint script into container..."
podman cp ./rails-new-entrypoint.sh "${RAILS_APP_NAME}:/box/rails-new-entrypoint.sh"

echo ""
echo "Starting interactive session — follow the instructions inside the container."
echo ""

# Start the container; this blocks until the entrypoint script finishes
podman start -ai "${RAILS_APP_NAME}"

echo ""
echo "--------------------------------------------"
echo "  Saving app to image '${RAILS_APP_IMAGE_NAME}'..."
echo "--------------------------------------------"
podman commit "${RAILS_APP_NAME}" "${RAILS_APP_IMAGE_NAME}"
echo "Image '${RAILS_APP_IMAGE_NAME}' created."

# Guard: don't create a second dev container if one already exists
if podman container exists "${DEV_CONTAINER_NAME}"; then
  echo "Dev container '${DEV_CONTAINER_NAME}' already exists; skipping creation."
else
  echo ""
  echo "Creating persistent dev container '${DEV_CONTAINER_NAME}'..."
  podman run -d \
    --name "${DEV_CONTAINER_NAME}" \
    --net "${NETWORK}" \
    -p "${PORT_RAILS}:${PORT_RAILS}" \
    "${RAILS_APP_IMAGE_NAME}" \
    sleep infinity
  echo "Dev container '${DEV_CONTAINER_NAME}' is ready."
fi

echo ""
echo "============================================"
echo "  Rails Setup Complete!"
echo "============================================"
echo ""
echo "Your Rails app '${RAILS_APP_NAME}' is ready for development."
echo ""
echo "Next steps:"
echo "  ./podman-rails-server.sh  — Start 'rails server'"
echo "  ./podman-rails-console.sh — Open 'rails console'"
echo "  ./podman-rails-test.sh    — Run your tests"
echo "  ./podman-move-project.sh  — Copy project to your host machine"
echo ""
