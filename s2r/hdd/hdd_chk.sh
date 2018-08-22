#!/bin/bash
#ver:0.06 2012/03/28 add _1S2RU9Z0ST1 check for S2RQ-3.5 [10] hdd use raid card LSI_9260
#ver:0.05 2012/03/22 add _1S2RZZZ0STC check for S2RS-2.5 [10] hdd use fixture LSI_9260_8i
#ver:0.04 2012/03/19 add _1S2RZZZ0STE check for S2RS-2.5 [10] hdd
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

detect_8port_control(){
  lshw -short >lshw_short.log
  if [ `cat lshw_short.log |grep -c "$storage1"` -eq 0 ]; then
    print_red "Can not found : $storage1" |tee -a $Logfile
    echo
    show_exit
  else
    print_green "Found : $storage1" |tee -a $Logfile
  fi 
}

detect_4port_control(){
  lshw -short >lshw_short.log
  if [ `cat lshw_short.log |grep -c "$storage3"` -eq 0 ]; then
    print_red "Can not found : $storage3" |tee -a $Logfile
    echo
    show_exit
  else
    print_green "Found : $storage3" |tee -a $Logfile
  fi
}

found_hdd_8_port(){
  cat lshw_short.log |grep -A12 "$storage1" |grep "/dev/sd" |awk '{print $2}' >disk_list8.log
  disk8_num=`cat disk_list8.log |wc -l`
  echo
  echo -en "$storage1 : " |tee -a $Logfile
  print_green "$disk8_num hdd" |tee -a $Logfile
  echo
}

found_hdd_4_port(){
  cat lshw_short.log |grep -A5 "$storage3" |grep "/dev/sd" |awk '{print $2}' >disk_list4.log
  disk4_num=`cat disk_list4.log` |tee -a $Logfile
  echo
  echo -en "$storage3 :" |tee -a $Logfile
  print_green "$disk4_num hdd" |tee -a $Logfile
  echo
}

found_hdd_6_port(){
  cat lshw_short.log |grep -A7 "$storage2" |grep "/dev/sd" |awk '{print $2}' >disk_list6.log
  disk6_num=`cat disk_list6.log |wc -l`
  echo
  echo -en "$storage2 : " |tee -a $Logfile
  print_green "$disk6_num hdd" |tee -a $Logfile
  echo
}

_1S2RZZZ0ST6(){
  #1S2RZZZ0ST6 an FAT have 12 SATA hdd and 2 sdd hdd check
  expect_hdd_num=14
  echo -e "[ $SHOW_MD ] [ $CONFIG ] [ $QCISN ] HDD number check start ... " |tee -a $Logfile
  detect_8port_control
  found_hdd_8_port
  found_hdd_6_port
  get_hdd_num=`expr $disk8_num + $disk6_num`
  echo -en "HDD number check : [ expect_hdd_num> $expect_hdd_num ] " |tee -a $Logfile
  if [ $expect_hdd_num -eq $get_hdd_num ]; then
    print_green "PASS" |tee -a $Logfile
  else
    print_red "FAIL [ get_hdd_num> $get_hdd_num]" |tee -a $Logfile 
    show_exit
  fi
  echo
  echo -e "[ $SHOW_MD ] [ $CONFIG ] [ $QCISN ] HDD led check start ... " |tee -a $Logfile
  cat disk_list8.log disk_list6.log >drv_list.tmp
  for sdd in `cat drv_list.tmp` 
  do
      dd if=$sdd of=/dev/null bs=1000 count=10000
      status=$?
      if [ $status -ne 0 ]; then
          print_red "$sdd led check FAIL " |tee -a $Logfile
          show_exit
      else
          print_green "$sdd led check PASS " |tee -a $Logfile
          sleep 1
      fi
  done
  remark  
}

_1S2RZZZ0STE(){
  #1S2RZZZ0STE an FAT have 10 SATA hdd check
  expect_hdd_num=10
  echo -e "[ $SHOW_MD ] [ $CONFIG ] [ $QCISN ] HDD number check start ... " |tee -a $Logfile
  detect_8port_control
  found_hdd_8_port
  found_hdd_6_port
  get_hdd_num=`expr $disk8_num + $disk6_num`
  echo -en "HDD number check : [ expect_hdd_num> $expect_hdd_num ] " |tee -a $Logfile
  if [ $expect_hdd_num -eq $get_hdd_num ]; then
    print_green "PASS" |tee -a $Logfile
  else
    print_red "FAIL [ get_hdd_num> $get_hdd_num]" |tee -a $Logfile 
    show_exit
  fi
  echo
  echo -e "[ $SHOW_MD ] [ $CONFIG ] [ $QCISN ] HDD led check start ... " |tee -a $Logfile
  cat disk_list8.log disk_list6.log >drv_list.tmp
  for sdd in `cat drv_list.tmp` 
  do
      dd if=$sdd of=/dev/null bs=1000 count=10000
      status=$?
      if [ $status -ne 0 ]; then
          print_red "$sdd led check FAIL " |tee -a $Logfile
          show_exit
      else
          print_green "$sdd led check PASS " |tee -a $Logfile
          sleep 1
      fi
  done
  remark  
}


delete_mr_volume(){

    MegaCli64 -CfgClr -aALL
     status=$?
    if [ $status -ne 0 ];then
        print_red "Error (delete_mr_volume): MegaCli64 failed with status $status" |tee -a $Logfile
        show_exit
    else
        print_green "MegCli64 config clear PASS" |tee -a $Logfile
    fi
    sleep 2
}

get_hdd_num(){
     rm -rf pdlist.tmp
     MegaCli64 -pdlist -a0 >pdlist.tmp
     status=$?
     if [ $status -ne 0 ]; then
        print_red "Error : MegaCli64 get SATA HDD info FAIL" |tee -a $Logfile
        show_exit
     else
        get_hdd_num=`cat pdlist.tmp |grep "Slot Number:" |wc -l`
        print_green "Get hdd number form BP : $get_hdd_num " |tee -a $Logfile
     fi
     sleep 1

}

get_enclosure_id(){
     #just for S2RQ 3.5 hdd_number=12
     enclosue_id=`cat pdlist.tmp |grep "Enclosure Device ID:" |uniq |awk '{print $4}'`
}

creat_raid_056(){
     #creat raid 0 5 6 for all free hdd
     MegaCli64 -cfgallfreedrv -r5 wt adra direct -a0
     status=$?
     if [ $status -ne 0 ]; then
        print_red "Error : MegaCli64 creat raid 5 FAIL" |tee -a $Logfile
        show_exit
     else
        print_green "MegaCli64 creat raid 5 PASS" |tee -a $Logfile
     fi
     sleep 1 
}

offline_drv0(){
    MegaCli64 -pdoffline -physdrv [$enclosue_id:0] -a0
    status=$?
    if [ $status -ne 0 ]; then
        print_red "Error : MegaCli64 pdoffline physdrv [$enclosue_id:0] -a0 FAIL" |tee -a $Logfile
        show_exit
    else
        print_green "PASS: MegaCli64 pdoffline physdrv [$enclosue_id:0] -a0 PASS" |tee -a $Logfile
    fi
}



creat_each_raid0(){
    MegaCli64 -cfgeachdskraid0 -a0 >/dev/null
    status=$?
    if [ $status -ne 0 ]; then
        sleep 2
        print_red "Error : Creat Raid 0 FAIL" |tee -a $Logfile
        show_exit
    else
        sleep 2
        print_green "Creat each HDD raid 0 Pass " |tee -a $Logfile
    fi
}

rear_sdd_connector_chk(){
    #on for S2RQ model 
    #check number and Led
    #expect number : 2
    rm -rf drv_list.tmp
    export exp_sdd_number=2
    print_yellow "check rear sdd connector now ..." |tee -a $Logfile
    get_sdd_number=`lshw -short |grep -A7 -i "Patsburg 6-Port SATA AHCI Controller" |grep "/dev/sd" |wc -l`
    if [ $exp_sdd_number -ne $get_sdd_number ] ;then
        print_red "sdd number check fail! [ exp> sdd number: $exp_sdd_number; get> sdd number: $get_sdd_number]" |tee -a $Logfile
        print_yellow "Please check rear sdd connector or have 2 sdd storage insert ..."
        show_exit
    else
        print_green "check rear sdd connector PASS!" |tee -a $Logfile
    fi
    sleep 1
    print_yellow "check rear sdd board Led now ...." |tee -a $Logfile
    lshw -short |grep -A7 -i "Patsburg 6-Port SATA AHCI Controller" |grep "/dev/sd" |awk '{print $2}' >drv_list.tmp
    for sdd in `cat drv_list.tmp` 
    do
      dd if=$sdd of=/dev/null bs=1 count=1
      status=$?
      if [ $status -ne 0 ]; then
          print_red "$sdd led check FAIL " |tee -a $Logfile
          show_exit
      else
          print_green "$sdd led check PASS " |tee -a $Logfile
      fi
    done
}

s2rs_35_hdd_chk(){
  #for S2RS 3.5 model
  #check number and Led
  #expect number : 4
  rm -rf drv_list.tmp
  export exp_sdd_number=4
  print_yellow "check S2RS-3.5 HDD connector now ..." |tee -a $Logfile
  get_sdd_number=`lshw -short |grep -A5 "Patsburg 4-Port SATA Storage Control Unit" |grep "/dev/sd" |wc -l`
  if [ $exp_sdd_number -ne $get_sdd_number ]; then
     print_red "sdd number check fail! [ exp> sdd number: $exp_sdd_number; get> sdd number: $get_sdd_number]" |tee -a $Logfile
     print_yellow "Please check front HDD connector or have 4 Hdd storage insert ..."
     show_exit
  else
      print_green "check front HDD connector PASS!" |tee -a $Logfile
  fi  
  sleep 1
  print_yellow "check front Hdd Led now ...." |tee -a $Logfile
  lshw -short |grep -A5 "Patsburg 4-Port SATA Storage Control Unit" |grep "/dev/sd" |awk '{print $2}' >drv_list.tmp
  for sdd in `cat drv_list.tmp` 
  do
      dd if=$sdd of=/dev/null bs=1 count=1
      status=$?
      if [ $status -ne 0 ]; then
          print_red "$sdd led check FAIL " |tee -a $Logfile
          show_exit
      else
          print_green "$sdd led check PASS " |tee -a $Logfile
      fi
  done
}

s2rq_35_hdd_chk(){
      #add time 2012/02/26
      #for S2RQ 3.5 HDD number =12; SDD=2; USB=1     
      delete_mr_volume
      rear_sdd_connector_chk
      sleep 2
      print_yellow "Now check fornt HDD number and LED... Press anykey to continue ...."
      anykey
      export exp_hdd_num=12
      get_hdd_num
      if [ $exp_hdd_num -ne $get_hdd_num ]; then
        print_red "The front HDD number check FAIL: [exp : $exp_hdd_num  get : $get_hdd_num ]" |tee -a $Logfile
        show_exit
      else
        print_green "HDD Number check PASS" |tee -a $Logfile
      fi
      sleep 1
      creat_each_raid0
      echo "sleep 5"; sleep 5
      delete_mr_volume
      sleep 1
      man_answer "The front HDD led check PASS or FAIL [Y/N]?"
      echo ".$answer."
      if [ "$answer" == "Y" ] || [ "$answer" == "P" ]; then
        print_green "OP check Front HDD led PASS " |tee -a $Logfile
      else
        print_red "OP check Front HDD led FAIL " |tee -a $Logfile
        show_exit
      fi
}

_red_led(){
      
      #for S2RQ 3.5 HDD number =12; SDD=2; USB=1  ;1S2RZZZ0ST5 ;#add time 2012/02/26
      #for S2RS 2.5 HDD number =10;                1S2RZZZ0STC ;#add time 2012/03/23 
      print_yellow "Now check fornt HDD red LED... Press anykey to continue ...."
      anykey
      get_enclosure_id
      creat_raid_056
      sleep 2
      offline_drv0
      man_answer "The front HDD led light red color YES or No [Y/N]?"
      echo ".$answer."
      if [ "$answer" == "Y" ] || [ "$answer" == "P" ]; then
        delete_mr_volume
        print_green "OP check Front HDD red color PASS " |tee -a $Logfile
      else
        print_red "OP check Front HDD led color FAIL " |tee -a $Logfile
        show_exit
      fi
}

_1S2RZZZ0STC(){
  #2.5 hdd 10 ; use fixture LSI_9260_8i
  #add time 03/23/2012
  echo -e "[ $SHOW_MD ] [ $CONFIG ] [ $QCISN ] HDD number check start ... " |tee -a $Logfile
  delete_mr_volume
  export exp_hdd_num=10
  get_hdd_num
  if [ $exp_hdd_num -ne $get_hdd_num ]; then
        print_red "The front HDD number check FAIL: [exp : $exp_hdd_num  get : $get_hdd_num ]" |tee -a $Logfile
        show_exit
  else
        print_green "HDD Number check [ $exp_hdd_num ] PASS" |tee -a $Logfile
  fi
  sleep 1
  creat_each_raid0
  echo "sleep 5"; sleep_t 5
  delete_mr_volume
  sleep 1
  man_answer "The front HDD led check PASS or FAIL [Y/N]?"
  echo ".$answer."
  if [ "$answer" == "Y" ] || [ "$answer" == "P" ]; then
        print_green "OP check Front HDD led PASS " |tee -a $Logfile
  else
        print_red "OP check Front HDD led FAIL " |tee -a $Logfile
        show_exit
  fi
  _red_led
}

_1S2RU9Z0ST1(){
  #3.5 hdd 10 ; raid card LSI_9260
  #add time 03/28/2012
  echo -e "[ $SHOW_MD ] [ $CONFIG ] [ $QCISN ] HDD number check start ... " |tee -a $Logfile
  rm -rf linkall.cfy
  cp /test/s2r/linkall.cfy .
  exp_hdd_num=`cat linkall.cfy |grep "HDD=" |wc -l`
  get_hdd_num
  if [ $exp_hdd_num -ne $get_hdd_num ]; then
        print_red "The front HDD number check FAIL: [exp : $exp_hdd_num  get : $get_hdd_num ]" |tee -a $Logfile
        show_exit
  else
        print_green "HDD Number check [ $exp_hdd_num ] PASS" |tee -a $Logfile
  fi

#------------------------------------------------------------------------------#  
  #add HDD part number check for this config
  export exp_hdd_pn="WD1003FBYX-01Y7B1"
  echo "HDD Part number check start..." |tee -a $Logfile
  if [ `cat pdlist.tmp |grep "$exp_hdd_pn" |wc -l` -ne $exp_hdd_num ]; then
    print_red "HDD Part number check FAIL " |tee -a $Logfile
    cat pdlist.tmp |grep "Inquiry Data:" >>$Logfile
    show_exit
  else
    print_green "HDD Part number check PASS" |tee -a $Logfile
  fi
#------------------------------------------------------------------------------#  
  sleep 1
  creat_each_raid0
  echo "sleep 5"; sleep_t 5
  delete_mr_volume
  sleep 1
  man_answer "The front HDD led check PASS or FAIL [Y/N]?"
  echo ".$answer."
  if [ "$answer" == "Y" ] || [ "$answer" == "P" ]; then
        print_green "OP check Front HDD led PASS " |tee -a $Logfile
  else
        print_red "OP check Front HDD led FAIL " |tee -a $Logfile
        show_exit
  fi
  _red_led
  
}



hdd_test(){
  if [ "$SHOW_MD" == "S2RQ" ]; then
    if [ "$CONFIG" == "1S2RZZZ0ST5" ] || [ "$CONFIG" == "1S2RZZZ0ST8" ]; then
      #1S2RZZZ0ST5 have 14 hdd; 3.5 HDD number =12; SDD=2 
      s2rq_35_hdd_chk
      _red_led
      
    elif [ "$CONFIG" == "1S2RZZZ0ST6" ] || [ "$CONFIG" == "1S2RZZZ0ST9" ]; then
      #for age1="Patsburg 8-Port SATA/SAS Storage Control Unit"
      _1S2RZZZ0ST6 
        
    elif [ "$CONFIG" == "1S2RZZZ0ST4" ] || [ "$CONFIG" == "1S2RZZZ0ST7" ]; then
      #for S2RQ 2.5
      DIAG_NAME=lhdd     
      FT "Storage(HDD0)" "$DIAG_NAME -drv sda -interval 1000"
      FT "Storage(HDD1)" "$DIAG_NAME -drv sdb -interval 1000"
      FT "Storage(HDD2)" "$DIAG_NAME -drv sdc -interval 1000"
      FT "Storage(HDD3)" "$DIAG_NAME -drv sdd -interval 1000"
    elif [ "$CONFIG" == "1S2RU9Z0ST1" ]; then
      _1S2RU9Z0ST1
    fi
  elif [ "$SHOW_MD" == "S2RS" ]; then
    if [ "$CONFIG" == "1S2RZZZ0STA" ] || [ "$CONFIG" == "1S2RZZZ0STB" ]; then
      #for S2RS 3.5 #HDD test 4 HDD #1S2RZZZ0STA
      s2rs_35_hdd_chk
    
    elif [ "$CONFIG" == "1S2RZZZ0STE" ] || [ "$CONFIG" == "1S2RZZZ0STF" ]; then
      #for S2RS 2.5 #HDD test 10 HDD #1S2RZZZ0STE
      _1S2RZZZ0STE 
            
    elif [ "$CONFIG" == "1S2RZZZ0STC" ] || [ "$CONFIG" == "1S2RZZZ0STD" ]; then
      #for S2RS 2.5 #HDD test 10 HDD TE TC have different BP board and middle board 
      #use sas fixture LSI_9260_8i #1S2RZZZ0STC
      _1S2RZZZ0STC
      
    fi
  fi     
}
hdd_test