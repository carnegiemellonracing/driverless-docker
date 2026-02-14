#!/bin/bash

XDG_RUNTIME_DIR=/tmp/xdg-runtime

sudo docker run --rm -it \
  --gpus all \
  --privileged \
  --cap-add=SYS_ADMIN \
  --cap-add=SYS_RAWIO \
  --cap-add=SYS_TTY_CONFIG \
  --security-opt seccomp=unconfined \
  -v $LIBS/canUsbKvaserTesting/linuxcan:/root/canUsbKvaserTesting/linuxcan \
  -v $DRIVERLESS/:/root/driverless/ \
  -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  -e NVIDIA_DRIVER_CAPABILITIES=all \
  -e __GLX_VENDOR_LIBRARY_NAME=nvidia \
  --device /dev/dri \
  --device /dev/nvidiactl \
  --device /dev/nvidia-uvm \
  --device /dev/nvidia-modeset \
  --device /dev/nvidia0 \
  controls-sim \
  bash -lc '
    set -euo pipefail
    mkdir -p /tmp/xdg-runtime
    chmod 700 /tmp/xdg-runtime
    cat >/etc/X11/xorg.conf <<"XEOF"
Section "Device"
    Identifier  "NVIDIA GPU"
    Driver      "nvidia"
    BusID       "PCI:1:0:0"
    Option      "AllowEmptyInitialConfiguration" "True"
    Option      "UseDisplayDevice" "None"
EndSection

Section "Screen"
    Identifier "Screen0"
    Device     "NVIDIA GPU"
    DefaultDepth 24
    SubSection "Display"
        Depth 24
        Virtual 1280 720
    EndSubSection
EndSection
XEOF

    Xorg :99 -noreset -config /etc/X11/xorg.conf -logfile /tmp/Xorg.99.log &
    sleep 1
    export DISPLAY=:99
    export SDL_VIDEODRIVER=x11
    exec bash
  '
