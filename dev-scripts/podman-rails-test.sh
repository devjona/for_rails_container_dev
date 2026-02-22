#!/bin/bash
set -e

source ../vars.sh

echo ""
echo "============================================"
echo "  Rails Test Shell"
echo "============================================"
echo ""

echo "Starting Postgres..."
ensure_container_running "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}"
check_pgready

echo ""
echo "Entering test shell in '${RAILS_APP_NAME}'."
echo "Run whichever rspec or minitest commands you need."
echo "Type 'exit' or press Ctrl+D to leave."
echo ""

run_in_container "" "-w /box/${RAILS_APP_NAME}"
