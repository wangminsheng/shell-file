#!/bin/bash
#ver:0.03 2012/03/09 add _1S2RZZZ0ST6 check for S2RQ-3.5 [12 + 2]hdd 
#ver:0.02 2012/02/28 add red LED check for S2RQ-3.5 hdd [12]
#ver:0.01 2012/02/26 

storage1="Patsburg 8-Port SATA/SAS Storage Control Unit"
storage2="Patsburg 6-Port SATA AHCI Controller"
storage3="Patsburg 4-Port SATA Storage Control Unit"

remark(){
  echo
  print_yellow "#--------------------------------------------------------------------------------------#"
  print_yellow "#[HDD Test finished . when FAT or FQA test done,Please do not forget follow items]     #"
  print_yellow "#  1.remove A/C                                                                        #"
  print_yellow "#  2.remove all SATA HDD add SDD                                                       #"
  print_yellow "#  3.remove upgrade ROM S2RQ - 1S2RZZZ0ST6, 1S2RZZZ0ST9; S2RS -1S2RZZZ0STE,1S2RZZZ0STF #"
  print_yellow "#--------------------------------------------------------------------------------------#"
  echo
  print_green "Press any key to continue"
  anykey
}

found_hdd_8_port(){
  lshw -short |grep -A9 "$storage1" >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    print_red "found [ Upgrade ROM ] in this [ $QCISN $SHOW_MD $CONFIG $STATION ] Please remove this and retest!" |tee -a $Logfile
    if [ `lshw -short|grep -A9 "$storage1" |grep -c "/dev/sd"` -gt 0 ]; then
      print_red "found [ fixture hdd ] in this [ $QCISN $SHOW_MD $CONFIG $STATION ] Please remove this and retest!" |tee -a $Logfile
      show_exit
    else
      show_exit
    fi
  else
    print_green "check fixture hdd pass" |tee -a $Logfile
  fi
}

found_hdd_4_port(){
  if [ `lshw -short |grep -A5 "$storage3" |grep -c "/dev/sd"` -gt 0 ]; then
      print_red "found [ fixture hdd ] in this [ $QCISN $SHOW_MD $CONFIG $STATION ] Please remove this and retest!" |tee -a $Logfile
      show_exit
  else
      print_green "check fixture hdd pass" |tee -a $Logfile
  fi
  
}

found_hdd_6_port(){
   if [ `lshw -short|grep -A7 "$storage2" |grep -c "/dev/sd"` -gt 0 ]; then
      print_red "found [ fixture hdd ] in this [ $QCISN $SHOW_MD $CONFIG $STATION ] Please remove this and retest!" |tee -a $Logfile
      show_exit
  else
      print_green "check fixture hdd pass" |tee -a $Logfile
  fi
  
}

found_hdd_8_port
found_hdd_4_port
found_hdd_6_port
remark


