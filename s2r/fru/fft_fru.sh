#!/bin/bash

#ver:0.01 2012/02/21

readfru(){	
  ipmitool fru print 0 >$QCISN.tmp
  if [ $? -ne 0 ]; then
    print_red "MB fru read FAIL ..." |tee -a $Logfile
    cat $QCISN.tmp >>$Logfile
    show_exit
   else
    print_green "MB fru read PASS ..." |tee -a $Logfile
    cat $QCISN.tmp >>$Logfile
    dos2unix $QCISN.tmp
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


if [ "$SHOW_MD" == "S2RQ" ] && [ `dmidecode -s baseboard-version |tail -n 1` == "31S2RMB0030" ]; then
  inifile="S2RQ_30-ini"
elif [ "$SHOW_MD" == "S2RQ" ] && [ `dmidecode -s baseboard-version |tail -n 1` == "31S2RMB0040" ]; then   
  inifile="S2RQ_40-ini"
elif [ "$SHOW_MD" == "S2RS" ] && [ `dmidecode -s baseboard-version |tail -n 1` == "31S2RMB0020" ]; then
  inifile="S2RS_20-ini"
elif [ "$SHOW_MD" == "S2RS" ] && [ `dmidecode -s baseboard-version |tail -n 1` == "31S2RMB0050" ]; then
  inifile="S2RS_50-ini"
fi   
clear
echo ""
echo -e "[ MODEL: $SHOW_MD ] [ CONIFIG: $CONFIG ] [ QCISN: $QCISN ] [ MBSN: $MB_SN ] Fru check start ..." |tee -a $Logfile
sleep 2
readfru
#auto check fru
if [ "$CONFIG" == "1S2RZZZ0ST4" ] || [ "$CONFIG" == "1S2RZZZ0ST5" ] || [ "$CONFIG" == "1S2RZZZ0ST6" ] || [ "$CONFIG" == "1S2RZZZ0ST7" ] || [ "$CONFIG" == "1S2RZZZ0ST8" ] || [ "$CONFIG" == "1S2RZZZ0ST9" ]; then
  if [ `cat $QCISN.tmp |grep -c "S210-X22RQ"` -eq 2 ] && [ `cat $QCISN.tmp |grep -c "Quanta"` -eq 2 ] && [ `cat $QCISN.tmp |grep -c "$QCISN"` -eq 2 ] && [ `cat $QCISN.tmp |grep -c $MB_SN` -eq 1 ] && [ "$QCISN" != "$MB_SN" ];then
     print_green "Auto check MB fru PASS ..." |tee -a $Logfile
  else
     print_red "Auto check MB fru FAIL ..." |tee -a $Logfile
     show_exit
  fi
elif [ "$CONFIG" == "1S2RZZZ0STA" ] || [ "$CONFIG" == "1S2RZZZ0STB" ] || [ "$CONFIG" == "1S2RZZZ0STC" ] || [ "$CONFIG" == "1S2RZZZ0STD" ] || [ "$CONFIG" == "1S2RZZZ0STE" ] || [ "$CONFIG" == "1S2RZZZ0STF" ]; then
  if [ `cat $QCISN.tmp |grep -c "S210-X12RS"` -eq 2 ] && [ `cat $QCISN.tmp |grep -c "Quanta"` -eq 2 ] && [ `cat $QCISN.tmp |grep -c "$QCISN"` -eq 2 ] && [ `cat $QCISN.tmp |grep -c $MB_SN` -eq 1 ] && [ "$QCISN" != "$MB_SN" ];then
     print_green "Auto check MB fru PASS ..." |tee -a $Logfile
  else
     print_red "Auto check MB fru FAIL ..." |tee -a $Logfile
     show_exit
  fi
fi 

