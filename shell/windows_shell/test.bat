@::关闭回显
@echo off
if "%1" == "linux" (echo "%1") else (echo "hehe")

goto start
:start
set yes=0
set no=0
set cancel=0

for %%i in (%yes%,%no%,%cancel%) do echo "init  variable values is %%i"

choice /c ync /t 10 /d y /n /m "确认请按Y，否请按N，取消请按C"
if errorlevel 3 goto cancel
if errorlevel 2 goto no
if errorlevel 1 goto yes

:yes
echo "input is yes"
set yes=1
goto end

:no
echo "input is no"
set no=2
goto end

:cancel
echo "input is cancel"
set cancel=3
goto end

:end
if %yes% ==1 (echo "your choice is yes，value is %yes%") 
if %no% ==2 (echo "your choice is no，value is %no%") 
if %cancel% ==3 (echo "your choice is cancel，value is %cancel%") 
goto start

