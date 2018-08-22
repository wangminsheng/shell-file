#!/bin/bash


#for RUNIN check detail SEL
if [ "$SEL" != "" ]; then           #have serious sel
  ECC=`ipmitool sel list |egrep -ic "Correctable ECC"`      #if Correctable ECC>=3,need to check
	 if [ $ECC -ge 3 ]; then
	   lhand -z $mnt_monitor_path -l -s -L "Correctable ECC=$ECC times" 
	   
     print_red "Correctable ECC=$ECC times" |tee -a $Logfile	     
	 fi
fi
sleep 2
	echo "" |tee -a $Logfile
	echo "Get SEL from BMC, using ipmitool" |tee -a $Logfile
	ipmitool sel list |tee -a $Logfile

echo -e "\e[32m [BMC SEL Check OK] \e[0m"
print_green "BMCtest Check OK" |tee -a $Logfile