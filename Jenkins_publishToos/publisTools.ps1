echo "start init Git repositories ..."
if(test-path publishTools) { 
    cd .\publishTools
    echo "start pull publishTools from remote ..."
    git pull origin fat
    cd ..
}else{
    echo "start clone publishTools ..."
    git clone git@gitlab.hs.com:OPS/publishTools.git -b fat
}
if(test-path NugetPackages) {
    cd .\NugetPackages
    echo "start pull NugetPackages from remote ..." 
    git pull
    cd ..
}else{
    echo "start clone NugetPackages ..."
    git clone git@gitlab.hs.com:Public/DevNugetPackages.git NugetPackages
}
echo "git init completed"
echo "start delete ..."
if(test-path d:\publish\) {
    Remove-item d:\publish\* -Recurse -Force -Exclude nuget.exe
}else{
    mkdir d:\publish
}
xcopy * d:\publish /y /e