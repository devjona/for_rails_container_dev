#!/bin/bash
# https://solargraph.org/guides/language-server - runs on 7658 by default.
# --- These are for local development ONLY!

# Resolve the rails_pbr directory (where vars.sh lives) and the Rails app project
# root (its parent), regardless of where the calling script is run from.
RAILS_PBR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${RAILS_PBR_DIR}/.." && pwd)"

# --- OS
DEBIAN_RELEASE=bookworm

# ---

# Ruby and Rails
# Update RAILS_APP_NAME to your liking!
RAILS_APP_NAME=

# ---

# You should leave the rest alone unless you have good reason to modify it
RAILS_VERSION="8.1.2"
RUBY_VERSION="4.0.1"
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

# Set to true by podman-move-project.sh when the project is copied to the host.
# When true, dev-scripts will bind-mount the project root into the container so
# that code changes on the host are instantly reflected inside the container.
BIND_MOUNT=false
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

# Runs a command inside the Rails app container, handling both exec and bind-mount modes.
# Usage: run_in_container [command] [extra_flags]
#   command     -- shell command to run (e.g. "rails server -b 0.0.0.0"); omit to drop into bash
#   extra_flags -- additional podman flags (e.g. "-p 3000:3000" or "-w /box/app")
#                  applied to 'podman run' always; applied to 'podman exec' only when no command is given
function run_in_container() {
  local command="${1:-}"
  local extra_flags="${2:-}"

  if [ "${BIND_MOUNT}" = "true" ]; then
    if [ -n "${command}" ]; then
      podman run --rm -it \
        --net "${NETWORK}" \
        ${extra_flags} \
        -v "${PROJECT_ROOT}:/box/${RAILS_APP_NAME}:z" \
        "${RAILS_APP_IMAGE_NAME}" \
        bash -c "cd /box/${RAILS_APP_NAME} && ${command}"
    else
      podman run --rm -it \
        --net "${NETWORK}" \
        ${extra_flags} \
        -v "${PROJECT_ROOT}:/box/${RAILS_APP_NAME}:z" \
        "${RAILS_APP_IMAGE_NAME}" \
        bash
    fi
  else
    ensure_container_running "${DEV_CONTAINER_NAME}"
    if [ -n "${command}" ]; then
      podman exec -it "${DEV_CONTAINER_NAME}" bash -c "cd /box/${RAILS_APP_NAME} && ${command}"
    else
      podman exec -it ${extra_flags} "${DEV_CONTAINER_NAME}" bash
    fi
  fi
}
# ---
