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