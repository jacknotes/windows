#.net web环境准备：
1. .net framework在iis安装之前安装，iis会在ISAPI筛选器中自动注册ASP .Net相应版本筛选器，
如果在iis安装之后安装则不会在ISAPI筛选器中自动注册ASP，需要执行c:\Windows\Microsoft.NET\Framework64\v4.0.30319\>aspnet_regiis.exe -i
进行注册，注册好后就可以在ISAPI筛选器中看到注册的相应版本Framework。(c:\Windows\Microsoft.NET\Framework64\v4.0.30319\>aspnet_regiis.exe -u是进行卸载)
2. 注册成功后，在"ISAPI和CGI限制"中允许已经注册的Framework版本。

#警告：此密钥备份还原会导致还原时出现无法导入用户名和密码，建议不要使用密钥备份还原。
密钥备份还原
cd C:\Windows\Microsoft.NET\Framework64\v4.0.30319
A机
aspnet_regiis -px "iisConfigurationKey" "D:\iisConfigurationKey.xml" -pri 
aspnet_regiis -px "iisWasKey" "D:\iisWasKey.xml" -pri 

B机
cd C:\Windows\Microsoft.NET\Framework64\v4.0.30319
aspnet_regiis -pi "iisConfigurationKey" "D:\iisConfigurationKey.xml" 
aspnet_regiis -pi "iisWasKey" "D:\iisWasKey.xml"

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


站点配置问题汇总：
注：安装好net framework后，需要在IIS管理器中服务器级别选择"ISAPI和CGI限制"并对其配置，允许ASP.NET V4.0功能
rpt.hs.com	站点目录需要本地用户组SRV-WEB01\IIS_IUSRS有访问读写权限
oa.hs.com		需要开启ASP.NET 模拟、windows两个身份验证才行
images.homsom.com	需要使用普通用户访问UNC路径，否则无权限访问而造成站点无法正常对外服务
erp.hs.com	等老网站，需要在应用程序池的高级设置中"启用32位应用程序"功能才可使服务正常对外服务
tms.hs.com	站点目录需要本地用户组SRV-WEB01\IIS_IUSRS有访问读写权限，并且需要安装.net framework3.5和4.6.1

