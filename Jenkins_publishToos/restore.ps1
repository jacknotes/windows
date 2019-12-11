$backupPath = $args[0] #backup folder path ex:d:\backup
$destinationPath = $args[1] #source folder ex:d:\somedir
$haoZipC="C:\Program Files\2345Soft\HaoZip\HaoZipC.exe"

function FindLatestBackupFile([String]$path)
{
    $LastBackup = dir $path | Where-Object {!$_.PSIsContainer} | Where-Object {$_.name -like "*.7z"} | Sort-Object {$_.LastWriteTime} -Descending | Select-Object -First 1
    $LatestBackupFilePath = $LastBackup.FullName
    return $LatestBackupFilePath
}

echo "start restore ..."

$fileName = FindLatestBackupFile $backupPath

echo "ready to restore the backup file $fileName"
echo "start to remove all files under $destinationPath"
if(test-path $destinationPath){
    $null = Remove-Item "$destinationPath\*" -recurse
}else{ $null = mkdir $destinationPath }
echo "restoring ..."
& $haoZipC x -r -y $fileName -"o$destinationPath"

echo "restore finished"