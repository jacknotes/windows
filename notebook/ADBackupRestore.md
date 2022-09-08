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




