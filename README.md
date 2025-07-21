# driverless-docker

## Prerequisites:
install docker for your machine.
[Docker desktop](https://docs.docker.com/desktop/) recommended, as it has multiple useful tools (e.g., GUI, docker compose, etc...)

## To clone the repository:
```bash
git clone https://github.com/carnegiemellonracing/driverless-docker.git
```

## To build / run the Docker container:
```bash
cd driverless-docker
docker compose up
```

## To run scripts from the container (attach interactive shell to container)
```bash
docker exec -it driverless-docker-26x-1 /bin/bash
```

- Note: Would also run with dev-containers extension with vscode

## To rebuild the Docker container:
```bash 
docker compose up --build
```

## Visualization

### Foxglove
1. Open a terminal and attach to container. Run:

    ```bash 
    ros2 run foxglove_bridge foxglove_bridge
    ```
2. In a browser of your choice, go to (app.foxglove.dev)[app.foxglove.dev] and make and account / sign in
3. Open a new connnection to ws://localhost:8765
4. Do stuff!

![Foxglove Viz](Images/foxglove.png "Visualizing lidar data in Foxglove")

### RVIZ / RQT_GRAPH / Desktop-related stuff, e.g., matplotlib...
1. open a tab in your browser of choice at localhost:8080
Click on `vnc.html`
    - This opens an Ubuntu desktop
2. when you run commands with viz, such as `rviz2`, `rqt_graph`, `foxglove`, etc... it will show up in the desktop instance running in the browser tab

![RVIZ Viz](Images/rviz.png "Visualizing lidar data in RVIZ2")
