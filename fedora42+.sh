#!/usr/bin/env bash
set -euo pipefail

# Ensure the script is executed as root
if [[ $(id -u) != "0" ]]; then
    echo 'This script must be run as root or with sudo privileges.'
    exit 1
fi

# Configure COPR repository and exclude Mesa packages from the official repositories
echo -n "Detecting operating system... "
if grep -qi 'nobara' /etc/system-release; then
    echo "Nobara Linux detected."
    sed -i '2s/^/exclude=mesa*\n/' /etc/yum.repos.d/nobara.repo
# elif grep -qi 'bazzite' /etc/system-release; then
#     echo "Bazzite Linux detected."
#     dnf config-manager --save --setopt='*.exclude=mesa*'
elif grep -qi 'fedora' /etc/system-release; then
    echo "Fedora Linux detected."
    sed -i '2s/^/exclude=mesa*\n/' /etc/yum.repos.d/fedora.repo
    sed -i '2s/^/exclude=mesa*\n/' /etc/yum.repos.d/fedora-updates.repo
else
    echo "Unsupported distribution detected."
    echo "Only Fedora-based systems (Fedora, Nobara, Bazzite) are supported by this script."
    exit 1
fi
dnf copr enable danayer/mesa-git -y
dnf upgrade -y 

# Install Oberon GPU governor
# Fork by mothenjoyer69, originally by Segfault
echo "Installing Oberon GPU governor..."
dnf install libdrm-devel cmake make g++ git -y
git clone https://gitlab.com/mothenjoyer69/oberon-governor.git && cd oberon-governor
cmake . && make && make install
systemctl enable oberon-governor.service

# Final notification and system reboot
echo "Configuration complete. The system will reboot in 5 seconds. Press Ctrl+C to cancel."
sleep 5 && systemctl reboot
