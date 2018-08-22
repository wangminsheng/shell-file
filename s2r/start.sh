#!/bin/bash   
ftp_or_network_drive=0
mnt_monitor_path="/mnt/monitor"
show_error="[ \e[31merror\e[0m ]"
show_pass="[ \e[32mPASSED\e[0m ]"
show_fail="[ \e[31mFAILED\e[0m ]"
show_warning="[ \e[33mwarning\e[0m ]"
export model=s2r
PATH=$PATH:/test/$model/tools:/test/$model/bios:/test/$model/bmc:/test/$model/BMCtest:/test/$model/cpu:/test/$model/hw:/test/$model/mem:/test/$model/cmos:/test/$model/bit:/test/$model/QCILxDiag:/test 

##Function define:
#------------------------------------------------------------------------------#
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NORMAL="\033[0m"

#Color print and strcmp functions
print_green(){
	[ $# -eq 0 ] && return 1
	echo -e $GREEN$@$NORMAL
}

print_red(){
	[ $# -eq 0 ] && return 1
	echo -e $RED$@$NORMAL	
}

print_yellow(){
	[ $# -eq 0 ] && return 1
	echo -e $YELLOW$@$NORMAL
}

#send_log()
#{
#  if [ ! -d /mnt/test_log/$model/$STATION ] ; then
#   mkdir -p /mnt/test_log/$model/$STATION
#  fi
#  if [ "$1" == "cr" ] ; then
#    echo " "  >> /mnt/test_log/$model/$STATION/$MAC8.log
#  else
#    echo -e "Time=`date`  | Event=$1" >> /mnt/test_log/$model/$STATION/$MAC8.log
#  fi
#}

get_uut_bmc_mode(){
  ipmitool raw 0x0c 0x02 0x01 0xff 0x00 0x00 >bmc_mode.tmp
  if [ $? -ne 0 ]; then
    print_red "Can not get UUT Management LAN Port Destination ..."
    show_exit
  else
    var=`cat bmc_mode.tmp |awk '{print $2}'`
    if [ "$var" == "00" ]; then
      print_green "Current BMC LAN Port State is share NIC mode ..." |tee -a $Logfile
      cat bmc_mode.tmp >>$Logfile
    elif [ "$var" == "01" ]; then
      print_green "Current BMC LAN Port State is dedicate NIC mode ..." |tee -a $Logfile
      cat bmc_mode.tmp >>$Logfile
    else
      print_red "unkown BMC NIC mode ..." |tee -a $Logfile
      cat bmc_mode.tmp >>$Logfile
      show_exit
    fi
  fi
}

share_lom_bmc(){
	get_uut_bmc_mode
	if [ "$var" != "00" ]; then
	   sleep 5; echo "set share lom bmc..."
	   ipmitool raw 0x0c 0x01 0x01 0xff 0x00
	   echo "sleep 20" sleep 10
	fi
}

dedicated_bmc()
{
	get_uut_bmc_mode
	if [ "$var" != "01" ]; then
	   sleep 5; echo "set dedicated bmc..."
	   ipmitool raw 0x0c 0x01 0x01 0xff 0x01
	   echo "sleep 20" sleep 10
	fi
}

show_exit(){
      mv $Logfile $Logfile.FAIL
      sleep 1 
      read_1=""
      until [ "$read_1" == "s" ] || [ "$read_1" == "S" ] || [ "$read_1" == "r" ] || [ "$read_1" == "R" ] 
      do
      echo -e "Press [S] to Shutdown the system,or Press [R] to reboot the system"' (S/R)'
      read read_1
      done
      if [ "$read_1" == "s" ] || [ "$read_1" == "S" ];then
			while true
			do 
			   send_log "System Shutdown"
               busybox poweroff
               sleep 100
            done
      fi
      if [ "$read_1" == "r" ] || [ "$read_1" == "R" ];then
			while true
			do 
				send_log "System reboot"
               reboot -f
               sleep 100
            done
      fi
      exit 1
}

sleep_t(){
	if [ $# -ne 1 ] && [ `echo "$1" |grep -c '[^0-9]'` -ne 0 ]; then
		print_red "usage: $0 [1---999]"
		show_exit
	fi
	for((i=$1;i>0;i--))
	do
  if [ `echo $((i%2))` -eq 0 ];then
			if [ $i -eq 9 ] || [ $i -eq 99 ] || [ $i -eq 999 ];then
				echo -en "Please wait ... \e[32m$i\e[0m\n"
			fi
			echo -en "Please wait ...\e[32m$i\e[0m\r"
			sleep 1
	else
			if [ $i -eq 9 ] || [ $i -eq 99 ] || [ $i -eq 999 ];then
				echo -en "Please wait ... \e[32m$i\e[0m\n"
			fi
			echo -en "Please wait ...\e[33m$i\e[0m\r"
			sleep 1
	fi 
	done
} 

itemfail()
{
            echo -e ""
            echo -e "\e[31m==================================================================\e[0m"
            echo -e "$1                                                                     "
            echo -e "\e[31m==================================================================\e[0m"
            echo -e ""
}
   
itempass()
{
            echo -e ""
            echo -e "\e[32m==================================================================\e[0m"
            echo -e "$1                                                                     "
            echo -e "\e[32m==================================================================\e[0m"
            echo -e ""
} 

amb()
{
            echo -e ""
            echo -e "\e[33m==================================================================\e[0m"
            echo -e "$1                                                                     "
            echo -e "\e[33m==================================================================\e[0m"
            echo -e ""
} 
        
get_station_from_sf()
{

      rt_err_str="send a request[station] to shopflor failed"
      if ! lhand -z $mnt_monitor_path -l -r -t; then return 1; fi
      sleep 8
      rt_err_str="get a response from shopflor failed"
      if ! lhand -z $mnt_monitor_path -l -g -t; then return 1; fi
      sleep 3
      source ./envvl.sh
      source ./gvl.sh
      cp $MAC8.txt runintime.cfg
      rt_err_str="can not get the station"
      if [ "$STATION" == "" ]; then 
       return 1
      fi
  return 0
}

send_start_to_sf(){

      rt_err_str="send a status[start] to shopflor failed"
      if ! lhand -z $mnt_monitor_path -l -s -B; then return 1; fi
      return 0
}

send_fail_to_sf(){
      rt_err_str="send a status[Fail] to shopflor failed"
      if ! lhand -z $mnt_monitor_path -l -s -L $1; then return 1; fi
      return 0
}

send_pass_to_sf(){
      rt_err_str="send a status[Pass] to shopflor failed"
      if ! lhand -z $mnt_monitor_path -l -s -P; then return 1; fi
      return 0
}


get_config_from_sf(){
      rt_err_str="send a request[station] to shopflor failed"
      if ! lhand -z $mnt_monitor_path -l -r -c; then return 1; fi
      sleep 8
      rt_err_str="get a response from shopflor failed"
      if ! lhand -z $mnt_monitor_path -l -g -c; then return 1; fi
      sleep 3
      source ./envvl.sh
      source ./gvl.sh
      cp $MAC8.txt config.cfy
      dos2unix config.cfy 
      return 0
}

get_linkall_from_sf(){
      rt_err_str="send a request[station] to shopflor failed"
      if ! lhand -z $mnt_monitor_path -l -r -A; then return 1; fi
      sleep 8
      rt_err_str="get a response from shopflor failed"
      if ! lhand -z $mnt_monitor_path -l -g -A; then return 1; fi
      sleep 3
      source ./envvl.sh
      source ./gvl.sh
      cp $MAC8.txt linkall.cfy
      dos2unix linkall.cfy
      return 0
}

man_answer(){
      answer=""
      until [ "$answer" == "y" ] || [ "$answer" == "Y" ]  || [ "$answer" == "N" ] || [ "$answer" == "n" ] || [ "$answer" == "P" ] || [ "$answer" == "p" ]  || [ "$answer" == "f" ] || [ "$answer" == "F" ]
      do
      echo -en "\e[35m $1 \e[0m"
      read answer
      done
      if [ "$answer" == "y" ] || [ "$answer" == "Y" ] || [ "$answer" == "p" ] || [ "$answer" == "P" ] ;then
                answer="Y"
      fi
      if [ "$answer" == "N" ] || [ "$answer" == "n" ] || [ "$answer" == "F" ] || [ "$answer" == "f" ] ;then
                answer="N"
      fi
}

mb_version_chk(){
if [ "$CONFIG" == "1S2RZZZ0ST4" ] || [ "$CONFIG" == "1S2RZZZ0ST5" ] || [ "$CONFIG" == "1S2RZZZ0ST6" ] || [ "$CONFIG" == "1S2RZZZ0ST7" ] || [ "$CONFIG" == "1S2RZZZ0ST8" ] || [ "$CONFIG" == "1S2RZZZ0ST9" ] || [ "$CONFIG" == "1S2RU9Z0ST1" ]; then
  export SHOW_MD="S2RQ"
  #check MB P/N is correct or not
  #MotherBoard P/N 31S2RMB0030 and 31S2RMB0040 for S2RQ
  baseboard_version=`dmidecode -s baseboard-version |tail -n 1`
  if [ "$baseboard_version" == "31S2RMB0030" ] || [ "$baseboard_version" == "31S2RMB0040" ]; then
    itempass "Mother Board version check Pass ... $baseboard_version"
  else
    itemfail "Mother Board version check FAIL ... this MB [ $baseboard_version ] not for S2RQ..."
    amb "expect MB version 31S2RMB0030 or 31S2RMB0040 for S2RQ; Please call PE support! thanks"
    show_exit
  fi    
elif [ "$CONFIG" == "1S2RZZZ0STA" ] || [ "$CONFIG" == "1S2RZZZ0STB" ] || [ "$CONFIG" == "1S2RZZZ0STC" ] || [ "$CONFIG" == "1S2RZZZ0STD" ] || [ "$CONFIG" == "1S2RZZZ0STE" ] || [ "$CONFIG" == "1S2RZZZ0STF" ] || [ "$CONFIG" == "1S2RUBZ0ST3" ]; then
  export SHOW_MD="S2RS"
  #MotherBoard P/N 31S2RMB0050 and 31S2RMB0020 for S2RS
  baseboard_version=`dmidecode -s baseboard-version |tail -n 1`
  if [ "$baseboard_version" == "31S2RMB0020" ] || [ "$baseboard_version" == "31S2RMB0050" ]; then
    itempass "Mother Board P/N check Pass ... $baseboard_version"
  else
    itemfail "Mother Board version check FAIL ... this MB [ $baseboard_version ] not for S2RS..."
    amb "expect MB version 31S2RMB0020 or 31S2RMB0050 for S2RS; Please call PE support! thanks"
    show_exit
  fi    
else
  itemfail "GET SF $CONFIG FAIL ..."
  amb "this $CONFIG not for S2RQ or S2RS, Please call PE or TE support!! thanks"
  show_exit
fi
}

get_bmc_ip()
{
	retry=0
	while [ $retry -lt 3 ]
	do
		ret="1"
		echo "Getting the BMC IP ... "
		bmcip=`ipmitool lan print 1 |grep "IP Address    " |awk '{print $4}'`
		bmcmac=`ipmitool lan print 1 |grep "MAC Address" |awk '{print $4}' | tr [A-Z] [a-z]`
		echo " BMC IP is: ---$bmcip---"
		if [ ! -z "$bmcip" ] && [ "$bmcip" != '0.0.0.0' ] ;then
			ping -c 4 $bmcip
			ret=$?
		fi
		if [ "$ret" == "0" ]; then
			break
		else
			let retry=retry+1
			if [ "$retry" != "3" ]; then
   				echo -e "\e[3${retry}m  Can not reach BMC, please check the network connection, Press any key to continue(Retry=${retry})...\e[0m"
			   # read
        	echo "Waiting for 30s to get IP..."
        #	sleep 30
        sleep_t 30
          continue 
			fi
		fi	
	done
}


#------------------------------------------------------------------------------#

#get station
if ! get_station_from_sf; then
    if ! get_station_from_sf; then
	    if ! get_station_from_sf; then
         echo -e "$show_error unknow station: $STATION"
         cat $MAC8.txt
         sleep 30
         reboot -f
		  fi    
    fi
fi

#check station
if [ "$STATION" != "FAT" ] &&  [ "$STATION" != "RUNIN" ] && [ "$STATION" != "FFT" ] && [ "$STATION" != "FQA" ] ; then
   echo -e "$show_error unkown station: $STATION"
   show_exit
fi

# get link infro
if ! get_linkall_from_sf; then
    if ! get_linkall_from_sf; then
	    if ! get_linkall_from_sf; then
         echo -e "get linkall fail !"
         echo "$rt_err_str"
         cat $MAC8.txt
         sleep 30
         reboot -f
    	fi
    fi
fi

# get config infro
if ! get_config_from_sf; then
    if ! get_config_from_sf; then
	    if ! get_config_from_sf; then
         echo -e "get config fail !"
         echo "$rt_err_str"
         cat $MAC8.txt
         sleep 30
         reboot -f
    	fi
    fi
fi

#SFC define check ...
export BIOS=`cat /test/s2r/config.cfy |grep "^CONFIG= BIOS" |awk '{print $3}'`
echo "BIOS=$BIOS"
export CONFIG=$BIOS
mb_version_chk
#------------------------------------------------------------------------------#  
export QCISN=`cat linkall.cfy |grep "^QCISN=" |awk -F\= '{print $2}'`
export BMCMAC=`cat linkall.cfy |grep "^BMC=" |awk -F\= '{print $2}'`
export MAC1=`cat linkall.cfy |grep "^MAC1=" |awk -F\= '{print $2}'`
export MAC2=`cat linkall.cfy |grep "^MAC2=" |awk -F\= '{print $2}'`
export MB_SN=`cat linkall.cfy |grep "^MB=" |awk -F\= '{print $2}'`


#SHOW_MD=`echo $model |tr "[a-z]" "[A-Z]"`

if [ -z "$CONFIG" ] ; then
  itemfail "SFC no CONFIG ! "
  cat config.cfy
  show_exit
fi

if [ -z "$QCISN" ] ; then
  itemfail "SFC no QCISN ! " 
  cat linkall.cfy
  show_exit
fi

if [ -z "$BMCMAC" ]; then
  itemfail "SFC no BMCMAC! "
  amb "Please check linkall.cfy..."
  show_exit
fi

if [ -z "$MAC1" ] ; then
  itemfail "SFC no MAC1! "
  amb "Please check linkall.cfy..."
  show_exit
fi

if [ -z "$MAC2" ] ; then
  itemfail "SFC no MAC2! "
  amb "Please check linkall.cfy..."
  show_exit
fi

if [ -z "$MB_SN" ]; then
  itemfail "SFC no MB_SN! "
  amb "Please check linkall.cfy..."
  show_exit
fi
  

#------------------------------------------------------------------------------#
#mount path for test log
mkdir -p /mnt/test_log
if ! mount -t cifs -o user=test,passwd=qcitest,rw //172.16.1.15/test_log /mnt/test_log ; then
itemfail "Can not mount to test log folder on the ECHO server  !"
show_exit
fi

if [ ! -d /mnt/test_log/$SHOW_MD/SFC ] ;then
 mkdir -p /mnt/test_log/$SHOW_MD/SFC
fi
cp linkall.cfy /mnt/test_log/$SHOW_MD/SFC/$QCISN.SFC

if [ ! -d /mnt/test_log/$SHOW_MD/$STATION ]; then
  mkdir -p /mnt/test_log/$SHOW_MD/$STATION
  rm -rf /mnt/test_log/$SHOW_MD/$STATION/$QCISN
  export Logfile="/mnt/test_log/$SHOW_MD/$STATION/$QCISN"
  echo "" >$Logfile
else
  rm -rf /mnt/test_log/$SHOW_MD/$STAION/$QCISN
  export Logfile="/mnt/test_log/$SHOW_MD/$STATION/$QCISN"
fi

#add boot form LAN Port 1 at FAT check and boot from LAN port 2 at FFT check 
#add time: 2012/02/14
#------------------------------------------------------------------------------#
if [ "$STATION" == "FAT" ]; then

 	eth=`ifconfig -a |grep "eth" |sed 's/://g' |grep -i "$MAC1" |awk '{print $1}'`
	if [ -z "$eth" ] ; then
	   itemfail "Can not found LAN MAC1 Address in the UUT ... exp> $MAC1"
	   show_exit
	fi
 ifconfig $eth |grep "inet addr:" >/dev/null
 	if [ $? != 0 ];then
		echo -e "Please use lan cable conect to \e[31mLAN MAC1\e[0m slot at \e[32mFAT\e[0m"
		show_exit
	fi
elif [ "$STATION" == "FFT" ]; then
	eth=`ifconfig -a |grep "eth" |sed 's/://g' |grep -i "$MAC2" |awk '{print $1}'`
	if [ -z "$eth" ] ; then
	   itemfail "Can not found LAN MAC2 Address in the UUT ... exp> $MAC2"
	   show_exit
	fi
 ifconfig $eth |grep "inet addr:" >/dev/null
	if [ $? != 0 ];then
		echo -e "Please use lan cable connect to \e[31mLAN MAC2\e[0m slot at \e[32mFFT\e[0m"
		show_exit
	fi
fi

#------------------------------------------------------------------------------#
#test start
#------------------------------------------------------------------------------#
clear
echo -e "\e[37;40m"
echo -e "          \e[36m|===========================================================|\e[37m"
echo -e "                        Model: \e[33m$SHOW_MD\e[37m Station: \e[33m$STATION\e[37m test start"
echo -e "          \e[36m|===========================================================|\e[37m"
echo -e "\e[37;40m"
sleep 5

echo  |tee -a $Logfile
echo "$STATION test start" |tee -a $Logfile
echo "QCISN : $QCISN  and  CONFIG : $CONFIG" |tee -a $Logfile
#recold sel log before test start ..

if ! source ./$STATION.sh; then
  itemfail "load $STATION.sh fail !!!"
  show_exit
fi

clear
echo ""
echo ""
echo ""
echo -e "          \e[36m=============================================================\e[37m"
echo -e "          \e[33m  ---------------------------------------------------------\e[37m"
echo -e "\e[32m"
echo -e "                   PP PP           AA          SSSSSSS     SSSSSSS      "
echo -e "                 PP      PP      AA  AA       SS          SS            "
echo -e "                 PP      PP     AA    AA      SS          SS            "
echo -e "                 PP PP PP      AA AAAA AA      SSSSSSS     SSSSSSS      "
echo -e "                 PP            AA      AA           SS          SS      "
echo -e "                 PP            AA      AA           SS          SS      "
echo -e "                 PP            AA      AA     SSSSSSS     SSSSSSS       "
echo -e "\e[0m"                                    
echo -e "          \e[33m  ---------------------------------------------------------\e[37m"
echo -e "       \e[36m===================================================================\e[37m"
echo ""
echo -e "       \e[36m    $STATION test finished     \e[37m"

print_green "$STATION test finished" |tee -a $Logfile


if [ "$STATION" == "RUNIN" ] ; then   
#send pass to SFC for RUNIN                                                                                           
     if ! send_pass_to_sf; then
        if ! send_pass_to_sf; then
	          if ! send_pass_to_sf; then
             	 echo "$rt_err_str" |tee -a $Logfile
               echo -e  "Send Pass to SFC fail, Please check your network !"
               echo "$rt_err_str"
               cat $MAC8.txt
               show_exit
           	fi
         fi
      fi
  busybox poweroff
  read
fi  

   echo "Please press any key, it will send SFC and shutdown..."
   anykey
#send pass to SFC for other station                                                                                         
     if ! send_pass_to_sf; then
        if ! send_pass_to_sf; then
	          if ! send_pass_to_sf; then
             	 echo "$rt_err_str" |tee -a $Logfile
               echo -e  "Send Pass to SFC fail, Please check your network !"
               echo "$rt_err_str"
               cat $MAC8.txt
               show_exit
           	fi
        fi
     fi
 
sleep 3 
  busybox poweroff   