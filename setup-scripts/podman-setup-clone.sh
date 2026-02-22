#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../vars.sh"

echo ""
echo "============================================"
echo "  Clone Setup"
echo "============================================"
echo ""

# --- Step 1: Rails app image ---------------------------------
echo "Step 1 of 5: Building Rails app image '${RAILS_APP_IMAGE_NAME}'..."
echo ""

if podman image exists "${RAILS_APP_IMAGE_NAME}"; then
  echo "Image '${RAILS_APP_IMAGE_NAME}' already exists. Skipping build."
else
  podman build \
    -t "${RAILS_APP_IMAGE_NAME}" \
    --build-arg RUBY_VERSION="${RUBY_VERSION}" \
    --build-arg DEBIAN_RELEASE="${DEBIAN_RELEASE}" \
    -f "${RAILS_PBR_DIR}/Containerfile.dev" \
    "${PROJECT_ROOT}"
  echo "Image '${RAILS_APP_IMAGE_NAME}' built."
fi

echo ""

# --- Step 2: Network -----------------------------------------
echo "Step 2 of 5: Network"
echo ""
"${SCRIPT_DIR}/podman-setup-network.sh"

echo ""

# --- Step 3: Volume ------------------------------------------
echo "Step 3 of 5: Volume"
echo ""
"${SCRIPT_DIR}/podman-setup-volume.sh"

echo ""

# --- Step 4: Postgres ----------------------------------------
echo "Step 4 of 5: Postgres"
echo ""
"${SCRIPT_DIR}/podman-setup-db.sh"

echo ""

# --- Step 5: Database ----------------------------------------
echo "Step 5 of 5: Preparing database..."
echo ""
podman run --rm \
  --net "${NETWORK}" \
  -v "${PROJECT_ROOT}:/box/${RAILS_APP_NAME}:z" \
  "${RAILS_APP_IMAGE_NAME}" \
  bash -c "cd /box/${RAILS_APP_NAME} && rails db:prepare"

echo ""
echo "============================================"
echo "  Clone Setup Complete!"
echo "============================================"
echo ""
echo "Your environment is ready. Start developing:"
echo ""
echo "  From the project root:"
echo "  ./rails_pbr/dev-scripts/podman-rails-server.sh  -- Start 'rails server'"
echo "  ./rails_pbr/dev-scripts/podman-rails-console.sh -- Open 'rails console'"
echo "  ./rails_pbr/dev-scripts/podman-rails-shell.sh   -- Open a shell for any Rails command"
echo "  ./rails_pbr/dev-scripts/podman-rails-test.sh    -- Run your tests"
echo ""
echo "When you're done for the day:"
echo "  ./rails_pbr/dev-scripts/podman-dev-stop.sh      -- Stop all containers"
echo ""
