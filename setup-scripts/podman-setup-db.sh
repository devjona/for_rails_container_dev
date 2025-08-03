#!/bin/bash
set -e

source ./vars.sh

# We should check if this has been created already

podman run -d -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} -e POSTGRES_USER=${POSTGRES_USER_NAME} --name ${POSTGRES_HOST_FOR_RAILS_CONFIG_DB} --user ${POSTGRES_CONTAINER_USERNAME} --net ${NETWORK} postgres:latest
# how do we restart this?
# how do we keep the same name but not delete prior data?
# You should include the pg_isready check here:
echo "Checking if Postgres is ready…"
podman exec -it ${POSTGRES_HOST_FOR_RAILS_CONFIG_DB} pg_isready
