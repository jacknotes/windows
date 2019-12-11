<?xml version="1.0" encoding="utf-8" ?>
<profile>
	<environments>
		<vt:foreach from="$envs" item="$env" index="$i">
			<add name="{$env.Name}" dataCenter="{$env.DataCenter}" target="{$env.Target}" iis="{$env.IIS}" net="{$env.DotNet}" />
		</vt:foreach>
	</environments>

	<vt:foreach from="$envs" item="$env" index="$i">
		<{$env.Name}>
			<DemoKey>12350</DemoKey>
		</{$env.Name}>
	</vt:foreach>

</profile>

