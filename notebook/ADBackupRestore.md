#Active Directory 备份和恢复

##1. 用户级别

### 1.1 备份
```
# AD 回收站：恢复删除的 AD 用户
# 条件：林功能级别必须在 2008R2 之上
# 保存时间：默认 180 天，可进行配置
# 默认未启用；一旦启动，无法再关闭
# 此功能只能恢复删除用户
﻿
### 开启 AD 回收站 功能﻿
1. ﻿打开 Active Directory 管理中心
2. 点击左边的 "本地" ,再点击右边的 "启用回收站"

### 修改 默认保存时间 180 天为 365 天
# 注意域名,此例子为:test.com
# 修改两个值即可：tombstoneLifetime,msDS-DeletedObjectLifetime
# 管理员打开 powershell 运行如下命令：
Set-ADObject -Identity "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=test,DC=com" –Partition "CN=Configuration,DC=test,DC=com" –Replace:@{ "tombstoneLifetime" = 365 }

Set-ADObject -Identity "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=test,DC=com" –Partition "CN=Configuration,DC=test,DC=com" –Replace:@{ "msDS-DeletedObjectLifetime" = 365 }
﻿```

### 1.2 恢复
```
1. 在 Active Directory 管理中心
2. 点击左边的 "本地"
3. 点击中间的 OU : "Deleted Objects"
4. 右击需还原的被删除用户，进行还原即可
```


## 2. 域控级别

### 2.1 备份
```
# 1. 企业中一般都会部署两台域控做互为主备
# ﻿2. 而为了防止极端情况下
     ﻿  例如：两台域控的磁盘都有问题，或者黑客入侵导致的 OU 混乱等的情况，
     而需要格外对域控做备份。
# 3. 使用 Windows 自带的 Windows Server Backup 工具
     可定时计划每天备份保存到网络共享盘上
# 4. AD 域控数据在 "系统状态" 中，所有只需要备份 "系统状态" 即可
# 5. Windows Server Backup 备份完毕之后，可搭配邮件进行通知备份情况
     因 WSB 并没有邮件告警功能，所以提供 powershell 脚本+计划任务进行告警

### 安装 Windows Server Backup
1. 管理员方式打开 PowerShell,输入如下命令进行安装
2. 安装命令：Install-WindowsFeature -Name Windows-Server-Backup
3. 检查是否安装成功：Get-WindowsFeature Windows-Server-Backup

### 备份
1. 打开 Windows Server Backup
2.  "本地备份"--"备份计划"--"自定义"--"添加项目"--"系统状态"
3. 自行选择 备份时间
4. 备份到共享网络文件夹[自行准备网络共享存储，仅支持 smb]

### 备份成功邮件告警通知
1. 打开 "计划任务程序"--"创建基本任务"--触发器:"当特定事件被记录时(E)"
2. 日志："Microsoft-Windows-Backup/Operational"
3. 源：选择刚才的备份名称
4. 事件 ID：4
   特别说明：成功事件 ID：4；
             失败事件的 ID：5,8,9,17,22,49,50,52,100,517,518,521,527,528,544,545,546,561,564,612
5. "启动程序"--"程序或脚本"--"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
6. ﻿"添加参数":就是选择如下脚本文件: Microsoft_Windows_Backup_Send_Mail.ps1
7. 修改刚才的计划任务的编辑触发条件
8. "自定义"--"编辑事件赛选器"--"按日志"--"Microsoft-Windows-Backup/Operational"
﻿9. "在所有事件 ID"输入：4,5,8,9,17,22,49,50,52,100,517,518,521,527,528,544,545,546,561,564,612
10. "常规"--"不管用户是否登录都要运行"

## 脚本文件：Microsoft_Windows_Backup_Send_Mail.ps1 如下：邮件信息需自行变更即可
function EmailNotification()
﻿{
# 定义需发送通知的邮件地址
$Sender = "xxx@xxx.com"
﻿# 定义发送邮件的帐号与密码
$SMTPAuthUsername = "xxx@xxx.com"
﻿$SMTPAuthPassword = "xxx"
﻿# 定义发送邮件的 SMTP 服务器等信息
$Server = "smtp.xxx.com"
﻿$Port = 25
$SSL = $true
  
# 定义接收通知的邮件地址
$Receipt = "xxx@xxx.com"
﻿# 邮件主题
$Object = $env:computername+": Backup report of "+(Get-Date)
# 邮件内容：获取最近的备份情况
$Content = Get-WBJob -Previous 1 | ConvertTo-Html -As List | Out-String

# 初始化邮件实例
$SMTPclient = new-object System.Net.Mail.SmtpClient($Server,$Port)
# SSL 协议
﻿$SMTPclient.Enablessl = $SSL
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($SMTPAuthUsername, $SMTPAuthPassword)
$Message = new-object System.Net.Mail.MailMessage $Sender, $Receipt, $Object, $Content$Message.IsBodyHtml = $true;
$SMTPclient.Send($Message)
}
EmailNotification
```

### 2.2.1 恢复方法
```
1. 将备份到共享文件夹的数据复制到移动硬盘，并插入到新的裸机器中
2. 裸机器通过DVD载入server2008 R2 ISO（全新机器未装系统），点击下一步后，进入修复计算机，然后选择新插入的移动硬盘进行系统映射恢复
3. 重启服务器进入系统。
```

### 2.2.2 恢复后效果
```
1. 恢复后域用户、计算机、DNS记录都恢复了
2. 组策略名称恢复，内容也恢复了
3. 新建AD域用户时，报错提示"无法创建对象 无法分配相对标识符"
```

### 2.3 解决办法
```
原因是有多台DC记录，而实际只有1台DC在工作，应该删除其它无效DC
通过ntdsutil这个命令，删除了多余的那台DC，重启了一下服务器，真的好了，原来就是这个没有正常卸载的DC在作怪
#### netdom query fsmo	//查询fsmo架构五大主机

1. 命令：
ntdsutil
	metadata cleanup
		connections
			connect to server srv01		//srv01为本机主机名称
			quit
		select operation target
		list sites
		list domains
		list servers for domain in site
		select site 0
		select domain 0 
		select server 1		//选择失效的域服务器进行删除
		list current selections
		q
	remove selected server

2. 命令详细输出：
PS C:\Users\Administrator> ntdsutil
C:\Windows\system32\ntdsutil.exe: metadata cleanup
metadata cleanup: connections
server connections: connect to server srv01
绑定到 srv01 ...
用本登录的用户的凭证连接 srv01。
server connections: quit
metadata cleanup: select operation target
select operation target: list sites
找到 1 站点
0 - CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=test,DC=com
select operation target: select site 0
站点 - CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=test,DC=com
没有当前域
没有当前服务器
当前的命名上下文
select operation target: list domains
找到 1 域
0 - DC=test,DC=com
select operation target: select domain 0
站点 - CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=test,DC=com
域 - DC=test,DC=com
没有当前服务器
当前的命名上下文
select operation target: list servers for domain in site
找到 2 服务器
0 - CN=SRV01,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=test,DC=com
1 - CN=SRV02,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=test,DC=com
select operation target: select server 1
站点 - CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=test,DC=com
域 - DC=test,DC=com
服务器 - CN=SRV02,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=test,DC=com
        DSA 对象 - CN=NTDS Settings,CN=SRV02,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Confi
com
        DNS 主机名称 - SRV02.test.com
        计算机对象 - CN=SRV02,OU=Domain Controllers,DC=test,DC=com
当前的命名上下文
select operation target: q
metadata cleanup: remove selected server
正在从所选服务器传送/获取 FSMO 角色。
正在删除所选服务器中的 FRS 元数据。
正在搜索“CN=SRV02,OU=Domain Controllers,DC=test,DC=com”下的 FRS 成员。
正在删除“CN=SRV02,OU=Domain Controllers,DC=test,DC=com”下的子树。
尝试删除 CN=SRV02,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=test,DC=com 上的
是 "找不到元素。"；
继续清除元数据。
“CN=SRV02,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=test,DC=com”删除了，从

PS C:\Users\Administrator> netdom query fsmo
架构主机               srv01.test.com
域命名主机        srv01.test.com
PDC                         srv01.test.com
RID 池管理器            srv01.test.com
结构主机       srv01.test.com
```

### 注：
```
1. 在PDC上执行 nltest /sc_query:test.com  是无法成功返回的，在其它备份DC上执行是有成功返回的
2. 此方法恢复后经过3次以上重启测试无任何影响，但是新加入的备份DC不能跟之前的DC主机名重名，否则后续整个AD域会报异常无法使用
3. 每个新增加的备份DC名称可以加前缀以示区分，例如：new-srv02, new-srv03, new-srv04等(之前是srv02, srv03, srv04)
```

### 多站点间多域名之间配置及问题
```
# 多站点间配置
1. 首先在1台域控之上更改或创建站点，例如shanghai、beijin（第一台域名在shanghai）
2. 增加两台域控，一台在shanghai，一台在beijing。
3. 在"站点和服务"上对所有域控进行配置
	* 新建子网，根据两个站点区域创建2个或多个子网，例如: 192.168.1.0/24
	* 配置"inter-site transports -> IP -> DEFAULTIPSITELINKG"，配置站点与站点之间的开销及同步时间，开销值越小则此链路优先级越高
	* 当每个站点中有多个域控时，需要配置一个特定的域控为"桥头服务器"，此桥头堡服务器将会首先同步其它站点数据，然后再同步自身数据到站点所在的其它域控。配置路径: "站点名称 -> Servers -> 服务器名称上右键属性 -> 常规选项卡 -> 将'可用于站点间数据传送的传输'协议添加到 '此服务器是下列传输的首选桥头服务器' -> 最后确定"
	* 站点之间的组策略名称条数会同步，但是内容不会很快同步，经过测试一天左右的时间才同步组策略内容(测试机测试)，点"站点与服务"中的立即同步也不同步数据。
	* 点"站点与服务"中的立即同步，会同步域用户信息、DNS记录、组策略条目（不包括组策略内容），这个生效时间取决于网络。
```

### 多站点间登陆时的过程
```
客户端登陆时定位DC的过程，基本上，它是这样的：

1，客户端对_LDAP._TCP.dc._msdcs.domainname进行DNS搜索，以查找DC。
2，DNS服务器返回DC的列表。
3，客户端将LDAP ping发送到DC，以根据客户端IP地址（仅IP地址！DC未知客户端的子网）来询问其所在的站点。
4，DC返回...
a，客户端的站点或与子网最匹配客户端IP的站点（通过将客户端的IP与Netlogon在启动时建立的子网到站点表进行比较来确定）。
b，当前域控制器所在的站点。
c，一个标志（DSClosestFlag = 0或1），用于指示当前DC是否位于最接近客户端的站点中。
5，客户决定是使用当前的DC还是寻找更接近的选项。
a，如果DC位于客户端站点中，或者位于DC所报告的DSClosestFlag所指示的最接近客户端的站点中，则客户端将使用当前DC。
b，如果DSClosestFlag指示当前DC不是最近的DC，则客户端将对以下站点进行特定于站点的DNS查询：_LDAP._TCP。sitename._site.domainname，并使用返回的域控制器。

更加详细的过程如下：

1，Windows计算机发送DNS查询，以要求 _ldap._tcp.dc._msdcs.domainname的DNS解析（示例：_ldap._tcp.dc._msdcs.contoso.com）SRV记录

2，DNS服务器以已注册的DNS记录的列表作为响应（这些记录包含AD域内的域控制器的列表）

3，Windows计算机将查看SRV记录列表， 并根据分配给记录的优先级和权重选择一个。然后它将查询DNS服务器以获取所选域控制器的 IP地址。

4，DNS服务器检查域控制器的A记录并以IP地址响应。

5，Windows计算机与选定的域控制器联系并启动与之的通信

6，启动通信后，选定的域控制器将检查客户端计算机是否属于其Active Directory站点。这是通过将客户端计算机的IP地址与Active Directory配置的站点和子网进行比较来完成的。在这里，将有两种可能的情况：

Windows计算机和所选的域控制器属于同一Active Directory站点： 在这种情况下，将发生以下情况：
所选的域控制器为客户端计算机提供站点名称

Windows计算机缓存其AD站点的名称和使用的域控制器的名称。只要选定的域控制器可用，就将使用它。Windows计算机不再需要在每次与域控制器进行通信时都重新执行本地化过程。

Windows计算机和所选的域控制器不属于同一Active Directory站点： 在这种情况下，将发生以下情况：
1）所选域控制器向客户端计算机提供站点名称，并通知它不是最近的域控制器。

2）Windows计算机发送DNS查询，以查询ldap._tcp.Computer_Site_Name ._sites.dc._msdcs .domain.com的DNS解析 （例如：_ldap._tcp.denver._sites.dc._msdcs.contoso.com）SRV记录

3）DNS服务器以注册的DNS记录列表作为响应（记录包含AD站点内的域控制器列表）

4）Windows计算机将查看SRV记录列表，并根据分配给记录的优先级和权重选择一个。然后它将查询DNS服务器以获取所选域控制器的IP地址。

5）DNS服务器检查域控制器的A记录并以IP地址响应

6）Windows计算机与选定的域控制器联系并启动与之的通信

所以，根据我的理解，如果配置了站点和子网的话，一般情况下客户端计算机都会找本站点内的DC作验证的。这中间会有DNS解析和AD站点子网查询的过程
```



## DNS备份及恢复
```
<#
前提：
  1.该脚本需要模块DnsServer
  2.执行脚本的主机与DNS服务器保持网络连接
  3.执行脚本的用户需要在远程DNS服务器上有相应权限
使用方式：
  利用任务计划程序来调用脚本，参数：-File <脚本文件路径> -ComputerName <远程DNS服务器FQDN> -ErrorAction SilentlyContinue
结果：
  1.脚本执行后，会在远程DNS服务器上的DNS目录（默认为：c:\windows\system32\dns）生成DNS区域的备份文件（AD类型）
  2.每天每个区域只能有一个文件，之后的同名文件会创建失败
恢复DNS区域：
  1.将备份文件复制到DNS服务器上的DNS目录（默认为：c:\windows\system32\dns）
  2.执行命令：dnscmd <远程DNS服务器FQDN> /ZoneAdd <ZoneName> /Primary /file <备份的区域文件名> /load
  3.打开DNS服务器管理器，将相应区域的类型更改为：Active Directory 集成区域，动态类型更改为：安全

  
  # ad域对象需要使用_msdcs.hs.com下的dc/domains/gc/pdc下面的域解析，否则指向新的DNS无法登录域
  # dnscmd srv-pre-dns /zoneadd _msdcs.hs.com /primary /file "Dns - 20230515 - _msdcs.hs.com.bak" /load
  
  # 恢复步骤：可以用notepad++打开"Dns - 20230515 - hs.com.bak"，把192.168.13.207批量替换为192.168.13.208
  # dnscmd srv-pre-dns /zoneadd hs.com /primary /file "Dns - 20230515 - hs.com.bak" /load
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$ComputerName
)

$Prefix = "Dns - " + (Get-Date -Format "yyyyMMdd") + " - " 
$Suffix = ".bak"
#$Zones = Get-DnsServerZone -ComputerName $ComputerName
$Zones = (Get-WmiObject -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Zone -ComputerName $ComputerName).Name

foreach($zone in $Zones){
    #$zonename = $zone.ZoneName
    $zonename = $zone
    if ($zonename -eq "TrustAnchors"){
        #$zonename = "_msdcs.hs.com"
    }
    $filename = $Prefix + $zonename + $Suffix
    #Export-DnsServerZone -FileName $filename -Name $zonename -ComputerName $ComputerName
    dnscmd $ComputerName /ZoneExport $zonename $filename
}




```


