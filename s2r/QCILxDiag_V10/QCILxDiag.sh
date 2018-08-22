#!/bin/bash
#ONLY 1st line of batch script = Declare the bash this script uses.
#================================================================
DIAG_VER=1.0	#2011/09/1 by Y.J
BATCH_LOG="Output.log"
UserLoop=1
BIOS_VER=S2E_2A04
CHK_BIOS=1
CHK_CPU=0
CHK_CPU_Quantity=1	#If set CHK_CPU_Quantity=1, Please input num of physical CPU
NumOfPhyCPU=1

CHK_SSE4=0
CHK_PIC=0
CHK_CMOS=0
CHK_DMA=0
CHK_RTC=0
CHK_VIDEO=0
CHK_COM=0
COM_PORT="1"		#COM_PORT="1 2"

CHK_PCIe=0
CHK_Beep=0
CHK_HPET=0
CHK_NIC=0
Auto_LAN_PORT=1		#Auto_LAN_PORT=1 Test all of LAN, 
			#Auto_LAN_PORT=0 only Test LAN_PORT LAN_PORT="eth0"
Auto_LAN_Cnt=2		#Check Device Count, Depend on "Auto_LAN_PORT=1"
LAN_PORT="eth0"		#LAN_PORT="eth0 eth1 eth2"
SERVER_IP="192.168.0.254"   #Echo server IP

CHK_CDROM=0
CHK_HDD=0
Auto_HDD_DEV=1		#Auto_HDD_DEV=1 Test all of HDD, Auto_HDD_DEV=0 only Test HDD_DEV="sda"
Auto_HDD_Cnt=3		#Check Device Count, Depend on "Auto_HDD_PORT=1"
HDD_DEV="sda" 		#HDD_DEV="sda sdb sdc"

CHK_MEM=0
Auto_MemTestSize=0	#Auto_MemTestSize=1 Test max free memory, 
			#Auto_MemTestSize=0 only test MemTestSize=512000000
MemTestSize=512000000	#500M=500*1024*1024=512000000 Byte
CHK_MEM_Size=1		#If set CHK_MEM_Size=1, Please input MEMGB=? (GB)
MEMGB=8			#default GB
AllOfMemSize=$((MEMGB*1024))	

CHK_BMC=1
BMC_Config="s2ebmcm3.ini"

CHK_ExtTool=1
ExtTool_PATH=./utility
ExtTool_Config="stress.cfg"
ExtStressTool_PATH=./bit
script_name_of_bit="2c_bit_script.cfg"

#================================================================

MAC_0=`ifconfig |grep eth0|sed 's/^.*HWaddr //'|awk 'BEGIN {FS=":"} {print $1$2$3$4$5$6}'|sed 's/^/MAC_/'`
ret=""
rm $BATCH_LOG -f >> /dev/null
rm LogFile.log -f >>/dev/null


STOFILE="tee -a $BATCH_LOG"

ESC_GREEN="\033[32m"
ESC_RED="\033[31m"
ESC_YELLOW="\033[33m"
ESC_OFF="\033[0m"

#=====================================================
#Display info
#=====================================================
Show_PASS()
{
                printf   "\n"
                printf   "$ESC_GREEN######     ####     ######   ######  \n"| $STOFILE;
                printf   "$ESC_GREEN##   ##  ##    ##  ##       ##       \n"| $STOFILE;
                printf   "$ESC_GREEN######   ########   ######   ######  \n"| $STOFILE;
                printf   "$ESC_GREEN##       ##    ##        ##       ## \n"| $STOFILE;
                printf   "$ESC_GREEN##       ##    ##   ######   ######  $ESC_OFF\n"| $STOFILE;
                printf   "\n"
                exit 0
}
Show_FAIL()
{
                printf    "\n"
                printf    "$ESC_RED#######   ####    #####  ##         \n"| $STOFILE;
                printf    "$ESC_RED##      ##    ##   ##    ##         \n"| $STOFILE;
                printf    "$ESC_RED######  ########   ##    ##         \n"| $STOFILE;
                printf    "$ESC_RED##      ##    ##   ##    ##         \n"| $STOFILE;
                printf    "$ESC_RED##      ##    ##  #####  #######    $ESC_OFF\n"| $STOFILE;
                printf    "\n"
                exit 1
}

function FT()
{
	echo -e "[-$1- test start...]"|tee -a $BATCH_LOG     		#$1=SHOW_DIAG_TITLE
	retry=0                             #CDROM/USB/COM test 3 times
	if [ "$1" == "CDROMtest" ]; then
	while [ $retry -lt 3 ]
	do
	    ./$2		
	    ret=$?
	    if [ "$ret" == "0" ]; then
		retry=100
	    else
		retry=`expr $retry + 1`
		umount /mnt/cdrom
  		eject /dev/sr0
		if [ "$rerty" != 3 ]; then
  		   echo -e "\e[3${retry}m  Please insert or replace CD. Press any key to continue(Retry=${retry})...\e[0m"
		   read
		   echo "Waiting for 20s to mount the CD..."
                   sleep 20 
	  	   mount -o loop /dev/sr0 /mnt/cdrom
		   sleep 5
		fi
	    fi	
	done
		
	elif [ "$1" == "USB" ]; then
	while [ $retry -lt 3 ]
	do
		./$2		
		ret=$?
		if [ "$ret" == "0" ]; then
			retry=100
		else
			retry=`expr $retry + 1`
			if [ "$retry" != "3" ]; then
  			echo -e "\e[3${retry}m  Please insert or replace USB drive. Press any key to continue(Retry=${retry})...\e[0m"
			read
                	echo "Waiting for 10s to mount USB drive..."
                	sleep 10 
                	fi
		fi	
	done
		
    	elif [ "$1" == "COM_PORT" ]; then
	while [ $retry -lt 3 ]
	do
		./$2		
		ret=$?
		if [ "$ret" == "0" ]; then
			retry=100
		else
			retry=`expr $retry + 1`
			if [ "$retry" != "3" ]; then
  			echo -e "\e[3${retry}m  Please insert or replace COM loopback. Press any key to continue(Retry=${retry})...\e[0m"
			read
                	echo "Waiting for 10s to re-test..."
                	sleep 10 
                	fi
		fi	
	done
	else
		./$2		
		ret=$?              #$?=return value
	fi
	
	echo |tee -a $BATCH_LOG
	if [ "$ret" == "0" ]; then		     	#judge $?="0" 0=test pass
	    echo -e "\033[1;42m$1 Test PASS!" "(ErrorLevel=$ret)\033[0m"|tee -a $BATCH_LOG
	else
	    echo -e "\033[1;41m$1 Test FAIL. (ErrorLevel = $ret)\033[0m"|tee -a $BATCH_LOG
	    Show_FAIL
	fi
	echo -e "[-$1- test end]\n\n"|tee -a $BATCH_LOG
	sleep 1
}

Diag_Test ()
{
#=====================================================
#BIOS Test
#=====================================================
if [ $CHK_BIOS -eq 1 ];then
#Get BIOS from MB
MB_BIOS=`dmidecode -t 0 | egrep "Version" | awk '{ print $2 }'`
    if [ "$BIOS_VER" != "$MB_BIOS" ];then
	echo -e "\033[1;41mCheck BIOS Test FAIL. \033[0m"|tee -a $BATCH_LOG
	echo -e "\033[1;41mBIOS Exp=$BIOS_VER, Get=$MB_BIOS\033[0m"|tee -a $BATCH_LOG
        Show_FAIL
    else
	echo -e "\033[1;42mCheck BIOS Test PASS!" "(ErrorLevel=0)\033[0m"|tee -a $BATCH_LOG
    fi

fi
#=====================================================
#CPU Test
#=====================================================

if [ $CHK_CPU_Quantity -eq 1 ];then

CPU_Quantity=`grep 'physical id' /proc/cpuinfo | sort | uniq | wc -l`
#echo $CPU_Quantity
    if [ $CPU_Quantity -ne $NumOfPhyCPU ]; then
	echo -e "\033[1;41mCheck CPU Quantity Test FAIL. \033[0m"|tee -a $BATCH_LOG
	echo -e "\033[1;41mCPU Exp Cnt=$NumOfPhyCPU, Get Cnt=$CPU_Quantity\033[0m"|tee -a $BATCH_LOG
        Show_FAIL
    else
	echo -e "\033[1;42mCheck CPU Quantity Test PASS!" "(ErrorLevel=0)\033[0m"|tee -a $BATCH_LOG
    fi
fi


if [ $CHK_CPU -eq 1 ];then
DIAG_NAME=CPUtest
FT "CPU(Cache)" "$DIAG_NAME --c"
FT "CPU(FPU)" "$DIAG_NAME --f"
FT "CPU(MMX)" "$DIAG_NAME --m"
FT "CPU(SSE)" "$DIAG_NAME --s"
FT "CPU(SSE2)" "$DIAG_NAME --e"
FT "CPU(SMP)" "$DIAG_NAME --p"
FT "CPU(SMP Cache Coherency)" "$DIAG_NAME --q"    
fi

if [ $CHK_SSE4 -eq 1 ];then
#SSE4
DIAG_NAME=SSE4test
FT "CPU_SSE4" "$DIAG_NAME -a"      #SSE4test not support SSE4.1 techonology
fi


#=====================================================
#PIC Test
#=====================================================

if [ $CHK_PIC -eq 1 ];then
DIAG_NAME=PICtest
FT "PIC" "$DIAG_NAME"
fi

#=====================================================
#CMOS_RAM Test
#=====================================================

if [ $CHK_CMOS -eq 1 ];then
DIAG_NAME=CMOStest
FT "CMOS_RAM" "$DIAG_NAME"
fi

#=====================================================
#DMA Test
#=====================================================

if [ $CHK_DMA -eq 1 ];then
DIAG_NAME=rwDMA
FT "RW_DMA" "$DIAG_NAME"
fi

#=====================================================
#RTC Test
#=====================================================

if [ $CHK_RTC -eq 1 ];then
DIAG_NAME=RTCtest
FT "RTC" "$DIAG_NAME --c --a --i"
fi


#=====================================================
#Video Test
#=====================================================

if [ $CHK_VIDEO -eq 1 ];then
DIAG_NAME=lvram
FT "Video(lvram)" "$DIAG_NAME"
fi

#=====================================================
#COM PORT Test
#=====================================================
#cat /proc/tty/driver/serial

if [ $CHK_COM -eq 1 ];then
DIAG_NAME=COMtest

for Num in $COM_PORT
 do
   FT "COMtest" "$DIAG_NAME -a $Num"
 done
fi

#=====================================================
#PCIe Test
#=====================================================

if [ $CHK_PCIe -eq 1 ];then
DIAG_NAME=PCIe

if [ ! -e PCIe.ini ]; then
  ./$DIAG_NAME -o PCIe.ini
fi

FT "PCIe" "$DIAG_NAME -c PCIe.ini"
fi

#=====================================================
#Beep Test
#=====================================================
if [ $CHK_Beep -eq 1 ];then
DIAG_NAME=lbeep
FT "Beeper" "$DIAG_NAME"
fi

#=====================================================
#HPET Test
#=====================================================

if [ $CHK_HPET -eq 1 ];then
DIAG_NAME=hpet
FT "HPET" "$DIAG_NAME -n1 -s"
fi

#=====================================================
#USB Test
#=====================================================
#DIAG_NAME=USBtest
#FT "USB" "$DIAG_NAME -n1"

#=====================================================
#NIC loopback Test
#=====================================================

if [ $CHK_NIC -eq 1 ];then
DIAG_NAME=nictest

  if [ $Auto_LAN_PORT -eq 1 ];then
    Count=`ifconfig -a |grep 'HWaddr'|wc -l`
    #echo "count=$Count"
    for (( i=1; i<=$Count; i=i+1  ))
     do
         Num=`ifconfig -a |grep 'HWaddr'| sed -n "{$i,$i p}"|cut -d ' ' -f 1`
         #echo "nic=$Num"
	 FT "NIC($Num)" "$DIAG_NAME --loopback $SERVER_IP $Num"
     done

    if [ $Auto_LAN_Cnt -ne $Count ]; then
        printf "$ESC_RED %s$ESC_OFF\n" "Check LAN number error!" | $STOFILE 
	printf "$ESC_RED LAN Exp Cnt=$Auto_LAN_Cnt, Get Cnt=$Count$ESC_OFF\n" | $STOFILE
        Show_FAIL
    fi

  else
    for Num in $LAN_PORT
     do
       FT "NIC" "$DIAG_NAME --loopback $SERVER_IP $Num"
       #FT "NIC" "$DIAG_NAME --ethtool eth0"
     done
  fi
fi

#=====================================================
#CDROM Test
#=====================================================
if [ $CHK_CDROM -eq 1 ];then
#DIAG_NAME=CDROMtest
#mv /dev/scd0 /dev/sr0
#mount -o loop /dev/sr0 /mnt/cdrom
#FT "CDROMtest" "$DIAG_NAME /mnt/cdrom/default.bin"
#umount /mnt/cdrom
#eject /dev/sr0
echo "CDROM test"
fi

#=====================================================
#HDD Test
#=====================================================

if [ $CHK_HDD -eq 1 ];then
DIAG_NAME=HDDtest   

Cnt=0
fdisk -l |grep Disk &> fdisk.ini
Total=`cat fdisk.ini |grep Disk |wc -l`
#echo $Total

    if [ $Auto_HDD_DEV -eq 1 ];then
	HDD_DEV=`cat fdisk.ini |grep Disk| awk 'BEGIN {FS=":"}$0{print $1}'| awk 'BEGIN {FS="/"}$0{print $3}'`

    fi

    for Num in $HDD_DEV
     do
       Cnt=$(( Cnt + 1 ))
       FT "Storage(HDD$Cnt)" "$DIAG_NAME --s $Num --i 1000"
     done
    #echo $Cnt

    if [ $Auto_HDD_Cnt -ne $Cnt -a $Auto_HDD_DEV -eq 1 ]; then
	echo -e "\033[1;41mCheck HDD number Test FAIL. \033[0m"|tee -a $BATCH_LOG
	echo -e "\033[1;41mHDD Exp Cnt=$Auto_HDD_Cnt, Get Cnt=$Cnt\033[0m"|tee -a $BATCH_LOG
        Show_FAIL
    else
	echo -e "\033[1;42mCheck HDD number Test PASS!" "(ErrorLevel=0)\033[0m"|tee -a $BATCH_LOG
    fi
fi


#=====================================================
#Memory Test
#=====================================================
if [ $CHK_MEM_Size -eq 1 ];then

DIMM=`dmidecode -t 17 | egrep "Size" | awk '{ print $2 }'`

for DIMMc in $DIMM;do
  if [ "$DIMMc" != "" -a "$DIMMc" != "No" ];then
      DIMM_Size=$(( DIMMc + DIMM_Size ))
  fi
done
#echo $DIMM_Size $AllOfMemSize

    if [ $DIMM_Size -ne $AllOfMemSize ];then
	echo -e "\033[1;41mCheck Memory size Test FAIL. \033[0m"|tee -a $BATCH_LOG
	echo -e "\033[1;41mMem Exp Cnt=$AllOfMemSize, Get Cnt=$DIMM_Size\033[0m"|tee -a $BATCH_LOG
        Show_FAIL
    else
	echo -e "\033[1;42mCheck Memory size Test PASS!" "(ErrorLevel=0)\033[0m"|tee -a $BATCH_LOG
    fi
fi

if [ $CHK_MEM -eq 1 ];then
DIAG_NAME=memtest

swapoff -a
    if [ $Auto_MemTestSize -eq 1 ];then
        FT "Memory" "$DIAG_NAME --module 1"
    else 
        FT "Memory" "$DIAG_NAME --module 1 --size $MemTestSize"   
    fi 
swapon -a
fi

#=====================================================
#External Tool
#=====================================================

if [ $CHK_ExtTool -eq 1 ];then
#Just Only for CPU/Memory stress
#If you want to change the run time, please modify $ExtTool_PATH/stress.cfg
cd $ExtTool_PATH
rm -r "lstress.log"
DIAG_NAME=cmd_lstress
FT "ExtTool Quanta stress" "$DIAG_NAME -c $ExtTool_Config"
cd ..
egrep "FAIL" "$ExtTool_PATH/lstress.log" 
if [ $? -eq 0 ];then
  echo -e "\033[1;41mQuanta stress Test FAIL, check $ExtTool_PATH/lstress.log\033[0m"|tee -a BATCH_LOG
  Show_FAIL
else

  echo -e "\033[1;42mQuanta stress Test PASS!" "(ErrorLevel=0)\033[0m"|tee -a $BATCH_LOG
fi 

#BurnIn stress
cd $ExtStressTool_PATH
rm -r "/tmp/BIT_log.log"

./bit_cmd_line_x64 -C $script_name_of_bit
cd ..
egrep -i "FAIL" "/tmp/BIT_log.log" 
if [ $? -eq 0 ];then
  echo -e "\033[1;41mBurnIn stress Test FAIL, check /tmp/BIT_log.log\033[0m"|tee -a $BATCH_LOG
  Show_FAIL
else

  echo -e "\033[1;42mBurnIn stress Test PASS!" "(ErrorLevel=0)\033[0m"|tee -a $BATCH_LOG
fi 


fi

#=====================================================
#BMC Test
#=====================================================

if [ $CHK_BMC -eq 1 ];then

    if [ ! -f $BMC_Config ]; then
        printf "$ESC_RED%s$ESC_OFF\n" "Error: Not found BMCtest config file" | $STOFILE 
        Show_FAIL
    fi

    DIAG_NAME=BMCtest
    FT "BMC" "$DIAG_NAME qcioem $BMC_Config"
fi

}

#=====================================================
#Start 
#=====================================================
clear
echo -e "\033[1m[QCILxDiag] Ver$DIAG_VER by Quanta Computer Inc.\033[0m"| $STOFILE
echo  ""  | $STOFILE

Loop=0
while [ $Loop -lt $UserLoop ]
do
    Loop=$(( Loop + 1 ))
    printf   "$ESC_GREEN#########################################################\n"| $STOFILE;
    printf   "$ESC_GREEN#		QCILxDiag Ver:$DIAG_VER LOOP $Loop		#\n"| $STOFILE;
    printf   "$ESC_GREEN#########################################################$ESC_OFF\n"| $STOFILE;
    Diag_Test
done



echo  ""  | $STOFILE                                                             
echo  "End of Ver$DIAG_VER QCILxDiag Tests!!!" echo  ""  | $STOFILE     
echo  ""  | $STOFILE     

Show_PASS  
