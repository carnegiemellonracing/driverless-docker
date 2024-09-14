# driverless-docker

Note: Windows users please use WSL (Windows Subsystem for Linux)

## Prerequisites:
Docker

## To clone the repository:
`git clone https://github.com/carnegiemellonracing/driverless-docker.git`

## To build the Docker container:
`cd driverless-docker` <br>
`docker pull ubuntu:22.04`
`sudo docker build -t driverless-image .`

## To run the Docker container:
`sudo docker run -it driverless-image bash`

## To run the Docker container with visualization (Linux):
`sudo docker run -it --env="DISPLAY" --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" driverless-image bash`

## To run the Docker container with visualization (Mac):
1. Install XQuartz from https://www.xquartz.org
2. `open -a XQuartz`
3. Go to settings with `CTRL + ,` or from menu bar and ensure the Security tab looks as below
![alt text]/securitySettings.jpg
4. Restart your Mac
5. `open -a XQuartz`
6. xhost +localhost
7. docker run -it -e DISPLAY=docker.for.mac.host.internal:0 driverless-image bash
