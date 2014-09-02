---
title: OpenTOSCA Ecosystem v1.1
layout: index
---

# OpenTOSCA Ecosystem v1.1

## Documentation
* [OpenTOSCA Documentation, Publications, Videos, Presentations](http://www.opentosca.org)

## Installation

### Automated installation

Run this command and some minutes later you've a running OpenTOSCA instance (tested for Ubuntu).

#### Amazon EC2
Short version: `wget -qO- http://install.opentosca.org/installEC2 | sh`

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
  1. Run `wget -qO- http://install.opentosca.org/installEC2 | sh`
  1. Wait for ~10 min
  1. Open the URL http://<publicDNS>:8080/ in your browser

#### OpenStack
Short version: `wget -qO- http://install.opentosca.org/installOpenStack | sh`

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
  1. Run `wget -qO- http://install.opentosca.org/installOpenStack | sh`
  1. Wait for ~10 min
  1. Open the URL http://<publicDNS>:8080/ in your browser

#### Generic Script
Short version: `wget -qO- http://install.opentosca.org/install | sh`

1. Run this command and some minutes later you've a running OpenTOSCA instance. Tested for Ubuntu 12.04 LTS.
1. After the installation and start up completed (~10min): Open the URL http://<YOUR-HOST>:8080/ in your browser

#### Remarks

* If OpenTOSCA runs (in its default configuration) on a virtual machine, you need to configure the firewall so at least ports 22 (SSH), 1337 (OSGi running OpenTOSCA container), 8080 (Tomcat), 9443 and 9763 (Business Process Server) are open!
* The Amazon and OpenStack scripts basically do the same as the generic script, but some EC2/OpenStack specific changes are required.
For example, the external DNS name of the instance must be configured into WSO2 BPS, because otherwise it uses the IP of the machine which is only accessible from within the EC2 network.

### Amazon CloudFormation
tbd

### Manual installation
tbd


## Repositories

* [OpenTOSCA container - TOSCA runtime](https://github.com/OpenTOSCA/container)
* [Vinothek - OpenTOSCA self-service portal](https://github.com/OpenTOSCA/vinothek)

## Known Major Issues

* OpenTOSCA Container
 * Supports imperative CSAR processing only
 * Restart of container not possible
 * The Partner Link role of the Build & Management Plans must be named “client”.