#!/bin/bash

PATH_PLANNING=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--pathplanning)
            PATH_PLANNING=true
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
    shift # Consume the current flag
done

set -e

apt update
apt install -y git vim python3-pip locales curl tmux

#------------------------------------------------->
#-----------------------OLD------------------------
#<-------------------------------------------------
# Perc 22a Library. Uncomment below lines to setup.
# cd ~
# git clone https://github.com/carnegiemellonracing/PerceptionsLibrary22a.git
# cd PerceptionsLibrary22a
# pip install -r requirements24.txt
# export PYTHONPATH="$(pwd):$PYTHONPATH"
# echo "export PYTHONPATH=\"$(pwd):$PYTHONPATH\"" >> ~/.bashrc


# Below should be taken care of by using the ros humble desktop image.
# locale-gen en_US en_US.UTF-8
# update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
# export LANG=en_US.UTF-8

# apt install -y software-properties-common
# add-apt-repository universe -y
# apt update
# debconf-set-selections <<< "tzdata tzdata/Areas select America"
# debconf-set-selections <<< "tzdata tzdata/Zones/America select New_York"
# curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
# apt update
# apt install -y ros-humble-desktop
#------------------------------------------------->
#----------------------END OLD---------------------
#<-------------------------------------------------

apt install -y ros-dev-tools ros-humble-tf-transformations libeigen3-dev libgsl-dev

# Install GTSAM for Path Planning
if $PATH_PLANNING; then 
    cd ~
    apt-get install -y libboost-all-dev cmake
    git clone https://github.com/borglab/gtsam.git
    cd gtsam
    mkdir build
    cd build
    cmake ..
    make install
fi

# Clone driverless repo
git clone --recurse-submodules https://github.com/carnegiemellonracing/driverless.git
cd driverless/driverless_ws

source /opt/ros/humble/setup.bash
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
echo "cd /root" >> ~/.bashrc

# Add commands to build relevent packages
# colcon build --packages-up-to perceptions_24a_cpp
# colcon build --packages-up-to planning
