#!/bin/bash

#
# rl.sh
#
# version: 0.2
#
# This script is used in manufacturing to read the raid level of the configured
# raid volume. The following assumptions are being made based on input from
# Marketing. The script will need to be updated if any of these assumptions
# change 
#
# 1. Only one raid volume will be present
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
    echo "Usage: $1 <adapter>"
    echo "  adapter = LSI_1064E | LSI_3081 | LSI_8708 | LSI_9261 | ich10"
}

#
# Routine: display_rl
#
# Input: rl
#
#   rl = raid level
#
# Output: none
#
# Purpose: Display raid level
#
#   This routine displays the raid level onto the standard output
#

display_rl() {
#
# Check for raid volumes and display the raid level
#
    if [ "$1" == "" ]
    then
        echo "RAID Level : None"
    else
        if [ $2 -eq 1 ]
        then
            echo "RAID Level : $1"
        else
            echo "RAID Level : $10"
        fi
    fi
}

#
# Routine: parse_ir_cfg
#
# Input: none
#
# Output: none
#
# Purpose: Parse integrated raid configuration
#
#   This routine parses the integrated raid configuration to determine
#   the raid level. It assumes no more than one RAID volume is present
#

parse_ir_cfg() {
#
# Read integrated raid configuration
#
    `cfggen 0 display > \/tmp\/ir_cfg`

#
# Check status
#
    status=$?
    if [ $status -ne 0 ]
    then
        echo "Error (parse_ir_cfg): cfggen failed with status $status"
        exit
    fi

#
# Parse configuration
#
    raid_level=`grep "RAID level" \/tmp\/ir_cfg | awk '{print $4}'`

#
# Display raid level
#
    display_rl "$raid_level" 1

#
# Cleanup
#
    rm \/tmp\/ir_cfg
}

#
# Routine: parse_mr_cfg
#
# Input: none
#
# Output: none
#
# Purpose: Parse megaraid configuration
#
#   This routine parses the megaraid configuration to determine the raid
#   level. It assumes no more than one RAID volume is present
#

parse_mr_cfg() {
#
# Read megaraid configuration
#
    `MegaCli64 -LDInfo -L0 -a0 > \/tmp\/mr_cfg`

#
# Check status
#
    status=$?
    if [ $status -ne 0 ]
    then
        echo "Error (parse_mr_cfg): MegaCli64 failed with status $status"
        exit
    fi

#
# Parse configuration
#
    raid_level=`grep "RAID Level" \/tmp\/mr_cfg | sed 's/.*Primary-//' | sed 's/,.*//'`
    span_depth=`grep "Span Depth" \/tmp\/mr_cfg | sed 's/.*://'`

#
# Display raid level
#
    display_rl "$raid_level" $span_depth

#
# Cleanup
#
    rm \/tmp\/mr_cfg
}

#
# Routine: read_rl
#
# Input: adapter
#
#   adapter = 1064E, 3081, 8708, 9261, ich10
#
# Output: none
#
# Purpose: Read raid level
#
#   This routine validates the adapter and calls the appropriate
#   handler to read the raid level
#

read_rl() {
#
# Validate adapter and call the appropriate handler
#
    case $1
    in
        LSI_1064E|LSI_3081)
            parse_ir_cfg
            ;;
        LSI_8708|LSI_9261|ich10)
            parse_mr_cfg
            ;;
        *)
            echo "Error (read_rl): unsupported adapter: $1"
            ;;
    esac
}

#
# Check argument count
#
    if [ $# -ne 1 ]
    then
        usage $0
        exit
    fi

#
# Read raid level
#
    read_rl $1
