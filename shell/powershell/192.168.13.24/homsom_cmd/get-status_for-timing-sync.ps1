$BASEHOME="C:\Program Files\"
$TIMING_LIST="diffsync\log\"
$SUFFIX="*sync*"
$DATETIME=(Get-Date).ToString('yyyy-MM-dd-HH:mm:ss')
$LOG_ADDRESS="\\192.168.13.182\HomsomAuto\192.168.13.24\sync.log"
$SYNC_HOST="192.168.13.24"

echo "HOST: $SYNC_HOST" | Out-File -Encoding utf8 $LOG_ADDRESS
echo "$DATETIME" | Out-File -Encoding utf8 -Append $LOG_ADDRESS
foreach($J in $TIMING_LIST){
	$SECOND_FOREACH=Get-ChildItem $BASEHOME$J$SUFFIX 
	#only one sync.log file,$SECOND_FOREACH.GetObjectData!=null.
	if( $SECOND_FOREACH.GetObjectData -ne $null){
		$RESULT=Get-Content $SECOND_FOREACH.fullname | Select-Object -Last 10 | select-string -Pattern "$((get-date).tostring('yyyy-MM-dd'))" -quiet 
			if($RESULT -eq $true){
				echo "$($SECOND_FOREACH.fullname): successful " | Out-File -Encoding utf8 -Append $LOG_ADDRESS
			}else{
				echo "$($SECOND_FOREACH.fullname): faiulre" | Out-File -Encoding utf8 -Append $LOG_ADDRESS
			}
	}
	else{
		foreach($i in 0..($second_foreach.length-1)){
			$result=get-content ${second_foreach}[$i].fullname | select-object -last 10 | select-string -pattern "$((get-date).tostring('yyyy-MM-dd'))" -quiet 

			if($result -eq $true){
				echo "$(${second_foreach}[${i}].fullname): successful " | out-file -encoding utf8 -append $log_address
			}else{
				echo "$(${second_foreach}[${i}].fullname): faiulre" | out-file -encoding utf8 -append $log_address
			}
		}
	}
}

