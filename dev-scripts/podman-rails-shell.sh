#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../vars.sh"

echo ""
echo "============================================"
echo "  Rails Shell"
echo "============================================"
echo ""

echo "Starting Postgres..."
ensure_container_running "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}"
check_pgready

echo ""
echo "Entering '${RAILS_APP_NAME}'. Run any Rails command you need."
echo "Type 'exit' or press Ctrl+D to leave."
echo ""

run_in_container "" "-w /box/${RAILS_APP_NAME}"
