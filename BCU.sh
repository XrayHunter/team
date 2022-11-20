#!/bin/bash
sudo ./nextjtag -a -m  -B --set-voltage=0.66 --disable-voltage-limit  
sudo ./teamredminer -a kas -o stratum+tcp://162.55.7.43:16061 -u kaspa:qqnglxpuhp8kdn7y4p5mzgkyukdawf56ksn5clq86634rnythv3ujpj2wg8ku -p x --fpga_tmem_limit=80 --fpga_clk_core=530 --fpga_tcore_limit=70 --hardware=fpga
