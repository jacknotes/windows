[cmdletbinding()]
param(
	[Parameter(Mandatory=$True,HelpMessage="running| stop | status")]
	[String]$TYPE
)


$SERVICE_NAME="TicketInbagService","�Ƶ��������˵���ѯ","HotelNoSaled","HomsomERPPollingService","InsuranceInputService","InsuranceOutService","IntInsuranceInputService","IntlInsuranceOutService","TMS�Զ���ѯ����","TaskManager.WinService","Mub2gTktService"

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