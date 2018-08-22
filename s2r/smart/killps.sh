#!/bin/sh
if [ $# != 1 ];then
  echo "usage : ./killps TASK"
  exit 1
fi
killt="$1"
data=`ps | egrep $killt | awk '{print $1}'`
taskid=`echo $data | awk '{print $1}'`
kill -9 $taskid
