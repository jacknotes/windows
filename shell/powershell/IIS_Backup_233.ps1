$HOSTNAME="192.168.13.233"
$LOGDIR="$DUNC\log"
$LOGFILE="$LOGDIR\log"
$DATEYEAR=(get-date).Year
$DATEMONTH=(get-date).Month
$DATEDAY=(get-date).Day
$DATE="$DATEYEAR"+"$DATEMONTH"+"$DATEDAY"
$APPPOOL_CMD="apppool"
$SITE_CMD="site"
$HOSTS="hosts"
$BACKUP_DIR="\\192.168.13.72\share_backup"

C:\windows\system32\inetsrv\appcmd list $APPPOOL_CMD /config /xml >  $BACKUP_DIR\$HOSTNAME-$APPPOOL_CMD-$DATE.xml

C:\windows\system32\inetsrv\appcmd list $SITE_CMD /config /xml >  $BACKUP_DIR\$HOSTNAME-$SITE_CMD-$DATE.xml

copy C:\Windows\system32\drivers\etc\hosts $BACKUP_DIR\$HOSTNAME-$HOSTS-$DATE