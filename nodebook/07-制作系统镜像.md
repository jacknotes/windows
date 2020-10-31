# WinPe 制作

基于 Windows10 1909 制作

1. 下载安装 [ADK for Windows 10, version 2004](https://go.microsoft.com/fwlink/?linkid=2120254)

2. 下载安装 [Windows PE add-on for the ADK, version 2004](https://go.microsoft.com/fwlink/?linkid=2120253)

3. 提权运行`部署和映像工具环境`

4. 创建工作文件

   ```
   copype amd64 C:\WinPE_amd64
   ```
   
5. 添加 Powershell 脚本支持

    ```
    Dism /Mount-Image /ImageFile:"C:\WinPE_amd64\media\sources\boot.wim" /Index:1 /MountDir:"C:\WinPE_amd64\mount"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-WMI.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-WMI_en-us.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-NetFX.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-NetFX_en-us.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-Scripting.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-Scripting_en-us.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-PowerShell.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-PowerShell_en-us.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-StorageWMI.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-StorageWMI_en-us.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-DismCmdlets.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-DismCmdlets_en-us.cab"
    Dism /Unmount-Image /MountDir:C:\WinPE_amd64\mount /Commit
    ```

6. 创建可启动介质

    可在运行**MakeWinPEMedia**前格式化U盘。**MakeWinPEMedia**会将 WinPE驱动器格式化为FAT32。如果希望能够在WinPE U盘上存储大于4GB的文件，则可以创建多分区U盘，其具有一个附加分区，格式为 NTFS。

    使用带有`/UFD`选项的**MakeWinPEMedia**格式化Windows PE并将其安装到U盘，同时指定U盘的驱动器号：

    ```
    MakeWinPEMedia /UFD C:\WinPE_amd64 P:
    ```
	或生成ISO-PE
	```
	MakeWinPEMedia /iso C:\WinPE_amd64 F:\homsomPE.iso
	```

# 制作自定义 Wim 文件并使用WinPE部署

1. 在虚拟机中安装 Windows 10 作为参考系统

2. 在参考系统中安装所需要用到的软件（必须为安装到所有用户）

3. 通用化系统并将其引导到OOBE

   ```
   Sysprep /generalize /oobe /shutdown
   ```

4. 启动 WinPE 并捕获参考系统的映像

   ```
   Dism /Capture-Image /ImageFile:"D:\Images\Homsom.wim" /CaptureDir:C:\ /Name:Homsom
   ```

5. 应用映像

   使用 WinPE 启动目标设备

   使用脚本擦除硬盘驱动器并设置新的分区

   ```
   deploy.bat
   ```

   使用脚本应用映像

   ```
   D:\ApplyImage.bat D:\Images\Homsom.wim
   ```

6. 重新启动目标设备并进行初始化设置

