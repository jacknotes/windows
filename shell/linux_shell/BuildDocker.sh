#!/bin/sh
#describe: .net core build docker and push private registory
#author: jackli
#datetime: 2020-05-20-21:16

#init variables
echo "init variables..........."
JobName=${JOB_NAME}
VersionFile='Version.txt'
ProjectName=
MirrorName=
TagName=
Username='jenkins'
Password='Homsom+4006'
Repository='192.168.13.235:8000'

info(){
	echo "---------Example Statement----------"
        echo "ProjectName:fat"
        echo "MirrorName:systemlog"
        echo "TagName:v1"
        echo "------------------------------------"
}

#change to workspace
cd /var/lib/jenkins/workspace/${JobName}

#check ${JobName}/${VersionFile} file
echo "check ${JobName}/${VersionFile} file legal......."
if [ -f $VersionFile ];then
	ProjectNameNum=$(grep -Ev '#|^$' $VersionFile | grep -i '^ProjectName' | wc -l)
	MirrorNameNum=$(grep -Ev '#|^$' $VersionFile | grep -i '^MirrorName' | wc -l)
	TagNameNum=$(grep -Ev '#|^$' $VersionFile | grep -i '^TagName' | wc -l)
	num=$((${ProjectNameNum}+${MirrorNameNum}+${TagNameNum}))
	if [ $num -gt 3 ];then
		echo "ERROR: $VersionFile only allow have one ProjectName,MirrorName,TagName"	
		info
		exit 2
	else
		ProjectName=$(grep -Ev '#|^$' $VersionFile | awk '{sub(/^[[:blank:]]*/,"",$0);sub(/[[:blank:]]*$/,"",$0);gsub(/[[:blank:]]*/,"",$0);print $0}' | grep -i '^ProjectName' | awk -F : '{print $2}')
		[ -z $ProjectName ] && echo "Error: ProjectName value is null" && info && exit 2
		MirrorName=$(grep -Ev '#|^$' $VersionFile | awk '{sub(/^[[:blank:]]*/,"",$0);sub(/[[:blank:]]*$/,"",$0);gsub(/[[:blank:]]*/,"",$0);print $0}' | grep -i '^MirrorName' | awk -F : '{print $2}')
		[ -z $MirrorName ] && echo "Error: MirrorName value is null" && info && exit 2
		TagName=$(grep -Ev '#|^$' $VersionFile | awk '{sub(/^[[:blank:]]*/,"",$0);sub(/[[:blank:]]*$/,"",$0);gsub(/[[:blank:]]*/,"",$0);print $0}' | grep -i '^TagName' | awk -F : '{print $2}')
		[ -z $TagName ] && echo "Error: TagName value is null" && info && exit 2
	fi
else
	echo "Error: ${ProjectName}/${VersionFile} file does not exist"
	info
	exit 2;
fi

#build docker image
echo "build image ${ProjectName}/${MirrorName}:${TagName}........"
sudo docker build -t ${ProjectName}/${MirrorName}:${TagName} . 
if [ $? == 0 ];then
	echo "INFO: Docker Build Image Succeed" 
else
	echo "ERROR: Docker Build Image Failure" 
	exit 6
fi

#login private repository
echo "login ${Repository}........."
sudo docker login -u ${Username} -p ${Password} ${Repository} 
if [ $? == 0 ];then
	echo "INFO: Login Succeed"
else
	echo "ERROR: Login Failure"
	exit 6
fi

#tag image 
echo "tag image ${ProjectName}/${MirrorName}:${TagName} to ${Repository}/${ProjectName}/${MirrorName}:${TagName}........"
sudo docker tag ${ProjectName}/${MirrorName}:${TagName} ${Repository}/${ProjectName}/${MirrorName}:${TagName} 
if [ $? == 0 ];then
	echo "INFO: Tag Image Succeed" 
else
	echo "ERROR: Tag Image Failure" 
	exit 6
fi

#push local image to remote repository
echo "push local image ${Repository}/${ProjectName}/${MirrorName}:${TagName} to remote repository ${Repository}......."
sudo docker push ${Repository}/${ProjectName}/${MirrorName}:${TagName} 
if [ $? == 0 ];then
	echo "INFO: Push ${Repository}/${ProjectName}/${MirrorName}:${TagName} Image To Remote Repository Succeed" 
else
	echo "ERROR: Push ${Repository}/${ProjectName}/${MirrorName}:${TagName} Image To Romote Repository Failure" 
	exit 6
fi

#logout private repository
echo "logout ${Repository}........."
sudo docker logout ${Repository} 
if [ $? == 0 ];then
	echo "INFO: Logout Succeed" 
else
	echo "ERROR: Logout Failure" 
	exit 6
fi

#delete local build and push image
echo "delete local image ${ProjectName}/${MirrorName}:${TagName} and ${Repository}/${ProjectName}/${MirrorName}:${TagName}........"
sudo docker image rm ${ProjectName}/${MirrorName}:${TagName} ${Repository}/${ProjectName}/${MirrorName}:${TagName} 
if [ $? == 0 ];then
	echo "INFO: Local Image ${ProjectName}/${MirrorName}:${TagName} ${Repository}/${ProjectName}/${MirrorName}:${TagName} Delete Succeed" 
else
	echo "ERROR: Local Image ${ProjectName}/${MirrorName}:${TagName} ${Repository}/${ProjectName}/${MirrorName}:${TagName} Delete Failure" 
	exit 6
fi

#delete local name is <none> image
NoNameImage=$(sudo docker image ls | grep '<none>' | awk '{print $3}') #if not delete name is <none> image,annotation can be. 
for i in ${NoNameImage};do
	echo "delete local not name image $i ........."
	sudo docker image rm $i 
	if [ $? == 0 ];then
		echo "INFO: Local not name Image ${i} Delete Succeed" 
	else
		echo "ERROR: Local not name Image ${i} Delete Failure" 
		exit 6
	fi
done
