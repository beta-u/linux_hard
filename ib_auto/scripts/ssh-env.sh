#!/bin/bash

touch /root/.mpd.conf
chmod 600 /root/.mpd.conf
echo "MPD_SECRETWORD=mr45-j9z" > /root/.mpd.conf
touch /etc/mpd.conf
chmod 600 /etc/mpd.conf
echo "MPD_SECRETWORD=111111" > /etc/mpd.conf

echo -e "192.168.1.1 m1\n192.168.1.2 m2" >/etc/hosts
echo -e "m1\nm2" > /root/.mpd.hosts

#ssh-keygen -t rsa
scp root@m1:/root/.ssh/id_rsa.pub root@m2:/root/.ssh/authorized_keys
scp root@m2:/root/.ssh/id_rsa.pub root@m1:/root/.ssh/authorized_keys

