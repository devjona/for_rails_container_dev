#!/bin/bash
# This script runs INSIDE the Rails container during initial setup.
# It is copied into the container and invoked by podman-setup-rails.sh.
# Do not run it directly from your host machine.

echo ""
echo "============================================"
echo "  Rails New — Interactive Setup"
echo "============================================"
echo ""
echo "You are inside the Rails container."
echo "Working directory: $(pwd)"
echo ""
echo "Run the following to create your app:"
echo ""
echo "  rails new ${RAILS_APP_NAME} -d postgresql [your optional flags]"
echo ""
echo "Some examples of optional flags:"
echo "  --css tailwind        (Tailwind CSS)"
echo "  --css bootstrap       (Bootstrap)"
echo "  --javascript esbuild  (esbuild bundler)"
echo "  --api                 (API-only mode)"
echo ""
echo "When 'rails new' is complete, type 'exit' to continue automated setup."
echo "============================================"
echo ""

exec /bin/bash
