# OpenTOSCA Ecosystem Releases

This repository contains the installation scripts and binaries of the [OpenTOSCA ecosystem](http://www.opentosca.org).

- [install](install) - installation on Ubuntu 16.04, 64bit
- [install*](install) - installation on Ubuntu 16.04 on diverse environments

Installation instructions are given in [index.md](index.md), which is rendered at <http://install.opentosca.org/>.

## Generate TOC

1. `npm install markdown-toc`
2.  `node_modules\.bin\markdown-toc -i index.md`

## Supporting files

- `includeInstallCommon.sh` - included by the `install*` scripts for installation
   - Ubuntu 16.04, 64bit
- `includeInstallCommonStart.sh` - included by the `install*` scripts for startup 

## Styleguide

We follow the [Google Shell Styleguide](https://google.github.io/styleguide/shell.xml#File_Extensions) as shortly explained at http://askubuntu.com/a/503129/196423
