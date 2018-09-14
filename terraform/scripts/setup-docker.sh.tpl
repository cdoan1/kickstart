#!/bin/bash

# SELINUX
sudo sed -i.bak 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config
if [ -f /etc/cloud/cloud.cfg ]; then
    sudo sed -i.bak -e 's/^ - set_hostname/# - set_hostname/' \
    -e 's/^ - update_hostname/# - update_hostname/' \
    /etc/cloud/cloud.cfg
fi

# install required packages
sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
subscription-manager repos --enable "rhel-*-optional-rpms" --enable "rhel-*-extras-rpms"
sudo yum -y -q update
sudo yum -y -q install ansible pyOpenSSL python-cryptography python-lxml
sudo yum -y -q install docker device-mapper-libs device-mapper-event-libs
sudo yum -y -q install golang
sudo yum install -y -q wget git net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct

if [ -f ~/.ssh/id_rsa ]; then
    chmod 0600 ~/.ssh/id_rsa
fi

# DOCKER
systemctl start docker.service
systemctl enable docker.service
systemctl restart docker.service
systemctl status docker.service

iptables -A INPUT -i eth1 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i eth1 -j DROP
