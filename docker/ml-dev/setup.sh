#!/bin/bash
set -e

apt-get update && apt-get install -y --no-install-recommends \
  git \
  vim \
  && rm -rf /var/lib/apt/lists/*

echo "Installing packages"
pip install --no-cache-dir -r ml_requirements.txt

echo "Clone YOLO project repository"
# git clone .... /root/yolo_project

echo "ML Environment Setup Complete"