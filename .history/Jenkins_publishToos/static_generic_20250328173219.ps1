$pubPath = $args[0] # the folder which you want to publish (website ,service, api etc.) ex:Homsom.Business.WebAPI\Homsom.Business.CustomerService
$repositoryName = $ENV:JOB_NAME

$backupPath = $ENV:BackupPath + "\" + $repositoryName
$pubToolsPath = "d:\publish\publishTools"
$cmdBackup = $pubToolsPath + "\backup.ps1"
$cmdRestore = $pubToolsPath + "\restore.ps1"
$cmdRTM = $pubToolsPath + "\rtm.ps1"
$tmpPublishPath = $ENV:WORKSPACE + "\" + "publishFiles"
$needBackup = $ENV:IgnoreBackup -ne 'true'
$branch = $ENV:Branch

echo "start init ..."
if (![string]::IsNullOrEmpty($targetPath)) { $ENV:ProdPath = $targetPath }
if ([string]::IsNullOrEmpty($branch)) { $branch="release" }

echo "###### start display all params ######"
echo "repositoryName:$repositoryName"
echo "backupPath:$backupPath"
echo "pubPath:$pubPath"
echo "targetPath:$targetPath"
echo "###### end display all params ######"

echo "current publish type is $ENV:PublishType"

switch($ENV:PublishType)
{
    "publishToProduction" {
        if ($ENV:publishPassword -eq "123456")
        { 
            $targetPath = $ENV:ProdPath
            echo "start copay files..."
            & $cmdRTM prd $tmpPublishPath $targetPath $backupPath $pubToolsPath $needBackup
        } else { 
            echo "wrong password !" 
            exit 1
        }
    }
    "backupProduction" {
        if ($ENV:publishPassword -eq "123456")
        { 
            $targetPath = $ENV:ProdPath    
            & $cmdBackup $backupPath $targetPath
        }
    }
    "rollbackProduction" {
        if ($ENV:publishPassword -eq "123456")
        {     
            $targetPath = $ENV:ProdPath    
            & $cmdRestore $backupPath $targetPath
        }
    }
    "buildToFAT" {
	    echo "===== start package ====="
     	if(test-path "publishFiles")
        {
    		echo "Starte delete $ENV:WORKSPACE\publishFiles..."
    		$null = Remove-Item publishFiles -recurse -force
    	}          
        cd $pubPath
    	cnpm i
    	npm run release
        $targetPath = $ENV:FatPath        
        echo "start copay files..."
        mkdir "$ENV:WORKSPACE\publishFiles"
        xcopy .\dist\* $ENV:WORKSPACE\publishFiles /y /e
        & $cmdRTM fat $tmpPublishPath $targetPath $backupPath $pubToolsPath 0        
    }
    "publishToUAT" {
        $targetPath = $ENV:UatPath
        & $cmdRTM uat $tmpPublishPath $targetPath $backupPath $pubToolsPath 0
    }
}

echo "finished selected task"