Get-WmiObject -Class Win32_NetworkAdapter -ComputerName localhost |
Where-Object { $_.physicalAdapter } | Select-Object macaddress,adapterType,DeviceID,Name,Speed