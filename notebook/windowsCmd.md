<pre>
rsop.msc	-- 组策略和结果集

gpresult /r	--命令行查看组策略结果、

gpupdate /force  --强制更新组策略

nltest /dclist:hs.com	--获取域的DC列表
获得域“hs.com”中 DC 的列表(从“\\HOMSOM-DC-03.hs.com”中)。
     HOMSOM-DC02.hs.com        [DS] 站点: Default-First-Site-Name
     HOMSOM-DC01.hs.com [PDC]  [DS] 站点: Default-First-Site-Name
    HOMSOM-DC-03.hs.com        [DS] 站点: Default-First-Site-Name

nltest /sc_verify:hs.com /server:hs-ua-tsj-0035		--查询<ServerName>上域的安全通道
标志: b0 HAS_IP  HAS_TIMESERV
受信任的 DC 名称 \\homsom-dc01.hs.com
受信任的 DC 连接状态Status = 0 0x0 NERR_Success
信任验证Status = 0 0x0 NERR_Success
此命令成功完成

nltest /sc_query:hs.com /server:hs-ua-tsj-0132		--将 <ServerName> 上 <域> 的安全通道重置为 <DcName>
标志: 30 HAS_IP  HAS_TIMESERV
受信任的 DC 名称 \\HOMSOM-DC02.hs.com
受信任的 DC 连接状态Status = 0 0x0 NERR_Success
此命令成功完成

nltest /sc_reset:hs.com\HOMSOM-DC01.hs.com /server:hs-ua-tsj-0132
标志: 30 HAS_IP  HAS_TIMESERV
受信任的 DC 名称 \\homsom-dc01.hs.com
受信任的 DC 连接状态Status = 0 0x0 NERR_Success
此命令成功完成

nltest /sc_query:hs.com /server:hs-ua-tsj-0132
标志: 30 HAS_IP  HAS_TIMESERV
受信任的 DC 名称 \\homsom-dc01.hs.com
受信任的 DC 连接状态Status = 0 0x0 NERR_Success
此命令成功完成

</pre>
