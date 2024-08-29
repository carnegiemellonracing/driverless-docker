# driverless-docker

## Prerequisites:
1. Docker

## To clone the repository:
`git clone <link-to-repo>`

## To build the Docker container:
`cd driverless-docker`
`sudo docker build -t driverless-image .`

## To run the Docker container:
`sudo docker run -it driverless-image bash`

## To run the Docker container with visualization (Linux):
`sudo docker run -it --env="DISPLAY" --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" driverless-image bash`
