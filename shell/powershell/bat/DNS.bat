netsh interface ip set dns "本地连接" source=static addr=192.168.10.250
netsh interface ip add dns "本地连接" 172.168.2.251

netsh interface ip set dns "本地连接 2" source=static addr=192.168.10.250
netsh interface ip add dns "本地连接 2" 172.168.2.251

netsh interface ip set dns "网络" source=static addr=192.168.10.250
netsh interface ip add dns "网络" 172.168.2.251

ipconfig /flushdns
