#!/bin/bash
get_cpu_num=` dmidecode -t 4 |grep "Current Speed" |grep -c "MHz" `
get_cpu_speed=` dmidecode -t 4|grep "Current Speed" |grep "MHz" |head -n 1 |awk '{print $3}' `
sfc_cpu_num=` echo $PROCESSOR |awk -F\; '{print NF}' `
sfc_cpu_speed=` echo $PROCESSOR |awk -F\; '{print $1}' |awk -FG '{print $1}' `
sfc_cpu_speed_MHz=` echo $sfc_cpu_speed |awk '{print $1*1000}' `
if [ "$get_cpu_num" != "$sfc_cpu_num" ] ;then
    echo " Current CPU number is $get_cpu_num ; SFC define CPU number is $sfc_cpu_num"
    itemfail " CPU number check error !"
    anykey
    lhand -z $mnt_monitor_path -l -s -L "CPU check fail!"
    send_log "CPU Number Check FAIL"
    show_exit
fi

if [ $get_cpu_speed -lt `expr $sfc_cpu_speed_MHz - 100 ` ] || [ $get_cpu_speed -gt `expr $sfc_cpu_speed_MHz + 100 ` ] ;then
    echo " Current CPU speed is $get_cpu_speed ; SFC define CPU speed is $sfc_cpu_speed_MHz"
    itemfail " CPU speed check error !"
    anykey
    lhand -z $mnt_monitor_path -l -s -L "CPU check fail!"
    send_log "CPU Speed Check FAIL"
    show_exit
fi
echo -e "\e[32m [CPU  Check OK]: $get_cpu_num  x $get_cpu_speed MHz \e[0m"
sleep 3
send_log "CPU Number Check PASS"
