#!/bin/bash
#---------------------------------------------------------------------#

#SF_LMAC1=`grep "^MAC1=" linkall.cfy |awk -F= '{print $2}'`
#SF_LMAC2=`grep "^MAC2=" linkall.cfy |awk -F= '{print $2}'` 
local_lmac1=`ifconfig eth0 | grep "eth0" |awk '{print $5}'| sed 's/://g'|tr "[a-z]" "[A-Z]"`
local_lmac2=`ifconfig eth1 | grep "eth1" |awk '{print $5}'| sed 's/://g'|tr "[a-z]" "[A-Z]"`
echo -en "LAN MAC1 [ $local_lmac1 ] check :  " |tee -a $Logfile
if [ "$MAC1" == "$local_lmac1" ] ; then
 	 print_green "PASS" |tee -a $Logfile
else
	print_red "FAIL exp> [ $MAC1 ]" |tee -a $Logfile
	show_exit
fi

echo -en "LAN MAC2 [ $local_lmac2 ] check :  "
if [ "$MAC2" == "$local_lmac2" ] ; then
	print_green "PASS" |tee -a $Logfile
else
	print_red "FAIL exp> [ $MAC2 ]" |tee -a $Logfile
fi
   
tmp=`echo $((16#$local_lmac1+1))`
tmp1=`printf "%012x" $tmp |tr '[:lower:]' '[:upper:]'`
if [ "$tmp1" != "$local_lmac2" ] ; then
	echo -e "-----------------------Warning----------------------------" |tee -a $Logfile
	echo -e "\e[33m LAN MAC or with wrong order\e[0m" |tee -a $Logfile
	echo -e "\e[32m$local_lmac1 + 1 == $tmp1 \e[0m" |tee -a $Logfile
	echo -e "\e[31m$local_lmac1 + 1 != $local_lmac2\e[0m" |tee -a $Logfile
	echo -e "\e[33m Please call PE or TE support it,thanks!!\e[0m" |tee -a $Logfile
	echo -e "-----------------------------------------------------------" |tee -a $Logfile
	show_exit
else 
	print_green "LAN MAC ADDRESS CHECK PASS" |tee -a $Logfile
	sleep 1
fi

