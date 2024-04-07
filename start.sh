#!/bin/bash
IP=$(hostname -I)
#sudo ./nextjtag -a -m  -B --set-voltage=0.60 --disable-voltage-limit  
sudo ./teamredminer -a alph -o stratum+tcp://de.vipor.net:5051 -u 18W8Nz5ZXhoDiQedakCScitnDkT844AzUdeysDX8yfDsJ.TH -p x --fpga_tmem_limit=80 --fpga_clk_core=600 --fpga_er_auto=3 --fpga_tcore_limit=65 --hardware=fpga --api_listen=$IP --fpga_vcc_int=700
