#!/bin/bash
# https://solargraph.org/guides/language-server - runs on 7658 by default.
# --- These are for local development ONLY!

# --- OS
DEBIAN_RELEASE=bookworm

# ---

# Ruby and Rails
# Update RAILS_APP_NAME to your liking!
RAILS_APP_NAME=rails_setup

# ---

# You should leave the rest alone unless you have good reason to modify it
RAILS_VERSION="8.0.2"
RUBY_VERSION="3.4.5"
RAILS_CONTAINER_TAG=debian_ruby-${RUBY_VERSION}_rails-${RAILS_VERSION}

# ---

# Network and Ports
NETWORK=${RAILS_APP_NAME}_netw
PORT_POSTGRES=5432
PORT_RAILS=3000

# ---

# Postgres
# This is the name of the linux user for the container, NOT the postgres db user.
# I think it's a default for postgres images.
POSTGRES_CONTAINER_USERNAME=postgres

POSTGRES_HOST_FOR_RAILS_CONFIG_DB=${RAILS_APP_NAME}_devtest_db
POSTGRES_PASSWORD=password

# Is set to the name of your app by default. If you change it, make sure you update your config/database.yaml
POSTGRES_USER_NAME=${RAILS_APP_NAME}

POSTGRES_VOLUME=${RAILS_APP_NAME}_volume
# ---

# --- Derived names (automatically updated when RAILS_APP_NAME changes)
RAILS_APP_IMAGE_NAME=${RAILS_APP_NAME}_image
DEV_CONTAINER_NAME=${RAILS_APP_NAME}_dev
# ---

# --- Functions
function check_pgready() {
  until podman exec -it ${POSTGRES_HOST_FOR_RAILS_CONFIG_DB} pg_isready -U postgres; do
    echo "Waiting for PostgreSQL to be ready..."
    sleep 3
  done

  echo "PostgreSQL is ready."
}

# Ensures a named container is running. Exits with an error if it does not exist.
function ensure_container_running() {
  local container=$1
  local status
  status=$(podman container inspect "${container}" --format '{{.State.Status}}' 2>/dev/null || echo "missing")

  if [ "${status}" = "missing" ]; then
    echo "ERROR: Container '${container}' does not exist."
    echo "Please complete the initial setup first by running: ./podman-new-rails-app.sh"
    exit 1
  elif [ "${status}" != "running" ]; then
    echo "Starting '${container}'..."
    podman start "${container}"
    sleep 1
  else
    echo "'${container}' is already running."
  fi
}
# ---
