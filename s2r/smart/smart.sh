#!/bin/sh
RUNmin=60
MEMSIZE=`cat /proc/meminfo | egrep 'MemTotal'`
MEM=`echo $MEMSIZE | awk '{print $2}'`
Rsize=$((MEM/1024/12))
#mkdir /usr/lib
#mkdir /usr/sbin
cp smartlib/* .
cp smartsbin/* .
cp bin/* .

dmesg -c > /dev/null
LD_LIBRARY_PATH=. ./smartd --interval=1200
insmod edac_mc.ko
clear
#i=0
#while [ $i -lt 10 ];do
#LD_LIBRARY_PATH=. ./memtester4 $Rsize 1 > "MEM$i.log" &
#  i=$((i+1))
#done

SDAsize=`cat /sys/block/sda/size`
Gsize=$((SDAsize/1024/1024/2))
dd if=/dev/sda of=/dev/null bs=1024M count=$Gsize &
LD_LIBRARY_PATH=. ./smart sda &
dd if=/dev/sdb of=/dev/null bs=1024M count=$Gsize &
LD_LIBRARY_PATH=. ./smart sdb &
dd if=/dev/sdc of=/dev/null bs=1024M count=$Gsize &
LD_LIBRARY_PATH=. ./smart sdc &
dd if=/dev/sdd of=/dev/null bs=1024M count=$Gsize &
LD_LIBRARY_PATH=. ./smart sdd &
dd if=/dev/sde of=/dev/null bs=1024M count=$Gsize &
LD_LIBRARY_PATH=. ./smart sde &
dd if=/dev/sdf of=/dev/null bs=1024M count=$Gsize &
LD_LIBRARY_PATH=. ./smart sdf &

#LD_LIBRARY_PATH=. ./cdmesg  &
#LD_LIBRARY_PATH=. ./Tedac &
#LD_LIBRARY_PATH=. ./WSMx64 -P100 -D$RUNmin

i=0
if [ -f Result.log ];then
  rm -f Result.log
fi  

#sleep 3600 
#sleep 21600 
sleep 1h

data=`cat SMART.log | egrep "failed"`
if [ $? == 0 ];then
  echo $data >> Result.log
fi

if [ ! -f Result.log ];then
  echo "PASS" > Result.log
fi  

cat Result.log
killall smart 2>/dev/null
killall smartctl  2>/dev/null
killall memtester 2>/dev/null
#killall Tedac
killall cdmesg 2>/dev/null
