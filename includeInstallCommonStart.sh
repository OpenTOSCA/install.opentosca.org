#!/bin/sh
echo "\n\n### Starting OpenTOSCA"
cd ~

export JAVA_HOME="$(readlink -f /usr/bin/java | sed "s:bin/java::")";

echo "Starting WSO2 BPS...";
nohup ./wso2bps/bin/wso2server.sh >> ~/wso2bps/nohup.log 2>&1 &
sleep 3

echo "Starting OpenTOSCA container..."
cd OpenTOSCA
nohup ./OpenTOSCA >>~/OpenTOSCA/nohup.log 2>&1 &
sleep 3

echo "Startup will be finished in background...";
echo "Run 'tail -f ~/OpenTOSCA/nohup.log ~/wso2bps/nohup.log' to see what's happening";
echo "Wait a minute";
echo "Open 'http://<HOST>:8080' in your browser to access the OpenTOSCA ecosystem";
