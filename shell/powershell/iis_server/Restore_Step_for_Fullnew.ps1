$BACKUP_DIR="C:\Software"
$ApppoolFiles="$BACKUP_DIR\172.168.2.220-apppool-2021127.xml"
$SiteFiles="$BACKUP_DIR\172.168.2.220-site-2021127.xml"
$SourceHostsFils="$BACKUP_DIR\172.168.2.220-hosts-2021127"
$DestinationHostsFils="C:\Windows\System32\drivers\etc\hosts"

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
type $ApppoolFiles | c:\windows\system32\inetsrv\appcmd.exe add apppool -
type $SiteFiles | c:\windows\system32\inetsrv\appcmd.exe add site - 
##copy hosts,move source directory
Copy-Item -Path $SourceHostsFils -Destination $DestinationHostsFils -Recurse
