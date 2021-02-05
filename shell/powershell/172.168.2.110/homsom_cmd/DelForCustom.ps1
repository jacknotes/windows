$today=Get-Date
#"今天是：$today"
#昨天
#"昨天是:$($today.AddDays(-1))"
#明天
#"明天是:$($today.AddDays(1))"
#一周前
#"一周前是: $($today.AddDays(-7))"
#五个月前
#"五个月前:$($today.AddMonths(-5))"
#十年之前
#"十年之前:$($today.AddYears(-10).Year)年,我们是朋友."
#日期格式化
#"格式化日期：" + $today.ToString('yyyy-MM-dd')
#删除7天前的文件
$day=$($today.AddDays(-7).ToString('yyyy-MM-dd'))
 
$LocalDir="D:\Callcenter_SQLServer_Backup"
$FilterDir="D:\Callcenter_SQLServer_Backup"

function delfiles
{
    if(! ($args | foreach {Test-Path $_}))
    {
        echo $args
        "File Path No Exists!"
    }else
    {  
     #布尔类型转换成整数
     $args | foreach { $result=Test-Path $_ |foreach { [int] $_ } 
        if ($result -eq 1){
            del -Recurse $_
            "$_  删除文件成功！"
        }else{
            "$_ 文件不存在"
            break
        } 
      }
    }
}

function delfilelist($RemoteDir=$False)
{
    if(! $RemoteDir){
	echo "args is null"
    }
    elseif($RemoteDir -eq $FilterDir)
    {
        Get-ChildItem -Path $RemoteDir -Recurse -ErrorAction SilentlyContinue -Filter *.bak |Where-Object { $_.Extension -eq '.bak' }| Where-Object -FilterScript {($_.LastWriteTime -lt $day) -and ($_.PsISContainer -eq $False)} |
        Select-Object FullName|
        ForEach-Object {delfiles $_.FullName}
    }
    else
    {
        Get-ChildItem -Path $RemoteDir  -Recurse -ErrorAction SilentlyContinue | Where-Object -FilterScript {($_.LastWriteTime -lt $day) } | Select-Object FullName |  
        ForEach-Object {delfiles $_.FullName}
    }
}
 
delfilelist $LocalDir