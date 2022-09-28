# jenkins dotnet for windows 平台构建



### 1. 安装jenkins

* 安装jdk，jenkins运行依赖，例如安装jdk-11.0.15.1
* 去jenkins[官网](https://www.jenkins.io/)下载并安装，安装在指定目录，例如：D:\Program Files\Jenkins

* 停止jenkins服务，更改配置D:\Program Files\jenkins\{jenkins.xml | config.xml}，并重启jenkins

  ```powershell
  sc stop jenkins
  
  notepad D:\Program Files\jenkins\jenkins.xml	#执行命令
  <env name="JENKINS_HOME" value="D:\Program Files\Jenkins"/>  #更改为jenkins根目录
  
  notepad D:\Program Files\jenkins\config.xml	#执行命令
  <workspaceDir>D:\Workspace\${ITEM_FULLNAME}.</workspaceDir> #更改为d盘指定目录
  
  sc start jenkins
  sc query jenkins
  ```



### 迁移jenkins

* 复制老jenkins的目录及配置文件到新jenkins中

  ```
  * jobs		#此目录太大，原因是构建时的日志太多，可清理后再复制到新的jenkins中，主要是jobs中的config.xml文件，此文件就是一个job
  * plugins #插件目录，可减少插件安装时间
  * users   #用户目录，jenkins自带的用户信息，包括密码信息
  * nodes   #如果有node节点则可以拷贝，，根据情况而定
  * secrets   #jenknins中配置的凭据信息，根据情况而定
  * userContent   #用户上传的数据信息，根据情况而定
  * config.xml   #此配置文件复制过来后，需要更改workspace位置
  * *plugins*.xml	#插件配置文件
  * hudson*.xml	#jenkins扩展配置文件
  ```



### 安装git和配置ssh key

```
* 下载安装git
* ssh-keygen -t rsa 生成ssh密钥对，默认会在当前用户的家目录下生存.ssh目录，目录下为密钥对。		#如果是迁移jenkins，则可以将老的jenkins用户下.ssh整个目录文件复制到新jenkins当前用户家目录下即可。
* jenkins进行git clone时会使用jenkins用户的ssh key权限，因为在配置jenkins服务时使用jenkins用户启动的服务。
* 如若在jenkins中配置了git管理方式来clone代码，则需要在jenkins中添加凭据，凭据类型为username and password。 然后添加jenkins的用户和密码即可。
```



### 安装.net framwork环境

```
* 需要安装.net framwork 2.0 3.0 3.5 4.0 4.5.1 4.5.2 4.6.1 4.6.2，但是安装太多还是无法通过jenkins构建，最后安装visual studio 2017解决，因为VS2017中自己会安装以上组件
* 为了实现jenkins进行pipeline时需要使用msbuild工具进行编译成功。需要安装vs_BuildTools.exe，安装此工具时，需要勾选“Web开发生成工具”选项，否则就算在这里成功安装msbuild，但也无法在jenkins中编译成功。切记。
```



### 安装Node.Js

```
* 前端项目需要依赖npm，所以这里需要安装nodejs，nodejs中有npm
* 安装cnpm，切记，安装cnpm时需要跟npm的版本对应，我这里安装的nodejs版本是8.19.2，对应的版本是7.x.x。详情见https://github.com/cnpm/cnpm/tree/7.x
npm install -g cnpm --registry=https://registry.npmmirror.com
* 配置windows环境变量，这里需要注意，配置好环境变量后需要重启jenkins服务，否则会出现明明在windows中可以使用npm命令，但是在jenkins pipeline脚本中无法识别npm命令，只需要重启下jenkins服务让其重新识别下环境变量即可。	#这里是个大坑，坑了我好久

```



### 清除jenkins构建日志

```
## Jenkins > 系统管理 > 工具和动作 > 脚本命令行


# 清除所有构建日志
def jobs = Jenkins.instance.projects.collect { it } 
jobs.each { job -> job.getBuilds().each { it.delete() }} 


# 清除指定项目日志
def jobName = "Your Job Name"
def job = Jenkins.instance.getItem(jobName)
job.getBuilds().each { it.delete() }

```

