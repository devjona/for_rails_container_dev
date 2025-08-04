#!/bin/bash
set -e

source ./vars.sh

# You should check pg_ready first, otherwise don't run this script.

# This is where you'll podman run --it the FIRST time to call:
# rails new <app name>
# rails db:create !! make sure the db is running first.

podman run -it --name ${RAILS_APP_NAME} --net ${NETWORK} -p ${PORT_RAILS}:${PORT_RAILS} ${RAILS_CONTAINER_TAG} /bin/bash
