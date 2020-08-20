FROM archlinux

# copy the mirrorlist from the host to speed up the image build
COPY files/mirrorlist /etc/pacman.d/mirrorlist

# install base packages required for ansible control
# (Arch infrastructure installs them from the install_arch role)
RUN pacman -Syu --noconfirm base python-requests python-yaml

# install and enable openssh
RUN pacman -Syu --noconfirm openssh
RUN systemctl enable sshd.service

# set up basic SSH access so that we can access the container with ansible
EXPOSE 22
RUN install -dm700 /root/.ssh/
COPY files/authorized_keys /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# start systemd as PID 1 in the container
CMD ["/usr/lib/systemd/systemd"]
