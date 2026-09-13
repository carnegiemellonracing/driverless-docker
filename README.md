# ATTENTION, THIS REPO IS NOW DEPRECATED
newest setup information can be found at https://github.com/carnegiemellonracing/driverless/tree/main/docker!



# Carnegie Mellon Racing Driverless Docker Environment Setup

Learn more about CMR [here](https://docs.cmr.red/). If you don't have access, message @Arya on Slack!

> [!NOTE]
> If you have issues in any step of the following procedure, please check [issues that have already been solved](https://github.com/carnegiemellonracing/driverless-docker/issues?q=is%3Aissue)

## Table of Contents

- [What is Docker / Why do we use it?](#what-is-docker--why-do-we-use-it)
- [Prerequisites](#prerequisites)
- [To clone the repository](#to-clone-the-repository)
- [To build / run the Docker container](#to-build--run-the-docker-container)
  - [Without SLAM Package](#without-slam-package)
  - [With ML-Dev Container](#with-ml-dev-container)
  - [With SLAM Package](#with-slam-package)
- [To run scripts from the container (attach interactive shell to container)](#to-run-scripts-from-the-container-attach-interactive-shell-to-container)
- [To rebuild the Docker container](#to-rebuild-the-docker-container)
- [Visualization](#visualization)

## What is Docker / Why do we use it?

Check out [this](https://docs.google.com/presentation/d/1i58fbb-e5uO1mVOff-ncIiogv28kOKN-KCW4cd_dVA8/edit?usp=sharing) google slide deck for more info (need access to CMR GDrive)

>[!NOTE]
><details>
><summary> Click me to see more! </summary>
>
>Docker is a way to manage "containers" of software. These "containers" are simply a set of packages and files (could be as simple as a single executable or as complex as an operating system with a Python and c++ installation and various files and programs).
>
>It allows you to quickly get started working with Git, ROS2, CMR Pipelines, etc… Don't have to worry about installing and fixing all of the dependencies!
>
>Essentially, we use Docker for a few reasons:
>
>  - Standard development environment
>  - Packages, OS, etc… allows us to run our codebase under a set of “standard conditions”
>  - GitHub Repository (our codebase)
> - Convenience
>  - **You can start a container on your laptop, a random PC, or any other device and have access to the versions, packages, etc… that you need!**
>
></details>

## Prerequisites:

install docker for your machine.
[Docker desktop](https://docs.docker.com/desktop/) recommended, as it has multiple useful tools (e.g., GUI, docker compose, etc...)

>[!NOTE]
> WINDOWS
><details>
><summary>On Windows if Docker Desktop says your machine lacks "virtualization support" you may need to turn on windows virtualization features.</summary>
>
> 1. `win + R`
> 2. `optionalfeatures` + ENTER
> 3. check `Virtual Machine Platform` , `Windows Subsystem for Linux` ,  `Windows Hypervisor???`
> after this you may also have to install Windows Subsystem for Linux 2 (WSL2), but Docker will supply the correct command if necessary.
></details>

install Git and the GitHub CLI for your machine.

>[!NOTE]
> Windows users, make sure to install in a powershell with administrator access. Winget is a useful tool:
>
> 1. ```winget install --id Git.Git -e --source winget```
> 2. ```winget install --id GitHub.cli```
>
> For MacOS homebrew (`brew`) works nicely

> [!WARNING]
> There are a few potential pitfalls when installing docker desktop. This list below is not comprehensive, but we will aim to update it as new issues/solutions are found:
>
> 1. For Linux Users, ensure that you add your user to the docker group at the end of setup (see [docker guide](https://docs.docker.com/engine/install/linux-postinstall/)). This will ensure you're running the container with the correct permissions! (see [issue](https://github.com/carnegiemellonracing/driverless-docker/issues/4))
> 2. For MacOS users ensure rosetta setting in docker desktop is unchecked (see [issue](https://github.com/carnegiemellonracing/driverless-docker/issues/1))
> 3. For Windows users using rosbags with WSL can sometimes result in painfully slow playback due to serialization / deserialization delays from the C drive to WSL live. see https://github.com/carnegiemellonracing/driverless-docker/issues/12 for more, but the solution is often to change the rosbag mount to your WSL filesystem

it is also recommended to install Visual Studio Code (VSCode) along with the Dev Containers extension to work with the docker container

>[!NOTE]
><details>
><summary>Orbstack For Mac Users</summary>
> If you have a Mac, it is highly recommended you install orbstack since it uses far less resources than Docker Desktop. Orbstack is a lightweight alternative to the docker VM and allows for native integration with the docker CLI.
>
> - To install: [https://docs.orbstack.dev/quick-start](https://docs.orbstack.dev/quick-start)
> - More information about orbstack: [https://docs.orbstack.dev/](https://docs.orbstack.dev/)
></details>

## To clone the repository:

```bash
git clone https://github.com/carnegiemellonracing/driverless-docker.git
```

## To build / run the Docker container:

#### Base Installation
*without ML-Dev or SLAM Packages*

```bash
cd driverless-docker
docker compose up
```

*Once docker compose up has finished (no longer printing to terminal):*

Open another terminal and run the following:

```bash
docker exec -it driverless-docker-26x-1 /bin/bash
bash /start.sh # this helps you set up github authentication and installs the driverless repo!
```

> [!NOTE]
> run `docker compose up -d` if you want to run the node in detached mode in the background. You can always turn it off from docker desktop, VSCode, or the CLI.



#### With ML-Dev Container

<details>
<summary>Running with ML Development container</summary>
```bash
cd driverless docker
docker compose --profile ml-dev up
```

> [!TIP]
> If it doesn't work immediately, try running the compose command with the additional --build flag.
>
> `bash docker compose --profile ml-dev up --build`

</details>

#### With SLAM Package

> [!WARNING]
> This can add 1+ hrs to the container build time. Only proceed if you need to run path planning modules.

<details>
<summary>Running With SLAM Packages</summary>

1. Using your choice of text editor, open the Dockerfile located in the folder `docker/26x`
2. Uncomment out the following [line](https://github.com/carnegiemellonracing/driverless-docker/blob/main/docker/26x/Dockerfile#L9)

```ruby [comment]: <> (this is just for color LOL)
9 RUN --mount=type=secret,id=github_pat /setup.sh -p  
```

3. Comment out the following [line](https://github.com/carnegiemellonracing/driverless-docker/blob/main/docker/26x/Dockerfile#L12)

```ruby
12 # RUN --mount=type=secret,id=github_pat /setup.sh
```

<br />

```bash
cd driverless-docker
docker compose up
```
</details>


## To run scripts from the container (attach interactive shell to container)

>[!IMPORTANT]
>This will create an interactive terminal and source the configuration script (.bashrc) via /bin/bash. The previous command is to be run on a terminal on your laptop and will give you access to the container. Once you're in, you only need this command again if you're trying to setup another terminal.

```bash
docker exec -it driverless-docker-26x-1 /bin/bash
```

> [!NOTE]
> Install the [dev-containers VSCode extension](https://code.visualstudio.com/docs/devcontainers/tutorial) to directly attach your VSCode front end to the docker container!

## Authentication within Docker

_Once Docker is setup and you are in, you may need to authenticate your GitHub account to retain write perms. This is easily done using the GitHub cli_

```bash
# within the docker container
root@<123123123> gh auth login
```

- select the HTTPS option and follow the prompts to authenticate via the weblink

## To rebuild the Docker container:

> [!NOTE]
> This is only required if you make a change in the `Dockerfile` or the `docker-compose.yaml`

```bash
docker compose up --build
```

## Rosbags

Now that you have the basic development environment setup, how do you start messing with our pipeline?
One of the easiest and best is to build our packages and run on some fake simulation data!

> [!NOTE]
> #### What is a Rosbag? 
> ros2 bag is a command line tool for recording data published on topics in your system. It accumulates the data passed on any number of topics and saves it in a database. You can then replay the data to reproduce the results of your tests and experiments. Recording topics is also a great way to share your work and allow others to recreate it. - ROS2 Docs
> #### How do I find CMR Rosbags so I can run them?
> This year (27x) we will be storing all of our data on the Foxglove Data Platform in our [CMR Foxglove workspace](https://app.foxglove.dev/carnegie-mellon-racing-2/p/prj_0dhz9E7X44ere86g/dashboard). From there you can export/download any data collected from our lot or track tests, as well as (hopefully soon) simulation data as well! If you don't have access to Foxglove, please DM @Arya on slack your andrewID and he can add you! [Foxglove Docs for more](https://docs.foxglove.dev/docs/data)
>
> We also have a collection of starter Rosbags from previous years with LiDAR data at the link below. You can download the files and paste them into <path_to_driverless_docker>/rosbags/ to have access in the Docker container. This can be done while the container is running :)
[CMR Gdrive link](https://drive.google.com/drive/u/0/folders/1oQVOXSc57-ql6duEqETDdyR1RkJkRvlT)

## Visualization

See the [visualization tutorial here](RUN_ROSBAGS.md)

