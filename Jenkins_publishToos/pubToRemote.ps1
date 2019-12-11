if(test-path $tmpPublishPath)
{       
    if(test-path $targetPath)
    {
        if([bool]$needBackup){
            & $cmdBackup $backupPath $targetPath
        }
        $null = Remove-Item "$targetPath\*" -recurse
    } else { mkdir $targetPath } 
    echo "targetPath is :$targetpath"
    echo "execute xcopy $tmpPublishPath\* $targetPath /y /e"
    
    xcopy $tmpPublishPath\* $targetPath /y /e
    
    echo "All done!"
} else {
    echo "there is nothing from Fat buiding, please buildToFAT first !"
    exit 1
}