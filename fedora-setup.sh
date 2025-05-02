#!/usr/bin/env bash
set -euo pipefail

# Ensure the script is executed as root
if [[ $(id -u) != "0" ]]; then
    echo 'This script must be run as root or with sudo privileges.'
    exit 1
fi

# Configure COPR repository and exclude Mesa packages from the official repositories
echo -n "Configuring Mesa COPR repository... "
if grep -q Nobara "/etc/system-release"; then
    echo -n "Nobara Linux detected... "
    sed -i '2s/^/exclude=mesa*\n/' /etc/yum.repos.d/nobara.repo 
else 
    echo -n "Fedora Linux detected... "
    sed -i '2s/^/exclude=mesa*\n/' /etc/yum.repos.d/fedora.repo
    sed -i '2s/^/exclude=mesa*\n/' /etc/yum.repos.d/fedora-updates.repo
fi
dnf copr enable @exotic-soc/bc250-mesa -y
dnf upgrade -y 

# Set RADV_DEBUG environment variable globally
echo -n "Configuring RADV_DEBUG environment variable... "
echo 'RADV_DEBUG=nocompute' > /etc/environment

# Install Oberon GPU governor
# Fork by mothenjoyer69, originally by Segfault
echo "Installing Oberon GPU governor..."
dnf install libdrm-devel cmake make g++ git -y
git clone https://gitlab.com/mothenjoyer69/oberon-governor.git && cd oberon-governor
cmake . && make && make install
systemctl enable oberon-governor.service

# Apply kernel module options and regenerate initramfs
echo -n "Configuring amdgpu kernel module options... "
echo 'options amdgpu sg_display=0' > /etc/modprobe.d/options-amdgpu.conf
echo -n "Configuring nct6683 kernel module options... "
echo 'nct6683' > /etc/modules-load.d/99-sensors.conf
echo 'options nct6683 force=true' > /etc/modprobe.d/options-sensors.conf
echo "Regenerating initramfs (this may take a few minutes)..."
dracut --stdlog=4 --regenerate-all --force

# Clean up GRUB configuration and regenerate GRUB config
echo "Updating GRUB configuration..."
sed -i 's/nomodeset//g' /etc/default/grub
sed -i 's/amdgpu\.sg_display=0//g' /etc/default/grub
grub2-mkconfig -o /etc/grub2.cfg

# Final notification and system reboot
echo "Configuration complete. The system will reboot in 5 seconds. Press Ctrl+C to cancel."
sleep 5 && systemctl reboot
