#!/bin/bash
script_name_of_bit="bit_script.cfg"
bit_log_file_path="/tmp"

#if [ "$show_model" =="S97C" ] ;then
   mv 4hours.cfg bit_script.cfg
#else
#   mv 12hours.cfg bit_script.cfg
#fi

./bit_cmd_line_x64 -C $script_name_of_bit



