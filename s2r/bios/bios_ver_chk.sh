#!/bin/bash

update(){
  print_yellow "[GET BIOS version is $get_bios_ver] "
  print_green "[BIOS version should be $exp_bios_ver]"
  if [ -f /host_test/firmware/$SHOW_MD/bios/$exp_bios_ver.rom ]; then
  	cp -rf /host_test/firmware/$SHOW_MD/bios/$exp_bios_ver.rom .
  	sleep 1
  else
  	print_red "Can not found the file [ /host_test/firmware/$SHOW_MD/bios/$exp_bios_ver.rom ]" |tee -a $Logfile
  	print_yellow "Please call TE to support this" |tee -a $Logfile
  	show_exit
  fi
  	
  	
  ./afulnx_64 $exp_bios_ver.rom /P /K /B /X
  if [ $? -eq 0 ]; then
  	print_green "BIOS ON LINE upgrade ok . system will reboot, please wait ..." |tee -a $Logflie
  	sleep 1
  	
  	reboot -f
  	sleep 100
  else
  	print_red "BIOS ON LINE upgrade FAIL ." |tee -a $Logfile
  	show_exit
  fi
}                            

#change 02/14/2012
get_bios_ver=`dmidecode -s bios-version |tail -n 1`
if [ "$SHOW_MD" == "S2RQ" ] && [ "$CONFIG" == "1S2RZZZ0ST5" ]; then

    exp_bios_ver="S2RQ3A05"
elif [ "$SHOW_MD" == "S2RQ" ] && [ "$CONFIG" == "1S2RZZZ0ST6" ]; then
    exp_bios_ver="S2RQ3A06"
elif [ "$SHOW_MD" == "S2RQ" ] && [ "$CONFIG" == "1S2RU9Z0ST1" ]; then
    #cut in time 2012/03/27
    exp_bios_ver="S2RQ3A06"
elif [ "$SHOW_MD" == "S2RS" ] && [ "$CONFIG" == "1S2RZZZ0STA" ]; then
    exp_bios_ver="S2RS3A05"
    #cut in time 2012/03/28 W/O 311044987
    exp_bios_ver="S2RS3A06"
    
elif [ "$SHOW_MD" == "S2RS" ] && [ "$CONFIG" == "1S2RZZZ0STE" ]; then
    #cut in time 2012/03/19
    exp_bios_ver="S2RS3A05"
elif [ "$SHOW_MD" == "S2RS" ] && [ "$CONFIG" == "1S2RZZZ0STC" ]; then
    #cut in time 2012/03/22
    exp_bios_ver="S2RS3A05"
elif [ "$SHOW_MD" == "S2RS" ] && [ "$CONFIG" == "1S2RUBZ0ST3" ]; then
    #cut in time 2012/03/30
    exp_bios_ver="S2RS3A06"
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