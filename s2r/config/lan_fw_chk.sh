#!/bin/bash
#------------------------------------------------------------------------------#
#get_uut_lom_fw(){
#  businfo=`lspci -n |grep "$1" |awk '{print $1}'`  
#}

#lan_fw_chk(){
#  #model: S2RQ MB Version: 31S2RMB0030 lan controller : I350_LOM
#  #I350_LOM_SANLUIS=$INTEL_VID:1521
#  INTEL_VID=8086
#  I350_LOM=$INTEL_VID:1521
#  if [ "$SHOW_MD" == "S2RQ" ] && [ "$baseboard_version" == "31S2RMB0030" ]; then
#    #if M1 lan FW upgrade ;need change about this !
#    export LAN_FW="1.5-2"
#    export I350_LOM="8086:1521"  
#  elif [ "$SHOW_MD" == "S2RQ" ] && [ "$baseboard_version" == "31S2RMB0040" ]; then
#    #if M1 lan FW upgrade ;need change about this !
#    export LAN_FW="2.4-2"
#    export X540_LOM="8086:1528" 
#  elif [ "SHOW_MD" == "S2RS" ] && [ "$baseboard_version" == "31S2RMB0020" ]; then
#    #if M1 lan FW upgrade ;need change about this !
#    export LAN_FW="1.5-2" 
#    export I350_LOM="8086:1521"
#  elif [ "SHOW_MD" == "S2RS" ] && [ "$baseboard_version" == "31S2RMB0050" ]; then
#    #if M1 lan FW upgrade ;need change about this !
#    export LAN_FW="2.4-2"
#    export X540_LOM="8086:1528" 
#  else
#    export LAN_FW="unknown"
#  fi
#
}