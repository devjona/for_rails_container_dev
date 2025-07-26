#!/bin/bash
set -e

source ./vars.sh
# This is where you'll podman run --it the FIRST time to call:
# rails new <app name>
# rails db:create !! make sure the db is running first.
podman run -it --net "$NETWORK" -p "$PORT_RAILS":"$PORT_RAILS" "$RAILS_CONTAINER_TAG"/bin/bash