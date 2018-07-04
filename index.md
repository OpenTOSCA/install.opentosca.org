---
layout: default
---
# OpenTOSCA Ecosystem: Installation Instructions

Version v2.0.0 is the current stable version of the OpenTOSCA ecosystem.

## Table of Contents

- [Installation](#installation)
  - [General Remarks](#general-remarks)
  - [Docker](#docker)
- [Repositories](#repositories)
- [Contact](#contact)
- [Documentation](#documentation)

## Installation

### General Remarks

- Make sure following ports in your environment are free in order to start OpenTOSCA properly:
  - `1337`
  - `8080-8088`
  - `8090`
  - `9763`
  - `1883` (optional)
  - `9000` (optional)

### Docker

The following steps will help you to setup our dockerized OpenTOSCA environment.
Beside of this installation script, there is a Docker Compose configuration available at <https://github.com/OpenTOSCA/opentosca-docker> that can be used to set up a customized environment.

- **testing, UNSTABLE, Ubuntu 16.04, 64bit**: Short version: `wget -qO- http://install.opentosca.org/install-dockerized | sh`

Wait a few seconds, then open the [OpenTOSCA user interface](http://<HOSTNAME>:8088).

| OpenTOSCA Component | URL |
|:------------------- |:--- |
| OpenTOSCA UI | <http://HOSTNAME:8088> |
| OpenTOSCA Modelling (Eclipse Winery) | <http://HOSTNAME:8080> |
| OpenTOSCA Container API | <http://HOSTNAME:1337> |
| OpenTOSCA Container Repository | <http://HOSTNAME:8081> |
| Plan Engine (Apache ODE) | <http://HOSTNAME:9763/ode> |
| IA Engine (Apache Tomcat) | <http://HOSTNAME:8090/manager><br>(user: `admin`, password: `admin`) |

You can check the status of the different containers by using the _Portainer_ Management UI at <http://HOSTNAME:9000>.

## Repositories

The OpenTOSCA eco system is open source and actively developed on GitHub.
Please head to our [website](https://github.com/opentosca) for further information.

Our main components are:

- OpenTOSCA UI - User interface for the OpenTOSCA Runtime: https://github.com/OpenTOSCA/ui
- OpenTOSCA Container - an open-source, TOSCA-compliant runtime: https://github.com/OpenTOSCA/container
- OpenTOSCA Modelling Tool (Eclipse Winery™): https://github.com/OpenTOSCA/winery

## Contact

If you need support, contact us at <opentosca@iaas.uni-stuttgart.de>.

## Documentation

- [OpenTOSCA Documentation, Publications, Videos, Presentations](http://www.opentosca.org)
