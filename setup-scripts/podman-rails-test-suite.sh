#!/bin/bash
set -e

source ./vars.sh

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

echo "Starting dev container..."
ensure_container_running "${DEV_CONTAINER_NAME}"

echo ""
if [ -n "${TEST_TARGET}" ]; then
  echo "Running: rails test ${TEST_TARGET}"
else
  echo "Running: rails test (full suite)"
fi
echo ""

podman exec -it "${DEV_CONTAINER_NAME}" bash -c "cd /box/${RAILS_APP_NAME} && rails test ${TEST_TARGET}"
