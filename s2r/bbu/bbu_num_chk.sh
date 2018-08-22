#!/bin/sh

#BatteryType: iBBU08 Device Name: bq27541

exp_bbu_num(){
  rm -rf linkall.cfy
  cp /test/s2r/linkall.cfy .
  exp_bbu_count=`cat linkall.cfy |grep "BATTERY CARD SN=" |wc -l`  
}
	
lsi_get_adpcount(){
  MegaCli -AdpCount &> /dev/null
  get_lsi_count=`echo $?`
}

get_bbu_count(){
  
  for((i=0; i<$get_lsi_count;i++))
  do
    MegaCli64 -adpallinfo -a$i >adpcount.$i
    bbu_status=`cat adpcount.$i |grep -A15 -i "HW Configuration" |grep "BBU              :" |awk -F\: '{print $2}' |sed 's/ //g'`
  
    echo "BBU  : $bbu_status" 
    if [ "$bbu_status" == "Present" ]; then
      bbu_count[$i]=1
    else
      bbu_count[$i]=0
      #1.this lsi card defined iBBU yes or not
      #2.Please check BBU connector is correct or not...
    fi
    total_bbu_count=$((bbu_count[$i] + total_bbu_count)) 
done
}

check_bbu_num(){
  exp_bbu_num
  get_bbu_count
  echo -en "ibbu count check :  "
  if [ $exp_bbu_count -ne $total_bbu_count ]; then
    print_red "FAIL [ exp> $exp_bbu_count get> $total_bbu_count ]" |tee -a $Logfile
    show_exit
  else
    print_green "PASS [ exp> $exp_bbu_count ]" |tee -a $Logfile
  fi
}

#start...
check_bbu_num
