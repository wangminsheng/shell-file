#!/bin/bash

################################# start test ###################################
rm -f /mnt/test_log/$SHOW_MD/$STATION/$QCISN.tmp                                  #for check test result

echo "**************************************************************************************************" |tee -a $Logfile
echo "$STATION TEST START ==^.^== " |tee -a $Logfile
cd /test/s2r/tools
ipmitool sel clear

#check SEL
cd /test/s2r/bmc
source ./chksel.sh

ipmitool sel clear

# ============================= passmark test ==================================
lhand -z $mnt_monitor_path -l -s -L "s2r Passmark test start!" 
cd /tmp
rm -f *.log
cd /test/s2r/bit
  if [ "$CONFIG" == "1S2RU9Z0ST1" ]; then
    source ./bit-L10.sh
  else
    source ./bit-L6.sh
  fi  
retstr=""
retstr=`egrep -i 'FAIL' /tmp/BIT_log.log`
cat /tmp/BIT_log.log >> /mnt/test_log/$SHOW_MD/$STATION/$QCISN.tmp
if [ ! -z "$retstr" ]; then		  	  	                                          #judge Fail/Error of diag   this mean fail
  print_red "Passmark test fail" |tee -a $Logfile                                                #need fail character to check whole runin result  
  itemfail "$retstr !!!" |tee -a $Logfile
  send_fail_to_sf "$QCISN $retstr"
#  echo "$retstr" > $log_path/$STATION/$QCISN=FAIL 
else
  lhand -z $mnt_monitor_path -l -s -L "s2r Passmark test finished!" 
  print_green "Passmark test pass" |tee -a $Logfile
fi

# ============================ QCILxdiag test ==================================
diagloop=40                                                                    #40 one hour
testloop=1
lhand -z $mnt_monitor_path -l -s -L "s2r $STATION QciLxdiag test start!" 
cd /test/s2r/QCILxDiag_V10
while [ $testloop -lt $diagloop ]
    do 
     rm -f Output.log
   if ! source diagrunin.sh  ; then
     itemfail "load diag.sh fail !!!"
     exit 0
   fi
  retstr=`egrep -i '(FAIL| abnormally| error)' Output.log`
   if [ ! -z "$retstr" ]; then		  	  	                                      #judge Fail/Error of diag   this mean fail
     itemfail "$MB_SN diagrunin.sh FAIL" |tee -a $Logfile
     show_exit
     print_red "QCILinux Test Fail" |tee -a $Logfile
     cat Output.log |tee -a $Logfile
   else
     echo "" |tee -a $Logfile
     sleep 3
     print_green "QCILinux Test Pass $testloop" |tee -a $Logfile
   fi
     let testloop=$(($testloop+1))
  done 
lhand -z $mnt_monitor_path -l -s -L "S2R QciLxdiag test finished!" 

# ============================== HDD smart ===================================== 
#lhand -z $mnt_monitor_path -l -s -L "S2R $STATION smart test start!"
#cd /test/s2r/smart
#if ! source ./smart.sh ; then
#    itemfail "load smart.sh fail !!!"
#    exit 0
#fi 
#send_log "smart Test PASS"
#lhand -z $mnt_monitor_path -l -s -L "S2R samrt test start!"

# ============================ check result ====================================
result=`egrep -i "(Fail|error|abnormal)" $Logfile`
if [ "$result" == "" ]; then
  touch /mnt/test_log/$SHOW_MD/$STATION/$QCISN=PASS
else                                                                            #fail
  send_fail_to_sf "$QCISN test fail : $result"
  print_red "Detail Fail Message is : "
  echo $result
  print_yellow "Please wait PE  to Anaysis ..."
  ipmitool sel list
  echo "$QCISN test result : $result" |tee -a $Logfile
  show_exit                                                                     #if fail,no need to poweroff
fi

#check SEL
echo "--record sel log to test log----------------" >>$Logfile
ipmitool sel elist -v >>$Logfile
echo "--------------------------------------------" >>$Logfile
echo "--record sdr to test log--------------------" >>$Logfile
ipmitool sdr list >>$Logfile
echo "--------------------------------------------" >>$Logfile

cd /test/s2r/bmc
source ./chksel.sh

cd /test/s2r/tools
ipmitool sel clear

# ============================ clear SEL log ===================================

ipmitool sel clear
sleep 3
print_green "Clear BMC Event Log OK" |tee -a $Logfile