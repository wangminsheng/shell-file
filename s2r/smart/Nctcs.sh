#!/bin/sh
RUNmin=60
MEMSIZE=`cat /proc/meminfo | egrep 'MemTotal'`
MEM=`echo $MEMSIZE | awk '{print $2}'`
Rsize=$((MEM/1024/64))
mkdir /usr/lib
mkdir /usr/sbin
cp smartlib/* /usr/lib
cp smartsbin/* /usr/sbin
dmesg -c > /dev/null
smartd --interval=1200
insmod edac_mc.ko
clear
i=0
while [ $i -lt 10 ];do
  ./memtester4 $Rsize 1 > "MEM$i.log" &
  i=$((i+1))
done
./smart sda &
./cdmesg  &
./Tedac &
./WSMx64 -P100 -D$RUNmin

i=0
if [ -f Result.log ];then
  rm -f Result.log
fi  

while [ $i -lt 10 ];do
  cat "MEM$i.log" | egrep "Done"
  if [ $? != 0 ];then
    cat "MEM$i.log" >> Result.log
  fi
  i=$((i+1))
done  

data=`cat SMART.log | egrep "failed"`
if [ $? == 0 ];then
  echo $data >> Result.log
fi
  
data=`cat EDAC.log | egrep "failed"`
if [ $? == 0 ];then
  echo $data >> Result.log
fi

data=`cat CDMESG.log | egrep "failed"`
if [ $? == 0 ];then
  echo $data >> Result.log
fi

if [ ! -f Result.log ];then
  echo "PASS" > Result.log
fi  

cat Result.log
