#!/bin/bash
get_ram_num=` dmidecode -t 17|grep "Size"|grep -c "MB" `
get_ram_single_size=` dmidecode -t 17|grep "Size" |grep "MB" |head -n 1 |awk '{print $2}' `
get_ram_total_size=` expr $get_ram_num \* $get_ram_single_size `
if [ "$sfc_config" == "1S2RZZZ0ST1" ];then
  sfc_ram_total_size="2048"
else
  sfc_ram_total_size="2048"
fi
#sfc_ram_total_size=` echo $MEMORY_INSTALLED_SIZE |awk -FM '{print $1}' `

if [ "$get_ram_total_size" != "$sfc_ram_total_size" ];then
    echo "current memory status is: $get_ram_num x $get_ram_single_size MB = $get_ram_total_size MB "
    echo "SFC define memory is: $MEMORY_INSTALLED_SIZE "
    itemfail "memory size should be $MEMORY_INSTALLED_SIZE   "
    anykey
#    lhand -z $mnt_monitor_path -l -s -L "memory check fail!"
#    send_log "MEMORY Check FAIL"
    show_exit
else
    echo -e "\e[32m [Mem  Check OK]: $get_ram_num x $get_ram_single_size MB\e[0m"
fi
sleep 3
#send_log "MEMORY Check PASS"
