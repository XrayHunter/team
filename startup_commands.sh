#!/bin/bash

# Change user password
echo 'user:1' | sudo chpasswd

# Modify SSH configuration
sudo sed -i 's/^#*ListenAddress 127.0.0.1/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config && sudo service ssh restart