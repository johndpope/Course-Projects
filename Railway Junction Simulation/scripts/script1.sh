m=$(ls /dev/tty* | grep XRUSB | head -n1)
n=$(ls /dev/tty* | grep XRUSB | tail -n1)
echo $m
echo $n

sudo python uart2.py $m $n