#!/bin/bash
set -euo pipefail

# Ensure we build from this script's directory (Docker context)
cd "$(dirname "$0")"

# Keep this aligned with docker/controls-sim/build.sh behavior.
sudo docker build --platform linux -t harness .
