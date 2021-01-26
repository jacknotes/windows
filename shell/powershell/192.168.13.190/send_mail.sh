#!/bin/sh

cp /windows/192.168.13.190/schtasks.log /tmp/schtasks.log
dos2unix /tmp/schtasks.log >& /dev/null
cat /tmp/schtasks.log | mail -s "roundrobin job status" jack.li@mail.com
