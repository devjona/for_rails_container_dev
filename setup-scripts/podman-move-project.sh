#!/bin/bash
set -e

source ../vars.sh

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

echo ""
echo "Copying '${RAILS_APP_NAME}' from container to '${DEST_DIR}'..."
podman cp "${DEV_CONTAINER_NAME}:/box/${RAILS_APP_NAME}" "${DEST_DIR}/"

echo "Copying dev-scripts to '${FULL_DEST}/dev-scripts'..."
cp -r dev-scripts/ "${FULL_DEST}/dev-scripts"

echo "Copying setup-scripts to '${FULL_DEST}/setup-scripts'..."
cp -r setup-scripts/ "${FULL_DEST}/setup-scripts"

echo "Copying Rails PBR README to '${FULL_DEST}/dev-scripts/README.md'..."
cp ../README.md "${FULL_DEST}/dev-scripts/README.md"

echo "Adding Rails PBR note to '${FULL_DEST}/README.md'..."
{ printf '> **Note:** This app was built with [Rails PBR](https://github.com/devjona/rails_pbr). See `dev-scripts/README.md` for information on running this app with Podman containers.\n\n'; cat "${FULL_DEST}/README.md"; } > /tmp/rails_pbr_readme_tmp && mv /tmp/rails_pbr_readme_tmp "${FULL_DEST}/README.md"

echo "Copying vars.sh to '${FULL_DEST}/vars.sh'..."
cp ../vars.sh "${FULL_DEST}/vars.sh"

echo "Copying the Containerfile to '${FULL_DEST}'..."
cp ../Containerfile "${FULL_DEST}"

echo "Copying Containerfile.dev to '${FULL_DEST}'..."
cp ../Containerfile.dev "${FULL_DEST}"

echo "Enabling bind mount in destination vars.sh..."
sed -i "s|^BIND_MOUNT=.*|BIND_MOUNT=true|" "${FULL_DEST}/vars.sh"

echo ""
echo "Done! Your Rails app is at: ${FULL_DEST}"
echo ""
echo "The dev-scripts and vars.sh have been included so all developers"
echo "can use them after cloning the repo. Run them from dev-scripts/:"
echo ""
echo "  cd ${FULL_DEST}/dev-scripts"
echo "  ./podman-rails-server.sh"
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
