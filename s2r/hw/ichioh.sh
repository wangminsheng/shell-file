#!/bin/bash
lshw >tmp.log
get_ich_pdt=` grep -A7 -m1 'ISA bridge' tmp.log|grep 'product:' |awk -F: '{print $2}' `
get_ich_ver=` grep -A7 -m1 'ISA bridge' tmp.log|grep 'version:' |awk -F: '{print $2}' `
get_ioh_pdt=` grep -A7 -m1 'pci:0' tmp.log|grep 'product:' |awk -F: '{print $2}' `
get_ioh_ver=` grep -A7 -m1 'pci:0' tmp.log|grep 'version:' |awk -F: '{print $2}' `
exp_ich_pdt=" VIA Technologies, Inc."
exp_ich_ver=" 00"
exp_ioh_pdt=" VIA Technologies, Inc."
exp_ioh_ver=" 14"

if  [ "$get_ich_pdt" != "$exp_ich_pdt" ] || [ "$get_ich_ver" != "$exp_ich_ver" ] ;then
    echo "get: $get_ich_pdt "
    echo "exp: $exp_ich_pdt "
    echo "get: $get_ich_ver "
    echo "exp: $exp_ich_ver "
    itemfail "ICH controller check fail !!! "
    cyn
  exit 1
fi
echo -e "\e[32m [ICH Check OK] :$get_ich_pdt \e[0m"
echo -e "\e[32m [ICH Check OK] :$get_ich_ver \e[0m"
sleep 3

if [ "$get_ioh_pdt" != "$exp_ioh_pdt" ] || [ "$get_ioh_ver" != "$exp_ioh_ver" ] ;then
    echo "get: $get_ioh_pdt "
    echo "exp: $exp_ioh_pdt "
    echo "get: $get_ioh_ver "
    echo "exp: $exp_ioh_ver "
    itemfail "IOH controller check fail !!! "
    cyn
  exit 1
fi
echo -e "\e[32m [IOH Check OK] :$get_ioh_pdt \e[0m"
echo -e "\e[32m [IOH Check OK] :$get_ioh_ver \e[0m"
sleep 3        
