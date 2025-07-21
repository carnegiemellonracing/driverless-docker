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

## To run scripts from the container (attach terminal)
```bash
docker exec -it driverless-docker-26x-1 /bin/bash
```

- Note: Would also run with dev-containers extension with vscode

## To rebuild the Docker container:
```bash 
docker compose up --build
```

## Visualization
open a tab in your browser of choice at localhost:8080
Click on `vnc.html`

- This opens an Ubuntu desktop
- when you run commands with viz, such as `rviz2`, `rqt_graph`, `foxglove`, etc... it will show up in the browser tab
