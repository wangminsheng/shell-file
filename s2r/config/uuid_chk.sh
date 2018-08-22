#!/bin/sh
uuid_chk(){
	get_full_uuid=`dmidecode -s system-uuid |tail -n 1`
	tmp_uuid=`echo "$get_full_uuid" | awk -F\- '{print $2$1}'`
	get_bmc_mac=`ipmitool lan print 1 |grep "MAC Address   " |awk '{print $4}' |sed 's/://g' |tr [a-z] [A-Z]`
	echo -en "System UUID [ $get_full_uuid ] check :  " |tee -a $Logfile
	if [ "$tmp_uuid" == "$get_bmc_mac" ]; then
		echo -e "\e[32mPASS\e[0m" |tee -a $Logfile
		return 0
	else
		echo -e "\e[31mFAIL\e[0m" |tee -a $Logfile
		return 1
	fi
}

bmc_mac_chk(){
	echo -en "BMC MAC Check: [ $get_bmc_mac ] :  " |tee -a $Logfile
	if [ "$BMCMAC" == "$get_bmc_mac" ]; then
		echo -e "\e[32mPASS\e[0m" |tee -a $Logfile
		return 0
	else
		echo -e "\e[31mFAIL exp> [ $SF_BMC ]\e[0m" |tee -a $Logfile
		return 1
	fi
}

if ! uuid_chk ; then
	itemfail "UUID Check FAIL!!"
  show_exit
fi

if ! bmc_mac_chk ; then
	itemfail "BMC MAC Check FAIL!!"
  show_exit
fi
