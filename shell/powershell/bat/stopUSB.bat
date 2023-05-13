@echo off 
  
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies" /v WriteProtect /t reg_dword /d 0 /f 
  
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\USBSTOR" /v Start /t reg_dword /d 4 /f 
  
copy %Windir%\inf\usbstor.inf %Windir%\usbstor.inf /y >nul 
copy %Windir%\inf\usbstor.pnf %Windir%\usbstor.pnf /y >nul 
del %Windir%\inf\usbstor.pnf /q/f >nul 
del %Windir%\inf\usbstor.inf /q/f >nul 
@echo on 
