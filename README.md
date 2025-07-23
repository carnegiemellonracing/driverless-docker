# driverless-docker

> [!NOTE]
> If you have issues in any step of the following procedure, please check [issues that have already been solved](https://github.com/carnegiemellonracing/driverless-docker/issues?q=is%3Aissue)

## Prerequisites:
install docker for your machine.
[Docker desktop](https://docs.docker.com/desktop/) recommended, as it has multiple useful tools (e.g., GUI, docker compose, etc...)

> [!WARNING]
> For MacOS users ensure rosetta setting in docker desktop is unchecked (see [issue](https://github.com/carnegiemellonracing/driverless-docker/issues/1))

it is also recommended to install Visual Studio Code (VSCode) along with the Dev Containers extension to work with the docker container

## To clone the repository:
```bash
git clone https://github.com/carnegiemellonracing/driverless-docker.git
```

## To build / run the Docker container:
#### With SLAM Package
```bash
cd driverless-docker
docker compose up
```
#### Without SLAM Package
1. Using your choice of text editor, open the Dockerfile located in the root directory of this project
2. Comment out the following [line](https://github.com/carnegiemellonracing/driverless-docker/blob/main/Dockerfile#L13)
``` ruby [comment]: <> (this is just for color LOL)
13 RUN /setup.sh -p
```
3. Uncomment out the following [lines](https://github.com/carnegiemellonracing/driverless-docker/blob/main/Dockerfile#L16-L17)
``` ruby
16 # RUN /setup.sh  
17 # COPY quaternions.py /usr/lib/python3/dist-packages/transforms3d/quaternions.py
```
<br />

```bash
cd driverless-docker
docker compose up
```

> [!NOTE]
> run `docker compose up -d` if you want to run the node in detached mode in the background. You can always turn it off from docker desktop, VSCode, or the CLI.

## To run scripts from the container (attach interactive shell to container)
```bash
docker exec -it driverless-docker-26x-1 /bin/bash
```

- Note: Would also run with dev-containers extension with vscode

## To rebuild the Docker container:

> [!NOTE]
> This is only required if you make a change in the `Dockerfile` or the `docker-compose.yaml`

```bash 
docker compose up --build
```

## Visualization

### Foxglove
1. Open a terminal and attach to container. Run:

    ```bash 
    docker exec -it driverless-docker-26x-1 /bin/bash
    ros2 run foxglove_bridge foxglove_bridge
    ```
2. In a browser of your choice, go to [app.foxglove.dev](app.foxglove.dev) and make and account / sign in
3. Open a new connnection to ws://localhost:8765
4. Do stuff!

![Foxglove Viz](Images/foxglove.png "Visualizing lidar data in Foxglove")

### RVIZ / RQT_GRAPH / Desktop-related stuff, e.g., matplotlib...
1. open a tab in your browser of choice at localhost:8080
Click on `vnc.html`
    - This opens an Ubuntu desktop
2. when you run commands with viz, such as `rviz2`, `rqt_graph`, `foxglove`, etc... it will show up in the desktop instance running in the browser tab

![RVIZ Viz](Images/rviz.png "Visualizing lidar data in RVIZ2")
