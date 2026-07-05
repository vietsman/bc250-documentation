#!/bin/bash

set -euo pipefail

# Check for systemd service if present
if [[ -f /etc/systemd/system/oberon-governor.service ]]; then
  systemctl stop oberon-governor.service
  systemctl disable oberon-governor.service
  rm /etc/systemd/system/oberon-governor.service
fi

# Check for binary if present
if [[ -f /etc/oberon-governor ]]; then
  rm /etc/oberon-governor
fi

echo "Downloading latest oberon-governor..."
curl -L -o /etc/oberon-governor https://github.com/vietsman/bc250-machine/releases/latest/download/oberon-governor
chmod +x /etc/oberon-governor

echo "Creating config file..."
curl -L -o /etc/oberon-config.toml https://github.com/vietsman/bc250-machine/releases/latest/download/oberon-config.toml

# Create systemd service
echo "Creating systemd service file..."
tee /etc/systemd/system/oberon-governor.service > /dev/null << 'EOF'
[Unit]
Description=Oberon GPU Governor

[Service]
ExecStart=/etc/oberon-governor /etc/oberon-config.toml
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
