#!/bin/sh
printf "Common install routines...\n"
printf "DEBUG: x${TAG}x${CONTAINER_VERSION}x${UI_VERSION}x${WINERY_VERSION}x\n"

if [ -z "${TAG}${CONTAINER_VERSION}${UI_VERSION}${WINERY_VERSION}" ]; then
  printf "A tag or specific versions have to be given\n"
  exit
fi

if [ -z "$CONTAINER_VERSION" ]; then
  #in case no specific version are set, we take the tag as version for all installed components
  printf "CONTAINER_VERISON not set. Falling back to tag.\n"
  export CONTAINER_VERSION=$TAG
  export UI_VERSION=$TAG
  if [ -z "$WINERY_VERSION" ]; then
    export WINERY_VERSION=$TAG
  fi
fi

printf "Using container version $CONTAINER_VERSION\n"
printf "Using ui version $UI_VERSION\n"
printf "Using winery version $WINERY_VERSION\n"

# where are the other scripts coming together with this script?
BINPATH="https://github.com/OpenTOSCA/install.opentosca.org/releases/download/$CONTAINER_VERSION"

# where do we find our builds?
BUILDPATH="http://builds.opentosca.org"

# where are tomcat config files
TOMCAT_CONFIG_PATH="https://cdn.rawgit.com/OpenTOSCA/engine-ia/a11ca314"

# third party dependencies are versioned separately
THIRDPARTYPATH="http://files.opentosca.org/third-party/v2.0.0"

printf "\n\n### AUTOMATICALLY INSTALLING OpenTOSCA\n"

# following does not work:
# export DEBIAN_FRONTEND="noninteractive"
# solution from https://github.com/phusion/baseimage-docker/issues/58#issuecomment-47995343
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections

printf "\n\n### Update Package List\n"
sudo apt-get -y update

printf "\n\n### Include security fixes\n"
sudo apt-get -y upgrade

printf "\n\n### Install Tomcat 8\n"
sudo apt-get install -y tomcat8 tomcat8-admin zip unzip apt-transport-https ca-certificates curl software-properties-common wget
sudo service tomcat8 stop

printf "\n\n### Set CATALINA_OPTS\n"
sudo sh -c "echo 'CATALINA_OPTS=\"-Xmx1024m\"' >> /etc/default/tomcat8"

printf "\n\n### Set JAVA_HOME"
sudo sh -c "echo 'JAVA_HOME=\"'$(readlink -f /usr/bin/java | sed "s:bin/java::")'\"' >> /etc/environment";
export JAVA_HOME="$(readlink -f /usr/bin/java | sed "s:bin/java::")";

printf "\n\n### Tomcat User Settings\n"
cd ~

wget -N ${TOMCAT_CONFIG_PATH}/tomcat-users.xml.tpl || (echo "not found"; exit 404)
wget -N ${TOMCAT_CONFIG_PATH}/server.xml || (echo "not found"; exit 404)
wget -N ${TOMCAT_CONFIG_PATH}/manager.xml || (echo "not found"; exit 404)
sudo mv ./tomcat-users.xml.tpl /var/lib/tomcat8/conf/tomcat-users.xml
sudo mv ./server.xml /var/lib/tomcat8/conf/server.xml
sudo mv ./manager.xml /var/lib/tomcat8/conf/Catalina/localhost/manager.xml

sudo sh -c "cat <<EOF > /root/rsyncd.conf
use chroot = no
gid = root
uid = root
[temp]
        path = /tmp
        read only = no
        comment = winery
EOF
"

# Retrieve external IP address
export IP=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
if [ -z "$IP" ]; then
  #in case instance is not an openstack client
  export IP=`curl -s ifconfig.co`;
fi
printf "\nExternal IP address = $IP\n"

printf "\n\n### Retreive, Configure, and Install UI\n"
wget -N $BUILDPATH/ui/$UI_VERSION/opentosca-ui.war || (echo "not found"; exit 404)
sudo mv opentosca-ui.war /opt
sudo chmod +x /opt/opentosca-ui.war
sudo ln -s /opt/opentosca-ui.war /etc/init.d/opentosca-web
sudo update-rc.d opentosca-web defaults

printf "\n\n### Install Winery\n"
wget -N $BUILDPATH/winery/$WINERY_VERSION/winery.war || (echo "not found"; exit 404)
wget -N $BUILDPATH/winery/$WINERY_VERSION/winery-topologymodeler.war || (echo "not found"; exit 404)
wget -N $BUILDPATH/winery/$WINERY_VERSION/winery-ui.war || (echo "not found"; exit 404)
sudo mv ./winery.war /var/lib/tomcat8/webapps
sudo mv ./winery-topologymodeler.war /var/lib/tomcat8/webapps
sudo mv ./winery-ui.war /var/lib/tomcat8/webapps/ROOT.war
sudo rm -Rf /var/lib/tomcat8/webapps/ROOT
sudo cp /var/lib/tomcat8/webapps/winery.war /var/lib/tomcat8/webapps/containerrepository.war

printf "\n\n### Import Winery Repository (into home)\n"
sudo mkdir ~tomcat8/winery-repository;
wget -N $THIRDPARTYPATH/winery-repository.zip || (echo "not found"; exit 404)
sudo unzip -qo winery-repository.zip -d ~tomcat8/winery-repository
sudo chown -R tomcat8:tomcat8 ~tomcat8/winery-repository

printf "\n\n### Start Tomcat\n"
sudo service tomcat8 start

printf "\n\n### Install WSO2 BPS\n"
cd ~
wget -N $THIRDPARTYPATH/wso2bps-2.1.2-java8.zip || (echo "not found"; exit 404)
unzip -qo wso2bps-2.1.2-java8.zip
sudo mv wso2bps-2.1.2/ wso2bps/
chmod +x wso2bps/bin/wso2server.sh

printf "\n\n### REST Extension\n"
cd ~
wget -N $THIRDPARTYPATH/bpel4restlight1.1.1.jar || (echo "not found"; exit 404)
sudo rm  wso2bps/repository/components/lib/bpel4*
sudo mv  bpel4restlight1.1.1.jar wso2bps/repository/components/lib/

printf "\n\n### Configure REST Extension\n"
cd ~
wget -N $THIRDPARTYPATH/bps.xml || (echo "not found"; exit 404)
sudo mv bps.xml wso2bps/repository/conf/bps.xml

printf "\n\n#Move WSO2 BPS to /opt\n"
cd ~
sudo mv wso2bps /opt/

#Download the Service files to the system folder
sudo wget $SCRIPTPATH/opentosca-wso2bps.service -O /etc/systemd/system/opentosca-wso2bps.service

#Copy the Service init files to the /opt folder
sudo wget $SCRIPTPATH/start-wso2bps.sh -O /usr/local/bin/start-wso2bps.sh

#Convert the init script to an executable
sudo chmod +x /usr/local/bin/start-wso2bps.sh

#Create Environment VAriable File for the Service
sudo mkdir /etc/systemd/system/opentosca-wso2bps.service.d
sudo sh -c "echo '[Service]\nEnvironment=\"JAVA_HOME='$(readlink -f /usr/bin/java | sed "s:bin/java::")'\"' >> /etc/systemd/system/opentosca-wso2bps.service.d/override.conf";

printf "\n\n#Register WSO2 BPS Service\n"
sudo chmod 664 /etc/systemd/system/opentosca-wso2bps.service
sudo systemctl daemon-reload
sudo systemctl enable opentosca-wso2bps.service

printf "\n\n### Install Docker\n"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo service docker stop
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo sed -ie "s/ExecStart=\/usr\/bin\/dockerd -H fd:\/\/$/ExecStart=\/usr\/bin\/dockerd -H fd:\/\/ -H tcp:\/\/0.0.0.0:2375/g" /lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo service docker start

printf "\n\n### Install OpenTOSCA Container\n"
cd ~
wget -N $BUILDPATH/container/$CONTAINER_VERSION/org.opentosca.container.product-linux.gtk.x86_64.zip || (echo "not found"; exit 404)
sudo mkdir OpenTOSCA
cd OpenTOSCA
unzip -qo ../org.opentosca.container.product-linux.gtk.x86_64.zip
sudo sed -ie "s/org.opentosca.container.hostname=localhost/org.opentosca.container.hostname=$IP/g" configuration/config.ini
chmod +x OpenTOSCA
cd ..

printf "\n\n### Move OpenTOSCA to /opt\n"
sudo mv OpenTOSCA /opt/

#Download the Service files to the system folder
sudo wget $SCRIPTPATH/opentosca-container.service -O /etc/systemd/system/opentosca-container.service

#Copy the Service init files to the /opt folder
sudo wget $SCRIPTPATH/start-container.sh -O /usr/local/bin/start-container.sh

#Convert the init script to an executable
sudo chmod +x /usr/local/bin/start-container.sh

printf "\n\n#Register OpenTOSCA Container Service\n"
sudo chmod 664 /etc/systemd/system/opentosca-container.service
sudo systemctl daemon-reload
sudo systemctl enable opentosca-container.service
