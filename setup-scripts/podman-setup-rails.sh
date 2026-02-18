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
  "${RAILS_CONTAINER_TAG}" \
  bash /box/rails-new-entrypoint.sh

# Copy the entrypoint script into the container before starting
echo "Copying entrypoint script into container..."
podman cp ./rails-new-entrypoint.sh "${RAILS_APP_NAME}:/box/rails-new-entrypoint.sh"

echo ""
echo "Starting interactive session — follow the instructions inside the container."
echo ""

# Start the container interactively. Blocks until the user types 'exit'.
# The entrypoint script prints instructions then hands off to bash via exec,
# so exiting bash exits the container cleanly with no continuation attempted.
podman start -ai "${RAILS_APP_NAME}"

echo ""
echo "--------------------------------------------"
echo "  Checking for Rails app..."
echo "--------------------------------------------"

TEMP_YAML=$(mktemp)

# Verify the app was created by checking for database.yml
if ! podman cp "${RAILS_APP_NAME}:/box/${RAILS_APP_NAME}/config/database.yml" "${TEMP_YAML}" 2>/dev/null; then
  echo ""
  echo "ERROR: Could not find '${RAILS_APP_NAME}/config/database.yml' in the container."
  echo "Did you run 'rails new ${RAILS_APP_NAME} -d postgresql ...' before typing 'exit'?"
  rm -f "${TEMP_YAML}"
  exit 1
fi

echo "Rails app found."
echo ""
echo "--------------------------------------------"
echo "  Patching config/database.yml"
echo "--------------------------------------------"
echo "Adding connection settings for:"
echo "  username: ${POSTGRES_USER_NAME}"
echo "  host:     ${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}"
echo "  port:     ${PORT_POSTGRES}"
echo ""

# Patch the default section so all environments inherit the connection settings
awk \
  -v user="${POSTGRES_USER_NAME}" \
  -v pass="${POSTGRES_PASSWORD}" \
  -v host="${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}" \
  -v port="${PORT_POSTGRES}" \
  '/pool: <%= ENV.fetch/ {
    print;
    print "  username: " user;
    print "  password: " pass;
    print "  host: " host;
    print "  port: " port;
    next
  }1' "${TEMP_YAML}" > "${TEMP_YAML}.patched" \
  && mv "${TEMP_YAML}.patched" "${TEMP_YAML}"

# Copy the patched file back into the stopped container
podman cp "${TEMP_YAML}" "${RAILS_APP_NAME}:/box/${RAILS_APP_NAME}/config/database.yml"
rm -f "${TEMP_YAML}"
echo "config/database.yml patched successfully."

echo ""
echo "--------------------------------------------"
echo "  Saving app to image '${RAILS_APP_IMAGE_NAME}'..."
echo "--------------------------------------------"
podman commit "${RAILS_APP_NAME}" "${RAILS_APP_IMAGE_NAME}"
echo "Image '${RAILS_APP_IMAGE_NAME}' created."

echo ""
echo "--------------------------------------------"
echo "  Running rails db:create"
echo "--------------------------------------------"
podman run --rm \
  --net "${NETWORK}" \
  "${RAILS_APP_IMAGE_NAME}" \
  bash -c "cd /box/${RAILS_APP_NAME} && rails db:create"

echo ""
echo "--------------------------------------------"
echo "  Creating persistent dev container"
echo "--------------------------------------------"

if podman container exists "${DEV_CONTAINER_NAME}"; then
  echo "Dev container '${DEV_CONTAINER_NAME}' already exists; skipping creation."
else
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
echo "  ./podman-rails-shell.sh   — Open a shell for any Rails command"
echo "  ./podman-move-project.sh  — Copy project to your host machine"
echo ""
