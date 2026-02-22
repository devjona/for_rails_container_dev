#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../vars.sh"

echo ""
echo "============================================"
echo "  Move Rails Project to Host"
echo "============================================"
echo ""
echo "This will copy '${RAILS_APP_NAME}' from the dev container"
echo "to a directory on your host machine."
echo ""

read -p "Enter the destination directory (e.g. ~/Projects or /home/user/Projects): " DEST_DIR

# Expand a leading ~ to the actual home directory
DEST_DIR="${DEST_DIR/#\~/$HOME}"

if [ -z "${DEST_DIR}" ]; then
  echo "ERROR: No destination provided."
  exit 1
fi

if [ ! -d "${DEST_DIR}" ]; then
  echo "ERROR: Directory '${DEST_DIR}' does not exist."
  echo "Please create it first or choose an existing directory."
  exit 1
fi

FULL_DEST="${DEST_DIR}/${RAILS_APP_NAME}"

if [ -d "${FULL_DEST}" ]; then
  echo ""
  echo "WARNING: '${FULL_DEST}' already exists."
  read -p "Overwrite? (y/N): " OVERWRITE
  if [[ ! "${OVERWRITE}" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
fi

RAILS_PBR_DEST="${FULL_DEST}/rails_pbr"

echo ""
echo "Copying '${RAILS_APP_NAME}' from container to '${DEST_DIR}'..."
podman cp "${DEV_CONTAINER_NAME}:/box/${RAILS_APP_NAME}" "${DEST_DIR}/"

echo "Creating rails_pbr directory at '${RAILS_PBR_DEST}'..."
mkdir -p "${RAILS_PBR_DEST}"

echo "Copying dev-scripts to '${RAILS_PBR_DEST}/dev-scripts'..."
cp -r "${RAILS_PBR_DIR}/dev-scripts" "${RAILS_PBR_DEST}/dev-scripts"

echo "Copying setup-scripts to '${RAILS_PBR_DEST}/setup-scripts'..."
cp -r "${RAILS_PBR_DIR}/setup-scripts" "${RAILS_PBR_DEST}/setup-scripts"

echo "Copying vars.sh to '${RAILS_PBR_DEST}/vars.sh'..."
cp "${RAILS_PBR_DIR}/vars.sh" "${RAILS_PBR_DEST}/vars.sh"

echo "Copying Containerfile to '${RAILS_PBR_DEST}'..."
cp "${RAILS_PBR_DIR}/Containerfile" "${RAILS_PBR_DEST}/Containerfile"

echo "Copying Containerfile.dev to '${RAILS_PBR_DEST}'..."
cp "${RAILS_PBR_DIR}/Containerfile.dev" "${RAILS_PBR_DEST}/Containerfile.dev"

echo "Copying Rails PBR README to '${RAILS_PBR_DEST}/README.md'..."
cp "${RAILS_PBR_DIR}/README.md" "${RAILS_PBR_DEST}/README.md"

echo "Enabling bind mount in destination vars.sh..."
sed -i "s|^BIND_MOUNT=.*|BIND_MOUNT=true|" "${RAILS_PBR_DEST}/vars.sh"

echo "Adding Rails PBR note to '${FULL_DEST}/README.md'..."
{ printf '> **Note:** This app uses [Rails PBR](https://github.com/devjona/rails_pbr) for containerized local development.\n> To set up your environment after cloning, run `./rails_pbr/setup-scripts/podman-setup-clone.sh`.\n> Day-to-day scripts live in `./rails_pbr/dev-scripts/`.\n\n'; cat "${FULL_DEST}/README.md"; } > /tmp/rails_pbr_readme_tmp && mv /tmp/rails_pbr_readme_tmp "${FULL_DEST}/README.md"

echo ""
echo "Done! Your Rails app is at: ${FULL_DEST}"
echo ""
echo "All Rails PBR scripts are under ${RAILS_PBR_DEST}/"
echo ""
echo "To set up version control:"
echo "  cd ${FULL_DEST}"
echo "  git init"
echo "  git add -A"
echo "  git commit -m 'Initial commit'"
echo ""
echo "To connect to an existing remote repository:"
echo "  git remote add origin <your-repo-url>"
echo "  git push -u origin main"
echo ""
echo "After cloning, teammates run:"
echo "  ./rails_pbr/setup-scripts/podman-setup-clone.sh"
echo ""
