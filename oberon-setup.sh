#!/bin/bash

set -euo pipefail

# Check for systemd service if present
if [[ -f /etc/systemd/system/oberon-governor.service ]]; then
  systemctl stop oberon-governor.service
  systemctl disable oberon-governor.service
  rm /etc/systemd/system/oberon-governor.service
else

# Check for binary if present
if [[ -f /etc/oberon-governor ]]; then
  rm /etc/oberon-governor
fi

echo "Downloading latest oberon-governor..."
curl -L -o /etc/oberon-governor https://github.com/vietsman/oberon-governor/releases/latest/download/oberon-governor
chmod +x /etc/oberon-governor

echo "Creating config file..."
tee /etc/oberon-config.yaml > /dev/null << 'EOF'
opps:
  - frequency:
    - min: 1000
    - max: 2000
  - voltage:
    - min: 700
    - max: 1000
EOF

# Create systemd service
echo "Creating systemd service file..."
tee /etc/systemd/system/oberon-governor.service > /dev/null << 'EOF'
[Unit]
Description=Oberon GPU Frequency Governor
After=network.target

[Service]
ExecStart=/etc/oberon-governor
RestartSec=5
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd..."
systemctl daemon-reexec
systemctl daemon-reload

echo "Enabling and starting oberon-governor service..."
systemctl enable oberon-governor
systemctl start oberon-governor

echo "Oberon Governor setup complete."
