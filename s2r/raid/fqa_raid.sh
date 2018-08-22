#!/bin/bash
hdd_num=` echo $HDD |awk -F\; '{print NF}' `
echo $hdd_num
echo "$RAID_CARD"|grep "LSI"
if [ "$?" == "0" ]; then
  if [ "$RAID_CARD" == "LSI_1064E" ] && [ "$hdd_num" == "1" ]; then
  echo "Do not need to check RAID!!"
  else
  cat /test/$model/config.cfy |grep "RAID_TYPE"
# SFC have RAID LEVEL
      if [ "$?" == "0" ]; then
         #get the exact RAID Level from UUT
         UUT_RAID_LEVEL=`./rl.sh $RAID_CARD|awk '{if($0~/RAID/) print $4}'`  
         if [ "$UUT_RAID_LEVEL" != "$RAID_LEVEL" ]; then
         itemfail "RAID LEVEL CHECK FAIL, RAID level should be $RAID_LEVEL; current RAID level is $UUT_RAID_LEVEL"
         show_exit
         else
         echo "RAID level is: $UUT_RAID_LEVEL "
         sleep 2
         fi
# SFC have NO RAID LEVEL    
      else
           #get the exact RAID Level from UUT
           UUT_RAID_LEVEL=`./rl.sh $RAID_CARD|awk '{if($0~/RAID/) print $4}'`
           if [ "$UUT_RAID_LEVEL" != "None" ]; then
           itemfail "RAID LEVEL CHECK FAIL, RAID level should be 0; current RAID level is $UUT_RAID_LEVEL"
           show_exit
           else
           echo "RAID level is: $UUT_RAID_LEVEL, check pass!! "
           sleep 2
           fi
      fi
  fi
else
 echo "No need to create and check RAID!"
fi