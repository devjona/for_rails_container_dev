#!/bin/bash
set -e

source ./vars.sh

podman run -d -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" -e POSTGRES_USER="$POSTGRES_USER_NAME" --name "$POSTGRES_HOST_FOR_RAILS_CONFIG_DB" --user "$POSTGRES_CONTAINER_NAME" --net "$NETWORK" postgres:latest
# how do we restart this?
# how do we keep the same name but not delete prior data?