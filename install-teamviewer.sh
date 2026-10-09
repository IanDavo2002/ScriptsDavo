#!/bin/bash

set -e

echo "===================================="
echo " TeamViewer Host Installation"
echo "===================================="

echo "Downloading TeamViewer Host..."

wget -O /tmp/teamviewer-host.deb \
https://download.teamviewer.com/download/linux/teamviewer-host_amd64.deb

echo "Installing TeamViewer Host..."

apt-get update
apt-get install -y /tmp/teamviewer-host.deb

echo "Enabling TeamViewer service..."

systemctl enable teamviewerd
systemctl start teamviewerd

echo
echo "✅ TeamViewer Host installed successfully."
echo

teamviewer info || true