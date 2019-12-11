$branch = $args[0] # branch name
$repositoryName = $args[1] # git repository name
$repositoryUrl = $args[2] # git repository url
$slnFile = $args[3] # sln pant + name without workspace & jobname . ex: file\path\ex.sln
$pubPath = $args[4] # the folder which you want to publish (website ,service, api etc.) ex:Homsom.Business.WebAPI\Homsom.Business.CustomerService
$templateName = $args[5]
$targetPath = $args[6] # the pub target folder
$docFileName = $args[7] #doc file name if exsits
$libBranch = $args[8] # libs branch name
$forceClone = $ENV:ForceClone -eq 'true'

echo "forceClone:" + $forceClone
echo "set up msbuild ..."
$msbuild = "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\msbuild.exe"
echo "set nuget ..."
$nuget = "D:\publish\publishTools\nuget.exe"
echo "init Git Repository ..."
if(test-path CommonLibs) { 
    cd .\CommonLibs
    $currLibBranch= &git rev-parse --abbrev-ref HEAD
    if( $libBranch -eq $currLibBranch -and $forceClone -ne 'false'){
        try{
            echo "start pull..."
            git pull origin $libBranch
            cd ..
        } catch {
            $null = Remove-Item * -recurse -force
            cd ..
            echo "failed to pull and start clone new commonLibs"
            git clone -b $libBranch git@gitlab.hs.com:Homsom/CommonLibs.git
        }
    } else {
        $null = Remove-Item * -recurse -force
        cd ..
        echo "start clone new commonLibs"
        git clone -b $libBranch git@gitlab.hs.com:Homsom/CommonLibs.git
    }    
} else { 
    git clone -b $libBranch git@gitlab.hs.com:Homsom/CommonLibs.git 
}
if(test-path Packages) { 
    cd .\Packages
    git pull origin release
    cd ..
} else { git clone -b release git@gitlab.hs.com:Arch/Packages.git }

echo "branch:" + $branch
echo "repositoryUrl:" + $repositoryUrl
echo "repositoryName:" + $repositoryName

try{
    if(test-path $repositoryName) { 
        cd .\$repositoryName
        $currBranch= &git rev-parse --abbrev-ref HEAD
        if( $Branch -eq $currBranch -and $forceClone -ne 'false'){
            try{
                echo "start pull..."
                git pull origin $branch
                cd ..
            } catch {
                cd ..
                $null = Remove-Item "$repositoryName\*" -recurse -force
                echo "failed to pull and start clone new repository"
                git clone -b $branch $repositoryUrl $repositoryName
            }
        } else {
            cd ..
            $null = Remove-Item "$repositoryName\*" -recurse -force
            echo "start clone new repository"
            git clone -b $branch $repositoryUrl $repositoryName
        }    
    } else { 
        echo "start clone ..."
        git clone -b $branch $repositoryUrl $repositoryName 
    }
}catch{
    write-host "Caught an exception"
    exit 1
}

echo "start restore nuget packages ..."
echo "sln path: " + $env:job_name\$slnFile
& $nuget restore .\$repositoryName\$slnFile -configfile "d:\publish\publishTools\config\nuget.config"
echo "pubProfileName regx: " + $templateName
& $cmdReplaceProfile $templateName $pubPath $tmpPublishPath
$templateName -match "(?<=\\{0,1})[a-zA-Z]*(?=\.pubxml)"
$templateName = $matches[0]

echo "start msbuild ..."
if(![String]::IsNullOrEmpty($docFileName)) {
   & $msbuild $repositoryName\$slnFile /t:rebuild /p:configuration=release /p:documentationfile=$docFileName
}else{
   & $msbuild $repositoryName\$slnFile /t:rebuild /p:configuration=release 
}
if(test-path $tmpPublishPath)
{
    $null = Remove-Item "$tmpPublishPath\*" -recurse
} else { mkdir $tmpPublishPath }
& $msbuild (get-item $repositoryName\$pubPath\*.csproj).fullname /t:rebuild /p:configuration=release /p:publishProfile=$templateName /p:deployOnBuild=true
if($LASTEXITCODE -le 0){ 
    xcopy $repositoryName\$pubPath\bin\* $tmpPublishPath\bin\ /y /e /exclude:d:\publish\publishTools\config\exclude.txt 
    echo $docFileName

    if(![String]::IsNullOrEmpty($docFileName)) {
        echo "start to gernate doc file"
        xcopy $repositoryName\$pubPath\$docFileName $tmpPublishPath\bin\ /y /e
    }
    
    echo "final targetPath is :$targetpath"
    echo "execute xcopy $tmpPublishPath\* $targetPath /y /e"
    
    # & $cmdRTM $tmpPublishPath $targetPath $backupPath $pubToolsPath 0
    
    echo "All done!"
}else{
    write-host "Caught an exception"
    exit 1
}