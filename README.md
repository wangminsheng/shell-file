Windows Samba 共享文件夹部署指南
===========================
在Windows Server 上创建Samba共享目录，提供`纵骥三维云桌面`用户存储公共和私有文件。
****
	
|作者|汪民胜|
|---|---
|E-mail|yelang007sheng@163.com


****
****
**环境准备**

|名称|操作系统|IP地址|
|---|---|---
|Samba 宿主机|Windows 2016 Server|11.11.1.94/23|
|域控主机（zy01.com）|Windows 2016 Server|11.11.1.32/23|

***
操作步骤：  
一、	更改Samba宿主机IP地址配置为静态IP,配置DNS为：11.11.1.32  
二、	将Samba宿主机加入到域zy01.com  
三、	使用域管理员登录到Samba宿主机  
四、	开始创建公共存储目录和私有目录：    
	创建文件夹：C:\ZY01\public和C:\ZY01\homes 目录  
