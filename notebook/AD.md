# AD域





**域架构: 主从域**

| 主机名            | IP           | 角色     |
| ----------------- | ------------ | -------- |
| pdc.test.com      | 172.168.2.61 | PDC      |
| bdc.test.com      | 172.168.2.62 | BDC      |
| client01.test.com | 172.168.2.65 | client01 |
| client02.test.com | 172.168.2.66 | client02 |









## 1. 安装PDC





### 1.1 配置网络

```cmd
# 配置网络

# 查看接口索引
netsh interface ip show interface
netsh interface ip set address 11 static 172.168.2.61 255.255.255.0 172.168.2.254
netsh interface ip add dnsservers 11 127.0.0.1
# 启用接口
netsh interface set interface "本地连接" admin=enabled

# 关闭防火墙
netsh advfirewall show domainprofile
netsh advfirewall set allprofiles state off
```





### 1.2 安装第一台域控

```cmd
# 打开安装域控程序窗口
dcpromo
```

![](../images/AD/01.png)

![](../images/AD/02.png)

![](../images/AD/03.png)

![](../images/AD/04.png)

![](../images/AD/05.png)

![](../images/AD/06.png)

![](../images/AD/07.png)

![](../images/AD/08.png)

![](../images/AD/09.png)

![](../images/AD/10.png)

![](../images/AD/11.png)

![](../images/AD/12.png)

![](../images/AD/13.png)

![](../images/AD/14.png)

![](../images/AD/15.png)

![](../images/AD/16.png)

![](../images/AD/17.png)





### 1.3 创建普通域用户

![](../images/AD/18.png)

![](../images/AD/19.png)









## 2. 客户端01





### 2.1 配置网络并加域

![](../images/AD/20.png)

![](../images/AD/21.png)





### 2.2 登录域用户并测试dns

![](../images/AD/22.png)

![](../images/AD/23.png)





### 2.3 PDC配置组策略

![](../images/AD/24.png)

![](../images/AD/25.png)





### 2.4 客户端01验证组策略

**强制刷新组策略并重启**

```cmd
gpupdate /force
shutdosn -r -t 0
```

![](../images/AD/26.png)









## 3. 安装BDC





### 3.1 配置网络

![](../images/AD/27.png)

![](../images/AD/28.png)





### 3.2 安装第二台域控，为BDC角色

![](../images/AD/29.png)

![](../images/AD/30.png)

![](../images/AD/31.png)

![](../images/AD/32.png)

![](../images/AD/33.png)

![](../images/AD/34.png)

![](../images/AD/35.png)

![](../images/AD/36.png)

![](../images/AD/37.png)

![](../images/AD/38.png)

![](../images/AD/39.png)





### 3.3 登录并配置BDC

![](../images/AD/40.png)

![](../images/AD/41.png)

![](../images/AD/42.png)

![](../images/AD/43.png)





### 3.4 查看BDC跟PDC同步的状态

**DNS**

![](../images/AD/44.png)



**域对象**

![](../images/AD/45.png)



**组策略**

![](../images/AD/46.png)



**域和信任关系**

![](../images/AD/47.png)



**站点和服务**

![](../images/AD/48.png)

![](../images/AD/49.png)









## 4. 客户端02





### 4.1 配置网络并加域

![](../images/AD/50.png)





### 4.2 在BDC上创建普通域用户

![](../images/AD/51.png)





### 4.3 登录域用户并测试dns

![](../images/AD/52.png)

![](../images/AD/53.png)

![](../images/AD/54.png)









## 5. 模拟PDC故障，BDC升级为PDC-灾难恢复-方式一





### 5.1 模拟PDC故障

**将PDC关机**

![](../images/AD/55.png)



**BDC已经无法ping通PDC了，表示PDC已经关机了**

![](../images/AD/56.png)





### 5.2 BDC升级为PDC

![](../images/AD/57.png)

![](../images/AD/58.png)



**清除元数据，抢夺五大角色**

```cmd
C:\Users\Administrator>ntdsutil
ntdsutil: metadata cleanup
metadata cleanup: select operation target
select operation target: connections
server connections: connect to domain test.com
绑定到 \\bdc.test.com ...
用本登录的用户的凭证连接 \\bdc.test.com。
server connections: quit
select operation target: list sites
找到 1 站点
0 - CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=test,DC=com
select operation target: select site 0
站点 - CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=test,DC=com
没有当前域
没有当前服务器
当前的命名上下文
select operation target: list domains in site
找到 1 域
0 - DC=test,DC=com
select operation target: select domain 0
站点 - CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=test,DC=com
域 - DC=test,DC=com
没有当前服务器
当前的命名上下文
select operation target: list servers for domain in site
找到 2 服务器
0 - CN=PDC,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=test,DC=com
1 - CN=BDC,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=test,DC=com
select operation target: select server 0
站点 - CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=test,DC=com
域 - DC=test,DC=com
服务器 - CN=PDC,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=test,DC=com
        DSA 对象 - CN=NTDS Settings,CN=PDC,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=test,DC=com
        DNS 主机名称 - pdc.test.com
        计算机对象 - CN=PDC,OU=Domain Controllers,DC=test,DC=com
当前的命名上下文
select operation target: quit
metadata cleanup: remove selected server

```

![](../images/AD/59.png)

![](../images/AD/60.png)

![](../images/AD/61.png)

![](../images/AD/62.png)

![](../images/AD/63.png)

![](../images/AD/64.png)

![](../images/AD/65.png)





### 5.3 删除PDC无用相关资源

**站点和服务**

![](../images/AD/66.png)



**DNS**

![](../images/AD/67.png)

![](../images/AD/68.png)





### 5.4 客户端查看当前PDC主机

**客户端01**

![](../images/AD/69.png)



**客户端02**

![](../images/AD/70.png)









## 6. 手动转移五大角色





### 6.1 GUI方式转移

![](../images/AD/71.png)

![](../images/AD/72.png)

![](../images/AD/73.png)

![](../images/AD/74.png)



**注册"Active Directory架构"图形化界面**

![](../images/AD/75.png)

![](../images/AD/76.png)

![](../images/AD/77.png)





### 6.2 CLI方式转移

```cmd
# 需要转移五大角色 PDC、RID master、schema master、naming master、infrastructure master
# 以下为转移pdc为例
C:\Users\Administrator>ntdsutil
ntdsutil: roles
fsmo maintenance: connections
server connections: connect to server "bdc.test.com"
绑定到 bdc.test.com ...
用本登录的用户的凭证连接 bdc.test.com。
server connections: quit
fsmo maintenance: transfer pdc
```

![](../images/AD/78.png)

```cmd
ldap_modify_sW 错误 0x34(52 (不可用).
Ldap 扩展的错误消息为 000020AF: SvcErr: DSID-03210581, problem 5002 (UNAVAILABLE
), data 1722

返回的 Win32 错误为 0x20af(请求的 FSMO 操作失败。不能连接当前的 FSMO 盒。)
)
根据错误代码这可能表示连接
ldap, 或角色传送错误。
服务器 "bdc.test.com" 知道有关 5 作用
架构 - CN=NTDS Settings,CN=PDC,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN
=Configuration,DC=test,DC=com
命名主机 - CN=NTDS Settings,CN=PDC,CN=Servers,CN=Default-First-Site-Name,CN=Site
s,CN=Configuration,DC=test,DC=com
PDC - CN=NTDS Settings,CN=PDC,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=
Configuration,DC=test,DC=com
RID - CN=NTDS Settings,CN=PDC,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=
Configuration,DC=test,DC=com
结构 - CN=NTDS Settings,CN=PDC,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN
=Configuration,DC=test,DC=com
fsmo maintenance:
```

> 错误原因：因为PDC已经关机不在线，所以转移不成功，PDC不变，如图

![](../images/AD/79.png)









## 7. 手动抢夺五大角色-灾难恢复-方式二

**方式一删除不干净，用此方式二次删除，可以抢夺五大角色**

```bash
C:\Users\Administrator>ntdsutil
ntdsutil: roles
fsmo maintenance: connections
server connections: connect to server "bdc.test.com"
绑定到 bdc.test.com ...
用本登录的用户的凭证连接 bdc.test.com。
server connections: quit

# 占用 RID 主机角色
seize RID master
# 占用 PDC 模拟器角色
seize PDC
# 占用结构主机角色
seize infrastructure master
# 占用域命名主机角色
seize domain naming master
# 占用架构主机角色
seize schema master
```

> **此方式抢夺五大角色后，重启机器如果提示此域不存在，原因是其它域控服务器DNS地址未填写新PDC服务器的IP地址，所以造成通信交互失败**

