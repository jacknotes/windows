net use * /del /y
net use \\192.168.13.182\HomsomAuto linuxuser /user:hs\linuxuser

chcp 437
schtasks /query -v /fo list > \\192.168.13.182\HomsomAuto\192.168.13.190\schtasks.txt

