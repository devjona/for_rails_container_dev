#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../vars.sh"

podman exec -it ${POSTGRES_HOST_FOR_RAILS_CONFIG_DB} /bin/bash
