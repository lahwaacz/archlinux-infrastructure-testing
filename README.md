# Arch infrastructure testing

The motivation for this "project" is running [Ansible](https://www.ansible.com/)
tasks in a local container for testing the
[Arch Linux infrastructure](https://gitlab.archlinux.org/archlinux/infrastructure/)
configuration.

The workflow starts with a base Arch container providing a clean system with
preconfigured SSH access. After starting the container, the system can be
managed by Ansible. The container itself is managed by the user. For example,
depending on your setup, you can create snapshots, add data volumes for testing
services, etc.

Below are hints for setting up a few container types. If you have a different
favourite setup, feel free to share!

## Set up a container

- [Docker](https://www.docker.com/) – see [docker/README.md](./docker/README.md)

## Ansible

The Arch infrastructure repository is cloned as a git submodule in
`./arch_infrastructure/`. Hence, make sure to initialize git submodules after
cloning the repo:

    git submodule update --init --recursive

The playbooks, variables etc. for managing local containers are in
`./local_infrastructure/` (maintaining a separate directory is needed to get
around the vaulted variables in the main repository).

The Ansible roles, plugins and library scripts are taken directly from the main
repository (see `ansible.cfg` in `local_infrastructure`). However, the roles do
not work out of the box inside local containers (yet). Also some roles do not
make sense at all for local containers (e.g. `archusers`, `root_ssh`,
`borg-client` etc.) In general we also cannot use Let's Encrypt in containers so
some services have to be modified to be accessible over plain HTTP.

> __Note:__
> The `arch_infrastructure` submodule tracks a custom repository/branch with
> the necessary changes by default:
> https://github.com/lahwaacz/archlinux-infrastructure/commits/local-docker

TODO: add more details
