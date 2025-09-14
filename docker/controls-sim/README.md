### Setup
This is a way to run the controls workflow locally, assuming you have a GPU.

This docker image containerizes the repo and allows GPU passthrough.

Unfortunately, I was not able to get CAN and DRIVERLESS to be copied into the image through the context, so the only requirement (apart from the GPU) is that **can** and driverless_ws named **tmp_driverless_ws** is within this same folder.

You need the following installed:

---------
[CANLib](https://kvaser.com/linux-drivers-and-sdk/)

carnegiemellonracing/driverless repository

carnegiemellonracing/driverless-docker repository

----------

Afterwards, set the following variables in your .{bash/zsh}rc:

$LINUXCAN, $DRIVERLESS, $DRIVERLESS_DOCKER

to the root directories of those respective folders that you've downloaded / pulled.

Finally, run the build.sh script followed by the spin_up.sh script.


### Spinning Up

From driverless-docker/docker/controls-sim, run:

$ sh spin_up.sh

This will place you inside the docker's bash.

Next, run

$ cd ../canUsbKvaserTesting/linuxcan

$ make

$ cd ../../driverless/driverless_ws/

$ ./build_controls.py

This will run. Some warnings may arise, but this is completely fine.

Next, run the following:

$ tmux

Then do <ctrl+b "> so that you can open a new pane right below the current one. You can use <ctrl+b _down arrow_> or <ctrl+b _up arrow_> to move around.

In each terminal, run the following:

$ dv_src

$ vim src/controls/src/nodes/configs/controls_default_config

Edit display_on to true.

Finally, in one window run

$ ros2 run controls controller

In the other, run

$ ros2 run controls controls_test_node

Order does not matter.
