$SHELL_HOME="D:\powershell"
$REMOTE_SHARE_WEBDIR="\\192.168.13.229\d$\ProductWeb"
$LOCAL_WEBDIR="D:\ProductWeb13_229"
$CTYPE="dir"

New-Item -ItemType "directory" -Path "$LOCAL_WEBDIR" -Force > $null
if($?){
    echo "start from $REMOTE_SHARE_WEBDIR copy to $LOCAL_WEBDIR"
    & $SHELL_HOME\xcopy.ps1 -SUNC $REMOTE_SHARE_WEBDIR -DUNC $LOCAL_WEBDIR -CTYPE $CTYPE
    if($?){
	echo "copy Successful,copy end."
    }
    else{
	echo "copy Failure!!!"
    }
}else{
    echo "create directory $LOCAL_WEBDIR Failure!!!"
}