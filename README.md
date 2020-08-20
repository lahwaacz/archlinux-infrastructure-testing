# Dockerized Arch Infrastructure

The motivation for this "project" is running [Ansible](https://www.ansible.com/)
tasks in a [Docker](https://www.docker.com/) container for testing the
[Arch Linux infrastructure](https://gitlab.archlinux.org/archlinux/infrastructure/)
configuration.

The process starts with a small Arch-based image providing a base system with
SSH service. After starting the Docker container, the system can be managed by
Ansible. The container has no data volumes (unless manually added) and the state
has to be manually committed in order to preserve the changes (see below for
details).


## Getting started

Make sure to initialize git submodules after cloning the repo:

    $ git submodule update --init --recursive

### Prerequisites

Make sure that Docker is installed, configured and started on your system. See
the [ArchWiki page about Docker](https://wiki.archlinux.org/index.php/Docker)
or the upstream documentation for instructions.

### Configuration

- Copy your public SSH key to `./files/authorized_keys`
- To speed up the build of the Docker image, the build script will copy
  `/etc/pacman.d/mirrorlist` from the host to `./files/mirrorlist` and then into
  the container. You can override the mirrors by editing `./files/mirrorlist`.
- The container name, port for the SSH service etc. can be configured in
  `./config`.

### Start the container

There are several scripts wrapping various common `docker` commands:

- Run `./build` as root to build the Docker image. The image name is
  `arch_infra:base`.
- Run `./start` as root to start the Docker container. It uses the values
  specified in `./config`.

Now you should be able to connect to the container with SSH:

    $ ssh -p <configured-port> root@localhost

__Note:__
> The running Docker container is not persistent, any changes made to the
> container will be lost when you stop `docker.service`. (Starting the container
> again with `./start` will create a new container with a different ID.) But
> commands like `docker container {stop,start,restart} <name-or-id>` preserve
> the container ID and thus all changes. You can also "reboot" the dockerized
> system over SSH. To discard the container and start from scratch, run
> `docker container rm <name-or-id>`.

__Tip:__
> To preserve the changes made to the container, you need to use commit:
> ```
> docker commit <container-name-or-id> <new-image-name>
> ```
> This will create a new image based on the container snapshot.

__Note:__
> We cannot use a data volume for `/` (i.e. we cannot run `docker run` with
> `--mount "source=root_volume,destination=/"`), which really sucks... But for
> testing some services it might be feasible to add some data volumes...


## Ansible

The Arch infrastructure repository is cloned as a git submodule in
`./arch_infrastructure/`. The playbooks, variables etc. for managing local
Docker containers are in `./local_infrastructure/` (maintaining a separate
directory is needed to get around the vaulted variables in the main repository).

The Ansible roles, plugins and library scripts are taken directly from the main
repository (see `ansible.cfg` in `local_infrastructure`). However, the roles do
not work out of the box inside Docker (yet). Also some roles do not make sense
at all for local containers (e.g. `archusers`, `root_ssh`, `borg-client` etc.)
In general we also cannot use Let's Encrypt in Docker containers so some
services have to be modified to be accessible over plain HTTP.

__Note:__
> The `arch_infrastructure` submodule tracks a custom repository/branch with
> the necessary changes by default:
> https://github.com/lahwaacz/archlinux-infrastructure/commits/local-docker

TODO: add more details
