#!/bin/bash

#
# cfg.sh
#
# version: 0.1
#
# This script is used in manufacturing to create a raid volume. The following
# assumptions are being made based on input from Marketing/Manufacturing. The
# script will need to be updated if any of these assumptions change
#
# 1. Number of available drives will meet minimum raid level requirements
# 2. All drives will be of the same type (SAS or SATA)
# 3. All drives will be of the same size
# 4. Drives will be populated sequentially starting with slot 0/1
#

#
# Routine: usage
#
# Input: name
#
#   name = shell program name
#
# Output: none
#
# Purpose: Usage
#
#   This routine displays the usage
#

usage() {
#
# Display usage
#
    echo "Usage: $1 <adapter> <raid_level>"
    echo "  adapter = LSI_1064E | LSI_3081 | LSI_8708 | LSI_9261 | ich10"
    echo "  raid_level = 0 | 1 | 5 | 6 | 10"
}

#
# Routine: get_ir_enclosure_id
#
# Input: none
#
# Output: eid
#
#   eid = enclosure id
#
# Purpose: Get integrated raid enclosure id
#
#   This routine returns the integrated raid enclosure id
#

get_ir_enclosure_id() {
#
# Read enclosure information
#
    `cfggen 0 display > \/tmp/\/ir_cfg`

#
# Check status
#
    status=$?
    if [ $status -ne 0 ]
    then
        echo "Error (get_ir_enclosure_id): cfggen failed with status $status"
        exit
    fi

#
# Parse enclosure id
#
    eid=`grep "Enclosure#" \/tmp\/ir_cfg | sed 's/.*: *//'`

#
# Cleanup
#
    rm \/tmp/\ir_cfg
}

#
# Routine: get_mr_enclosure_id
#
# Input: none
#
# Output: eid
#
#   eid = enclosure id
#
# Purpose: Get megaraid enclosure id
#
#   This routine returns the megaraid enclosure id
#

get_mr_enclosure_id() {
#
# Read enclosure information
#
    `MegaCli64 -EncInfo -a0 > \/tmp/\/mr_cfg`

#
# Check status
#
    status=$?
    if [ $status -ne 0 ]
    then
        echo "Error (get_mr_enclosure_id): MegaCli64 failed with status $status"
        exit
    fi

#
# Parse enclosure id
#
    eid=`grep "Device ID" \/tmp\/mr_cfg | sed '$!N;s/\n//' | awk '{print $4}'`

#
# Parse number of enclosures 
#
    num_enc=`grep "enclosures on" \/tmp\/mr_cfg | sed 's/.*-- *//'`

#
# Check for the presense of an expander. If present, the slot numbers start
# from 1 instead of 0
#
    if [ $num_enc -eq 2 ]
    then
        slot_base=1
    else
        slot_base=0
    fi

#
# Cleanup
#
    rm \/tmp/\mr_cfg
}

#
# Routine: cfg_ir_volume_rl_0
#
# Input: none
#
# Output: none
#
# Purpose: Configure integrated raid volume with raid level 0
#
#   This routine configures a integrated raid volume with raid level 0
#

cfg_ir_volume_rl_0() {
#
# Create raid 0 volume
#
    `cfggen 0 auto raid0 max qsync noprompt > \/dev\/null 2>&1`

#
# Check status
#
    status=$?
    if [ $status -ne 0 ]
    then
        echo "Error (cfg_ir_volume_rl_0): cfggen failed with status $status"
        exit
    fi
}

#
# Routine: cfg_ir_volume_rl_1
#
# Input: none
#
# Output: none
#
# Purpose: Configure integrated raid volume with raid level 1
#
#   This routine configures a integrated raid volume with raid level 1
#

cfg_ir_volume_rl_1() {
#
# Get enclosure id
#
    get_ir_enclosure_id

#
# Create raid 1 volume
#
    `cfggen 0 create raid1 max $eid:0 $eid:1 qsync noprompt > \/dev\/null 2>&1`

#
# Check status
#
    status=$?
    if [ $status -ne 0 ]
    then
        echo "Error (cfg_ir_volume_rl_1): cfggen failed with status $status"
        exit
    fi
}

#
# Routine: cfg_mr_volume_rl_1
#
# Input: none
#
# Output: none
#
# Purpose: Configure megaraid volume with raid level 1
#
#   This routine configures a megaraid volume with raid level 1. The volume
#   settings are adaptive read ahead, write thru, direct i/o, and the default
#   strip size (64KB)
#

cfg_mr_volume_rl_1() {
#
# Get enclosure id
#
    get_mr_enclosure_id

#
# Compute slot numbers
#
    drv_0=`expr $slot_base + 0`
    drv_1=`expr $slot_base + 1`

#
# Create raid 1 volume
#
    `MegaCli64 -CfgLdAdd -r1 [$eid:$drv_0,$eid:$drv_1] WT ADRA Direct -a0 > \/dev\/null 2>&1`

#
# Check status
#
    status=$?
    if [ $status -ne 0 ]
    then
        echo "Error (cfg_mr_volume_rl_1): MegaCli64 failed with status $status"
        exit
    fi
}

#
# Routine: cfg_mr_volume_rl_10
#
# Input: none
#
# Output: none
#
# Purpose: Configure megaraid volume with raid level 10
#
#   This routine configures a megaraid volume with raid level 10. The volume
#   settings are adaptive read ahead, write thru, direct i/o, and the default
#   strip size (64KB)
#

cfg_mr_volume_rl_10() {
#
# Get enclosure id
#
    get_mr_enclosure_id

#
# Compute slot numbers
#
    drv_0=`expr $slot_base + 0`
    drv_1=`expr $slot_base + 1`
    drv_2=`expr $slot_base + 2`
    drv_3=`expr $slot_base + 3`

#
# Create raid 1 volume
#
    `MegaCli64 -CfgSpanAdd -r10 -Array0[$eid:$drv_0,$eid:$drv_1] -Array1[$eid:$drv_2,$eid:$drv_3] WT ADRA Direct -a0 > \/dev\/null 2>&1`

#
# Check status
#
    status=$?
    if [ $status -ne 0 ]
    then
        echo "Error (cfg_mr_volume_rl_10): MegaCli64 failed with status $status"
        exit
    fi
}

#
# Routine: cfg_mr_volume_rl_056
#
# Input: none
#
# Output: none
#
# Purpose: Configure megaraid volume with raid level 0, 5 or 6
#
#   This routine configures a megaraid raid volume with raid level 0, 5, or 6.
#   The volume settings are adaptive read ahead, write thru, direct i/o, and the
#   default strip size (64KB)
#

cfg_mr_volume_rl_056() {
#
# Create raid 0, 5, or 6 volume
#
    `MegaCli64 -CfgAllFreeDrv -r$1 WT ADRA Direct -a0 > \/dev\/null 2>&1`

#
# Check status
#
    status=$?
    if [ $status -ne 0 ]
    then
        echo "Error (cfg_mr_volume_rl_056): MegaCli64 failed with status $status"
        exit
    fi
}

#
# Routine: cfg_ir_volume
#
# Input: raid_level
#
#   raid_level = 0, 1
#
# Output: none
#
# Purpose: Configure integrated raid volume
#
#   This routine configures an integrated raid volume. If the raid
#   level is 0 all available drives are used to create the volume.
#   If the raid level is 1 the first two drives are used to create
#   the volume
#

cfg_ir_volume() {
#
# Determine raid level and call the appropriate handler
#
    case $1
    in
        0)
            cfg_ir_volume_rl_0
            ;;
        1)
            cfg_ir_volume_rl_1
            ;;
    esac
}

#
# Routine: cfg_mr_volume
#
# Input: raid_level
#
#   raid_level = 0, 1, 5, 6, 10
#
# Output: none
#
# Purpose: Configure megaraid volume
#
#   This routine configures a megaraid volume. If the raid level is
#   0, 5, or 6, all available drives are used to create the volume.
#   If the raid level is 1 or 10, the first two or four drives are
#   used to create the volume
#

cfg_mr_volume() {
#
# Determine raid level and call the appropriate handler
#
    case $1
    in
        1)
            cfg_mr_volume_rl_1
            ;;
        10)
            cfg_mr_volume_rl_10
            ;;
        *)
            cfg_mr_volume_rl_056 $1
    esac
}

#
# Routine: cfg_rv
#
# Input: adapter, raid_level
#
#   adapter = 1064E, 3081, 8708, 9261, ich10
#   raid_level = 0, 1, 5, 6, 10
#
# Output: none
#
# Purpose: Configure raid volume
#
#   This routine validates the adapter, raid level and calls
#   the appropriate handler to configure the raid volume
#

cfg_rv() {
#
# Validate adapter, raid level and call the appropriate handler
#
    case $1
    in
        LSI_1064E|LSI_3081)
            if [ $2 -le 1 ]
            then
                cfg_ir_volume $2
                return
            fi
            ;;
        LSI_8708|LSI_9261)
            if [ $2 -le 1 ] || [ $2 -eq 5 ] || [ $2 -eq 6 ] || [ $2 -eq 10 ]
            then
                cfg_mr_volume $2
                return
            fi
            ;;
        ich10)
            if [ $2 -le 1 ]
            then
                cfg_mr_volume $2
                return
            fi
            ;;
        *)
            echo "Error: unsupported adapter: $1"
            return
            ;;
    esac

#
# Unsupported adapter, raid level
#
    echo "Error: unsupported adapter, raid level: $1, $2"
}

#
# Check argument count
#
    if [ $# -ne 2 ]
    then
        usage $0
        exit
    fi

#
# Configure raid volume
#
    cfg_rv $1 $2
