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

printf "Using container version $CONTAINER_VERSION"
printf "Using ui version $UI_VERSION"
printf "Using winery version $WINERY_VERSION"

# where are the other scripts coming together with this script?
BINPATH="https://github.com/OpenTOSCA/install.opentosca.org/releases/download/$CONTAINER_VERSION"

# where do we find our builds?
BUILDPATH="http://builds.opentosca.org/"

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
wget -N $THIRDPARTYPATH/tomcat-users.xml || (echo "not found"; exit 404)
wget -N $THIRDPARTYPATH/server.xml || (echo "not found"; exit 404)
sudo mv ./tomcat-users.xml /var/lib/tomcat8/conf/tomcat-users.xml
sudo mv ./server.xml /var/lib/tomcat8/conf/server.xml

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

printf "\n\n### Retreive, Configure, and Install UI\n"
# the ui is named "opentosca" to have nice urls
wget -N $BUILDPATH/ui/$UI_VERSION/opentosca-ui.war || (echo "not found"; exit 404)
# patch ip into ui
export IP=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
if [ -z "$IP" ]; then
  #in case instance is not an openstack client
  export IP=`curl -s ifconfig.co`;
fi
printf "\nExternal IP=$IP\n"

sudo mv opentosca-ui.war /opt
sudo chmod +x /opt/opentosca-ui.war
sudo ln -s /opt/opentosca-ui.war /etc/init.d/opentosca-web
sudo update-rc.d opentosca-web defaults

printf "\n\n### Install Winery\n"
wget -N $BUILDPATH/winery/$WINERY_VERSION/winery.war || (echo "not found"; exit 404)
wget -N $BUILDPATH/winery/$WINERY_VERSION/winery-topologymodeler.war || (echo "not found"; exit 404)
sudo mv ./winery.war /var/lib/tomcat8/webapps
sudo mv ./winery-topologymodeler.war /var/lib/tomcat8/webapps
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
mv wso2bps-2.1.2/ wso2bps/
chmod +x wso2bps/bin/wso2server.sh
sudo ln -s wso2bps/bin/wso2server.sh /etc/init.d/opentosca-wso2bps
sudo update-rc.d opentosca-wso2bps defaults

printf "\n\n### REST Extension\n"
cd ~
wget -N $THIRDPARTYPATH/bpel4restlight1.1.1.jar || (echo "not found"; exit 404)
rm  wso2bps/repository/components/lib/bpel4*
mv  bpel4restlight1.1.1.jar wso2bps/repository/components/lib/

printf "\n\n### Configure REST Extension\n"
cd ~
wget -N $THIRDPARTYPATH/bps.xml || (echo "not found"; exit 404)
mv bps.xml wso2bps/repository/conf/bps.xml

printf "\n\n### Install Docker\n"

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo service docker stop
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo sed -ie "s/ExecStart=\/usr\/bin\/dockerd -H fd:\/\//ExecStart=\/usr\/bin\/dockerd -H fd:\/\/ -H tcp:\/\/0.0.0.0:2375/g" /lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo service docker start

printf "\n\n### Install OpenTOSCA\n"
cd ~
wget -N $BUILDPATH/container/$CONTAINER_VERSION/org.opentosca.container.product-linux.gtk.x86_64.zip || (echo "not found"; exit 404)
mkdir OpenTOSCA
cd OpenTOSCA
unzip -qo ../org.opentosca.container.product-linux.gtk.x86_64.zip
sudo sed -ie "s/org.opentosca.container.hostname=localhost/org.opentosca.container.hostname=$IP/g" configuration/config.ini
chmod +x OpenTOSCA
sudo ln -s OpenTOSCA /etc/init.d/opentosca-container
sudo update-rc.d opentosca-container defaults
cd ..
