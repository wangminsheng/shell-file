#!/bin/bash
#ver: 0.01  2012/02/20
#S2RQ/S FP check
#----------------------------FP Part Number list-------------------------------#
#S2RQ-3.5HDD: 3QS99FB0000  (1S2RZZZ0ST5;1S2RZZZ0ST6;1S2RZZZ0ST8;1S2RZZZ0ST9)   #
#                           1S2RU9Z0ST1 add time 03/27
#                           1S2RUBZ0ST3 add time 03/30
#S2RQ-2.5HDD: 3AS99FB0020  (1S2RZZZ0ST4;1S2RZZZ0ST7)                           #
#S2RS-3.5HDD: 34S99CB0000  (1S2RZZZ0STA;1S2RZZZ0STB)                           #
#S2RS-2.5HDD: 3AS99FB0000  (1S2RZZZ0STC;1S2RZZZ0STD;1S2RZZZ0STE;1S2RZZZ0STF)   #
#------------------------------------------------------------------------------#
get_uut_FP(){
  unset errmsg
  errmsg="0x00"
  rm -rf fp_fru.tmp
  ipmitool fru print 1 >fp_fru.tmp
  dos2unix fp_fru.tmp
  get_FP_PN=`cat fp_fru.tmp |grep "Board Part Number" |awk -F\: '{print $2}'|sed 's/ //g'`
# echo $get_FP_PN
  get_FP_CHTP=`cat fp_fru.tmp |grep "Chassis Type" |awk -F\: '{print $2}' |sed 's/ //'`
#  echo $get_FP_CHTP
  if [ -z "$get_FP_PN" ]; then
    errmsg="0x01"
  fi
  
  if [ -z "$get_FP_CHTP" ]; then
    errmsg="0x02"
  fi
}

FP_PN_EXP(){
#  export SHOW_MD=S2RQ
#  export CONFIG=1S2RZZZ0ST7
  if [ "$SHOW_MD" == "S2RQ" ];then
    if [ "$CONFIG" == "1S2RZZZ0ST5" ] || [ "$CONFIG" == "1S2RZZZ0ST6" ] || [ "$CONFIG" == "1S2RZZZ0ST8" ] || [ "$CONFIG" == "1S2RZZZ0ST9" ] || [ "$CONFIG" == "1S2RU9Z0ST1" ]; then
      #for S2RQ-3.5HDD
      exp_FP_PN="3QS99FB0000"
    elif [ "$CONFIG" == "1S2RZZZ0ST4" ] || [ "$CONFIG" == "1S2RZZZ0ST7" ]; then
      #for S2RQ-2.5HDD 
      exp_FP_PN="3AS99FB0020"
    fi
  elif [ "$SHOW_MD" == "S2RS" ]; then
    if [ "$CONFIG" == "1S2RZZZ0STA" ] || [ "$CONFIG" == "1S2RZZZ0STB" ] || [ "$CONFIG" == "1S2RUBZ0ST3" ]; then
      #for S2RS-3.5HDD
      exp_FP_PN="34S99CB0000"
    elif [ "$CONFIG" == "1S2RZZZ0STC" ] || [ "$CONFIG" == "1S2RZZZ0STD" ] || [ "$CONFIG" == "1S2RZZZ0STE" ] || [ "$CONFIG" == "1S2RZZZ0STF" ]; then
      #for S2RS-2.5HDD
      exp_FP_PN="3AS99FB0000"
    fi
  fi

}

get_uut_FP

if [ "$errmsg" == "0x01" ]; then
  echo -en "Get UUT FP Chassis Part Number: " |tee -a $Logfile
  print_red "FAIL! errmsg=0x01"  |tee -a $Logfile
  show_exit
elif [ "$errmsg" == "0x02" ]; then
  echo -en "Get UUT FP Chassis Type:        " |tee -a $Logfile
  print_red "FAIL! errmsg=0x02"  |tee -a $Logfile
  show_exit
elif [ "$errmsg" == "0x00" ]; then
  echo -en "Get UUT FP FRU infomation:      " |tee -a $Logfile
  print_green "PASS" |tee -a $Logfile
  sleep 1
fi

FP_PN_EXP

if [ "$get_FP_PN" != "$exp_FP_PN" ]; then
  echo -en "FP Part Number check: exp> [ $exp_FP_PN ]  " |tee -a $Logfile
  print_red "FAIL! get> [ $get_FP_PN ]" |tee -a $Logfile
  echo
  print_green "[ Model: $SHOW_MD] [CONFIG: $CONFIG] [Expect FP Part number : $exp_FP_PN]" |tee -a $Logfile
  show_exit
else
  echo -en "FP Part Number check: exp> [ $exp_FP_PN ]  " |tee -a $Logfile
  print_green "PASS" |tee -a $Logfile
  sleep 1
fi

if [ "$get_FP_CHTP" != "Rack Mount Chassis" ]; then
  echo -en "FP Chassis Type check: exp> [ Rack Mount Chassis ] " |tee -a $Logfile
  print_red "FAIL! get> [ $get_FP_CHTP ]" |tee -a $Logfile
  show_exit
else
  echo -en "FP Chassis Type check: exp> [ Rack Mount Chassis ]  " |tee -a $Logfile
  print_green "PASS" |tee -a $Logfile
  sleep 2
fi