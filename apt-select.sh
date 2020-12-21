#!/usr/bin/env bash

# Author: Yihsiu
# Reference: https://linuxconfig.org/how-to-select-the-fastest-apt-mirror-on-ubuntu-linux

if [ -z "$SHELL" ]; then
    echo "The shell you use is not supported. Please use bash instead."
    exit 1
fi

all_sites=$(wget -qO- mirrors.ubuntu.com/mirrors.txt)

echo $all_sites 

# wget -qO- mirrors.ubuntu.com/mirrors.txt | sed 's/https*:\/\///' | \
# while read line; do
#     site=${line%%/*}
#     echo $site
#     time=$(ping -c 5 $site | grep -E "time [0-9]+ms") #| sed 's/^.*time \([0-9]*\)ms.*$/\1/')
#     echo $time
# done < /dev/stdin
