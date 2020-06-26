@echo off
cls

rem interfacename
set "nic=interface"

rem dnsname
set "dns=8.8.8.8"

goto setdns

:setdns
rem interfacename dnsname
netsh interface ipv4 delete dnsservers name="%nic%" all
netsh interface ipv4 add dnsservers  name="%nic%" address="%dns%"

