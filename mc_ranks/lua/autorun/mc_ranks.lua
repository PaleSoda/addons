-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║╚═╝║╚══╗──By MacTavish <3──────
-- ║║║║║║╔╗╔╩══╗║───────────────────────
-- ║║║║║║║║╚╣╚═╝║───────────────────────
-- ╚╝╚╝╚╩╝╚═╩═══╝───────────────────────

MRS = {}
MRS.Config = {}
MRS.Ranks = {}
MRS.PlayerStats = {}
MRS.Version = "1.2.2"
MRS.ServerID = "MRS77656119831188152202ID"
MRS.MainUserID = "76561198311881522"
MRS.DB = {}

if SERVER then
	util.AddNetworkString( "MRS.Notify" )
	util.AddNetworkString( "MRS.TaskNotify" )
	util.AddNetworkString( "MRS.SetPData" )
	util.AddNetworkString( "MRS.GetBigData" )
	util.AddNetworkString( "MRS.DataShare" )
	util.AddNetworkString( "MRS.GetPData" )
	util.AddNetworkString( "MRS.OpenEditor" )
	util.AddNetworkString( "MRS.GetConfigData" )
	util.AddNetworkString( "MRS.SaveConfig" )
	util.AddNetworkString( "MRS.RanksRemove" )
	util.AddNetworkString( "MRS.RanksSubmit" )
	util.AddNetworkString( "MRS.RanksUpdate" )
	util.AddNetworkString( "MRS.GetPlayersRanks" )
	util.AddNetworkString( "MRS.SavePlayerRankList" )
	util.AddNetworkString( "MRS.RequestStoredData" )
	resource.AddWorkshop( "2689168958" )
end

function MRS.Load()
	MsgC(Color(0, 255, 0), "[MRS] Initialization started\n")

	if not file.Exists(MRS.ServerID, "DATA") then
		file.CreateDir(MRS.ServerID)
		MsgC(Color(0, 255, 0), "[MRS] Server DATA Dir created \n")
	end

	MsgC(Color(0, 255, 0), "[MRS] Initialization started\n")

	if SERVER then
		include("mc_ranks/sh_config.lua")
		AddCSLuaFile("mc_ranks/sh_config.lua")
		local f = file.Find("mc_ranks/core/*", "LUA")

		for _, v in ipairs(f) do
			if string.StartWith(v, "sh_") then
				include("mc_ranks/core/" .. v)
				AddCSLuaFile("mc_ranks/core/" .. v)
			elseif string.StartWith(v, "sv_") then
				include("mc_ranks/core/" .. v)
			elseif string.StartWith(v, "cl_") then
				AddCSLuaFile("mc_ranks/core/" .. v)
			end
		end

		f = file.Find("mc_ranks/ui/*", "LUA")

		for _, v in ipairs(f) do
			AddCSLuaFile("mc_ranks/ui/" .. v)
		end
	else
		include("mc_ranks/sh_config.lua")
		local f = file.Find("mc_ranks/core/*", "LUA")

		for _, v in ipairs(f) do
			if string.StartWith(v, "sh_") then
				include("mc_ranks/core/" .. v)
			elseif string.StartWith(v, "cl_") then
				include("mc_ranks/core/" .. v)
			end
		end

		f = file.Find("mc_ranks/ui/*", "LUA")

		for _, v in ipairs(f) do
			include("mc_ranks/ui/" .. v)
		end
	end

	MsgC(Color(0, 255, 0), "[MRS] Initialization done\n")
end

if SERVER then
	hook.Add("PostGamemodeLoaded", "MRS.Load.SV", function()
		MRS.Load()
	end)
else
	hook.Add("InitPostEntity", "MRS.Load.CL", function()
		MRS.Load()
	end)
end

if GAMEMODE then
	MRS.Load()
end