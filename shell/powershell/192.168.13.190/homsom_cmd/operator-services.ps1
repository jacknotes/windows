[cmdletbinding()]
param(
	[Parameter(Mandatory=$True,HelpMessage="running| stop | status")]
	[String]$TYPE
)


$SERVICE_NAME="TicketInbagService","酒店无消费账单轮询","HotelNoSaled","HomsomERPPollingService","InsuranceInputService","InsuranceOutService","IntInsuranceInputService","IntlInsuranceOutService","TMS自动轮询服务","TaskManager.WinService","Mub2gTktService"

function running(){
	foreach($i in $SERVICE_NAME){
		Set-Service -name $i -StartupType automatic
		Start-Service -name $i
	}
}

function stop(){
	foreach($i in $SERVICE_NAME){
		Set-Service -name $i -StartupType disabled
		Stop-Service -name $i
	}
}

function status(){
	foreach($i in $SERVICE_NAME){
		Get-Service -name $i
	}
}


. $($TYPE)