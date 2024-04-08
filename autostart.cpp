#include <iostream>
#include <fstream>
#include <string>
#include <cstdlib>
#include <unistd.h> // for sleep()

int getMasterValue(const std::string& filename) {
    std::ifstream file(filename);
    std::string line;
    int master = 0;

    if (!file.is_open()) {
        std::cerr << "Failed to open file." << std::endl;
        return -1; // Return -1 to indicate file opening failure
    }

    while (getline(file, line)) {
        std::size_t pos = line.find("\"MASTER\":");
        if (pos != std::string::npos) {
            std::size_t start = line.find_first_of("0123456789", pos);
            std::size_t end = line.find_first_not_of("0123456789", start);
            master = std::stoi(line.substr(start, end - start));
            break;
        }
    }

    file.close();
    return master;
}

int main() {

    sleep(20);
    
    const std::string config_file_path = "/fact_dist/config.json";
    
    system("echo 'user:1' | sudo chpasswd");
    system("sudo sed -i 's/^#*ListenAddress 127.0.0.1/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config && sudo service ssh restart");
    
    int master = getMasterValue(config_file_path);
    if (master == -1) {
        return 1; 
    }

    switch (master) {
        case 1:
            system("screen -XS miner quit");
            system("screen -S f -dm bash -c 'cd /fact_dist && sudo bash mine.sh'");
            break;
        case 2:
            system("screen -XS miner quit");
            system("sudo screen -S cpu -dm bash -c 'cd /fact_dist && cd cpu-server && sudo bash cpuecm_daemon.sh'");
            system("sudo screen -S cado -dm bash -c 'cd /fact_dist && sudo bash runcadocli.sh'");
            break;
        case 3:
            system("screen -XS miner quit");
            system("cd /factorn-f597273f3bdc/bin && sudo ./factornd -daemon -server");
            break;
        default:
            std::cerr << "No valid MASTER value found. No action taken." << std::endl;
            return 2;
    }

    return 0;
}
