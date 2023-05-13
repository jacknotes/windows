$SUNC="F:\Monitor File"
$TODAY=$($(Get-Date).ToString('yyyy-MM-dd'))
$VIDEO_NUM=9
$COUNTS=Get-ChildItem -Path $SUNC | Where-Object -FilterScript {($_.LastWriteTime.tostring('yyyy-MM-dd') -eq $TODAY) } | measure |select -Property count
$LOG_ADDRESS="\\192.168.13.182\HomsomAuto\172.168.2.10\video.log"

$DATETIME=(Get-Date).ToString('yyyy-MM-dd-HH:mm:ss')
$VIDEO_HOST="172.168.2.10"

echo "HOST: $VIDEO_HOST" | Out-File -Encoding utf8 $LOG_ADDRESS
echo "$DATETIME" | Out-File -Encoding utf8 -Append $LOG_ADDRESS

if($COUNTS.count -eq $VIDEO_NUM){
	echo "Status: Video is Running" | Out-File -Encoding utf8 -Append $LOG_ADDRESS
}else{
	echo "Status: Video is No Running" | Out-File -Encoding utf8 -Append $LOG_ADDRESS
}


