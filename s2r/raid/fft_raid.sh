#!/bin/bash
hdd_num=` echo $HDD |awk -F\; '{print NF}' `
echo $hdd_num
echo "$RAID_CARD"|grep "LSI"
if [ "$?" == "0" ] ; then
  if [ "$RAID_CARD" == "LSI_1064E" ] && [ "$hdd_num" == "1" ]; then
          echo "Do not need to create RAID!!"
  else
          source ./del.sh $RAID_CARD
          source ./cfg.sh $RAID_CARD 0 
        
           UUT_RAID_LEVEL=`./rl.sh $RAID_CARD|awk '{if($0~/RAID/) print $4}'`
           if [ "$UUT_RAID_LEVEL" != "0" ]; then
           itemfail "RAID LEVEL CHECK FAIL, RAID level should be 0; current RAID level is $UUT_RAID_LEVEL"
           show_exit
           else
           echo "RAID level is: $UUT_RAID_LEVEL "
           sleep 2
           fi
   fi
else
 echo "No need to build RAID!"
fi