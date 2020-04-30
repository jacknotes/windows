#!/bin/bash
date=$(date +%Y-%m-%d-%H:%M:%S)   
logpath=/usr/local/nginx/logs
bkpath=$logpath/backup_logs
nginx_pid=/var/run/nginx.pid 
mkdir -p $bkpath

mv $logpath/access.log $bkpath/access-$date.log 
mv $logpath/error.log $bkpath/error-$date.log
kill -USR1 $(cat $nginx_pid) 

#clean old logs
find $bkpath/ -atime +90 -exec rm -f {} \;
