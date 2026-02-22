#!/bin/bash
set -e

source ../vars.sh

echo ""
echo "============================================"
echo "  Rails Console"
echo "============================================"
echo ""

echo "Starting Postgres..."
ensure_container_running "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}"
check_pgready

echo ""
echo "Opening Rails console (type 'exit' or press Ctrl+D to quit)..."
echo ""

run_in_container "rails console"
