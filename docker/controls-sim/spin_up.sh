#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${LIBS:-}" || -z "${DRIVERLESS:-}" ]]; then
  echo "LIBS and DRIVERLESS must be set before running this script."
  exit 1
fi

XDG_RUNTIME_DIR_CONTAINER=/tmp/xdg-runtime

docker_args=(
  run --rm -it
  --gpus all
  --privileged
  --cap-add=SYS_ADMIN
  --cap-add=SYS_RAWIO
  --cap-add=SYS_TTY_CONFIG
  --security-opt seccomp=unconfined
  -v "${LIBS}/canUsbKvaserTesting/linuxcan:/root/canUsbKvaserTesting/linuxcan"
  -v "${DRIVERLESS}/:/root/driverless/"
  -e "XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR_CONTAINER}"
  -e "NVIDIA_DRIVER_CAPABILITIES=all"
  -e "__GLX_VENDOR_LIBRARY_NAME=nvidia"
)

for device in /dev/dri /dev/nvidiactl /dev/nvidia-uvm /dev/nvidia-modeset /dev/nvidia0; do
  if [[ -e "${device}" ]]; then
    docker_args+=(--device "${device}")
  fi
done

if [[ -n "${DISPLAY:-}" && -d /tmp/.X11-unix ]]; then
  if command -v xhost >/dev/null 2>&1; then
    xhost +local:root >/dev/null 2>&1 || true
  fi

  docker_args+=(
    -v /tmp/.X11-unix:/tmp/.X11-unix
    -e "DISPLAY=${DISPLAY}"
    -e SDL_VIDEODRIVER=x11
  )

  if [[ -n "${XAUTHORITY:-}" && -f "${XAUTHORITY}" ]]; then
    docker_args+=(-v "${XAUTHORITY}:/root/.Xauthority:ro" -e XAUTHORITY=/root/.Xauthority)
  elif [[ -f "${HOME}/.Xauthority" ]]; then
    docker_args+=(-v "${HOME}/.Xauthority:/root/.Xauthority:ro" -e XAUTHORITY=/root/.Xauthority)
  fi

  echo "Using host X11 display (${DISPLAY})."
  exec sudo docker "${docker_args[@]}" controls-sim bash
fi

echo "No host X11 display detected. Starting Xvfb on :99 inside the container."
exec sudo docker "${docker_args[@]}" controls-sim bash -lc '
  set -euo pipefail
  mkdir -p /tmp/xdg-runtime
  chmod 700 /tmp/xdg-runtime

  Xvfb :99 -screen 0 1280x720x24 -ac +extension GLX +render -noreset >/tmp/Xvfb.99.log 2>&1 &
  sleep 1

  if ! xdpyinfo -display :99 >/dev/null 2>&1; then
    echo "Xvfb failed to start. /tmp/Xvfb.99.log:"
    cat /tmp/Xvfb.99.log
    exit 1
  fi

  export DISPLAY=:99
  export SDL_VIDEODRIVER=x11
  exec bash
'
