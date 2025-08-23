#!/bin/bash
# THIS IS STILL AN EXPERIMENTAL FILE!
set -e # Exit immediately if a command exits with a non-zero status

# I don't think we should check if anything exists anymore; that setup should've been performed already.
# We should be running podman restart <container>, though.

# 2. Restart postgres:latest in the network
podman restart ${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}

# 3. Wait for PostgreSQL to be ready
check_pgready
# until podman exec -it ${POSTGRES_HOST_FOR_RAILS_CONFIG_DB} pg_isready -U postgres; do
#   echo "Waiting for PostgreSQL to be ready..."
#   sleep 3
# done

echo "PostgreSQL is ready."

# 4. Restart the Rails container
# We'll have an issue here if you pull an existing project and want to run it in this container; you'll have to mount it.
# You might need a separate script for that; this is beyond the current scope, though.
podman restart ${RAILS_APP_NAME}

# Stop the PostgreSQL container after the Ruby server exits
echo "Exited from ${RAILS_APP_NAME}; stopping the postgres container..."
podman stop ${POSTGRES_HOST_FOR_RAILS_CONFIG_DB}
echo "${POSTGRES_HOST_FOR_RAILS_CONFIG_DB} is stopped."
