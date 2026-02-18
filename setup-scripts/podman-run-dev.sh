#!/bin/bash
set -e

source ./vars.sh

echo ""
echo "============================================"
echo "  Restarting Dev Environment"
echo "============================================"
echo ""

echo "Restarting Postgres..."
podman restart "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}"
check_pgready

echo "Restarting dev container..."
podman restart "${DEV_CONTAINER_NAME}"

echo ""
echo "Dev environment is running."
echo ""
echo "  ./podman-rails-server.sh  — Start 'rails server'"
echo "  ./podman-rails-console.sh — Open 'rails console'"
echo "  ./podman-rails-test.sh    — Open test shell"
echo "  ./podman-dev-stop.sh      — Stop all containers"
echo ""
