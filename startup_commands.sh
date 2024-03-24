#!/usr/bin/bash

# Change user password
echo 'user:1' | sudo chpasswd                                                                                                                                                                                      

# Modify SSH configuration
sudo sed -i 's/^#*ListenAddress 127.0.0.1/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config && sudo service ssh restart                                                                                                 

# Define the MASTER flag as 1, SLAVE flag as 2, different = stock hiveos
MASTER=1                                                                                                                                                                                                           

# Check if the MASTER flag is set to 1
if [ "$MASTER" == "1" ]; then
  # Run the master command in a detached screen session
  screen -S f -dm bash -c 'cd /fact_dist && sudo bash mine.sh'
  screen -XS miner quit                                                                                                                                                                                            
  crontab -l | { cat; echo "@reboot sleep 20 && /startup_commands.sh"; } | crontab -                                                                                                                               
elif [ "$MASTER" == "2" ]; then
  # Run the slave command in a detached screen session
  sudo screen -S cpu -dm bash -c 'cd /fact_dist && cd cpu-server && sudo bash cpuecm_daemon.sh'
  sudo screen -S cado -dm bash -c 'cd /fact_dist && sudo bash runcadocli.sh'
  screen -XS miner quit                                                                                                                                                                                            
  crontab -l | { cat; echo "@reboot sleep 20 && /startup_commands.sh"; } | crontab -                                                                                                                               
fi
