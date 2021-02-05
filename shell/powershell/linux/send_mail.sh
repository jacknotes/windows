#!/bin/sh
#1. windows list schtasks.time:8:00
#2. linux format to unix file.time:8:05
#3. windows append utf8 text file to process unix file.time:8:10
#4. other timing task insert to process unix file.8:06----8:29
#5. send mail of this shell file,time:08:30 and 15:30

SCHTASKS_LIST="/windows/192.168.13.190/schtasks.log /windows/192.168.13.182/sync.log /windows/172.168.2.186/sync.log /windows/192.168.13.24/sync.log"
JOB_FILE="/tmp/job.txt"

for i in ${SCHTASKS_LIST};do
	dos2unix ${SCHTASKS_LIST} >& /dev/null
	cat $i >> ${JOB_FILE}
	echo "" >> ${JOB_FILE}
done

#send mail
cat ${JOB_FILE} | mail -s "everyday check" jack.li@homsom.com
[ $? == 0 ] && rm -rf ${JOB_FILE}
