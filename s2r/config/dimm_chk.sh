#!/bin/sh
#ver:0.01 
#just for S2RQ/S2RS uut dimm info  2012/02/09
#for L6 test script

get_uut_dimm(){
  dimdecode -t 17 >dimm_info.tmp
  echo -e "\e[33m  DIMM Slot   Size(MB)  Speed    Part Number\e[0m"
  cat dimm_info.tmp |grep Locator: |grep -v Bank |awk '{print $2}' >dimm_locator.tmp
  cat dimm_info.tmp |grep Size: |sed 's/No Module Installed/----/g' |awk '{print $2}' >size.tmp
  cat dimm_info.tmp |grep Speed: |awk '{print $2}' |sed 's/Unknown/----/g' >speed.tmp
  cat dimm_info.tmp |grep "Part Number:" |awk '{print $3}'> part_nu.tmp
  paste dimm_locator.tmp size.tmp speed.tmp part_nu.tmp >dimm_tmp
  echo -e "\e[32m`cat dimm_tmp`\e[0m"
}

max_support(){
	max_nu=`cat part_nu.tmp | grep -v "_PartNum" |uniq |wc -l`
	if [ $max_nu -ne 1 ]; then
		echo -e "UUT get Memory type great then one ..."
		itemfail "Found Memory Type great then one in the the UUT [ $QCISN ]..."
		show_exit
	fi
}

rm -rf dim_locator.tmp size.tmp speed.tmp part_nu.tmp dimm_tmp 

get_uut_dimm
man_answer "DIMM Locator and Size Check PASS or FAIL? [Y/N]"
  if [ "$answer" == "Y" ]; then
      echo -e "\e[32mDIMM config check PASS\e[0m"
  else
      item_fail "DIMM config check FAIL ..."
      show_exit
  fi

max_support

