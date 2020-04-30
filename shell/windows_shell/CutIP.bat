@echo off
cls

rem 网络连接名称
set "nic=interface"
rem 静态 IP 地址
set "ip=172.168.2.219"
set "governmentIP=192.168.20.21"
rem 子网掩码
set "subnetMask=255.255.255.0"
rem 默认网关
set "defaultGateway=172.168.2.254"
set "governmentDefaultGateway=192.168.20.1"
rem 首选 DNS 服务器
set "dns=192.168.10.250"
rem 备用 DNS 服务器
set "dns2=8.8.8.8"
rem 多个IP地址
set "ip1=172.168.7.11"
set "ip2=172.168.7.12"
set "ip3=172.168.7.13"
set "ip4=172.168.7.14"

:start
echo [1] 配置公司内网 IP
echo [2] 配置政务外网 IP
echo [3] 动获得 IP 地址（DHCP）
echo [4] 添加多个ip地址
echo [5] 直接退出
set choice=
set /p choice=请输入编号，并按回车键结束:
if "%choice%"=="1" goto setStaticIP
if "%choice%"=="2" goto setGovernmentStaticIP
if "%choice%"=="3" goto setDHCP
if "%choice%"=="4" goto addsIP
if "%choice%"=="5" goto end
echo "%choice%" 是无效的，请重新输入
echo.
goto start

:setStaticIP
rem 网络连接名称 静态 IP 地址 子网掩码 默认网关
netsh interface ipv4 set address name=%nic% static %ip% %subnetMask% %defaultGateway%
netsh interface ipv4 delete dnsservers name="%nic%" all
netsh interface ipv4 add dnsservers name=%nic% addr=%dns% 
netsh interface ipv4 add dnsservers name=%nic% addr=%dns2% index=2 
goto end

:setGovernmentStaticIP
rem 网络连接名称 静态 IP 地址 子网掩码 默认网关
netsh interface ipv4 set address name=%nic% static %governmentIP% %subnetMask% %governmentDefaultGateway%
netsh interface ipv4 delete dnsservers name="%nic%" all
netsh interface ipv4 add dnsservers name=%nic% addr=%dns% 
netsh interface ipv4 add dnsservers name=%nic% addr=%dns2% index=2 
goto end

:setDHCP
rem 自动从 DHCP 服务器获取 IP 地址
netsh interface ipv4 set address name=%nic% dhcp
netsh interface ipv4 set dnsservers name=%nic% dhcp
goto end

:addsIP
rem 添加多个ip地址
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
echo 当前网络连接信息
ipconfig /all
pause