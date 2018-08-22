#!/bin/bash

lshw >hw.log
get_ich_pdt=` grep -A7 -m1 'ISA bridge' hw.log|grep 'product:' |awk -F: '{print $2}' `
get_ich_ver=` grep -A7 -m1 'ISA bridge' hw.log|grep 'version:' |awk -F: '{print $2}' `
get_ioh_pdt=` grep -A7 -m1 'pci:0' hw.log|grep 'product:' |awk -F: '{print $2}' `
get_ioh_ver=` grep -A7 -m1 'pci:0' hw.log|grep 'version:' |awk -F: '{print $2}' `

exp_ich_pdt=" Patsburg LPC Controller"
exp_ich_ver=" 05"
exp_ioh_pdt=" Sandy Bridge IIO PCI Express Root Port 1a"
exp_ioh_ver=" 05"

#check ICH
if  [ "$get_ich_pdt" != "$exp_ich_pdt" ] || [ "$get_ich_ver" != "$exp_ich_ver" ] ;then
    echo "get: $get_ich_pdt "
    echo "exp: $exp_ich_pdt "
    echo "get: $get_ich_ver "
    echo "exp: $exp_ich_ver "
    itemfail "ICH controller check fail !!! "
    sleep 5
    show_exit
    cyn
  exit 1
fi
echo -e "\e[32m [ICH Pdt Check OK] : $get_ich_pdt \e[0m"
echo -e "\e[32m [ICH Ver Check OK] : $get_ich_ver \e[0m"
sleep 3

#check IOH
if [ "$get_ioh_pdt" != "$exp_ioh_pdt" ] || [ "$get_ioh_ver" != "$exp_ioh_ver" ] ;then
    echo "get: $get_ioh_pdt "
    echo "exp: $exp_ioh_pdt "
    echo "get: $get_ioh_ver "
    echo "exp: $exp_ioh_ver "
    itemfail "IOH controller check fail !!! "
    sleep 5
    show_exit
    cyn
  exit 1
fi
echo -e "\e[32m [IOH Pdt Check OK] : $get_ioh_pdt \e[0m"
echo -e "\e[32m [IOH Ver Check OK] : $get_ioh_ver \e[0m"
sleep 3  

send_log "ICH and IOH Check OK"      