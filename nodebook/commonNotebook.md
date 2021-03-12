#windowsServer2008R2/2012自动登录
打开注册表：regedit，找到[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon]，新建或配置此3项字符串键值：
DefaultUserName   admin
DefaultPassword     password
AutoAdminLogon    1     
--AutoAdminLogon=1此项是在打开运行窗口输入'control userpasswords2'后，是否显示"要使用本机用户必须输入用户名和密码"，
--也可以开启此一项，打开运行窗口输入'control userpasswords2'，取消"要使用本机用户必须输入用户名和密码"并选择你需要登录的用户名，
--如没有则新建用户，然后点确定保存，当你点确定的时候系统需要你输入用户名和密码进行保存。
注：上面自动登录动作使用场景在:图形化界面程序需要在用户登录后运行。但是为确定安全，应在登录后进行锁定屏幕。所以有如下步骤：
在开机启动目录中新建快捷方式值为：%windir%\system32\rundll32.exe user32.dll,LockWorkStation   
工作流程：windows自动登录--> 运行图形化程序-->自动锁屏

