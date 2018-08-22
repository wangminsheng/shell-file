#!/bin/bash
if [ "$STATION" == "FAT" ] ; then
  share_lom_bmc
  get_bmc_ip
  if [ $ret -eq 0 ]; then
    print_green "FAT share lom mode ping test PASS !!!" |tee -a $Logfile
    sleep 10
    dedicated_bmc
  else
    print_red "FAT share lom mode ping test FAIL!!!" |tee -a $Logfile
    show_exit
  fi
elif [ "$STATION" == "FFT" ]; then
  dedicated_bmc
  get_bmc_ip
  if [ $ret -eq 0 ]; then
    print_green "FFT dedicated mode ping test PASS !!!" |tee -a $Logfile
    sleep 10
    share_lom_bmc
  else
    print_red "FFT dedicated mode ping test FAIL!!!" |tee -a $Logfile
    show_exit
  fi
 elif [ "$STATION" == "FQA" ]; then
  share_lom_bmc
  get_bmc_ip
  if [ $ret -eq 0 ]; then
  	print_green "FQA share lom mode ping test PASS!!!" |tee -a $Logfile
  	sleep 10
  	share_lom_bmc
  else
  	print_red "FQA share lom mode ping test FAIL!!!" |tee -a $Logfile
  	show_exit
 fi
fi