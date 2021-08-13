#!/bin/bash

cd /root/git/wg

cp rc.local /etc/
cp rc.shutdown /etc/
chmod 750 /etc/rc.local
chmod 750 /etc/rc.shutdown
cp rc-local.service /etc/systemd/system/
cp rc-shutdown.service /etc/systemd/system/
systemctl enable rc-local.service
systemctl enable rc-shutdown.service
systemctl daemon-reload
exit 1

