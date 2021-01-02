#PowerShell
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
get-aduser -filter {enabled -eq "true"} -properties * | where-object samaccountname -eq "0799" | select-object displayname,samaccountname,Created,LastLogonDate,PasswordExpired,PasswordNeverExpires,PasswordLastSet,AccountLockoutTime | Format-table

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


----20210102
变量:
$env:path
$env:users
--临时加入变量路径
$env:path=$env:path+"d:\system32"

&"notepad"  等同于 notepad

get-alias | where {$_.definition.startswith("Remove")} ------definition.startswith()是.net类库中字符串的方法
get-alias | group-object definition | sort -descending count 
set-alias -name pad -value notepad
del alias:pad
export-alias demo.ps1
import -force demo.ps1

ls variable:
ls variable:pwd
test-path variable:pwd
test-path variable:num0
del variable:num1

ls env:
ls env:windir
$env:name="jack"
$env:name
del env:name

--永久设置用户环境变量
[environment]::setenvironmentvariable("testvar","d:\","user")
[environment]::getenvironmentvariable("testvar","user")

--powershell执行策略
PS C:\Users\Jackli> Get-ExecutionPolicy
Unrestricted
PS C:\Users\Jackli> get-help set-executionpolicy
{Unrestricted | RemoteSigned | AllSigned | Restricted | Default | Bypass | U
    ndefined}
Set-ExecutionPolicy RemoteSigned --设置powershell脚本执行级别

--cmd执行powershell脚本 
cmd: powershell "&'c:\users\administrator\desktop\demo.ps1'"

--条件操作符
-eq -gt -ge -lt -le -contains -notcontains -and -or -not -xor

--if语句
$num=48
if($num -gt 50)
{
	echo "此数值大于50"
}elseif($num -eq 50)
{
	echo "此数值等于50"
}else
{
	echo "此数值小于50"
}

--switch语句 
$num=49
switch($num)
{
	{($_ -lt 50) -and ($_-gt 40)} {"此数值小于50大于40"}
	50 {"此数值等于50"}
	{$_ -gt 50} {"此数值大于50"}
}

--foreach语句
$arr=1..10
foreach($n in $arr)
{
	if($n -gt 5)
	{
		$n	
	}
}

$path_value=dir d:\all
foreach($n in $path_value)
{
	if($n -gt 1kb)
	{
		$n	
	}
}

--while语句，do .while语句
$num=50
while($num -gt 45)
{
	$num
	$num=$num-1
}
do.while语句
$num=50
do
{
	$num
	$num=$num-1
}
while($num -gt 45)

--break,continue
$num=1
while($num -lt 6)
{
	if($num -eq 4)
	{
		break
	}
	else
	{
		$num
		$num++
	}
}
----continue
$num=1
while($num -lt 6)
{
	if($num -eq 4)
	{
		$num++
		continue
	}
	else
	{
		$num
		$num++
	}
}

$arr=1..100
$sum=0
foreach($i in $arr)
{
	$sum=$sum+$i
	$sum
}


$sum=0
for($n=1;$n -le 100;$n++){
	$sum=$sum+$n
	$sum
}

$nums=1..10
switch($nums)
{
	{($_ % 2) -eq 0} {"$_ 是偶数"}
	{($_ % 2) -ne 0} {"$_ 是奇数"}
}

--数组
$arr=1,2,3,4,5
$arr
$arr -is [array]

$arr=1..5
$arr
$arr -is [array]

$arr=1,"hello world"
$arr
$arr -is [array]

$arr=@()
$arr -is [array]

$arr=1,"hello world",(get-date)
$arr.count
$arr.length
$arr[0..2]
$arr[1,-1]
$arr[($arr.count)..0]  --倒序输出
$arr+="hehe"
$arr[($arr.count)..0]

--powershell 函数
function myping($addr)
{
	ping $addr
}
myping www.mi.com
--function return语句
function add($num1,$num2)
{
	$sum=$num1+$num2
	$sum.gettype()
	$sum.gettype().fullname
	return $sum
}
add 1.3 2.5

----powershell `(转换字符),`n(换行符) `r `t `b 
"hello world , my name is `"jack`",`ncurrent date is $(get-date)"  
--read-host
$input=read-host "请输入数字:"
"您输入的数字是："$input
--字符串格式化
$name='jack'
"myname is {0},age is {1}" -f $name,(3*6)
--字符串处理
$str="c:\windows\system32\test.txt"
$str.endswith('txt')
$str.contains('windows')
$str.compareto("c:\windows\system32\test.txt")  --是否相等，相等为0，不相等为1
$str.indexof('w')
$str.split('.')
$str[-1]
$str.insert(1,'hehe')
$str.replace("c","C")

----powershell帮助系统
get-help -online | -showwindow | detailed | examples | full 
get-help about*
get-help category

--get-service
 Get-Service | ConvertTo-Html -property name,status
 Get-Service | Export-Clixml c:\services.xml
Get-Service -display *update*
 Get-Service -name wuauserv | Stop-Service -whatif
Get-Service -name wuauserv | Stop-Service -confirm

--module
----安装远程服务器管理工具，里面有AD工具，就可以用powershell加载ADmodule
 Get-Module -ListAvailable   ----列出可以加载的模块
Get-Module     ----显示当前已加载的模块
 Import-Module SmbShare

--Get-WmiObject
Get-WmiObject win32_logicaldisk -Filter "deviceid='c:'"  | select @{n="freegb";e={$_.freespace / 1gb -as [int]}},freespace

---
param(
	$ComputerName='localhost'
)
Get-WmiObject win32_logicaldisk -ComputerName $ComputerName -Filter "deviceid='c:'"  | select @{n="freegb";e={$_.freespace / 1gb -as [int]}},freespace
---
$myvar = get-service bits
PS C:\Users\Jackli> $myvar.status
Stopped
PS C:\Users\Jackli> $myvar.start()
PS C:\Users\Jackli> $myvar.refresh()
PS C:\Users\Jackli> $myvar.status
Running
PS C:\Users\Jackli> 1..5 > d:\test.txt
PS C:\Users\Jackli> ${d:\test.txt}   --这个变量名称是跨计算机的，可以在另我一个窗口使用这个变量
1
2
3
4
5

--远程命令
$sessions=New-PSSession -ComputerName wsus02-xen01
icm -Session $sessions {ls d:\}

--远程管理多台计算机
PS C:\Users\Jackli> $servers="web01","web02"
PS C:\Users\Jackli> $servers
web01
web02
 $s=New-PSSession -ComputerName $servers
Invoke-Command -Session $s {install-windowsfeature web-server}   --安装webserver
$servers | foreach{Copy-Item c:\defult.html -Destination \\$_\c$\inetpub\wwwroot\}
$servers | foreach{start iexplore http://$_}

--从远程服务器导入模块到本地，本地可不安装远程管理工具管理远端服务器
--从新的会话中导入命令
PS C:\> $s=New-PSSession
PS C:\> Import-PSSession -session $s -CommandName Get-Process -prefix hehe
PS C:\> Get-heheProcess
--从远程服务器导入模块
 $s=New-PSSession -ComputerName dc
Import-PSSession -Session $s -Module ActiveDirectory -Prefix remote
Get-Command *remoteAD*


</pre>

