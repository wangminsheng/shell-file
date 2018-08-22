#!/bin/bash
starttime=$(date +%s)
echo `date +"%Y%m%d-%H:%M:%S"` >result.log
for ((;;))
do
   test=`curl -XPUT -H "Content-Type:application/json" -d "@data1.json" http://10.10.1.57:8765/api/admin/agent/heartbeat/agent_mac -s -w %{http_code}`
   echo "$(date +%Y%m%d-%H:%M:%S) ${test}" |tee -a result.log
   sleep 1
   endtime=$(date +%s)
   if [ $(expr $endtime - $starttime) -gt 640 ];then
     break
   fi
done
 
endtime=$(date +%s)
echo "$0 running time : $(expr $endtime - $starttime) Seconds." >>result.log
cat result.log |awk -F\} '{print $2}' |grep -v ^$ |grep -v 200 >result.fail.log
echo "Fail Number: $(cat result.log |awk -F\} '{print $2}' |grep -v ^$ |grep -v 200 |wc -l)" >>result.log
