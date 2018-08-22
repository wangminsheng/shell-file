#!/bin/bash
# ver: 0.01 2012/02/21
check_usbdrv(){
	echo 
	if [ -d /dev/disk ]; then
		#pci-0000:00:1d.?-usb  //? 0 1 2 ...
		found_usbnum=`ls -l /dev/disk/by-path |grep -v part |grep -c "\-usb\-"`
		echo -n "USB: "
		if [ $found_usbnum -eq 0 ]; then
			print_red "NOT DETECTED"
		else
			print_green "FOUND $found_usbnum USB DEVICE(s)"
			drv_list=`ls -l /dev/disk/by-path |grep -v part |grep "\-usb\-" |awk -F\/ '{print $3}' |tr '\n' ' '`
			echo -n "Drive List: "
			print_green "$drv_list"
		fi
	else
		found_usbnum=0
	fi
	echo 
}

#check_usbdrv

if [ "$STATION" == "FAT" ] || [ "$STATION" == "FQA" ]; then
  print_yellow "Plese insert USB Press [ Enter ] to continue ..." |tee -a $Logfile
  read
  for ((i=1;i<3;i++));do
    check_usbdrv
    if [ $found_usbnum -eq 0 ]; then
	     echo -en "USB check :  "
	     print_yellow "Can not Detect !"
       print_yellow "Waiting 5s try $(($i+1))  "
	     sleep 5
	     if [ $i -eq 2 ]; then
		    echo -en "USB check :  "
		    print_red "FAIL" 
		    show_exit
	     fi
	     continue
    else
	     echo -en "USB check :  " |tee -a $Logfile
	     print_green "PASS" |tee -a $Logfile
	     break
    fi
  done
fi