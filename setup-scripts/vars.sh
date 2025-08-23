#!/bin/bash
# https://solargraph.org/guides/language-server - runs on 7658 by default.
# --- These are for local development ONLY!

# --- OS
DEBIAN_RELEASE=bookworm
# ---

# Ruby and Rails
RAILS_APP_NAME=rails_setup
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

# --- Functions
function check_pgready() {
  until podman exec -it ${POSTGRES_HOST_FOR_RAILS_CONFIG_DB} pg_isready -U postgres; do
    echo "Waiting for PostgreSQL to be ready..."
    sleep 3
  done

  echo "PostgreSQL is ready."
}

# function check_volume_exists() {
#
# }
#
# function check_network_exists() {
#
# }
# ---
