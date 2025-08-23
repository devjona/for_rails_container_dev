#!/bin/bash
set -e

source ./vars.sh

# We should check if this has been created already
podman run -d -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} -e POSTGRES_USER=${POSTGRES_USER_NAME} --name ${POSTGRES_HOST_FOR_RAILS_CONFIG_DB} --user ${POSTGRES_CONTAINER_USERNAME} --net ${NETWORK} -v ${POSTGRES_VOLUME}:/var/lib/postgresql/data postgres:latest

# 3. Wait for PostgreSQL to be ready
check_pgready
# until podman exec -it ${POSTGRES_HOST_FOR_RAILS_CONFIG_DB} pg_isready -U postgres; do
#   echo "Waiting for PostgreSQL to be ready..."
#   sleep 3
# done
