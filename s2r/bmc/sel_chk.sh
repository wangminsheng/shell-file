#!/bin/bash

ipmitool mc selftest |grep -q "passed"
  if [ $? -ne 0 ];then
      echo "mc selftest FAIL" >>$Logfile
      show_exit
  fi

ipmitool sel elist >sel.tmp
cat sel.tmp | egrep -i "(ECC|going high|going low|fan|temp)"
  if [ $? -eq 0 ];then
    echo "BMC SEL FAIL" >>$Logfile
    cat sel.tmp | egrep -i "(ECC|going high|going low)" |tee -a $Logfile
    show_exit
  fi




