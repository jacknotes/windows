Param(
  [Parameter(Mandatory=$True,Position=1)]
    [string]$ComputerListFile # CSV FILE COLUMES: computer,uninstallstring,isuninstall,必须是csv格式才行，xlsx会报错
)

$Cred = Get-Credential -Message "请输入域管理员账户"
$EAP = $ErrorActionPreference
$Computers = Import-Csv -Path $ComputerListFile

# 获取各计算机的 Publisher 含 "adobe" 的已安装软件
foreach ($computer in $Computers)
{
    if ($computer.isuninstall -eq "yes")
    {
        continue
    }

    $apps = "1"
    Try
    {
        echo "start from $($computer.computer) uninstall $($computer.softwarename)"
        $ErrorActionPreference = "Stop"
        $MyPsSession = New-PSSession -ComputerName $computer.computer -Credential $Cred
 
        $command="$(($computer.uninstallstring))"
        invoke-command -session $MyPsSession -scriptblock { param($v) $command=$v; Invoke-Expression $command } -ArgumentList $command

        Remove-PSSession -Session $MyPsSession
    }
    Catch
    {
        Remove-PSSession -Session $MyPsSession
        continue
    }
    Finally
    {
        $ErrorActionPreference = $EAP
    }
}