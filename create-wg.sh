#!/bin/bash
clear

echo "Inserire indirizzo dell'interfaccia: (esempio: 172.25.1.1)"
read II
echo "inserire subnet (esempio: 172.25.1.0)"
read SUB
echo "***"
echo ""
echo "inserire CIDR (8,16,18,23,24,28,32)"
read MASK
echo "***"
echo ""
echo "inserire nome interfaccia wireguard:"
read NI
echo "***"
echo ""
echo "inserire ListenPort:"
read P
echo "***"
echo ""

FILE=$NI.conf
echo "creazione file di conf"

printf "[Interface] %s\n" >> /etc/wireguard/tmp/$FILE
printf "Address = $II/$MASK %s\n" >> /etc/wireguard/tmp/$FILE
printf "SaveConfig = true %s\n" >> /etc/wireguard/tmp/$FILE

printf "PostUp = iptables -A FORWARD -i $NI -j ACCEPT %s\n" >> /etc/wireguard/tmp/$FILE
printf "PostUp = iptables -t nat -A POSTROUTING -o $NI -j MASQUERADE %s\n" >> /etc/wireguard/tmp/$FILE
printf "PostUp = ufw route insert 1 allow from $SUB/$MASK to $SUB/$MASK %s\n" >> /etc/wireguard/tmp/$FILE
printf "PostUp = ufw route insert 2 deny from $SUB/$MASK to 0.0.0.0/0 %s\n" >> /etc/wireguard/tmp/$FILE
printf "PostUp = ufw insert 1 allow from any to any port $P proto udp %s\n" >> /etc/wireguard/tmp/$FILE

printf "PostDown = iptables -D FORWARD -i $NI -j ACCEPT %s\n" >> /etc/wireguard/tmp/$FILE
printf "PostDown = ufw route delete allow from $SUB/$MASK to $SUB/$MASK %s\n" >> /etc/wireguard/tmp/$FILE
printf "PostDown = ufw route delete deny from $SUB/$MASK to 0.0.0.0/0 %s\n" >> /etc/wireguard/tmp/$FILE
printf "PostDown = ufw delete allow from any to any port $P proto udp %s\n" >> /etc/wireguard/tmp/$FILE
printf "PostDown = iptables -t nat -D POSTROUTING -o $NI -j MASQUERADE %s\n" >> /etc/wireguard/tmp/$FILE
printf "ListenPort = $P %s\n" >> /etc/wireguard/tmp/$FILE

KEY=$(wg genkey)
printf "PrivateKey = $KEY %s\n" >> /etc/wireguard/tmp/$FILE
