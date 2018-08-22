#!/bin/bash
#model=c0d
script_name_of_bit="bit_script_L6.cfg"
bit_log_file_path="/tmp"

# need know runin time
#rt_err_str="can not got the runin time from config file: runintime.cfg"
#if ! lcstr runintime.cfg -k "RunInTime" -s "=" -g "1" -v runin_time; then return 1; fi
#. ./lcstr_out_val

# need know hard drive number
#rt_err_str="can not got the hard drive number from UUT"
#if ! lhdtst -g uut_hdd_num; then return 1; fi
#. ./lhdtst_out_val

./bit_cmd_line_x64 -C $script_name_of_bit