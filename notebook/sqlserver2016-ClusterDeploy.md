
# 主机相关信息

* SRV-DB01: 192.168.13.131
* SRV-DB02: 192.168.13.132
* SRV-DB03: 192.168.13.133
* DBCLUSTER: 192.168.13.134    		# WSFC侦听器名称及地址
* `\\192.168.13.122\dbzc`			# 文件共享仲裁
* DBCONN: 192.168.13.135





# 用户信息

* 登录用户：hs\dbadmin   		角色: `hs\domain admins`
* sqlserver用户：hs\dbadmin		角色: `hs\domain admins`







# 部署



## 1. 加域

1. 配置网络
2. 配置主机名及加域
3. 用hs\dbadmin用户登录服务器




## 2. 安装更新

1. 配置wsus配置
2. 安装更新到最新补丁
3. windows server 2019安装更新失败报`0x8024401c`错误时，可使用如下办法解决
```
net stop wuauserv
reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f
net start wuauserv
```
4. 如果wsus更新安装不，则使用系统默认的更新服务器安装



## 3. 安装WSFC群集

1. 服务器管理器 --> 添加功能和角色 --> 添加功能 --> "故障转移群集"，SRV-DB01、SRV-DB02、SRV-DB03三个节点都需要安装，安装完成生重启服务器生效
2. 配置故障转移集群管理器，新建一个群集
	* 将SRV-DB01、SRV-DB02、SRV-DB03三个服务器节点加入群集
	* 运行群集测试
	* 配置群集名称：DBCLUSTER，群集地址：192.168.13.134
	* 去除 "将所有符合条件的存储添加到群集" 复选框
3. 配置仲裁，我们有3个节点，可以承受一个节点故障，但是第二次节点再故障将会脑裂，为了可以容忍二次节点故障，可以配置仲裁，这样就可以容忍二次节点故障了。
	* 配置文件共享仲裁
	* 因为是DBCLUSTER群集去读写仲裁，所以需要将在文件共享中给予`DBCLUSTER`计算机用户读写权限、本地管理员administrators权限




## 4. 安装SQLServer 2016

1. 安装前关闭windows防火墙
2. 每台节点正常安装sqlserver 2016 enterprise实例，是单实例安装，不是集群模式安装
3. 安装与不安装特定服务
	* "数据库引擎服务" --> "针对外部数据的Polybase查询服务"、"R服务(数据库内)", "analysis services"、"reporting services"不要勾选安装、
	* "共享功能" --> "R Server(独立)"、"Reporting Services - SharePoint"、"用于SharePoint产品的Reporting Service外接程序"、"Distributed Replay控制器"、"Distributed Replay客户端" 不要勾选安装
	* 其它勾选安装
4. 身份验证模式为：混合模式，添加当前用户hs\dbadmin 为 sqlserver管理员 
5. 所有节点的sqlserver安装，数据目录为"D:\DBDATA\"
6. 安装完成后，安装SSMS客户端，需要单独下载安装才行，SSMS安装完成后重启服务器
7. 每个节点安装好后需要为 MSSQLSERVER实例服务、SQLServer代理服务 配置当前专用管理员帐户(hs\dbadmin)进行登录、配置服务自动启动，并重启服务，使2个服务有管理员权限



## 5. 开启AlwaysOn高可用功能

3个节点`SQL Server(MSSQLSERVER)`都需要启用AlwaysOn可用性组功能，并重启sqlserver服务生效



## 6. 配置AlwaysOn

1. 在建可用性组之前：在集群名称`DBCLUSTER`计算机所在的OU上，`DBCLUSTER` 需要有 `读取所有对象`(默认就有读取所有对象权限，此权限可不更改)、`创建计算机对象`(需要添加此权限)的权限
2. 配置AlwaysOn可用性组前，需要先完全备份将要运行在Always On分布式集群中的数据库
	* 例如ReportDB数据库("RankDB_full.bak")，在主要服务器上恢复数据库，主要数据库必须是RCOVERY状态，哪台恢复，哪台就是主要数据库
3. 在AlwaysOn高可用性菜单上右键选择  --> "新建可用性组向导"，配置一个可用性组名称`DBCONN`，群集类型是 "Windows Server故障转移群集"
4. 添加副本、配置备份首选项、配置侦听器名称为：`DBCONN`，侦听器IP为：192.168.13.135
5. 选择数据同步为`仅联接`，前提是已经在所有辅助副本还原过数据库
6. 可用性组添加完成



## 7. 节点故障恢复

`注：此步骤为故障恢复，步骤时可跳过`
1. WSFC群集逐出故障节点
2. 故障节点重装系统、安装更新、安装WSFC、安装SQLServer 2016、安装SQLServer客户端
3. 打开WSFC群集管理器将新节点加入WSFC群集
4. 在正常AlwaysOn集群任意一节点，完全备份`所有正在使用的数据库`、并将备份数据复制到新节点上进行恢复，恢复状态必须为`NORECOVERY`状态
5. 在AlwaysOn可用性组中添加副本，此副本为新部署的SQLServer节点、选择数据同步为`仅联接`



## 8. 配置只读路由

1. 在AlwaysOn可用性组`DBCONN`上打开属性配置框，选择左边只读路由 
2. 配置服务器实例对应的`只读路由URL`
	* SRV-DB01: `TCP://SRV-DB01.hs.com:1433`
	* SRV-DB02: `TCP://SRV-DB02.hs.com:1433`
	* SRV-DB03: `TCP://SRV-DB03.hs.com:1433`
3. 配置服务器实例对应的`只读路由列表`
	* SRV-DB01: `SRV-DB02,SRV-DB03`
	* SRV-DB02: `SRV-DB01,SRV-DB03`
	* SRV-DB03: `SRV-DB01,SRV-DB02`
	* 如果需要使2个辅助副本具有同样的优先级，可以选中2个副本，再点`添加`，则为SRV-DB01: `(SRV-DB02,SRV-DB03)`
4. 配置完成后，进行测试即可
5. 配置出错插曲
	* 当时只有2个数据库节点，配置只读路由列表时报错
	* 于是增加了1个数据库节点，形成3个节点，配置只读路由列表还是报错
	* 于是手动故障转移`主要节点`到新节点
	* 再配置只读路由列表成功
	* 创建第二个可用性组时也报错，原因是先填写`只读路由URL`并先保存，然后再编辑`只读路由列表`保存即可
	
	
```sql
---查询可用性副本信息
SELECT * FROM master.sys.availability_replicas

---建立read指针 - 在当前的primary上为每个副本建立副本对于的tcp连接
ALTER AVAILABILITY GROUP [DBCONN]
MODIFY REPLICA ON
N'SRV-DB01' WITH
(SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://SRV-DB01.hs.com:1433'))

ALTER AVAILABILITY GROUP [DBCONN]
MODIFY REPLICA ON
N'SRV-DB02' WITH
(SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://SRV-DB02.hs.com:1433'))

ALTER AVAILABILITY GROUP [DBCONN]
MODIFY REPLICA ON
N'SRV-DB03' WITH
(SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://SRV-DB03.hs.com:1433'))



----为每个可能的primary role配置对应的只读路由副本
--list列表有优先级关系，排在前面的具有更高的优先级,当db02正常时只读路由只能到db02，如果db02故障了只读路由才能路由到DB03
ALTER AVAILABILITY GROUP [DBCONN]
MODIFY REPLICA ON
N'SRV-DB01' WITH
(PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=(('SRV-DB02','SRV-DB03'))));	--同一优先级使用()表示，默认优先级是以顺序来确定

ALTER AVAILABILITY GROUP [DBCONN]
MODIFY REPLICA ON
N'SRV-DB02' WITH
(PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=('SRV-DB01','SRV-DB03')));

ALTER AVAILABILITY GROUP [DBCONN]
MODIFY REPLICA ON
N'SRV-DB03' WITH
(PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=('SRV-DB01','SRV-DB02')));


--查询优先级关系
SELECT  ar.replica_server_name ,
        rl.routing_priority ,
        ( SELECT    ar2.replica_server_name
          FROM      sys.availability_read_only_routing_lists rl2
                    JOIN sys.availability_replicas AS ar2 ON rl2.read_only_replica_id = ar2.replica_id
          WHERE     rl.replica_id = rl2.replica_id
                    AND rl.routing_priority = rl2.routing_priority
                    AND rl.read_only_replica_id = rl2.read_only_replica_id
        ) AS 'read_only_replica_server_name'
FROM    sys.availability_read_only_routing_lists rl
        JOIN sys.availability_replicas AS ar ON rl.replica_id = ar.replica_id
```



## 9. 配置多网口

1. 可以在每个节点上增加多网口，例如每个节点再增加1个网口，并配置IP网关等信息，确保每个网口可正常上网
2. 在WSFC群集中`验证集群`，此时不会报网络单点故障的警告了
3. 当WSFC群集检测到网络后，只读路由中的`只读路由URL`域名自动会指向多个IP的A记录
```
> srv-db02.hs.com
服务器:  homsom-dc01.hs.com
Address:  192.168.10.250

名称:    srv-db02.hs.com
Addresses:  192.168.13.132
          192.168.13.137
```
4. DBCONN是在某个物理接口之上进行监听工作的，所以当这个物理接口故障后，可用性组侦听器IP则会闪断飘移到本机另外一个接口，如果本机接口都故障，则会飘移到其它节点接口




## 10. 程序配置读写和只读

```
---C# 连接字符串
server=侦听IP;database=;uid=;pwd=;ApplicationIntent=ReadOnly

---ssms：其它连接参数
--仅意向读连接
ApplicationIntent=ReadOnly
--读写连接
ApplicationIntent=ReadWrite
```


​	

## 11. 创建第个二可用性组DBCONNLOG


1. 在`数据库服务器上`创建新数据库`Test02`

```sql
CREATE DATABASE [Test02] 
ON PRIMARY
(
NAME = N'Test02',
FILENAME = N'D:\SQLData\Test02.mdf',
SIZE = 8192KB,
FILEGROWTH = 65536KB,
MAXSIZE = UNLIMITED
)
LOG ON
(
NAME = N'Test02_log',
FILENAME = N'D:\SQLData\Test02_log.ldf',
SIZE = 8192KB,
FILEGROWTH = 65536KB,
MAXSIZE = 2048GB
)
GO
```

2. 完全备份`空的`数据库`Test02`

```sql
BACKUP DATABASE [Test02] TO DISK=N'd:\dbbackup\test02'  
WITH NOFORMAT ,NOINIT,  NAME = N'test-完整 数据库 备份', SKIP, NOREWIND, NOUNLOAD,  STATS = 10  
```

3. 创建可用性组，`数据同步首选项`选择`自动种子设定`，此时会自动备份还原新的数据库到其它辅助数据库，前提是所有数据库实例的DATA目录`D:\SQLData`路径必须一样
`注：不建议使用第3步 自动种子设定 ，因为经过测试，有些节点的数据库并没有创建，从而可用性组中的某些数据库并没有完成同步，只能采用第4步的步骤进行修复`


4. 新建数据库添加可用性组建议
- 批处理脚本新建数据库
- 批处理脚本备份新建数据库
- 复制备份数据库到其它节点同样的备份目录中
- 其它节点批处理脚本恢复数据库，恢复模式必须为NORECOVERY
- 在主要数据库可用性组中添加`可用性数据库`，可使用`Shift`键进行多选，并用`空格`进行选择





## 12. golang生成数据库脚本

```go
/*
connlog需要每年底创建下一年数据库，此脚本用于生成创建和删除数据库SQL命令
此文件具备AlwaysOn集群新建数据库及全备的脚本生成功能
*/
package main

import (
	"fmt"
	"sort"
)

type Month int

const (
	YEAR   int    = 2023
	Prefix string = "Log"
)

const (
	January Month = iota + 1
	February
	March
	April
	May
	June
	July
	August
	September
	October
	November
	December
)

var (
	d               = 1
	Slist           = []string{}
	DATA_DIR        = "D:\\SQLData"
	SIZE            = "8192KB"
	FILEGROWTH      = "65536KB"
	PRIMARY_MAXSIZE = "UNLIMITED"
	LOG_MAXSIZE     = "2048GB"
	BACKUP_DIR      = "D:\\tmp"
)

// 判断是否为润年，润年2月29天，非润年2月28天
func IsRunNian(year int) bool {
	if year > 0 {
		result := year % 4
		if result == 0 {
			return true
		} else {
			return false
		}
	} else {
		panic("[ERROR]: 年份不合法")
	}
}

// 输出大小月日期
func OutputDate() {
	MaxMonthList := [7]Month{January, March, May, July, August, October, December}
	MinMonthList := [4]Month{April, June, September, November}
	for _, v := range MaxMonthList {
		if v < October {
			Slist = append(Slist, fmt.Sprintf("%s%d%s%d%s%d", Prefix, YEAR, "0", v, "0", d))
			Slist = append(Slist, fmt.Sprintf("%s%d%s%d%d", Prefix, YEAR, "0", v, d+10))
			Slist = append(Slist, fmt.Sprintf("%s%d%s%d%d", Prefix, YEAR, "0", v, d+20))
			Slist = append(Slist, fmt.Sprintf("%s%d%s%d%d", Prefix, YEAR, "0", v, d+30))
		} else {
			Slist = append(Slist, fmt.Sprintf("%s%d%d%s%d", Prefix, YEAR, v, "0", d))
			Slist = append(Slist, fmt.Sprintf("%s%d%d%d", Prefix, YEAR, v, d+10))
			Slist = append(Slist, fmt.Sprintf("%s%d%d%d", Prefix, YEAR, v, d+20))
			Slist = append(Slist, fmt.Sprintf("%s%d%d%d", Prefix, YEAR, v, d+30))
		}
	}
	for _, v := range MinMonthList {
		if v < November {
			Slist = append(Slist, fmt.Sprintf("%s%d%s%d%s%d", Prefix, YEAR, "0", v, "0", d))
			Slist = append(Slist, fmt.Sprintf("%s%d%s%d%d", Prefix, YEAR, "0", v, d+10))
			Slist = append(Slist, fmt.Sprintf("%s%d%s%d%d", Prefix, YEAR, "0", v, d+20))
			Slist = append(Slist, fmt.Sprintf("%s%d%s%d%d", Prefix, YEAR, "0", v, d+29))
		} else {
			Slist = append(Slist, fmt.Sprintf("%s%d%d%s%d", Prefix, YEAR, v, "0", d))
			Slist = append(Slist, fmt.Sprintf("%s%d%d%d", Prefix, YEAR, v, d+10))
			Slist = append(Slist, fmt.Sprintf("%s%d%d%d", Prefix, YEAR, v, d+20))
			Slist = append(Slist, fmt.Sprintf("%s%d%d%d", Prefix, YEAR, v, d+29))
		}
	}
}

// 加入2月日期
func GenDate(b bool) {
	if b {
		//润年，2月29天
		OutputDate()
		Slist = append(Slist, fmt.Sprintf("%s%d%s%d%s%d", Prefix, YEAR, "0", February, "0", d))
		Slist = append(Slist, fmt.Sprintf("%s%d%s%d%d", Prefix, YEAR, "0", February, d+10))
		Slist = append(Slist, fmt.Sprintf("%s%d%s%d%d", Prefix, YEAR, "0", February, d+20))
		Slist = append(Slist, fmt.Sprintf("%s%d%s%d%d", Prefix, YEAR, "0", February, d+28))
	} else {
		//非润年，2月28天
		OutputDate()
		Slist = append(Slist, fmt.Sprintf("%s%d%s%d%s%d", Prefix, YEAR, "0", February, "0", d))
		Slist = append(Slist, fmt.Sprintf("%s%d%s%d%d", Prefix, YEAR, "0", February, d+10))
		Slist = append(Slist, fmt.Sprintf("%s%d%s%d%d", Prefix, YEAR, "0", February, d+20))
		Slist = append(Slist, fmt.Sprintf("%s%d%s%d%d", Prefix, YEAR, "0", February, d+27))
	}
}

func AlwaysOnClusterCreateDB() {
	// 生成新建数据库脚本
	fmt.Println("---- AlwaysOn集群创建数据库")
	for _, v := range Slist {
		fmt.Printf("-- %s\n", v)
		fmt.Printf("CREATE DATABASE %s\nON PRIMARY\n(\nNAME = N'%s',\nFILENAME = N'%s\\%s.mdf',\nSIZE = %s,\nFILEGROWTH = %s,\nMAXSIZE = %s\n)\nLOG ON\n(\nNAME = N'%s_log',\nFILENAME = N'%s\\%s_log.ldf',\nSIZE = %s,\nFILEGROWTH = %s,\nMAXSIZE = %s\n)\nGO\n",
			v, v, DATA_DIR, v, SIZE, FILEGROWTH, PRIMARY_MAXSIZE, v, DATA_DIR, v, SIZE, FILEGROWTH, LOG_MAXSIZE)
		fmt.Println()
	}

	// 生成完全备份数据库脚本
	fmt.Println("---- AlwaysOn集群完全备份数据库")
	for _, v := range Slist {
		fmt.Printf("-- %s\n", v)
		fmt.Printf("BACKUP DATABASE [%s] TO DISK=N'%s\\%s_full.bak'\nWITH NOFORMAT, NOINIT, NAME=N'%s-完整 数据库 备份', SKIP, NOREWIND, NOUNLOAD, STATS=10\n", v, BACKUP_DIR, v, v)
		fmt.Println()
	}

	// 生成恢复数据库脚本-RECOVERY
	fmt.Println("---- AlwaysOn集群恢复数据库-RECOVERY")
	for _, v := range Slist {
		fmt.Printf("-- %s\n", v)
		fmt.Printf("RESTORE DATABASE [%s]\nFROM\nDISK=N'%s\\%s_full.bak'\nWITH MOVE '%s' TO N'%s\\%s.mdf',\nMOVE '%s_log' TO N'%s\\%s_log.ldf',\nSTATS = 10, REPLACE,RECOVERY\nGO\n",
			v, BACKUP_DIR, v, v, DATA_DIR, v, v, DATA_DIR, v)
		fmt.Println()
	}

	// 生成恢复数据库脚本-NORECOVERY
	fmt.Println("---- AlwaysOn集群恢复数据库-NORECOVERY")
	for _, v := range Slist {
		fmt.Printf("-- %s\n", v)
		fmt.Printf("RESTORE DATABASE [%s]\nFROM\nDISK=N'%s\\%s_full.bak'\nWITH MOVE '%s' TO N'%s\\%s.mdf',\nMOVE '%s_log' TO N'%s\\%s_log.ldf',\nSTATS = 10, REPLACE,NORECOVERY\nGO\n",
			v, BACKUP_DIR, v, v, DATA_DIR, v, v, DATA_DIR, v)
		fmt.Println()
	}

}

func CreateDBStatement() {
	for _, v := range Slist {
		fmt.Printf("CREATE DATABASE %s\n", v)
	}
}

func DropDBStatement() {
	for _, v := range Slist {
		fmt.Printf("DROP DATABASE %s\n", v)
	}
}

func main() {
	result := IsRunNian(YEAR)
	GenDate(result)

	// 对slice进行排序
	sort.Strings(Slist)

	fmt.Println("-------- AlwaysOn集群创建数据库和完全备份语句")
	AlwaysOnClusterCreateDB()

	// fmt.Println("-- 创建数据库语句")
	// CreateDBStatement()

	// fmt.Println("-- 删除数据库语句")
	// DropDBStatement()
}

```

