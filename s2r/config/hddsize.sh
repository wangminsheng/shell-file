#!/bin/bash
 
raid_hddcheck()
{
  rm -f tmp.log
  fdisk -l |grep "Disk /dev/sd" >tmp.log
  get_hdd_size_GB=`grep 'GB' tmp.log |awk '{print $3}' `
  get_hdd_size_MB=` echo $get_hdd_size_GB |awk '{print $1*1024}'  `
  sfc_hdd_size="500000"
  sfc_hdd_num="1"
#  sfc_hdd_size=` echo $HDD |awk -F\; '{print $1}' |awk -FM '{print $1}' `


#get hdd driver letter for HDD test
 DIAG_HDD_DRV=`grep 'GB' tmp.log |awk '{print $2}' |cut -c6-8`


#  sfc_hdd_num=` echo $HDD |awk -F\; '{print NF}' `
  
  sfc_total_size=$(($sfc_hdd_size * $sfc_hdd_num))
  if [ $get_hdd_size_MB -lt `expr $sfc_total_size - 15000 ` ] || [ $get_hdd_size_MB -gt `expr $sfc_total_size + 15000 ` ]; then
    echo " get HDD size is $get_hdd_size_MB MB"
    echo " SFC HDD size is $sfc_total_size MB"    
    itemfail " HDD Size should be $sfc_hdd_size MB "
#    send_log "HDD Size Check FAIL"
    show_exit
   else
   echo -e  " \e[32m[HDD  Check OK]: $sfc_hdd_num  x $sfc_hdd_size MB  \e[0m "
   sleep 3
#   send_log "HDD Size Check PASS"
  fi
}

no_raid_hddcheck()
{
 rm -f tmp.log
 fdisk -l |grep "Disk /dev/sd" >tmp.log
 get_hdd_num=`grep -c "GB" tmp.log`
 get_hdd_size_GB=`head -n 1 tmp.log |awk '{print $3}'`
 get_hdd_size_MB=`echo $get_hdd_size_GB |awk '{print $1*1024}'` 
 sfc_hdd_size=` echo $HDD |awk -F\; '{print $1}' |awk -FM '{print $1}' `
 sfc_hdd_num=` echo $HDD |awk -F\; '{print NF}' `
 
 if [ "$get_hdd_num" != "$sfc_hdd_num" ];then
    echo "get HDD number is $get_hdd_num"
    echo "SFC HDD number is $sfc_hdd_num"
    itemfail "HDD number check fail !"
    read
    lhand -z $mnt_monitor_path -l -s -L "HDD check fail!"
    send_log "HDD Size Check FAIL"
    show_exit
 fi
 if [ $get_hdd_size_MB -lt `expr $sfc_hdd_size - 2048 ` ] || [ $get_hdd_size_MB -gt `expr $sfc_hdd_size + 2048 ` ] ;then
    echo " get HDD size is $get_hdd_size_MB MB"
    echo " SFC HDD size is $sfc_hdd_size MB"    
    itemfail " HDD Size should be $sfc_hdd_size MB "
    read
    lhand -z $mnt_monitor_path -l -s -L "HDD check fail!"
    send_log "HDD Size Check FAIL"
    show_exit
 fi
 
 echo -e  " \e[32m[HDD  Check OK]: $get_hdd_num  x $get_hdd_size_GB GB  (HDD Type: $HDD_TYPE)\e[0m "
 sleep 3
 send_log "HDD Size Check PASS"
}


#if [ -z $RAID_CARD ] ;then
#   no_raid_hddcheck
#else 
   raid_hddcheck
#fi

