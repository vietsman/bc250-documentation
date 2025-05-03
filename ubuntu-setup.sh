  #!/usr/bin/env bash
set -euo pipefail

# Ensure the script is executed as root
if [[ $(id -u) != "0" ]]; then
    echo 'This script must be run as root or with sudo privileges.'
    exit 1
fi

# Install updated Mesa drivers and block updates from default sources
echo -n "Adding Mesa repo... "

UBUNTU_VERSION=$(lsb_release -rs)
UBUNTU_CODENAME=$(lsb_release -sc)

if (( $(echo "$UBUNTU_VERSION >= 25.04" | bc -l) )); then
    echo -n "Ubuntu $UBUNTU_VERSION ($UBUNTU_CODENAME) detected... "

    GPG_KEYRING_PATH="/usr/share/keyrings/mesarc.gpg"
    curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xF7D9F0EAA92354B674013D4523A159D3E514D90F" \
        | gpg --dearmor -o "$GPG_KEYRING_PATH"

    echo "deb [signed-by=$GPG_KEYRING_PATH] https://ppa.launchpadcontent.net/ernstp/mesarc/ubuntu $UBUNTU_CODENAME main" > /etc/apt/sources.list.d/mesarc.list
    echo "deb-src [signed-by=$GPG_KEYRING_PATH] https://ppa.launchpadcontent.net/ernstp/mesarc/ubuntu $UBUNTU_CODENAME main" >> /etc/apt/sources.list.d/mesarc.list

    apt update
    apt full-upgrade -y
else
    echo "Ubuntu version $UBUNTU_VERSION is not supported."
    exit 1
fi

# Install Oberon GPU governor
# Fork by mothenjoyer69, originally by Segfault
echo "Installing Oberon GPU governor..."
apt install libdrm-dev cmake make g++ git -y
git clone https://gitlab.com/mothenjoyer69/oberon-governor.git && cd oberon-governor
cmake . && make && make install
systemctl enable oberon-governor.service

# Final notification and system reboot
echo "Configuration complete. The system will reboot in 5 seconds. Press Ctrl+C to cancel."
sleep 5 && systemctl reboot
