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
* 安装cnpm，切记，安装cnpm时需要跟npm的版本对应，我这里安装的npm版本是8.19.2，对应的版本是7.x.x。详情见https://github.com/cnpm/cnpm/tree/7.x
npm install -g cnpm@7.0.0 --registry=https://registry.npmmirror.com			
npm install -g gulp --registry=https://registry.npmmirror.com
npm install -g webpack --registry=https://registry.npmmirror.com
npm install -g webpack-cli --registry=https://registry.npmmirror.com

错误：Error: Cannot find module 'fs/promises'  
原因：npm和cnpm版本不对应所致。需要先卸载再安装对应版本
npm uninstall -g cnpm 

#获取镜像地址
npm get registry
#永久配置registry地址，实现在用户家目录下生成.npmrc文件，内容为镜像地址
npm config set registry http://nugetv3.hs.com/repository/npm-proxy/


* 配置windows环境变量，为nodejs安装的目录，例如D:\Program Files\nodejs\，另外自动会配置用户下的变量()，此变量不要配置。这里需要注意，配置好环境变量后需要重启jenkins服务，否则会出现明明在windows中可以使用npm命令，但是在jenkins pipeline脚本中无法识别npm命令，只需要重启下jenkins服务让其重新识别下环境变量即可。	#这里是个大坑，坑了我好久

```



### 清除jenkins构建日志

```
## Jenkins > 系统管理 > 工具和动作 > 脚本命令行


# 清除所有构建日志
def jobs = Jenkins.instance.projects.collect { it } 
jobs.each { job -> job.getBuilds().each { it.delete() }} 


# 清除所有job不大于maxNumber的构建日志
def maxNumber = 3
def jobs = Jenkins.instance.projects.collect { it } 
jobs.each { job -> job.getBuilds().findAll {
  it.number <= maxNumber
}.each { 
	it.delete() }
} 


# 清除指定项目日志
def jobName = "Your Job Name"
def job = Jenkins.instance.getItem(jobName)
job.getBuilds().each { it.delete() }


# 清除指定项目日志，删除不大于 maxNumber 的记录
def jobName = "nginx.hs.com"
def maxNumber = 70
Jenkins.instance.getItemByFullName(jobName);
Jenkins.instance.getItemByFullName(jobName).builds.findAll {
  it.number <= maxNumber
}.each {
  it.delete()
}


# 删除指定job构建历史区间记录
import jenkins.model.*;
import hudson.model.Fingerprint.RangeSet;

def jobName = "nginx.hs.com";
def buildRange = "74-76";
def j = jenkins.model.Jenkins.instance.getItemByFullName(jobName);
def r = RangeSet.fromString(buildRange, true);
j.getBuilds(r).each { it.delete() }

```


