#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../vars.sh"

echo ""
echo "============================================"
echo "  New Rails App — Full Setup"
echo "============================================"
echo ""

# --- Step 1: App name ----------------------------------------
echo "Step 1 of 5: App Name"
echo ""
echo "Current app name in vars.sh: '${RAILS_APP_NAME}'"
read -p "Enter a new app name (or press Enter to keep '${RAILS_APP_NAME}'): " INPUT_NAME

if [ -n "${INPUT_NAME}" ]; then
  if [[ ! "${INPUT_NAME}" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
    echo ""
    echo "ERROR: App name must start with a letter and contain only letters, numbers, and underscores."
    exit 1
  fi
  sed -i "s/^RAILS_APP_NAME=.*/RAILS_APP_NAME=${INPUT_NAME}/" "${SCRIPT_DIR}/../vars.sh"
  # Re-source so all derived variables (NETWORK, POSTGRES_VOLUME, etc.) update
  source "${SCRIPT_DIR}/../vars.sh"
  echo "Updated RAILS_APP_NAME to '${RAILS_APP_NAME}' in vars.sh."
fi

echo ""
echo "  App name:        ${RAILS_APP_NAME}"
echo "  Network:         ${NETWORK}"
echo "  Postgres volume: ${POSTGRES_VOLUME}"
echo "  Dev container:   ${DEV_CONTAINER_NAME}"
echo ""
read -p "Proceed with these settings? (Y/n): " CONFIRM
if [[ "${CONFIRM}" =~ ^[Nn]$ ]]; then
  echo "Aborted."
  exit 0
fi

echo ""

# --- Step 2: Rails image -------------------------------------
echo "Step 2 of 5: Rails Image"
echo ""
if podman image exists "${RAILS_CONTAINER_TAG}"; then
  echo "Image '${RAILS_CONTAINER_TAG}' already exists. Skipping build."
else
  echo "Image '${RAILS_CONTAINER_TAG}' not found."
  read -p "Build it now? This may take a few minutes. (Y/n): " BUILD_CHOICE
  if [[ "${BUILD_CHOICE}" =~ ^[Nn]$ ]]; then
    echo ""
    echo "Please build the image first by running:"
    echo "  ./podman-setup-debian-rails-image.sh"
    exit 1
  fi
  "${SCRIPT_DIR}/podman-setup-debian-rails-image.sh"
fi

echo ""

# --- Step 3: Network & volume --------------------------------
echo "Step 3 of 5: Network & Volume"
echo ""
"${SCRIPT_DIR}/podman-setup-network.sh"
"${SCRIPT_DIR}/podman-setup-volume.sh"

echo ""

# --- Step 4: Postgres ----------------------------------------
echo "Step 4 of 5: Postgres Database"
echo ""
"${SCRIPT_DIR}/podman-setup-db.sh"

echo ""

# --- Step 5: Rails app ---------------------------------------
echo "Step 5 of 5: Rails App"
echo ""
"${SCRIPT_DIR}/podman-setup-rails.sh"

echo ""
echo "============================================"
echo "  All Done!"
echo "============================================"
echo ""
echo "Your Rails app '${RAILS_APP_NAME}' is fully set up."
echo ""
echo "Start developing:"
echo "  ./podman-rails-server.sh  — Start 'rails server'"
echo "  ./podman-rails-console.sh — Open 'rails console'"
echo "  ./podman-rails-test.sh    — Run your tests"
echo ""
echo "When you're done for the day:"
echo "  ./podman-dev-stop.sh      — Stop all containers"
echo ""
echo "To move your project to a new location (e.g. to initialise a git repo):"
echo "  ./podman-move-project.sh"
echo ""
