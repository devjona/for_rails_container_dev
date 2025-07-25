# for_rails_container_dev

The building blocks that one will need to start a Rails project developed locally in Podman containers. 

I recently purchased a Framework 13; it's my daily driver (Fedora Workstation) and I'm trying to avoid installation of languages and frameworks on the host; it's an added challenge but I'm learning a lot about Containers.

**This assumes**
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


