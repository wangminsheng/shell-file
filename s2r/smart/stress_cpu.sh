#!/bin/sh
CPU_stress_test ()
{
send_log "CPU stress $testloop loop test start"
stress --cpu 10  --vm 2 --vm-bytes 1024M --timeout 7500
if [ "$?" = "0" ]; then
   send_log "CPU stress $testloop loop test finished"
  else
   itemfail "CPU stress $testloop loop test Fail"
  # mv $CONFIRM_FOLDER/$STATION/$QCISN.start $CONFIRM_FOLDER/$STATION/$QCISN.fail
   send_log "CPU stress $testloop loop test Fail"
   lhand -z $mnt_monitor_path -l -s -L "Fail: $QCISN CPU stress test Fail"
   show_exit
fi
 
source ./ECC_check.sh
}



  lhand -z $mnt_monitor_path -l -s -L "$QCISN CPU stress test start"
CPU_stress_loop=4

#if [ $SWID == "LONG" ] || [ "$STATION" != "FDT" ] ; then
#CPU_stress_loop=2
#else 
#CPU_stress_loop=1
#fi
testloop=0
while [ $testloop -lt $CPU_stress_loop ]
 do 
   CPU_stress_test
   let testloop=testloop+1
 done
  lhand -z $mnt_monitor_path -l -s -L "$QCISN CPU stress test finished"
  send_log "CPU stress test finished"