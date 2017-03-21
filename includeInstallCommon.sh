#!/bin/sh

if [ -z "$TAG" ]; then
  echo "A tag has to be given"
  exit
fi

BINPATH="https://github.com/OpenTOSCA/install.opentosca.org/releases/download/$TAG"
BUILDPATH="http://builds.opentosca.org/"
THIRDPARTYPATH="http://files.opentosca.org/third-party/$TAG"

echo "\n\n### AUTOMATICALLY INSTALLING OpenTOSCA\n"

echo "\n\n### Update Package List\n"
sudo apt-get -y update

echo "\n\n### Include security fixes\n"
sudo apt-get -y upgrade

echo "\n\n### Install Tomcat 8\n"
sudo apt-get -y install tomcat8 tomcat8-admin zip unzip
sudo service tomcat8 stop

echo "\n\n### Set CATALINA_OPTS\n"
sudo sh -c "echo 'CATALINA_OPTS=\"-Xmx1024m\"' >> /etc/default/tomcat8"

echo "\n\n### Set JAVA_HOME"
sudo sh -c "echo 'JAVA_HOME=\"'$(readlink -f /usr/bin/java | sed "s:bin/java::")'\"' >> /etc/environment";
export JAVA_HOME="$(readlink -f /usr/bin/java | sed "s:bin/java::")";

echo "\n\n### Tomcat User Settings\n"
cd ~
wget -N $THIRDPARTYPATH/tomcat-users.xml
wget -N $THIRDPARTYPATH/server.xml
sudo mv ./tomcat-users.xml /var/lib/tomcat8/conf/tomcat-users.xml
sudo mv ./server.xml /var/lib/tomcat8/conf/server.xml

#echo "\n\n### Install ROOT.war"
#wget -N $BINPATH/ROOT.war;
#sudo rm /var/lib/tomcat7/webapps/ROOT -fr;
#sudo mv ./ROOT.war /var/lib/tomcat7/webapps/ROOT.war;
cat << EOF | sudo tee /var/lib/tomcat8/webapps/ROOT/index.html
<!DOCTYPE HTML>
<html lang="en-US">
    <head>
        <meta http-equiv="refresh" content="1;url=/opentosca/">
        <script type="text/javascript">
            window.location.href = "opentosca/"
        </script>
        <title>OpenTOSA</title>
    </head>
    <body>
        Please wait while OpenTOSCA is loading...
    </body>
</html>
EOF

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

#echo "\n\n### Install admin.war"
#wget -N $BINPATH/admin.war;
#sudo mv ./admin.war /var/lib/tomcat7/webapps/admin.war;

printf "\n\n### Retreive, Configure, and Install UI\n"
# the ui is named "opentosca" to have nice urls
wget -N $BUILDPATH/ui/$TAG/opentosca.war

IP=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
cd /tmp
mkdir ui
cd ui
unzip ~/opentosca.war
sed -i "s/dev.winery.opentosca.org/$IP/g" WEB-INF/classes/static/doc/modules/_app_redux_store_.html
sed -i "s/dev.winery.opentosca.org/$IP/g" WEB-INF/classes/static/main.bundle.js
sed -i "s/opentosca-dev.iaas.uni-stuttgart.de/$IP/g" WEB-INF/classes/static/doc/modules/_app_redux_store_.html
sed -i "s/opentosca-dev.iaas.uni-stuttgart.de/$IP/g" WEB-INF/classes/static/main.bundle.js
zip -r ~/opentosca.war WEB-INF/classes/static/doc/modules/_app_redux_store_.html
zip -r ~/opentosca.war WEB-INF/classes/static/main.bundle.js
cd ~
sudo mv ./opentosca.war /var/lib/tomcat8/webapps/

#echo "\n\n### Install vinothek.war"
#wget -N $BINPATH/vinothek.war;
#sudo mv ./vinothek.war /var/lib/tomcat7/webapps/vinothek.war;

echo "\n\n### Install Winery\n"
wget -N $BUILDPATH/winery/$TAG/winery.war
wget -N $BUILDPATH/winery/$TAG//winery-topologymodeler.war
sudo mv ./winery.war /var/lib/tomcat8/webapps
sudo mv ./winery-topologymodeler.war /var/lib/tomcat8/webapps

echo "\n\n### Import Winery Repository (into home)\n"
sudo mkdir ~tomcat8/winery-repository;
wget -N $THIRDPARTYPATH/winery-repository.zip;
sudo unzip -qo winery-repository.zip -d ~tomcat8/winery-repository
sudo chown -R tomcat8:tomcat8 ~tomcat8/winery-repository

echo "\n\n### Start Tomcat\n"
sudo service tomcat8 start

echo "\n\n### Install WSO2 BPS\n"
cd ~
wget -N $THIRDPARTYPATH/wso2bps-2.1.2-java8.zip
unzip -qo wso2bps-2.1.2-java8.zip
mv wso2bps-2.1.2/ wso2bps/
chmod +x wso2bps/bin/wso2server.sh

echo "\n\n### REST Extension\n"
cd ~
wget -N $THIRDPARTYPATH/bpel4restlight1.1.1.jar
rm  wso2bps/repository/components/lib/bpel4*
mv  bpel4restlight1.1.1.jar wso2bps/repository/components/lib/

echo "\n\n### Configure REST Extension\n"
cd ~
wget -N $THIRDPARTYPATH/bps.xml
mv bps.xml wso2bps/repository/conf/bps.xml

printf "\n\n### Install Docker\n"
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
sudo apt-get update
sudo apt-get install -y docker-engine
echo 'DOCKER_OPTS="-D -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock"' | sudo tee -a /etc/default/docker > /dev/null
sudo service docker restart

echo "\n\n### Install OpenTOSCA\n"
cd ~
wget -N $BUILDPATH/container/$TAG/org.opentosca.container.product-linux.gtk.x86_64.zip
mkdir OpenTOSCA
cd OpenTOSCA
unzip -qo ../org.opentosca.container.product-linux.gtk.x86_64.zip
chmod +x OpenTOSCA
cd ..
