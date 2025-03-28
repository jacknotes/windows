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
$libBranch = $ENV:LibBranch

echo "start init ..."
if (![string]::IsNullOrEmpty($targetPath)) { $ENV:ProdPath = $targetPath }
if ([string]::IsNullOrEmpty($branch)) { $branch="release" }
if ([string]::IsNullOrEmpty($libBranch)) { $libBranch="release" }

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
        $targetPath = $ENV:FatPath
        echo "start publish ..."
        & $cmdPublish $branch $repositoryName $repositoryUrl $slnFile $pubPath $templateName $targetPath $docFileName $libBranch
        echo "start copay files..."
        if($LASTEXITCODE -le 0){
            & $cmdRTM fat $tmpPublishPath $targetPath $backupPath $pubToolsPath 0
        }
    }
    "publishToUAT" {
        $targetPath = $ENV:UatPath
        & $cmdRTM uat $tmpPublishPath $targetPath $backupPath $pubToolsPath 0
    }
}

echo "finished selected task"