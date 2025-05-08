#!/data/data/com.termux/files/usr/bin/bash

# Prevent termux from sleeping
termux-wake-lock

# Install in background
apt install -y tmux
tmux new-session -d -s miner "bash mine.sh"

echo "Mining started in background. Use 'tmux attach -t miner' to view"
