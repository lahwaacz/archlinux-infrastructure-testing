## Prerequisites

Make sure that Docker is installed, configured and started on your system. See
the [ArchWiki page about Docker](https://wiki.archlinux.org/index.php/Docker)
or the upstream documentation for instructions.

## Configuration

- Copy your public SSH key to `./files/authorized_keys`
- To speed up the build of the Docker image, the build script will copy
  `/etc/pacman.d/mirrorlist` from the host to `./files/mirrorlist` and then into
  the container. You can override the mirrors by editing `./files/mirrorlist`.
- The container name, port for the SSH service etc. can be configured in
  `./config`.
- The container will have no data volumes (unless manually added).

## Start the container

There are several scripts wrapping various common `docker` commands:

- Run `./build` as root to build the Docker image. The image name is
  `arch_infra:base`.
- Run `./start` as root to start the Docker container. It uses the values
  specified in `./config`.

Now you should be able to connect to the container with SSH:

    ssh -p <configured-port> root@localhost

> __Note:__
> The running Docker container is not persistent, any changes made to the
> container will be lost when you stop `docker.service`. (Starting the container
> again with `./start` will create a new container with a different ID.) But
> commands like `docker container {stop,start,restart} <name-or-id>` preserve
> the container ID and thus all changes. You can also "reboot" the dockerized
> system over SSH. To discard the container and start from scratch, run
> `docker container rm <name-or-id>`.

> __Tip:__
> To preserve the changes made to the container, you need to use commit:
> ```
> docker commit <container-name-or-id> <new-image-name>
> ```
> This will create a new image based on the container snapshot.

> __Note:__
> We cannot use a data volume for `/` (i.e. we cannot run `docker run` with
> `--mount "source=root_volume,destination=/"`), which really sucks... But for
> testing some services it might be feasible to add some data volumes...
