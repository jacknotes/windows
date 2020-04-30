@echo off
cls

rem ������������
set "nic=interface"
rem ��̬ IP ��ַ
set "ip=172.168.2.219"
set "governmentIP=192.168.20.21"
rem ��������
set "subnetMask=255.255.255.0"
rem Ĭ������
set "defaultGateway=172.168.2.254"
set "governmentDefaultGateway=192.168.20.1"
rem ��ѡ DNS ������
set "dns=192.168.10.250"
rem ���� DNS ������
set "dns2=8.8.8.8"
rem ���IP��ַ
set "ip1=172.168.7.11"
set "ip2=172.168.7.12"
set "ip3=172.168.7.13"
set "ip4=172.168.7.14"

:start
echo [1] ���ù�˾���� IP
echo [2] ������������ IP
echo [3] ����� IP ��ַ��DHCP��
echo [4] ��Ӷ��ip��ַ
echo [5] ֱ���˳�
set choice=
set /p choice=�������ţ������س�������:
if "%choice%"=="1" goto setStaticIP
if "%choice%"=="2" goto setGovernmentStaticIP
if "%choice%"=="3" goto setDHCP
if "%choice%"=="4" goto addsIP
if "%choice%"=="5" goto end
echo "%choice%" ����Ч�ģ�����������
echo.
goto start

:setStaticIP
rem ������������ ��̬ IP ��ַ �������� Ĭ������
netsh interface ipv4 set address name=%nic% static %ip% %subnetMask% %defaultGateway%
netsh interface ipv4 delete dnsservers name="%nic%" all
netsh interface ipv4 add dnsservers name=%nic% addr=%dns% 
netsh interface ipv4 add dnsservers name=%nic% addr=%dns2% index=2 
goto end

:setGovernmentStaticIP
rem ������������ ��̬ IP ��ַ �������� Ĭ������
netsh interface ipv4 set address name=%nic% static %governmentIP% %subnetMask% %governmentDefaultGateway%
netsh interface ipv4 delete dnsservers name="%nic%" all
netsh interface ipv4 add dnsservers name=%nic% addr=%dns% 
netsh interface ipv4 add dnsservers name=%nic% addr=%dns2% index=2 
goto end

:setDHCP
rem �Զ��� DHCP ��������ȡ IP ��ַ
netsh interface ipv4 set address name=%nic% dhcp
netsh interface ipv4 set dnsservers name=%nic% dhcp
goto end

:addsIP
rem ��Ӷ��ip��ַ
netsh interface ipv4 set address name=%nic% static %ip% %subnetMask% %defaultGateway%
netsh interface ipv4 delete dnsservers name="%nic%" all
netsh interface ipv4 add dnsservers name=%nic% addr=%dns% > null
netsh interface ipv4 add dnsservers name=%nic% addr=%dns2% index=2 > null
netsh interface ipv4 add address name=%nic%  address="%ip1%" mask=%subnetMask% 
netsh interface ipv4 add address name=%nic% address="%ip2%" mask=%subnetMask%
netsh interface ipv4 add address name=%nic% address="%ip3%" mask=%subnetMask%
netsh interface ipv4 add address name=%nic% address="%ip4%" mask=%subnetMask%
goto end

:end
echo.
echo ��ǰ����������Ϣ
ipconfig /all
pause