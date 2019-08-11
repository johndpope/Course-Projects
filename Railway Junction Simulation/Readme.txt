Team Name - HackStreet Boys


Team Members -
        Shubham Anand - 160050060
        Vinod Shekokar - 160050016
        Neelesh Verma - 160050062
        Sarthak Mallick - 160050070


Note: We have used the earlier convention TrackExists | TrackOk | Direction | NextSignal for transferring data from sliders to the host


--------------------------VHDL compilation--------------------------


cksum_rtl.vhdl is the top module, and its dependencies are:-


harness.vhdl
top_level.vhdl
board.ucf
baudrate_gen.vhd
uart_rx.vhd
uart_tx.vhd
decrypter.vhd
encrypter.vhd
debouncer.vhd
track_data.csv -


There are some dependencies with same name which have to placed in different directories.
For that we have provided the 20140524.tar.gz compressed folder which is same as the one provided to us during the checksum lab. Its structure is same and we have added and edited the above files as required.




----------------------------Mandatory part------------------------




Open hdlmake.sh and make required changes to the file paths. 


Run it on terminal to start communication with FPGA.




-----------------------------Optional part-------------------------------


We have used a laptop as a UART relay between the two boards.


Run the script1.sh and script2.sh on different terminals on the relay laptop


Run hdlmake.sh on terminal as before 


Note: pyserial library is required to run the python script which are run from within the bash script


Data transfer between the usb can be seen in the terminal which will be open in the relay laptop.