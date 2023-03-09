#!/bin/bash
IP=$(hostname -I)
sudo ./nextjtag -a -c -m
sudo ./nextjtag -a -m  -B --set-voltage=0.65 --disable-voltage-limit --enable-allmine-vcu-bmc --disable-known-bmc-check --enable-allmine-btu9p-bmc  
sudo ./teamredminer -a kas -o stratum+tcp://162.55.7.43:16061 -u kaspa:qrqk6ln46685zvdfsjtr2en4dxzuuas7093kgq8gza2stcqfhrwcww8kw60jm -o stratum+tcp://162.55.101.8:16061 -u kaspa:qrqk6ln46685zvdfsjtr2en4dxzuuas7093kgq8gza2stcqfhrwcww8kw60jm  -p x --fpga_tmem_limit=80 --fpga_tcore_limit=70 --hardware=fpga --api_listen=$IP --fpga_clk_core=600
