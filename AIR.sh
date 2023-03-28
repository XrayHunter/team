#!/bin/bash
IP=$(hostname -I)
sudo ./nextjtag -a -c -m
sudo ./nextjtag -a -m  -B --set-voltage=0.63 --disable-voltage-limit --enable-allmine-vcu-bmc --disable-known-bmc-check --enable-allmine-btu9p-bmc  
sudo ./teamredminer -a kas -o stratum+tcp://162.55.7.43:16061 -u kaspa:qqnglxpuhp8kdn7y4p5mzgkyukdawf56ksn5clq86634rnythv3ujpj2wg8ku.AIR -o stratum+tcp://eu.kaspa.k1pool.com:3112 -u kaspa:qqnglxpuhp8kdn7y4p5mzgkyukdawf56ksn5clq86634rnythv3ujpj2wg8ku.AIRfailover -p x --fpga_tmem_limit=80 --fpga_clk_core=500 --fpga_tcore_limit=60 --hardware=fpga --api_listen=$IP
