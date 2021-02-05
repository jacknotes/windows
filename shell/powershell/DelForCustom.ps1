param(
    [Parameter(Mandatory=$True,HelpMessage="Input Source Directory or file")]
    [Alias('SDIR')]
    [string]$SUNC=$(throw "Source Directory or file is NULL"),

    [Parameter(Mandatory=$True,HelpMessage="Input Source File Type [xml | hosts]")]
    [Alias('filetype')]
    [string]$TYPE=$(throw "Input Source File Type is NULL"),

    [Parameter(Mandatory=$True,HelpMessage="Delete Begin Number of Days")]
    [Alias('DeleteDay')]
    [string]$DAYS=$(throw "Delete Begin Number of Days")
)


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
$day=$($today.AddDays(-$DAYS).ToString('yyyy-MM-dd'))
 

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

function delfilelist($Dirs=$False)
{
    if(! $Dirs){
	echo "args is null"
    }
    elseif($TYPE -eq "xml")
    {
        Get-ChildItem -Path $Dirs -Recurse -ErrorAction SilentlyContinue -Filter *.xml |Where-Object { $_.Extension -eq '.xml' }| Where-Object -FilterScript {($_.LastWriteTime -lt $day) -and ($_.PsISContainer -eq $False)} |
        Select-Object FullName|
        ForEach-Object {delfiles $_.FullName}
    }
    elseif($TYPE -eq "hosts")
    {
        Get-ChildItem -Path $Dirs -Recurse -ErrorAction SilentlyContinue -Filter *$TYPE* | Where-Object -FilterScript {($_.LastAccessTime -lt $day) -and ($_.PsISContainer -eq $False)} |
        Select-Object FullName|
        ForEach-Object {delfiles $_.FullName}
    }
    else
    {
        Get-ChildItem -Path $Dirs  -Recurse -ErrorAction SilentlyContinue | Where-Object -FilterScript {($_.LastWriteTime -lt $day) } | Select-Object FullName |  
        ForEach-Object {delfiles $_.FullName}
    }
}
 
delfilelist $SUNC