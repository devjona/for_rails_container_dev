#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../vars.sh"

# Optionally pass a specific test file or directory as an argument:
#   ./podman-rails-test-suite.sh test/models/user_test.rb
TEST_TARGET="${1:-}"

echo ""
echo "============================================"
echo "  Rails Test Suite"
echo "============================================"
echo ""

echo "Starting Postgres..."
ensure_container_running "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}"
check_pgready

echo ""
if [ -n "${TEST_TARGET}" ]; then
  echo "Running: rails test ${TEST_TARGET}"
else
  echo "Running: rails test (full suite)"
fi
echo ""

run_in_container "rails test ${TEST_TARGET}"
