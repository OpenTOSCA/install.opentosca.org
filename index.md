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
    1. Open `http://<publicDNS>:8080/`

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
    1. Open `http://<publicDNS>:8080/`

#### Generic Script
Short version: `wget -qO- http://install.opentosca.org/install | sh`

Step by step:

1. Run `wget -qO- http://install.opentosca.org/install | sh`
1. After the installation and start up completed (~10min), you've a running OpenTOSCA instance
1. Open `http://<HOST>:8080/`

#### Remarks

* If OpenTOSCA runs (in its default configuration) on a virtual machine, you need to configure the firewall so at least ports 22 (SSH), 1337 (OSGi running OpenTOSCA container), 8080 (Tomcat), 9443 and 9763 (Business Process Server) are open!
* The Amazon and OpenStack scripts basically do the same as the generic script, but some EC2/OpenStack specific changes are required.
For example, the external DNS name of the instance must be configured into WSO2 BPS, because otherwise it uses the IP of the machine which is only accessible from within the EC2 network.


### Amazon CloudFormation
Short version: [CloudFormation Template](http://install.opentosca.de/cloudformation.template)

Step by step:

1. Open https://console.aws.amazon.com/cloudformation
1. Create a new stack in region of your choice
1. Select “Upload a Template File” and upload this template: http://install.opentosca.de/cloudformation.template
1. Input
    1. KeyName
        1. Name of the EC2 Key Pair to access the created instance
        1. Step 2 of the automated installation on Amazon EC2 shows how to create a new key pair
    1. InstanceType
        1. Default is `m1.medium`
        1. Smaller instance types don’t work! (not enough memory)
1. Create Stack


### Manual Installation of OpenTOSCA Container

Step by step:

1. Install Java 7 and Tomcat 7.x (Packages: tomcat7 and tomcat7-admin)
1. Add `CATALINA_OPTS=\"-Xms512m -Xmx1024m\"` to file `/etc/default/tomcat7`
1. Replace [tomcat-users.xml](https://github.com/OpenTOSCA/OpenTOSCA.github.io/blob/master/third-party/tomcat-users.xml) in `/var/lib/tomcat7/conf/`
1. Copy WARs [ROOT.war](https://github.com/OpenTOSCA/OpenTOSCA.github.io/releases/download/v1.1/ROOT.war), [admin.war](https://github.com/OpenTOSCA/OpenTOSCA.github.io/releases/download/v1.1/admin.war), [vinothek.war](https://github.com/OpenTOSCA/OpenTOSCA.github.io/releases/download/v1.1/vinothek.war)) into Tomcat `webapps` folder
1. Download and unzip [OpenTOSCA.zip](https://github.com/OpenTOSCA/OpenTOSCA.github.io/releases/download/v1.1/OpenTOSCA.zip) and [wso2bps-2.1.2.zip](http://www.iaas.uni-stuttgart.de/OpenTOSCA/third-party/wso2bps-2.1.2.zip)
1. Rename folder `wso2bps-2.1.2` ro `wso2bps`
1. Install BPEL4Rest extension on BPS
    1. Copy [bpel4restlight1.1.jar](https://github.com/OpenTOSCA/OpenTOSCA.github.io/raw/master/third-party/bpel4restlight1.1.jar) into folder `wso2bps/repository/components/lib/`
    1. Replace [bps.xml](https://github.com/OpenTOSCA/OpenTOSCA.github.io/raw/master/third-party/bps.xml) in `wso2bps/repository/conf/`
1. (Re)start Tomcat
1. Start WSO2BPS (`wso2bps/bin/wso2server.sh` or `wso2server.bat`) and wait until started
1. Start OpenTOSCA (`OpenTOSCA/startup.sh` or `startup.bat`) and wait until started
1. Open: `http://<HOST>:8080/`


## Repositories

* [OpenTOSCA container - TOSCA runtime](https://github.com/OpenTOSCA/container)
* [Vinothek - OpenTOSCA self-service portal](https://github.com/OpenTOSCA/vinothek)
* [Landing page of OpenTOSCA container](https://github.com/OpenTOSCA/ui-root)
* [Admin Page of OpenTOSCA container](https://github.com/OpenTOSCA/ui-admin)

## Known Major Issues

* OpenTOSCA Container
    * Supports imperative CSAR processing only
    * Restart of container not possible
    * The Partner Link role of the Build & Management Plans must be named “client”.