#!/bin/bash
#version 1.18
clear
if=$(wg show interfaces)
extip=$(curl -sS ifconfig.io)
lanip=$(ip a  | grep ":" | grep -v "::" | grep -v "00:00" | grep -v "ff:ff" | grep -v "lo" | awk -F ":" '{print $2}' | grep -v "wg")
workdir="/etc/wireguard/tmp"

echo "Delete everything in $workdir? [y/n]"
read del
if [ $del = "y" ]; then
	rm -rf $workdir/*
echo "Deleted!"
else echo "Nothing has been deleted!"
fi

echo ""
echo "**********************"
echo "Choose your interface:"
echo ""
echo $if
echo ""
read int
port=$(wg show $int listen-port)

echo "Choose a name for the clients' conf file (contigous):"
read nome

echo "Your interfaces is: $int"
echo "Interface Public Ip is: $extip"
echo "Interface Listen Port is: $port"
echo "Range of Ip Addresses in use on $int:"
echo "(an empty list means no client configured yet)"
wg show $int | grep allowed | awk -F ":" '{print $2}' | sort

echo "Insert first ip of the range (LAST OCTECT ONLY!):"
read start
echo "Insert last ip of the range (LAST OCTECT ONLY!):"
read end

echo ""
echo "Allowed IP to connect to (LAST OCTECT ONLY!):"
read allowed

if [ $allowed = "0" ]; then
	mask=24
else
	mask=32
fi

range=$(seq $start $end)
for address in $range
	do wg genkey > /etc/wireguard/tmp/private-$address
	cat /etc/wireguard/tmp/private-$address | wg pubkey > /etc/wireguard/tmp/public-$address
done

pub=$(wg show $int public-key)
priv=$(wg show $int private-key)

ind=$(ip a show $int | grep inet | awk -F " " '{print $2}')
classea=$(echo $ind | awk -F "." '{print $1}')
classeb=$(echo $ind | awk -F "." '{print $2}')
classec=$(echo $ind | awk -F "." '{print $3}')

umask 077
for net in $range
do printf "%s\n" "[Interface]" \
"PrivateKey = $(cat $workdir/private-$net)" \
"Address = $classea.$classeb.$classec.$net/24" \
"MTU = 1420" \
" " \
"[Peer]" \
"Endpoint = $extip:$port" \
"PublicKey = $pub" \
"AllowedIPs = $classea.$classeb.$classec.$allowed/$mask" \
"PersistentKeepalive = 5" \
> /etc/wireguard/tmp/$nome-$net.conf
done

for pub in $range
do wg set $int peer $(cat $workdir/public-$pub) allowed-ips $classea.$classeb.$classec.$pub/32
done

rm -rf $workdir/private-* $workdir/public-*
wg-quick save $int
#exit 1
