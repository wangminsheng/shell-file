#!/bin/bash
hdd_num=` echo $HDD |awk -F\; '{print NF}' `
echo $hdd_num
if [ "$hddnum" != "0" ]; then
    echo "$RAID_CARD"|grep "LSI"
    if [ "$?" == "0" ]; then
        
            if ! source ./del.sh $RAID_CARD; then
              itemfail "run del.sh fail !!!"
              lhand -z $mnt_monitor_path -l -s -L "RAID Level del FAIL"
              show_exit
            fi
            sleep 5
            RAID_CHECK=`./rl.sh $RAID_CARD|awk '{if($0~/RAID/) print $4}'`
            sleep 10
            if [ "$RAID_CHECK" == "None" ]; then
            echo "NO RAID LEVEL, DEL RAID PASS!!"
            else
            itemfail "RAID clear fail !!!"
            lhand -z $mnt_monitor_path -l -s -L "RAID Level clear FAIL"
            show_exit
            fi
        
    fi
fi
