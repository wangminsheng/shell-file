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

