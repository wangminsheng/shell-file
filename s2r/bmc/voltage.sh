#!/bin/bash
#check cmos voltage
#ver: 0.01 2012/02/21
ipmitool sdr list |grep P3V_BAT |grep ok
if [ "$?" != "0" ];then
     itemfail "CMOS Voltage test fail,please check ...." |tee -a $Logfile
     show_exit
else
     print_green "CMOS Voltage test PASS !!" |tee -a $Logfile
fi
