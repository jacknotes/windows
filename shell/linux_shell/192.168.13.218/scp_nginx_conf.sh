#/bin/bash
#
#Description: scp nginx.conf in VIP to BackupServer 
#
CVIP=`/sbin/ip add show  | grep 207 | awk '{print $2}' | awk -F '/' '{print $1}'`
VIP="192.168.13.207"
BIP="192.168.13.215"  #proxy1
CPDATE=$(date +%Y-%m-%d-%H:%M:%S)

if [[ $CVIP = ${VIP} ]];then 
  logger "scp nginx.conf in $VIP to BackupServer $BIP"
  /bin/mkdir -p /backup
  /bin/cp -a /usr/local/nginx/conf/nginx.conf /backup/nginx.conf-$CPDATE
  /usr/bin/scp /usr/local/nginx/conf/nginx.conf $BIP:/usr/local/nginx/conf/ &> /dev/null
  [ $? -eq 0 ] && logger "scp to BackupServer $BIP successful" || logger "scp to BackupServer $BIP failure"
else 
  logger "this host without $VIP,stop scp"
fi


