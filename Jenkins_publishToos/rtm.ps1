param(
    [string]$env = $(throw "Parameter missing -env"),
    [string]$sourcePath = $(throw "Parameter missing -sourcePath"),
    [string]$targetPath = $(throw "Parameter missing -targetPath"),
    [string]$backupPath = $(throw "Parameter missing -backupPath"),
    [string]$pubToolsPath = $(throw "Parameter missing -pubToolsPath"),
    [bool]$needBackup = $(throw "Parameter missing -needBackup")
)
$cmdBackup = $pubToolsPath + "\backup.ps1"

echo "source path is:$sourcePath"
echo "target path is:$targetPath"

if(!(test-path $sourcePath)) {
    write-host "there is wrong path for sourePath:$sourcePath"
    exit 1
}

echo "set up configGen..."
$configGen = "c:\DevTools\ConfigGen\ConfigGen.exe"
echo "configProfile: $repositoryName\$pubPath\ConfigProfile.xml"
if(test-path "$repositoryName\$pubPath\ConfigProfile.xml") { 
    echo "start gen configuration..."
    & $configGen -ge $ENV:WORKSPACE\$repositoryName\$pubPath $env
} else { echo "Configprofile.xml not found, ignore gen configuration..." }

if([bool]$needBackup -eq 1){
    & $cmdBackup $backupPath $targetPath
}
echo "LastExitCode is $LASTEXITCODE"
if($LASTEXITCODE -le 0){ 
    if(test-path $targetPath) {
        echo "delete all in the targetPath:$targetPath ..."
        del $targetPath\* -recurse
        echo "complete deleted all files in $targetPath"
    } else { mkdir $targetPath }

    echo "start to copy files from $sourcPath to $targetPath ..."
    xcopy $sourcePath $targetPath /y /e /exclude:d:\publish\publishTools\exclude.txt
    if(test-path $ENV:WORKSPACE\$repositoryName\$pubPath\__ConfigTemp\$env) { 
        echo "start to copy env files from $ENV:WORKSPACE\$repositoryName\$pubPath\__ConfigTemp\$env..."
        xcopy  $ENV:WORKSPACE\$repositoryName\$pubPath\__ConfigTemp\$env $targetPath /y /e /exclude:d:\publish\publishTools\exclude.txt
    } else { echo "skip copy configuration..." }    
        
    echo "All done!"
}