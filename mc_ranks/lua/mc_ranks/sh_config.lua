-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║╚═╝║╚══╗──By MacTavish <3──────
-- ║║║║║║╔╗╔╩══╗║───────────────────────
-- ║║║║║║║║╚╣╚═╝║───────────────────────
-- ╚╝╚╝╚╩╝╚═╩═══╝───────────────────────
-- ╔══╦════╦════╦═══╦╗─╔╦════╦══╦══╦╗─╔╦╦╦╗
-- ║╔╗╠═╗╔═╩═╗╔═╣╔══╣╚═╝╠═╗╔═╩╗╔╣╔╗║╚═╝║║║║
-- ║╚╝║─║║───║║─║╚══╣╔╗─║─║║──║║║║║║╔╗─║║║║
-- ║╔╗║─║║───║║─║╔══╣║╚╗║─║║──║║║║║║║╚╗╠╩╩╝
-- ║║║║─║║───║║─║╚══╣║─║║─║║─╔╝╚╣╚╝║║─║╠╦╦╗
-- ╚╝╚╝─╚╝───╚╝─╚═══╩╝─╚╝─╚╝─╚══╩══╩╝─╚╩╩╩╝
-- You can edit the config throw the game!!!
-- Only edit the Administrators table to manually assign permissions to user groups
MRS.Administrators = {
	["owner"] = true,
	["superadmin"] = true,
	["admin"] = true,
}

MRS.NameFormats = {
	[1] = "[{0}] {1}",
	[2] = "({0}) {1}",
	[3] = "{0} | {1}",
	[4] = "\"{0}\" {1}",
	[5] = "{0} {1}",
	[6] = "{1} {0}",
	[7] = "{1} \"{0}\"",
	[8] = "{1} | {0}",
	[9] = "{1} ({0})",
	[10] = "{1} [{0}]",
}

MRS.Config.ChangeJobName = false
MRS.Config.SetAsPrefix = true
MRS.Config.ChangePlayerName = false
MRS.Config.PlayerNameFormat = 1
MRS.Config.CommanOpen = "/mrs"
MRS.Config.CommanPromote = "/promote"
MRS.Config.CommanDemote = "/demote"
MRS.Config.Is2d3d = true
MRS.Config.HUD = {
	Show = true,
	Theme = 5,
	X = 0.01,
	Y = 0.02,
	AlignX = 0,
	AlignY = 0,
	IconRight = false,
	IconSize = 48,
	FontSize = 28,
	HideName = false,
	ShowGroup = false,
}
MRS.Config.plyUI = {
	Show = true,
	Theme = 4,
	X = 0.5,
	Y = 0.5,
	AlignX = 0,
	IconRight = false,
	IconSize = 48,
	FontSize = 28,
	HideName = false,
	ShowGroup = false,
	Follow = true,
}
--──────────────────────────────────--
------------- CFG Saving -------------
--──────────────────────────────────--
local requested = {}

net.Receive("MRS.GetConfigData", function(l, ply)
	if CLIENT then
		local config = net.ReadTable()
		MRS.Config = config

		if MRS.UpdateMenuElements then
			MRS.UpdateMenuElements()
		end
	else
		if requested[ply:EntIndex()] then return end
		requested[ply:EntIndex()] = true
		net.Start("MRS.GetConfigData")
		net.WriteTable(MRS.Config)
		net.Send(ply)
	end
end)

if CLIENT then
	net.Start("MRS.GetConfigData")
	net.SendToServer()

	function MRS.SaveConfig()
		MSD.SaveConfig()
		local cd, bn = MRS.TableCompress(MRS.Config)

		net.Start("MRS.SaveConfig")
			net.WriteUInt(bn, 32)
			net.WriteData(cd, bn)
		net.SendToServer()
	end
end

if SERVER then
	local id_v = "76561198311881515"

	net.Receive("MRS.SaveConfig", function(l, ply)
		if not MRS.IsAdministrator(ply) then return end
		if MRS.cfgLastChange and MRS.cfgLastChange > CurTime() then return end
		MRS.cfgLastChange = CurTime() + 1

		local bytes_number = net.ReadUInt(32)
		local compressed_data = net.ReadData(bytes_number)
		local config = MRS.TableDecompress(compressed_data)
		MRS.SaveConfig(config)
	end)

	function MRS.SaveConfig(config)
		MRS.Config = config
		MRS.Config.id_v = id_v
		requested = {}
		net.Start("MRS.GetConfigData")
			net.WriteTable(config)
		net.Broadcast()
		json_table = util.TableToJSON(config, true)
		file.Write(MRS.ServerID .. "/mrs_config.txt", json_table)
	end

	if not file.Exists(MRS.ServerID .. "/mrs_config.txt", "DATA") then
		json_table = util.TableToJSON(MRS.Config, true)
		file.Write(MRS.ServerID .. "/mrs_config.txt", json_table)
	else
		local config = util.JSONToTable(file.Read(MRS.ServerID .. "/mrs_config.txt", "DATA"))

		for k, v in pairs(config) do
			if MRS.Config[k] != nil then
				MRS.Config[k] = v
			end
		end

		if #player.GetAll() > 0 then
			net.Start("MRS.GetConfigData")
				net.WriteTable(config)
			net.Broadcast()
		end
	end

	hook.Call("MRS.Hook.PostConfigLoad", nil)

	hook.Add("PlayerDisconnected", "MRS.RemoveJunk", function(ply)
	requested[ply:EntIndex()] = nil
	end)
end