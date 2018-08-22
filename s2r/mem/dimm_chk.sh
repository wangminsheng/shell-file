#!/bin/sh
#just for S2RQ/S2RS uut dimm info  2012/02/09

rm -rf dim_locator.tmp size.tmp speed.tmp part_nu.tmp dimm_tmp
get_uut_dimm(){

	dmidecode -t 17 >dimm_info.tmp
	ipmitool sdr list >sdr.tmp
	cat sdr.tmp |grep -i "temp_dimm" |sort |awk '{print $3}' >dimm_temp.tmp
	cat dimm_info.tmp |grep Locator: |grep -v Bank |awk '{print $2}' >dimm_locator.tmp
	cat dimm_info.tmp |grep Size: |sed 's/No Module Installed/----/g' |awk '{print $2}' >size.tmp
	cat dimm_info.tmp |grep Speed: |awk '{print $2}' |sed 's/Unknown/----/g' >speed.tmp
	cat dimm_info.tmp |grep "Part Number:" |awk '{print $3}' > part_nu.tmp
	echo -e "\e[33m   DIMM Slot  Size(MB)  Speed     Part Number       temperature\e[0m"
	paste dimm_locator.tmp size.tmp speed.tmp part_nu.tmp dimm_temp.tmp>dimm_tmp
	echo -e "\e[32m`cat dimm_tmp`\e[0m"
	echo |tee -a $Logfile
  print_green "Record DIMM infomation to Logfile" |tee -a $Logfile
  cat dimm_tmp >>$Logfile
}

max_support(){
	max_nu=`cat part_nu.tmp | grep -v "_PartNum" |uniq |wc -l`
	if [ $max_nu -ne 1 ]; then
		print_red "This UUT $QCISN get Memory type great then one ..." |tee -a $Logfile
		show_exit
	fi
}
 
get_uut_dimm
if [ -f $CONFIG.ini ]; then
  diff dimm_locator.tmp $CONFIG.ini
  if [ $? -ne 0 ]; then
    print_red "This config $CONFIG DIMM Locator check FAIL " |tee -a $Logfile
    echo "Expect DIMM Locator as below : " >>$Logfile
    cat $CONFIG.ini >>$Logfile
    echo "Get UUT DIMM Locator is below: " >>$Logfile
    show_exit
  else
    print_green "This conifg $CONFIG DIMM Locator check PASS" |tee -a $Logfile
  fi
else
  print_green "This config $CONFIG no need check DIMM Locator" |tee -a $Logfile
fi

max_support

#check SFC define DIMM 
#1.in the same uut only support one type memory  
if [ -f $CONFIG.ini ]; then
  cp /test/s2r/linkall.cfy .
  if [ `cat linkall.cfy |grep "RAM=CN" | uniq |wc -l` -ne 1 ]; then
    print_red "SFC define more then one type DIMM " |tee -a $Logfile
    show_exit
  fi
  exp_dimm_pn=`cat linkall.cfy |grep "RAM=CN" |uniq |awk '{print $4}'`
  get_dimm_pn=`cat part_nu.tmp |grep -v "_PartNum" |uniq`
  echo -en "DIMM Part Number check start:  "
  if [ "$exp_dimm_pn" != "$get_dimm_pn" ]; then
     print_red "FAIL [ exp> $exp_dimm_pn get> $get_dimm_pn ]"
     show_exit
  else
     print_green "PASS [ expect : $exp_dimm_pn ]" |tee -a $Logfile
  fi  
fi

  
