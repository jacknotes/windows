#!/bin/sh
SCHTACK_HOST="192.168.13.190"
TASK_HOME="/windows/${SCHTACK_HOST}"
SCHTASKS_FILE="$TASK_HOME/schtasks.txt"
SCHTASIS_FILE_HANDLER="$TASK_HOME/schtasks_handler.txt"
SCHTASKS_LOGS="$TASK_HOME/schtasks.log" 
LOGFILE="/tmp/taskslog.err"

echo "HOST: ${SCHTACK_HOST}" > $SCHTASKS_LOGS
echo "`date +'%Y-%m-%d-%T'`" >> $SCHTASKS_LOGS 
[ $? == 0 ] && /usr/bin/dos2unix $SCHTASKS_FILE >& /dev/null || echo "`date`: ${SCHTASKS_LOGS} is deny access" >>${LOGFILE}
if [ $? == 0 ];then
	/usr/bin/sed -n '/Folder: \\$/,/Folder: \\Microsoft$/{/Folder: \\Microsoft$/b;p}' $SCHTASKS_FILE > $SCHTASIS_FILE_HANDLER
else
	echo 'Translation Format Dos2unix Failure!' >> $SCHTASKS_LOGS 
fi

COUNT=`grep 'Last Result:' $SCHTASIS_FILE_HANDLER | wc -l`
RESULT01=`grep 'Last Result:' $SCHTASIS_FILE_HANDLER | awk -F ':' '{print $2}' | egrep '[[:space:]].*0$' | wc -l`
RESULT02=`grep "Status" $SCHTASIS_FILE_HANDLER | grep "Running" | wc -l`
RESULT_COUNT=`echo "${RESULT01}+${RESULT02}" | bc`
if [ $RESULT_COUNT -eq $COUNT ];then
	echo 'scheduler task running successful!' >> $SCHTASKS_LOGS
else
	echo 'scheduler task running failure!' >> $SCHTASKS_LOGS
fi
