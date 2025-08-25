## Windows网卡绑定

Windows 系统上的网卡绑定一般称为“网络团队”（NIC Teaming）或者“网络接口聚合”（Link Aggregation）。它允许你把多块物理网卡聚合成一个逻辑网卡，提高带宽和冗余。

### 1. 适用版本

- Windows Server 2012 及以上版本内置支持 NIC Teaming
- Windows 10 专业版和企业版某些版本支持
- 需要网卡驱动支持团队功能

------

### 2. 通过 GUI 配置（以 Windows Server 2016/2019 为例）

1. 打开 **服务器管理器** → 点击左侧 **本地服务器**
2. 找到 **NIC Teaming**（默认是关闭）点击右侧的“关闭”链接进入配置界面
3. 点击 **Tasks** → **New Team**
4. 给团队起名字（例如 Team1）
5. 选择要绑定的物理网卡（Ctrl 多选）
6. 点击 **Additional properties**，选择团队模式：
   - **Switch Independent**（独立交换机模式，兼容性好，主备冗余）
   - **LACP (Link Aggregation Control Protocol)**（需要交换机支持）
   - **Static Teaming**（静态绑定，需要交换机配置静态聚合）
7. 选择负载均衡模式（如地址散列、动态）
8. 点击确定完成创建

------

### 3. 通过 PowerShell 配置

打开 PowerShell（管理员权限），执行：

```powershell
# 创建一个名为 Team1 的团队，绑定网卡 Ethernet1 和 Ethernet2，模式为 SwitchIndependent
New-NetLbfoTeam -Name Team1 -TeamMembers Ethernet1,Ethernet2 -TeamingMode SwitchIndependent -LoadBalancingAlgorithm TransportPorts

# 查看团队状态
Get-NetLbfoTeam

# 查看团队成员网卡状态
Get-NetLbfoTeamMember -TeamName Team1
```

其他 `-TeamingMode` 参数可用值：

- `SwitchIndependent`
- `LACP`
- `Static`

------



### 4. 注意事项

- 确保网卡驱动支持 NIC Teaming
- 如果用 LACP 或 Static，需要交换机端也对应配置聚合端口
- 在虚拟机环境（如 Hyper-V），也支持类似的虚拟交换机聚合
- 配置前建议备份网络设置，避免失联



### 5. powershell脚本

```powershell
# PowerShell 脚本：自动创建 NIC Teaming
# 运行前请以管理员身份打开 PowerShell

# 配置参数 - 请根据实际修改
$teamName = "Team1"                   # 团队名称
$teamMembers = @("Ethernet1","Ethernet2")  # 绑定的物理网卡名称，数组形式
$teamingMode = "SwitchIndependent"    # 模式：SwitchIndependent, LACP, Static
$loadBalancingAlgorithm = "TransportPorts"  # 负载均衡算法，如 TransportPorts, IPAddresses, MacAddresses, HyperVPort, Dynamic

# 检查是否已存在同名团队，存在则先删除
if (Get-NetLbfoTeam -Name $teamName -ErrorAction SilentlyContinue) {
    Write-Host "已存在同名团队 $teamName，先删除..."
    Remove-NetLbfoTeam -Name $teamName -Confirm:$false
}

# 创建团队
Write-Host "创建团队 $teamName，绑定网卡：$($teamMembers -join ', ')"
New-NetLbfoTeam -Name $teamName -TeamMembers $teamMembers -TeamingMode $teamingMode -LoadBalancingAlgorithm $loadBalancingAlgorithm

# 显示创建结果
Write-Host "团队创建完成，团队信息："
Get-NetLbfoTeam -Name $teamName | Format-List *

Write-Host "团队成员信息："
Get-NetLbfoTeamMember -TeamName $teamName | Format-Table -AutoSize
```

**使用说明：**

1. 保存为 `Create-NICTeam.ps1`

2. 右键“以管理员身份运行 PowerShell”

3. 运行脚本：

   ```powershell
   .\Create-NICTeam.ps1
   ```

4. 根据需要，修改脚本顶部的变量：`$teamName`、`$teamMembers`、`$teamingMode`、`$loadBalancingAlgorithm`