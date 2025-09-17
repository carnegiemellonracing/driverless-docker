# Carnegie Mellon Racing Driverless Docker Environment Setup

Learn more about CMR [here](https://cmr.red/driverless/driverless-docs/build/html/index.html).

> [!NOTE]
> If you have issues in any step of the following procedure, please check [issues that have already been solved](https://github.com/carnegiemellonracing/driverless-docker/issues?q=is%3Aissue)

## Table of Contents

- [What is Docker / Why do we use it?](#what-is-docker--why-do-we-use-it)
- [Prerequisites](#prerequisites)
- [To clone the repository](#to-clone-the-repository)
- [Git Authentication](#authentication)
  - [Generate a Personal Access Token](#generate-a-personal-access-token)
- [To build / run the Docker container](#to-build--run-the-docker-container)
  - [Without SLAM Package](#without-slam-package)
  - [With ML-Dev Container](#with-ml-dev-container)
  - [With SLAM Package](#with-slam-package)
- [To run scripts from the container (attach interactive shell to container)](#to-run-scripts-from-the-container-attach-interactive-shell-to-container)
- [To rebuild the Docker container](#to-rebuild-the-docker-container)
- [Visualization](#visualization)
  - [Foxglove](#foxglove)
  - [RVIZ / RQT_GRAPH / Desktop-related stuff, e.g., matplotlib...](#rviz--rqt_graph--desktop-related-stuff-eg-matplotlib)

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

> [!WARNING]
> There are a few potential pitfalls when installing docker desktop. This list below is not comprehensive, but we will aim to update it as new issues/solutions are found:
>
> 1. For Linux Users, ensure that you add your user to the docker group at the end of setup (see [docker guide](https://docs.docker.com/engine/install/linux-postinstall/)). This will ensure you're running the container with the correct permissions! (see [issue](https://github.com/carnegiemellonracing/driverless-docker/issues/4))
> 2. For MacOS users ensure rosetta setting in docker desktop is unchecked (see [issue](https://github.com/carnegiemellonracing/driverless-docker/issues/1))

it is also recommended to install Visual Studio Code (VSCode) along with the Dev Containers extension to work with the docker container

## To clone the repository:

```bash
git clone https://github.com/carnegiemellonracing/driverless-docker.git
```

## Authentication

_Now that CMR Driverless is a private repository we need to authenticate via [personal access tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#about-personal-access-tokens)_

#### Generate a Personal Access Token

<details>
<summary>How to generate a token</summary>

- Go to [GitHub](https://github.com/settings/tokens) (GitHub -> Settings -> Developer Settings -> Personal Access Tokens)
- You can use either Classic or Fine-Grained Tokens. _You may not have access to fine-grained tokens for the CMR organization_

> [!WARNING]
> Make sure that your token time scope is set less than 365 days. Otherwise it will not work with our CMR organization settings, and not clone the repo correctly.

  - Classic: Ensure the following are selected (add write:packages if you have access / need it)

  ![Classic Token Scopes](Images/classic_token_scopes.png "Classic Token Required Scopes")

  ![Sample Token Gen Output](Images/sample_token_output.png "Sample output token")
  _don't try this token..._

- Copy the token and export to your terminal where you cloned the driverless-docker repo as a new local variable.

</details>



> [!IMPORTANT]
> Make sure you follow the next instructions based on your OS
><details>
><summary>MACOS / LINUX</summary>
>
>```bash
># Make sure to paste your token / username instead of the >bracketed text
>export GH_PAT="<YOUR TOKEN HERE>"
>export GH_USER="<YOUR GITHUB USERNAME>"
>```
></details>
>
><details>
><summary>WINDOWS</summary>
>
>- create a folder in your `driverless-packages/` folder >with the name `.env`
>- Use a text editor such as vim, NotePad, or VSCode to add >the following two lines:
>
>```bash
>GH_PAT="<YOUR TOKEN HERE>"
>GH_USER="<YOUR GITHUB USERNAME>"
>```
>
></details>


> 
## To build / run the Docker container:

#### Base Installation
*without ML-Dev or SLAM Packages*

```bash
cd driverless-docker
docker compose up
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
> Install the dev-containers VSCode extension to directly attach your VSCode front end to the docker container!

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

We have a set of starter Rosbags with LiDAR data at the link below. You can download the files and paste them into <path_to_driverless_docker>/rosbags/ to have access in the Docker container. This can be done while the container is running :)
[CMR drive link](https://drive.google.com/drive/u/0/folders/1oQVOXSc57-ql6duEqETDdyR1RkJkRvlT)

## Visualization

See the [visualization tutorial here](RUN_ROSBAGS.md)

