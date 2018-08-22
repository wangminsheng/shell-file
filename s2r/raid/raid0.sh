#!/bin/bash

echo -e "\e[36mclear RAID, please wait...\e[37m"
./MegaCli64 -CfgClr -a0
status=$?
    if [ $status -ne 0 ]
    then
        itemfail "Error (cfg_mr_volume_rl_056): MegaCli64 failed with status $status"
        show_exit
    fi
sleep 5
./MegaCli64 -CfgForeign -Clear -aALL
status=$?
    if [ $status -ne 0 ]
    then
        itemfail "Error (cfg_mr_volume_rl_056): MegaCli64 failed with status $status"
        show_exit
    fi
sleep 5
echo -e "\e[36mBuild RAID 0, please wait...\e[37m"
./MegaCli64 -CfgAllFreeDrv -r0 WT ADRA Direct -a0
status=$?
    if [ $status -ne 0 ]
    then
        itemfail "Error (cfg_mr_volume_rl_056): MegaCli64 failed with status $status"
        show_exit
    fi
sleep 5
