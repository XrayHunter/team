start gerate.bat
timeout 5
nextjtag.exe -a -c -m 
nextjtag.exe -a -m  -B --set-voltage= 0.66
nextjtag.exe  -a -m -b th55_v2.bit


timeout 2
start load20_TH55.bat
