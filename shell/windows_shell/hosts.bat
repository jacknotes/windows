@echo off
echo "请注意你的杀毒软件提示，一定要允许"
@echo  ########################################
@xcopy C:\Windows\system32\drivers\etc\hosts C:\Windows\system32\drivers\etc\hosts.bak\ /d /c /i /y
@echo  ########################################
@echo  hosts文件备份完毕，开始修改hosts文件
@echo
@echo 192.168.13.207 passport.hs.com >>C:\Windows\System32\drivers\etc\hosts
@echo 192.168.13.207 tms.hs.com >>C:\Windows\System32\drivers\etc\hosts
@echo 192.168.13.207 erp.hs.com >>C:\Windows\System32\drivers\etc\hosts
@echo 192.168.13.207 operation.hs.com >>C:\Windows\System32\drivers\etc\hosts
@echo 192.168.13.207 intlflights.hs.com >>C:\Windows\System32\drivers\etc\hosts
@echo 192.168.13.207 cdn.hs.com >>C:\Windows\System32\drivers\etc\hosts
@echo 192.168.13.207 travel.hs.com >>C:\Windows\System32\drivers\etc\hosts
@echo 192.168.13.207 trains.hs.com >>C:\Windows\System32\drivers\etc\hosts
@echo 192.168.13.207 ticketproduct.hs.com >>C:\Windows\System32\drivers\etc\hosts
@echo 192.168.13.207 performance.hs.com >>C:\Windows\System32\drivers\etc\hosts
@echo 192.168.13.207 audit.hs.com >>C:\Windows\System32\drivers\etc\hosts
@echo 192.168.13.207 rpt.hs.com >>C:\Windows\System32\drivers\etc\hosts
@echo 192.168.13.207 metronic.hs.com >>C:\Windows\System32\drivers\etc\hosts
@echo 192.168.13.207 csms.hs.com >>C:\Windows\System32\drivers\etc\hosts
@echo 192.168.13.204 oa.hs.com >>C:\Windows\System32\drivers\etc\hosts
echo   "hosts文件修改完成"
@ipconfig /flushdns
@echo   "刷新DNS完成"
 

echo  hosts文件恢复完毕，按任意键退出
@echo
@pause > nul
@exit
