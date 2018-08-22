#!/bin/bash
record_cpu_info(){
	rm -rf cpuinfo.log  
	get_cpu_physicl_num=`cat /proc/cpuinfo |grep "physical id" |sort |uniq |wc -l |sed 's/ //g'`
	get_cpu_cores_num=`cat /proc/cpuinfo |grep "cores" |uniq |awk '{print $4}'`
	get_cpu_siblings=`cat /proc/cpuinfo |grep "siblings"|sort |uniq |awk '{print $3}'`
	get_cpu_stepping=`cat /proc/cpuinfo |grep "stepping" |sort |uniq |awk '{print $3}'`
	get_cpu_speed=`dmidecode -t 4 |grep "Current Speed"|grep "MHz" |head -n 1 |awk '{print $3}'`
	get_cpu_full_name=`cat /proc/cpuinfo | grep "name" |awk -F: '{print $2}'|uniq` 
	get_cpu_name=`echo $get_cpu_full_name |awk '{print $4}'`
	echo -e "\e[33m$get_cpu_full_name\e[0m" |tee -a cpuinfo.log 
	echo -e "CPU_PHYSICL_NUM=\e[32m$get_cpu_physicl_num\e[0m" |tee -a cpuinfo.log
	echo -e "CPU_CORES_NUM=\e[32m$get_cpu_cores_num\e[0m" |tee -a cpuinfo.log
	echo -e "CPU_SIBLINGS=\e[32m$get_cpu_siblings\e[0m" |tee -a cpuinfo.log
	echo -e "CPU_STEPPING=\e[32m$get_cpu_stepping\e[0m" |tee -a cpuinfo.log
	echo -e "CPU_SPEED=\e[32m$get_cpu_speed\e[0m" |tee -a cpuinfo.log
	cat cpuinfo.log >>$Logfile
}

cpu_chk(){
	echo -en "CPU physicl number check:  "|tee -a $Logfile
	if [ "$exp_cpu_physicl_num" != "$get_cpu_physicl_num" ]; then
		print_red "FAIL [ exp> $exp_cpu_physicl_num get> $get_cpu_physicl_num ]" |tee -a $Logfile
		show_exit
	else
		print_green "PASS [ exp> $exp_cpu_physicl_num ]" |tee -a $Logfile
	fi
	echo -en "CPU name check :  "
	if [ "$exp_cpu_name" != "$get_cpu_name" ]; then
		print_red "FAIL [ exp> $exp_cpu_name get> $get_cpu_name ]" |tee -a $Logfile
		show_exit
	else
		print_green "PASS [ exp> $exp_cpu_name ]" |tee -a $Logfile
		
	fi

}
record_cpu_info

if [ "$CONFIG" == "1S2RU9Z0ST1" ]; then
	cp /test/s2r/linkall.cfy .
	exp_cpu_physicl_num=`cat linkall.cfy |grep "CPU SN=" |wc -l |sed 's/ //g'`
	exp_cpu_name="E5-2650"
	cpu_chk
elif [ "$CONFIG" == "1S2RUBZ0ST3" ]; then

	cp /test/s2r/linkall.cfy .
	exp_cpu_physicl_num=`cat linkall.cfy |grep "CPU SN=" |wc -l |sed 's/ //g'`
	exp_cpu_name="E5-2670"
	cpu_chk
fi

