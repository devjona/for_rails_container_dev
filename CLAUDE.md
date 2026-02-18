# Inspiration for this project

To be able to start a new Ruby on Rails project from scratch, on the assumption that the host machine only has Podman and does not, nor will it, install Ruby, gems, or Node, etc.

The end goal is that after creation, the user will be able to copy the Rails project into its own directory (with helpful scripts), to have a development and test environment that mimics the feel of "rails server, rails console, rails routes, etc" but all within podman container(s) that are interactive. The user should never have to install Ruby, Node, Postgres, etc. on their host machine; the development will be entirely inside of containers.

# Constraints

1. I don't want to lean on `podman compose`; it's not quite the same as `docker compose`. Instead, there are already a series of shell scripts that we can invoke. We should proceed with this paradigm. The goal is that a developer should be able to invoke the `podman-*` scripts and it should feel similar to `rails new` or `rails server/console/db:, etc.`
1. For the moment, we don't need to worry about Neovim; it installs, which is fine, but I'll leave the enhancement of that experience (Ruby LSP, for example) for a future ticket.
1. Let's focus on the development and test experience, first.
1. Let's keep the scripts modular; to the best of our ability, we should follow a SOLID-type principle in that a script should try to only accomplish one task. My hope is that there can be some reusability and composability; they should also be easy to read. If you think any of the existing scripts should change or be modified, I welcome your suggestions.
1. We assume that we'll use postgres.

# What Has Been Built

All scripts live in `setup-scripts/` and must be run from that directory. `source ./vars.sh` is the convention for picking up shared variables and functions.

## Key architectural decisions

- **Setup flow** (`podman-new-rails-app.sh` → `podman-setup-rails.sh` → `rails-new-entrypoint.sh`):
  1. `podman create` defines the container with env vars and sets `rails-new-entrypoint.sh` as its command
  2. `podman cp` copies the entrypoint script into the stopped container
  3. `podman start -ai` starts the container interactively — this is where the user runs `rails new`
  4. After the user exits, the entrypoint auto-patches `database.yml` and runs `rails db:create`
  5. Back on the host, `podman commit` snapshots the container (with the full Rails app) into `${RAILS_APP_IMAGE_NAME}`
  6. A persistent dev container (`${DEV_CONTAINER_NAME}`) is created from that image using `sleep infinity` to stay alive
  7. All subsequent dev work is done via `podman exec` into the dev container

- **`database.yml` patching**: The `awk` patch in `rails-new-entrypoint.sh` inserts `username`, `password`, `host`, and `port` into the `default: &default` section. This means all environments (development, test, and production) inherit these values. Production credentials will be handled separately in future work.

- **Test scripts are split in two**:
  - `podman-rails-test.sh` — drops into an interactive shell in the dev container (primary use case; run individual rspec or minitest commands manually)
  - `podman-rails-test-suite.sh` — runs the full suite non-interactively; currently uses `rails test` (MiniTest). **Update the command in this file once a test framework is decided.**

- **Naming conventions** (derived automatically from `RAILS_APP_NAME` in `vars.sh`):
  - `DEV_CONTAINER_NAME` = `${RAILS_APP_NAME}_dev`
  - `RAILS_APP_IMAGE_NAME` = `${RAILS_APP_NAME}_image`

- **`ensure_container_running()`** is a shared helper in `vars.sh`; it checks if a container exists and starts it if stopped, or exits with a clear error if it was never created.

## Scripts reference

| Script | Purpose |
|--------|---------|
| `podman-new-rails-app.sh` | **Start here.** Prompts for app name, orchestrates all setup steps |
| `podman-setup-debian-rails-image.sh` | Builds the base Rails image from the Containerfile |
| `podman-setup-network.sh` | Creates the Podman network (idempotent) |
| `podman-setup-volume.sh` | Creates the Postgres volume (idempotent) |
| `podman-setup-db.sh` | Creates and starts the Postgres container (idempotent) |
| `podman-setup-rails.sh` | Creates the Rails setup container, runs interactive session, commits image, creates dev container |
| `rails-new-entrypoint.sh` | Runs **inside** the container only; not invoked directly from the host |
| `podman-rails-server.sh` | Starts postgres + dev container, runs `rails server` |
| `podman-rails-console.sh` | Starts postgres + dev container, opens `rails console` |
| `podman-rails-shell.sh` | Starts postgres + dev container, drops into interactive shell for any Rails command (`rails routes`, `rails generate`, etc.) |
| `podman-rails-test.sh` | Starts postgres + dev container, drops into interactive shell for manual test runs |
| `podman-rails-test-suite.sh` | Starts postgres + dev container, runs the full test suite |
| `podman-run-dev.sh` | Restarts postgres and the dev container if they already exist |
| `podman-dev-stop.sh` | Stops the dev container and postgres cleanly |
| `podman-interact-db.sh` | Opens a bash shell inside the Postgres container |
| `podman-move-project.sh` | Copies the Rails app from the dev container to a host directory |

# Remaining / Future Work

1. **Host/container code sync** — currently the Rails app lives only inside the dev container. When the user runs `podman-move-project.sh`, a one-time copy is made to the host. Ongoing sync (bind mounts) is deferred and should be addressed when the project is moved to its own directory.
1. **Test framework decision** — RSpec vs MiniTest has not been decided. Update `podman-rails-test-suite.sh` once chosen (`bundle exec rspec` or `rails test`).
1. **Staging/production configuration** — `database.yml` currently patches the `default` section, so production inherits dev DB credentials. Production and staging should override credentials via environment variables or Rails encrypted credentials.
1. **Neovim / Ruby LSP** — Neovim installs but is not configured for Ruby development. Left for a future ticket.
1. **README update** — the `README.md` Sequence section still describes the old manual multi-step flow. It should be updated to reflect that `./podman-new-rails-app.sh` is now the single entry point.

# Summary

The user only has to:

1. `chmod +x setup-scripts/*.sh` (first time only)
1. `cd setup-scripts && ./podman-new-rails-app.sh` — prompted for an app name, then ushered through the full setup automatically
1. Run `rails new` with desired flags inside the interactive container session, then `exit`
1. Use `./podman-rails-server.sh`, `./podman-rails-console.sh`, `./podman-rails-test.sh` for day-to-day development
1. Run `./podman-move-project.sh` to copy the project to a host directory for version control

Please let me know if you have any questions! I look forward to what we can accomplish.
