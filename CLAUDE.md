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

Scripts are split into two directories. `vars.sh` lives in the project root and is sourced by all scripts as `source ../vars.sh`.

- `setup-scripts/` — one-time setup; run from within this directory
- `dev-scripts/` — day-to-day development; run from within this directory

## Key architectural decisions

- **Setup flow** (`podman-new-rails-app.sh` → `podman-setup-rails.sh` → `rails-new-entrypoint.sh`):
  1. `podman create` defines the container with `rails-new-entrypoint.sh` as its command
  2. `podman cp` copies the entrypoint script into the stopped container
  3. `podman start -ai` starts the container interactively — the entrypoint prints a welcome banner then hands off via `exec /bin/bash`; this is where the user runs `rails new`
  4. After the user types `exit`, control returns to `podman-setup-rails.sh` on the host; `podman cp` extracts `database.yml` from the stopped container, `awk` patches it, and `podman cp` copies it back
  5. `podman commit` snapshots the container (with the full Rails app and patched config) into `${RAILS_APP_IMAGE_NAME}`
  6. `rails db:create` runs via `podman run --rm` against the committed image — no container lifecycle juggling needed
  7. A persistent dev container (`${DEV_CONTAINER_NAME}`) is created from that image using `sleep infinity` to stay alive
  8. All subsequent dev work is done via `podman exec` into the dev container

- **`database.yml` patching**: Done in `podman-setup-rails.sh` on the host using `podman cp` + `awk`. The patch inserts `username`, `password`, `host`, and `port` into the `default: &default` section so all environments inherit the values. Production credentials will be handled separately in future work.

- **Test scripts are split in two**:
  - `podman-rails-test.sh` — drops into an interactive shell in the dev container (primary use case; run individual rspec or minitest commands manually)
  - `podman-rails-test-suite.sh` — runs the full suite non-interactively; currently uses `rails test` (MiniTest). **Update the command in this file once a test framework is decided.**

- **Naming conventions** (derived automatically from `RAILS_APP_NAME` in `vars.sh`):
  - `DEV_CONTAINER_NAME` = `${RAILS_APP_NAME}_dev`
  - `RAILS_APP_IMAGE_NAME` = `${RAILS_APP_NAME}_image`

- **`BIND_MOUNT` flag** in `vars.sh` controls which dev strategy is used. It defaults to `false` (exec mode: `podman exec` into the persistent dev container). `podman-move-project.sh` sets it to `true` in the destination copy of `vars.sh` so the exported app automatically uses bind-mount mode. In bind-mount mode every dev script uses `podman run --rm -v $(cd .. && pwd):/box/${RAILS_APP_NAME}:z` — a fresh container per command, no persistent dev container needed. The `:z` flag handles SELinux relabelling and is a no-op on non-SELinux hosts.

- **`ensure_container_running()`** is a shared helper in `vars.sh`; it checks if a container exists and starts it if stopped, or exits with a clear error if it was never created. Used in exec mode only.

## Scripts reference

### `setup-scripts/`

| Script | Purpose |
|--------|---------|
| `podman-new-rails-app.sh` | **Start here.** Prompts for app name, orchestrates all setup steps |
| `podman-setup-debian-rails-image.sh` | Builds the base Rails image from the Containerfile |
| `podman-setup-network.sh` | Creates the Podman network (idempotent) |
| `podman-setup-volume.sh` | Creates the Postgres volume (idempotent) |
| `podman-setup-db.sh` | Creates and starts the Postgres container (idempotent) |
| `podman-setup-rails.sh` | Creates the Rails setup container, runs interactive session, patches `database.yml` via `podman cp` + `awk`, runs `rails db:create`, commits image, creates dev container |
| `rails-new-entrypoint.sh` | Runs **inside** the container only; prints a welcome banner then `exec /bin/bash` — no automation, all automation is handled by `podman-setup-rails.sh` on the host |

### `dev-scripts/`

| Script | Purpose |
|--------|---------|
| `podman-rails-server.sh` | Starts postgres, runs `rails server`; in bind-mount mode stops the dev container first to free the port |
| `podman-rails-console.sh` | Starts postgres, opens `rails console` |
| `podman-rails-shell.sh` | Starts postgres, drops into interactive shell for any Rails command (`rails routes`, `rails generate`, etc.) |
| `podman-rails-test.sh` | Starts postgres, drops into interactive shell for manual test runs |
| `podman-rails-test-suite.sh` | Starts postgres, runs the full test suite |
| `podman-dev-stop.sh` | Stops the dev container and postgres cleanly |
| `podman-interact-db.sh` | Opens a bash shell inside the Postgres container |
| `podman-move-project.sh` | Copies the Rails app from the dev container to a host directory; sets `BIND_MOUNT=true` in the destination `vars.sh` |

# Remaining / Future Work

1. **Test framework decision** — RSpec vs MiniTest has not been decided. Update `podman-rails-test-suite.sh` once chosen (`bundle exec rspec` or `rails test`).
1. **Staging/production configuration** — `database.yml` currently patches the `default` section, so production inherits dev DB credentials. Production and staging should override credentials via environment variables or Rails encrypted credentials.
1. **Neovim / Ruby LSP** — Neovim installs but is not configured for Ruby development. Left for a future ticket.

# Summary

The user only has to:

1. `chmod +x setup-scripts/*.sh dev-scripts/*.sh` (first time only)
1. `cd setup-scripts && ./podman-new-rails-app.sh` — prompted for an app name, then ushered through the full setup automatically
1. Run `rails new` with desired flags inside the interactive container session, then `exit`
1. `cd ../dev-scripts` and use `./podman-rails-server.sh`, `./podman-rails-console.sh`, `./podman-rails-test.sh` for day-to-day development
1. Run `./podman-move-project.sh` to copy the project to a host directory for version control

Please let me know if you have any questions! I look forward to what we can accomplish.
