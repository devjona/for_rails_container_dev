#!/bin/bash
set -e

source ./vars.sh

# Error, the network doesn't exist yet when this is happening;
# When should we creat that network?

podman run -d -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" -e POSTGRES_USER="$POSTGRES_USER_NAME" --name "$POSTGRES_HOST_FOR_RAILS_CONFIG_DB" --user "$POSTGRES_CONTAINER_NAME" --net "$NETWORK" postgres:latest
# how do we restart this?
# how do we keep the same name but not delete prior data?
# You should include the pg_isready check here:
echo "Checking if Postgres is ready…"
podman exec -it "$POSTGRES_HOST_FOR_RAILS_CONFIG_DB" pg_isready

