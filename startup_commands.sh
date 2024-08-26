#!/usr/bin/bash
sleep 20
crontab -l | { cat; echo "@reboot sleep 40 && /startup_commands.sh"; } | crontab - 
(crontab -l 2>/dev/null; echo "*/10 * * * * /load.sh") | crontab -
# Change user password
echo 'user:1' | sudo chpasswd                                                                                                                                                                                      
sleep 5
# Modify SSH configuration
sudo sed -i 's/^#*ListenAddress 127.0.0.1/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config && sudo service ssh restart 
# Define the MASTER flag as 1, SLAVE flag as 2, different = stock hiveos
MASTER=0
screen -XS miner quit
sleep 1
screen -S tig -dm bash -c 'cd /tig-monorepo && sudo sysctl -w vm.nr_hugepages=0 && sudo bash start.sh'
sleep 1
tmux new-session -d -s tig "bash -c 'cd /tig-monorepo && sudo bash start2.sh'"
# Check if the MASTER flag is set to 1
if [ "$MASTER" == "1" ]; then
  # Run the master command in a detached screen session
  screen -XS miner quit
  screen -S f -dm bash -c 'cd /home/fact/fact_dist && sudo sysctl -w vm.nr_hugepages=0 && sudo bash fact_miner.sh'
elif [ "$MASTER" == "2" ]; then
  # Run the slave command in a detached screen session
  screen -XS miner quit
  screen -S slave -dm bash -c 'cd /home/fact/fact_dist && sudo sysctl -w vm.nr_hugepages=0 && sudo bash fact_miner.sh'
elif [ "$MASTER" == "3" ]; then
  # Run the slave command in a detached screen session
  cd /factorn-f597273f3bdc/bin && sudo ./factornd -daemon -server
  screen -XS miner quit
fi
