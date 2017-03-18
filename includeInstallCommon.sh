#!/bin/sh

if [ -z "$TAG" ]; then
  echo "A tag has to be given"
  exit
fi

BINPATH="https://github.com/OpenTOSCA/OpenTOSCA.github.io/releases/download/$TAG"
BUILDPATH="http://builds.opentosca.org/"
THIRDPARTYPATH="http://files.opentosca.org/third-party/$TAG"

echo "\n\n### AUTOMATICALLY INSTALLING OpenTOSCA"

echo "\n\n### Update Package List"
sudo apt-get -y update

echo "\n\n### Include security fixes"
sudo apt-get -y upgrade

echo "\n\n### Install Tomcat 8"
sudo apt-get -y install tomcat8 tomcat8-admin unzip
sudo service tomcat8 stop

echo "\n\n### Set CATALINA_OPTS"
sudo sh -c "echo 'CATALINA_OPTS=\"-Xmx1024m\"' >> /etc/default/tomcat8"

echo "\n\n### Tomcat User Settings"
cd ~
wget -qN $THIRDPARTYPATH/tomcat-users.xml
wget -qN $THIRDPARTYPATH/server.xml
sudo mv ./tomcat-users.xml /var/lib/tomcat8/conf/tomcat-users.xml
sudo mv ./server.xml /var/lib/tomcat8/conf/server.xml

#echo "\n\n### Install ROOT.war"
#wget -qN $BINPATH/ROOT.war;
#sudo rm /var/lib/tomcat7/webapps/ROOT -fr;
#sudo mv ./ROOT.war /var/lib/tomcat7/webapps/ROOT.war;
sudo sh -c "echo 'Please open the UI' > ~tomcat8/webapps/ROOT/index.html"

#echo "\n\n### Install admin.war"
#wget -qN $BINPATH/admin.war;
#sudo mv ./admin.war /var/lib/tomcat7/webapps/admin.war;

printf "\n\n### Install ui"
wget -qN $BUILDPATH/ui/$TAG/ui.war

sudo mv ./ui.war /var/lib/tomcat8/webapps/

#echo "\n\n### Install vinothek.war"
#wget -qN $BINPATH/vinothek.war;
#sudo mv ./vinothek.war /var/lib/tomcat7/webapps/vinothek.war;

echo "\n\n### Install Winery"
wget -qN $BUILDPATH/winery/$TAG/winery.war
wget -qN $BUILDPATH/winery/$TAG//winery-topologymodeler.war
sudo mv ./winery.war /var/lib/tomcat8/webapps
sudo mv ./winery-topologymodeler.war /var/lib/tomcat8/webapps

echo "\n\n### Import Winery Repository (into home)"
sudo mkdir ~tomcat8/winery-repository;
wget -qN $THIRDPARTYPATH/winery-repository.zip;
sudo unzip -qo winery-repository.zip -d ~tomcat8/winery-repository
sudo chown -R tomcat8:tomcat8 ~tomcat8/winery-repository

echo "\n\n### Start Tomcat"
sudo service tomcat8 start

echo "\n\n### Install WSO2 BPS"
cd ~
wget -qN $THIRDPARTYPATH/$TAG/wso2bps-2.1.2-java8.zip
unzip -qo wso2bps-2.1.2-java8.zip
mv wso2bps-2.1.2/ wso2bps/
chmod +x wso2bps/bin/wso2server.sh

echo "\n\n### REST Extension"
cd ~
wget -qN $THIRDPARTYPATH/bpel4restlight1.1.1.jar
rm  wso2bps/repository/components/lib/bpel4*
mv  bpel4restlight1.1.1.jar wso2bps/repository/components/lib/

echo "\n\n### Configure REST Extension"
cd ~
wget -qN $THIRDPARTYPATH/bps.xml
mv bps.xml wso2bps/repository/conf/bps.xml

echo "\n\n### Install OpenTOSCA"
cd ~
wget -qN -O OpenTOSCA.zip $BUILDPATH/container/$TAG/org.opentosca.container.product-linux.gtk.x86.zip
mkdir OpenTOSCA
cd OpenTOSCA
unzip -qo ../OpenTOSCA.zip
chmod +x OpenTOSCA
cd ..
