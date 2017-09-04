---
layout: default
---
# OpenTOSCA Ecosystem

Version v2.0.0 is the current stable version of the OpenTOSCA ecosystem.

## Table of Contents

<!-- toc -->

- [Installation](#installation)
  * [General Remarks](#general-remarks)
  * [Automated Installation](#automated-installation)
    + [Overview](#overview)
    + [Ubuntu](#ubuntu)
    + [Amazon EC2](#amazon-ec2)
    + [OpenStack](#openstack)
  * [Docker](#docker)
  * [Amazon CloudFormation](#amazon-cloudformation)
- [Repositories](#repositories)
- [Known Major Issues](#known-major-issues)
- [Contact](#contact)
- [Documentation](#documentation)

<!-- tocstop -->

## Installation

### General Remarks

* If OpenTOSCA runs (in its default configuration) on a virtual machine, you need to configure the firewall so at least ports `22` (SSH), `1337` (OpenTOSCA Container), `8080` (Tomcat), `9443` and `9763` (Business Process Server) are open.
* The Amazon and OpenStack scripts basically do the same as the generic script, but some EC2/OpenStack specific changes are required.
  For example, the external DNS name of the instance must be configured into WSO2 BPS, because otherwise it uses the IP of the machine which is only accessible from within the EC2 network.


### Automated Installation

Run this command and some minutes later you have a running OpenTOSCA environment (tested for Ubuntu).

#### Overview

The OpenTOSCA environment can be set-up automatically by following the installation instructions below.
The setup has three major components that are installed as **systemd services** on the system.

| Component | Service Name | Service File | Init Script |
|:------------------- |:--- |:------ |:------ |
| OpenTOSCA Container | `opentosca-container` | `opentosca-container.service` | `start-container.sh` |
| WSO2 BPS Server | `opentosca-wso2bps` | `opentosca-wso2bps.service` | `start-wso2bps.sh` |
| Apache Tomcat Sever | `tomcat8` | - | - |
{: class="table table-bordered table-striped table-condensed"}

**Note:** All the services are configured to restart automatically on system reboot.

Although the services are automatically started, the following commands can be used to manually start, stop and monitor the services:

| Action | Command |
|:------ |:------- |
| Start | `sudo systemctl start opentosca-container | opentosca-wso2bps | tomcat8` |
| Stop | `sudo systemctl stop opentosca-container | opentosca-wso2bps | tomcat8` |
| Monitor| `sudo systemctl status opentosca-container | opentosca-wso2bps | tomcat8` |

Once the installation is complete, you can access the components using the following URLs:

| OpenTOSCA Component |	URL |
|:------------------- |:--- |
| OpenTOSCA UI | `http://<HOST_NAME>:8080` |
| OpenTOSCA Modelling (Eclipse Winery™) | `https://<HOST_NAME>:8080/winery-ui` |
| OpenTOSCA Container API | `http://<HOST_NAME>:1337` |
| OpenTOSCA Container Repository| `http://<HOST_NAME>:8080/container-repository` |
| Plan Engine (WSO2 BPS)| `http://<HOST_NAME>:9763` (user: `admin`, password: `admin`) |
| IA Engine (Apache Tomcat) | `http://localhost:8080/manager` (user: `admin`, password: `admin`) |


#### Ubuntu

- **v2.0.0, STABLE, Ubuntu 16.04, 64bit**: Short version: `wget -qO- http://install.opentosca.org/install | sh`
  - With KVM Hypervisor Install: `wget -qO- http://install.opentosca.org/installKVM | sh`
- **v1.1, STABLE, Ubuntu 12.04**: Short version: `wget -qO- https://raw.githubusercontent.com/OpenTOSCA/install.opentosca.org/v1.1/install | sh`
- **testing, UNSTABLE, Ubuntu 16.04, 64bit**: Short version: `wget -qO- http://install.opentosca.org/latest | sh`

We recommend 2 CPUs, 6 GB of RAM, 100 GB hard disk space.

Step by step:

1. Run `wget -qO- http://install.opentosca.org/install | sh`
1. After the installation and start up completed (~10min), you've a running OpenTOSCA instance
1. Open `http://<HOST>:8080`


#### Amazon EC2

- **v2.0.0, STABLE, Ubuntu 16.04, 64bit**: Short version: `wget -qO- http://install.opentosca.org/installEC2 | sh`
- **v1.1**: Short version: `wget -qO- https://raw.githubusercontent.com/OpenTOSCA/install.opentosca.org/v1.1/installEC2 | sh`

Step by step:

1. Create Security group (same region as the EC2 instance!) with at least TCP ports 22, 1337, 8080, 9443 and 9763 open
1. Create Key Pair
    1. Open: https://console.aws.amazon.com/ec2
    1. Select AWS region in top right
    1. Click “Key Pairs” in the menu on the bottom left
    1. Click Create Key Pair
    1. Provide a KeyName
    1. Store key to your local machine (If you want to connect via SSH to the machine OpenTOSCA is installed on, you will need this key.)
1. Create EC2 instance
    1. Key: Select key created before
    1. AMI: Ubuntu Server 12.04.2 LTS 64bit (AMI id for your region: http://cloud-images.ubuntu.com/locator/ec2/)
    1. Size: m1.medium or larger
    1. Security Group: Select security group created before
    1. Connect to the instance using SSH
    1. [v1.1, STABLE] Run `wget -qO-  https://raw.githubusercontent.com/OpenTOSCA/install.opentosca.org/v1.1/installEC2 | sh`
	1. [testing, UNSTABLE] Run `wget -qO- http://install.opentosca.org/installEC2 | sh`
    1. Wait for ~10 min
    1. Open `http://<publicDNS>:8080/`


#### OpenStack

- **v2.0.0, STABLE, Ubuntu 16.04, 64bit**: Short version: `wget -qO- http://install.opentosca.org/installOpenStack | sh`
- **v1.1**: Short version: `wget -qO- https://raw.githubusercontent.com/OpenTOSCA/install.opentosca.org/v1.1/installOpenStack | sh`

Step by step:

1. Create Security group with at least TCP ports 22, 1337, 8080, 9443 and 9763 open
1. Create Keypair
1. Launch Instance
    1. Flavor: m1.medium or larger
    1. Instance Boot Source: Boot from image
    1. Image Name: Ubuntu Server 12.04 or 13.04
    1. Access & Security Tab: Select keypair and security group created before
    1. Assign floating IP to instance
    1. Connect to the instance using SSH
    1. [v1.1, STABLE] Run `wget -qO-  https://raw.githubusercontent.com/OpenTOSCA/install.opentosca.org/v1.1/installOpenStack | sh`
	1. [testing, UNSTABLE] Run `wget -qO- http://install.opentosca.org/installOpenStack | sh`
    1. Wait for ~10 min
    1. Open `http://<publicDNS>:8080/`


### Docker

The following steps will help you set-up a dockerized environment for OpenTOSCA.
Beside of this installation script, there is a Docker Compose configuration available at <https://github.com/OpenTOSCA/opentosca-docker> that can be used to set up a pure development environment.

- **testing, UNSTABLE, Ubuntu 16.04, 64bit**: Short version: `wget -qO- http://install.opentosca.org/install-opentosca-docker | sh`

Wait a few seconds, then open the [OpenTOSCA user interface](http://localhost:8088).

| OpenTOSCA Component | URL | GitHub | Docker Hub |
|:------------------- |:--- |:------ |:---------- |
| OpenTOSCA UI | `http://<HOST_NAME>:8088` | [Link](https://github.com/OpenTOSCA/ui) | [Link](https://hub.docker.com/r/opentosca/ui) |
| OpenTOSCA Modelling (Eclipse Winery™) | `http://<HOST_NAME>:8080` | [Link](https://github.com/OpenTOSCA/winery) | [Link](https://hub.docker.com/r/opentosca/winery) |
| OpenTOSCA Container API | `http://<HOST_NAME>:1337` | [Link](https://github.com/OpenTOSCA/container) | [Link](https://hub.docker.com/r/opentosca/container) |
| OpenTOSCA Container Repository | `http://<HOST_NAME>:8081` | [Link](https://github.com/OpenTOSCA/winery) | [Link](https://hub.docker.com/r/opentosca/winery) |
| Plan Engine (WSO2 BPS) | `http://<HOST_NAME>:9763`<br>(user: `admin`, password: `admin`) | [Link](https://github.com/OpenTOSCA/engine-plan) | [Link](https://hub.docker.com/r/opentosca/engine-plan) |
| IA Engine (Apache Tomcat) | `http://<HOST_NAME>:8090/manager`<br>(user: `admin`, password: `admin`) | [Link](https://github.com/OpenTOSCA/engine-ia) | [Link](https://hub.docker.com/r/opentosca/engine-ia) |

You can check the status of the different containers by using the _Portainer_ Management UI at <http://HOST_NAME:9000>.


### Amazon CloudFormation

* **testing** Short version: [CloudFormation Template](http://install.opentosca.org/cloudformation.template)

Step by step:

1. Open https://console.aws.amazon.com/cloudformation
1. Create a new stack in region of your choice
1. Select “Upload a Template File” and upload this template: http://install.opentosca.org/cloudformation.template
1. Input
    1. KeyName
        1. Name of the EC2 Key Pair to access the created instance
        1. Step 2 of the automated installation on Amazon EC2 shows how to create a new key pair
    1. InstanceType
        1. Default is `m1.medium`
        1. Smaller instance types don’t work! (not enough memory)
1. Create Stack


## Repositories

The OpenTOSCA eco system is open source and actively developed on GitHub. Please head to our <https://github.com/opentosca/>.

Our main components are:

* OpenTOSCA UI - UI for the OpenTOSCA Runtime: https://github.com/OpenTOSCA/ui
* OpenTOSCA Container - an open-source, TOSCA-compliant runtime: https://github.com/OpenTOSCA/container
* OpenTOSCA Modelling Tool (Eclipse Winery™): https://github.com/OpenTOSCA/winery


## Contact

If you need support, contact us at <opentosca@iaas.uni-stuttgart.de>.


## Documentation

* [OpenTOSCA Documentation, Publications, Videos, Presentations](http://www.opentosca.org)
