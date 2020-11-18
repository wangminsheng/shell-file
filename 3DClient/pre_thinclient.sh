#!/bin/bash
show_error="[ \e[31mError\e[0m ]"
show_pass="[ \e[32mPASSED\e[0m ]"
show_fail="[ \e[31mFAILED\e[0m ]"
show_warning="[ \e[33mWarning\e[0m ]"
LOGFILE="/opt/setup.log"
#Color print and strcmp functions
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NORMAL="\033[0m"
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
reconf_tzdata(){
	print_yellow "[ Reconfigure time zone to Shanghai... ]" |tee $LOGFILE
	print_yellow "Current time zone: $(date -R)" |tee -a $LOGFILE
	if [ $(date -R|awk '{print $6}') != "+0800" ];then
		tzdata="/usr/share/zoneinfo/Asia/Shanghai"
		if [ -f "$tzdata" ];then
			ln -fs $tzdata /etc/localtime
			dpkg-reconfigure -f noninteractive tzdata
			if [ $(date -R|awk '{print $6}') != "+0800" ];then
				print_red "reconfigure time zone to Shanghai Fialed" |tee -a $LOGFILE
				print_red "Current time zone: $(date -R)" |tee -a $LOGFILE
			else
				print_green "reconfigure time zone to Shanghai Success" |tee -a $LOGFILE
				print_green "Current time zone: $(date -R)" |tee -a $LOGFILE

			fi
		else
			print_red "reconfigure time zone to Shanghai Failed" |tee -a $LOGFILE
			print_red "Can not find file: $tzdata" |tee -a $LOGFILE
		fi
	fi
}

  get_sys_time(){
	print_green "========================================================"
		echo -e  "	System Current time:[ $YELLOW `date +'%Y-%m-%d %H:%M'`$NORMAL ]" |tee -a $LOGFILE
	print_green "========================================================"

}

chk_year(){
	stat=1
	if [ $# -gt 1 ];then
		return $stat
	elif [ $# -eq 1 ];then
		var=$1
		echo "$var" | grep '^[[:digit:]]*$' >/dev/null
		if [ $? -ne 0 ];then
			stat=2
			return $stat
		else
			if [ $var -ge 2019 ] && [ $var -le 2025 ]; then
				stat=0
			fi
		fi
	else
		return $stat
	fi
}
chk_month(){
	stat=1
	if [ $# -gt 1 ];then
		return $stat
	elif [ $# -eq 1 ];then
		var=$1
		echo "$var" | grep '^[[:digit:]]*$' >/dev/null
		if [ $? -ne 0 ];then
			stat=2
			return $stat
		else
			if [ $var -ge 1 ] && [ $var -le 12 ]; then
				stat=0
			fi
		fi
	else
		return $stat
	fi
}

chk_date(){
	stat=1
	if [ $# -gt 1 ];then
		return $stat
	elif [ $# -eq 1 ];then
		var=$1
		echo "$var" | grep '^[[:digit:]]*$' >/dev/null
		if [ $? -ne 0 ];then
			stat=2
			return $stat
		else
			if [ $var -ge 1 ] && [ $var -le 31 ]; then
				stat=0
			fi
		fi
	else
		return $stat
	fi
}

chk_hour(){
	stat=1
	if [ $# -gt 1 ];then
		return $stat
	elif [ $# -eq 1 ];then
		var=$1
		echo "$var" | grep '^[[:digit:]]*$' >/dev/null
		if [ $? -ne 0 ];then
			stat=2
			return $stat
		else
			if [ $var -ge 0 ] && [ $var -le 23 ]; then
				stat=0
			fi
		fi
	else
		return $stat
	fi
}


chk_minute(){
	stat=1
	if [ $# -gt 1 ];then
		return $stat
	elif [ $# -eq 1 ];then
		var=$1
		echo "$var" | grep '^[[:digit:]]*$' >/dev/null
		if [ $? -ne 0 ];then
			stat=2
			return $stat
		else
			if [ $var -ge 0 ] && [ $var -le 59 ]; then
				stat=0
			fi
		fi
	else
		return $stat
	fi
}

config_local_time(){
	while true
	do
		read -e -p "Please Enter the Year:[ `date +%Y` ]" year
		year=${year:-`date +%Y`}
		chk_year "$year"
		if [ $? -ne 0 ];then
			print_red "$year not a valid year, Please Try again..."
			continue
		else
			break
		fi

	done

	while true
	do
		read -e -p "Please Enter the Month:[ `date +%m` ]" month
		month=${month:-`date +%m`}
		chk_month "$month"
		if [ $? -ne 0 ];then
			print_red "$month not a valid Mouth, Please Try again..."
			continue
		else
			break
		fi

	done

	while true
	do
		read -e -p "Please Enter the Date:[ `date +%d` ]" date
		date=${date:-`date +%d`}
		chk_date "$date"
		if [ $? -ne 0 ];then
			print_red "$year not a valid Date, Please Try again..."
			continue
		else
			break
		fi

	done

	while true
	do
		read -e -p "Please Enter the Hour:[ `date +%H` ]" hour
		hour=${hour:-`date +%H`}
		chk_hour "$hour"
		if [ $? -ne 0 ];then
			print_red "$hour not a valid Hour, Please Try again..."
			continue
		else
			break
		fi

	done

	while true
	do
		read -e -p "Please Enter the Minute:[ `date +%M` ]" minute
		minute=${minute:-`date +%M`}
		chk_minute "$minute"
		if [ $? -ne 0 ];then
			print_red "$year not a valid Minute, Please Try again..."
			continue
		else
			break
		fi

	done
	conf_time="$year-$month-$date $hour:$minute"

}

set_time(){
	timedatectl set-ntp 0
	if [ $? -ne 0 ];then
		print_red "Stop Network time Fail"
		exit 1
	fi
	timedatectl set-time "$conf_time"
	if [ $? -ne 0 ];then
		print_red "Change System time Fail"
		exit 2
	fi
	hwclock -w >/dev/null
	if [ $? -ne 0 ];then
		print_red "sync systime time to RTC Fail"
		exit 3
	fi
	timedatectl set-local-rtc 0
	if [ $? -ne 0 ];then
		print_red "RTC in Universal time Fail"
		exit 4
	fi
	timedatectl set-ntp 1
	if [ $? -ne 0 ];then
		print_yellow "Setting Network time on Fail"
	else
		print_green "Setting local time OK" |tee -a $LOGFILE
		sleep 5
		hwclock -w >/dev/null
	fi
}

set_local_time(){
  clear
  get_sys_time
  echo ""
  print_yellow "Let's set local time now..." |tee -a $LOGFILE
  echo ""

  config_local_time
  echo ""
  echo -e "So the current local time is: $GREEN [ $conf_time ] $NORMAL"
  echo ""

  while true; do
    read -e -n 1 -p "Are these local time is correct?[ $conf_time ] [y/n]: " yn
    case $yn in
      [Yy]* )
  	 set_time
	   get_sys_time
	   break;;

      [Nn]* ) config_local_time;;
          * ) echo "Pleas enter y or n!";;
    esac
  done

}

chk_user(){
	stat=1
	cat /etc/passwd|grep "/bin/bash" |awk -F\: '{print $1}' >/tmp/user.log
	if [ `grep -c "$1" /tmp/user.log` -eq 1 ];then
		stat=0
		return $stat
	else
		return $stat
	fi
}

edit_auto_login_file(){
	print_yellow "	[ Edit config file for AutomaticLogin ]" |tee -a $LOGFILE
	login_conf="/etc/gdm3/custom.conf"
	if [ -f $login_conf ];then
		cp $login_conf{,.bak}
		cat >$login_conf <<EOF
[daemon]

  AutomaticLoginEnable = true
  AutomaticLogin = $user_name

  TimedLoginEnable = true
  TimedLogin = $user_name
  TimedLoginDelay = 10

[security]

[xdmcp]

[chooser]

[debug]

EOF
		print_green "	edit autologin file [$login_conf] Success" |tee -a $LOGFILE
	else
		print_red "	edit autologin file [$login_conf] Failed " |tee -a $LOGFILE
	fi

}

set_auto_login(){
	
  	print_yellow "Set Automatic Login User now..." |tee -a $LOGFILE
	while true
	do
		read -e -p "Please Enter the AutomaticLogin User:[ ${USER} ]" user_name
		user_name=${user_name:-$USER}
		chk_user "$user_name"
		if [ $? -ne 0 ];then
			print_red "$user_name not a valid User, Please Try again..."
			continue
		else
			break
		fi
	done
	edit_auto_login_file "$user_name"	



}

set_auto_start_app(){
  	
	print_yellow "Set Autostart Application now..." |tee -a $LOGFILE
	mkdir -p /home/$user_name/.config/autostart
	app_file="/home/$user_name/.config/autostart/3dclient.sh.desktop"
	cat > $app_file <<EOF
[Desktop Entry]
Type=Application
Exec=/opt/3dclient/3dclient.sh
Hidden=false
NoDisplay=yes
X-GNOME-Autostart-enabled=true
Name[zh_CN]=3dclient
Name=3dclient
Comment[zh_CN]=3dclient
Comment=3dclient

EOF
	if [ -f $app_file ];then
		
		print_green "Set AutoStart Application [ "$app_file" ] Success " |tee -a $LOGFILE
	else
		print_red "Set AutoStart Application [ "$app_file" ] Failed " |tee -a $LOGFILE
	fi	

}

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

install_openbox_online(){
	if command_exists openbox; then
		print_green "openbox_version="$(openbox --version |head -n 1)"" |tee -a $LOGFILE
	else
		sudo apt install openbox -y 
		if [ $? -eq 0 ];then
			print_green "openbox_version="$(openbox --version |head -n 1)"" |tee -a $LOGFILE
		else
			print_red "openbox install online Failed" | tee -a $LOGFILE
		fi
	fi
}

conf_lightdm(){
	print_yellow "Config lightdm.conf file now..." |tee -a $LOGFILE
	mkdir -p /etc/lightdm
	lightdm_file="/etc/lightdm/lightdm.conf"
	cat > $lightdm_file <<EOF
[Seat:*]
autologin-user=$user_name
autologin-session=openbox
EOF

	if [ -f $lightdm_file ];then
		
		print_green "Config ligthdm.conf [ "$lightdm_file" ] Success " |tee -a $LOGFILE
	else
		print_red "Config ligthdm.conf [ "$lightdm_file" ] Failed " |tee -a $LOGFILE
	fi	

}

add_appdesktopfile(){
	print_yellow "add app.desktop file now...." |tee -a $LOGFILE
	appdesktop_file="/usr/share/xsessions/app.desktop"
	cat > $appdesktop_file <<EOF
[Desktop Entry]
Name=3DClient
Comment=This session exec 3DClient app
Exec=/opt/3dclient/3dclient.sh
TryExec=/opt/3dclient/3dclient.sh
Icon=
Type=Application

EOF

	if [ -f $appdesktop_file ];then
		
		print_green "add app.desktop file [ "$appdesktop_file" ] Success " |tee -a $LOGFILE
	else
		print_red "add app.desktop file [ "$appdesktop_file" ] Failed " |tee -a $LOGFILE
	fi	

}

copy_openbox_file(){
	print_yellow "Copy openbox config files to user home..." |tee -a $LOGFILE
	home_openbox="/home/$user_name/.config/openbox"
	sudo mkdir -p "$home_openbox"
	chown -R $user_name:$user_name $home_openbox
	cp /etc/xdg/openbox/{rc.xml,menu.xml,autostart,environment} "$home_openbox"
	if [ `ls -l $home_openbox|grep -c rc.xml` -eq 1 ] && \
	   [ `ls -l $home_openbox |grep -c menu.xml` -eq 1 ] && \
	   [ `ls -l $home_openbox |grep -c autostart` -eq 1 ] && \
	   [ `ls -l $home_openbox |grep -c environment` -eq 1 ];then
		print_green "Copy openbox config files to [ $home_openbox ] Success" |tee -a $LOGFILE
	else
		print_red "Copy openbox config files to [ $home_openbox ] Failed" |tee -a $LOGFILE
	fi

}

start_openbox_alone(){
	print_yellow "Set openbox alone desktop after system power on now..." |tee -a $LOGFILE
	xinitrc_file="/home/$user_name/.xinputrc"
	cat > $xinitrc_file << EOF

# im-config(8) generated on Mon, 02 Nov 2020 14:42:07 +0800
run_im ibus
# im-config signature: 8d960ff7921b97535af47820235508ad  -
exec openbox-session

EOF
	chown -R $user_name:$user_name $xinitrc_file	
	if [ -f $xinitrc_file ];then
		
		print_green "add app.desktop file [ "$xinitrc_file" ] Success " |tee -a $LOGFILE
	else
		print_red "add app.desktop file [ "$xinitrc_file" ] Failed " |tee -a $LOGFILE
	fi	
}

starttime=$(date +%s)
echo "" > $LOGFILE
reconf_tzdata
set_local_time
set_auto_login
set_auto_start_app
install_openbox_online
conf_lightdm
add_appdesktopfile
copy_openbox_file
start_openbox_alone
endtime=$(date +%s)
print_green "$0 running time : $(expr $endtime - $starttime) Seconds." |tee -a $LOGFILE
