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

</pre>