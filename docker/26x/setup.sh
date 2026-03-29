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
apt install -y git gh vim python3-pip locales curl tmux

OPENCV_CPP_VERSION=4.11.0
OPENCV_PYTHON_VERSION=4.11.0.86

# Build and install a newer system OpenCV for C++ ROS nodes.
apt install -y build-essential cmake pkg-config
apt install -y libgtk-3-dev libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
apt install -y libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev gfortran
apt install -y libatlas-base-dev libtbb2 libtbb-dev libdc1394-dev

cd /tmp
git clone --branch ${OPENCV_CPP_VERSION} --depth 1 https://github.com/opencv/opencv.git opencv
cmake -S /tmp/opencv -B /tmp/opencv/build \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=/opt/opencv-${OPENCV_CPP_VERSION} \
    -D BUILD_LIST=core,imgproc,imgcodecs,highgui,videoio,dnn,calib3d,features2d,flann \
    -D BUILD_TESTS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_opencv_python3=OFF \
    -D BUILD_JAVA=OFF
cmake --build /tmp/opencv/build -j"$(nproc)"
cmake --install /tmp/opencv/build
ln -sfn /opt/opencv-${OPENCV_CPP_VERSION} /opt/opencv-current
echo "/opt/opencv-${OPENCV_CPP_VERSION}/lib" > /etc/ld.so.conf.d/opencv-${OPENCV_CPP_VERSION}.conf
ldconfig
rm -rf /tmp/opencv

# Install a newer Python cv2 wheel for Python tooling only.
python3 -m pip install --no-cache-dir --upgrade pip
python3 -m pip uninstall -y opencv-python opencv-python-headless opencv-contrib-python || true
python3 -m pip install --no-cache-dir "opencv-python==${OPENCV_PYTHON_VERSION}"

curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~.git-completion.bash


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

apt update

apt install -y ros-dev-tools ros-humble-tf-transformations libeigen3-dev libgsl-dev

# rosbag mcap storage plugin
apt install -y ros-humble-rosbag2-storage-mcap

# Foxglove bridge (has been dropped from current ros humble apt sync)
# apt install -y ros-humble-foxglove-bridge

# build foxglove from source
mkdir -p /root/ros2_ws/src
cd /root/ros2_ws/src
if [ ! -d foxglove-sdk ]; then
    git clone https://github.com/foxglove/foxglove-sdk.git
fi
cd /root/ros2_ws
# Ensure ROS package CMake configs (including ament_cmake) are on CMAKE_PREFIX_PATH.
source /opt/ros/humble/setup.bash
rosdep install --from-paths src --ignore-src -r -y
colcon build --packages-select foxglove_bridge
source install/setup.bash

# bc for bash math (used for scripts)
apt install -y bc

cd ~

# Install GTSAM for Path Planning
if $PATH_PLANNING; then 
    apt-get install -y libboost-all-dev cmake
    git clone https://github.com/borglab/gtsam.git
    cd gtsam
    git checkout release/4.3a0
    mkdir build && cd build
    cmake ..
    make check -j$(nproc)
    make install -j$(nproc)
    sudo ldconfig
    cd ../..
fi


# Clone driverless repo
if [[ -z "${GITHUB_USERNAME}" ]]; then
    echo "Error: GITHUB_USERNAME is not set." >&2
    exit 1
fi
if [[ ! -f /run/secrets/github_pat ]]; then
    echo "Error: /run/secrets/github_pat not found." >&2
    exit 1
fi
git clone --recurse-submodules https://${GITHUB_USERNAME}:$(cat /run/secrets/github_pat)@github.com/carnegiemellonracing/driverless.git
cd driverless/driverless_ws
git remote rm origin
git remote add origin https://github.com/carnegiemellonracing/driverless.git


source /opt/ros/humble/setup.bash
echo "cd /root" >> ~/.bashrc

# enable command history
cat << 'EOF' >> ~/.bashrc
# Append commands to history file immediately
export PROMPT_COMMAND="history -a"

# Ensure history is appended, not overwritten
shopt -s histappend

# Optional: Configure history size
export HISTSIZE=10000 # Number of commands to remember in the history list
export HISTFILESIZE=20000 # Maximum size of the history file in lines

if [ -f ~/.git-completion.bash ]; then      
    . ~/.git-completion.bash
fi

EOF

# Add commands to build relevent packages
# colcon build --packages-up-to perceptions_24a_cpp
# colcon build --packages-up-to planning
