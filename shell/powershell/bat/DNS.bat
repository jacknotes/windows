netsh interface ip set dns "��������" source=static addr=192.168.10.250
netsh interface ip add dns "��������" 172.168.2.251

netsh interface ip set dns "�������� 2" source=static addr=192.168.10.250
netsh interface ip add dns "�������� 2" 172.168.2.251

netsh interface ip set dns "����" source=static addr=192.168.10.250
netsh interface ip add dns "����" 172.168.2.251

ipconfig /flushdns
