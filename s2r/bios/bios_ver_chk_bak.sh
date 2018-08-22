#!/bin/bash

update(){
  print_yellow "[GET BIOS version is $get_bios_ver] "
  print_green "[BIOS version should be $exp_bios_ver]"
  if [ -f /host_test/common/$SHOW_MD/bios/$exp_bios_ver.rom ]; then
  	cp -rf /host_test/common/$SHOW_MD/bios/$exp_bios_ver.rom .
  	sleep 1
  else
  	print_red "Can not found the Expect bios version file in the server ..." |tee -a $Logfile
  	print_yellow "Please call TE to support this" |tee -a $Logfile
  	show_exit
  fi
  	
  	
  ./afulnx_64 $exp_bios_ver.rom /P /K /B /X
  reboot -f
  sleep 100
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
  echo ".$answer."
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