$backPath = $args[0] #backup folder path ex:d:\backup
$sourcePath = $args[1] #source folder ex:d:\somedir
$haoZipC="C:\Program Files\2345Soft\HaoZip\HaoZipC.exe"
$filename = Get-Date -Format "yyyyMMddhhmmssfff"
$filename +=  ".7z"
echo "backupPath:$backPath"
echo "start backup ..."

if(!(test-path $backPath)) { 
    $null = mkdir $backPath
}
& $haozipc a -r -t7z "$backPath\$filename" $sourcePath\*

echo "backup finished"