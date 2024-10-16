#!/bin/bash
IP=$(hostname -I)
sudo ./nextjtag -a -c -m
sudo ./nextjtag -a -m  -B --set-voltage=0.65 --disable-voltage-limit --enable-allmine-vcu-bmc --disable-known-bmc-check --enable-allmine-btu9p-bmc  
sudo ./teamredminer -a kas -o stratum+tcp://eu.kaspa.k1pool.com:3112 -u kaspa:qzep5zpw3cwhxrdk4vaeeh39ps0983vcxpnq0vgv203gv6dqvjftwes3v78zr -o stratum+tcp://162.55.101.8:16061 -u kaspa:qzep5zpw3cwhxrdk4vaeeh39ps0983vcxpnq0vgv203gv6dqvjftwes3v78zr.failover  -p x --fpga_tmem_limit=80 --fpga_tcore_limit=70 --hardware=fpga --api_listen=$IP --fpga_clk_core=600
