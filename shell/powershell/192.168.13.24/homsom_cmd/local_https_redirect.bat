@echo off
netsh interface portproxy add v4tov4 listenaddress=172.168.2.220 listenport=443 connectaddress=192.168.13.207 connectport=443