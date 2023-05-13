$DATETIME=(Get-Date).ToString('yyyy-MM-dd-HH:mm:ss')
$PROGRAMS="D:\software\时间健康\时间健康\TimeHealth.WApp.exe"
$LOG_ADDRESS=".\process-satus.log"
$TIME=1

while( 1 -ne 2){
	if(-not (Get-Process TimeHealth.Wapp -ErrorAction Ignore)){
		echo $DATETIME`n"	TimeHealth.Wapp is stop." | Out-File -Encoding utf8 -Append $LOG_ADDRESS
		& $PROGRAMS
	}
	sleep $TIME
}