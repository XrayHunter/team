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
  screen -S f -dm bash -c 'cd /home/fact/fact_dist && sudo sysctl -w vm.nr_hugepages=0 && sudo bash install.sh && cd /home/fact/fact_dist/cado-nfs/parameters/factor && wget http://192.168.13.45:8000/params.c124 && cd /home/fact/fact_dist && sudo bash fact_miner.sh'
  screen -XS miner quit
elif [ "$MASTER" == "2" ]; then
  # Run the slave command in a detached screen session
  screen -S slave -dm bash -c 'cd /home/fact/fact_dist && sudo sysctl -w vm.nr_hugepages=0 && sudo bash install.sh && cd /home/fact/fact_dist/cado-nfs/parameters/factor && wget http://192.168.13.45:8000/params.c124 && cd /home/fact/fact_dist && sudo bash fact_miner.sh'
  screen -XS miner quit
elif [ "$MASTER" == "3" ]; then
  # Run the slave command in a detached screen session
  cd /factorn-f597273f3bdc/bin && sudo ./factornd -daemon -server
  screen -XS miner quit
fi
