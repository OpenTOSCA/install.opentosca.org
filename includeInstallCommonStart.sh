#!/bin/sh
echo "\n\n### Starting OpenTOSCA"

echo "Starting WSO2 BPS...";
sudo systemctl start opentosca-wso2bps.service
sleep 3

echo "Starting OpenTOSCA container..."
sudo systemctl start opentosca-container.service
sleep 3

echo "Starting OpenTOSCA Web UI"
sudo service opentosca-web start

echo "Startup will be finished in background...";
#echo "Run 'tail -f ~/OpenTOSCA/nohup.log ~/wso2bps/nohup.log' to see what's happening";
echo "Run 'systemctl status opentosca-container.service' 'systemctl status opentosca-wso2bps.service' to see what's happening";
echo "Wait a minute";
echo "Open 'http://$IP:8088' in your browser to access the OpenTOSCA ecosystem";
