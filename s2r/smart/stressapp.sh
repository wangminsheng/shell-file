#!/bin/sh

MEM_stress_test ()
{
send_log "stressapp $testloop loop test start"
./usr/local/bin/stressapptest --pause_delay 300 --pause_duration 60 -l stresstest.log -W -i 2 -f /tmp/dd5 --cc_test -M $stressapp_test_m -s 3000
if [ "$?" == "0" ]; then
   send_log "stressapp $testloop loop test finished[ Test memory $stressapp_test_m M ]"
  else
   itemfail "stressapp $testloop loop test fail![ Test memory $stressapp_test_m M ]"
   send_log "stressapp $testloop loop test fail![ Test memory $stressapp_test_m M ] \n`cat stresstest.log`"
   lhand -z $mnt_monitor_path -l -s -L "Fail: stressapp $testloop loop test fail![ $testloop loop Test memory $stressapp_test_m M ]"
   show_exit
fi
 source ./fri_sen_check.sh
 source ./fri_sel_check.sh
}

sfc_ram_total_size=`echo $RAM |awk -FM '{print $1}'`
stressapp_test_m=$(($sfc_ram_total_size-4096))

rpm2cpio fb-stressapptest-1.0.3-1.x86_64.rpm | cpio -imdv

if [ ! -e ./usr/local/bin/stressapptest ] ; then
  send_log "setup stressapptest fail!"
  show_exit
fi



  lhand -z $mnt_monitor_path -l -s -L "MEM stress test start"
if [ $SWID == "LONG" ] ; then
MEM_stress_loop=3
else 
MEM_stress_loop=1
fi
testloop=0
#MEM_stress_loop=6
#testloop=0
while [ $testloop -lt $MEM_stress_loop ]
 do 
   MEM_stress_test
   let testloop=testloop+1
 done
  lhand -z $mnt_monitor_path -l -s -L "MEM stress test finished"
  send_log "MEM stress test finished"