#!/bin/bash
#model=c0d
script_name_of_bit="2c_bit_script.cfg"
bit_log_file_path="/tmp"
sfc_hdd_num=` echo $HDD |awk -F\; '{print NF}' `

if [ -z $RAID_CARD ] ;then
mv ${sfc_hdd_num}_hdd.cfg 2c_bit_script.cfg
else
mv 1_hdd.cfg 2c_bit_script.cfg
fi
  ./bit_cmd_line_x64 -C $script_name_of_bit



