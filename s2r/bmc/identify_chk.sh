#!/bin/bash
#ver: 0.01 2012/02/21
ipmitool chassis identify force |tee -a $Logfile
  if [ $? -eq 0 ]; then
    print_green "identify on PASS " |tee -a $Logfile
    sleep 2
  else
    print_red "identify on FAIL " |tee -a $Logfile
    show_exit
  fi

ipmitool chassis identify off |tee -a $Logfile
  if [ $? -eq 0 ]; then
    print_green "identify off PASS " |tee -a $Logfile
    sleep 1
  else
    print_red "identify off FAIL" |tee -a $Logfile
    show_exit
  fi  

man_answer "Please press identify and check PASS or FAIL [Y/N]?"
echo ".$answer."
if [ "$answer" == "Y" ] || [ "$answer" == "P" ]; then
  print_green "OP check identify PASS " |tee -a $Logfile
else
  print_red "OP check identify FAIL " |tee -a $Logfile
  show_exit
fi
#man_answer  "\e[35m==>FR Check PASS[Y]or FAIL[N]?\e[0m"
#if [ "$answer" == "Y" ] || [ "$answer" == "P" ]; then 
#        print_green "FRU Information check PASS ..." |tee -a $Logfile
#else
#        itemfail "FRU Check Fail !!!"
#        print_green "FRU Information check FAIL ..." |tee -a $Logfile
#        show_exit
#fi
