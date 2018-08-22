#!/bin/sh
update_bmc(){
  print_green "Expect [ $SHOW_MD ] [ $CONFIG ] BMC version is : $exp_bmc_ver" |tee -a $Logfile
  print_yellow "Get UUT [ $QCISN ] [ $SHOW_MD ] [ $CONFIG ] BMC version is: $get_bmc_ver" |tee -a $Logfile
  if [ ! -f /host_test/firmware/$SHOW_MD/bmc/rom$exp_bmc_ver.ima ]; then
  	print_red "Can not found file [ /host_test/firmware/$SHOW_MD/bmc/rom$exp_bmc_ver.ima ]"
  	print_yellow "Please call TE support."
  	show_exit
  else
  	cp -rf /host_test/firmware/$SHOW_MD/bmc/rom$exp_bmc_ver.ima .
  	sleep 2
  fi
  man_answer "Do you want upgrade the BMC version now ...[Y|N]?"
  echo ".$answer."
  if [ "$answer" == "Y" ] || [ "$answer" == "P" ]; then
     ./socflash_x64 -s rom$exp_bmc_ver.ima
     if [ $? -eq 0 ]; then
        print_green "BMC Version upgrade ok , Please wait 120 second for bmc reset ..." |tee -a $Logfile
        ipmitool bmc reset cold
        sleep_t 120
        return 0
     else
        print_red "BMC Version upgrade FAIL" |tee -a $Logfile
        show_exit
     fi
  else
        print_red "OP check identify FAIL " |tee -a $Logfile
        show_exit
  fi
}

#exp_bmc_ver="2.13"  
#exp_bmc_ver="3.2" #cut in time 2012/03/07 
if [ "$SHOW_MD" == "S2RQ" ] && [ "$CONFIG" == "1S2RZZZ0ST6" ] ; then
    exp_bmc_ver="3.2"
elif [ "$SHOW_MD" == "S2RQ" ] && [ "$CONFIG" == "1S2RZZZ0ST5" ] ; then
    exp_bmc_ver="2.13"
elif [ "$SHOW_MD" == "S2RQ" ] && [ "$CONFIG" == "1S2RU9Z0ST1" ] ; then
 #   cut in time 2012/03/27 
    exp_bmc_ver="3.5"
elif [ "$SHOW_MD" == "S2RS" ] && [ "$CONFIG" == "1S2RZZZ0STA" ]; then
    #exp_bmc_ver="2.13"
    #cut in time 2012/03/29 W/O 311044987
    exp_bmc_ver="3.5"
elif [ "$SHOW_MD" == "S2RS" ] && [ "$CONFIG" == "1S2RZZZ0STE" ]; then
    exp_bmc_ver="2.13"
elif [ "$SHOW_MD" == "S2RS" ] && [ "$CONFIG" == "1S2RZZZ0STC" ]; then
    exp_bmc_ver="2.13"
elif [ "$SHOW_MD" == "S2RS" ] && [ "$CONFIG" == "1S2RUBZ0ST3" ]; then
    #cut in time 2012/03/30
    exp_bmc_ver="3.5"
fi


for ((;;))
do
  ipmitool mc info >bmc_info.tmp
  if [ $? -eq 0 ];then
    get_bmc_ver=`cat bmc_info.tmp |grep "Firmware Revision" |awk '{print $4}'`
    if [ "$exp_bmc_ver" != "$get_bmc_ver" ]; then
      print_red "BMC Firmware Revsion check FAIL ! exp> [ $exp_bmc_ver] get> [ $get_bmc_ver ]" |tee -a $Logfile
      cat bmc_info.tmp >>$Logfile
      update_bmc
      continue
    else
      print_green "BMC Firmware Revsion check PASS ! [ $exp_bmc_ver ]" |tee -a $Logfile
      cat bmc_info.tmp >>$Logfile
      sleep 1
      break
    fi
  else
    print_red "BMC Version check FAIL " |tee -a $Logfile
    echo "Use command [ ipmitool mc info] fail " >>$Logfile
    show_exit
  fi
done  
