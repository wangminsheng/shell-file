#!/bin/bash
#ver: 0.01 2012/02/22
#ver: 0.02 2012/02/25
#ver:0.03 2012/03/19
#----------------------------FP Part Number list-------------------------------#
#S2RQ-3.5HDD: 3QS99FB0000  (1S2RZZZ0ST5;1S2RZZZ0ST6;1S2RZZZ0ST8;1S2RZZZ0ST9;)  #
#             1S2RU9Z0ST1
#fan speed between [ 5400 ] and [ 10400+100 ]                                  #
#S2RQ-2.5HDD: 3AS99FB0020  (1S2RZZZ0ST4;1S2RZZZ0ST7)                           #
#fan speed between [ 3600-100 ] and [ 8500+100 ]                               #
#S2RS-3.5HDD: 34S99CB0000  (1S2RZZZ0STA;1S2RZZZ0STB)                           #
#fan speed between [ 7000-100 ] and [ 15000+100 ]                              #
#S2RS-2.5HDD: 3AS99FB0000  (1S2RZZZ0STC;1S2RZZZ0STD;1S2RZZZ0STE;1S2RZZZ0STF)   #
#fan speed between [ 7000-100 ] and [ 15500+100 ]                              #
#------------------------------------------------------------------------------#

rm -rf fan_check.tmp
get_uut_fan_speed(){
  ipmitool sdr type fan >fan_info.tmp
  if [ $? -ne 0 ]; then
    print_red "Get uut fan sdr list Fail " |tee -a $Logfile
    cat fan_info.tmp >>$Logfile
    show_exit
  else
    if [ "$SHOW_MD" == "S2RS" ] ;then
      #for S2RS 2.5 and 3.5 hdd
        cat fan_info.tmp |grep "SYS_FAN.-1" |awk '{print $9}' >fan_s2rs.tmp1
        cat fan_info.tmp |grep "SYS_FAN.-2" |awk '{print $9}' >fan_s2rs.tmp2
    else
      cat fan_info.tmp |awk '{print $9}' >fan_speed.tmp
      cat fan_info.tmp >>$Logfile
    fi
  fi
}
check_fan_speed(){
  if [ "$SHOW_MD" == "S2RQ" ]; then
    if [ "$CONFIG" == "1S2RZZZ0ST5" ] || [ "$CONFIG" == "1S2RZZZ0ST6" ] || [ "$CONFIG" == "1S2RZZZ0ST8" ] || [ "$CONFIG" == "1S2RZZZ0ST9" ] ||  [ "$CONFIG" == "1S2RU9Z0ST1" ]; then
      #for S2RQ 3.5
       for speed in `cat fan_speed.tmp`
       do
        if [ $speed -gt 5400 ] && [ $speed -lt 10500 ]; then
          print_green "$SHOW_MD $CONFIG FAN test PASS!!! [ 5400 < $speed < 10500 ]" |tee -a fan_check.tmp
        else
 
          print_red "$SHOW_MD $CONFIG FAN test FAIL!!! between 5400 and 10500 not $speed" |tee -a fan_check.tmp
        fi
       done
        
    elif [ "$CONFIG" == "1S2RZZZ0ST4" ] || [ "$CONFIG" == "1S2RZZZ0ST7" ]; then
      #for S2RQ 2.5
      for speed in `cat fan_speed.tmp`
       do
        if [ $speed -gt 3500 ] && [ $speed -lt 8600 ]; then
          print_green "$SHOW_MD $CONFIG FAN test PASS!!! [ 3500 < $speed < 8600 ]" |tee -a fan_check.tmp
        else
          print_red "$SHOW_MD $CONFIG FAN test FAIL!!! between 3500 and 8600 not $speed" |tee -a fan_check.tmp
        fi
       done
    fi
  elif [ "$SHOW_MD" == "S2RS" ]; then
    if [ "$CONFIG" == "1S2RZZZ0STA" ] || [ "$CONFIG" == "1S2RZZZ0STB" ]; then
      #for S2RS 3.5 #fan number=12 #expect fan_x-1_low=6000 fan_x-2_low=4200 expect fan_high=15500
    
       for speed in `cat fan_s2rs.tmp1`
       do
          if [ $speed -gt 6000 ] && [ $speed -lt 15500 ]; then
          print_green "$SHOW_MD $CONFIG FAN test PASS!!! [ 6000 < $speed < 15500]" |tee -a fan_check.tmp
        else
          print_red "$SHOW_MD $CONFIG FAN test FAIL!!! between 6000 and 15500 not $speed" |tee -a fan_check.tmp
        fi
       done
       sleep 1
       for speed in `cat fan_s2rs.tmp2`
       do
        if [ $speed -gt 4200 ] && [ $speed -lt 15500 ]; then
          print_green "$SHOW_MD $CONFIG FAN test PASS!!! [ 4200 < $speed < 15500]" |tee -a fan_check.tmp
        else
          print_red "$SHOW_MD $CONFIG FAN test FAIL!!! between 4200 and 15500 not $speed" |tee -a fan_check.tmp
        fi
       done       

      
    elif [ "$CONFIG" == "1S2RZZZ0STC" ] || [ "$CONFIG" == "1S2RZZZ0STD" ] || [ "$CONFIG" == "1S2RZZZ0STE" ] || [ "$CONFIG" == "1S2RZZZ0STF" ]; then
       #for S2RS 2.5 #fan number=12 #expect fan_x-1_low=6000 fan_x-2_low=4200 expect fan_high=16400
       #cut in time 2012/03/19
    
       for speed in `cat fan_s2rs.tmp1`
       do
          if [ $speed -gt 6000 ] && [ $speed -lt 16400 ]; then
          print_green "$SHOW_MD $CONFIG FAN test PASS!!! [ 6000 < $speed < 16400]" |tee -a fan_check.tmp
        else
          print_red "$SHOW_MD $CONFIG FAN test FAIL!!! between 6000 and 16400 not $speed" |tee -a fan_check.tmp
        fi
       done
       sleep 1
       for speed in `cat fan_s2rs.tmp2`
       do
        if [ $speed -gt 4200 ] && [ $speed -lt 16400 ]; then
          print_green "$SHOW_MD $CONFIG FAN test PASS!!! [ 4200 < $speed < 16400]" |tee -a fan_check.tmp
        else
          print_red "$SHOW_MD $CONFIG FAN test FAIL!!! between 4200 and 16400 not $speed" |tee -a fan_check.tmp
        fi
       done       
    fi
  fi     
}

get_uut_fan_speed
check_fan_speed
dos2unix fan_check.tmp
if [ `cat fan_check.tmp |grep -c "FAN test FAIL"` -ne 0 ]; then
  itemfail "$SHOW_MD $CONFIG FAN TEST FAIL" |tee -a $Logfile
  cat fan_info.tmp |tee -a $Logfile
  sleep 2
  show_exit
else
  print_green " $SHOW_MD $CONFIG ALL FAN TEST PASS!!!" |tee -a $Logfile
fi

ipmitool sel list |grep -i fan |egrep "(going low|going high)"
if [ $? -eq 0 ]; then
  itemfail "FAN test FAIL form sel log " |tee -a $Logfile
  ipmitool sel list |grep -i fan >>$Logfile
  show_exit
else
  print_green "FAN test PASS form sel log " |tee -a $Logfile
fi


 
  