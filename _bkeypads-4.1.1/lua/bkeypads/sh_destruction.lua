hook.Add("loadCustomDarkRPItems", "bKeypads.DestructionItems", function()

	local batteryConfig = table.Copy(bKeypads.Config.KeypadDestruction.DarkRP.Battery)
	if not batteryConfig.Disabled then
		local batteryItemName = batteryConfig.Name
		batteryConfig.Disabled = nil
		batteryConfig.Name = nil

		batteryConfig.ent = "bkeypads_repair"
		batteryConfig.model = "models/items/battery.mdl"
		batteryConfig.price = batteryConfig.price or 500
		batteryConfig.max = batteryConfig.max or 0
		batteryConfig.cmd = batteryConfig.cmd or "buykeypadbattery"

		DarkRP.createEntity(batteryItemName, batteryConfig)
	end

	local shieldBatteryConfig = table.Copy(bKeypads.Config.KeypadDestruction.DarkRP.ShieldBattery)
	if not shieldBatteryConfig.Disabled then
		local shieldBatteryItemName = shieldBatteryConfig.Name
		shieldBatteryConfig.Disabled = nil
		shieldBatteryConfig.Name = nil

		shieldBatteryConfig.ent = "bkeypads_shield"
		shieldBatteryConfig.model = "models/items/battery.mdl"
		shieldBatteryConfig.price = shieldBatteryConfig.price or 1000
		shieldBatteryConfig.max = shieldBatteryConfig.max or 0
		shieldBatteryConfig.cmd = shieldBatteryConfig.cmd or "buykeypadshield"

		DarkRP.createEntity(shieldBatteryItemName, shieldBatteryConfig)
	end

end)