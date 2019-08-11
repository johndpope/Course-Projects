
cd '/home/vinod/20140524/makestuff/hdlmake/apps/makestuff/swled/cksum/vhdl'
../../../../../bin/hdlmake.py -t ../../templates/fx2all/vhdl -b atlys -p fpga
sudo ../../../../../../apps/flcli/lin.x64/rel/flcli -v 1d50:602b:0002 -i 1443:0007
sudo ../../../../../../apps/flcli/lin.x64/rel/flcli -v 1d50:602b:0002 -p J:D0D2D3D4:fpga.xsvf



cd '/home/vinod/20140524/makestuff/apps/flcli'
make deps

cd '/home/vinod/Downloads/xr_usb_serial_common_lnx-3.6-and-newer-pak'
make
sudo insmod ./xr_usb_serial_common.ko

sudo gtkterm -p /dev/ttyXRUSB0 -s 115200

cd '/home/vinod/20140524/makestuff/hdlmake/apps/makestuff/swled/cksum/vhdl'
sudo ../../../../../../apps/flcli/lin.x64/rel/flcli -v 1d50:602b:0002 -z