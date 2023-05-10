#.net web环境准备：
1. .net framework在iis安装之前安装，iis会在ISAPI筛选器中自动注册ASP .Net相应版本筛选器，
如果在iis安装之后安装则不会在ISAPI筛选器中自动注册ASP，需要执行c:\Windows\Microsoft.NET\Framework64\v4.0.30319\>aspnet_regiis.exe -i
进行注册，注册好后就可以在ISAPI筛选器中看到注册的相应版本Framework。(c:\Windows\Microsoft.NET\Framework64\v4.0.30319\>aspnet_regiis.exe -u是进行卸载)
2. 注册成功后，在"ISAPI和CGI限制"中允许已经注册的Framework版本。

#警告：此密钥备份还原会导致还原时出现无法导入用户名和密码，建议不要使用密钥备份还原。
#出现以下情况需要备份还原密钥：
```
应用程序池“erp.hs.com”的工作进程在尝试从文件“\\?\C:\inetpub\temp\apppools\erp.hs.com\erp.hs.com.config”的第“149”行读取配置数据时遇到错误“未能解密特性“password”
”。数据字段包含错误代码。
```
密钥备份还原
cd C:\Windows\Microsoft.NET\Framework64\v4.0.30319
A机
aspnet_regiis -px "iisConfigurationKey" "D:\iisConfigurationKey.xml" -pri 
aspnet_regiis -px "iisWasKey" "D:\iisWasKey.xml" -pri 

B机
cd C:\Windows\Microsoft.NET\Framework64\v4.0.30319
aspnet_regiis -pi "iisConfigurationKey" "D:\iisConfigurationKey.xml" 
aspnet_regiis -pi "iisWasKey" "D:\iisWasKey.xml"
aspnet_regiis -pi "iisConfigurationKey" "c:\192.168.13.205-iisConfigurationKey-202358.xml"
aspnet_regiis -pi "iisWasKey" "c:\192.168.13.205-iisWasKey-202358.xml"



删除key
aspnet_regiis -pz "iisConfigurationKey"
aspnet_regiis -pz "iisWasKey"


★在IIS7+上导出所有应用程序池的方法:
%windir%\system32\inetsrv\appcmd list apppool /config /xml > c:\apppools.xml
 

这个命令会将服务器上全部的应用程序池都导出来,但有些我们是我们不需要的,要将他们删掉.比如:
DefaultAppPool
Classic .Net AppPool
 如果在导入时发现同名的应用程序池已经存在,那么导入就会失败.
 

导入应用程序池的方法: 
%windir%\system32\inetsrv\appcmd add apppool /in < c:\apppools.xml
or
type c:\apppools.xml | %windir%\system32\inetsrv\appcmd add apppool -
 

这样就可以将全部的应用程序池都导入到另一个服务器中了.

 导出全部站点的方法:
 %windir%\system32\inetsrv\appcmd list site /config /xml > c:\sites.xml


同样,我们需要编辑sites.xml文件删除不需要的站点.如:
Default Website
 

导入站点的方法:
 %windir%\system32\inetsrv\appcmd add site /in < c:\sites.xml
or
type c:\sites.xml | %windir%\system32\inetsrv\appcmd add site /in


恢复问题汇总：
环境：windows2008R2 Enterprise
1.否则会报500.X错误？数据目录权限必需让iis有权限访问，或者让everyone用户读写，可不共享出去。

2.导入192.168.13.205备份时，报hresult: 80090005格式不对错误？经过对site配置文件进行一步步删减，最终确定错误原因，
在于erp.hs.com站点有password密码导致导入时读取错误，（1）. 可将erp.hs.com站点删除导入，然后手动建立站点erp.hs.com
（2）或者将密码(password)字段删除，并且用户名(name)为空

3.以上问题解决可以导入成功时，访问站点，服务器报500.X错误，设置目录权限后，还是报这个错误，就是应用程序池使用.net版本有问题，
这个本应该在导入时自己会配置好，不知道什么原因版本设置错误，总是设置成v2.0 .net，所以需要手动更改成v4.0 .net

4.导入应用程序池版本始终是v2.0？可以点击“应用程序池”菜单(不要选择某个详细的程序池)，然后在右边选择默认程序池版本为v4.0即可成功导入。

5.192.168.13.205部署失败，40多个站点，有10个站点有问题，不知道192.168.13.205当初部署环境时安装了啥，只能回滚(从192.168.13.204导出快照还原为新的192.168.13.205)

6.上面报hresult: 80090005格式不正确根本原因是你导入了key(密钥备份还原)，这步省略就不会报这个上错了。

7. net framwork4.0 --> 4.5 --> 4.6.1  最后在安装程序面板中只看到4.6.1，表示这个是升级安装，没有共存。

8. office安装：
	1. 先装office2007到C盘
	2. 后安装office2003到D盘
	3. 此2个版本可共存

9. WEBFILES配置共享权限：
共享权限：everyone读写
读写权限：IIS_IUSRS有读写权限


站点配置问题汇总：
注：安装好net framework后，需要在IIS管理器中服务器级别选择"ISAPI和CGI限制"并对其配置，允许ASP.NET V4.0功能
rpt.hs.com	站点目录需要本地用户组SRV-WEB01\IIS_IUSRS有访问读写权限
oa.hs.com		需要开启ASP.NET 模拟、windows两个身份验证才行
images.homsom.com	需要使用普通用户访问UNC路径，否则无权限访问而造成站点无法正常对外服务
erp.hs.com,sso.hs.com,hotelwebapi.homsom.com	等老网站，需要在应用程序池的高级设置中"启用32位应用程序"功能才可使服务正常对外服务
tms.hs.com	站点目录需要本地用户组SRV-WEB01\IIS_IUSRS有访问读写权限，并且需要安装.net framework3.5和4.6.1，必须先安装.net framework3.5、然后再安装4.6.1，否则会影响4.6.1，解决办法是重新运行4.6.1将其修复至原始状态。
images.homsom.com 站点目录指向共享\\172.168.2.220\TripPhoto，需要使用hs\iisuser用户访问才行，不能使用应用程序池用户访问，否则会有问题（例如其它网站调用此网站的图片显示不全）
注：一定要在新部署服务器打开站点看是否正常，并且对比旧站点的返回code是否一致，例如403.1和403.14不一样，需要部署成完全一样。
注：前端项目需要安装URL重写模块，否则服务无法正常访问。




# 192.168.13.229 IIS迁移
1. 安装OS，系统版本Windows Server 2012R2 Datacenter
2. 安装IIS，下一步到"Web服务器角色"--全选角色服务--确认安装
3. 备份192.168.13.229 site、apppool、hosts文件
```
$HOSTNAME="192.168.13.228"
$DATEYEAR=(get-date).Year
$DATEMONTH=(get-date).Month
$DATEDAY=(get-date).Day
$DATE="$DATEYEAR"+"$DATEMONTH"+"$DATEDAY"
$APPPOOL_CMD="apppool"
$SITE_CMD="site"
$HOSTS="hosts"
$BACKUP_DIR="\\192.168.13.72\share_backup"
$NETFRAMWORK_DIR="C:\Windows\Microsoft.NET\Framework64\v4.0.30319"
$IIS_Config_Key="iisConfigurationKey"
$IIS_Was_Key="iisWasKey"

C:\windows\system32\inetsrv\appcmd list $APPPOOL_CMD /config /xml >  $BACKUP_DIR\$HOSTNAME-$APPPOOL_CMD-$DATE.xml
C:\windows\system32\inetsrv\appcmd list $SITE_CMD /config /xml >  $BACKUP_DIR\$HOSTNAME-$SITE_CMD-$DATE.xml
copy C:\Windows\system32\drivers\etc\hosts $BACKUP_DIR\$HOSTNAME-$HOSTS-$DATE.host
```
4. 将"\\192.168.13.72\share_backup"共享下备份的文件复制到新机器"C:\Software"下
5. 在新机器上还原备份的site、apppool、hosts文件
```
$HOST_CUSTOM="192.168.13.228"
$DATE_CUSTOM="2023217"
$BACKUP_DIR="C:\Software"
$ApppoolFiles="$BACKUP_DIR\${HOST_CUSTOM}-apppool-${DATE_CUSTOM}.xml"
$SiteFiles="$BACKUP_DIR\${HOST_CUSTOM}-site-${DATE_CUSTOM}.xml"
$SourceHostsFils="$BACKUP_DIR\${HOST_CUSTOM}-hosts-${DATE_CUSTOM}"
$DestinationHostsFils="C:\Windows\System32\drivers\etc\hosts"

##DELETE
#step1:
$CurrentSites=C:\Windows\system32\inetsrv\appcmd.exe list sites
$Sites=foreach($i in $CurrentSites){($i -split '"')[1]}
foreach($i in $Sites){C:\Windows\system32\inetsrv\appcmd.exe delete site $i}

#step2:
$CurrentApppools=C:\Windows\system32\inetsrv\appcmd.exe list apppools
$Apppools=foreach($i in $CurrentApppools){($i -split '"')[1]}
foreach($i in $Apppools){C:\Windows\system32\inetsrv\appcmd.exe delete apppool $i}

##RESTORE
#step3:
type $ApppoolFiles | c:\windows\system32\inetsrv\appcmd.exe add apppool -
type $SiteFiles | c:\windows\system32\inetsrv\appcmd.exe add site - 
##copy hosts,move source directory
Copy-Item -Path $SourceHostsFils -Destination $DestinationHostsFils -Recurse
```

6. 导入apppool文件报错：
```
ERROR ( hresult:8007000d, message:命令执行失败。
数据无效。
 )
 ```
 解决办法：
原因是192.168.13.229是windows server2019，IIS版本是v10，而新机器是windows server 2012R2，IIS版本是V8.5，所以版本v8.5并不兼容v10，但v10是向下兼容v8.5的。
为了解决这个问题，我从192.168.13.228备份，因为228服务器版本是v8.5，跟新机器版本一致，不存在兼容问题。

7. 安装IIS URL重写模块2
8. 安装.net framework4.6.1
9. 同步最新站点数据
---









