#!/usr/bin/env bash
set -euo pipefail

# Ensure the script is executed as root
if [[ $(id -u) != "0" ]]; then
    echo 'This script must be run as root or with sudo privileges.'
    exit 1
fi

# Check if it's Fedora 42
if [ "$fedora_version" != "42" ]; then
  echo "This script is designed to run only on Fedora 42. Exiting."
  exit 1
fi

# Configure COPR repository
dnf copr enable danayer/mesa-git -y
dnf upgrade -y

echo "Verifying Mesa version:"
rpm -q mesa-libGL

# Install Oberon GPU governor. Credit to Segfault and mothenjoyer69
echo "Installing Oberon GPU governor..."
dnf install libdrm-devel cmake make g++ git -y
git clone https://github.com/buoyantbeaver/oberon-governor.git && cd oberon-governor
cmake . && make && make install
systemctl enable oberon-governor.service

# Clean up GRUB configuration and regenerate GRUB config
echo "Updating GRUB configuration..."
sed -i 's/nomodeset//g' /etc/default/grub
grub2-mkconfig -o /etc/grub2.cfg

# Final notification and system reboot
echo "Configuration complete. The system will reboot in 5 seconds. Press Ctrl+C to cancel."
sleep 5 && systemctl reboot
