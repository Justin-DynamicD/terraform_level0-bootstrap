# Landing zones on Terraform - Rover

The **nixRover** is a Docker container in charge of the deployment of the landing zones in your Azure environment.

It is acting as a **sandbox toolchain** development environment to avoid impacting the local machine but more importantly to make sure that all contributors in the GitOps teams are using a **consistent set of tools** and versions.

The rover is the same container regardless you are using Windows, Linux or macOS. On the local GitOps machine you need to install Visual Studio Code. The rover is executed locally in a container.

![container image](./documentation/img/devcontainer.png)

You can learn more about the Visual Studio Code Remote on this [link](https://code.visualstudio.com/docs/remote/remote-overview).

## Pre-requisites

The Visual Studio Code system requirements describe the steps to follow to get your GitOps development environment ready -> [link](https://code.visualstudio.com/docs/remote/containers#_system-requirements)

* **Windows**: Docker Desktop 2.0+ on Windows 10 Pro/Enterprise with Linux Container mode
* **macOS**: Docker Desktop 2.0+
* **Linux**: Docker CE/EE 18.06+ and Docker Compose 1.24+

The rover is a Ubuntu:20 base image. You can see more details on configuring the workspacer here:

[Configuring DevOps Workspace](documentation/devops_workspace.md)
