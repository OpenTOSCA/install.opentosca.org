#!/bin/sh
echo "\n\n### Starting OpenTOSCA"
cd ~

echo "Starting WSO2 BPS...";
nohup ./wso2bps/bin/wso2server.sh >> ~/OpenTOSCA/wso2bps-nohup.log 2>&1 &
sleep 30

echo "Starting OpenTOSCA container..."
cd OpenTOSCA
nohup ./OpenTOSCA >>~/OpenTOSCA/opentosca-nohup.log 2>&1 &
sleep 30

echo "Startup will be finished in background...";
echo " + Run 'tail ~/OpenTOSCA/*nohup.log -f' to see what's happening";
echo " + Wait a minute";
echo " + Open 'http://<HOST>:8080' in your browser to access the OpenTOSCA ecosystem";
