#!/bin/bash
# Postinstall script for PuppyPic

# Set the hostname
hostname puppypic1
echo puppypic1 > /etc/hostname
sed -i "s/127.0.0.1 localhost/127.0.0.1 localhost puppypic1 salt/" /etc/hosts

# Install and configure SaltStack, and highstate the machine
echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" > /etc/apt/sources.list.d/saltstack.list
wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | apt-key add -
apt-get update; apt-get -y upgrade
apt-get install -y salt-minion salt-master git
sleep 12
salt-key -ya puppypic1
git clone https://github.com/eddpayne/samarium-saltstack.git /srv/salt
git clone https://github.com/eddpayne/samarium-pillar.git /srv/pillar
