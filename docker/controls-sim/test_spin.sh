#!/bin/bash
set -e

# 1. Ensure we’re pointing at the right display on host
# (don’t override these if they’re already set correctly)

echo "Host DISPLAY=$DISPLAY"
echo "Host WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
echo "Host XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"

# 2. Allow local root (container) to talk to X *if* X11 is in play.
# Harmless even if you're mostly using Wayland.
xhost +local:root || echo "xhost failed; X11 may not be running (that's OK if we're on Wayland)"

# 3. Run container, now mounting Wayland runtime and passing env

sudo docker run --rm -it \
  --gpus all \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$LIBS/canUsbKvaserTesting/linuxcan":/root/canUsbKvaserTesting/linuxcan \
  -v "$DRIVERLESS"/:/root/driverless/ \
  -v "$HOME/.Xauthority":/root/.Xauthority:ro \
  -v "$XDG_RUNTIME_DIR":"$XDG_RUNTIME_DIR" \
  -e DISPLAY=$DISPLAY \
  -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  -e XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
  -e XAUTHORITY=/root/.Xauthority \
  -e NVIDIA_DRIVER_CAPABILITIES=all \
  --device /dev/dri \
  --cap-add=SYS_ADMIN \
  controls-sim

