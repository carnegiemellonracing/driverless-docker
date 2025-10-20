#!/bin/bash
set -e

apt install -y git gh vim python3-pip tmux curl
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~.git-completion.bash

echo "Clone YOLO project repository"
git clone https://github.com/carnegiemellonracing/driverless-ml-dev.git /root/driverless-ml-dev


echo "ML Environment Setup Complete"
