$HOSTNAME="192.168.13.229"
$DATEYEAR=(get-date).Year
$DATEMONTH=(get-date).Month
$DATEDAY=(get-date).Day
$DATE="$DATEYEAR"+"$DATEMONTH"+"$DATEDAY"
$APPPOOL_CMD="apppool"
$SITE_CMD="site"
$HOSTS="hosts"
$BACKUP_DIR="\\172.168.2.219\share\server\tmp"



C:\windows\system32\inetsrv\appcmd list $APPPOOL_CMD /config /xml >  $BACKUP_DIR\$HOSTNAME-$APPPOOL_CMD-$DATE.xml

C:\windows\system32\inetsrv\appcmd list $SITE_CMD /config /xml >  $BACKUP_DIR\$HOSTNAME-$SITE_CMD-$DATE.xml


copy C:\Windows\system32\drivers\etc\hosts $BACKUP_DIR\$HOSTNAME-$HOSTS-$DATE
