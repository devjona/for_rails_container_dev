#!/bin/bash

# These are for local development ONLY!
# Network and Ports
NETWORK="rails_setup_netw" # I like to use "app_name_" + "netw"
PORT_POSTGRES=5432
PORT_RAILS=3000
PORT_SOLARGRAPH=8888
# ---

# Postgres
POSTGRES_CONTAINER_USERNAME=postgres

# I like to use "app_name" + "_db"
POSTGRES_HOST_FOR_RAILS_CONFIG_DB=rails_setup_db
POSTGRES_PASSWORD=password

# Is set to the name of your app by default. If you change it, make sure you update your config/database.yaml
POSTGRES_USER_NAME=rails_setup
# ---

# Ruby and Rails
RAILS_APP_NAME=rails_setup # set to the name of your app.
RAILS_VERSION="8.0.2"
RUBY_VERSION="3.4.5"
RAILS_CONTAINER_TAG="debian-ruby'$RUBY_VERSION':rails-'$RAILS_VERSION'"
# ---
