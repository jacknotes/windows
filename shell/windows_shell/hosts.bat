@echo off
echo "��ע�����ɱ�������ʾ��һ��Ҫ����"
@echo  ########################################
@xcopy C:\Windows\system32\drivers\etc\hosts C:\Windows\system32\drivers\etc\hosts.bak\ /d /c /i /y
@echo  ########################################
@echo  hosts�ļ�������ϣ���ʼ�޸�hosts�ļ�
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
echo   "hosts�ļ��޸����"
@ipconfig /flushdns
@echo   "ˢ��DNS���"
 

echo  hosts�ļ��ָ���ϣ���������˳�
@echo
@pause > nul
@exit
