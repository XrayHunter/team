#!/usr/bin/bash
sleep 20
# Change user password
echo 'user:1' | sudo chpasswd                                                                                                                                                                                      
cp -R /fact_dist /ramdisk/fact_dist
sleep 5
# Modify SSH configuration
sudo sed -i 's/^#*ListenAddress 127.0.0.1/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config && sudo service ssh restart 
crontab -l | { cat; echo "@reboot sleep 3 && cp -R /fact_dist /ramdisk/fact_dist"; } | crontab -
crontab -l | { cat; echo "@reboot sleep 40 && /startup_commands.sh"; } | crontab - 
# Define the MASTER flag as 1, SLAVE flag as 2, different = stock hiveos
MASTER=0                                                                                                                                                                                                         

# Check if the MASTER flag is set to 1
if [ "$MASTER" == "1" ]; then
  # Run the master command in a detached screen session
  screen -S f -dm bash -c 'cd /ramdisk/fact_dist && sudo bash mine.sh'
  screen -XS miner quit                                                                                                                                                                                                                                                                                                                           
elif [ "$MASTER" == "2" ]; then
  # Run the slave command in a detached screen session
  sudo screen -S cpu -dm bash -c 'cd /fact_dist && cd cpu-server && sudo bash cpuecm_daemon.sh'
  sudo screen -S cado -dm bash -c 'cd /fact_dist && sudo bash runcadocli.sh'
  screen -XS miner quit                                                                                                                                                                                                                                                     
elif [ "$MASTER" == "3" ]; then
  # Run the slave command in a detached screen session
  cd /factorn-f597273f3bdc/bin && sudo ./factornd -daemon -server
  screen -XS miner quit      
fi
