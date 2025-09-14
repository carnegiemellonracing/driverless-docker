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
