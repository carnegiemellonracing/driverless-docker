#!/bin/bash

set -e

apt update
apt install -y git vim python3-pip locales curl tmux

apt install -y ros-dev-tools ros-humble-tf-transformations libeigen3-dev libgsl-dev bc

cd ~

# Install GTSAM
apt-get install -y libboost-all-dev cmake
git clone https://github.com/borglab/gtsam.git
cd gtsam
git checkout release/4.3a0
mkdir build && cd build
cmake ..
make check -j2
make install -j2
sudo ldconfig
cd ../..

# Clone iSAM2_REPO
git clone https://github.com/carnegiemellonracing/iSAM2_SLAM.git
cd iSAM2_SLAM

# Quality of life
source /opt/ros/humble/setup.bash
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
echo "cd /root" >> ~/.bashrc
echo "alias sros='source install/setup.bash'" >> ~/.bashrc
echo "alias dv_src='source ~/driverless/driverless_ws/install/setup.bash || echo "driverless_ws likely not built. Try building with colcon build in ~/driverless/driverless_ws"'" >> ~/.bashrc

# enable command history
cat << 'EOF' >> ~/.bashrc
# Append commands to history file immediately
export PROMPT_COMMAND="history -a"

# Ensure history is appended, not overwritten
shopt -s histappend

# Optional: Configure history size
export HISTSIZE=10000 # Number of commands to remember in the history list
export HISTFILESIZE=20000 # Maximum size of the history file in lines

EOF
