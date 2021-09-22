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

<<<<<<< HEAD
#wsus client sync command 
wuauclt /resetauthorization /detectnow
wuauclt /detectnow
wuauclt /reportnow
=======
#Dell服务器IDRAC默认帐户信息
<pre>
Dell服务器默认用户信息如下：
IP: 192.168.0.120
USER: root
PASSWORD: caivin
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

Get-WmiObject -class win32_product -Filter "name like 'eTerm%'"
Get-WmiObject -query "select * from win32_product where name like 'eTerm%'" | select-object __server,name,version | format-table | Export-Csv -Append f:\test.csv

$client=Get-Content .\hostname.txt
foreach($i in $client){Get-WmiObject -query "select * from win32_product where name like 'eTerm%'" -ComputerName $i | select-object __server,name,version| format-table >> \\172.168.2.219\share\tmp\eterm.txt}

防火墙：
netsh advfirewall show domainprofile



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







</pre>

