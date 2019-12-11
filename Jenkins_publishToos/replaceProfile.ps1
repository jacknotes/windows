$templateName = $args[0]
$pubPath = $args[1]
$target = $args[2]

echo "start replace profile ..."
$filename = $pubConfigToolsPath + $templateName 
$originfilename = $filename -replace ".*\\",""
$outfilepath = $ENV:WORKSPACE + "\" + $repositoryName + "\" + $pubPath + "\Properties\PublishProfiles\"
$outfilename = $ENV:WORKSPACE + "\" + $repositoryName + "\" + $pubPath + "\Properties\PublishProfiles\" + $originfilename
echo "profile out path: $outfilename"

$file = Get-Item $filename
$content = Get-Content $file
if(!(test-path outfilepath)) { 
   $null = mkdir $outfilepath
}

$content -replace "{publishUrl}",$target | Out-File -Encoding utf8 $outfilename