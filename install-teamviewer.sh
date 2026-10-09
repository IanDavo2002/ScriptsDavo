#!/bin/bash

set -e

TMP_DEB="/tmp/teamviewer-host_amd64.deb"

echo "Updating packages..."
sudo apt update

echo "Downloading TeamViewer Host..."
wget -O "$TMP_DEB" \
https://download.teamviewer.com/download/linux/teamviewer-host_amd64.deb

echo "Installing TeamViewer Host..."
sudo apt install -y "$TMP_DEB"

echo "Fixing dependencies..."
sudo apt --fix-broken install -y

echo "Disabling Wayland..."

if [ -f /etc/gdm3/custom.conf ]; then
    sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf

    if ! grep -q '^WaylandEnable=false' /etc/gdm3/custom.conf; then
        sudo sed -i '/^\[daemon\]/a WaylandEnable=false' /etc/gdm3/custom.conf
    fi

    echo "Wayland disabled."
fi

echo "Accepting TeamViewer license..."
sudo teamviewer license accept || true

echo "Enabling TeamViewer service..."
sudo systemctl enable --now teamviewerd

echo "Waiting for TeamViewer service to initialize..."
sleep 10

echo ""
read -p "Enter TeamViewer Assignment Token (leave blank to skip): " TV_TOKEN

if [ -n "$TV_TOKEN" ]; then
    echo "Assigning device to TeamViewer..."

    sudo teamviewer assignment \
        --id "$TV_TOKEN" \
        --grant-easy-access

    echo "Assignment completed."
else
    echo "Assignment skipped."
fi

echo ""
echo "================================="
echo "TEAMVIEWER READY"
echo "================================="

teamviewer info || true

echo ""
echo "Reboot recommended to switch from Wayland to Xorg."