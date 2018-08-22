#!/bin/bash
create_offline_package(){
	dir=`pwd`
	if [ -d /offlinepackage ];then
		rm -rf /offlinepackage
	else
		mkdir /offlinepackage
	fi
	dpkg -l |grep "^ii" |grep mysql |awk '{print $2}' |xargs sudo apt-get -y --allow-downgrades install --reinstall --download-only >/dev/null
	cp -r /var/cache/apt/archives /offlinepackage
	if [ $? -eq 0 ];then
		cd /offlinepackage/archives
	fi
	which dpkg-scanpackages >/dev/null
	if [ $? -ne 0 ];then
		sudo apt -y install dpkg-dev
	fi
	if [ -f /offlinepackage/archives/Packages.gz ];then
		rm -rf /offlinepackage/archives/Packages
	fi
	dpkg-scanpackages -m . | gzip -c > Packages.gz
	cd /
	tar zcvf offlinePackage.tar.gz offlinepackage > /dev/null
	rm -rf /offlinepackage
	cd $dir
}

create_offline_package

