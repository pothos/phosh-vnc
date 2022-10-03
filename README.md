# Phosh Container with VNC Server

A graphical GNOME Phosh user session in a container, accessible via VNC and using software rendering.

Note that GNOME Shell has also has desktop sharing via RDP and VNC but here Phosh is used due to it being a bit more lightweight.

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

## TODO

Document Docker usage (maybe `--tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro`)