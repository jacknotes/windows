#windowsServer2008R2/2012自动登录
打开注册表：regedit，找到[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon]，新建或配置此3项字符串键值：
DefaultUserName   admin
DefaultPassword     password
AutoAdminLogon    1     
--AutoAdminLogon=1此项是在打开运行窗口输入'control userpasswords2'后，是否显示"要使用本机用户必须输入用户名和密码"，
--也可以开启此一项，打开运行窗口输入'control userpasswords2'，取消"要使用本机用户必须输入用户名和密码"并选择你需要登录的用户名，
--如没有则新建用户，然后点确定保存，当你点确定的时候系统需要你输入用户名和密码进行保存。
注：上面自动登录动作使用场景在:图形化界面程序需要在用户登录后运行。但是为确定安全，应在登录后进行锁定屏幕。所以有如下步骤：
在开机启动目录中新建快捷方式值为：%windir%\system32\rundll32.exe user32.dll,LockWorkStation   
工作流程：windows自动登录--> 运行图形化程序-->自动锁屏


#DFS 分布式文件系统
前提：必须工作在域环境上，有DC 
DC01: 192.168.10.110
DFS01: 192.168.10.111
DFS02: 192.168.10.112

DFS01、DFS02:
1. DFS命名空间、DFS复制、删除重复数据功能安装。
2. 新建一个命令空间，承载服务器选择DFS服务器本身，以域名称显示共享
3. 配置对外发布的共享文件夹名称，例如为：dfs ，选择DFS01、DFS02两台服务器的共享目录，此目录名称，存储大小最好一样。
4. 第三步确定后会提示你建立复制组，用于DFS01、DFS02两台服务器共享文件夹同步文件，网络拓扑为交错模式。
5. 在建立好的命名空间服务器上添加另一台命名空间服务器，此服务器用于负载均衡高可用（DFS命名空间安装在哪台服务器上，那么这么服务器就不能关机，否则无法通过DFS访问后端共享文件夹），
当其中一台服务器故障掉时，DFS服务不会中断。
6. 在命名空间名称上右键开启“客户端故障回复到首先目标”，此功能用于在命名空间服务器回归到正常状态时，客户端会连接首先服务器（此服务器在建立复制组时会提示选择）
7. 也可按需对复制组进行计划复制，默认复制是全天候复制。


#wsus client sync command 
wuauclt /resetauthorization /detectnow
wuauclt /detectnow
wuauclt /reportnow

windows server2012无法向WSUS报告状态：
1. 手动下载并安装更新https://www.catalog.update.microsoft.com/Search.aspx?q=KB4054519
2. 在你的WSUS上，打开IIS Application Pool，进行以下修改，然后重启IIS服务
Queue Length: 25000 from 10000
Limit Interval (minutes): 15 from 5





#Dell服务器IDRAC默认帐户信息
<pre>
Dell服务器默认用户信息如下：
IP: 192.168.0.120
USER: root
PASSWORD: caivin

#DELL RAID重建过程疏理
1. 用6块盘组建的RAID5(ID为0到5，ID为6的是全局热备盘)：
0: 600G 15K 3.5寸 希捷 
1: 600G 15K 3.5寸 希捷
2: 600G 15K 3.5寸 希捷
3: 600G 15K 3.5寸 希捷
4: 600G 15K 3.5寸 希捷
5: 600G 15K 3.5寸 希捷
6: 600G 15K 3.5寸 希捷	全局热备盘
2. ID为0的磁盘故障了，此时全局热备盘ID为6的起作用了，进行自动重建，此时RAID5的磁盘包括ID为1到6的磁盘，ID为0的磁盘是故障盘位，不属于RAID5磁盘组
3. 倒霉的事情发生了，在ID为6的磁盘进行重建到94%时，ID为5的硬盘故障导致整个RAID恢复失败，此时整个虚拟机系统死机而不能使用，亦不能正常关机，此时只能按开关机键强行关机
4. 在关机后并正常开机后进入RAID管理界面时卡住很久才进来，此时看到ID为5的磁盘状态为faild，RAID为6的磁盘offline，此时整个虚拟磁盘组为红色表示故障不可用，查看物理磁盘状态时，ID为6的磁盘为offline，此时操作这块盘为online，
在到虚拟磁盘管理界面中看到虚拟磁盘为黄色(为白色表示状态最佳)，表示磁盘组可用，但是非常紧急随时有可能故障。
5. 此时心里非常不好受，冒着试一试的状态启动服务器到系统，没想到可以进入系统，此时是不幸中的万幸了，赶紧一台一台虚拟机先开机备份重要数据，直至全部虚拟机备份完成。
6. 备份完成后想打算把6块盘全部格式化后重新配置RAID，但是磁盘都在创建为RAID(创建一块盘为RAID0进行测试)后不到5分钟都闪黄绿灯(上面黄灯闪，下面闪绿灯){此种状态是预测性故障，在RAID管理界面中也都是online状态，其实没有故障，但是不确定哪天就会坏了，所以全部报废}，经过RAID卡固件升级和IDRAC升级依然这样，只有不创建为RAID时磁盘才正常，猜测：
	1. 不把磁盘配置成RAID时不会往磁盘写信息，
	2. 如果做成RAID，那么会定时写校验数据到磁盘中进行核验，所以在一写校验数据时就会报错。

</pre>


>>>>>>> 703b2e1570b15df507f165c771bceafd92c60d7c

#Powershell Manual
<pre>
read-host "input:" | get-service
Get-Content f:\services.txt | get-service
Import-Csv f:\services.csv | get-service
--过滤
where-object status -eq running 
where-object {$_.status -eq "running"}

--输出
write-host "test"
Get-ADUser -filter {enabled -eq "true"} -properties * | select name,samaccountname | export-csv f:\users.csv
Get-ADUser -filter {enabled -eq "true"} -properties * | select name,samaccountname | Out-File f:\users.txt

--powershell node
--custom user
get-aduser -filter {enabled -eq "true"} -properties * | where-object samaccountname -eq "0799" | select-object displayname,samaccountname,PasswordExpired,PasswordNeverExpires,AccountLockoutTime,Created,PasswordLastSet,@{n="Lastlogon";e={[datetime]::FromFileTime($_.lastlogon)}} | Format-table

--password expired
get-aduser -filter {enabled -eq "true"} -properties * | select-object displayname,samaccountname,Created,LastLogonDate,PasswordExpired,PasswordNeverExpires,PasswordLastSet,AccountLockoutTime,CanonicalName | where-object PasswordExpired -eq "true" | format-table

--disable users
get-aduser -filter {enabled -eq "false"} -properties * | select-object displayname,samaccountname,Created,LastLogonDate,PasswordExpired,PasswordNeverExpires,PasswordLastSet,AccountLockoutTime,CanonicalName | format-table

--rpc 
--远程执行命令
wmic /node:192.168.1.158 /user:pt007 /password:admin123  process call create "cmd.exe /c ipconfig>d:\result.log
--远程改计算机名
wmic /node:192.168.1.158 /user:pt007 /password:admin123 process call create 'cmd.exe /c wmic computersystem where caption="WIN-DF8S0D8K72Q" call rename "ops-test002"'
--远程开启远程桌面----0(关)---1(开)
wmic rdtoggle where servername='ops-test002' call setallowtsconnections 1
wmic /node:192.168.1.158 /user:pt007 /password:admin123 process call create 'cmd.exe /c wmic rdtoggle where servername="ops-test002" call setallowtsconnections 1'



--20210105
----powershell的管理单元(已经很少使用)和模块
Get-PSProvider
Get-PSDrive
------powerhshell的管理单元
Get-PSSnapin
Get-PSSnapin -registered
Add-PSSnapin SqlServerCmdletSnapin100   ----成功加入sqlserver命令包
Get-Command *sqlcmd*   ----可以直接使用sqlserver命令
Add-PSSnapin SqlServerProviderSnapin100  ----成功加入提供信息包
ls sqlserver:    ----可以直接浏览sqlserver驱动器
----object
Get-Member
import-csv users.csv | select-object -property *,@{name="samaccountname";expression="0799"},@{n="name";e="jack"},@{label="dept";expression="$_.dept"}
Get-ADComputer -Filter * -SearchBase "ou=domain controllers,dc=hs,dc=com" | select -expandProperty name  ------expandProperty会返回指定属性的值，很常用
get-hotfix | ft -autosize
Get-Service | Sort-Object Status | Format-Table -GroupBy status
Get-Service | Format-Table name,status,displayname -autosize -wrap   ---自动换行
Get-Service | Format-List ----是gm的备用方案
Get-Process | Format-wide name -column 4
Get-Service | Format-Table @{name="servicename";expression={$_.name}},status,displayname
Get-Process| Format-Table name,@{n='VM(MB)';e={$_.VM / 1MB -as [int]}} -autosize
----对比操作符
-eq -ne -ge -le -gt -lt -ceq -cne -cgt -clt -cge -cle -not -like -clike -cnotlike -match -cmatch -cnotmach 
=    <>     <=    >=    >   <  
examples:
Get-NetAdapter | where {$_.Virtual -eq $false} | format-table name,ifIndex,status,MacAddress,LinkSpeed,virtual
Get-NetAdapter | where {-not $_.Virtual -eq $false} | format-table name,ifIndex,status,MacAddress,LinkSpeed,virtual
Get-Service | where {($_.StartType -eq "automatic") -and ($_.status -eq "stopped")} | Format-Table name,DependentServices,servicesdependedon,ServiceType,StartType,Status
----scheduledtask
Register-ScheduledTask -taskname "get_print_job" -description "show the gonggong_printer queue at 3am daily" -action (New-ScheduledTaskAction -execute "get-printjob -printer 'fax'") -Trigger (New-ScheduledTaskTrigger -daily -at '3:00 am')
----远程处理
 Invoke-Command -ComputerName localhost,ops-test002 -ScriptBlock {Get-EventLog Security -newest 20 | Where-Object {$_.EventID -eq 1212}}
----windwos管理规范
WMIexplore、CIMexplore
Get-WmiObject -list *Win32_Network* ----获取所有类别
PowershellV3.0以后有WMI cmdlet和CIM cmdlet工具使用、如：Get-WmiObject、Invoke-WmiMethod、Get-CimInstance、Invoke-CimMethod
gwmi -Class win32_desktop -filter "name='HS-UA-TSJ-0132\\administrator'"
Get-CimInstance -ClassName win32_logicaldisk
Invoke-Command -Command {Get-CimInstance -ClassName Win32_process} -ComputerName ops-test002 -Credential ops-test-002\adimistrator
----多任务后台job
Start-Job -ScriptBlock {dir c:\}    ----本地后台job
get-job  ----当HasMoreData变为False时，则表示输出结果没有被缓存
Receive-Job 5 -keep  ----获取后台job作业的结果，并不从内存中删除(-keep)
Get-WmiObject -Class win32_operatingsystem -ComputerName localhost  -AsJob  ----WMI作业
Invoke-Command -ScriptBlock {get-process} -ComputerName (echo wsus02) -AsJob -JobName wsus02job --invoke-command JOB
Receive-Job -name job9 | Sort-Object pscomputername | format-table -groupby pscomputername  --通过invoke-command创建会自己添加PSComputerName属性
Get-Job -id 7 | Format-List * ----会看到子作业ChildJobs，name为job8
Get-Job -Name job8 | Format-List *  ----查看子job8
Get-Job -Name job7 | Select-Object -expandproperty childjobs ----返回子job对象 
Get-Job | where {-not $_.HasMoreData} | Remove-Job  ----移除没有缓存的job
Get-Job | where {$_.state -eq "running"} | Stop-Job  ----停止正在支持的job
Invoke-Command -Command { nothing } -ComputerName notonline -AsJob -JobName ThisWillFail  ----执行失败的job
Get-Job -name ThisWillFail | Select-Object -ExpandProperty childjobs  ----获取子jobID
Receive-Job -id 16
Register-ScheduledJob -Name DailyProcList -ScriptBlock {Get-Process} -Trigger (New-JobTrigger -Daily -At 2am) -ScheduledJobOption (New-ScheduledJobOption -WakeToRun -RunElevated)  ----创建一个调度作业，允许唤醒运行，运行在高级特权下
Get-ScheduledJob  ----获取刚刚创建的调度作业，不像常规的job，调度作业是缓存在硬盘中，所以获取结果后，结果不会被删除，当你使用receive-job命令时结果将一起被删除，可以通过Register-ScheduledJob 的-MaxResultCount参数来控制存放结果数量。
----同时处理多个对象
Get-Service -name bits | Start-Service -passthru  ----显示结果
Get-WmiObject -class win32_networkadapterconfiguration -Filter "description like 'intel%'"
Get-WmiObject -class win32_networkadapterconfiguration -Filter "description like 'intel%'" | gm
Get-WmiObject -class win32_networkadapterconfiguration -Filter "description like 'intel%'" | Invoke-WmiMethod -name EnableDHCP -whatif
WMI需要RPC，老的电脑兼容性好。CIM需要WS-MAN，只需要PSRemoting，兼容性差
Get-WmiObject win32_service -Filter "name = 'BITS'" | Invoke-WmiMethod -name change -ArgumentList $null,$null,$null,$null,$null,$null,$null,"P@ssw0rd" ----Invoke-WmiMethod与method方法不兼容，用下面枚举方法
Get-WmiObject win32_service -Filter "name = 'BITS'" | ForEach-Object -process {$_.change($null,$null,$null,$null,$null,$null,$null,"P@ssw0rd")} ----忽略参数请$null忽略，后面参数忽略也可用$null或者不写进行忽略 
gwmi win32_service -Fi "name = 'BITS'" | % {$_.change($null,$null,$null,$null,$null,$null,$null,"P@ssw0rd")} ----简化版
总结：即使是PowerShell v3，对于某些任务，WMI依然是一种值得的使用方式
----安全警报
脚本执行策略
remotesigned
------变量
`n  --换行符
`t   --tab
------优先执行符号
()   $()
------类型强制转换
int,single,double,string,char,xml,adsi  ----类型
[int]$num=host-raad "Enter a Number"
----输入和输出 
输入：Read-Host
------powershell在任何时候运行将会弹出输出框方法：
输入：
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')  ----1.载入类型方法
$computername=[Microsoft.VisualBasic.Interaction]::InputBox("Enter a computer name ","computer name","localhost") ----2.输入提示信息、弹框标签、默认值
输出：Write-Host "COLORFUL!" -ForegroundColor Yello -BackgroundColor Magenta  ----此命令不经过管道输出，直接输出在界面中
write-output "hello"  --> out-default -->out-host  -->"hello"  ----write-output不会直接输出在界面上，而是先输向管道中，最后输出在界面中，
Write-Output "Hello World!" | Where-Object {$_.length -ge 20}  --Where-Object可用`?代替
以下输出更像Write-Host命令一样直接输出到界面：
write-warning(默认$WarningPreference=Continue)
write-verbose(默认$VerbosePreference=Continue)
write-debug(默认$DebugPreference=Continue)
write-error(默认$ErrorActionPreference=Continue)
----轻松实现远程控制
$iis_servers = new-pssession -ComputerName web01,web02,web03
$iis_servers | Remove-PSSession
get-PSSession | Remove-PSSession
$server01,$server02 = New-PSSession -ComputerName localhost,wsus02-xen01 --or
$server_session = New-PSSession -ComputerName localhost,wsus02-xen01
Enter-PSSession -Session $server_session[0]
Enter-PSSession -Session ($server_session | where-object {$_.computername -eq "localhost"})
Enter-PSSession -Session (Get-PSSession -ComputerName localhost)
Get-PSSession -ComputerName localhost | Enter-PSSession
Invoke-Command -Command {Get-WmiObject -Class win32_process} -Session $server_session  --invoke-command是并行执行，默认最大一次执行32台计算机，而wmi是串行执行的。
------隐示远程控制
$session0799=New-PSSession -ComputerName hs-ua-tsj-0132
Set-ExecutionPolicy remotesigned
Import-PSSession -Session $sessiontest -Module ActiveDirectory -Prefix tmp
$creden=Get-Credential  hs\test
Get-tmpADUser -Filter "samaccountname -eq 'admin'" -Credential $creden  --必须带认证信息才能输出结果
注：无论是import-pssession还是import-module，导入的命令都是在目标机器上运行的
------psremoting会话参数选项
\WSMan::localhost\Shell  在此路径下设置：
超时时间(IdleTimeout)
一次最在管理计算机数(MaxConcurrentUsers)
指定会话可以打开的最长时间(MaxShellRunTime)
指定任何用户可以在同一系统上远程打开的并发shell的最大数目(MaxShellsPerUser)
----powershell批处理
------获取磁盘大小信息
---
<#
CreateDateTime:2020-01-10
Author: JackLi
Descripton: get computer logical disk size
#>
[cmdletbinding()]
param(
    #下面三行只可以变成一行书写，但是难以阅读
    [Parameter(Mandatory=$True,HelpMessage="Enter a Computer Name To Query")]
    [Alias('hostname')]
    [String]$COMPUTERNAME,

    [ValidateSet(2,3)]
    [int]$DRIVETYPE=3
)
Get-WmiObject -Class win32_logicaldisk `
-ComputerName $COMPUTERNAME -Filter "DRIVETYPE=$DRIVETYPE" | 
Sort-Object -Property deviceid | 
Select-Object -property deviceid,@{name="FreeSpace(MB)";expression={$_.freespace/1MB -as [int]}},
@{n="Size(MB)";e={$_.size/1MB -as [int]}},
@{label="Free(%)";expression={$_.freespace/$_.size*100 -as [int]}} 
Write-Verbose "Finished Running Shell Command"
---
Get-WmiObject -Class Win32_NetworkAdapter -ComputerName localhost | where {$_.PhysicalAdapter } | select -Property *
----高级远程管理特性
PS WSMan:\localhost\Shell>Get-PSSessionConfiguration
microsoft.powershell、 microsoft.powershell.workflow、 microsoft.powershell32、microsoft.windows.servermanagerworkflows
默认端点是microsoft.powershell，当你考虑兼容性目的，可以使用备用端点：
PS WSMan:\localhost\Shell> Enter-PSSession -ComputerName localhost -ConfigurationName "microsoft.powershell32"
------创建我自定义端点
------启用多跳远程
--------将homsom-server24替换为希望将身份委托到的计算机名称
Enable-WSManCredSSP -Role client -DelegateComputer homsom-server24  
或者
Enable-WSManCredSSP -Role client -DelegateComputer *.hs.com
Enter-PSSession -Session (New-PSSession -ComputerName homsom-server24)
--------开启目标计算机的CredSSP功能
Enable-WSManCredSSP -Role server -force
远程执行第二台以外机器的命令，如访问其它计算机共享 
$session=New-PSSession -ComputerName homsom-server24 -Credential hs\opsadmin -Authentication credssp
Invoke-Command -Session $session -ScriptBlock {Copy-Item \\192.168.10.187\611\cw.txt c:\} 
--------开启、查看 、关闭SSP
Enable-WSManCredSSP -Role Client  -DelegateComputer wsus02-xen01 -force
Get-WSManCredSSP
Disable-WSManCredSSP client
------通过受信任的主机实现双向身份验证
通过组策略或本地策略来设置：计算机配置--管理模板--windows组件--windows远程管理--winrm客户端--双机受信任的主机--启用并添加信任的主机名称--gpudate /force刷新组策略
----正则表达式
\w(数字，字母，下划线) \W(与\w相反)  \d(0-9的数字)  \D(与\d相反)  \s(tab,空格,回车符) \S(与\s相反)  .(单个字符)  *(重复0到任意个前面字符)  + \  []  ^ $
通过-Match使用正则表达式
PS C:\> "jack" -match "ja[abcdefg]k"
True
通过select-string使用正则表达式
"(WindowsNT+6.2;+WOW64;+tv:11.0)+Gecko" -match "6\.2;[\w\W]+\+Gecko"
 Get-ChildItem *.txt | select-string -Pattern "6\.2;[\w\W]+\+Gecko"
Get-EventLog -LogName Security | where {$_.EventID -eq 4624} | Select-Object -ExpandProperty message | Select-String -Pattern "WIN[\W\w]+TM[234][0-9]\$" --这样输出是个字符串
或者 
Get-EventLog -LogName Security | where {$_.EventID -eq 4624 -and $_.message -match "WIN[\W\w]+TM[234][0-9]\$"} --这样输出还是个对象
正则表达式可与switch结构体进行判断是否符合、与其它高级cmdlet进行结合匹配，可将匹配的值放入一个集合
----运算符
-as -is -replace -join -split -in -contains -like -match
1000/3 -as [int]   ----转换类型有int,single,double,string,xml,datetime等
1000/3 -is [int]  ----返回对象是否是指定类型，是则返回true,否则返回false
"1000/3" -is [string]
"192.168.13.100" -replace "192","172"  ----将192替换成172
$array='one','two','three','four','five'
$array -join '|'  ----设定分隔符为管道 
one|two|three|four|five  
PS C:\> gc .\test.txt  --文件是tab键分隔的
server01        server02        server03        server04
PS C:\> $aa=(gc .\test.txt) -split "`t"
PS C:\> $aa
server01
server02
server03
server04
PS C:\> gc .\test.txt  --文件以空格分隔 
server01 server02 server03 server04
PS C:\> $aa=(gc .\test.txt) -split " "  --gc is get-content
PS C:\> $aa
server01
server02
server03
server04
PS C:\> "this" -like "*hi*"
True
PS C:\> $str="one","two","three"
PS C:\> $str -contains "one"
True
PS C:\> $str -contains "four"
False
PS C:\> "three" -in $str
True
"Server-02" | gm  ----split() join() replace()跟前面的运行符一样
PS C:\> "Server-02".IndexOf('-')
6
PS C:\> "Server-02".ToUpper()
SERVER-02
PS C:\> "Server-02".ToLower()
server-02
PS C:\> $username="  my name is jack "
PS C:\> $username.Trim()
my name is jack
PS C:\> $username.TrimStart()
my name is jack
PS C:\> $username.TrimEnd()
  my name is jack
------日期处理
get-date | gm
PS C:\> Get-Date
2021年1月10日 17:41:38
PS C:\> (Get-Date).Month
1PS C:\> (Get-Date).AddDays(-90)
2020年10月12日 17:42:35
PS C:\> (Get-Date).AddDays(-90).ToShortDateString()
2020/10/12
PS C:\> (get-date).ToString()
2021/1/10 17:45:11
---------处理wmi日期
PS C:\> Get-WmiObject win32_operatingsystem  | select-object lastbootuptime
lastbootuptime
--------------
20210105174401.500000+480
PS C:\> $os=Get-WmiObject win32_operatingsystem
PS C:\> $os.ConvertToDateTime($os.LastBootUpTime).tostring()
2021/1/5 17:44:01
--------设置参数默认值 
$PSDefaultParameterValues  --默认值都在这个变量中
PS C:\> $credential=Get-Credential -UserName hs\0799 -Message "enter admin credential"  --先新增一个凭据变量
PS C:\> $PSDefaultParameterValues.add('*:credential',$credential) --增加默认参数credential的值$credential，可用于所有(*)命令中的credential参数
$psdefaultparametervalues.add('invoke-command:credential',{Get-Credential -UserName hs\0799 -Message "enter admin credential"})
PS C:\> $PSDefaultParameterValues["disabled"]=$true  --关闭默认参数
PS C:\> $PSDefaultParameterValues.Remove("invoke-command:credential")  --移除一个参数，作用域会各不相同
----脚本块
PS C:\> $block={    --创建一个脚本块
>> Get-Process | Sort-Object -Property vm -Descending | Select-Object -First 10
>> }
PS C:\> $block
Get-Process | Sort-Object -Property vm -Descending | Select-Object -First 10
PS C:\> & $block   --执行一个脚本块
Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
-------  ------    -----      -----     ------     --  -- -----------
   1290      96   120624      76088      43.56   9236   1 SearchUI
    109      10     3892       7500       0.00 115172   0 pacjsworker
    425      23    62512      54348      43.20  44912   1 chrome
    347      22    53044      47236       2.83  92956   1 chrome
    384      33   111280      76408     324.88  40552   1 chrome
    415      25    66968      69364       6.27 107100   1 chrome
    379      26    76144      73748     135.48  46356   1 chrome
    307      24   142296      39880     254.28  11176   1 chrome
    338      23    50452      16192       8.20  43836   1 chrome
    376      24    72980      70572     103.41  67828   1 chrome
----符号
%号是foreach-object的别名
?是where-object的别名,`?

----文本处理
example1:
type .\users.txt
李一 93
王二 83
王三 93
李四 60
王五 75
马六 61
孙七 75
刘八 75

$scoreTables=@{}
$stus=Get-Content .\users.txt |
foreach{
$stu=$_ -split " "
if($scoreTables.ContainsKey($stu[1]))
{
}
else{
$scoreTables[$stu[1]]=1
}
@{Score=$stu[1];Name=$stu[0]}
$stus | Where-Object {$scoreTables[$_.score] -gt 1} | foreach {"{0} {1}" -f $_.name,$_.score}
李一 93
王三 93
王五 75
孙七 75
刘八 75

example2:
Get-Content .\users.txt | ForEach-Object{
[pscustomobject]@{
name = $_.split()[0]
value = $_.split()[1]
}
} | Group-Object value | Where-Object {$_.count -gt 1} |
foreach {$_.group | ForEach-Object {"{0} {1}" -f $_.name,$_.value}}
李一 93
王三 93
王五 75
孙七 75
刘八 75

example3:
PS D:\deploy\iisbackup> $rawTxt='"data1":111,"data2":22,"data3":3,"data4":4444444'
PS D:\deploy\iisbackup> $rawTxt -split ',' | ForEach-Object { $tmp=$_ -split ':';"{0}={1}" -f $tmp[0].Substring(1,$tmp[0].Length-2),$tmp[1]} | ConvertFrom-StringData
Name                           Value
----                           -----
data1                          111
data2                          22
data3                          3
data4                          4444444

example4:
PS D:\deploy\iisbackup> Import-Csv .\url.csv -Header "link"
link
----
https://www.pstips.net/diff-with-currentculture-and-currentuiculture.html
https://www.pstips.net/tag/powershell-v3
https://www.pstips.net/powershell-download-files.html
http://www.notelee.com/cs0012-the-type-system-object-is-defined-in-an-assembly-that-is-not-referenced.html
http://www.notelee.com/scom-create-wmi-perf-rule.html
http://www.lonsoon.com/2013/04/94.html
http://www.lonsoon.com/2013/05/101.html

PS D:\deploy\iisbackup> Import-Csv .\url.csv -Header "link" | ForEach-Object {([uri]($_.link)).host}
www.pstips.net
www.pstips.net
www.pstips.net
www.notelee.com
www.notelee.com
www.lonsoon.com
www.lonsoon.com

custom_example:
PS D:\deploy\iisbackup\backup\iisbackup20210111> cat .\applicationHost.config | Where-Object {$_ -match "physicalPath"} | ForEach-Object {$tmp=$_ -split "=";$tmp2=$tmp[2] | ForEach-Object {$_ -split '"'};$tmp2[1]}
D:\ProductWeb\commonservice.hs.com
D:\ProductWeb\cupid.homsom.com
D:\ProductWeb\customerreposwebapi.hs.com
$webdir=cat .\applicationHost.config | Where-Object {$_ -match "physicalPath"} | ForEach-Object {$tmp=$_ -split "=";$tmp2=$tmp[2] | ForEach-Object {$_ -split '"'};$tmp2[1] -replace "D:\\","\\192.168.13.228\"}
$webdir2=cat d:\deploy\iisbackup\backup\iisbackup20210111\applicationHost.config | Where-Object {$_ -match "physicalPath"} | ForEach-Object {$tmp=$_ -split "=";$tmp2=$tmp[2] | ForEach-Object {$_ -split '"'};$tmp2[1]}

脚本：
xcopy.ps1:
-------
[cmdletbinding()]
param(
    [Parameter(Mandatory=$True,HelpMessage="Input Source Directory or file")]
    [Alias('SDIR')]
    [string]$SUNC=$(throw "Source Directory or file is NULL"),

    [Parameter(Mandatory=$True,HelpMessage="Input Destination Directory")]
    [Alias('DDIR')]
    [string]$DUNC=$(throw "Destination Directory is NULL"),

    [Parameter(Mandatory=$True,HelpMessage="Input Copy Type (dir | file)")]
    [Alias('TYPE')]
    [string]$CTYPE=$(throw "Type (dir | file) is NULL")
)
$LOGDIR="$DUNC\log"
$LOGFILE="$LOGDIR\log"
$DATEYEAR=(get-date).Year
$DATEMONTH=(get-date).Month
$DATEDAY=(get-date).Day
$DATE="$DATEYEAR"+"$DATEMONTH"+"$DATEDAY"

if((Get-Item $SUNC) -is [IO.DIRECTORYInfo]){$DIRNAME=$SUNC}
elseif((Get-Item $SUNC) -is [IO.FileInfo]){$DIRNAME=Split-Path $SUNC}

if((Get-Item $SUNC) -is [IO.DIRECTORYInfo]){$BASENAME="*"}
elseif((Get-Item $SUNC) -is [IO.FileInfo]){$BASENAME=Split-Path $SUNC -Leaf -Resolve}

#test path is exists.
if (-not (Test-Path $SUNC)){
    echo "source $nc path not exists"
    exit 1
}
if (!(Test-Path $DUNC)){
    echo "destination $nc path not exists"
    exit 1
}

#create log dir
New-Item -ItemType "directory" -Path "$LOGDIR" -Force > $null

#echo datetime to logfile
echo "BEGIN" >> "$LOGFILE$DATE.txt"
(Get-Date).ToString() >> "$LOGFILE$DATE.txt"

if($CTYPE -eq "dir" -and (Get-Item $SUNC) -is [IO.DIRECTORYInfo]){
	xcopy $SUNC $DUNC /h/s/d/e/y/k/f | Out-File -Append "$LOGFILE$DATE.txt"
	if ($?){
        echo "RESULT: Copy $DIRNAME\* To $DUNC Successful" ;
        echo "RESULT: Copy $DIRNAME\* To $DUNC Successful" >> "$LOGFILE$DATE.txt"
    }else{
        echo "RESULT: Copy $DIRNAME\* To $DUNC Failure";
        echo "RESULT: Copy $DIRNAME\* To $DUNC Failure" >> "$LOGFILE$DATE.txt"
    }
}elseif($CTYPE -eq "file" -and (Get-Item $SUNC) -is [IO.FileInfo]){
	xcopy $SUNC $DUNC /h/d/y/k/f | Out-File -Append "$LOGFILE$DATE.txt"
	if ($?){
        echo "RESULT: Copy $DIRNAME\\$BASENAME To $DUNC Successful" ;
        echo "RESULT: Copy $DIRNAME\\$BASENAME To $DUNC Successful" >> "$LOGFILE$DATE.txt"
    }else{
        echo "RESULT: Copy $DIRNAME\\$BASENAME To $DUNC Failure";
        echo "RESULT: Copy $DIRNAME\\$BASENAME To $DUNC Failure" >> "$LOGFILE$DATE.txt"
    }
}else {
    echo "RESULT: source file and type is no match";
    echo "RESULT: source file and type is no match" >> "$LOGFILE$DATE.txt";
    echo "END" >> "$LOGFILE$DATE.txt";
    echo "" >> "$LOGFILE$DATE.txt";exit 1
}

(Get-Date).ToString() >> "$LOGFILE$DATE.txt"
echo "END" >> "$LOGFILE$DATE.txt"
echo "" >> "$LOGFILE$DATE.txt"
-------
fromServerXcopy.ps1:
-------
$BACKUP_CONFIGDIR="D:\powershell\iisbackup-192.168.13.204-20210112\"
$REMOTE_IPADDR="192.168.13.204"
$CTYPE="dir"

$REMOTE_SHARE_WEBDIR=cat $BACKUP_CONFIGDIR\applicationHost.config | 
    Where-Object {$_ -match "physicalPath"} | 
    ForEach-Object {$tmp=$_ -split "=";$tmp2=$tmp[2] | 
    ForEach-Object {$_ -split '"'};$tmp2[1] -replace "D:\\","\\$REMOTE_IPADDR\"}

$REMOTE_WEBDIR=cat $BACKUP_CONFIGDIR\applicationHost.config |
    Where-Object {$_ -match "physicalPath"} | 
    ForEach-Object {$tmp=$_ -split "=";$tmp2=$tmp[2] |
    ForEach-Object {$_ -split '"'};$tmp2[1]}

$REMOTE_SOURCE_DIR=$REMOTE_SHARE_WEBDIR | foreach-object {"\\"+($_ -split "\\")[2]+"\"+($_ -split "\\")[3]} | Sort-Object chars -Unique
$LOCAL_DST_DIR=$REMOTE_WEBDIR | foreach-object {($_ -split "\\")[0]+"\"+($_ -split "\\")[1]} | Sort-Object chars -Unique

New-Item -ItemType "directory" -Path "$LOCAL_DST_DIR" -Force > $null
if($?){
    echo "start from $REMOTE_SOURCE_DIR copy to $LOCAL_DST_DIR "
    .\xcopy.ps1 -SUNC $REMOTE_SOURCE_DIR -DUNC $LOCAL_DST_DIR -CTYPE $CTYPE
    if($?){echo "copy successful,copy end."}
}
-------




-------
需求汇总：
需求1：将时间戳转换为标准时间格式
[DateTime]::FromFileTime(132547549886938765)
2021年1月10日 20:23:08


#获取安装软件信息
$client=Get-Content .\hostname.txt
foreach($i in $client){Get-WmiObject -query "select * from win32_product where name like 'eTerm%'" -ComputerName $i | select-object __server,name,version| format-table >> \\172.168.2.219\share\tmp\eterm.txt}

--通过调用命令使用ciminstance代码块执行安装包查看
Invoke-Command  -computername ( Get-Content  E:\1234.txt | where {$_.length -ne 0}) -ErrorAction Ignore -ScriptBlock {Get-CimInstance -ClassName win32_product  | Where-Object name -eq "企业QQ" | select-object name,version,PSComputerName} | format-table

--通过格式化方式建立名称
$session=130..132 | foreach { "HS-UA-TSJ-{0:D4}" -F $PSItem } | New-PSSession -ThrottleLimit 50 -ErrorAction Ignore
Invoke-Command -Session $Session -ScriptBlock {Get-CimInstance -ClassName win32_product  | Where-Object name -eq "企业QQ" | select-object name,version,PSComputerName} | format-table


Get-WmiObject -class win32_product -Filter "name like 'eTerm%'"
Get-WmiObject -query "select * from win32_product where name like 'eTerm%'" | select-object __server,name,version | format-table | Export-Csv -Append f:\test.csv

$client=Get-Content .\hostname.txt
foreach($i in $client){Get-WmiObject -query "select * from win32_product where name like 'eTerm%'" -ComputerName $i | select-object __server,name,version| format-table >> \\172.168.2.219\share\tmp\eterm.txt}

防火墙：
netsh advfirewall show domainprofile
netsh advfirewall set allprofiles state off


-- 移动当前目录下的所有文件，移除后并删除当前目录：
PS D:\BaiduNetdiskDownload\周杰伦歌曲\123> $dirname=Get-ChildItem -dir | select name
PS D:\BaiduNetdiskDownload\周杰伦歌曲\123>  for($i=0;$i -le $dirname.length-1; $i++){ls -path $dirname[$i].name -Recurse | mv -Destination "D:\BaiduNetdiskDownload\周杰伦歌曲\123" -Force -ErrorAction Ignore;Remove-Item -Force -Recurse -ErrorAction Ignore $dirname[$i].name}

command:
$dirname=Get-ChildItem -dir | select name
for($i=0;$i -le $dirname.length-1; $i++){ls -path $dirname[$i].name -Recurse | mv -Destination "D:\BaiduNetdiskDownload\周杰伦歌曲\123" -Force -ErrorAction Ignore;Remove-Item -Force -Recurse -ErrorAction Ignore $dirname[$i].name}



--202109221453
-- 锁定屏幕
rundll32.exe user32.dll,LockWorkStation

------powershell5.0及以上
--在 Windows Server 上，以管理员身份将功能名称与 Install-WindowsFeature cmdlet 一起使用。 例如
Install-WindowsFeature -Name ActiveDirectory
--在 Windows 10 上，Windows 管理模块作为 Windows 可选功能或 Windows 功能提供 。 必须使用“以管理员身份运行”从提升的会话运行以下命令 。
对于 Windows 可选功能
Get-WindowsOptionalFeature –Online
若要安装功能，请执行以下操作：
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Management-PowerShell
--对于 Windows 功能
若要获取 Windows 功能的列表，请运行以下命令：
Get-WindowsCapability -online
请注意，功能包的名称以 ~~~~0.0.1.0 结尾。 必须使用全名才能安装功能：
Add-WindowsCapability -Online -Name Rsat.ServerManager.Tools~~~~0.0.1.0



--202109230910
--------------
# DNS备份脚本简介
## 脚本基本信息：
1. 脚本类型：Powershell
2. 脚本名称：backupDNS.ps1
3. 需要模块：`DnsServer`

## 脚本使用方式：
使用任务计划程序调用该脚本，之后会在DNS服务器上的DNS目录下生成AD区域的备份文件。
计划任务-操作选择`启动程序`：`C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`
参数选择：`-File "<脚本文件路径>" -ComputerName <DNS服务器名称> -ErrorAction SilentlyContinue`

# 恢复DNS区域
1. 将DNS区域备份文件复制到DNS服务器（homsom-dc-03.hs.com）上的DNS文件夹下（默认：`c:\windows\system32\dns`）
2. 运行命令：`dnscmd <远程DNS服务器FQDN，如果在DNS服务器上运行，则可省略> /ZoneAdd <ZoneName> /Primary /file <备份的区域文件名> /load`
3. 打开DNS服务器管理器，将相应区域的类型更改为：Active Directory 集成区域，动态类型更改为：安全

# 附件：脚本
```powershell
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$ComputerName
)

$Prefix = "Dns - " + (Get-Date -Format "yyyyMMdd") + " - " 
$Suffix = ".bak"
$Zones = Get-DnsServerZone -ComputerName $ComputerName

foreach($zone in $Zones){
    $zonename = $zone.ZoneName
    if ($zonename -eq "TrustAnchors"){
        $zonename = "_msdcs.hs.com"
    }
    $filename = $Prefix + $zonename + $Suffix
    Export-DnsServerZone -FileName $filename -Name $zonename -ComputerName $ComputerName
}
```
# Example（脚本使用）
1. 在操作主机上安装DNS server角色（OS版本不低于server2012）
2. 将脚本文件复制到`c:\Scripts`
3. 新建计划任务：
   名称：BackupDNS
   运行任务的账户：hs\opsadmin，不管用户是否登录都要运行
   触发器：每天 16:50
   操作：启动程序`C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`; 添加参数：`-File "C:\Scripts\backupDNS.ps1" -ComputerName homsom-dc02.hs.com -ErrorAction SilentlyContinue`
--------------


#windows10域中桌面黑屏处理方法：
1. 在"C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Themes"目录下删除"CachedFiles"目录，或者"CachedFiles"目录下的桌面背景图片。
切记不可删除"C:\Users\0799\AppData\Roaming\Microsoft\Windows\Themes"下的"TranscodedWallpaper"文件，此文件决定桌面是否显示，如果删除只能去其它电脑复制一份。
2. 执行组策略更新，gpupdate /force。
3. 桌面背景图片显示出来了，但显示有矩阵点，此时应该注销重新登录即可解决。logoff。
4. 如果将"C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Themes"目录下所有删除，则可以去其它电脑复制一份到有问题电脑即可。

#组策略注意事项
1. 值类型策略按照策略的顺序优先级执行
2. 集合类型将多个相同的组策略集合合并成一个集合，如果其中有两个相同的规则，但动作是允许和拒绝动作，则拒绝动作优先级大于允许动作。
3. 计算机配置——策略——管理模板——Windows 组件/远程桌面服务/远程桌面会话主机/连接 可以开启用户端的远程桌面功能。



#20211116--增加powershell卸载软件方法
--获取powershell驱动器
Get-PSDrive
--添加powershell驱动器
New-PSDrive -Name Uninstall -PSProvider Registry -Root HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
--软件安装
在远程安装时，请使用通用命名约定 (UNC) 网络路径指定 .msi 包的路径，因为 WMI 子系统并不了解 PowerShell 路径。 
例如，若要在远程计算机 PC01 上安装位于网络共享 \\AppServ\dsp 中的 NewPackage.msi 包，请在 PowerShell 提示符下键入以下命令：
Invoke-CimMethod -ClassName Win32_Product -MethodName Install -Arguments @{PackageLocation='\\AppSrv\dsp\NewPackage.msi'}
--软件卸载
Get-CimInstance -Class Win32_Product -Filter "name='腾讯企点'" | Invoke-CimMethod -MethodName Uninstall
--获取卸载字符串后进行卸载
--32位和64位
> get-childitem "hklm:\software\microsoft\windows\currentversion\uninstall" | foreach { get-itemproperty $_.pspath} |where { $_.publisher -match "$publisher"}
> get-childitem "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\" | Where-Object -FilterScript {$_.GetValue('Publisher') -like '*adobe*'} | foreach { get-itemproperty $_.pspath} | Select-Object -Property DisplayName,UninstallString,Publisher
DisplayName                 UninstallString                                                                             Publisher
-----------                 ---------------                                                                             ---------
Adobe Flash Player 34 PPAPI C:\WINDOWS\SysWOW64\Macromed\Flash\FlashUtil32_34_0_0_164_pepper.exe -maintain pepperplugin Adobe
Adobe Acrobat XI Pro        MsiExec.exe /I{AC76BA86-1033-FFFF-7760-000000000006}                                        Adobe Systems
----从获取的卸载符串中进行卸载,将参数/I改成/X,因为/X是卸载，而/I是安装
 >& "C:\Windows\System32\cmd.exe" /c "MsiExec.exe /X{AC76BA86-1033-FFFF-7760-000000000006}  /quiet /norestart"
--获取返回的对象类型
> Get-Service | gm
TypeName:System.ServiceProcess.ServiceController
--查看相关对象的命令
> Get-Command -ParameterType ServiceController
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Cmdlet          Get-Service                                        3.1.0.0    Microsoft.PowerShell.Management
Cmdlet          Restart-Service                                    3.1.0.0    Microsoft.PowerShell.Management
Cmdlet          Resume-Service                                     3.1.0.0    Microsoft.PowerShell.Management
Cmdlet          Set-Service                                        3.1.0.0    Microsoft.PowerShell.Management
Cmdlet          Start-Service                                      3.1.0.0    Microsoft.PowerShell.Management
Cmdlet          Stop-Service                                       3.1.0.0    Microsoft.PowerShell.Management
Cmdlet          Suspend-Service                                    3.1.0.0    Microsoft.PowerShell.Management
--Head和Tail都可以用Select-Object用-First和-Last参数来模拟。
> get-childitem "HKLM:\software\wow6432node\microsoft\windows\currentversion\Uninstall\" | Select-Object -First 1 | gm
--排序
Get-ChildItem |
  Sort-Object -Property LastWriteTime, Name -Descending |
  Format-Table -Property LastWriteTime, Name

--获取对象的属性名称
> get-childitem "HKLM:\software\wow6432node\microsoft\windows\currentversion\Uninstall\" | Select-Object -First 1 | ForEach-Object -Process { $_.getvaluenames()}
DisplayName
DisplayIcon
UninstallString
DisplayVersion
URLInfoAbout
Publisher
InstallLocation
--获取属性的值 
>get-childitem "HKLM:\software\wow6432node\microsoft\windows\currentversion\Uninstall\" |  ForEach-Object -Process { $_.getvalue('UninstallString')}
--字符串处理
$bb="MsiExec.exe /I{AC76BA86-1033-FFFF-7760-000000000006}"
$cc=$bb.Replace('/I','/X')
$dd='& "C:\Windows\System32\cmd.exe" /c ','"',$cc.ToString(),' /quiet /norestart"' -join ''
-- $ee=-Join('& "C:\Windows\System32\cmd.exe" /c ','"',$cc.ToString(),' /quiet /norestart"')
-get-childitem "HKLM:\software\wow6432node\microsoft\windows\currentversion\Uninstall\" | Where-Object -FilterScript {$_.GetValue('Publisher') -like '*adobe*'} | foreach { get-itemproperty $_.pspath} | Select-Object -Property DisplayName,UninstallString,Publisher-Invoke-Expression调用命令表达式来执行命令
wershell驱动器
New-PSDrive -Name Uninstall -PSProvider Registry -Root HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
--查找支持无需特殊配置即可进行远程处理的 cmdlet 具有 ComputerName 参数，但不具有 Session 参数
Get-Command | where { $_.parameters.keys -contains "ComputerName" -and $_.parameters.keys -notcontains "Session"}
--通过跃点访问第三个服务器，将凭据传输给第三个服务器
Invoke-Command -ComputerName hs-ua-tsj-0131  -Credential $cred -ScriptBlock{hostname; Invoke-Command -ComputerName hs-ua-tsj-0120 -Credential $Using:cred -ScriptBlock {hostname}}
HS-UA-TSJ-0131
HS-UA-TSJ-0120
invoke-command -session $session -scriptblock { param($v) $command=$v; Invoke-Expression $command } -ArgumentList $dd

--在远程会话中增加共享
net use \\172.168.2.219\share password /user:user@domain
\\172.168.2.219\share\homsom\QiDian5.0.0.18520.exe /s
----静默安装exe文件
\\172.168.2.130\d\QiDian5.0.0.18520\QiDian5.0.0.18520.exe /s
--获取安装文件卸载字符器
get-childitem -Path "HKLM:\software\wow6432node\microsoft\windows\currentversion\Uninstall\" | Where-Object -FilterScript {$_.GetValue('InstallLocation') -match 'qidian'}
--卸载有弹窗的软件
Start-Job -ScriptBlock {& "C:\Windows\System32\cmd.exe" /c "MsiExec.exe /X{E354F39D-4B67-4B4F-914F-FFAF55D6F5FF} /quiet /norestart"}
[hs-ua-tsj-0120]: PS C:\Users\0799\Documents> Get-Process msiexec
Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
-------  ------    -----      -----     ------     --  -- -----------
    257      11     6492      11404       0.03   5564   0 msiexec
    518      22     7628      20444       1.98   6988   0 msiexec
    437      17     8948      19736       0.34   7632   0 msiexec
[hs-ua-tsj-0120]: PS C:\Users\0799\Documents> Get-Process msiexec  | Stop-Process -Force
[hs-ua-tsj-0120]: PS C:\Users\0799\Documents> Get-Job
Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Job1            BackgroundJob   Completed     True            localhost            & "C:\Windows\System32...
--以后台job方式运行
Start-Job -ScriptBlock {& "C:\Windows\System32\cmd.exe" /c "MsiExec.exe /X{E354F39D-4B67-4B4F-914F-FFAF55D6F5FF} /quiet /norestart"} ; Start-Sleep -Seconds 60 ; Get-Process msiexec  | Stop-Process -Force;
Start-Job -ScriptBlock { \\172.168.2.130\d\QiDian5.0.0.18520\QiDian5.0.0.18520.exe /s}

#在客户端查看生效的组策略
1. 普通用户和管理员用户：gpresult
2. 管理员用户： rsop



# 更改电源计划方案
PS C:\Users\0799> powercfg.exe /l

现有电源使用方案 (* Active)
-----------------------------------
电源方案 GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (平衡) *
电源方案 GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  (高性能)
电源方案 GUID: a1841308-3541-4fab-bc81-f71556f20b4a  (节能)
电源方案 GUID: e9a42b02-d5df-448d-aa00-03f14749eb61  (卓越性能)
PS C:\Users\0799> powercfg.exe /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
PS C:\Users\0799> powercfg.exe /l

现有电源使用方案 (* Active)
-----------------------------------
电源方案 GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (平衡)
电源方案 GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  (高性能) *
电源方案 GUID: a1841308-3541-4fab-bc81-f71556f20b4a  (节能)
电源方案 GUID: e9a42b02-d5df-448d-aa00-03f14749eb61  (卓越性能)

PS C:\Users\0799> powercfg /q 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 238c9fa8-0aad-41ed-83f4-97be242c8f20		#高性能方案
电源方案 GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  (高性能)	
  GUID 别名: SCHEME_MIN
  子组 GUID: 238c9fa8-0aad-41ed-83f4-97be242c8f20  (睡眠)
    GUID 别名: SUB_SLEEP
    电源设置 GUID: 29f6c1db-86da-48c5-9fdb-f2b67b1f44da  (在此时间后睡眠)
      GUID 别名: STANDBYIDLE
      最小可能的设置: 0x00000000
      最大可能的设置: 0xffffffff
      可能的设置增量: 0x00000001
      可能的设置单位: 秒
    当前交流电源设置索引: 0x00000000
    当前直流电源设置索引: 0x00000000

    电源设置 GUID: 94ac6d29-73ce-41a6-809f-6363ba21b47e  (允许混合睡眠)
      GUID 别名: HYBRIDSLEEP
      可能的设置索引: 000
      可能的设置友好名称: 关闭
      可能的设置索引: 001
      可能的设置友好名称: 启用
    当前交流电源设置索引: 0x00000001
    当前直流电源设置索引: 0x00000001

    电源设置 GUID: 9d7815a6-7ee4-497e-8888-515a05f02364  (在此时间后休眠)
      GUID 别名: HIBERNATEIDLE
      最小可能的设置: 0x00000000
      最大可能的设置: 0xffffffff
      可能的设置增量: 0x00000001
      可能的设置单位: 秒
    当前交流电源设置索引: 0x00000000
    当前直流电源设置索引: 0x00000000

    电源设置 GUID: bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d  (允许使用唤醒定时器)
      GUID 别名: RTCWAKE
      可能的设置索引: 000
      可能的设置友好名称: 禁用
      可能的设置索引: 001
      可能的设置友好名称: 启用
      可能的设置索引: 002
      可能的设置友好名称: 仅限重要的唤醒计算器
    当前交流电源设置索引: 0x00000001
    当前直流电源设置索引: 0x00000001		
	
PS C:\Users\0799> powercfg.exe /q 381b4222-f694-41f0-9685-ff5bb260df2e 238c9fa8-0aad-41ed-83f4-97be242c8f20		#平衡方案
电源方案 GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (平衡)		
  GUID 别名: SCHEME_BALANCED
  子组 GUID: 238c9fa8-0aad-41ed-83f4-97be242c8f20  (睡眠)
    GUID 别名: SUB_SLEEP
    电源设置 GUID: 29f6c1db-86da-48c5-9fdb-f2b67b1f44da  (在此时间后睡眠)
      GUID 别名: STANDBYIDLE
      最小可能的设置: 0x00000000
      最大可能的设置: 0xffffffff
      可能的设置增量: 0x00000001
      可能的设置单位: 秒
    当前交流电源设置索引: 0x00004650		#此16进制表示配置睡眠时间为18000秒=5小时
    当前直流电源设置索引: 0x03938700		

    电源设置 GUID: 94ac6d29-73ce-41a6-809f-6363ba21b47e  (允许混合睡眠)
      GUID 别名: HYBRIDSLEEP
      可能的设置索引: 000
      可能的设置友好名称: 关闭
      可能的设置索引: 001
      可能的设置友好名称: 启用
    当前交流电源设置索引: 0x00000001
    当前直流电源设置索引: 0x00000001

    电源设置 GUID: 9d7815a6-7ee4-497e-8888-515a05f02364  (在此时间后休眠)
      GUID 别名: HIBERNATEIDLE
      最小可能的设置: 0x00000000
      最大可能的设置: 0xffffffff
      可能的设置增量: 0x00000001
      可能的设置单位: 秒
    当前交流电源设置索引: 0x03938700
    当前直流电源设置索引: 0x03938700

    电源设置 GUID: bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d  (允许使用唤醒定时器)
      GUID 别名: RTCWAKE
      可能的设置索引: 000
      可能的设置友好名称: 禁用
      可能的设置索引: 001
      可能的设置友好名称: 启用
      可能的设置索引: 002
      可能的设置友好名称: 仅限重要的唤醒计算器
    当前交流电源设置索引: 0x00000001
    当前直流电源设置索引: 0x00000001	
	

</pre>


# WSUS服务
**安装wsus服务**
在服务器管理器中勾选wsus更新服务，并默认安装iis，并安装指定.netframwork版本，安装完后设置是做为主wsus，
还是自治wsus或者副本wsus，要看更新报告，需要安装两个插件：1.ReportViewer.msi(可在wsus更新服务中点击
查看更新报告时会弹出链接下载)，2.SQLSysClrTypes.msi(这个软件在安装ReportViewer.msi时提示依赖此软件，必须先安装，
地址可google或百度出来下载)

**更换存储位置**
PS C:\Program Files\Update Services\Tools> .\WsusUtil.exe movecontent D:\WSUSData d:\wsusMove.log
正在移动内容位置。请不要终止该程序。
已成功完成内容移动。





## Windows Terminal添加Bash
1. 安装`Windows Git`程序
2. Ctrl+Shift+P打开命令面板输入`打开设置文件(JSON)`打开settings.json
3. 在`profiles`配置段添加`"name": "Git Bash"`的配置，如下显示，GUID可自动生成或用以下GUID
```json
    "profiles": 
    {
        "defaults": {},
        "list": 
        [
            {
                "guid": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
                "hidden": false,
                "name": "Windows PowerShell"
            },
            {
                "guid": "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}", 
                "hidden": false,
                "name": "\u547d\u4ee4\u63d0\u793a\u7b26"
            },
            {
                "guid": "{b453ae62-4e3d-5e58-b989-0a998ec441b8}",
                "hidden": false,
                "name": "Azure Cloud Shell",
                "source": "Windows.Terminal.Azure"
            },
			{
				"guid": "{d2736993-1af8-4eaa-b03c-a3fcbf915a26}",
				"name": "Git Bash",
				"commandline": "C:\\Program Files\\Git\\bin\\bash.exe",
				"icon": "C:\\Program Files\\Git\\mingw64\\share\\git\\git-for-windows.ico",
				"startingDirectory": "%USERPROFILE%",
				"colorScheme": "Campbell",
				"fontFace": "Consolas",
				"useAcrylic": true,
				"acrylicOpacity": 0.8
			}
        ]
    }
```



## 自动登录windows

### 1. 配置注册表
```cmd
# 配置用户名、密码、是否自动登录(1为true，0为false)、如果是域用户需要配置域名称
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /t REG_SZ /d "username" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d "password" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultDomainName /t REG_SZ /d "test.com" /f
```

### 2. 锁定屏幕命令
```cmd
%windir%\system32\rundll32.exe user32.dll,LockWorkStation
```

### 3. 脚本实现自动登录运行程序并锁定屏幕
```cmd
# StartupAndLock.bat
@echo off
:: 设置工作目录并启动 waitress-serve（不阻塞）
start "Waitress Server" /D "C:\software\hs-sgui" "C:\software\hs-sgui\waitress-serve.exe" --host 0.0.0.0 --port 8018 app:app

:: 等待服务初始化（根据实际情况调整时间）
timeout /t 3 /nobreak >nul

:: 立即锁定工作站
rundll32.exe user32.dll,LockWorkStation
```

### 4. 开机运行弹窗需确认问题
```powershell
## C:\Scripts\StartupAndLock.ps1
# 启动 waitress-serve（后台运行）
Start-Process -FilePath "C:\software\hs-sgui\waitress-serve.exe" -ArgumentList "--host 0.0.0.0 --port 8018 app:app" -WorkingDirectory "C:\software\hs-sgui" -WindowStyle Hidden

# 等待 5 秒
Start-Sleep -Seconds 5

# 锁定工作站
rundll32.exe user32.dll,LockWorkStation


## 创建快捷方式，保存到 shell:startup
powershell.exe -ExecutionPolicy Bypass -File "C:\Scripts\StartupAndLock.ps1"
```
