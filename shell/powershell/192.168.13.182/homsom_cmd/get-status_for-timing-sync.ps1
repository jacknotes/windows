$BASEHOME="C:\Users\administrator.HS\Desktop\"
$TIMING_LIST="diffsync_Callcenter\diffsync\log\","diffsync_CONN\diffsync\log\","diffsync-190\log\"
$SUFFIX="*sync*"
$DATETIME=(Get-Date).ToString('yyyy-MM-dd-HH:mm:ss')
$LOG_ADDRESS="\\192.168.13.182\HomsomAuto\192.168.13.182\sync.log"
$SYNC_HOST="192.168.13.182"

echo "HOST: $SYNC_HOST" | Out-File -Encoding utf8 $LOG_ADDRESS
echo "$DATETIME" | Out-File -Encoding utf8 -Append $LOG_ADDRESS
foreach($J in $TIMING_LIST){
	$SECOND_FOREACH=Get-ChildItem $BASEHOME$J$SUFFIX 
	foreach($I in 0..($SECOND_FOREACH.length-1)){
		$RESULT=Get-Content ${SECOND_FOREACH}[$I].fullname | Select-Object -Last 10 | select-string -Pattern "$((get-date).tostring('yyyy-MM-dd'))" -quiet 

		if($RESULT -eq $true){
			echo "$(${SECOND_FOREACH}[${I}].fullname): successful " | Out-File -Encoding utf8 -Append $LOG_ADDRESS
		}else{
			echo "$(${SECOND_FOREACH}[${I}].fullname): faiulre" | Out-File -Encoding utf8 -Append $LOG_ADDRESS
		}
	}
}


