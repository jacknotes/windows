[cmdletbinding()]
param(
    [Parameter(Mandatory=$True,HelpMessage="Input Source Directory or file")]
    [Alias('SDIR')]
    [string]$SUNC=$(throw "Source Directory or file is NULL"),

    [Parameter(Mandatory=$True,HelpMessage="Input Destination Directory")]
    [Alias('DDIR')]
    [string]$DUNC=$(throw "Destination Directory is NULL"),

    [Parameter(Mandatory=$True,HelpMessage="Input Copy Type (dir | file)")]
    [Alias('TYPE')]
    [string]$CTYPE=$(throw "Type (dir | file) is NULL")
)
$LOGDIR="$DUNC\log"
$LOGFILE="$LOGDIR\log"
$DATEYEAR=(get-date).Year
$DATEMONTH=(get-date).Month
$DATEDAY=(get-date).Day
$DATE="$DATEYEAR"+"$DATEMONTH"+"$DATEDAY"

if((Get-Item $SUNC) -is [IO.DIRECTORYInfo]){$DIRNAME=$SUNC}
elseif((Get-Item $SUNC) -is [IO.FileInfo]){$DIRNAME=Split-Path $SUNC}

if((Get-Item $SUNC) -is [IO.DIRECTORYInfo]){$BASENAME="*"}
elseif((Get-Item $SUNC) -is [IO.FileInfo]){$BASENAME=Split-Path $SUNC -Leaf -Resolve}

#test path is exists.
if (-not (Test-Path $SUNC)){
    echo "source $nc path not exists"
    exit 1
}
if (!(Test-Path $DUNC)){
    echo "destination $nc path not exists"
    exit 1
}

#create log dir
New-Item -ItemType "directory" -Path "$LOGDIR" -Force > $null

#echo datetime to logfile
echo "BEGIN" >> "$LOGFILE$DATE.txt"
(Get-Date).ToString() >> "$LOGFILE$DATE.txt"

if($CTYPE -eq "dir" -and (Get-Item $SUNC) -is [IO.DIRECTORYInfo]){
	xcopy $SUNC $DUNC /h/e/c/i/d/r/y/k/f | Out-File -Append "$LOGFILE$DATE.txt"
	if ($?){
        echo "RESULT: Copy $DIRNAME\* To $DUNC Successful" ;
        echo "RESULT: Copy $DIRNAME\* To $DUNC Successful" >> "$LOGFILE$DATE.txt"
    }else{
        echo "RESULT: Copy $DIRNAME\* To $DUNC Failure";
        echo "RESULT: Copy $DIRNAME\* To $DUNC Failure" >> "$LOGFILE$DATE.txt"
	(Get-Date).ToString() >> "$LOGFILE$DATE.txt"
	echo "END" >> "$LOGFILE$DATE.txt"
	echo "" >> "$LOGFILE$DATE.txt"
	exit 1
    }
}elseif($CTYPE -eq "file" -and (Get-Item $SUNC) -is [IO.FileInfo]){
	xcopy $SUNC $DUNC /h/d/y/k/f | Out-File -Append "$LOGFILE$DATE.txt"
	if ($?){
        echo "RESULT: Copy $DIRNAME\\$BASENAME To $DUNC Successful" ;
        echo "RESULT: Copy $DIRNAME\\$BASENAME To $DUNC Successful" >> "$LOGFILE$DATE.txt"
    }else{
        echo "RESULT: Copy $DIRNAME\\$BASENAME To $DUNC Failure";
        echo "RESULT: Copy $DIRNAME\\$BASENAME To $DUNC Failure" >> "$LOGFILE$DATE.txt"
	(Get-Date).ToString() >> "$LOGFILE$DATE.txt"
	echo "END" >> "$LOGFILE$DATE.txt"
	echo "" >> "$LOGFILE$DATE.txt"
	exit 1
    }
}else {
    echo "RESULT: source file and type is no match";
    echo "RESULT: source file and type is no match" >> "$LOGFILE$DATE.txt";
    echo "END" >> "$LOGFILE$DATE.txt";
    echo "" >> "$LOGFILE$DATE.txt";exit 1
}

(Get-Date).ToString() >> "$LOGFILE$DATE.txt"
echo "END" >> "$LOGFILE$DATE.txt"
echo "" >> "$LOGFILE$DATE.txt"



