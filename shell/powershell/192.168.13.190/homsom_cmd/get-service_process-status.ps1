$DATETIME=(Get-Date).ToString('yyyy-MM-dd-HH:mm:ss')
$LOG_ADDRESS="\\192.168.13.182\HomsomAuto\192.168.13.190\schtasks.log"

#services status
$SERVICES=Get-Content E:\homsom_cmd\roundrobin_services-displayname.txt

echo "$DATETIME" | Out-File -Encoding utf8 -Append $LOG_ADDRESS
foreach($i in $SERVICES){
	$RESULT=(Get-Service -name "$i").Status 
	if($RESULT -eq "Running"){
		echo "SERVICE: $i is running" | Out-File -Encoding utf8 -Append $LOG_ADDRESS
	}else{
		echo "SERVICE: $i is no running" | Out-File -Encoding utf8 -Append $LOG_ADDRESS
	}
}


#process status
$CUSTOM_PROCESS="Homsom.Hotel.ConsoleApp.CtripOrderHandle"

Get-Process $CUSTOM_PROCESS > $null
if($? -eq $true){
	echo $DATETIME`n"PROCESS: $CUSTOM_PROCESS is running." | Out-File -Encoding utf8 -Append $LOG_ADDRESS
}else{
	echo $DATETIME`n"PROCESS: $CUSTOM_PROCESS is no running." | Out-File -Encoding utf8 -Append $LOG_ADDRESS
}