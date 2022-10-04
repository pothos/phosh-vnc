# Phosh Container with VNC Server

A graphical GNOME Phosh user session in a container, accessible via VNC and using software rendering.
This works thanks to [wayvnc](https://github.com/any1/wayvnc) for wlroots.

Note that GNOME Shell also has desktop sharing via RDP and VNC but here Phosh is used due to it being a bit more lightweight.

## Usage

From the prebuilt image:

```
podman run --systemd=always --rm -p 7050:7050 ghcr.io/pothos/phosh-vnc:main
```

From a locally built image:

```
make
podman run --systemd=always --rm -p 7050:7050 phosh-vnc
```

Test it out with `vinagre -f vnc://127.0.0.1:7050` and stop the container with Ctrl-C on the command line or from within the container through a `sudo poweroff`.

The user account `user` has no password set and you have sudo access without a password from it.

With Docker things are a bit more complicated, you can try one of:

```
docker run --rm --privileged --cgroupns=host --tmpfs /tmp --tmpfs /run --tmpfs /run/lock -v /sys/fs/cgroup:/sys/fs/cgroup -p 7050:7050 phosh-vnc
# or
docker run --rm --privileged --cgroup-parent=docker.slice --cgroupns private --tmpfs /tmp --tmpfs /run --tmpfs /run/lock -p 7050:7050 phosh-vnc
```

However, this wasn't enough for me and Phosh failed to start for some reason.

## Note

If you already have SSH access to a system with Phosh installed, you don't need to use the container.
Instead, you can either directly create the file `/etc/systemd/system/phosh.service.d/10-headless.conf` as done in the container
or you can start Phosh temporarily:

```
# start-vnc.sh
set -euo pipefail
export LIBGL_ALWAYS_SOFTWARE=1 # You can skip this if you have a GPU present
export LD_LIBRARY_PATH=/usr/lib
mkdir -p /tmp/.X11-unix
[ -d "/run/user/$UID" ] || { sudo mkdir -p "/run/user/$UID" && sudo chown "$USER:$USER" "/run/user/$UID" ; }
export XDG_CURRENT_DESKTOP=GNOME XDG_SESSION_DESKTOP=phosh XDG_SESSION_TYPE=wayland "XDG_RUNTIME_DIR=/run/user/$UID"
gsettings set sm.puri.phoc auto-maximize false
killall phoc || true
WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 phoc --exec "bash -lc '/usr/libexec/phosh --unlocked & wayvnc -g 127.0.0.1 7050'"
```
