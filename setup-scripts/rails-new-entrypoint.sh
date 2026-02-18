#!/bin/bash
# This script runs INSIDE the Rails container during initial setup.
# It is copied into the container and invoked by podman-setup-rails.sh.
# Do not run it directly from your host machine.

set -e

APP_DIR="/box/${RAILS_APP_NAME}"
DB_YAML="${APP_DIR}/config/database.yml"

echo ""
echo "============================================"
echo "  Rails New — Interactive Setup"
echo "============================================"
echo ""
echo "You are inside the Rails container."
echo "Working directory: $(pwd)"
echo ""
echo "Please run the following command to create your Rails app:"
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

cd /box

/bin/bash

echo ""
echo "Checking for Rails app at '${APP_DIR}'..."

if [ ! -d "${APP_DIR}" ]; then
  echo ""
  echo "ERROR: Rails app not found at '${APP_DIR}'."
  echo "Did you run 'rails new ${RAILS_APP_NAME} -d postgresql ...'?"
  echo ""
  exit 1
fi

echo "Rails app found!"
echo ""
echo "--------------------------------------------"
echo "  Patching config/database.yml"
echo "--------------------------------------------"
echo "Adding connection settings for:"
echo "  username: ${POSTGRES_USER_NAME}"
echo "  host:     ${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}"
echo "  port:     ${PORT_POSTGRES}"
echo ""

# Insert username, password, host, and port into the 'default' section,
# directly after the 'pool:' line so all environments inherit them.
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
  }1' "${DB_YAML}" > "${DB_YAML}.tmp" && mv "${DB_YAML}.tmp" "${DB_YAML}"

echo "config/database.yml patched successfully."
echo ""
echo "--------------------------------------------"
echo "  Running rails db:create"
echo "--------------------------------------------"
echo ""

cd "${APP_DIR}"
rails db:create

echo ""
echo "============================================"
echo "  Database setup complete!"
echo "============================================"
echo ""
echo "Your Rails app '${RAILS_APP_NAME}' is ready."
echo "Type 'exit' in the outer shell to finish setup."
echo ""
