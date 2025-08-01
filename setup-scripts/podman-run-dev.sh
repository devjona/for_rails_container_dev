#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status


#1. Check if the network exists; if not, create it
if ! podman network exists "$NETWORK"; then
    podman network create "$NETWORK"
    echo "Pod '$NETWORK' created."
else
    echo "Pod '$NETWORK' already exists."
fi

# 2. Start postgres:latest in the network
podman run -d --rm \
    --network "$NETWORK" \
    -p "$PORT_POSTGRES" \
    -e POSTGRES_PASSWORD=password \
    -e POSTGRES_USER=postgres \
    --name db \
    postgres:latest

# 3. Wait for PostgreSQL to be ready
until podman exec db pg_isready -U postgres; do
    echo "Waiting for PostgreSQL to be ready..."
    sleep 3
done

echo "PostgreSQL is ready."

# 4. Start the alpine ruby service in the pod as well
podman run -it --rm \
    --network "$NETWORK" \
    -p "$PORT_RAILS":"$PORT_RAILS" \
    # -v "$(pwd)":/app/:z \
    # -e DB_NAME=postgres \
    # -e DB_HOST=db \
    # -e DB_USER=postgres \
    # -e DB_PASSWORD=passy \
    # -e DB_PORT="$PORT_POSTGRES" \
    --name rails_server \
    ruby:"$RUBY_VERSION"-bullseye \
    /bin/bash -c "rails server.rb -o 0.0.0.0"

# Stop the PostgreSQL container after the Ruby server exits
echo "Exited from ruby_server; time to stop the db…"
podman stop db
echo "db is stopped."

    
