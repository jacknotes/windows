Param(
  [Parameter(Mandatory=$True,Position=1)]
    [string]$ComputerListFile, # CSV FILE COLUMES: Name,isGetInfo,必须是csv格式才行，xlsx会报错
  [Parameter(Mandatory=$True,Position=2)]
    [string]$ResultFile        # txt格式文件，然后复制到csv表格中
)

$Computers = Import-Csv -Path $ComputerListFile
$NewSessionComputerList=New-Object -TypeName System.Collections.ArrayList
$Credential=get-credential -message "Please Input Your Username and Password...."
$EAP = $ErrorActionPreference
$ThrottleLimits=200
# $Computers='HS-UA-TSJ-0049',
# 'HS-UA-TSJ-0114',
# 'HS-UA-TSJ-0158',
# 'HS-UA-TSJ-0148',
# 'HS-UA-TSJ-0085',
# 'HS-UA-TSJ-0130'



#create pssession
ForEach($computer in $Computers){
	if ($computer.isGetInfo -eq "yes")
    {
        continue
    }
	
	New-PSSession -ComputerName $computer.name -Credential $Credential -ErrorAction Ignore >> $null
	if($? -eq $false){
		$NewSessionComputerList.Add($computer.name) >> $null
		continue
	}
}

######get computer info 
#get computer system info
$SystemResultInfo=Invoke-Command -ThrottleLimit $ThrottleLimits -Session (Get-PSSession) -ErrorAction Ignore -ScriptBlock { 
		Get-CimInstance -Namespace root/CIMV2 -ClassName win32_operatingsystem | Select-Object -Property Caption,OSArchitecture,RegisteredUser,TotalVisibleMemorySize
	} 
#get computer memory info
$MemoryResultInfo=Invoke-Command -ThrottleLimit $ThrottleLimits -Session (Get-PSSession) -ErrorAction Ignore -ScriptBlock {
		Get-CimInstance -Namespace root/CIMV2 -ClassName Win32_PhysicalMemory -ErrorAction Ignore | select-object -ErrorAction Ignore PSComputerName,DeviceLocator,SMBIOSMemoryType,ConfiguredClockSpeed,Speed,Capacity,Tag
	} 
#get computer disk info
$DiskResultInfo=Invoke-Command -ThrottleLimit $ThrottleLimits -Session (Get-PSSession) -ErrorAction Ignore -ScriptBlock {
		Get-CimInstance -Namespace root/CIMV2 -ClassName Win32_DiskDrive | Select-Object -Property Model,Partitions,Size
	} 
#get computer cpu info
$CpuResultInfo=Invoke-Command -ThrottleLimit $ThrottleLimits -Session (Get-PSSession) -ErrorAction Ignore -ScriptBlock {
		Get-CimInstance -Namespace root/CIMV2 -ClassName Win32_Processor | Select-Object -Property name,MaxClockSpeed,CurrentClockSpeed,NumberOfCores,ThreadCount
	} 	
	
	
######Output to txt file.
#computer system info
Out-File -FilePath $ResultFile -Append -Encoding utf8 -InputObject "PSComputerName`tCaption`tOSArchitecture`tRegisteredUser`tTotalVisibleMemorySize"
foreach($i in $SystemResultInfo){
	Out-File -FilePath $ResultFile -Append -Encoding utf8 -InputObject "$($i.PSComputerName)`t$($i.Caption)`t$($i.OSArchitecture)`t$($i.RegisteredUser)`t$($i.TotalVisibleMemorySize)"
}
Write-Output "" >> $ResultFile
#computer memory info
Out-File -FilePath $ResultFile -Append -Encoding utf8 -InputObject "PSComputerName`tDeviceLocator`tSMBIOSMemoryType`tConfiguredClockSpeed`tSpeed`tCapacity`tTag"
foreach($i in $MemoryResultInfo){
	Out-File -FilePath $ResultFile -Append -Encoding utf8 -InputObject "$($i.PSComputerName)`t$($i.DeviceLocator)`t$($i.SMBIOSMemoryType)`t$($i.ConfiguredClockSpeed)`t$($i.Speed)`t$($i.Capacity)`t$($i.Tag)"
}
Write-Output "" >> $ResultFile
#computer disk info
Out-File -FilePath $ResultFile -Append -Encoding utf8 -InputObject "PSComputerName`tModel`tPartitions`tSize"
foreach($i in $DiskResultInfo){
	Out-File -FilePath $ResultFile -Append -Encoding utf8 -InputObject "$($i.PSComputerName)`t$($i.Model)`t$($i.Partitions)`t$($i.Size)"
}
Write-Output "" >> $ResultFile
#computer cpu info
Out-File -FilePath $ResultFile -Append -Encoding utf8 -InputObject "PSComputerName`tname`tMaxClockSpeed`tCurrentClockSpeed`tNumberOfCores`tThreadCount"
foreach($i in $CpuResultInfo){
	Out-File -FilePath $ResultFile -Append -Encoding utf8 -InputObject "$($i.PSComputerName)`t$($i.name)`t$($i.MaxClockSpeed)`t$($i.CurrentClockSpeed)`t$($i.NumberOfCores)`t$($i.ThreadCount)"
}
Write-Output "" >> $ResultFile


#remove pssession
Get-PSSession | Remove-PSSession


#Output To Console
Write-Host "Computer System Info: "
	$SystemResultInfo | Format-Table
# foreach ( $c in $SystemResultInfo){
	# Write-Host $c
# }
Write-Host "Computer memory Info: "
	$MemoryResultInfo | Format-Table
# foreach ( $c in $MemoryResultInfo){
	# Write-Host $c
# }
Write-Host "Computer disk Info: "
	$DiskResultInfo | Format-Table
# foreach ( $c in $DiskResultInfo){
	# Write-Host $c
# }
Write-Host "Computer cpu Info: "
	$CpuResultInfo | Format-Table
# foreach ( $c in $CpuResultInfo){
	# Write-Host $c
# }

#Output NewSession Error of Computer Name
Write-Host "The Following Computer Create Session Is Error: "
foreach ( $c in $NewSessionComputerList)
{
    Write-Host $c
}


#get user computer
#PS C:\Users\0799> $session=100..160 | foreach { "HS-UA-TSJ-{0:D4}" -F $PSItem } | New-PSSession -ThrottleLimit 50 -ErrorAction Ignore
#PS C:\Users\0799> Invoke-Command -Session $Session -ErrorAction Ignore -ScriptBlock {Get-ComputerInfo -Property CsName,csusername} | Where-Object csusername -eq 'hs\0892' | Format-table
#CsName         CsUserName PSComputerName RunspaceId
#------         ---------- -------------- ----------
#HS-UA-TSJ-0121 HS\0892    HS-UA-TSJ-0121 a7c76033-8846-4657-aea0-680573ab946c


