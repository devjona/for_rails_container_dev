# for_rails_container_dev

The building blocks that one will need to start a Rails project developed locally in Podman containers.

I recently purchased a Framework 13; it's my daily driver (Fedora Workstation) and I'm trying to avoid installation of languages and frameworks on the host; it's an added challenge but I'm learning a lot about Containers.

**This assumes**:

1. You don't have Ruby, Node, etc. installed on your host machine and need a Container image that installs all dependencies so that you can **PBR**:
   - Pull
   - Build
   - Run (`rails new`, `rails db:create`)
1. You'll use PostgreSQL

## Prerequisites

Before running any scripts for the first time, make them executable from the project root:

```shell
chmod +x setup-scripts/*.sh
```

All scripts are designed to be run from within the `setup-scripts/` directory:

```shell
cd setup-scripts
./name-of-script.sh
```

## Creating a New Rails App

The entire setup is orchestrated by a single script. From the `setup-scripts/` directory:

```shell
./podman-new-rails-app.sh
```

This will:

1. Prompt you for your app name and update `vars.sh`
2. Build the Rails image if it hasn't been built yet
3. Set up the Podman network and volume
4. Pull and start the Postgres container
5. Drop you into an interactive container where you can run `rails new` with any flags you choose:

```shell
rails new <your_app_name> -d postgresql [your optional flags]
```

Some examples of optional flags:

```shell
--css tailwind        # Tailwind CSS
--css bootstrap       # Bootstrap
--javascript esbuild  # esbuild bundler
--api                 # API-only mode
```

6. Once you type `exit`, setup continues automatically: `config/database.yml` is patched with the correct connection settings and `rails db:create` is run for you
7. The container is committed as an image and a persistent dev container is created, ready for development

## Day-to-Day Development

From the `setup-scripts/` directory:

```shell
./podman-rails-server.sh     # Start 'rails server' at http://localhost:3000
./podman-rails-console.sh    # Open 'rails console'
./podman-rails-shell.sh      # Drop into a shell to run any Rails command (routes, generate, migrate, etc.)
./podman-rails-test.sh       # Drop into an interactive shell to run individual tests
./podman-rails-test-suite.sh # Run the full test suite
./podman-dev-stop.sh         # Stop all containers cleanly when you're done
```

Each script starts Postgres and the dev container automatically if they aren't already running.

To restart containers that already exist (e.g. after a reboot):

```shell
./podman-run-dev.sh
```

## Moving Your Project

Once you're happy with your app and want to set up a git repo or move it to its own directory:

```shell
./podman-move-project.sh
```

This copies the Rails app from the dev container to a location of your choice on the host. You'll be prompted for the destination path. Afterwards, you can initialise a git repo or connect it to an existing remote:

```shell
cd /your/destination/path/<app_name>
git init
git add -A
git commit -m "Initial commit"

# To connect to an existing remote:
git remote add origin <your-repo-url>
git push -u origin main
```

## Interacting with the Database Directly

To open a shell inside the Postgres container:

```shell
./podman-interact-db.sh
```

From there you can connect with `psql`:

```shell
psql -U <POSTGRES_USER_NAME>
```
