# for_rails_container_dev

The building blocks that one will need to start a Rails project developed locally in Podman containers.

I recently purchased a Framework 13; it's my daily driver (Fedora Workstation) and I'm trying to avoid installation of languages and frameworks on the host; it's an added challenge but I'm learning a lot about Containers.

**This assumes**:

1. You don't have Ruby, Node, etc. installed on your host machine and need a Container image that installs all dependencies so that you can **PBR**:
    - Pull
    - Build
    - Run (`rails new`, `rails db:create`)
1. You'll use PostgreSQL

**Missing Components**:

1. I need script(s) for *PBR-ing* a `Postgres` image and container that the Rails app will recognize when we run `rails db:create`.
1. Script equivalents for:
    - `rails server`
    - `rails console`
    - Running tests, (whether RSpec or MiniTest)
    - If necessary, running a separate front-end but I don't plan on using a SPA library such as React or Svelte.

## Sequence

These scripts are designed to make your life easier! Invoke them in the proper sequence, and you should have a perfectly functioning Rails app, containerized, ready for local development!

You can run scripts like this:

```shell
./name-of-script.sh
```

### Choose Variables

Before you run, take a look at `setup-scripts.vars.sh`; most of the variables in there should stay put (unless you have a very good reason for changing the standards). You should definitely update the `$RAILS_APP_NAME` and `$NETWORK` to the name you desire for your future Rails app.

### Build The Rails Image

Build the image with

```bash
setup-scripts/podman-setup-debian-rails-image.sh
```

The resulting image will have the necessary dependencies, ruby, the bundler and the rails gems installed.

### Set up the Podman network with

```shell
setup-scripts/podman-setup-network.sh
```

### Build Postgres Image and Confirm it is Ready

This will run your db for the first time; if you don't have the `postgres:latest` image, it will pull it.

```bash
./podman-setup-db
```

To see if your db is accepting connections:

```bash
podman exec -it <name of container> pg_isready
```

To get into the container:

```bash
podman exec -it <name of container> /bin/bash
```

You can then run the following to make sure you can see something like:

```shell
psql -U <POSTGRES_USER_NAME>
# and you should see:
psql (17.5 (Debian 17.5-1.pgdg120+1))
Type "help" for help.
```

### Create the Rails App and Database

(*Note, if you want to use Sqlite or MySql, you'll likely have to change the dependencies in the `Gemfile`*)

Before you run `rails new…`, research the full range of defaults you might want (CSS, API-only mode, etc.) Once you're ready, you can enter the Rails container with:

```shell
./podman-setup-rails.sh
```

Run the following command, making sure the app name matches the variable in `vars.sh`:

```shell
rails new <$RAILS_APP_NAME> -d postgresql (plus other options)
```

If `rails new` was successful, let's proceed!

Once your Rails app is created, you'll need to edit the `config/database.yml` file in the `development` and `test` sections. You'll be doing this from *within* the container, which is why `vim` and `nano` are included. Use the values from `vars.sh`, not the variable names; the variable names are only for reference:
<!-- I'd love to automate this below, with some sort of "search and uncomment" and "add lines after" for the development and test portions of this -->
```yaml
username: $RAILS_APP_NAME
password: $POSTGRES_PASSWORD
host: $POSTGRES_HOST_FOR_RAILS_CONFIG_DB
port: 5432
```

```bash
rails db:create
```

If that succeeds, run:

```bash
rails server -b 0.0.0.0
```

### Updating Our Image to Save the App

We have an entire Rails app structure that wasn't a part of the original build (Containerfile and scripts); in order to save this, we have a few options, both of which are great ideas and highly recommended

1. **Commit**

```bash

```

1. **Copy**
You can copy the app out of the container onto your host machine:

```bash
# to get the name of your container:
podman ps -a

# to copy:
podman cp <container name>:/path/to/app /path/on/host/
```
