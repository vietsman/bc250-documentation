#!/usr/bin/env bash
set -euo pipefail

# Ensure the script is executed as root
if [[ $(id -u) != "0" ]]; then
    echo 'This script must be run as root or with sudo privileges.'
    exit 1
fi

# List of Mesa 25.1.0 Fedora 43 RPM URLs
MESA_URLS=(
  "https://kojipkgs.fedoraproject.org//packages/mesa/25.1.0/1.fc43/x86_64/mesa-libGL-25.1.0-1.fc43.x86_64.rpm"
  "https://kojipkgs.fedoraproject.org//packages/mesa/25.1.0/1.fc43/x86_64/mesa-dri-drivers-25.1.0-1.fc43.x86_64.rpm"
  "https://kojipkgs.fedoraproject.org//packages/mesa/25.1.0/1.fc43/x86_64/mesa-filesystem-25.1.0-1.fc43.x86_64.rpm"
  "https://kojipkgs.fedoraproject.org//packages/mesa/25.1.0/1.fc43/x86_64/mesa-libEGL-25.1.0-1.fc43.x86_64.rpm"
  "https://kojipkgs.fedoraproject.org//packages/mesa/25.1.0/1.fc43/x86_64/mesa-va-drivers-25.1.0-1.fc43.x86_64.rpm"
  "https://kojipkgs.fedoraproject.org//packages/mesa/25.1.0/1.fc43/x86_64/mesa-vulkan-drivers-25.1.0-1.fc43.x86_64.rpm"
  "https://kojipkgs.fedoraproject.org//packages/mesa/25.1.0/1.fc43/x86_64/mesa-libgbm-25.1.0-1.fc43.x86_64.rpm"
  "https://kojipkgs.fedoraproject.org//packages/mesa/25.1.0/1.fc43/x86_64/mesa-libgbm-devel-25.1.0-1.fc43.x86_64.rpm"
)

# Directory for temporary downloads
DOWNLOAD_DIR="/tmp/mesa-rpms"
mkdir -p "$DOWNLOAD_DIR"

echo "Downloading Mesa 25.1.0 RPMs with curl..."
for url in "${MESA_URLS[@]}"; do
  echo "Downloading $(basename "$url")..."
  curl -L -o "$DOWNLOAD_DIR/$(basename "$url")" "$url"
done

echo "Installing Mesa 25.1.0 RPMs..."
sudo rpm -Uvh "$DOWNLOAD_DIR"/mesa*.rpm

echo "Cleaning up..."
rm -rf "$DOWNLOAD_DIR"

echo "Verification:"
rpm -q mesa-libGL

# Install Oberon GPU governor
# Thanks to mothenjoyer69 and Segfault
echo "Installing Oberon GPU governor..."
dnf install libdrm-devel cmake make g++ git -y
git clone https://github.com/buoyantbeaver/oberon-governor.git && cd oberon-governor
cmake . && make && make install
systemctl enable oberon-governor.service

# Final notification and system reboot
echo "Configuration complete. The system will reboot in 5 seconds. Press Ctrl+C to cancel."
sleep 5 && systemctl reboot
