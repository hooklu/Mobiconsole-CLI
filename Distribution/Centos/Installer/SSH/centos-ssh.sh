#!/bin/bash

#Get the necessary components
yum install openssh-server -y

#Setup the necessary files
wget https://raw.githubusercontent.com/MobilinuxApp/Mobiconsole-CLI/master/Distribution/Centos/Installer/SSH/sshd_config -P /etc/ssh

echo "You can now start OpenSSH Server by running /etc/init.d/sshd start"
echo " "
echo "The Open Server will be started at 127.0.0.1:22"
