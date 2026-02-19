#!/bin/bash
set -e

source ../vars.sh

podman exec -it ${POSTGRES_HOST_FOR_RAILS_CONFIG_DB} /bin/bash
