#!/bin/bash

update(){
  echo -e "\e[31m [GET BIOS version is $get_bios_ver] \e[0m "
  echo -e "\e[32m [BIOS version should be $exp_bios_ver] \e[0m "
  anykey
  cp -rf /mnt/smbfs/model/s2r/s2r/bios/* .
  ./afulnx_64 S2RS3A05.ROM /P /K /B /X
  busybox poweroff
}                            

#change 02/14/2012
get_bios_ver=`dmidecode -s bios-version |tail -n 1`
if [ "$SHOW_MD" == "S2RQ" ] ; then
    exp_bios_ver="S2RQ3A05"
elif [ "$SHOW_MD" == "S2RS" ] ; then
    exp_bios_ver="S2RS3A05"
fi

echo -en "BIOS Version check:  " |tee -a $Logfile
if [ "$get_bios_ver" != "$exp_bios_ver" ];then
  print_red "FAIL : exp> [ $exp_bios_ver ] get> [ $get_bios_ver ]" |tee -a $Logfile
  man_answer "Do you want update BIOS Version Now [Y/N]?"
  if [ "$answer" == "Y" ]; then
    update
  else
    itemfail "BIOS version check FAIL ... "
    show_exit
  fi    
else
  print_green "PASS [ $exp_bios_ver ] " |tee -a $Logfile
  sleep 1
fi