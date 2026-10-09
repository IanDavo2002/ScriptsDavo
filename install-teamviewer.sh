#!/bin/bash

set -e

TMP_DEB="/tmp/teamviewer-host_amd64.deb"

echo "================================="
echo " TeamViewer Host Installer"
echo "================================="

echo "Updating packages..."
sudo apt update

echo "Downloading TeamViewer Host..."
wget -O "$TMP_DEB" \
https://download.teamviewer.com/download/linux/teamviewer-host_amd64.deb

echo "Installing TeamViewer Host..."
sudo apt install -y "$TMP_DEB"

echo "Fixing dependencies..."
sudo apt --fix-broken install -y

echo "Configuring GDM for Xorg..."

if [ -f /etc/gdm3/custom.conf ]; then

    # Remove any existing Wayland settings
    sudo sed -i '/^#\?WaylandEnable=/d' /etc/gdm3/custom.conf

    # Add WaylandEnable=false under [daemon]
    if grep -q "^\[daemon\]" /etc/gdm3/custom.conf; then
        sudo sed -i '/^\[daemon\]/a WaylandEnable=false' /etc/gdm3/custom.conf
    else
        echo -e "[daemon]\nWaylandEnable=false" | sudo tee -a /etc/gdm3/custom.conf > /dev/null
    fi

    echo "Wayland disabled."
else
    echo "WARNING: /etc/gdm3/custom.conf not found."
fi

echo "Accepting TeamViewer license..."
sudo teamviewer license accept || true

echo "Starting TeamViewer service..."
sudo systemctl enable --now teamviewerd

echo "Waiting for TeamViewer to initialize..."
sleep 15

echo ""
read -p "Enter TeamViewer Assignment Token (leave blank to skip): " TV_TOKEN

if [ -n "$TV_TOKEN" ]; then
    echo "Assigning device to TeamViewer..."

    sudo teamviewer assignment --id="$TV_TOKEN"

    echo "Assignment completed."
else
    echo "Assignment skipped."
fi

echo ""
echo "================================="
echo " TEAMVIEWER READY"
echo "================================="

echo ""
echo "Current TeamViewer Information:"
teamviewer info || true

echo ""
echo "Current Display Session:"
echo "XDG_SESSION_TYPE=$XDG_SESSION_TYPE"

echo ""
echo "IMPORTANT:"
echo "A reboot is required before Ubuntu switches from Wayland to Xorg."
echo ""

read -p "Reboot now? (y/N): " REBOOT

if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
    sudo reboot
fi