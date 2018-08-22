#!/bin/sh

#ver:0.01 2012/02/21
get_uut_lom_fw(){
	eth=`ifconfig -a |grep -B1 "inet addr:" |grep "eth" |awk '{print $1}'`
	get_lom_fw=`ethtool -i $eth |grep "firmware-version:" |awk '{print $2}'`
	echo -e "get uut lan firmware-version: $get_lom_fw" |tee -a $Logfile
}

exp_lom_fw(){
	#if lom fw upgrade need change about this
  if [ `dmidecode -s baseboard-version |tail -n 1` == "31S2RMB0040" ] || [ `dmidecode -s baseboard-version |tail -n 1` == "31S2RMB0050" ]; then
		exp_lom_fw="2.4-2"
	else
		exp_lom_fw="1.5-2"
	fi
}

lom_fw_chk(){
	exp_lom_fw
	get_uut_lom_fw
	if [ "$exp_lom_fw" != "$get_lom_fw" ]; then
		echo -en "Lan firmware check: exp> [ $exp_lom_fw ] "
		print_red "FAIL  get> [ $get_lom_fw ]"  |tee -a $Logfile
		show_exit
	else
		echo -en "Lan firmware check: exp> [ $exp_lom_fw ]"
		print_green "PASS"  |tee -a $Logfile
	fi

}

lom_fw_chk




