local function Override()
	local ents = {}
	F4Menu.Overwritten = true

	if SERVER then

		util.AddNetworkString("F4Menu.SyncEntLimit")

		hook.Add("PlayerDisconnect", "F4Menu.RemoveLimits", function(ply)
			ents[ply] = nil

			net.Start("DarkRP_DarkRPVarDisconnect")
			net.WriteUint(ply:UserID(), 16)
			net.Broadcast()
		end)
	end

	if CLIENT then
		net.Receive("F4Menu.SyncEntLimit", function(len)
			local ply = LocalPlayer()
			local cmd = net.ReadString()
			local increment = net.ReadBool()

			if increment then
				ply:addCustomEntity({
				cmd = cmd })
			else
				ply:removeCustomEntity({
				cmd = cmd })
			end
		end)
	end

	local PLY = FindMetaTable("Player")

	function PLY:addCustomEntity(tbl)
		if (!tbl) then return end
		local cmd = tbl.cmd

		ents[self] = ents[self] or {}
		ents[self][cmd] = ents[self][cmd] or 0
		ents[self][cmd] = ents[self][cmd] + 1

		if SERVER then
			net.Start("F4Menu.SyncEntLimit")
			net.WriteString(cmd)
			net.WriteBool(true)
			net.Send(self)
		end
	end

	function PLY:removeCustomEntity(tbl)
		if (!tbl) then return end
		if (!tbl.cmd) then return end
		local cmd = tbl.cmd

		ents[self] = ents[self] or {}
		ents[self][cmd] = ents[self][cmd] or 0
		ents[self][cmd] = ents[self][cmd] - 1

		if SERVER then
			net.Start("F4Menu.SyncEntLimit")
			net.WriteString(cmd)
			net.WriteBool(false)
			net.Send(self)
		end
	end

	function PLY:customEntityLimitReached(tbl)
		if (!tbl) then return end
		local cmd = tbl.cmd

		ents[self] = ents[self] or {}
		ents[self][cmd] = ents[self][cmd] or 0
		local max = tbl.getMax and tbl.getMax(self) or tbl.max

		return max != 0 and ents[self][cmd] >= max
	end

	function PLY:getCustomEntity(tbl)
		if (!tbl) then return end
		local cmd = tbl.cmd

		ents[self] = ents[self] or {}
		ents[self][cmd] = ents[self][cmd] or 0
		return ents[self][cmd]
	end

	timer.Remove("F4Menu.OverrideDarkRPEntityFunctionality")
end

timer.Create("F4Menu.OverrideDarkRPEntityFunctionality", 5, 0, function()
	if (!F4Menu.Overwritten) then
		Override()
	end
end)
