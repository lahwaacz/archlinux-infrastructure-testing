## Prerequisites

[systemd-nspawn](https://wiki.archlinux.org/index.php/systemd-nspawn) works on
any Arch host system. Configuring _systemd-networkd_ and _systemd-resolved_ on
the host may simplify networking setup (see below).

## Create a container

First copy your public SSH key to `./files/authorized_keys`.

Run the `create-container` script (uses `sudo`):

    ./create-container <container-name>

This creates a container in `/var/lib/machines/<container_name>` which can be
managed with [machinectl](
https://wiki.archlinux.org/index.php/systemd-nspawn#machinectl).

## Tips and tricks

- The name of the container implies its hostname (see the `--machine` and
  `--hostname` flags).
- Hostname resolution for local containers with private network (see below)
  managed by `machinectl` works out-of-the-box with `nss-mymachines(8)`, so
  you can access the container with `ssh root@<container>`.
- Containers can be configured in `/etc/systemd/nspawn/<container>.nspawn`.
- Note there is an `Ephemeral=yes` option to run the container from a temporary
  snapshot.

## Networking

> __Note:__ this section is work in progress!

By default, containers started with `machinectl` have a private network. To let
the container access the internet, either configure NAT translation for the
virtual ethernet device or add the virtual ethernet device to a bridge with a
physical interface or disable private networking by seting `VirtualEthernet=no`
in the `<container>.nspawn` file.

Note that ports in the container can be exposed by the `Port=` option, e.g.
`Port=tcp:<host-port>:<container-port>`. The `Port=` option requires private
networking.

Note: NAT should work out-of-the-box with systemd-networkd, because the file
`/usr/lib/systemd/network/80-container-ve.network` has `IPMasquerade=yes`. But
configuring the firewall properly may be tricky - systemd-networkd adds just
one rule in the `nat` table, like:

    -A POSTROUTING -s 192.168.163.192/28 -j MASQUERADE

The filter table has to be configured manually, see
https://wiki.archlinux.org/index.php/Internet_sharing#With_iptables

I also had to add this to the `INPUT` chain:

    -A INPUT -i ve-+ -j ACCEPT

Also, `IPMasquerade=yes` may not work with nftables.
