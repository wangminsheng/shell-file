#############################################################################################################
# Note:
# 1. Update and Check CMOS time for delivery
# 2. Cover RTC battery lost issue            
# NTP server(win2003) setting:
#   run regedit
#   HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpServer Enabled==>1
#   HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Config\AnnounceFlags ==>5
#   run net stop w32Time && net start W32Time
#                                                                                       --04/08/10 By Jonny
#############################################################################################################
#!/bin/sh
time_check()
{
echo ""
echo -e "\e[37mChecking time against NTP server...\e[37m"
echo ""
ntpdate 172.16.1.15
if [ ! $?  -eq 0 ] ;then
itemfail "Get time Failed, please check NTP server!"
show_exit
else
echo "Getting time successfully!"
fi 

sleep 3
hc_check_1=`hwclock |cut -c1-21`
#echo $hc_check_1
hc_check_2=`hwclock |cut -c26-27`
#echo $hc_check_2
os_check_1=`date '+%a %d %b %Y %r'|cut -c1-21`
#echo $os_check_1
os_check_2=`date '+%a %d %b %Y %r'|cut -c26-27`
#echo $os_check_2
if [ "$hc_check_1" != "$os_check_1" ] || [ "$hc_check_2" != "$os_check_2" ] ; then
#  echo "CMOS time error, please check the RTC Battery!"
  return 1
else
#  echo "Time check Pass!"
  return 0
fi
}

time_update()
{
echo ""
echo -e "\e[37mUpdating time from NTP server...\e[37m"
echo ""
ntpdate 172.16.1.15
if [ ! $?  -eq 0 ] ;then
itemfail "Get time Failed, please check NTP server!"
show_exit
else
echo "Getting time successfully!"
fi 

hwclock -w
if [ ! $?  -eq 0 ] ;then
itemfail "Setting time to CMOS Failed!"
show_exit
else
echo "Setting time successfully!"
echo -e "System time is: \e[33m`date '+%D %T'`\e[37m "
fi 
}

if [ "$STATION" == "FAT" ] || [ "$STATION" == "RUNIN" ] || [ "$STATION" == "FFT" ] || [ "$STATION" == "FQA" ] ;then
 time_update
else
 if ! time_check ; then
   echo "Wait 10s to check again..."
   sleep 10
   if ! time_check ; then
    itemfail "CMOS time error, please check the RTC Battery!"
    echo "System time is $hc_check_1 $hc_check_2 , time should be $os_check_1 $os_check_2"
    show_exit
   fi
 fi
   echo ""
   echo -e "System time is: \e[33m`date '+%D %T'`\e[37m     ... [\e[32mPass\e[37m]"
   echo ""
   sleep 3
  
fi

