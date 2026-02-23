ARG DRIVERLESS
ARG HOME

# Base image with CUDA support
FROM nvidia/cuda:12.3.0-devel-ubuntu22.04
ENV DEBIAN_FRONTEND=noninteractive
# Install ROS 2 Humble dependencies
RUN apt update && apt install -y \
    curl \
    gnupg2 \
    build-essential \
    cmake \
    git \
    wget \
    python3-pip \
    libxext6 \
    libxrender1 \
    libsm6 \
    locales \
    vim \
    tmux \
    gdb \
    && locale-gen en_US.UTF-8


# ==== INSTALL ROS HUMBLE ====
RUN apt -y install software-properties-common && add-apt-repository universe

RUN apt update && apt install curl -y

RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt update && apt install -y ros-humble-desktop

RUN python3 -m pip install colcon-common-extensions

RUN apt update && apt install -y \
  python3-flake8-docstrings \
  python3-pip \
  python3-pytest-cov \
  ros-dev-tools

RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc

# ==== NVIDIA OpenGL / GLVND + Headless Xorg ====
# NOTE: Do NOT install xserver-xorg-video-nvidia here; it can mismatch the host driver.
# The NVIDIA container runtime injects the correct user-space libs.
RUN apt update && apt install -y \
    libgl1-mesa-glx \
    libglvnd0 \
    libglx0 \
    libegl1 \
    libgles2 \
    libgl1 \
    xauth \
    xorg \
    xserver-xorg-core \
    x11-utils \
    xvfb \
    mesa-utils \
    && rm -rf /var/lib/apt/lists/*


# ==== SET UP WORKING DIRECTORY ====
WORKDIR /root/driverless/

# ==== SET UP LIBRARIES ====

RUN apt update && apt -y install libglm-dev
RUN apt update && apt -y install libgsl-dev

# ==== SET UP LINUXCAN ====

RUN mkdir /root/canUsbKvaserTesting/
RUN mkdir /root/canUsbKvaserTesting/linuxcan/


# ==== SET UP ENV VARIABLES ====

ENV CMAKE_PREFIX_PATH="/root/driverless/driverless_ws/install/controls:/root/driverless/driverless_ws/install/interfaces"
ENV AMENT_PREFIX_PATH="/root/driverless/driverless_ws/install/controls:/root/driverless/driverless_ws/install/interfaces:/opt/ros/humble"

ENV LINUXCAN_PATH="/root/canUsbKvaserTesting/linuxcan"
ENV DRIVERLESS="/root/driverless/"
ENV CONTROLLER_CONFIGS="/root/driverless/driverless_ws/src/controls/configs/controller"
ENV CONTROLS_SIM_CONFIGS="/root/driverless/driverless_ws/src/controls/configs/simulator"
RUN echo "export LD_LIBRARY_PATH=$LINUXCAN_PATH/canlib:$LD_LIBRARY_PATH" >> /root/.bashrc
ENV ROS_LOG_DIR=/root/driverless/logs/

# ==== USEFUL ALIASES ====

RUN echo "alias dv_src=\"source /root/driverless/driverless_ws/install/setup.bash\"" >> /root/.bashrc

# ==== HARNESS ADDITIONS ====
WORKDIR /root/harness
COPY requirements.txt /root/harness/requirements.txt
RUN python3 -m pip install --no-cache-dir -r /root/harness/requirements.txt
COPY run_harness.py /root/harness/run_harness.py
COPY harness_runs.example.yaml /root/harness/harness_runs.example.yaml

CMD ["bash"]
