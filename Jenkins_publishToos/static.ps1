$repositoryName = $args[0] # git repository url
$repositoryUrl = $args[1] # git repository url
$slnFile = $args[2] # sln pant + name without workspace & jobname . ex: file\path\ex.sln
$pubPath = $args[3] # the folder which you want to publish (website ,service, api etc.) ex:Homsom.Business.WebAPI\Homsom.Business.CustomerService
$docFileName = $args[4] #doc file name if exsits

$templateName = "d:\publish\publishTools\config\template.pubxml"
$backupPath = $ENV:BackupPath + "\" + $repositoryName
$pubToolsPath = "d:\publish\publishTools"
$cmdPublish = $pubToolsPath + "\publish.ps1"
$cmdBackup = $pubToolsPath + "\backup.ps1"
$cmdRestore = $pubToolsPath + "\restore.ps1"
$cmdRTM = $pubToolsPath + "\rtm.ps1"
$cmdReplaceProfile = $pubToolsPath + "\replaceProfile.ps1"
$tmpPublishPath = $ENV:WORKSPACE + "\" + "publishFiles"
$needBackup = $ENV:IgnoreBackup -ne 'true'
$branch = $ENV:Branch

echo "start init ..."
if (![string]::IsNullOrEmpty($targetPath)) { $ENV:ProdPath = $targetPath }
if ([string]::IsNullOrEmpty($branch)) { $branch="release" }

echo "###### start display all params ######"
echo "repositoryName:$repositoryName"
echo "repositoryUrl:$repositoryUrl"
echo "slnFile:$slnFile"
echo "pubPath:$pubPath"
echo "backupPath:$backupPath"
echo "templateName:$templateName"
echo "docFileName:$docFileName"
echo "###### end display all params ######"

echo "current publish type is $ENV:PublishType"

switch($ENV:PublishType)
{
    "publishToProduction" {
        if ($ENV:publishPassword -eq "homsom+4006123123")
        { 
            cd Homsom.TMS.Client\Homsom.TMS.Client.CDN\Homsom.TMS.Client.CDN.WebSite
            npm run release
            echo "start copay files..."
            xcopy .\dist $ENV:WORKSPACE\publishFiles\dist /y /e        
            echo "start publish ..."
            $targetPath = $ENV:ProdPath
            & $cmdRTM prd $tmpPublishPath $targetPath $backupPath $pubToolsPath $needBackup
        } else { 
            echo "wrong password !" 
            exit 1
        }
    }
    "backupProduction" {
        if ($ENV:publishPassword -eq "homsom+4006123123")
        { 
            $targetPath = $ENV:ProdPath    
            & $cmdBackup $backupPath $targetPath
        }
    }
    "rollbackProduction" {
        if ($ENV:publishPassword -eq "homsom+4006123123")
        {     
            $targetPath = $ENV:ProdPath    
            & $cmdRestore $backupPath $targetPath
        }
    }
    "buildToFAT" {
	echo "===== start package ====="
	cd Homsom.TMS.Client\Homsom.TMS.Client.CDN\Homsom.TMS.Client.CDN.WebSite
	cnpm i
	npm run release
    npm run scss:fat
	$publishPatch = $ENV:WORKSPACE.Substring(0,$ENV:WORKSPACE.length-1) + "\publishFiles"
	echo "evn Path is $publishPatch"
        $targetPath = $ENV:FatPath
	if(test-path $publishPatch)
    {
		echo "Starte delete $publishPatch..."
		$null = Remove-Item $publishPatch -recurse -force
	}
    echo "start copay files..."
	mkdir "$ENV:WORKSPACE\publishFiles\res"
    mkdir "$ENV:WORKSPACE\publishFiles\dist"
    mkdir "$ENV:WORKSPACE\publishFiles\Scripts"
    copy Web.Config $ENV:WORKSPACE\publishFiles
	xcopy .\res $ENV:WORKSPACE\publishFiles\res /y /e
	xcopy .\Scripts $ENV:WORKSPACE\publishFiles\Scripts /y /e
	xcopy .\dist $ENV:WORKSPACE\publishFiles\dist /y /e
	& $cmdRTM fat $tmpPublishPath $targetPath $backupPath $pubToolsPath 0
    }
    "publishToUAT" {
        $targetPath = $ENV:UatPath
        cd Homsom.TMS.Client\Homsom.TMS.Client.CDN\Homsom.TMS.Client.CDN.WebSite
        npm run scss:uat
        echo "start copay files..."
        xcopy .\dist $ENV:WORKSPACE\publishFiles\dist /y /e
        & $cmdRTM uat $tmpPublishPath $targetPath $backupPath $pubToolsPath 0
    }
}

echo "finished selected task"