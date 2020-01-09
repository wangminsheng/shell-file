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


***
|样式|示例|
|--|--
|粗体|**粗体**|
|斜体|_斜体_|
|删除线|~~删除线~~|
|粗体和嵌入的斜体|**_粗体和嵌入的斜体_**|  

***
引用  
>引用别人说的话
输入以下命令：  
```
git status
git add
ait commit
```
[我的博客](https://www.cnblogs.com/hayden1106/)  
章节链接    
相对链接  
列表  
- 无序列表1  
- 无序列表2  
* 无序列表3  
* 无序列表4    

列表排序
===
1. 列表1  
2. 列表2 
3. 列表3  

嵌套列表
===
1. 管理平台  
   - 配置管理  
     - 用户管理  
     - 主机管理  
     - 应用管理
     - 组管理  
     
任务列表
===
 [x]完成更改  
 [ ]推送提交  
 [ ]打开拉取请求
