FROM docker.io/library/fedora:36
RUN dnf -y update && dnf install -y phosh phoc wayvnc sudo socat iproute mutter xorg-x11-server-Xwayland dbus-x11 mesa-libgbm mesa-libOpenCL mesa-libGL mesa-libGLU mesa-libEGL mesa-vulkan-drivers mesa-libOSMesa mesa-dri-drivers mesa-filesystem gnome-shell gnome-console htop nano
RUN mkdir -p /etc/systemd/system/phosh.service.d
COPY 10-headless.conf /etc/systemd/system/phosh.service.d/10-headless.conf
RUN systemctl enable phosh.service
# Mask udev instead of making /sys/ read-only as suggested in https://systemd.io/CONTAINER_INTERFACE/
RUN systemctl mask systemd-udevd.service systemd-modules-load.service systemd-udevd-control.socket systemd-udevd-kernel.socket rtkit-daemon.service
ENV container=docker
RUN groupadd --system sudo
RUN useradd --create-home --shell /bin/bash -G sudo user
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
ENV LIBGL_ALWAYS_SOFTWARE=1
COPY phosh-auto-maximize.service /etc/systemd/user/phosh-auto-maximize.service
RUN mkdir -p /etc/systemd/user/default.target.wants && ln -fs /etc/systemd/user/phosh-auto-maximize.service /etc/systemd/user/default.target.wants/phosh-auto-maximize.service
EXPOSE 7050
# Set up a /dev/console link to have the same behavior with or without "-it", needs podman run --systemd=always
CMD [ "/bin/sh", "-c", "if ! [ -e /dev/console ] ; then socat -u pty,link=/dev/console stdout & fi ; exec /sbin/init" ]
# Use as: podman run --systemd=always --rm -p 7050:7050 phosh-vnc
