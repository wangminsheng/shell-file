#!/bin/bash
#ver: 0.01  2012/02/20
#S2RQ/S FP check
#----------------------------FP Part Number list-------------------------------#
#S2RQ-3.5HDD: 3QS99FB0000  (1S2RZZZ0ST5;1S2RZZZ0ST6;1S2RZZZ0ST8;1S2RZZZ0ST9)   #
#S2RQ-2.5HDD: 3AS99FB0020  (1S2RZZZ0ST4;1S2RZZZ0ST7)                           #
#S2RS-3.5HDD: 34S99CB0000  (1S2RZZZ0STA;1S2RZZZ0STB)                           #
#S2RS-2.5HDD: 3AS99FB0000  (1S2RZZZ0STC;1S2RZZZ0STD;1S2RZZZ0STE;1S2RZZZ0STF)   #
#------------------------------------------------------------------------------#

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

get_uut_FP(){
  unset errmsg
  errmsg="0x00"
  ipmitool fru >fru.tmp
  dos2unix fru.tmp
  get_FP_PN=`cat fru.tmp |grep -A3 "FP FRU \(ID 1\)" |grep "Board Part Number" |awk -F\: '{print $2}'|sed 's/ //g'`
  get_FP_CHTP=`cat fru.tmp |grep -A3 "FP FRU \(ID 1\)" |grep "Chassis Type"` |awk -F\: '{print $2}' |cut -c1-18`
  if [ -z "$FP_PN" ]; then
    errmsg="0x01"
  fi
  
  if [ -z "$FP_CHTP" ]; then
    errmsg="0x02"
  fi
}

FP_PN_EXP(){
  if [ "$SHOW_MD" == "S2RQ" ];then
    if [ "$CONFIG" == "1S2RZZZ0ST5" ] || [ "$CONFIG" == "1S2RZZZ0ST6" ] || [ "$CONFIG" == "1S2RZZZ0ST8" ] || [ "$CONFIG" == "1S2RZZZ0ST9" ]; then
      #for S2RQ-3.5HDD
      exp_FP_PN="3QS99FB0000"
    elif [ "$CONFIG" == "1S2RZZZ0ST4" ] || [ "$CONFIG" == "1S2RZZZ0ST7" ]; then
      #for S2RQ-2.5HDD 
      exp_FP_PN="3AS99FB0020"
    fi
  elif [ "$SHOW_MD" == "S2RS" ]; then
    if [ "$CONFIG" == "1S2RZZZ0STA" ] || [ "$CONFIG" == "1S2RZZZ0STB" ]; then
      #for S2RS-3.5HDD
      exp_FP_PN="34S99CB0000"
    elif [ "$CONFIG" == "1S2RZZZ0STC" ] || [ "$CONFIG" == "1S2RZZZ0TD" ] || [ "$CONFIG" == "1S2RZZZ0TE" ] || [ "$CONFIG" == "1S2RZZZ0TF" ]; then
      #for S2RS-2.5HDD
      exp_FP_PN="3AS99FB0000"
    fi
  fi

}

get_uut_FP

if [ "$errmsg" == "0x01" ]; then
  echo -en "Get UUT FP Chassis Part Number: "
  print_red "FAIL! errmsg=0x01"
  show_exit
elif [ "$errmsg" == "0x02" ]; then
  echo -en "Get UUT FP Chassis Type:        "
  print_red "FAIL! errmsg=0x01"
  show_exit
elif [ "$errmsg" == "0x00" ]; then
  echo -en "Get UUT FP FRU infomation:      "
  print_green "PASS"
fi

FP_PN_EXP

if [ "$get_FP_PN" != "$exp_FP_PN" ]; then
  echo -en "FP Part Number check: exp> [ $exp_FP_PN ]  "
  print_red "FAIL! get> [ $get_FP_PN ]"
  echo
  print_green "[ Model: $SHOW_MD] [CONFIG: $CONFIG] [Expect FP Part number : $exp_FP_PN]"
  show_exit
else
  echo -en "FP Part Number check: exp> [ $exp_FP_PN ]  "
  print_green "PASS"
fi

if [ "$get_FP_CHTP" != "Rack Mount Chassis" ]; then
  echo -en "FP Chassis Type check: exp> [ Rack Mount Chassis ] "
  print_red "FAIL! get> [ $get_FP_CHTP ]"
  show_exit
else
  echo -en "FP Chassis Type check: exp> [ Rack Mount Chassis ]  "
  print_green "PASS"
fi