<pre>
--sqlserver2016 AlwaysOn高可用集群部署
1. 安装前数据库服务器需要加域。并且加入域管理员组。
2. 节点上正常安装SQLserver实例（不是集群模式安装），是单实例安装。
3. 安装时需要将当前登录用户加入到Sqlserver管理员中。安装报JDK错误，可不安装相关JDK服务。(--在alwaysOn新建可用性组提示失败时，需要重新在MSSQLSERVER服务上关闭可用性功能并重启MSSQLSERVER
服务，然后再开启可用性功能并重启MSSQLSERVER服务。此后再新建可用性组即可成功。在建立可用性组时，)
4. 每个节点安装好后需要为MSSQLSERVER实例服务和SQLServer代理服务配置当前登录域管理员帐户进行登录。
5. 每个节点需要开启AlwaysOn高可用功能，打开'SQL Server配置管理器'，找到MSSQLSERVER实例服务，右键属性开启AlwaysOn高可用服务并重启服务(需要先安装故障转移集群管理器)。
6. 配置AlwaysOn可用性组前，需要先完全备份需要进行分布式集群的数据库，需要在主要服务器上恢复数据库，主要数据库必须是RCOVERY状态。副本服务器上恢复数据库，副本数据库必须是NORECOVERY状态。如果有多个副本数据库，则多个副本数据库都要执行恢复操作，而且必须是NORECOVERY状态
7. 安装Sql Server Managerment Studio客户端，在AlwaysOn高可用性菜单上右键选择'新建可用性组向导'，配置一个可用性组名称，群集类型是'Windows Server故障转移群集'，下一步，选择前面恢复的数据库名称，下一步，添加副本，勾选'自动故障转移(最多3个)的勾'，可用性模式为'同步提交'，可读辅助副本配置：主要节点为'否'，辅助节点为'否'。配置端点为IP地址(不使用DNS名称)，添加一个侦听器(侦听器DNS名称，SQLSERVER端口1433,网络IP地址为局域网内空闲IP[此IP为主要节点IP，提供读写功能的数据库IP])。
8. 可在主要服务器AlwaysOn高可用性菜单下，手动执行故障转移，转移群集节点后需要执行下列语句，让主要节点可读辅助副本为'否'，让辅助节点可读辅助副本为'是'，故障转移集群特定角色中，如果自动故障转移(或者手动故障转移)到DB02-SQLSERVER，则转移完成后需要在'主要服务器'上执行正下SQL
use master
go 
-- 让辅助节点可读辅助副本为'是'
alter availability group [AvailableGroup01] 
modify replica on 'DB01-SQLSERVER' with (secondary_role(allow_connections=all))
go
-- 让主要节点可读辅助副本为'否'
alter availability group [AvailableGroup01] 
modify replica on 'DB02-SQLSERVER' with (secondary_role(allow_connections=no))
go



--故障转移集群管理器
1. 角色中是整个集群连接的服务，右键属性可设置几个小时内几次失败执行故障转移到可用节点。例如：6小时内
如果有10次失败则执行自动故障转移，如果大于11次则不执行自动故障转移，最后需要手动进行转移

--增加AlwaysOn高可用副本节点
1. 首先安装故障转移集群管理器。
2. 将此节点加入到现有的集群中。可用下面语句查看集群节点信息：
select * from sys.dm_hadr_cluster_members
select * from sys.dm_hadr_cluster
3. 打开'SQL Server配置管理器'，找到MSSQLSERVER实例服务，右键属性开启AlwaysOn高可用服务并重启服务。
4. 在新加故障转移集群的节点上新建数据库，并恢复历史完全备份数据文件，状态必须为NORECOVERY
5. 在'主要'节点的'AlwaysOn高可用'菜单下添加副本到现在有可用组。完成副本添加。此时完成AlwaysOn高可用副本节点，
注：添加副本时，集群中所有的节点Sqlserver服务必须都是在线状态，否则加入不了新副本节点。
注：在AlwaysOn高可用显示时，主要节点会显示：主要和辅助(并且图标是转圈圈的状态)，副本节点会显示：当前节点是辅助，其余节点不会显示主要和辅助(并且图标是?的状态)



----用户权限管理
use reportDB
go
--创建登录用户(create login)--是全局的
create login [dba] with password='abcd1234@', default_database=master
create login [HS\0799] from windows
--创建数据库用户(create user)dba并映射到登录用户dba上,一般数据库用户和登录用户名称一样，并且默认的架构为dbo，大多是dbo，只应用当前数据库
-- select * from sys.schemas  --查看架构有哪些
create user dba for login [dba] with default_schema=dbo
create user [HS\0799] for login [HS\0799] with default_schema=dbo
--在当前数据库上授予dba数据库用户db_owner组权限
exec sp_addrolemember 'db_owner', 'dba'
exec sp_addrolemember 'db_owner', 'hs\0799'
--在当前数据库上删除dba数据库用户db_owner组权限
--exec sp_droprolemember 'db_owner', 'dba'
--在test01数据库上进行授权
use test01 
create user dba for login dba with default_schema=dbo
exec sp_addrolemember 'db_owner', 'dba'
--在test01数据库上删除用户授权并删除数据库用户dba,只删除此数据库用户dba
--use test01 
--exec sp_droprolemember 'db_owner', 'dba'
--drop user dba 

--授权/取消当前数据库用户dba对指定表的权限
use test01
create table test01
(
	id int,
	name varchar(50)
)
create user dba for login dba with default_schema=dbo
GRANT SELECT,UPDATE ON test01 TO dba
revoke UPDATE ON test01 TO dba
deny select on test01 to dba
--简单来说，deny就是将来都不许给，revoke就是收回已经给予的

--获取所有数据库用户名
SELECT * FROM Sysusers


--禁用登陆帐户
alter login dba disable
--启用登陆帐户
alter login dba enable
--登陆帐户改名
alter login dba with name=dba_tom
--登陆帐户改密码： 
alter login dba with password='aabb@ccdd'

--数据库用户改名： 
alter user dba with name=dba_tom
--更改数据库用户 defult_schema： 
alter user dba with default_schema=sales

--删除数据库用户： 
drop user dba
--删除 SQL Server登陆帐户： 
drop login dba
drop login [hs\0799]

--管理会话
select * from sys.dm_exec_connections where session_id=54
select * from sys.dm_exec_sessions where login_name='dba'
kill 54

--删除数据库用户： 
drop user dba
--删除 SQL Server登陆帐户： 
drop login dba

--管理会话
select * from sys.dm_exec_connections where session_id=54
select * from sys.dm_exec_sessions where login_name='dba'
kill 54



#20210806 note
#sqlserver2008R2群集安装
<pre>
涉及到三台虚拟机：
192.168.10.250：角色DC，DNS，域名hs.com
192.168.13.77:安装有Windows Server 2008 R2,Node01,两块网卡IP地址分别192.168.13.77,133.10.10.10
192.168.13.78:安装有Windows Server 2008 R2,Node02,两块网卡IP地址分别192.168.13.78,133.10.10.11

注：共享存储，IPSAN、光纤SAN，这里测试，用StarWind6软件来模拟IPSAN

1. 两台数据库节点安装Windows Server 2008R2系统，并加入hs.com域。过程省略。注：命令的帐户是域管理员hs\opsadmin
2. 在域控服务器上安装StarWind6软件来模拟IPSAN，安装过程省略。
	1. 添加target3个，一个为quorum仲裁磁盘，一个DTC分布式事务协调器，一个sqldata数据库存储盘。
	注：在新建target时，需要勾选“Allow multiple concurrent iSCSI connections (clustering)”,勾选后多个节点在添加同一个target时才不会冲突，这里非常重要，影响群集共享磁盘是否成功。
	2. 添加device3个，此为三个硬盘，这里用作测试，quorumDisk大小为1G，DTCDisk大小为1G，sqldataDisk大小为5G。在新建device时选择"Virtual Hard Disk" --> "Image File device" --> "create new virtual disk" --> 选择虚拟磁盘存储位置，磁盘名称必须以.imag结尾，否则创建失败，最后三个磁盘都要一一对应3个target。
	3. 两个数据库节点打开Iscsi连接程序，连接192.168.10.250:3260，在其中一个节点先添加一个Target,以quorum结尾的。并格式化磁盘为正常硬盘使用。其余两个磁盘在仲裁硬盘配置完成后添加。
3. 在两个数据库节点上安装"故障转移群集管理器"，安装完成后先执行"验证群集"。通过后再执行"创建一个群集"，输入两个数据库节点的主机名称,并创建管理群集的访问点，设置一个VIP。并点下一步确认安装，在安装过程中会自动配置仲裁磁盘。完成后可以在"故障转移群集管理器"中查看新建立的群集。
4. 连接另外两个target，跟连接第一个target一样，只是在初始化为硬盘时需要注意：在第一次初始化为硬盘的节点上继续执行这两个target为硬盘，因为会分配盘符，如果在不同节点初始化可能会分配到同一个盘符，会导致问题。
5. 在"故障转移群集管理器" --> "存储" --> 添加两块硬盘到这个群集中。
6. 在"故障转移群集管理器" --> "服务和应用程序" --> "配置服务和应用程序" --> "分布式事务协调器" --> 确认并设置IP地址和网络名称、并选择一块硬盘作为存储。
7. 两个节点在"更改适配器"设置中，依次选择"组织" --> "布局" --> "勾选菜单栏"，并选择菜单"高级"来调整网卡连接的顺序，将192.168.13.77或192.168.13.78网卡调至最上。
8. 先在第一个节点安装sqlserver2008R2企业版，进入DOS命令行，进入SQL2008 R2安装目录下，输入Setup /SkipRules=Cluster_VerifyForErrors /Action=InstallFailoverCluster 进行安装，用此方法安装第一个SQL群集节点。安装时勾选数据库引擎服务、数据库复制、全文索引、客户端连接工具、基本管理工具、完整的管理工具。然后设置sqlserver群集网络名称conn，后面选择集群硬盘用于存储数据库数据，配置集群网络IP，配置对所有服务帐户使用域管理员hs\opsadmin。然后安装。
9. 在第二个节点安装sqlserver2008R2企业版，进入DOS命令行，进入SQL2008 R2安装目录下，输入Setup /SkipRules=Cluster_VerifyForErrors /Action=AddNode 进行安装，用此方法把第二个节点添加到SQL群集中。过程需要输入hs\opsadmin的密码进行确认。
10. 上面步骤完成后2008R2群集就已经配置完成。

#如何向现有群集"服务和应用程序"添加sqlserver实例，比如log数据库实例服务
1. 新建一块logDisk target。
2. 两个数据库节点连接logDisk target,并在之前初始化硬盘的节点上初始化这块硬盘。
3. 在现有群集上 --> "存储" --> 添加硬盘到群集中。
4. 然后像之前添加数据库实例一个添加一个log实例，并设置sqlserver群集网络名称log和集群网络IP，选择刚才添加的集群硬盘用于存储数据库数据。
5. 上面步骤完成后log数据库实例服务也安装完成了。
注： 此时可以一台运行conn实例，另一台可以运行log实例。实现资源的利用。

#如何向"服务和应用程序" --> "conn"服务中添加一块硬盘用作备份盘使用
1. 新建一块backupDisk target。
2. 两个数据库节点连接backupDisk target,并在之前初始化硬盘的节点上初始化这块硬盘。
3. 在"故障转移群集管理器" --> "存储" --> 添加这块硬盘到这个群集中。
4. 在"服务和应用程序" --> "conn"服务上右键选择添加存储 --> 选择这块空闲的硬盘
5. 此时，conn服务就有两块硬盘了，一块是数据库存储数据的盘，一块是空闲可拿来备份数据库的硬盘。

注：数据库程序是安装在各个数据库节点上的，存储盘是在共享存储中，以免可随时漂移的。刚添加的存储盘也是在共享存储中，因为需要跟随conn服务一起移动。

</pre>


</pre>
