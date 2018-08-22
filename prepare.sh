#!/bin/bash
show_error="[ \e[31mError\e[0m ]"
show_pass="[ \e[32mPASSED\e[0m ]"
show_fail="[ \e[31mFAILED\e[0m ]"
show_warning="[ \e[33mWarning\e[0m ]"
LOGFILE="$PWD/setup.log"
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
	tzdata="/usr/share/zoneinfo/Asia/Shanghai"
	if [ -f "$tzdata" ];then
		ln -fs $tzdata /etc/localtime
		dpkg-reconfigure -f noninteractive tzdata
		print_green "reconfigure time zone to Shanghai Success" |tee -a $LOGFILE
	else
		print_red "reconfigure time zone to Shanghai Failed" |tee -a $LOGFILE
	fi
}

enable_ssh_for_root(){
	print_yellow "[ Enable ssh for root login... ]" |tee -a $LOGFILE
	sshd_conf="/etc/ssh/sshd_config"
	if [ -f "$sshd_conf" ];then
		sed -i 's/\<PermitRootLogin prohibit-password\>/PermitRootLogin yes/' $sshd_conf
		/etc/init.d/ssh restart
		print_green "enable ssh for root login Success" |tee -a $LOGFILE
	else
		print_red "sshd config file [$sshd_conf] not exist" |tee -a $LOGFILE
	fi
}

install_samba(){
	print_yellow "[ Samba server install Now ...]"
	which smbpasswd >/dev/null
	if [ $? -ne 0 ];then
		apt clean all
		apt-get update
		apt-get install -y samba samba-common python-glade2 system-config-samba
		if [ $? -ne 0 ]; then
			print_red "samba server install Failed" |tee -a $LOGFILE
		else
			print_green "Samba server is installed Success [$(samba --version)]" |tee -a $LOGFILE

		fi
	else
		print_green "Samba server is installed [$(samba --version)]" |tee -a $LOGFILE
	fi

}

edit_smb_conf_file(){
	print_yellow "	[ Edit config file for Samba Server ]"
	smb_conf="/etc/samba/smb.conf"
	if [ -f $smb_conf ];then
		cp $smb_conf{,.bak2}
		cat >$smb_conf <<EOF
[global]
workgroup = WORKGROUP
server string = Samba Server %v
netbios name = ubuntu
security = user
map to guest = bad user
dns proxy = no

#============================ Share Definitions ============================== 
[Anonymous]
path = /samba/anonymous
browsable =yes
writable = yes
guest ok = yes
read only = no
force user = nobody

[secured]
path = /samba/secured
valid users = @smbgrp
guest ok = no
writable = yes
browsable = yes
EOF
		print_green "	edit smb.conf[$smb_conf] file Success" |tee -a $LOGFILE		
	else
		print_red "	edit smb.conf[$smb_conf] file Failed" |tee -a $LOGFILE
	fi		
}

create_smb_grp_users(){
	print_yellow "	[ Create samba group and user ]" |tee -a $LOGFILE
	user="zycloud"
	passwd="123.com"
	group="smbgrp"
	egrep "^\<$group\>" /etc/group >/dev/null
	if [ $? -eq 0 ];then
		print_yellow "	samba group [$group] exist" |tee -a $LOGFILE
	else
		addgroup $group
		print_green "	add samba group [$group] Success" |tee -a $LOGFILE
	fi
	
	egrep "^\<$user\>" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		usermod $user -G $group
		print_green "	Move users[$user] to the group[$group]" |tee -a $LOGFILE
	else
		useradd $user -G $group
		echo -e "$passwd\n$passwd" |smbpasswd -a $user -s
		print_green "	Create samba group[$group] and user[$user] Success " |tee -a $LOGFILE
	fi
		
}

create_smb_share_folder(){
	print_yellow "	[ Create samba share folder ]" |tee -a $LOGFILE
	samba_folder1="/samba/anonymous"
	if [ ! -d "$samba_folder1" ];then
		mkdir -p $samba_folder1
		chmod -R 0775 $samba_folder1
		chown -R nobody:nogroup $samba_folder1
		print_green "	Create smb share folder[$samba_folder1] Success" |tee -a $LOGFILE
	else
		print_yellow "	Smb share folder[$samba_folder1] is exist"
		chmod -R 0775 $samba_folder1
		chown -R nobody:nogroup $samba_folder1
		print_green "	Create smb share folder[$samba_folder1] Success" |tee -a $LOGFILE	
	fi
	create_smb_grp_users
	samba_folder2="/samba/secured"
	if [ ! -d "$samba_folder2" ];then
		mkdir -p $samba_folder2
		chmod -R 0770 $samba_folder2
		chown root:smbgrp $samba_folder2
		print_green "	Create smb share folder[$samba_folder2] Success" |tee -a $LOGFILE
	else
		print_yellow "	smb share folder[$samba_folder2] is exist"
		chmod -R 0770 $samba_folder2
		chown -R root:smbgrp $samba_folder2
		print_green "	Create smb share folder[$samba_folder2] Success" |tee -a $LOGFILE	
	fi

	print_yellow "[ reload samba ]"|tee -a $LOGFILE
	/etc/init.d/samba reload
	print_yellow "[ restart samba service ]"|tee -a $LOGFILE
	service smbd restart
}

install_docker_online(){
	print_yellow "[ Install docker now... ]" |tee -a $LOGFILE
	
	which docker >/dev/null
	if [ $? -ne 0 ];then
		apt-get install -y apt-transport-https ca-certificates curl software-properties-common
		if [ $? -ne 0 ];then
			print_red "apt-get install -y apt-transport-https ca-certificates curl software-properties-common Failed" |tee -a $LOGFILE
		else
			print_green "apt-get install -y apt-transport-https ca-certificates curl software-properties-common Success" |tee -a $LOGFILE
		fi
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
		if [ $? -ne 0 ];then
			print_red "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - Failed" |tee -a $LOGFILE
		else
			print_green "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - Success" |tee -a $LOGFILE
		fi
		sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
		if [ $? -ne 0 ];then
			print_red "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' Failed" |tee -a $LOGFILE
		else
			print_green "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' - Success" |tee -a $LOGFILE
		fi
		apt-get update
		if [ $? -ne 0 ];then
			print_red "apt-get update Failed" |tee -a $LOGFILE
		else
			print_green "apt-get update Success" |tee -a $LOGFILE
		fi

		apt-get install -y docker-ce
		if [ $? -ne 0 ];then
			print_red "apt-get install -y docker-ce  Failed" |tee -a $LOGFILE
		else
			print_green "apt-get install -y docker-ce Success" |tee -a $LOGFILE
		fi
	else
		print_green "docker server is installed [$(docker --version)]" |tee -a $LOGFILE
	fi
}

install_docker_offline(){
	print_yellow "[ Install docker now... ]" |tee -a $LOGFILE
	which docker >/dev/null
	if [ $? -ne 0 ];then
		apt-get install -y docker-ce
		if [ $? -ne 0 ];then
			print_red "apt-get install -y docker-ce  Failed" |tee -a $LOGFILE
		else
			print_green "apt-get install -y docker-ce Success" |tee -a $LOGFILE

		fi
	else
		print_green "docker server is installed [$(docker --version)]" |tee -a $LOGFILE
	fi		
}


install_mysql_client(){
	print_yellow "[ Install mysql client now... ]" |tee -a $LOGFILE
	which mysql >/dev/null
	if [ $? -ne 0 ];then
		apt update
		apt install -y mysql-client
		if [ $? -ne 0 ];then
			print_red "apt install -y mysql-client Failed" |tee -a $LOGFILE
		else
			print_green "apt install -y mysql-client Success" |tee -a $LOGFILE
		fi
	else
		print_green "mysql client is installed [$(mysql --version)]" |tee -a $LOGFILE
	fi
}

offline_prepare(){
	reconf_tzdata
	starttime=$(date +%s)
	enable_ssh_for_root
	print_yellow "[ Offline install necessary packages now... ]"
	tarfile="`pwd`/offlinePackage.tar.gz"
        if [ ! -f $tarfile ];then
		print_red "offlinePackage.tar.gz not exist" |tee -a $LOGFILE
	fi
	chmod -R 777 $tarfile
	tar xvf $tarfile -C /tmp >/dev/null
	package_path="/tmp/offlinepackage/archives" 
        sources_list="/etc/apt/sources.list"
        if [ -f $sources_list ];then
                cp $sources_list{,.bak}
       		echo "deb [trusted=yes] file://${package_path} ./" |tee $sources_list >/dev/null    
	fi
	install_samba
	edit_smb_conf_file
	create_smb_share_folder
	install_docker_offline
	install_mysql_client
	endtime=$(date +%s)
	cp /etc/apt/sources.list.bak $sources_list
	print_green "$0 running time : $(expr $endtime - $starttime) Seconds." |tee -a $LOGFILE
	
}

online_prepare(){
	reconf_tzdata
	starttime=$(date +%s)
	enable_ssh_for_root
	install_samba
	edit_smb_conf_file
	create_smb_share_folder
	install_docker_online
	install_mysql_client
	endtime=$(date +%s)
	print_green "$0 running time : $(expr $endtime - $starttime) Seconds." |tee -a $LOGFILE

}

#main
main(){
	ping -c1 8.8.8.8 >/dev/null
	if [ $? -ne 0 ];then
		offline_prepare
	else
		online_prepare
	fi
}

main
