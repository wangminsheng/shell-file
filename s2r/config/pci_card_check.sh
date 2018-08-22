#!/bin/sh
## SFC PCI Card list ###############
#  LSI_9260
#  intel_82599EB
#  intel_i350
# 
#  
#
# 
####################################

#Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)

intel_i350="Intel Corporation I350 Gigabit Network Connection (rev 01)"
intel_i350_port=2

#Ethernet controller: Intel Corporation 82599EB 10-Gigabit SFI/SFP+ Network Connection (rev 01)
intel_82599_EB="Intel Corporation 82599EB 10-Gigabit SFI/SFP+ Network Connection (rev 01)"
intel_82599_port=2

#RAID bus controller: LSI Logic / Symbios Logic LSI MegaSAS 9260 (rev 05)
LSI_9260="LSI Logic / Symbios Logic LSI MegaSAS 9260 (rev 05)"
LSI_9260_port=1

find_pci(){
  pci_card_name=$1
  device_name=$2
  device_port=$3
  pci_num=`lspci |grep "$device_name" |wc -l`
  card_num=`expr $pci_num / $device_port`
  print_green "Found: $pci_card_name number: $card_num" |tee -a $Logfile
}


#just for S2R [ 1S2RU9Z0ST1 ] [ 1S2RUBZ0ST3 ]

if [ "$CONFIG" == "1S2RU9Z0ST1" ] || [ "$CONFIG" == "1S2RUBZ0ST3" ]; then
  echo "" |tee -a $Logfile
  find_pci "Intel 82599EB" "$intel_82599_EB" "$intel_82599_port"
  echo -en "Check Intel 82599EB card number: " |tee -a $Logfile
  if [ $card_num -ne 1 ]; then
     print_red "FAIL [ exp> 1 get> $card_num ]" |tee -a $Logfile
     show_exit
  else
     print_green "PASS [ exp > 1 ]" |tee -a $Logfile 
     sleep 1
  fi
fi
 






