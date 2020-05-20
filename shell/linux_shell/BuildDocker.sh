#!/bin/sh
#describe: .net core build docker and push private registory
#author: jackli
#datetime: 2020-05-20-21:16

#init variables
echo "init variables..........."
ProjectName=${JOB_NAME}
VersionFile='tag.txt'
MirrorName=
Tag=
Username='admin'
Password='password'
Repository='192.168.13.21:5000'

#change to workspace
cd /var/lib/jenkins/workspace/${ProjectName}

#judgment MirrorName and Tag is legal
echo "judgment MirrorName and Tag is legal......."
if [ -f $VersionFile ];then
	MirrorName_LineNum=$(grep -Ev '#|^$' $VersionFile | wc -l)
	[ $MirrorName_LineNum -gt 1 ] && echo "Error: MirrorName greater than 1,INFO: only allow 1 Mirror Name and Tag,Example mirror_name:version_name" && exit 2
	MirrorName=$(grep -v '#' $VersionFile | awk -F ':' '{print $1'})
	[ -z $MirrorName ] && echo "Error: MirrorName is null,INFO: MirrorName and Tag must all exist,Example mirror_name:version_nam " && exit 2
	Tag=$(grep -v '#' $VersionFile | awk  -F ':' '{print $2}')
	[ -z $Tag ] && echo "Error: Tag is null,INFO: MirrorName and Tag must all exist,Example mirror_name:version_nam" && exit 2
	echo "MirrorName and Tag is legal"
else
	echo "Error: /var/lib/jenkins/workspace/${ProjectName}/${VersionFile} file does not exist,Content Example mirror_name:version_nam"
	exit 2;
fi

#build docker image
echo "build image ${MirrorName}:${Tag}........"
sudo docker build -t ${MirrorName}:${Tag} . && echo "INFO: Docker Build Image Succeed" || (echo "ERROR: Docker Build Image Failure" && exit 6)

#login private repository
echo "login ${Repository}........."
sudo docker login -u ${Username} -p ${Password} ${Repository} && echo "INFO: Login Succeed" || (echo "ERROR: Login Failure" && exit 6)

#tag image 
echo "tag image ${MirrorName}:${Tag} to ${Repository}/${MirrorName}:${Tag}........"
sudo docker tag ${MirrorName}:${Tag} ${Repository}/${MirrorName}:${Tag} && echo "INFO: Tag Image Succeed" || (echo "ERROR: Tag Image Failure" && exit 6)

#push local image to remote repository
echo "push local image ${Repository}/${MirrorName}:${Tag} to remote repository ${Repository}......."
sudo docker push ${Repository}/${MirrorName}:${Tag} && echo "INFO: Push ${Repository}/${MirrorName}:${Tag} Image To Remote Repository Succeed" || (echo "ERROR: Push ${Repository}/${MirrorName}:${Tag} Image To Romote Repository Failure" && exit 6)

#logout private repository
echo "logout ${Repository}........."
sudo docker logout ${Repository} && echo "INFO: Logout Succeed" || (echo "ERROR: Logout Failure" && exit 6)

#delete local build and push image
echo "delete local image ${MirrorName}:${Tag} and ${Repository}/${MirrorName}:${Tag}........"
sudo docker image rm ${MirrorName}:${Tag} ${Repository}/${MirrorName}:${Tag} && echo "INFO: Local Image ${MirrorName}:${Tag} ${Repository}/${MirrorName}:${Tag} Delete Succeed" || (echo "ERROR: Local Image ${MirrorName}:${Tag} ${Repository}/${MirrorName}:${Tag} Delete Failure" && exit 6)

#delete local name is <none> image
NoNameImage=$(sudo docker image ls | grep '<none>' | awk '{print $3}') #if not delete name is <none> image,annotation can be. 
for i in ${NoNameImage};do
	echo "delete local not name image $i ........."
	sudo docker image rm $i && echo "INFO: Local not name Image ${i} Delete Succeed" || (echo "ERROR: Local not name Image ${i} Delete Failure" && exit 6)
done
