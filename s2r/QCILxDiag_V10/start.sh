#!/bin/bash
#ONLY 1st line of batch script = Declare the bash this script uses.
#================================================================
DIAG_VER=1.0
BATCH_LOG="Output.log"
UserLoop=1
CHK_CPU=1
CHK_SSE4=1
CHK_PIC=1
CHK_CMOS=1
CHK_DMA=1
CHK_RTC=1
CHK_VIDEO=0
CHK_COM=1
CHK_PCIe=1
CHK_Beep=0
CHK_HPET=0
CHK_NIC=1
CHK_CDROM=0
CHK_HDD=1
CHK_MEM=1

COM_PORT="1"

Auto_LAN_PORT=0		#Enable=All of LAN, disable=LAN_PORT
LAN_PORT="eth0"
SERVER_IP="192.168.0.254"

Auto_HDD_DEV=1		#Enable=All of HDD, disable=HDD_DEV
HDD_DEV="sdb" 

Auto_MemTestSize=0	#Enable=max free memory, disable=MemTestSize
MemTestSize=512000000	#500M=500*1024*1024=512000000 Byte
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

    if [ $Cnt -ne $Total -a $Auto_HDD_DEV -eq 1 ]; then
        printf "$ESC_RED%s$ESC_OFF\n" "Check HDD number error!" | $STOFILE 
        Show_FAIL
    else
        printf "$ESC_GREEN%s$ESC_OFF\n" "Check HDD number ok!" | $STOFILE  
    fi
fi

}


clear
echo -e "\033[1m[QCILxDiag] Ver$DIAG_VER by Quanta Computer Inc.\033[0m"|tee -a $BATCH.LOG
echo  ""  |tee -a $BATCH.LOG

Loop=0
while [ $Loop -lt $UserLoop ]
do
    Loop=$(( Loop + 1 ))
    printf   "$ESC_GREEN#########################################################\n"| $STOFILE;
    printf   "$ESC_GREEN#		QCILxDiag Ver:$DIAG_VER LOOP $Loop		#\n"| $STOFILE;
    printf   "$ESC_GREEN#########################################################$ESC_OFF\n"| $STOFILE;
    Diag_Test
done



echo  ""  |tee -a $BATCH.LOG                                                             
echo  "End of Ver$DIAG_VER QCILxDiag Tests!!!" echo  ""  |tee -a $BATCH.LOG     
echo  ""  |tee -a $BATCH.LOG     

Show_PASS  
