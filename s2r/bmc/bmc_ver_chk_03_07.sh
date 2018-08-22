#!/bin/sh
exp_bmc_ver="2.13"
ipmitool mc info >bmc_info.tmp
if [ $? -eq 0 ];then
  get_bmc_ver=`cat bmc_info.tmp |grep "Firmware Revision" |awk '{print $4}'`
  if [ "$exp_bmc_ver" != "$get_bmc_ver" ]; then
    print_red "BMC Firmware Revsion check FAIL ! exp> [ $exp_bmc_ver] get> [ $get_bmc_ver ]" |tee -a $Logfile
    cat bmc_info.tmp >>$Logfile
    show_exit
  else
    print_green "BMC Firmware Revsion check PASS ! [ $exp_bmc_ver ]" |tee -a $Logfile
    cat bmc_info.tmp >>$Logfile
    sleep 1
  fi
else
  print_red "BMC Version check FAIL " |tee -a $Logfile
  echo "Use command [ ipmitool mc info] fail " >>$Logfile
  show_exit
fi
  
