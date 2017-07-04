---
layout: default
---
# OpenTOSCA Ecosystem

Version v2.0.0 is the current stable version of the OpenTOSCA ecosystem.

Besides these installation scripts, we offer a dockerized OpenTOSCA environment at <https://github.com/OpenTOSCA/opentosca-dockerfiles>.
That environment builds the latest versions from source.
This script here uses builds from <http://builds.opentosca.org/>.

## Table of Contents

<!-- toc -->

- [Installation](#installation)
  * [General Remarks](#general-remarks)
  * [Automated installation](#automated-installation)
    + [Generic Script](#generic-script)
    + [Amazon EC2](#amazon-ec2)
    + [OpenStack](#openstack)
  * [Amazon CloudFormation](#amazon-cloudformation)
- [Repositories](#repositories)
- [Known Major Issues](#known-major-issues)
- [Contact](#contact)
- [Documentation](#documentation)

<!-- tocstop -->

## Installation

### General Remarks

* If OpenTOSCA runs (in its default configuration) on a virtual machine, you need to configure the firewall so at least ports 22 (SSH), 1337 (OSGi running OpenTOSCA container), 8080 (Tomcat), 9443 and 9763 (Business Process Server) are open!
* The Amazon and OpenStack scripts basically do the same as the generic script, but some EC2/OpenStack specific changes are required.
  For example, the external DNS name of the instance must be configured into WSO2 BPS, because otherwise it uses the IP of the machine which is only accessible from within the EC2 network.


### Automated installation

Run this command and some minutes later you've a running OpenTOSCA instance (tested for Ubuntu).


#### Generic Script

- **v2.0.0, STABLE, Ubuntu 16.04, 64bit**: Short version: `wget -qO- http://install.opentosca.org/install | sh`
  - With KVM Hypervisor Install: `wget -qO- http://install.opentosca.org/installKVM | sh`
- **v1.1, STABLE, Ubuntu 12.04**: Short version: `wget -qO- https://raw.githubusercontent.com/OpenTOSCA/install.opentosca.org/v1.1/install | sh`
- **testing, UNSTABLE, Ubuntu 16.04, 64bit**: Short version: `wget -qO- http://install.opentosca.org/latest | sh`

We recommend 2 CPUs, 6 GB of RAM, 100 GB hard disk space.

Step by step:

1. Run `wget -qO- http://install.opentosca.org/install | sh`
1. After the installation and start up completed (~10min), you've a running OpenTOSCA instance
1. Open `http://<HOST>:8080/`


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

* OpenTOSCA container - TOSCA runtime: https://github.com/OpenTOSCA/container
* OpenTOSCA UI - the new UI for the container: https://github.com/OpenTOSCA/ui
* <s>Vinothek - OpenTOSCA self-service portal: https://github.com/OpenTOSCA/vinothek</s> - replaced by OpenTOSCA UI
* <s>Landing page of OpenTOSCA container: https://github.com/OpenTOSCA/ui-root</s> - replaced by OpenTOSCA UI
* <s>Admin Page of OpenTOSCA container: https://github.com/OpenTOSCA/ui-admin</s> - replaced by OpenTOSCA UI
* Winery: https://github.com/eclipse/winery


## Known Major Issues

* OpenTOSCA Container
    * Restart of container not possible
    * The Partner Link role of the Build & Management Plans must be named “client”.

## Contact

If you need support, contact us at <opentosca@iaas.uni-stuttgart.de>.

## Documentation

* [OpenTOSCA Documentation, Publications, Videos, Presentations](http://www.opentosca.org)
