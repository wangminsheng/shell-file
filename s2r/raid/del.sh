#!/bin/bash

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
# Routine: delete_ir_volume
#
# Input: none
#
# Output: none
#
# Purpose: Delete integrated raid volume
#
#   This routine deletes the integrated raid volume
#

delete_ir_volume() {
#
# Delete integrated raid volume
#
    `cfggen 0 delete noprompt > \/dev\/null 2>&1`

#
# Check status
#
    status=$?
    if [ $status -ne 0 ]
    then
        echo "Error (delete_ir_volume): cfggen failed with status $status"
        exit
    fi
}

#
# Routine: delete_mr_volume
#
# Input: none
#
# Output: none
#
# Purpose: Delete megaraid volume
#
#   This routine deletes the megaraid volume. It assumes no more than
#   one RAID volume is present
#

delete_mr_volume() {
#
# Delete megaraid volume
#
#    `MegaCli64 -CfgLdDel -L0 -a0 > \/dev\/null`
     MegaCli64 -CfgClr -aALL
#
# Check status
#
    status=$?
    if [ $status -ne 0 ]
    then
        echo "Error (delete_mr_volume): MegaCli64 failed with status $status"
        exit
    fi
}

#
# Routine: delete_rv
#
# Input: adapter
#
#   adapter = 1064E, 3081, 8708, 9261, ich10
#
# Output: none
#
# Purpose: Delete raid volume
#
#   This routine validates the adapter and calls the appropriate
#   handler to delete the raid volume
#

delete_rv() {
#
# Validate adapter and call the appropriate handler
#
    case $1
    in
        LSI_1064E|LSI_3081)
            delete_ir_volume
            ;;
        LSI_8708|LSI_9261|ich10)
            delete_mr_volume
            ;;
        *)
            echo "Error (delete_rv): unsupported adapter: $1"
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
# Delete raid volume
#
    delete_rv $1
