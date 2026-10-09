#!/bin/bash

set -e

echo "===================================="
echo " TeamViewer Host Installation"
echo "===================================="

# Prompt for Assignment Token
read -s -p "Enter TeamViewer Assignment Token: " TV_TOKEN
echo

if [ -z "$TV_TOKEN" ]; then
    echo "Error: No token entered."
    exit 1
fi

echo "Downloading TeamViewer Host..."

wget -O /tmp/teamviewer-host.deb \
https://download.teamviewer.com/download/linux/teamviewer-host_amd64.deb

echo "Installing TeamViewer Host..."

sudo apt-get update
sudo apt-get install -y /tmp/teamviewer-host.deb

echo "Starting TeamViewer service..."

sudo systemctl enable teamviewerd
sudo systemctl start teamviewerd

echo "Waiting for TeamViewer to initialize..."
sleep 10

echo "Assigning device to company account..."

sudo teamviewer assignment \
    --id "$TV_TOKEN" \
    --grant-easy-access

echo
echo "✅ TeamViewer Host installed and assigned successfully."