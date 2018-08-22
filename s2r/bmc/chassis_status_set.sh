#!/bin/bash
#chassis status check 
#ver: 0.01 2012/02/29
ipmitool chassis policy always-off
if [ $? -eq 0 ]; then
  print_green "set chassis policy always-off ok " |tee -a $Logfile
else
  print_red "set chassis policy always-off FAIL "|tee -a $Logfile
  show_exit
fi

