#!/bin/bash

# Download the oberon-governor binary to /etc
curl -L -o /etc/oberon-governor https://github.com/buoyantbeaver/oberon-governor/releases/download/v1.0.0/oberon-governor

# Make it executable
chmod +x /etc/oberon-governor

# Create the configuration file
tee /etc/oberon-config.yaml > /dev/null << 'EOF'
opps:
  - frequency:
    - min: 1000
    - max: 2000
  - voltage:
    - min: 700
    - max: 1000
EOF

# Create the systemd service file
tee /etc/systemd/system/oberon-governor.service > /dev/null << 'EOF'
[Unit]
Description=Oberon CPU Frequency Governor
After=network.target

[Service]
ExecStart=/etc/oberon-governor
RestartSec=5
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to recognize the new service
systemctl daemon-reexec
systemctl daemon-reload

# Enable and start the service
systemctl enable oberon-governor
systemctl start oberon-governor

echo "Oberon Governor installed, configured, enabled, and started."
