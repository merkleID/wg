#!/bin/bash

declare -A list
list=$(ls -1 /etc/wireguard/*.conf)

for nic in ${list[@]}
	do
	wg-quick down $nic
done
