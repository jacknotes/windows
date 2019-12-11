<?xml version="1.0" encoding="utf-8" ?>
<profile>
	<environments>
		<vt:foreach from="$envs" item="$env" index="$i">
			<add name="{$env.ConfigEnv}" dataCenter="{$env.DataCenter}" target="{$env.Target}" iis="{$env.IIS}" net="{$env.DotNet}" />
		</vt:foreach>
	</environments>

	<vt:foreach from="$envs" item="$env" index="$i">
    <{$env.ConfigEnv}>
      <vt:foreach from="$env.ProfileKeyValue" item="$KeyValue" index="$c">
        <{$KeyValue.Key}>{$KeyValue.Value}</{$KeyValue.Key}>
      </vt:foreach>
		</{$env.ConfigEnv}>
	</vt:foreach>

</profile>

