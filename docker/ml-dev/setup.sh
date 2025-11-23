#!/bin/bash
set -e

apt install -y git gh vim curl

echo "Clone YOLO project repository"
git clone https://github.com/carnegiemellonracing/driverless-ml-dev.git /root/driverless-ml-dev


echo "ML Environment Setup Complete"
