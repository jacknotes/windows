@echo off 
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\USBSTOR" /v Start /t reg_dword /d 3 /f   

copy %Windir%\usbstor.inf %Windir%\inf\usbstor.inf /y >nul
copy %Windir%\usbstor.pnf %Windir%\inf\usbstor.pnf /y >nul
del %Windir%\usbstor.pnf /q/f >nul
del %Windir%\usbstor.inf /q/f >nul
@echo on