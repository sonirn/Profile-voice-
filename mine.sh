#!/bin/bash

# Configuration
WALLET="BrRNyvr6TJfhqFewqWenyuC4VrfFAZXJoiPBkLbc8eRk"
COIN="SOL"
WORKER_NAME="github-miner"
THREADS=$(nproc)

# Detect platform
PLATFORM=$(uname -m)
OS=$(uname -s)

# Download appropriate miner
if [[ "$OS" == "Linux" ]]; then
    if [[ "$PLATFORM" == "x86_64" ]]; then
        # CPU Miner (XMRig)
        MINER_URL="https://github.com/xmrig/xmrig/releases/download/v6.18.0/xmrig-6.18.0-linux-x64.tar.gz"
    elif [[ "$PLATFORM" == "aarch64" ]]; then
        # Android/Termux optimized
        MINER_URL="https://github.com/xmrig/xmrig/releases/download/v6.18.0/xmrig-6.18.0-android-arm64.tar.gz"
    fi
elif [[ "$OS" == "Darwin" ]]; then
    MINER_URL="https://github.com/xmrig/xmrig/releases/download/v6.18.0/xmrig-6.18.0-macos-x64.tar.gz"
fi

# GPU Detection
if command -v nvidia-smi &> /dev/null; then
    GPU_MINER_URL="https://github.com/trexminer/T-Rex/releases/download/0.26.5/t-rex-0.26.5-linux.tar.gz"
    ALGO="kawpow"
elif command -v rocm-smi &> /dev/null; then
    GPU_MINER_URL="https://github.com/Lolliedieb/lolMiner-releases/releases/download/1.52/lolMiner_v1.52_Lin64.tar.gz"
    ALGO="ethash"
fi

# Setup mining
setup() {
    echo "Installing dependencies..."
    if [[ "$OS" == "Linux" ]]; then
        sudo apt-get update
        sudo apt-get install -y libuv1-dev libssl-dev build-essential
    elif [[ "$OS" == "Android" ]]; then
        pkg update
        pkg install -y git wget openssl-tool
    fi

    # Download miners
    wget $MINER_URL -O miner.tar.gz
    tar -xzf miner.tar.gz
    
    if [ ! -z "$GPU_MINER_URL" ]; then
        wget $GPU_MINER_URL -O gpu-miner.tar.gz
        tar -xzf gpu-miner.tar.gz
    fi
}

start_mining() {
    # CPU Mining
    if [ -f "xmrig" ]; then
        ./xmrig -o rx.unmineable.com:3333 -u $COIN:$WALLET.$WORKER_NAME -k --threads=$THREADS
    fi

    # GPU Mining
    if [ -f "t-rex" ]; then
        ./t-rex -a $ALGO -o stratum+tcp://rx.unmineable.com:3333 -u $COIN:$WALLET.$WORKER_NAME -p x
    elif [ -f "lolMiner" ]; then
        ./lolMiner --algo $ALGO --pool rx.unmineable.com:3333 --user $COIN:$WALLET.$WORKER_NAME
    fi
}

# Main execution
setup
start_mining
