
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

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

## Haftung

Dies ist ein Forschungsprototyp.
Die Haftung für entgangenen Gewinn, Produktionsausfall, Betriebsunterbrechung, entgangene Nutzungen, Verlust von Daten und Informationen, Finanzierungsaufwendungen sowie sonstige Vermögens- und Folgeschäden ist, außer in Fällen von grober Fahrlässigkeit, Vorsatz und Personenschäden ausgeschlossen.

## Disclaimer of Warranty

Unless required by applicable law or agreed to in writing, Licensor provides the Work (and each Contributor provides its Contributions) on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied, including, without limitation, any warranties or conditions of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A PARTICULAR PURPOSE.
You are solely responsible for determining the appropriateness of using or redistributing the Work and assume any risks associated with Your exercise of permissions under this License.
