#!/bin/bash
set -e

source ../vars.sh

echo ""
echo "============================================"
echo "  Clone Setup"
echo "============================================"
echo ""

# --- Step 1: Rails app image ---------------------------------
echo "Step 1 of 4: Building Rails app image '${RAILS_APP_IMAGE_NAME}'..."
echo ""

if podman image exists "${RAILS_APP_IMAGE_NAME}"; then
  echo "Image '${RAILS_APP_IMAGE_NAME}' already exists. Skipping build."
else
  podman build \
    -t "${RAILS_APP_IMAGE_NAME}" \
    --build-arg RUBY_VERSION="${RUBY_VERSION}" \
    --build-arg DEBIAN_RELEASE="${DEBIAN_RELEASE}" \
    -f ../Containerfile.dev \
    ..
  echo "Image '${RAILS_APP_IMAGE_NAME}' built."
fi

echo ""

# --- Step 2: Network -----------------------------------------
echo "Step 2 of 4: Network"
echo ""
./podman-setup-network.sh

echo ""

# --- Step 3: Volume ------------------------------------------
echo "Step 3 of 4: Volume"
echo ""
./podman-setup-volume.sh

echo ""

# --- Step 4: Postgres ----------------------------------------
echo "Step 4 of 4: Postgres"
echo ""
./podman-setup-db.sh

echo ""
echo "============================================"
echo "  Clone Setup Complete!"
echo "============================================"
echo ""
echo "Your environment is ready. Start developing:"
echo ""
echo "  cd ../dev-scripts"
echo "  ./podman-rails-server.sh  -- Start 'rails server'"
echo "  ./podman-rails-console.sh -- Open 'rails console'"
echo "  ./podman-rails-shell.sh   -- Open a shell for any Rails command"
echo "  ./podman-rails-test.sh    -- Run your tests"
echo ""
echo "When you're done for the day:"
echo "  ./podman-dev-stop.sh      -- Stop all containers"
echo ""
