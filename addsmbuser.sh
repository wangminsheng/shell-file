#!/bin/bash
# FileName: addsmbuser.sh
# Useage : sh addsmbuser.sh userlistfile / username
#批量添加用户
add_list(){
    #从userlist中读取用户帐号并循环添加
    cat $1 | while read username
    do
        #利用echo -e 的回车功能解决smbpasswd需要交互的问题，比expect简单多了
        echo -e "$username\n$username" | smbpasswd -a $username -s
        #如果添加成功，则新建家目录，避免首次直接登陆samba失败，适合公司铁将军鉴权方式，其他环境可以省略
        if [[ 0 = $? ]]
        then
            mkdir -p /home/$username
            chown -R $username:users /home/$username
        fi
    done
}
#单个添加用户
add_one() {
   echo -e "$1\n$1" | smbpasswd -a $1 -s && (
       mkdir -p /home/$1
       chown -R $1:users /home/$1
   )
}

# 先确认系统安装了samba，如果没有就安装 
which smbpasswd || yum install -y samba

#如果参数1是文件那么执行批量添加，否则就单个添加
if [[ ! -z $1 ]];then
    test -f $1 && (
        add_list $1
    ) || (
        add_one $1
    )
else
    echo "Usage: $0 username / userlistfile"
    exit 1
fi
