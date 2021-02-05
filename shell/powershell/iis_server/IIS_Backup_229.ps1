$HOSTNAME="192.168.13.229"
$DATEYEAR=(get-date).Year
$DATEMONTH=(get-date).Month
$DATEDAY=(get-date).Day
$DATE="$DATEYEAR"+"$DATEMONTH"+"$DATEDAY"
$APPPOOL_CMD="apppool"
$SITE_CMD="site"
$HOSTS="hosts"
$BACKUP_DIR="\\192.168.13.72\share_backup"
$NETFRAMWORK_DIR="C:\Windows\Microsoft.NET\Framework64\v4.0.30319"
$IIS_Config_Key="iisConfigurationKey"
$IIS_Was_Key="iisWasKey"


C:\windows\system32\inetsrv\appcmd list $APPPOOL_CMD /config /xml >  $BACKUP_DIR\$HOSTNAME-$APPPOOL_CMD-$DATE.xml

C:\windows\system32\inetsrv\appcmd list $SITE_CMD /config /xml >  $BACKUP_DIR\$HOSTNAME-$SITE_CMD-$DATE.xml

& $NETFRAMWORK_DIR\aspnet_regiis.exe -px "iisConfigurationKey" "$BACKUP_DIR\$HOSTNAME-$IIS_Config_Key-$DATE.xml" -pri 

& $NETFRAMWORK_DIR\aspnet_regiis.exe -px "iisWasKey" "$BACKUP_DIR\$HOSTNAME-$IIS_Was_Key-$DATE.xml" -pri 

copy C:\Windows\system32\drivers\etc\hosts $BACKUP_DIR\$HOSTNAME-$HOSTS-$DATE
