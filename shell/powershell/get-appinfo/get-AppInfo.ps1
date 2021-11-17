Param(
  [Parameter(Mandatory=$True,Position=1)]
    [string]$Publisher,
  [Parameter(Mandatory=$True,Position=2)]
    [string]$ComputerListFile, # CSV FILE COLUMES: Name,isGetInfo,必须是csv格式才行，xlsx会报错
  [Parameter(Mandatory=$False,Position=3)]
    [string]$ResultFile        # txt格式，然后复制到csv表格中
)

$Cred = Get-Credential -Message "请输入域管理员账户"
$EAP = $ErrorActionPreference
$Computers = Import-Csv -Path $ComputerListFile
$ResultList = New-Object -TypeName System.Collections.ArrayList
$ErrorList = New-Object -TypeName System.Collections.ArrayList
$ClearList = New-Object -TypeName System.Collections.ArrayList

# 获取各计算机的 Publisher 含 "adobe" 的已安装软件
foreach ($computer in $Computers)
{
    if ($computer.isGetInfo -eq "yes")
    {
        continue
    }
    $arch = "32-bit"
    $apps = "1"
    Try
    {
        $ErrorActionPreference = "Stop"
        $MyPsSession = New-PSSession -ComputerName $computer.name -Credential $Cred
        $arch = Invoke-Command -Session $MyPsSession -ScriptBlock { (Get-WmiObject -Class win32_operatingsystem).osarchitecture }

        invoke-command -session $mypssession -scriptblock {param($v) $publisher = $v} -argumentlist $publisher
        if ( $arch -match "32" )
        {
            $command = { get-childitem "hklm:\software\microsoft\windows\currentversion\uninstall" | foreach { get-itemproperty $_.pspath} |where { $_.publisher -match "$publisher"}}
        }
        if ( $arch -match "64" )
        {
            $command = { get-childitem "hklm:\software\wow6432node\microsoft\windows\currentversion\uninstall" | foreach { get-itemproperty $_.pspath} |where { $_.publisher -match "$publisher"}}
        }
        $apps = invoke-command -session $mypssession -scriptblock $command
        Remove-PSSession -Session $MyPsSession
    }
    Catch
    {
        Remove-PSSession -Session $MyPsSession
        $ErrorList.Add($($computer.name))
        #Write-Host ("$computer.name")
        continue
    }
    Finally
    {
        $ErrorActionPreference = $EAP
    }
    
    if ($apps -eq $null)
    {
        $ClearList.Add($($computer.name))
    }
    else
    {
        foreach ($app in $apps)
        {
            #$ResultList.Add(("$($app.PSComputerName)`t$($app.DisplayName)`t$($app.UninstallString)`t$($app.Publisher)"))
            Out-File -FilePath $ResultFile -Append -Encoding utf8 -InputObject "$($computer.seat)`t$($computer.depatment)`t$($computer.username)`t$($app.PSComputerName)`t$($app.DisplayName)`t$($app.UninstallString)`t$($app.Publisher)"
        }
    }
}

Write-Host "以下计算机在获取信息时错误："
foreach ( $r in $ErrorList)
{
    Write-Host $r
}

Write-Host "以下计算机没有Adobe软件"
foreach ( $ec in $ClearList)
{
    Write-Host $ec
}