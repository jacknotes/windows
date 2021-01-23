$BACKUP_DIR="D:\share_backup"
$ApppoolFiles="$BACKUP_DIR\192.168.13.233-apppool-2021122.xml"
$SiteFiles="$BACKUP_DIR\192.168.13.233-site-2021122.xml"
$IIS_Config_Key_File="$BACKUP_DIR\192.168.13.233-iisConfigurationKey-2021122.xml"
$IIS_Was_Key_File="$BACKUP_DIR\192.168.13.233-iisWasKey-2021122.xml"
$SourceHostsFils="$BACKUP_DIR\192.168.13.233-hosts-2021122"
$DestinationHostsFils="C:\Windows\System32\drivers\etc\hosts"
$SourceDir="D:\WebFiles13_233"
$DestinationDir="D:\WebFiles"
$NETFRAMWORK_DIR="C:\Windows\Microsoft.NET\Framework64\v4.0.30319"
$IIS_Config_Key="iisConfigurationKey"
$IIS_Was_Key="iisWasKey"
$DATETIME=(get-date).Year.tostring()+(get-date).Month.tostring()+(get-date).Day.tostring()+(get-date).Millisecond.tostring()

if(! (Test-Path $SourceDir)){
	echo "$SourceDir Not Exists!exit..."
	exit 1
}

if(Test-Path $DestinationDir){
	stop-Service w3svc
	echo "$DestinationDir is Exists!!!  move $DestinationDir to $DestinationDir$DATETIME"
	Move-Item -Path $DestinationDir -Destination $DestinationDir$DATETIME
}


Restart-Service w3svc
if(! $?){
	echo "www service boot failure!exit..."
	exit 1
}

##DELETE
#step1:
$CurrentSites=C:\Windows\system32\inetsrv\appcmd.exe list sites
$Sites=foreach($i in $CurrentSites){($i -split '"')[1]}
foreach($i in $Sites){C:\Windows\system32\inetsrv\appcmd.exe delete site $i}

#step2:
$CurrentApppools=C:\Windows\system32\inetsrv\appcmd.exe list apppools
$Apppools=foreach($i in $CurrentApppools){($i -split '"')[1]}
foreach($i in $Apppools){C:\Windows\system32\inetsrv\appcmd.exe delete apppool $i}

##RESTORE
#step3:
& $NETFRAMWORK_DIR\aspnet_regiis.exe -pi "$IIS_Config_Key" "$IIS_Config_Key_File"
& $NETFRAMWORK_DIR\aspnet_regiis.exe -pi "$IIS_Was_Key" "$IIS_Was_Key_File"
type $ApppoolFiles | c:\windows\system32\inetsrv\appcmd.exe add apppool -
type $SiteFiles | c:\windows\system32\inetsrv\appcmd.exe add site - 
##copy hosts,move source directory
Copy-Item -Path $SourceHostsFils -Destination $DestinationHostsFils -Recurse
Move-Item -Path $SourceDir -Destination $DestinationDir
