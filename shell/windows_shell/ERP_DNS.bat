@echo off
cls

rem interfacename
set "nic=interface"

rem dnsname
set "dns=192.168.10.250"

goto setdns

:setdns
rem interfacename dnsname
netsh interface ipv4 delete dnsservers name="%nic%" all
netsh interface ipv4 add dnsservers  name="%nic%" address="%dns%"
