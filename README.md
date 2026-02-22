# Rails PBR (Pull, Build, Run)

[Project Link](https://github.com/devjona/rails_pbr)

The building blocks that one will need to start a Rails project developed locally in Podman containers.

I recently purchased a Framework 13; it's my daily driver (Fedora Workstation) and I'm trying to avoid installation of languages and frameworks on the host; it's an added challenge but I'm learning a lot about Containers.

**This assumes**:

1. You don't have Ruby, Node, etc. installed on your host machine and need a Container image that installs all dependencies so that you can **PBR**:
   - _Pull_ all the images you need
   - _Build_ the containers for various services
   - _Run_ your Rails app for local development, fully in Podman Containers
1. You'll use PostgreSQL
1. You have Podman (or can install it).

## Prerequisites

Before running any scripts for the first time, make them executable from the project root:

```shell
chmod +x **/*.sh
```

Scripts are organised into two directories. They can be called from the project root or from within their directory — both work:

```shell
# From the project root:
./setup-scripts/podman-new-rails-app.sh

# Or from within the directory:
cd setup-scripts
./podman-new-rails-app.sh
```

## Creating a New Rails App

The entire setup is orchestrated by a single script:

```shell
./setup-scripts/podman-new-rails-app.sh
```

This will:

1. Prompt you for your app name and update `vars.sh`
2. Build the Rails image
3. Set up the Podman network and volume
4. Pull and start the Postgres container
5. Drop you into an interactive container where you can run `rails new` with any flags you choose:

```shell
rails new <your_app_name> -d postgresql [your optional flags]
```

Some examples of optional flags (these come from Ruby on Rails):

```shell
--css tailwind        # Tailwind CSS
--css bootstrap       # Bootstrap
--javascript esbuild  # esbuild bundler
--api                 # API-only mode
```

6. Once you type `exit`, setup continues automatically: `config/database.yml` is patched with the correct connection settings and `rails db:create` is run for you
7. The container is committed as an image and a persistent dev container is created, ready for development

## Day-to-Day Development

```shell
./dev-scripts/podman-rails-server.sh     # Start 'rails server' at http://localhost:3000
./dev-scripts/podman-rails-console.sh    # Open 'rails console'
./dev-scripts/podman-rails-shell.sh      # Drop into a shell to run any Rails command (routes, generate, migrate, etc.)
./dev-scripts/podman-rails-test.sh       # Drop into an interactive shell to run individual tests
./dev-scripts/podman-rails-test-suite.sh # Run the full test suite
./dev-scripts/podman-dev-stop.sh         # Stop all containers cleanly when you're done
```

Each script starts Postgres automatically. The dev container is started when needed (exec mode, before `podman-move-project.sh` is run).

## Moving Your Project

Once you're happy with your app and want to set up a git repo or move it to its own directory:

```shell
./setup-scripts/podman-move-project.sh
```

This copies the Rails app from the dev container to a location of your choice on the host, along with `dev-scripts/`, `setup-scripts/`, the `Containerfiles`, and `vars.sh`, so all developers on the project have everything they need. You'll be prompted for the destination path. It also copies this project's `README.md` into `dev-scripts/`.

After the move, the dev scripts switch to bind-mount mode: the project directory on the host is mounted directly into each container, so any code change you make in your editor is immediately reflected — no sync step needed.

Once moved, make the scripts executable and set up version control:

```shell
cd /your/destination/path/<app_name>
chmod +x rails_pbr/**/*.sh
git init
git add -A
git commit -m "Initial commit"

# To connect to an existing remote:
git remote add origin <your-repo-url>
git push -u origin main
```

Any developer who clones the repo will also need to run `chmod +x rails_pbr/**/*.sh` before using the scripts.

## Setting Up a Cloned Project

If you've cloned an existing Rails project that was built with PBR and need to set up your local environment from scratch, run this from the project root:

```shell
./rails_pbr/setup-scripts/podman-setup-clone.sh
```

This will build the Rails app image (from `Containerfile.dev`), create the Podman network and volume, start the Postgres container, and run `rails db:prepare`. Once complete, you can use the dev scripts as normal:

```shell
./rails_pbr/dev-scripts/podman-rails-server.sh
./rails_pbr/dev-scripts/podman-rails-console.sh
./rails_pbr/dev-scripts/podman-rails-shell.sh
```

## Interacting with the Database Directly

To open a shell inside the Postgres container:

```shell
./dev-scripts/podman-interact-db.sh
```

From there you can connect with `psql`:

```shell
psql -U <POSTGRES_USER_NAME>
```
