#!/bin/bash

#ver:0.01 2012/02/21

GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NORMAL="\033[0m"

#Color print and strcmp functions
print_green(){
	[ $# -eq 0 ] && return 1
	echo -e $GREEN$@$NORMAL
}

print_red(){
	[ $# -eq 0 ] && return 1
	echo -e $RED$@$NORMAL	
}

print_yellow(){
	[ $# -eq 0 ] && return 1
	echo -e $YELLOW$@$NORMAL
}

record_M1_fru(){
 ipmitool fru print 0 |tee -a $Logfile
 if [ $? -ne 0 ]; then
  print_red "Record Mother Board Fru form M1 FAIL" |tee -a $Logfile
  show_exit
 else
  print_green "Record Mother Board Fru form M1 PASS" |tee -a $Logfile
 fi
}

readfru(){	
  ipmitool fru print 0 |tee "$QCISN".tmp
  if [ $? -ne 0 ]; then
    print_red "MB fru read FAIL ..." |tee -a $Logfile
    cat "$QCISN".tmp >>$Logfile
    show_exit
   else
    print_green "MB fru read PASS ..." |tee -a $Logfile
    cat "$QCISN".tmp >>$Logfile
    dos2unix "$QCISN".tmp
  fi
}

writefru(){
   ./fru-tool-1210 -f $inifile -w < $QCISN.fru
   if [ $? -ne 0 ]; then
    print_red "MB Fru Write FAIL ..." |tee -a $Logfile
    show_exit
   else
    print_green "MB Fru Write PASS ..." |tee -a $Logfile
   fi 
}

clear
#main
record_M1_fru

if [ "$SHOW_MD" == "S2RQ" ] && [ `dmidecode -s baseboard-version |tail -n 1` == "31S2RMB0030" ]; then
  inifile="S2RQ_30-ini"
elif [ "$SHOW_MD" == "S2RQ" ] && [ `dmidecode -s baseboard-version |tail -n 1` == "31S2RMB0040" ]; then   
  inifile="S2RQ_40-ini"
elif [ "$SHOW_MD" == "S2RS" ] && [ `dmidecode -s baseboard-version |tail -n 1` == "31S2RMB0020" ]; then
  inifile="S2RS_20-ini"
elif [ "$SHOW_MD" == "S2RS" ] && [ `dmidecode -s baseboard-version |tail -n 1` == "31S2RMB0050" ]; then
  inifile="S2RS_50-ini"
fi   

echo -e "[ MODEL: $SHOW_MD ] [ CONIFIG: $CONFIG ] [ QCISN: $QCISN ] [ MBSN: $MB_SN ] Fru write start ..." |tee -a $Logfile
echo "$QCISN" >$QCISN.fru ; echo "$MB_SN" >>$QCISN.fru ; echo "$QCISN" >>$QCISN.fru
writefru
readfru
#auto check fru
if [ "$SHOW_MD" == "S2RQ" ]; then
  if [ `cat $QCISN.tmp |grep -c "S210-X22RQ"` -eq 2 ] && [ `cat $QCISN.tmp |grep -c "Quanta"` -eq 2 ] && [ `cat $QCISN.tmp |grep -c "$QCISN\>"` -eq 2 ] && [ `cat $QCISN.tmp |grep -c $MB_SN` -eq 1 ] && [ "$QCISN" != "$MB_SN" ];then
     print_green "Auto check MB fru PASS ..." |tee -a $Logfile
  else
     print_red "Auto check MB fru FAIL ..." |tee -a $Logfile
     show_exit
  fi
elif [ "$SHOW_MD" == "S2RS" ]; then
  if [ `cat $QCISN.tmp |grep -c "S210-X12RS"` -eq 2 ] && [ `cat $QCISN.tmp |grep -c "Quanta"` -eq 2 ] && [ `cat $QCISN.tmp |grep -c "$QCISN\>"` -eq 2 ] && [ `cat $QCISN.tmp |grep -c $MB_SN` -eq 1 ] && [ "$QCISN" != "$MB_SN" ];then
     print_green "Auto check MB fru PASS ..." |tee -a $Logfile
  else
     print_red "Auto check MB fru FAIL ..." |tee -a $Logfile
     show_exit
  fi
fi 

clear
echo 
echo
cat $QCISN.tmp
echo
echo
man_answer  "\e[35m==>FRU Check PASS[Y]or FAIL[N]?\e[0m"
if [ "$answer" == "Y" ] || [ "$answer" == "P" ]; then 
        print_green "FRU Information check PASS ..." |tee -a $Logfile
else
        itemfail "FRU Check Fail !!!"
        print_green "FRU Information check FAIL ..." |tee -a $Logfile
        show_exit
fi
