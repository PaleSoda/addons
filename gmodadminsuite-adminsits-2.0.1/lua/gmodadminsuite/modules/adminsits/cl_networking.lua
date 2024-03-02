local function L(phrase)
	return GAS:Phrase(phrase, "adminsits")
end

GAS.AdminSits.SitPlayers = GAS:Registry()
local function IsInSit()
	GAS.AdminSits.SitPlayers(net.ReadEntity(), net.ReadBool() or nil)
end
GAS:netReceive("AdminSits.IsInSit", IsInSit)

local function IsInSitArray()
	local in_sit = net.ReadBool()
	for i=1,net.ReadUInt(7) do
		GAS.AdminSits.SitPlayers(net.ReadEntity(), in_sit or nil)
	end
end
GAS:netReceive("AdminSits.IsInSit[]", IsInSitArray)

local function NotAllowedInSit()
	GAS:PlaySound("flash")
	notification.AddLegacy(L"NotAllowedInSit", NOTIFY_ERROR, 2)
end
GAS:netReceive("AdminSits.NotAllowedInSit", NotAllowedInSit)

local function DisconnectedPlayerReconnected()
	local ply = net.ReadEntity()
	local sit_id = net.ReadUInt(16)

	local chatTable = {
		GAS_PRINT_COLOR_NEUTRAL,
		"[GmodAdminSuite] ",
		"[" .. L"module_name" .. "] ",
		bVGUI.COLOR_WHITE,
	}
	for _,s in ipairs(string.Explode(" ", L"DisconnectedPlayerReconnected")) do
		if (s == "PLY_NAME") then
			table.insert(chatTable, team.GetColor(ply:Team()))
			table.insert(chatTable, ply:Nick() .. " ")
			table.insert(chatTable, bVGUI.COLOR_WHITE)
		elseif (s == "PLY_STEAMID") then
			table.insert(chatTable, team.GetColor(ply:Team()))
			table.insert(chatTable, "[" .. ply:SteamID() .. "] ")
			table.insert(chatTable, bVGUI.COLOR_WHITE)
		elseif (s == "SIT_ID") then
			table.insert(chatTable, Color(66, 115, 217))
			table.insert(chatTable, "#" .. sit_id .. " ")
			table.insert(chatTable, bVGUI.COLOR_WHITE)
		else
			table.insert(chatTable, s .. " ")
		end
	end

	GAS:PlaySound("flash")
	chat.AddText(unpack(chatTable))
end
GAS:netReceive("AdminSits.DisconnectedPlayerReconnected", DisconnectedPlayerReconnected)

local function NoSitPosition()
	GAS:PlaySound("error")
	notification.AddLegacy(L"NoSitPosition", NOTIFY_ERROR, 10)
end
GAS:netReceive("AdminSits.NoSitPosition", NoSitPosition)

local function PlayerMayBeStuck()
	local ply = net.ReadEntity()

	local chatTable = {
		GAS_PRINT_COLOR_NEUTRAL,
		"[GmodAdminSuite] ",
		"[" .. L"module_name" .. "] ",
		bVGUI.COLOR_WHITE,
	}
	for _,s in ipairs(string.Explode(" ", L"PlayerMayBeStuck")) do
		if (s == "PLY_NAME") then
			table.insert(chatTable, team.GetColor(ply))
			table.insert(chatTable, ply:Nick() .. " ")
			table.insert(chatTable, bVGUI.COLOR_WHITE)
		else
			table.insert(chatTable, s .. " ")
		end
	end

	GAS:PlaySound("flash")
	chat.AddText(unpack(chatTable))
end
GAS:netReceive("AdminSits.PlayerMayBeStuck", PlayerMayBeStuck)

do
	if (system.IsWindows() or system.IsLinux()) then
		local WindowHasFocus
		local function WindowFocus()
			local HasFocus = system.HasFocus()
			if (HasFocus ~= WindowHasFocus) then
				WindowHasFocus = HasFocus
				GAS:netStart("AdminSits.WindowFocus")
					net.WriteBool(HasFocus)
				net.SendToServer()
			end
		end
		local function TransmitWindowFocus()
			GAS:hook("Think", "AdminSits.WindowFocus", WindowFocus)
		end
		GAS:InitPostEntity(TransmitWindowFocus)
	end

	GAS.AdminSits.SitPlayersWindowFocus = {}
	local function SitPlayersWindowFocus()
		GAS.AdminSits.SitPlayersWindowFocus[net.ReadEntity()] = net.ReadBool() and nil
	end
	GAS:netReceive("AdminSits.WindowFocus", SitPlayersWindowFocus)
end

GAS.AdminSits.SitPlayersTimingOut = {}
local function SitPlayersTimingOut()
	GAS.AdminSits.SitPlayersTimingOut[net.ReadEntity()] = net.ReadBool() or nil
end
GAS:netReceive("AdminSits.TimingOut", SitPlayersTimingOut)

local function TransmitCountry()
	local country = system.GetCountry()
	if (country ~= nil and country ~= "XX" and #country == 2) then
		GAS:netStart("AdminSits.GetCountry")
			net.WriteString(country)
		net.SendToServer()
	end
end
GAS:InitPostEntity(TransmitCountry)

local function TransmitOS()
	local OSEnum
	if (system.IsWindows()) then
		OSEnum = 0
	elseif (system.IsLinux()) then
		OSEnum = 1
	elseif (system.IsOSX()) then
		OSEnum = 2
	end
	if (OSEnum) then
		GAS:netStart("AdminSits.GetOS")
			net.WriteUInt(OSEnum, 2)
		net.SendToServer()
	end
end
GAS:InitPostEntity(TransmitOS)

GAS:netReceive("AdminSits.FlashWindow", system.FlashWindow)

local function CheckPocket()
	local ply = net.ReadEntity()
	local items = net.ReadUInt(16)
	if (items > 0) then
		local msg = ""
		local itemQuantities = {}
		local itemNames = GAS:Registry()
		for i=1,items do
			local item = net.ReadString()
			itemQuantities[item] = (itemQuantities[item] or 0) + 1
			itemNames(item, true)
		end
		table.sort(itemNames:sequential())
		for _,item in ipairs(itemNames:sequential()) do
			msg = msg .. "x" .. itemQuantities[item] .. " " .. item .. "\n"
		end
		Derma_Message(msg:sub(1,-2), L"CheckPocket" .. " - " .. ply:Nick(), L"Dismiss")
	else
		Derma_Message(L"CheckPocketNone", L"CheckPocket" .. " - " .. ply:Nick(), L"Dismiss")
	end
end
GAS:netReceive("AdminSits.CheckPocket", CheckPocket)

local function CheckSteamFamilySharing()
	local ply = net.ReadEntity()
	local statusCode = net.ReadUInt(2)
	if (statusCode == 0) then
		Derma_Message(L"NoSteamAPIKey", L"CheckSteamFamShare" .. " - " .. ply:Nick(), L"Dismiss")
	elseif (statusCode == 1) then
		Derma_Message(L"CheckSteamFamilySharing_Error", L"CheckSteamFamShare" .. " - " .. ply:Nick(), L"Dismiss")
	elseif (statusCode == 2) then
		if (net.ReadBool()) then
			local account_id = net.ReadUInt(32)
			local fam = player.GetByAccountID(account_id)
			if (IsValid(fam)) then
				Derma_Message((L"CheckSteamFamilySharingYes"):format(ply:Nick(), fam:Nick()), L"CheckSteamFamShare" .. " - " .. ply:Nick(), L"Dismiss")
			else
				Derma_Query((L"CheckSteamFamilySharingYes"):format(ply:Nick(), GAS:AccountIDToSteamID(account_id)), L"CheckSteamFamShare" .. " - " .. ply:Nick(), L"Dismiss", nil, L"SteamProfile", function()
					GAS:OpenURL("https://steamcommunity.com/profiles/" .. GAS:AccountIDToSteamID64(account_id))
				end)
			end
		else
			Derma_Message((L"CheckSteamFamilySharingNo"):format(ply:Nick()), L"CheckSteamFamShare" .. " - " .. ply:Nick(), L"Dismiss")
		end
	end
end
GAS:netReceive("AdminSits.CheckSteamFamilySharing", CheckSteamFamilySharing)

local function OpenHelp()
	GAS:OpenURL("https://gmodsto.re/adminsits")
end
GAS:netReceive("AdminSits.OpenHelp", OpenHelp)

local function AllStaffDisconnected()
	GAS:PlaySound("error")
	notification.AddLegacy(L"AllStaffDisconnected", NOTIFY_GENERIC, 5)
end
GAS:netReceive("AdminSits.AllStaffDisconnected", AllStaffDisconnected)

local function AllPlayersDisconnected()
	GAS:PlaySound("error")
	notification.AddLegacy(L"AllPlayersDisconnected2", NOTIFY_GENERIC, 10)
	notification.AddLegacy(L"AllPlayersDisconnected", NOTIFY_GENERIC, 10)
end
GAS:netReceive("AdminSits.AllPlayersDisconnected", AllPlayersDisconnected)

GAS:netReceive("AdminSits.NoPermission", function()
	GAS:PlaySound("error")
	chat.AddText(bVGUI.COLOR_RED, "[GmodAdminSuite] [" .. L"module_name" .. "] ", bVGUI.COLOR_WHITE, L"NoPermission")
end)
GAS:netReceive("AdminSits.NoPermission.TargetStaff", function()
	local target = net.ReadEntity()
	local chatTbl = {
		bVGUI.COLOR_RED,
		"[GmodAdminSuite] [" .. L"module_name" .. "] ",
		bVGUI.COLOR_WHITE
	}
	local str = L"NoPermission_TargetStaff"
	local s,e = str:find("PLY_NAME")
	table.insert(chatTbl, str:sub(0,s-1))
	table.insert(chatTbl, team.GetColor(target:Team()))
	table.insert(chatTbl, target:Nick())
	table.insert(chatTbl, bVGUI.COLOR_WHITE)
	table.insert(chatTbl, str:sub(e+1))
	chat.AddText(unpack(chatTbl))
end)
GAS:netReceive("AdminSits.ChatCommand.MultipleMatches", function()
	local argCount = net.ReadUInt(7)

	local chatTbl = {
		bVGUI.COLOR_RED,
		"[GmodAdminSuite] [" .. L"module_name" .. "] ",
		bVGUI.COLOR_WHITE
	}
	local str = L"ChatCommand_MultipleMatches"

	local s,e = str:find("ARG_COUNT")
	table.insert(chatTbl, str:sub(0,s-1))
	table.insert(chatTbl, Color(255,130,130))
	table.insert(chatTbl, tostring(argCount))
	table.insert(chatTbl, bVGUI.COLOR_WHITE)

	local s2,e2 = str:find("MATCH_FAILS")
	table.insert(chatTbl, str:sub(e+1,s2-1))

	for i=1,argCount do
		local arg = net.ReadString()
		table.insert(chatTbl, Color(255,130,130))
		table.insert(chatTbl, arg)
		table.insert(chatTbl, bVGUI.COLOR_WHITE)

		local matchCount = net.ReadUInt(7)
		table.insert(chatTbl, " (")
		for i=1,matchCount do
			local target = net.ReadEntity()
			table.insert(chatTbl, team.GetColor(target:Team()))
			table.insert(chatTbl, target:Nick())
			table.insert(chatTbl, bVGUI.COLOR_WHITE)
			if (i ~= matchCount) then table.insert(chatTbl, ", ") end
		end
		table.insert(chatTbl, ")")
		if (i ~= argCount) then table.insert(chatTbl, ", ") end
	end
	table.insert(chatTbl, str:sub(e2+1))

	chat.AddText(unpack(chatTbl))
end)
GAS:netReceive("AdminSits.ChatCommand.MatchFailed", function()
	local matchFailCount = net.ReadUInt(7)

	local chatTbl = {
		bVGUI.COLOR_RED,
		"[GmodAdminSuite] [" .. L"module_name" .. "] ",
		bVGUI.COLOR_WHITE
	}
	local str = "ChatCommand_MatchFailed"
	if (matchFailCount > 1) then str = "ChatCommand_MatchFailed_Plural" end
	str = L(str)

	local s,e = str:find("MATCH_COUNT")
	table.insert(chatTbl, str:sub(0,s-1))
	table.insert(chatTbl, Color(255,130,130))
	table.insert(chatTbl, tostring(matchFailCount))
	table.insert(chatTbl, bVGUI.COLOR_WHITE)

	local s2,e2 = str:find("MATCH_FAILS")
	table.insert(chatTbl, str:sub(e+1,s2-1))

	for i=1,matchFailCount do
		local arg = net.ReadString()
		table.insert(chatTbl, Color(255,130,130))
		table.insert(chatTbl, arg)
		table.insert(chatTbl, bVGUI.COLOR_WHITE)
		if (i ~= matchFailCount) then table.insert(chatTbl, ", ") end
	end
	table.insert(chatTbl, str:sub(e2+1))

	chat.AddText(unpack(chatTbl))
end)
GAS:netReceive("AdminSits.ChatCommand.AlreadyInSit", function()
	local target = net.ReadEntity()
	local chatTbl = {
		bVGUI.COLOR_RED,
		"[GmodAdminSuite] [" .. L"module_name" .. "] ",
		bVGUI.COLOR_WHITE
	}
	local str = L"ChatCommand_AlreadyInSit"
	local s,e = str:find("PLY_NAME")
	table.insert(chatTbl, str:sub(0,s-1))
	table.insert(chatTbl, team.GetColor(target:Team()))
	table.insert(chatTbl, target:Nick())
	table.insert(chatTbl, bVGUI.COLOR_WHITE)
	table.insert(chatTbl, str:sub(e+1))
	chat.AddText(unpack(chatTbl))
end)
GAS:netReceive("AdminSits.ChatCommand.Clash", function()
	chat.AddText(bVGUI.COLOR_RED, "[GmodAdminSuite] [" .. L"module_name" .. "] ", bVGUI.COLOR_WHITE, L"ChatCommand_Clash")
end)
GAS:netReceive("AdminSits.ChatCommand.Clash.AddToSit", function()
	local target = net.ReadEntity()
	local arg = net.ReadString()

	local chatTbl = {
		bVGUI.COLOR_RED,
		"[GmodAdminSuite] [" .. L"module_name" .. "] ",
		bVGUI.COLOR_WHITE
	}
	local str = L"ChatCommand_Clash_RemoveFromSit"

	local s,e = str:find("PLY_NAME")
	table.insert(chatTbl, str:sub(0,s-1))
	table.insert(chatTbl, team.GetColor(target:Team()))
	table.insert(chatTbl, target:Nick())
	table.insert(chatTbl, bVGUI.COLOR_WHITE)

	local s2,e2 = str:find("MATCH_FAIL")
	table.insert(chatTbl, str:sub(e+1,s2-1))
	table.insert(chatTbl, Color(255,130,130))
	table.insert(chatTbl, arg)
	table.insert(chatTbl, bVGUI.COLOR_WHITE)
	table.insert(chatTbl, str:sub(e2+1))

	chat.AddText(unpack(chatTbl))
end)
GAS:netReceive("AdminSits.ChatCommand.Clash.RemoveFromSit", function()
	local target = net.ReadEntity()
	local arg = net.ReadString()

	local chatTbl = {
		bVGUI.COLOR_RED,
		"[GmodAdminSuite] [" .. L"module_name" .. "] ",
		bVGUI.COLOR_WHITE
	}
	local str = L"ChatCommand_Clash_AddToSit"

	local s,e = str:find("PLY_NAME")
	table.insert(chatTbl, str:sub(0,s-1))
	table.insert(chatTbl, team.GetColor(target:Team()))
	table.insert(chatTbl, target:Nick())
	table.insert(chatTbl, bVGUI.COLOR_WHITE)

	local s2,e2 = str:find("MATCH_FAIL")
	table.insert(chatTbl, str:sub(e+1,s2-1))
	table.insert(chatTbl, Color(255,130,130))
	table.insert(chatTbl, arg)
	table.insert(chatTbl, bVGUI.COLOR_WHITE)
	table.insert(chatTbl, str:sub(e2+1))

	chat.AddText(unpack(chatTbl))
end)

local function ShowDisconnectReason()
	local nick = net.ReadString()
	local reason = net.ReadString()

	local chatTbl = {
		bVGUI.COLOR_RED,
		"[GmodAdminSuite] [" .. L"module_name" .. "] ",
		bVGUI.COLOR_WHITE
	}
	
	if (#reason == 0 or reason == "disconnected") then
		local str = L"ShowDisconnectReason_NoReason"

		local s,e = str:find("PLY_NAME")
		table.insert(chatTbl, str:sub(0,s-1))
		table.insert(chatTbl, Color(255,255,100))
		table.insert(chatTbl, nick)
		table.insert(chatTbl, bVGUI.COLOR_WHITE)
		table.insert(chatTbl, str:sub(e+1))
	else
		local str = L"ShowDisconnectReason"

		local s,e = str:find("PLY_NAME")
		table.insert(chatTbl, str:sub(0,s-1))
		table.insert(chatTbl, Color(255,255,100))
		table.insert(chatTbl, nick)
		table.insert(chatTbl, bVGUI.COLOR_WHITE)

		local s2,e2 = str:find("DISCONNECT_REASON")
		table.insert(chatTbl, str:sub(e+1,s2-1))
		table.insert(chatTbl, Color(255,130,130))
		table.insert(chatTbl, reason)
		table.insert(chatTbl, bVGUI.COLOR_WHITE)
		table.insert(chatTbl, str:sub(e2+1))
	end

	chat.AddText(unpack(chatTbl))
end
GAS:netReceive("AdminSits.PlayerDisconnected", ShowDisconnectReason)

local function InviteSent()
	local target = net.ReadEntity()

	local chatTbl = {
		Color(0,255,0),
		"[GmodAdminSuite] [" .. L"module_name" .. "] ",
		bVGUI.COLOR_WHITE
	}
	
	local str = L"ChatCommand_InviteSent"

	local s,e = str:find("PLY_NAME")
	table.insert(chatTbl, str:sub(0,s-1))
	table.insert(chatTbl, team.GetColor(target:Team()))
	table.insert(chatTbl, target:Nick())
	table.insert(chatTbl, bVGUI.COLOR_WHITE)
	table.insert(chatTbl, str:sub(e+1))

	chat.AddText(unpack(chatTbl))
end
GAS:netReceive("AdminSits.InviteSent", InviteSent)

GAS:netReceive("AdminSits.CmdFailed", function()
	GAS:PlaySound("error")
end)

GAS:netReceive("AdminSits.SitPos.Failed", function()
	GAS:PlaySound("error")

	chat.AddText(
		bVGUI.COLOR_RED,
		"[GmodAdminSuite] [" .. L"module_name" .. "] ",
		bVGUI.COLOR_WHITE,
		L"SitPosFailed"
	)
end)
GAS:netReceive("AdminSits.SitPos.Success", function()
	GAS:PlaySound("success")

	chat.AddText(
		Color(0,255,0),
		"[GmodAdminSuite] [" .. L"module_name" .. "] ",
		bVGUI.COLOR_WHITE,
		L"SitPosSuccess"
	)
end)

do
	for i=1,9 do
		if (i ~= 4) then
			util.PrecacheSound("ambient/energy/zap" .. i .. ".wav")
		end
	end

	local function Zap()
		local tpPosition = net.ReadVector()
		local ply = net.ReadEntity()

		local zapEffect = EffectData()
		zapEffect:SetStart(tpPosition)
		zapEffect:SetOrigin(tpPosition)
		zapEffect:SetMagnitude(1)
		zapEffect:SetScale(3)
		zapEffect:SetRadius(1)
		zapEffect:SetEntity(ply)

		for i=1,100 do
			timer.Simple(1 / i, function()
				util.Effect("TeslaHitBoxes", zapEffect, true, true)
			end)
		end

		local zap = math.random(1,9)
		if (zap == 4) then zap = 3 end
		ply:EmitSound("ambient/energy/zap" .. zap .. ".wav")
	end
	GAS:netReceive("AdminSits.Zap", Zap)

	local function VortDispel()
		local tpPosition = net.ReadVector()

		local effectData = EffectData()
		effectData:SetOrigin(tpPosition)
		effectData:SetMagnitude(1)
		effectData:SetRadius(1)
		effectData:SetScale(3)
		util.Effect("VortDispel", effectData, true, true)

		local zap = math.random(1,9)
		if (zap == 4) then zap = 3 end
		sound.Play("ambient/energy/zap" .. zap .. ".wav", tpPosition)
	end
	GAS:netReceive("AdminSits.VortDispel", VortDispel)
end

GAS:InitPostEntity(function()
	GAS:netStart("AdminSits.NetworkingReady")
	net.SendToServer()
end)