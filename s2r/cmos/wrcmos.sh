#!/bin/bash

clear 
echo ""
echo -e "\e[35m ================= Will write BIOS setting information ==================\e[0m "
wrcmos -w $CONFIG

if [ "$?" == "0" ] ; then
  print_green "BIOS setting is ok" |tee -a $Logfile
  sleep 1
else
  print_red "BIOS setting is Fail ! " |tee -a $Logfile
  sleep 1
  show_exit
fi