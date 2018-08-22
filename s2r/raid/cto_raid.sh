#!/bin/bash
hdd_num=` echo $HDD |awk -F\; '{print NF}' `
echo $hdd_num
if [ "$hddnum" != "0" ]; then
    echo "$RAID_CARD"|grep "LSI"
    if [ "$?" == "0" ] ; then
      if [ "$RAID_CARD" == "LSI_1064E" ] && [ "$hdd_num" == "1" ]; then
      echo "Do not need to create RAID!!"
      else
      ./del.sh $RAID_CARD
      sleep 5
      cat /test/$model/config.cfy |grep "RAID_TYPE"
    # SFC have RAID LEVEL
          if [ "$?" == "0" ]; then
             if ! source ./cfg.sh $RAID_CARD $RAID_LEVEL; then
              itemfail "run cfg.sh fail !!!"
              show_exit
             fi
             sleep 10
             UUT_RAID_LEVEL=`./rl.sh $RAID_CARD|awk '{if($0~/RAID/) print $4}'`
             sleep 10
             if [ "$UUT_RAID_LEVEL" != "$RAID_LEVEL" ]; then
             itemfail "RAID LEVEL CHECK FAIL, RAID level should be $RAID_LEVEL; current RAID level is $UUT_RAID_LEVEL"
             lhand -z $mnt_monitor_path -l -s -L "RAID Level Check FAIL"
             send_log "RAID LEVEL check FAIL"
             show_exit
             else
             echo "RAID level is: $UUT_RAID_LEVEL "
             lhand -z $mnt_monitor_path -l -s -L "RAID Level Check PASS"
             send_log "RAID LEVEL check PASS"
             sleep 2
             fi
    # SFC have NO RAID LEVEL    
          else
              source ./del.sh $RAID_CARD
              sleep 5
               UUT_RAID_LEVEL=`./rl.sh $RAID_CARD|awk '{if($0~/RAID/) print $4}'`
               sleep 10
               if [ "$UUT_RAID_LEVEL" != "None" ]; then
               itemfail "RAID LEVEL CHECK FAIL, RAID should be unset; current RAID level is $UUT_RAID_LEVEL"
               send_log "RAID LEVEL UNSET FAIL"
               lhand -z $mnt_monitor_path -l -s -L "RAID Level Unset FAIL"
               show_exit
               else
               echo "RAID unset OK! "
               lhand -z $mnt_monitor_path -l -s -L "RAID Level Unset PASS"
               send_log "RAID LEVEL UNSET PASS"
               sleep 2
               fi
          fi
      fi
    else
     echo "No need to build RAID!"
    fi
fi