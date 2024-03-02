-- Some strings and behaviour have been adapted under fair use from
-- https://github.com/willox/gmod-keypad/blob/master/lua/weapons/gmod_tool/stools/keypad_willox.lua
-- https://github.com/willox/gmod-keypad/blob/master/lua/weapons/gmod_tool/stools/keypad_willox_wire.lua
-- This is to simulate behaviour that players are already familiar with; all rights reserved.

local L = bKeypads.L

bKeypads.STOOL = {}
bKeypads.STOOL.RainbowBackgroundColor = 0xFFFFFF+1

--## Spawn menu closure blocking ##--

bKeypads.STOOL.BlockSpawnmenuClose = false
local function BlockSpawnmenuClose()
	if bKeypads.STOOL.BlockSpawnmenuClose then
		RunConsoleCommand("+menu")
	end
end
hook.Add("OnSpawnMenuClose", "bKeypads.BlockSpawnmenuClose", BlockSpawnmenuClose)

local function BlockSpawnmenuClose_BindPress(_, bind, pressed)
	if bKeypads.STOOL.BlockSpawnmenuClose and (bind == "+attack" or bind == "+attack2") and pressed then
		return true
	end
end
hook.Add("PlayerBindPress", "bKeypads.BlockSpawnmenuClose.BindPress", BlockSpawnmenuClose_BindPress)

--## Admin tools ##--

hook.Add("AddToolMenuCategories", "bKeypads.Spawnmenu.Admin", function()
	spawnmenu.AddToolCategory("Admin", "Billy's Keypads", "Billy's Keypads")
end)
hook.Add("PopulateToolMenu", "bKeypads.Spawnmenu.Admin", function()
	spawnmenu.AddToolMenuOption("Admin", "Billy's Keypads", "bKeypads.Persistence", "#bKeypads_Persistence", "gmod_tool bkeypads_persistence", "", bKeypads_Persistence_BuildCPanel)
	spawnmenu.AddToolMenuOption("Admin", "Billy's Keypads", "bKeypads.AdminTool", "#bKeypads_AdminTool", "gmod_tool bkeypads_admin_tool", "", bKeypads_AdminTool_BuildCPanel)
	spawnmenu.AddToolMenuOption("Admin", "Billy's Keypads", "bKeypads.KeypadBreaker", "#tool.bkeypads_breaker.name", "gmod_tool bkeypads_breaker", "", bKeypads_KeypadBreaker_BuildCPanel)
end)

--## CheckLimit convenience function ##--

bKeypads.STOOL.LIMIT_KEYPADS = 0
bKeypads.STOOL.LIMIT_FADING_DOORS = 1
function bKeypads.STOOL:CheckLimit(ply, limitType)
	local max, count

	if limitType == bKeypads.STOOL.LIMIT_KEYPADS then
		max = bKeypads.Config.MaxKeypads[ply:GetUserGroup()] or bKeypads.Config.MaxKeypads["default"] or 0
		count = ply:GetCount("_bkeypads")
	elseif limitType == bKeypads.STOOL.LIMIT_FADING_DOORS then
		max = bKeypads.Config.FadingDoors.Maximum[ply:GetUserGroup()] or bKeypads.Config.FadingDoors.Maximum["default"] or 0
		count = ply:GetCount("_bkeypads_fading_doors")
	end

	if max and count then
		return max == 0 or count < max
	end

	return false
end

--## Utility ##--

local stool_tr = { mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX ) }
local stool_tr_cached
local stool_tr_cached_clock
function bKeypads:GetToolTrace(ply)
	local clock = SERVER and engine.TickCount() or FrameNumber()
	if stool_tr_cached and stool_tr_cached_clock ~= clock then
		stool_tr_cached = nil
	end
	if not stool_tr_cached then
		stool_tr_cached_clock = clock

		stool_tr.start = ply:EyePos()
		stool_tr.endpos = stool_tr.start + (ply:GetAimVector() * (4096 * 8))
		stool_tr.filter = ply

		stool_tr_cached = util.TraceLine(stool_tr)
	end
	return stool_tr_cached
end

--## Keypad STOOL itself ##--

bKeypads.STOOL.Settings = {}

local function print_err_stack(err)
	ErrorNoHalt(err .. "\n")
	debug.Trace()
end

function bKeypads.STOOL.LeftClick(self, tr)
	if not IsFirstTimePredicted() then return end

	local ply = self:GetOwner()
	if not IsValid(ply) then return false end

	if not tr.HitPos or (IsValid(tr.Entity) and tr.Entity:IsPlayer()) then return false end

	local isUpdating = IsValid(tr.Entity) and tr.Entity.bKeypad
	if not isUpdating and not bKeypads.STOOL:CheckLimit(ply, bKeypads.STOOL.LIMIT_KEYPADS) then return true end

	local KeypadOnlyFadingDoors = bKeypads.Config.KeypadOnlyFadingDoors and not bKeypads.Permissions:Check(ply, "keypads/bypass_keypad_only_fading_doors")
	if not isUpdating and KeypadOnlyFadingDoors and (tr.Entity == game.GetWorld() or not bKeypads.FadingDoors:CanFadingDoor(tr.Entity)) then
		return false
	end

	local authMode = self:GetClientNumber("auth_mode")

	if (
		(authMode ~= bKeypads.AUTH_MODE.KEYCARD or not bKeypads.Config.Scanning.ScanMethods.EnableKeycards) and
		(authMode ~= bKeypads.AUTH_MODE.FACEID or not bKeypads.Config.Scanning.ScanMethods.EnableFaceID) and
		(authMode ~= bKeypads.AUTH_MODE.PIN or not bKeypads.Config.Scanning.ScanMethods.EnablePIN)
	) then return false end

	if not bKeypads.Permissions:Check(ply, "access_methods/" .. (
		(authMode == bKeypads.AUTH_MODE.KEYCARD and "keycard") or
		(authMode == bKeypads.AUTH_MODE.FACEID and "faceid") or
		(authMode == bKeypads.AUTH_MODE.PIN and "pin")
	)) then return false end

	local keypad
	local mirrorKeypad
	if SERVER then

		local CreationData = isUpdating and tr.Entity:GetCreationData() or bKeypads.KeypadData:CreationData()
		CreationData.AuthMode = authMode

		CreationData.PIN = authMode == bKeypads.AUTH_MODE.PIN and self:GetClientInfo("pin") or nil

		CreationData.KeypadName = string.sub(self:GetClientInfo("name"), 1, 30)

		CreationData.NoCollide = tobool(self:GetClientNumber("nocollide")) or not bKeypads.Permissions:Check(ply, "keypads/collidable_keypads") or nil
		CreationData.Freeze = tobool(self:GetClientNumber("freeze")) or not bKeypads.Permissions:Check(ply, "keypads/unfrozen_keypads") or nil

		local must_weld = not bKeypads.Permissions:Check(ply, "keypads/unwelded_keypads")
		if KeypadOnlyFadingDoors or (tobool(self:GetClientNumber("weld")) or must_weld) then
			if not isUpdating and (IsValid(tr.Entity) or tr.HitWorld) then
				CreationData.WeldToEnt = tr.Entity
				CreationData.WeldToEntID = tr.Entity:MapCreationID() ~= -1 and tr.Entity:MapCreationID() or nil
				CreationData.WeldBone = tr.PhysicsBone or 0
				CreationData.WeldRemoveOnBreak = KeypadOnlyFadingDoors or nil
			elseif must_weld then
				return false
			end
		else
			CreationData.WeldToEnt = nil
			CreationData.WeldToEntID = nil
		end

		CreationData.Wiremod = tobool(self:GetClientNumber("wiremod")) and bKeypads.Permissions:Check(ply, "keypads/wiremod") or nil -- TODO https://www.gmodstore.com/messages/60657
		CreationData.Uncrackable = tobool(self:GetClientNumber("uncrackable")) and bKeypads.Permissions:Check(ply, "keypads/uncrackable_keypads") or nil

		if not bKeypads.Config.EnableKeyboardPress or not bKeypads.Permissions:Check(ply, "keypads/keyboard_button_simulation") then
			CreationData.GrantedKey = 0
			CreationData.DeniedKey = 0
		else
			CreationData.GrantedKey = self:GetClientNumber("granted_key") or 0
			CreationData.DeniedKey = self:GetClientNumber("denied_key") or 0
		end

		CreationData.GrantedTime = bKeypads.math.min(bKeypads.math.max(self:GetClientNumber("granted_hold_time"), 0, bKeypads.Config.Scanning.AccessGranted.MinimumTime), bKeypads.Config.Scanning.AccessGranted.MaximumTime ~= 0 and bKeypads.Config.Scanning.AccessGranted.MaximumTime or nil)
		CreationData.GrantedDelay = bKeypads.math.max(self:GetClientNumber("granted_initial_delay"), 0)
		CreationData.GrantedRepeats = bKeypads.math.min(bKeypads.math.max(math.Round(self:GetClientNumber("granted_repeats")), 0), bKeypads.Config.Scanning.AccessGranted.MaximumRepeats ~= 0 and bKeypads.Config.Scanning.AccessGranted.MaximumRepeats or nil)
		CreationData.GrantedRepeatDelay = bKeypads.math.max(self:GetClientNumber("granted_repeat_delay"), 0, bKeypads.Config.Scanning.AccessGranted.MinimumRepeatDelay)

		CreationData.DeniedTime = bKeypads.math.min(bKeypads.math.max(self:GetClientNumber("denied_hold_time"), 0, bKeypads.Config.Scanning.AccessDenied.MinimumTime), bKeypads.Config.Scanning.AccessDenied.MaximumTime ~= 0 and bKeypads.Config.Scanning.AccessDenied.MaximumTime or nil)
		CreationData.DeniedDelay = bKeypads.math.max(self:GetClientNumber("denied_initial_delay"), 0)
		CreationData.DeniedRepeats = bKeypads.math.min(bKeypads.math.max(math.Round(self:GetClientNumber("denied_repeats")), 0), bKeypads.Config.Scanning.AccessDenied.MaximumRepeats ~= 0 and bKeypads.Config.Scanning.AccessDenied.MaximumRepeats or nil)
		CreationData.DeniedRepeatDelay = bKeypads.math.max(self:GetClientNumber("denied_repeat_delay"), 0, bKeypads.Config.Scanning.AccessDenied.MinimumRepeatDelay)

		CreationData.ChargeUnauthorized = tobool(self:GetClientNumber("charge_unauthorized")) and bKeypads.Permissions:Check(ply, "keypads/payments") or nil

		CreationData.GrantedNotifications = tobool(self:GetClientNumber("granted_notification")) and bKeypads.Permissions:Check(ply, "notifications/access_granted") or nil
		CreationData.DeniedNotifications = tobool(self:GetClientNumber("denied_notification")) and bKeypads.Permissions:Check(ply, "notifications/access_denied") or nil

		CreationData.BackgroundColor = (tobool(self:GetClientNumber("rainbow_background_color")) and bKeypads.Permissions:Check(ply, "keypads/appearance/rainbows") and bKeypads.STOOL.RainbowBackgroundColor) or (authMode ~= bKeypads.AUTH_MODE.PIN and bKeypads.Permissions:Check(ply, "keypads/appearance/bg_color") and self:GetClientNumber("background_color")) or nil

		CreationData.Destructible = bKeypads.Config.KeypadDestruction.Enable
		if bKeypads.Config.KeypadDestruction.Enable then
			if bKeypads.Permissions:Check(ply, "destruction/indestructible") then
				CreationData.Destructible = not tobool(self:GetClientNumber("indestructible"))
				if CreationData.Destructible then
					CreationData.MaxHealth = math.max(self:GetClientNumber("max_health"), 1)
					CreationData.Shield = math.max(self:GetClientNumber("shield"), 0)
				end
			end
		else
			if bKeypads.Permissions:Check(ply, "destruction/destructible") then
				CreationData.Destructible = tobool(self:GetClientNumber("destructible"))
				if CreationData.Destructible then
					CreationData.MaxHealth = math.max(self:GetClientNumber("max_health"), 1)
					CreationData.Shield = math.max(self:GetClientNumber("shield"), 0)
				end
			end
		end

		CreationData.ImageURL = bKeypads.Config.Appearance.CustomImages.Enable and bKeypads.Permissions:Check(ply, "keypads/appearance/custom_img") and self:GetClientInfo("image_url") or ""
		if #CreationData.ImageURL == 0 or not bKeypads.KeypadImages:VerifyURL(CreationData.ImageURL) then
			CreationData.ImageURL = nil
		end

		if isUpdating then
			tr.Entity:Reset()
			tr.Entity:SetCreationData(CreationData)
			bKeypads:FetchAccessMatrix(ply, tr.Entity)
		else

			CreationData.Creator = ply

			local pos, angles = self:CalculateKeypadPos(tr)
			keypad = bKeypads:CreateKeypad(pos, angles, CreationData)

			ply:AddCount("_bkeypads", keypad)
			ply:AddCleanup("_bkeypads", keypad)

			if bKeypads.Config.KeypadMirroring and self:GetClientNumber("mirror") == 1 and bKeypads.Permissions:Check(ply, "mirror_keypads") then
				local mirrorPos, mirrorAng = self:CalculateMirroredKeypadPos(keypad, tr)
				if mirrorPos and mirrorAng then
					mirrorKeypad = bKeypads:CreateKeypad(mirrorPos, mirrorAng, CreationData)
				end
			end

			bKeypads:FetchAccessMatrix(ply, keypad, mirrorKeypad)

			if IsValid(mirrorKeypad) then
				timer.Simple(0, function()
					if IsValid(mirrorKeypad) and IsValid(keypad) then
						constraint.Weld(mirrorKeypad, keypad, 0, 0, 0, true, true)
					else
						if IsValid(mirrorKeypad) then
							mirrorKeypad:Remove()
						elseif IsValid(keypad) then
							keypad:Remove()
						end
					end
				end)

				bKeypads:FetchAccessMatrix(ply, mirrorKeypad)

				undo.Create("bKeypad")
					undo.AddEntity(keypad)
					undo.AddEntity(mirrorKeypad)
					undo.SetPlayer(ply)
				undo.Finish()

				ply:AddCleanup("_bkeypads", mirrorKeypad)

				bKeypads.KeypadLinking:Link(keypad, mirrorKeypad)
			else
				undo.Create("bKeypad")
					undo.AddEntity(keypad)
					undo.SetPlayer(ply)
				undo.Finish()
			end

		end

	end

	if not isUpdating and self:AutoFadingDoor() and bKeypads.Permissions:Check(ply, "fading_doors/create") then
		local tool = ply:GetTool("bkeypads_fading_door")
		if tool then
			if bKeypads.FadingDoors:CanFadingDoor(tr.Entity) and not bKeypads.FadingDoors:IsFadingDoor(tr.Entity) then
				bKeypads.FadingDoors.STOOL.LeftClick(tool, tr)
			end
			if SERVER and IsValid(keypad) and bKeypads.FadingDoors:IsFadingDoor(tr.Entity) and hook.Run("CanTool", ply, tr, "bkeypads_linker") then
				local links = bKeypads.FadingDoors:GetLinks(tr.Entity)
				if not links or not IsValid(links[keypad]) then
					bKeypads.FadingDoors:Link(keypad, tr.Entity, true, ply)
				end
				if IsValid(mirrorKeypad) and (not links or not IsValid(links[mirrorKeypad])) then
					bKeypads.FadingDoors:Link(mirrorKeypad, tr.Entity, true, ply)
				end
			end
		end
	end

	return true
end

if SERVER then
	util.AddNetworkString("bKeypads.KeypadAccessMatrix.Copy")
end
function bKeypads.STOOL.RightClick(self, tr)
	if not IsValid(self:GetOwner()) or not IsValid(tr.Entity) or not tr.Entity.bKeypad or tr.Entity:GetAuthMode() == bKeypads.AUTH_MODE.PIN then return false end

	if CLIENT then
		if IsFirstTimePredicted() then
			surface.PlaySound("garrysmod/balloon_pop_cute.wav")
			notification.AddProgress("KeypadAccessMatrixCopying", bKeypads.L("KeypadAccessMatrixCopying"))
			return true
		end
		return false
	else
		net.Start("bKeypads.KeypadAccessMatrix.Copy")
			bKeypads.KeypadData.Net:Serialize(tr.Entity.AccessMatrix)
			net.WriteUInt(tr.Entity:GetAuthMode(), 4)
		net.Send(self:GetOwner())
	end

	return true
end

if CLIENT then
	local matKeycard = Material("bkeypads/keycard")

	local function NumericOnly(self, c)
		if self:GetValue():sub(1,1) == "0" then
			return c == "0" or self:GetCaretPos() > 0
		end
		if c == "0" then
			return self:GetCaretPos() == 0 and #self:GetValue() > 0
		end
		return tonumber(c) == nil
	end

	local function NumericOnlyBounds(self)
		local n = tonumber(self:GetValue())
		if not n or (self.m_iMinimum ~= nil and n < self.m_iMinimum) or (self.m_iMaximum ~= nil and n > self.m_iMaximum) then
			self:SetText(tostring(self.m_iDefault))
		end
	end

	--## VGUI ##--

	local AccessOptions = {
		[bKeypads.ACCESS_GROUP.PLAYER] = function(AccessTable, AccessType, menu)
			if AccessType == bKeypads.ACCESS_TYPE.WHITELIST then
				local op = menu:AddOption(L("AddGroup"):format(L"GroupMe"), function()
					AccessTable:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.PLAYER][LocalPlayer():SteamID()] = LocalPlayer():Nick()
					AccessTable:ResolveConflicts(AccessType)
					AccessTable:Populate()
					surface.PlaySound("garrysmod/ui_click.wav")
				end)
				op:SetIcon("icon16/box.png")

				op.m_Image.AvatarImage = vgui.Create("AvatarImage", op.m_Image)
				op.m_Image.AvatarImage:SetSteamID(LocalPlayer():SteamID64(), 32)
				op.m_Image.AvatarImage:Dock(FILL)
			end

			menu:AddOption(L("AddGroup"):format(L"Player"), function()
				bKeypads.STOOL.BlockSpawnmenuClose = true
				bKeypads.PlayerSelector:Open(function(steamid64s)
					bKeypads.STOOL.BlockSpawnmenuClose = false
					for steamid64, nick in pairs(steamid64s) do
						local ply = bKeypads.player.GetBySteamID64(steamid64)
						AccessTable:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.PLAYER][util.SteamIDFrom64(steamid64)] = IsValid(ply) and ply:Nick() or (isstring(nick) and nick) or false
						AccessTable:ResolveConflicts(AccessType)
					end
					AccessTable:Populate()
				end)
			end):SetIcon("icon16/user.png")
		end,

		[bKeypads.ACCESS_GROUP.KEYCARD_LEVEL] = function(AccessTable, AccessType, menu)
			local AddKeycardLevel, _ = menu:AddSubMenu(L("AddGroup"):format(L"GroupKeycardLevel"))
			_:SetIcon("icon16/vcard.png")

			for level, data in SortedPairs(bKeypads.Keycards.Levels) do
				bKeypads.DermaMenuOption_Color(AddKeycardLevel:AddOption("[" .. level .. "] " .. data.Name, function()
					AccessTable:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.KEYCARD_LEVEL][level] = true
					AccessTable:ResolveConflicts(AccessType)
					AccessTable:Populate()
					surface.PlaySound("garrysmod/ui_click.wav")
				end), data.Color or Color(255,0,0))
			end

			if AccessType == bKeypads.ACCESS_TYPE.WHITELIST then
				-- bKeypads.ACCESS_GROUP.SUPERIOR_KEYCARDS
				AddKeycardLevel:AddOption(L"AllSuperiorKeycards", function()
					AccessTable:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.SUPERIOR_KEYCARDS] = true
					AccessTable:ResolveConflicts(AccessType)
					AccessTable:Populate()
					surface.PlaySound("garrysmod/ui_click.wav")
				end):SetIcon("icon16/sitemap_color.png")
			end
		end,

		[bKeypads.ACCESS_GROUP.STEAM_FRIENDS] = function(AccessTable, AccessType, menu)
			menu:AddOption(L"SteamFriends", function()
				AccessTable:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.STEAM_FRIENDS] = true
				AccessTable:ResolveConflicts(AccessType)
				AccessTable:Populate()
				surface.PlaySound("garrysmod/ui_click.wav")
			end):SetIcon("icon16/emoticon_grin.png")
		end,

		[bKeypads.ACCESS_GROUP.USERGROUP] = function(AccessTable, AccessType, menu)
			local AddUsergroup, _ = menu:AddSubMenu(L("AddGroup"):format(L"Usergroup"))
			_:SetIcon("icon16/shield.png")

			local usergroups = {user = true, admin = true, superadmin = true}
			for _, ply in ipairs(player.GetAll()) do
				if OpenPermissions and OpenPermissions.GetUserGroups then
					for usergroup in pairs(OpenPermissions:GetUserGroups(ply)) do
						usergroups[usergroup] = true
					end
				else
					usergroups[ply:GetUserGroup()] = true
				end
			end

			for usergroup in SortedPairs(usergroups) do
				AddUsergroup:AddOption(usergroup, function()
					AccessTable:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.USERGROUP][usergroup] = true
					AccessTable:ResolveConflicts(AccessType)
					AccessTable:Populate()
					surface.PlaySound("garrysmod/ui_click.wav")
				end):SetIcon((usergroup == "admin" or usergroup == "superadmin") and "icon16/shield.png" or "icon16/group.png")
			end

			AddUsergroup:AddOption(L"CustomEllipsis", function()
				bKeypads.STOOL.BlockSpawnmenuClose = true
				Derma_StringRequest(L("AddGroup"):format(L"Usergroup"), L"EnterUsergroup", "", function(usergroup)
					if usergroup and #usergroup > 0 then
						AccessTable:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.USERGROUP][usergroup] = true
						AccessTable:ResolveConflicts(AccessType)
						AccessTable:Populate()
						surface.PlaySound("garrysmod/ui_click.wav")
					end
					bKeypads.STOOL.BlockSpawnmenuClose = false
				end, function() bKeypads.STOOL.BlockSpawnmenuClose = false end)
			end):SetIcon("icon16/pencil.png")
		end,

		[bKeypads.ACCESS_GROUP.TEAM] = function(AccessTable, AccessType, menu)
			local AddTeam, _ = menu:AddSubMenu(L("AddGroup"):format(L"Team"))
			_:SetIcon("icon16/flag_purple.png")

			for _, teamTbl in SortedPairsByMemberValue(team.GetAllTeams(), "Name") do
				bKeypads.DermaMenuOption_Color(AddTeam:AddOption(teamTbl.Name, function()
					AccessTable:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.TEAM][teamTbl.Name] = true
					AccessTable:ResolveConflicts(AccessType)
					AccessTable:Populate()
					surface.PlaySound("garrysmod/ui_click.wav")
				end), teamTbl.Color)
			end
		end,

		["DarkRP"] = function(AccessType, menu)
			local DarkRPSubMenu, _ = menu:AddSubMenu("DarkRP")
			_:SetMaterial(Material("vgui/titlebaricon"))
			return DarkRPSubMenu
		end,

		[bKeypads.ACCESS_GROUP.DARKRP_JOB] = function(AccessTable, AccessType, menu, DarkRPSubMenu)
			DarkRPSubMenu:AddOption(L("AddGroup"):format(L"Job"), function()
				bKeypads.STOOL.BlockSpawnmenuClose = true
				bKeypads.JobSelector:Open(function(commands)
					bKeypads.STOOL.BlockSpawnmenuClose = false
					if #commands > 0 and IsValid(AccessTable) then
						for _, command in ipairs(commands) do
							AccessTable:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.DARKRP_JOB][command] = true
							AccessTable:ResolveConflicts(AccessType)
						end
						AccessTable:Populate()
					end
				end)
			end):SetIcon("icon16/user_gray.png")
		end,

		[bKeypads.ACCESS_GROUP.DARKRP_JOB_CATEGORY] = function(AccessTable, AccessType, menu, DarkRPSubMenu)
			local AddJobCategory, _ = DarkRPSubMenu:AddSubMenu(L("AddGroup"):format(L"GroupJobCategory"))
			_:SetIcon("icon16/user_gray.png")

			for _, category in SortedPairsByMemberValue(DarkRP.getCategories().jobs, "name") do
				bKeypads.DermaMenuOption_Color(AddJobCategory:AddOption(category.name, function()
					AccessTable:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.DARKRP_JOB_CATEGORY][category.name] = true
					AccessTable:ResolveConflicts(AccessType)
					AccessTable:Populate()
					surface.PlaySound("garrysmod/ui_click.wav")
				end), category.color)
			end
		end,

		[bKeypads.ACCESS_GROUP.DARKRP_DOOR_GROUP] = function(AccessTable, AccessType, menu, DarkRPSubMenu)
			local AddDoorGroupCategory, _ = DarkRPSubMenu:AddSubMenu(L("AddGroup"):format(L"GroupDoorGroup"))
			_:SetIcon("icon16/door.png")

			for _, doorGroup in SortedPairsByMemberValue(RPExtraTeamDoors, "name") do
				local opt = AddDoorGroupCategory:AddOption(doorGroup.name, function()
					AccessTable:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.DARKRP_DOOR_GROUP][doorGroup.name] = true
					AccessTable:ResolveConflicts(AccessType)
					AccessTable:Populate()
					surface.PlaySound("garrysmod/ui_click.wav")
				end)
				if doorGroup[1] then
					bKeypads.DermaMenuOption_Color(opt, team.GetColor(doorGroup[1]))
				else
					opt:SetIcon("icon16/door.png")
				end
			end
		end,

		[bKeypads.ACCESS_GROUP.DARKRP_AGENDA_GROUP] = function(AccessTable, AccessType, menu, DarkRPSubMenu)
			local AddAgendaGroupCategory, _ = DarkRPSubMenu:AddSubMenu(L("AddGroup"):format(L"GroupAgendaGroup"))
			_:SetIcon("icon16/sound.png")

			local added = {}
			for _, agenda in SortedPairsByMemberValue(DarkRP.getAgendas(), "Title") do
				if not added[agenda] then added[agenda] = true else continue end
				local opt = AddAgendaGroupCategory:AddOption(agenda.Title, function()
					AccessTable:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.DARKRP_AGENDA_GROUP][agenda.Title] = true
					AccessTable:ResolveConflicts(AccessType)
					AccessTable:Populate()
					surface.PlaySound("garrysmod/ui_click.wav")
				end)

				if isnumber(agenda.Manager) then
					bKeypads.DermaMenuOption_Color(opt, team.GetColor(agenda.Manager))
				else
					local job = agenda.Manager[1] or agenda.Listeners[1]
					if job then
						bKeypads.DermaMenuOption_Color(opt, team.GetColor(job))
					else
						opt:SetIcon("icon16/comments.png")
					end
				end
			end
		end,

		[bKeypads.ACCESS_GROUP.DARKRP_DEMOTE_GROUP] = function(AccessTable, AccessType, menu, DarkRPSubMenu)
			local AddDemoteGroupCategory, _ = DarkRPSubMenu:AddSubMenu(L("AddGroup"):format(L"GroupDemoteGroup"))
			_:SetIcon("icon16/report_user.png")

			local added = {}
			for job, demoteGroup in SortedPairsByMemberValue(DarkRP.getDemoteGroups(), "name") do
				if not added[demoteGroup] then added[demoteGroup] = true else continue end
				if not demoteGroup.name then continue end

				bKeypads.DermaMenuOption_Color(AddDemoteGroupCategory:AddOption(demoteGroup.name, function()
					AccessTable:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.DARKRP_DEMOTE_GROUP][demoteGroup.name] = true
					AccessTable:ResolveConflicts(AccessType)
					AccessTable:Populate()
					surface.PlaySound("garrysmod/ui_click.wav")
				end), team.GetColor(job))
			end
		end,

		["Helix"] = function(AccessType, menu)
			local HelixSubMenu, _ = menu:AddSubMenu("Helix")
			_:SetMaterial(Material("vgui/titlebaricon"))
			return HelixSubMenu
		end,

		[bKeypads.ACCESS_GROUP.HELIX_FLAG] = function(AccessTable, AccessType, menu, HelixSubMenu)
			local AddHelixFlagCategory, _ = HelixSubMenu:AddSubMenu(L("AddGroup"):format(L"Flag"))
			_:SetIcon("icon16/flag_green.png")

			for flag, data in SortedPairs(ix.flag.list) do
				local op = AddHelixFlagCategory:AddOption(flag, function()
					AccessTable:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.HELIX_FLAG][flag] = true
					AccessTable:ResolveConflicts(AccessType)
					AccessTable:Populate()
					surface.PlaySound("garrysmod/ui_click.wav")
				end)
				op:SetIcon("icon16/flag_green.png")
				op.bKeypads_Tooltip = data.description
			end
		end,

		["Mac's Rank System"] = function(AccessType, menu)
			local MRSSubmenu, _ = menu:AddSubMenu("Mac's Rank System")
			_:SetMaterial(Material("icon16/award_star_gold_1.png"))
			return MRSSubmenu
		end,

		[bKeypads.ACCESS_GROUP.MRS_RANK] = function(AccessTable, AccessType, menu, MRSSubmenu)
			if AccessType == bKeypads.ACCESS_TYPE.WHITELIST then
				-- bKeypads.ACCESS_GROUP.MRS_SUPERIOR_RANKS
				MRSSubmenu:AddOption(L"AllSuperiorRanks", function()
					AccessTable:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.MRS_SUPERIOR_RANKS] = true
					AccessTable:ResolveConflicts(AccessType)
					AccessTable:Populate()
					surface.PlaySound("garrysmod/ui_click.wav")
				end):SetIcon("icon16/sitemap_color.png")
			end

			for rankGroup, rankGroupData in SortedPairs(MRS.Ranks) do
				if table.IsEmpty(rankGroupData.ranks) then
					continue
				end

				local rankGroupCategory, _ = MRSSubmenu:AddSubMenu(rankGroup)
				_:SetIcon("icon16/award_star_gold_1.png")

				for rank, data in pairs(rankGroupData.ranks) do
					local op = rankGroupCategory:AddOption(data.name, function()
						AccessTable:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.MRS_RANK][data.name .. "\n" .. rankGroup] = true
						AccessTable:ResolveConflicts(AccessType)
						AccessTable:Populate()
						surface.PlaySound("garrysmod/ui_click.wav")
					end)
					op:SetIcon("icon16/award_star_gold_1.png")
					op.bKeypads_Tooltip = data.description
				end
			end
		end,
	}

	local function RainbowLabelPaint(self)
		local txt, rainbow = bKeypads.L("RainbowBackground"), not bKeypads.Performance:Optimizing() and self.bkeypads_rainbow_background_color:GetBool()
		if rainbow then
			txt = txt:upper()
			if self:GetText() ~= " " then self:SetText(" ") end
		else
			if self:GetText() ~= txt then
				self:SetText(txt)
				self:InvalidateParent(true)
			end
			return
		end

		local dc = DisableClipping(true)

		surface.SetFont(self:GetFont() == "DermaDefault" and "DermaDefaultBold" or self:GetFont())

		local shakeX, shakeY = math.Rand(-1, 1), math.Rand(-1, 1)
		surface.SetTextColor(self:GetColor())
		surface.SetTextPos(shakeX * 2, shakeY * 2)
		surface.DrawText(txt)

		surface.SetTextPos(0, 0)
		local txt_len = #txt
		local timeStep = CurTime() % txt_len
		for i = 1, txt_len do
			surface.SetTextColor(bKeypads:Rainbow(((((i + timeStep) % (txt_len - 1)) + 1) / txt_len) * 360))
			surface.DrawText(txt[i])
		end

		DisableClipping(dc)
	end

	local function BtnContainer_PerformLayout(self, w)
		self.Button1:Dock(LEFT)
		self.Button1:SetWide((w / 2) - 5)
		self.Button2:Dock(RIGHT)
		self.Button2:SetWide((w / 2) - 5)
	end

	local function HelpCategory_OnToggle(self)
		if not self:GetExpanded() then
			cookie.Set("bkeypads_help_viewed", 1)
		end
	end

	local function MethodBtnContainer_PerformLayout(self, w, h)
		local methods = (self.PIN:IsVisible() and 1 or 0) + (self.Keycard:IsVisible() and 1 or 0) + (self.FaceID:IsVisible() and 1 or 0)

		local space = math.min((w - (10 * (methods - 1))) / 3, 75)

		self:SetTall(space)
		self.PIN:SetSize(space - 14, space - 14)
		self.FaceID:SetSize(space - 14, space - 14)
		self.Keycard:SetSize(space - 14, space - 14)

		local btn_w = (methods * space) + ((methods - 1) * 10)
		local x = (w - btn_w) / 2

		if self.PIN:IsVisible() then
			self.PIN:SetPos(x + 7, 0)
			self.PIN:CenterVertical()

			x = x + space + 10
		end

		if self.FaceID:IsVisible() then
			self.FaceID:SetPos(x + 7, 0)
			self.FaceID:CenterVertical()

			x = x + space + 10
		end

		if self.Keycard:IsVisible() then
			self.Keycard:SetPos(x + 7, 0)
			self.Keycard:CenterVertical()

			--x = x + space + 10
		end
	end

	local bkeypads_auth_mode, authMethodAnimStart, authMethodAnimXStart, authMethodAnimX
	local function MethodBtnAnim(self)
		local x,y
		local AuthMode = bkeypads_auth_mode:GetInt()
		if AuthMode == bKeypads.AUTH_MODE.KEYCARD then
			x,y = self.Keycard:GetPos()
		elseif AuthMode == bKeypads.AUTH_MODE.PIN then
			x,y = self.PIN:GetPos()
		elseif AuthMode == bKeypads.AUTH_MODE.FACEID then
			x,y = self.FaceID:GetPos()
		end

		authMethodAnimX = x

		return x,y
	end

	local function MethodBtnClickSwitch(self)
		authMethodAnimStart, authMethodAnimXStart = SysTime(), authMethodAnimX
		bkeypads_auth_mode:SetInt(self.AuthMode)
		self:GetParent().CPanel.AccessCategory:AuthModeChanged(self.AuthMode)
		self:GetParent().CPanel.AppearanceCategory:AuthModeChanged(self.AuthMode)
	end

	local function MethodBtnClick(self)
		self:DoSwitch(self)
		RunConsoleCommand("gmod_tool", "bkeypads")
		surface.PlaySound("ui/buttonclick.wav")
	end

	local function MethodBtnContainer_PaintOver(self, w, h)
		surface.SetDrawColor(0,0,0)

		local x,y = MethodBtnAnim(self)
		local frac = math.Clamp(math.TimeFraction(authMethodAnimStart, authMethodAnimStart + .2, SysTime()), 0, 1)
		x = Lerp(bKeypads.ease.InOutSine(frac), authMethodAnimXStart, authMethodAnimX)

		local methods = (self.PIN:IsVisible() and 1 or 0) + (self.Keycard:IsVisible() and 1 or 0) + (self.FaceID:IsVisible() and 1 or 0)
		local space = math.min((w - (10 * (methods - 1))) / 3, 75)
		surface.DrawOutlinedRect(x - 6 - 1, y - 6 - 1, space, space)
		surface.DrawOutlinedRect(x - 6, y - 6, space - 2, space - 2)
	end

	local function AccessBtnContainer_PerformLayout(self,w,h)
		self.WhitelistBtn:SetWide((w / 2) - 5)
		self.BlacklistBtn:SetWide((w / 2) - 5)
	end

	local function SaveKeypadAllowInput(self, c)
		return not c:match("[A-Za-z0-9-_]")
	end

	local function PaymentEntryAllowInput(self, c)
		if c == "0" then
			return #self:GetValue() ~= 0 and (self:GetValue() == "0" or self:GetCaretPos() == 0)
		else
			if not c:match("[1-9]") then return true end
			return self:GetValue() == "0" and self:GetCaretPos() ~= 0
		end
	end

	local function MaximumCharsAllowInput(self, c)
		if self._AllowInput and self:_AllowInput(c) == true then return true end
		if not self.m_MaximumChars then return end
		if #self:GetValue() + 1 >= self.m_MaximumChars then
			return true
		end
	end

	function bKeypads.STOOL.BuildCPanel(CPanel)
		local isMainCPanel = controlpanel.Get("bkeypads") == CPanel
		local AccessTable

		bKeypads:InjectSmoothScroll(CPanel)

		bkeypads_auth_mode = bkeypads_auth_mode or GetConVar("bkeypads_auth_mode")
		local bkeypads_background_color = GetConVar("bkeypads_background_color")
		local bkeypads_image_url = GetConVar("bkeypads_image_url")

		bKeypads:STOOLMatrix(CPanel)

		local KeypadName = bKeypads:RecursiveTooltip(L"KeypadNameTip", CPanel:TextEntry(L"Name", "bkeypads_name"))
		KeypadName.m_MaximumChars = 23
		KeypadName.AllowInput = MaximumCharsAllowInput

		local AutoFadingDoor = bKeypads:RecursiveTooltip(L"AutoFadingDoorTip", CPanel:CheckBox(L"AutoFadingDoor", "bkeypads_auto_fading_door"))
		local MirrorPlacement = bKeypads:RecursiveTooltip(L"MirrorPlacementTip", CPanel:CheckBox(L"MirrorPlacement", "bkeypads_mirror"))

		--## HELP ##--

		CPanel.HelpCategory = vgui.Create("DForm", CPanel)
		CPanel.HelpCategory:SetLabel(L"Help")
		CPanel.HelpCategory:SetExpanded(cookie.GetNumber("bkeypads_help_viewed", 0) == 0)
		CPanel.HelpCategory.OnToggle = HelpCategory_OnToggle

			local img = vgui.Create("bKeypads.DockedImage", CPanel.HelpCategory)
			img:SetMaterial(Material("bkeypads/keypads.png", "smooth"))
			CPanel.HelpCategory:AddItem(img)

			CPanel.HelpCategory:Help(L"ToolHelp1" .. "\n\n" .. L"ToolHelp2" .. "\n\n" .. L"ToolHelp3" .. "\n\n" .. L"ToolHelp4"):DockMargin(0, 0, 0, 0)

			CPanel.Tutorial = vgui.Create("DButton", CPanel)
			CPanel.Tutorial:SetText(L"Tutorial")
			CPanel.Tutorial:SetIcon("icon16/emoticon_grin.png")
			CPanel.Tutorial:SetTall(25)
			CPanel.Tutorial.DoClick = function()
				bKeypads.Tutorial:OpenMenu()
			end
			-- TODO write wiki and add https://youtu.be/IK4TrpkGBLs [FR]

			CPanel.HelpCategory:AddItem(CPanel.Tutorial)

		CPanel:AddItem(CPanel.HelpCategory)

		--## SAVING ##--

		CPanel.SavesCategory = vgui.Create("DForm", CPanel)
		CPanel.SavesCategory:SetLabel(L"SavedKeypads")
		CPanel.SavesCategory:SetExpanded(false)

			bKeypads:AddHelp(CPanel.SavesCategory, L"SaveLoadTip"):DockMargin(0, 0, 0, 0)

			CPanel.FileSelection = vgui.Create("DListView", CPanel.SavesCategory)
			CPanel.FileSelection:SetTall(150)
			CPanel.FileSelection:AddColumn(L"Name")
			CPanel.FileSelection:AddColumn(L"Added")
			function CPanel.FileSelection:Populate()
				self:Clear()

				local savedKeypads = {}
				for _, f in ipairs((file.Find("bkeypads/saved/*.json", "DATA"))) do
					table.insert(savedKeypads, {LastModified = file.Time("bkeypads/saved/" .. f, "DATA"), Name = f:sub(1,-2-5-5)})
				end
				table.SortByMember(savedKeypads, "LastModified")
				for _, f in ipairs(savedKeypads) do
					CPanel.FileSelection:AddLine(f.Name, os.date("%x %X", f.LastModified)).Name = f.Name
				end
			end
			CPanel.FileSelection:Populate()

		CPanel.SavesCategory:AddItem(CPanel.FileSelection)

			local BtnContainer = vgui.Create("DPanel", CPanel.SavesCategory)
			BtnContainer.Paint = nil
			BtnContainer.PerformLayout = BtnContainer_PerformLayout

				CPanel.LoadSave = vgui.Create("DButton", BtnContainer)
				CPanel.LoadSave:SetText(L"LoadSave")
				CPanel.LoadSave:SetIcon("icon16/page_lightning.png")
				CPanel.LoadSave:SetTall(25)
				CPanel.LoadSave:SetDisabled(true)

				CPanel.DeleteSave = vgui.Create("DButton", BtnContainer)
				CPanel.DeleteSave:SetText(L"Delete")
				CPanel.DeleteSave:SetIcon("icon16/cancel.png")
				CPanel.DeleteSave:SetTall(25)
				CPanel.DeleteSave:SetDisabled(true)
				CPanel.DeleteSave.DoClick = function(self)
					surface.PlaySound("common/warning.wav")

					bKeypads.STOOL.BlockSpawnmenuClose = true

					local _, line = CPanel.FileSelection:GetSelectedLine()
					Derma_Query((bKeypads.L("DeleteSaveConfirm")):format(line.Name), L"Delete", L"Yes", function()
						surface.PlaySound("npc/roller/remote_yes.wav")

						bKeypads.STOOL.BlockSpawnmenuClose = false

						file.Delete("bkeypads/saved/" .. line.Name .. "_stool.json")
						file.Delete("bkeypads/saved/" .. line.Name .. "_access.dat")

						self:SetDisabled(true)
						CPanel.LoadSave:SetDisabled(true)
						CPanel.FileSelection:Populate()
					end, L"Cancel", function() bKeypads.STOOL.BlockSpawnmenuClose = false end)
				end

				BtnContainer.Button1 = CPanel.LoadSave
				BtnContainer.Button2 = CPanel.DeleteSave

		CPanel.SavesCategory:AddItem(BtnContainer)

			CPanel.SaveKeypad = vgui.Create("DButton", CPanel.SavesCategory)
			CPanel.SaveKeypad:SetText(L"SaveKeypad")
			CPanel.SaveKeypad:SetIcon("icon16/page_save.png")
			CPanel.SaveKeypad:SetTall(25)
			CPanel.SaveKeypad.DoClick = function()
				bKeypads.STOOL.BlockSpawnmenuClose = true

				local Window = Derma_StringRequest(L"SaveKeypad", L"SaveKeypadFileName", "", function(filename)
					if #filename > 0 then
						local function DoSave()
							surface.PlaySound("garrysmod/content_downloaded.wav")
							bKeypads.STOOL.BlockSpawnmenuClose = false

							local savedKeypad = {}
							for convar_name, def in pairs(bKeypads_STOOL_CONVARS) do
								local convar = GetConVar("bkeypads_" .. convar_name)
								if isnumber(def) then
									local fl = convar:GetFloat()
									savedKeypad[convar_name] = fl % 1 == 0 and convar:GetInt() or fl
								else
									savedKeypad[convar_name] = convar:GetString()
								end
							end
							file.Write("bkeypads/saved/" .. filename .. "_stool.json", util.TableToJSON(savedKeypad))
							bKeypads.KeypadData.File:Serialize(bKeypads.KeypadData.File:Open("bkeypads/saved/" .. filename .. "_access.dat", true, "DATA"), AccessTable:GetAccessMatrix())

							CPanel.LoadSave:SetDisabled(true)
							CPanel.DeleteSave:SetDisabled(true)
							CPanel.FileSelection:Populate()
						end
						if file.Exists("bkeypads/saved/" .. filename .. "_stool.json", "DATA") then
							surface.PlaySound("npc/roller/remote_yes.wav")
							Derma_Query((bKeypads.L("SaveKeypadAlreadyExists")):format(os.date("%c", file.Time("bkeypads/saved/" .. filename .. "_stool.json", "DATA"))), L"SaveKeypad", L"Yes", DoSave, L"Cancel")
						else
							DoSave()
						end
					else
						bKeypads.STOOL.BlockSpawnmenuClose = false
					end
				end, function() bKeypads.STOOL.BlockSpawnmenuClose = false end)

				local TextEntry = Window:Find("DTextEntry")
				TextEntry:SetAllowNonAsciiCharacters(false)
				TextEntry._AllowInput = SaveKeypadAllowInput
				TextEntry.m_MaximumChars = 30
				TextEntry.AllowInput = MaximumCharsAllowInput
			end

		function CPanel.FileSelection:OnRowSelected(index, line)
			CPanel.DeleteSave:SetDisabled(false)
			CPanel.LoadSave:SetDisabled(false)
		end

		CPanel.SavesCategory:AddItem(CPanel.SaveKeypad)

		CPanel:AddItem(CPanel.SavesCategory)

		--## DESTRUCTION ##--

		CPanel.DestructionCategory = vgui.Create("DForm", CPanel)
		CPanel.DestructionCategory:SetLabel(L"Destruction")
		CPanel.DestructionCategory:SetExpanded(false)

			CPanel.DestructionCategory.Indestructible = CPanel.DestructionCategory:CheckBox(L"Indestructible", "bkeypads_indestructible")
			bKeypads:AddShieldIcon(CPanel.DestructionCategory.Indestructible)

			CPanel.DestructionCategory.Destructible = CPanel.DestructionCategory:CheckBox(L"Destructible", "bkeypads_destructible")
			bKeypads:AddShieldIcon(CPanel.DestructionCategory.Destructible)

			CPanel.DestructionCategory.MaxHealth = CPanel.DestructionCategory:TextEntry(L"MaxHealth", "bkeypads_max_health")
			CPanel.DestructionCategory.MaxHealth.m_iDefault = bKeypads.Config.KeypadDestruction.KeypadHealth
			CPanel.DestructionCategory.MaxHealth.m_iMinimum = 1
			CPanel.DestructionCategory.MaxHealth.AllowInput = NumericOnly
			CPanel.DestructionCategory.MaxHealth.OnValueChange = NumericOnlyBounds
			bKeypads:AddShieldIcon(CPanel.DestructionCategory.MaxHealth)

			CPanel.DestructionCategory.Shield = CPanel.DestructionCategory:TextEntry(L"Shield", "bkeypads_shield")
			CPanel.DestructionCategory.Shield.m_iDefault = 0
			CPanel.DestructionCategory.Shield.m_iMinimum = 0
			CPanel.DestructionCategory.Shield.AllowInput = NumericOnly
			CPanel.DestructionCategory.Shield.OnValueChange = NumericOnlyBounds
			bKeypads:AddShieldIcon(CPanel.DestructionCategory.Shield)

		CPanel:AddItem(CPanel.DestructionCategory)

		--## NOTIFICATIONS ##--

		CPanel.NotificationsCategory = vgui.Create("DForm", CPanel)
		CPanel.NotificationsCategory:SetLabel(L"Notifications")
		CPanel.NotificationsCategory:SetExpanded(GetConVar("bkeypads_granted_notification"):GetBool() or GetConVar("bkeypads_denied_notification"):GetBool())

			CPanel.NotificationsCategory.AccessGranted = CPanel.NotificationsCategory:CheckBox(L"AccessGranted", "bkeypads_granted_notification")
			CPanel.NotificationsCategory.AccessDenied  = CPanel.NotificationsCategory:CheckBox(L"AccessDenied", "bkeypads_denied_notification")

			bKeypads:RecursiveTooltip(L"AccessGrantedNotificationTip", CPanel.NotificationsCategory.AccessGranted)
			bKeypads:RecursiveTooltip(L"AccessDeniedNotificationTip", CPanel.NotificationsCategory.AccessDenied)

		CPanel:AddItem(CPanel.NotificationsCategory)

		--## CONFIG ##--

		CPanel.ConfigCategory = vgui.Create("DForm", CPanel)
		CPanel.ConfigCategory:SetLabel(L"Configuration")

			local NoCollideCheckbox = bKeypads:RecursiveTooltip(L"NoCollideTip", CPanel.ConfigCategory:CheckBox(L"NoCollide", "bkeypads_nocollide"))
			local FreezeCheckbox = bKeypads:RecursiveTooltip(L"FreezeTip", CPanel.ConfigCategory:CheckBox(L"Freeze", "bkeypads_freeze"))
			local WeldCheckbox = bKeypads:RecursiveTooltip(L"WeldTip", CPanel.ConfigCategory:CheckBox(L"Weld", "bkeypads_weld"))

			local WiremodCheckbox = bKeypads:RecursiveTooltip(L"WiremodTip", CPanel.ConfigCategory:CheckBox("Wiremod", "bkeypads_wiremod"))

			local UncrackableCheckbox = CPanel.ConfigCategory:CheckBox(L"Uncrackable", "bkeypads_uncrackable")
			bKeypads:AddShieldIcon(UncrackableCheckbox)
			bKeypads:RecursiveTooltip(L"UncrackableTip" .. "\n" .. L"UncrackableIncompatibilitiesTip", UncrackableCheckbox)

		CPanel:AddItem(CPanel.ConfigCategory)

		--## METHOD ##--

		CPanel.MethodCategory = vgui.Create("DForm", CPanel)
		CPanel.MethodCategory:SetLabel(L"KeypadMethod")

			local MethodBtnContainer = vgui.Create("DPanel", CPanel.MethodCategory)
			MethodBtnContainer.CPanel = CPanel
			MethodBtnContainer.Paint = nil
			MethodBtnContainer:SetTall(64 + 20)
			MethodBtnContainer.PerformLayout = MethodBtnContainer_PerformLayout

			MethodBtnContainer.PIN = vgui.Create("DImageButton", MethodBtnContainer)
			MethodBtnContainer.PIN.AuthMode = bKeypads.AUTH_MODE.PIN
			MethodBtnContainer.PIN:SetSize(64,64)
			MethodBtnContainer.PIN.bKeypads_Tooltip = L"PINTip"
			MethodBtnContainer.PIN.DoClick = MethodBtnClick
			MethodBtnContainer.PIN.DoSwitch = MethodBtnClickSwitch
			MethodBtnContainer.PIN:SetMaterial(Material("bkeypads/method_pin"))
			MethodBtnContainer.PIN:SetColor(bKeypads.COLOR.BLACK)

			MethodBtnContainer.FaceID = vgui.Create("DImageButton", MethodBtnContainer)
			MethodBtnContainer.FaceID.AuthMode = bKeypads.AUTH_MODE.FACEID
			MethodBtnContainer.FaceID:SetSize(64,64)
			MethodBtnContainer.FaceID.bKeypads_Tooltip = L"FaceIDTip"
			MethodBtnContainer.FaceID.DoClick = MethodBtnClick
			MethodBtnContainer.FaceID.DoSwitch = MethodBtnClickSwitch
			MethodBtnContainer.FaceID:SetMaterial(Material("bkeypads/face_id"))
			MethodBtnContainer.FaceID:SetColor(bKeypads.COLOR.BLACK)

			MethodBtnContainer.Keycard = vgui.Create("DImageButton", MethodBtnContainer)
			MethodBtnContainer.Keycard.AuthMode = bKeypads.AUTH_MODE.KEYCARD
			MethodBtnContainer.Keycard:SetSize(64,64)
			MethodBtnContainer.Keycard.bKeypads_Tooltip = L"KeycardTip"
			MethodBtnContainer.Keycard.DoClick = MethodBtnClick
			MethodBtnContainer.Keycard.DoSwitch = MethodBtnClickSwitch
			MethodBtnContainer.Keycard:SetMaterial(matKeycard)
			MethodBtnContainer.Keycard:SetColor(bKeypads.COLOR.BLACK)

			MethodBtnAnim(MethodBtnContainer)
			authMethodAnimStart = SysTime() - .2
			authMethodAnimXStart = authMethodAnimX
			MethodBtnContainer.PaintOver = MethodBtnContainer_PaintOver

			bKeypads_AuthModeChangedCallbackID = (bKeypads_AuthModeChangedCallbackID or 0) + 1
			local myCallbackID = bKeypads_AuthModeChangedCallbackID
			cvars.AddChangeCallback("bkeypads_auth_mode", function(_, __, AuthMode)
				if IsValid(MethodBtnContainer) then
					local AuthMode = tonumber(AuthMode)
					if AuthMode == bKeypads.AUTH_MODE.PIN then
						MethodBtnContainer.PIN:DoSwitch()
					elseif AuthMode == bKeypads.AUTH_MODE.FACEID then
						MethodBtnContainer.FaceID:DoSwitch()
					elseif AuthMode == bKeypads.AUTH_MODE.KEYCARD then
						MethodBtnContainer.Keycard:DoSwitch()
					end
				else
					cvars.RemoveChangeCallback("bkeypads_auth_mode", "bkeypads_auth_mode_" .. myCallbackID)
				end
			end, "bkeypads_auth_mode_" .. bKeypads_AuthModeChangedCallbackID)

			CPanel.MethodCategory:AddItem(MethodBtnContainer)

		CPanel:AddItem(CPanel.MethodCategory)

		--## ACCESS ##--

		CPanel.AccessCategory = vgui.Create("DForm", CPanel)
		CPanel.AccessCategory:SetLabel(L"Access")

			local PINField = CPanel.AccessCategory:TextEntry(L"PIN", "bkeypads_pin")
			function PINField:AllowInput(c)
				return not tonumber(c) or #self:GetValue() >= 6
			end

			local ChargeUnauthorized = bKeypads:RecursiveTooltip(L"ChargeUnauthorizedTip", CPanel.AccessCategory:CheckBox(L"ChargeUnauthorized", "bkeypads_charge_unauthorized"))
			ChargeUnauthorized:SetDisabled(true)
			ChargeUnauthorized:SetChecked(false)

			local PaymentBtn = vgui.Create("DButton", CPanel.AccessCategory)
			PaymentBtn:SetTall(25)
			PaymentBtn:SetIcon("icon16/money.png")
			PaymentBtn:SetText(L"SetPayment")
			PaymentBtn.bKeypads_Tooltip = L"SetPaymentTip"
			PaymentBtn.DoClick = function()
				surface.PlaySound("garrysmod/ui_click.wav")

				bKeypads.STOOL.BlockSpawnmenuClose = true

				local txt = L"PaymentEntry"
				if bKeypads.Config.Payments.MaximumPayment > 0 or bKeypads.Config.Payments.MinimumPayment > 1 then
					txt = txt .. "\n"
					if bKeypads.Config.Payments.MinimumPayment > 1 then
						txt = txt .. "\n" .. (L"PaymentMinimum"):format(bKeypads.Economy:formatMoney(bKeypads.Config.Payments.MinimumPayment))
					end
					if bKeypads.Config.Payments.MaximumPayment > 0 then
						txt = txt .. "\n" .. (L"PaymentMaximum"):format(bKeypads.Economy:formatMoney(bKeypads.Config.Payments.MaximumPayment))
					end
				end
				Derma_StringRequest(L"Payment", txt, "",
					function(amount)
						bKeypads.STOOL.BlockSpawnmenuClose = false
						amount = tonumber(amount)
						if amount and amount >= 0 and amount % 1 == 0 then
							if amount == 0 then
								AccessTable:GetAccessMatrix()[bKeypads.ACCESS_GROUP.PAYMENT] = false
							elseif bKeypads.Config.Payments.MaximumPayment > 0 and amount > bKeypads.Config.Payments.MaximumPayment then
								surface.PlaySound("common/warning.wav")
								Derma_Message((L"PaymentAboveMaximum"):format(bKeypads.Economy:formatMoney(bKeypads.Config.Payments.MaximumPayment)), L"Payment", L"Dismiss")
								return
							elseif bKeypads.Config.Payments.MinimumPayment > 1 and amount < bKeypads.Config.Payments.MinimumPayment then
								surface.PlaySound("common/warning.wav")
								Derma_Message((L"PaymentBelowMinimum"):format(bKeypads.Economy:formatMoney(bKeypads.Config.Payments.MinimumPayment)), L"Payment", L"Dismiss")
								return
							else
								AccessTable:GetAccessMatrix()[bKeypads.ACCESS_GROUP.PAYMENT] = math.min(amount, (2^31)-1)
							end
							AccessTable:Populate()
							surface.PlaySound("bkeypads/cash.wav")
						end
					end,

					function()
						bKeypads.STOOL.BlockSpawnmenuClose = false
					end
				):Find("DTextEntry").AllowInput = PaymentEntryAllowInput
			end
			CPanel.AccessCategory:AddItem(PaymentBtn)

		do
			local AccessTip = bKeypads:AddHelp(CPanel.AccessCategory, L"KeypadAccessTip2")
			AccessTip:DockMargin(0, 0, 0, 0)

			AccessTable = vgui.Create("bKeypads.AccessMatrix", CPanel.AccessCategory)
			if isMainCPanel then bKeypads.AccessTable = AccessTable end
			AccessTable:SetUseConVar(true)
			AccessTable:Dock(TOP)
			AccessTable:SetTall(200)
			AccessTable.PostPopulate = function()
				if AccessTable:GetAccessMatrix()[bKeypads.ACCESS_GROUP.PAYMENT] ~= false then
					ChargeUnauthorized:SetDisabled(false)
				else
					ChargeUnauthorized:SetChecked(false)
					ChargeUnauthorized:SetDisabled(true)
				end
			end

			CPanel.AccessCategory:AddItem(AccessTable)

			local function AccessBtnClick(self)
				surface.PlaySound("garrysmod/ui_return.wav")

				local menu = DermaMenu(nil, self)

				if bkeypads_auth_mode:GetInt() == bKeypads.AUTH_MODE.KEYCARD then
					AccessOptions[bKeypads.ACCESS_GROUP.KEYCARD_LEVEL](AccessTable, self.AccessType, menu)
				end

				AccessOptions[bKeypads.ACCESS_GROUP.PLAYER](AccessTable, self.AccessType, menu)
				AccessOptions[bKeypads.ACCESS_GROUP.STEAM_FRIENDS](AccessTable, self.AccessType, menu)
				AccessOptions[bKeypads.ACCESS_GROUP.USERGROUP](AccessTable, self.AccessType, menu)
				if DarkRP then
					local DarkRPSubMenu = AccessOptions["DarkRP"](self.AccessType, menu)
					AccessOptions[bKeypads.ACCESS_GROUP.DARKRP_JOB](AccessTable, self.AccessType, menu, DarkRPSubMenu)
					AccessOptions[bKeypads.ACCESS_GROUP.DARKRP_JOB_CATEGORY](AccessTable, self.AccessType, menu, DarkRPSubMenu)
					AccessOptions[bKeypads.ACCESS_GROUP.DARKRP_DOOR_GROUP](AccessTable, self.AccessType, menu, DarkRPSubMenu)
					AccessOptions[bKeypads.ACCESS_GROUP.DARKRP_AGENDA_GROUP](AccessTable, self.AccessType, menu, DarkRPSubMenu)
					AccessOptions[bKeypads.ACCESS_GROUP.DARKRP_DEMOTE_GROUP](AccessTable, self.AccessType, menu, DarkRPSubMenu)
				else
					AccessOptions[bKeypads.ACCESS_GROUP.TEAM](AccessTable, self.AccessType, menu)
				end
				if ix and ix.flag then
					local HelixSubMenu = AccessOptions["Helix"](self.AccessType, menu)
					AccessOptions[bKeypads.ACCESS_GROUP.HELIX_FLAG](AccessTable, self.AccessType, menu, HelixSubMenu)
				end
				if MRS and MRS.Ranks then
					local MRSSubMenu = AccessOptions["Mac's Rank System"](self.AccessType, menu)
					AccessOptions[bKeypads.ACCESS_GROUP.MRS_RANK](AccessTable, self.AccessType, menu, MRSSubMenu)
				end

				if bKeypads.CustomAccess.UserConfig.Enabled then
					local spacer = false

					if not table.IsEmpty(bKeypads.CustomAccess.UserConfig.TeamGroups) then
						if not spacer then
							spacer = true
							menu:AddSpacer()
						end

						local TeamGroups, _ = menu:AddSubMenu(L("AddGroup"):format(L"GroupCustomTeamGroup"))
						_:SetIcon("icon16/script_code_red.png")

						for name in pairs(bKeypads.CustomAccess.UserConfig.TeamGroups) do
							TeamGroups:AddOption(name, function()
								AccessTable:GetAccessMatrix()[self.AccessType][bKeypads.ACCESS_GROUP.CUSTOM_TEAM_GROUP][name] = true
								AccessTable:ResolveConflicts(self.AccessType)
								AccessTable:Populate()
								surface.PlaySound("garrysmod/ui_click.wav")
							end):SetIcon("icon16/script_code_red.png")
						end
					end

					if not table.IsEmpty(bKeypads.CustomAccess.UserConfig.LuaFunctions) and bKeypads.Permissions:Check(LocalPlayer(), "keypads/custom_lua_functions") then
						if not spacer then
							spacer = true
							menu:AddSpacer()
						end

						local LuaFunctions, _ = menu:AddSubMenu(L("AddGroup"):format(L"GroupCustomLuaFunction"))
						_:SetIcon("icon16/script_code.png")

						for name in pairs(bKeypads.CustomAccess.UserConfig.LuaFunctions) do
							LuaFunctions:AddOption(name, function()
								AccessTable:GetAccessMatrix()[self.AccessType][bKeypads.ACCESS_GROUP.CUSTOM_LUA_FUNCTION][name] = true
								AccessTable:ResolveConflicts(self.AccessType)
								AccessTable:Populate()
								surface.PlaySound("garrysmod/ui_click.wav")
							end):SetIcon("icon16/script_code.png")
						end
					end
				end

				if bKeypads.CustomAccess.Addons.Enabled then
					menu:AddSpacer()

					local function addCustomAccessMember(parent, member)
						local option, btn
						if member.Members then
							option, btn = parent:AddSubMenu(member.Name)
							for id, member in SortedPairsByMemberValue(member.Members, "Name") do
								addCustomAccessMember(option, member)
							end
						else
							option = parent:AddOption(member.Name, function()
								AccessTable:GetAccessMatrix()[self.AccessType][bKeypads.ACCESS_GROUP.CUSTOM_ADDON_FUNCTION][member.ID] = true
								AccessTable:ResolveConflicts(self.AccessType)
								AccessTable:Populate()
								surface.PlaySound("garrysmod/ui_click.wav")
							end)
						end
						if IsColor(member.Icon) or (istable(member.Icon) and member.Icon.r and member.Icon.g and member.Icon.b) then
							bKeypads.DermaMenuOption_Color(btn or option, member.Icon)
						elseif isstring(member.Icon) then
							(btn or option):SetIcon(member.Icon)
						elseif type(member.Icon) == "IMaterial" then
							(btn or option):SetMaterial(member.Icon)
						end
					end
					for id, addon in SortedPairsByMemberValue(bKeypads.CustomAccess.Addons.Registry, "Name") do
						addCustomAccessMember(menu, addon)
					end
				end

				local x,y = self:LocalToScreen(0, self:GetTall() - 1)
				menu:Open(x,y,nil,self)
			end

			local AccessBtnContainer = vgui.Create("DPanel", CPanel.AccessCategory)
			AccessBtnContainer:SetTall(25)
			AccessBtnContainer.Paint = nil
			AccessBtnContainer.PerformLayout = AccessBtnContainer_PerformLayout
			CPanel.AccessCategory:AddItem(AccessBtnContainer)

			AccessBtnContainer.WhitelistBtn = vgui.Create("DButton", AccessBtnContainer)
			AccessBtnContainer.WhitelistBtn:Dock(LEFT)
			AccessBtnContainer.WhitelistBtn:SetIcon("icon16/accept.png")
			AccessBtnContainer.WhitelistBtn:SetText(L"Whitelist")
			AccessBtnContainer.WhitelistBtn.bKeypads_Tooltip = L"WhitelistTip"
			AccessBtnContainer.WhitelistBtn.DoClick = AccessBtnClick
			AccessBtnContainer.WhitelistBtn.AccessType = bKeypads.ACCESS_TYPE.WHITELIST

			AccessBtnContainer.BlacklistBtn = vgui.Create("DButton", AccessBtnContainer)
			AccessBtnContainer.BlacklistBtn:Dock(RIGHT)
			AccessBtnContainer.BlacklistBtn:SetIcon("icon16/delete.png")
			AccessBtnContainer.BlacklistBtn:SetText(L"Blacklist")
			AccessBtnContainer.BlacklistBtn.bKeypads_Tooltip = L"BlacklistTip"
			AccessBtnContainer.BlacklistBtn.DoClick = AccessBtnClick
			AccessBtnContainer.BlacklistBtn.AccessType = bKeypads.ACCESS_TYPE.BLACKLIST

			local ClearBtn = vgui.Create("DButton", CPanel.AccessCategory)
			ClearBtn:SetTall(25)
			ClearBtn:SetIcon("icon16/bin.png")
			ClearBtn:SetText(L"Clear")
			ClearBtn.DoClick = function()
				surface.PlaySound("common/warning.wav")

				bKeypads.STOOL.BlockSpawnmenuClose = true
				Derma_Query(L"ClearAccessMatrixConfirm", L"Clear", L"Yes", function()
					surface.PlaySound("npc/roller/remote_yes.wav")
					bKeypads.STOOL.BlockSpawnmenuClose = false
					AccessTable:ResetAccessMatrix()
					AccessTable:Populate()
				end, L"No", function() bKeypads.STOOL.BlockSpawnmenuClose = false end)
			end
			CPanel.AccessCategory:AddItem(ClearBtn)

			function CPanel.AccessCategory:AuthModeChanged(authMode)
				local is_pin = authMode == bKeypads.AUTH_MODE.PIN

				PINField:GetParent():SetVisible(is_pin)
				ChargeUnauthorized:GetParent():SetVisible(not is_pin)
				PaymentBtn:GetParent():SetVisible(not is_pin)
				AccessTip:GetParent():SetVisible(not is_pin)
				AccessTable:GetParent():SetVisible(not is_pin)
				AccessBtnContainer.WhitelistBtn:GetParent():SetVisible(not is_pin)
				AccessBtnContainer.BlacklistBtn:GetParent():SetVisible(not is_pin)
				ClearBtn:GetParent():SetVisible(not is_pin)

				AccessTable:LoadAccessMatrix(authMode)

				CPanel:InvalidateChildren(true)
			end
			CPanel.AccessCategory:AuthModeChanged(bkeypads_auth_mode:GetInt())
		end

		CPanel:AddItem(CPanel.AccessCategory)

		--## BEHAVIOUR ##--

		CPanel.BehaviourCategory = vgui.Create("DForm", CPanel)
		CPanel.BehaviourCategory:SetLabel(L"Behaviour")

		local KeyBindersContainer = vgui.Create("DPanel", CPanel.BehaviourCategory)
		KeyBindersContainer:SetTall(75)
		KeyBindersContainer.Paint = nil

		do
			local ctrl = vgui.Create("CtrlNumPad", KeyBindersContainer)
			ctrl:Dock(FILL)
			ctrl:SetConVar1("bkeypads_granted_key")
			ctrl:SetConVar2("bkeypads_denied_key")
			ctrl:SetLabel1(L"AccessGrantedKey")
			ctrl:SetLabel2(L"AccessDeniedKey")

			CPanel.BehaviourCategory:AddItem(KeyBindersContainer)

			ctrl.NumPad1.bKeypads_Tooltip = L"AccessGrantedKeyTip" .. "\n" .. L"DBinderTip"
			ctrl.NumPad2.bKeypads_Tooltip = L"AccessDeniedKeyTip" .. "\n" .. L"DBinderTip"

			local AccessSettings = {"AccessGranted", "AccessDenied"}
			local AccessConVars = {"granted", "denied"}
			for i=1,2 do
				local AccessX = AccessSettings[i]
				local AccessConVar = AccessConVars[i]

				CPanel.BehaviourCategory[AccessX] = vgui.Create("DForm", CPanel.BehaviourCategory)
				CPanel.BehaviourCategory[AccessX]:SetLabel(L(AccessX))
				CPanel.BehaviourCategory[AccessX]:SetExpanded(i == 1)

				local AccessCategory = CPanel.BehaviourCategory[AccessX]

				AccessCategory.HoldLength = bKeypads:RecursiveTooltip(L"HoldLengthTip", AccessCategory:NumSlider(L"HoldLength", "bkeypads_" .. AccessConVar .. "_hold_time", bKeypads.Config.Scanning[AccessX].MinimumTime, bKeypads.Config.Scanning[AccessX].MaximumTime ~= 0 and bKeypads.Config.Scanning[AccessX].MaximumTime or 10, 2))
				AccessCategory.InitialDelay = bKeypads:RecursiveTooltip(L"InitialDelayTip", AccessCategory:NumSlider(L"InitialDelay", "bkeypads_" .. AccessConVar .. "_initial_delay", 0, 10, 2))
				AccessCategory.Repeats = bKeypads:RecursiveTooltip(L"RepeatsTip", AccessCategory:NumSlider(L"Repeats", "bkeypads_" .. AccessConVar .. "_repeats", 0, 10, 0))
				AccessCategory.RepeatDelay = bKeypads:RecursiveTooltip(L"RepeatDelayTip", AccessCategory:NumSlider(L"RepeatDelay", "bkeypads_" .. AccessConVar .. "_repeat_delay", 0.1, 10, 2))

				CPanel.BehaviourCategory:AddItem(AccessCategory)
			end
		end

		CPanel:AddItem(CPanel.BehaviourCategory)

		--## APPEARANCE ##--

		CPanel.AppearanceCategory = vgui.Create("DForm", CPanel)
		CPanel.AppearanceCategory:SetLabel(L"Appearance")
		CPanel.AppearanceCategory:SetExpanded(false)

			CPanel.AppearanceCategory.BackgroundColor = vgui.Create("DForm", CPanel.AppearanceCategory)
			CPanel.AppearanceCategory.BackgroundColor:SetLabel(L"BackgroundColor")
			CPanel.AppearanceCategory.BackgroundColor.Color = Color(255,255,255)

			CPanel.AppearanceCategory.BackgroundColor.Rainbow = CPanel.AppearanceCategory.BackgroundColor:CheckBox(L"RainbowBackground", "bkeypads_rainbow_background_color")
			CPanel.AppearanceCategory.BackgroundColor.Rainbow.Label.bkeypads_rainbow_background_color = GetConVar("bkeypads_rainbow_background_color")
			CPanel.AppearanceCategory.BackgroundColor.Rainbow.Label.Paint = RainbowLabelPaint

			do
				local BackgroundColor = vgui.Create("DPanel", CPanel.AppearanceCategory)
				CPanel.AppearanceCategory.BackgroundColor.ColorPicker = BackgroundColor
				BackgroundColor:SetTall(150)
				BackgroundColor.Paint = nil

					local RGBPicker = vgui.Create("DRGBPicker", BackgroundColor)
					RGBPicker:Dock(LEFT)
					RGBPicker:SetWide(30)
					RGBPicker:DockMargin(0, 0, 5, 0)

					local ColorCubeContainer = vgui.Create("DPanel", BackgroundColor)
					ColorCubeContainer.Paint = nil
					ColorCubeContainer:Dock(FILL)

						local ColorCube = vgui.Create("DColorCube", ColorCubeContainer)
						ColorCube:Dock(FILL)

						local Manual = vgui.Create("DPanel", ColorCubeContainer)
						Manual:Dock(BOTTOM)
						Manual:DockMargin(0, 5, 0, 0)
						Manual:SetTall(20)

							local r = vgui.Create("DTextEntry", Manual)
							r:SetNumeric(true)
							r:Dock(LEFT)
							r:SetWide(40)
							r:DockMargin(0, 0, 5, 0)

							local g = vgui.Create("DTextEntry", Manual)
							g:SetNumeric(true)
							g:Dock(LEFT)
							g:SetWide(40)
							g:DockMargin(0, 0, 5, 0)

							local b = vgui.Create("DTextEntry", Manual)
							b:SetNumeric(true)
							b:Dock(LEFT)
							b:SetWide(40)
							b:DockMargin(0, 0, 5, 0)

							local hex = vgui.Create("DTextEntry", Manual)
							hex:Dock(FILL)
							function hex:AllowInput(char)
								return (self:GetValue():sub(1, self:GetCaretPos()) .. char .. self:GetValue():sub(self:GetCaretPos() + 1)):match("^%#?%x?%x?%x?%x?%x?%x?$") == nil
							end

					local function UpdateColors(col)
						CPanel.AppearanceCategory.BackgroundColor.Color = col

						r:SetText(col.r)
						r.PrevText = r:GetText()

						g:SetText(col.g)
						g.PrevText = g:GetText()

						b:SetText(col.b)
						b.PrevText = b:GetText()

						hex:SetText("##" .. string.upper(bit.tohex(col.r, 2) .. bit.tohex(col.g, 2) .. bit.tohex(col.b, 2)))
						hex.PrevText = hex:GetText()

						bkeypads_background_color:SetInt(65536 * col.r + 256 * col.g + col.b)
					end

					function CPanel.AppearanceCategory.BackgroundColor:SetColors(col)
						ColorCube:SetColor(col)

						UpdateColors(col)

						local h = ColorToHSV(col)
						RGBPicker:SetRGB(HSVToColor(h, 1, 1))

						local _, height = RGBPicker:GetSize()
						RGBPicker.LastY = height*(1-(h/360))
					end

					function r:OnUserUpdate()
						local val = tonumber(self:GetValue())
						if val and val >= 0 and val <= 255 then
							CPanel.AppearanceCategory.BackgroundColor.Color.r = val
							CPanel.AppearanceCategory.BackgroundColor:SetColors(CPanel.AppearanceCategory.BackgroundColor.Color)
						else
							self:SetText(self.PrevText)
						end
					end

					function g:OnUserUpdate()
						local val = tonumber(self:GetValue())
						if val and val >= 0 and val <= 255 then
							CPanel.AppearanceCategory.BackgroundColor.Color.g = val
							CPanel.AppearanceCategory.BackgroundColor:SetColors(CPanel.AppearanceCategory.BackgroundColor.Color)
						else
							self:SetText(self.PrevText)
						end
					end

					function b:OnUserUpdate()
						local val = tonumber(self:GetValue())
						if val and val >= 0 and val <= 255 then
							CPanel.AppearanceCategory.BackgroundColor.Color.b = val
							CPanel.AppearanceCategory.BackgroundColor:SetColors(CPanel.AppearanceCategory.BackgroundColor.Color)
						else
							self:SetText(self.PrevText)
						end
					end

					function hex:OnUserUpdate()
						local val = tonumber(self:GetText():gsub("^%#+", ""), 16)
						if val then
							CPanel.AppearanceCategory.BackgroundColor:SetColors(bKeypads:IntToColor(val))
						else
							self:SetText(self.PrevText)
						end
					end

					for _, v in ipairs({r, g, b, hex}) do
						function v:OnFocusChanged(gained)
							if not gained then
								self:OnEnter()
							end
						end
						function v:OnEnter()
							self:OnUserUpdate()
						end
					end

					local RGBPicker_PerformLayout = RGBPicker.PerformLayout
					function RGBPicker:PerformLayout()
						CPanel.AppearanceCategory.BackgroundColor:SetColors(bKeypads:IntToColor(bkeypads_background_color:GetInt() or 0x0096FF))
						self.PerformLayout = RGBPicker_PerformLayout
						RGBPicker_PerformLayout = nil
					end

					function RGBPicker:OnChange(col)
						local h = ColorToHSV(col)
						local _, s, v = ColorToHSV(ColorCube:GetRGB())
						ColorCube:SetColor(HSVToColor(h, s, v))
						UpdateColors(col)
					end

					function ColorCube:OnUserChanged(col)
						UpdateColors(col)
					end

				CPanel.AppearanceCategory.BackgroundColor:AddItem(BackgroundColor)

				local reset = CPanel.AppearanceCategory.BackgroundColor:Button(L"Reset")
				CPanel.AppearanceCategory.BackgroundColor.ResetBtn = reset
				reset:SetIcon("icon16/arrow_refresh.png")
				function reset:DoClick()
					CPanel.AppearanceCategory.BackgroundColor:SetColors(Color(0,150,255))
				end
			end

			CPanel.AppearanceCategory:AddItem(CPanel.AppearanceCategory.BackgroundColor)

			CPanel.AppearanceCategory.LogoImage = vgui.Create("DForm", CPanel.AppearanceCategory)
			CPanel.AppearanceCategory.LogoImage:SetLabel(L"LogoImage")

			do
				local LogoImageContainer = vgui.Create("DPanel", CPanel.AppearanceCategory.LogoImage)
				LogoImageContainer:SetTall(128 + 10)
				LogoImageContainer.Paint = nil

				local LogoImageMaterial, CustomLogoImageMaterial

				local LogoImage = vgui.Create("DPanel", LogoImageContainer)
				LogoImage:SetSize(128 + 10, 128 + 10)
				function LogoImage:Paint(w,h)
					if CPanel.AppearanceCategory.BackgroundColor.Rainbow.Label.bkeypads_rainbow_background_color:GetBool() and bKeypads.Permissions:Cached(LocalPlayer(), "keypads/appearance/rainbows") then
						if bKeypads.Performance:Optimizing() then
							surface.SetDrawColor(bKeypads:Rainbow((((CurTime() + 1) / 4) % 2) * math.pi))
							surface.DrawRect(0, 0, w, h)
						else
							bKeypads:DrawRainbow(w, h)
						end
					else
						surface.SetDrawColor(CPanel.AppearanceCategory.BackgroundColor.Color)
						surface.DrawRect(0,0,w,h)
					end

					if CustomLogoImageMaterial and not bKeypads.KeypadImages.Bans:Check(LocalPlayer()) then
						surface.SetDrawColor(255,255,255)
						surface.SetMaterial(CustomLogoImageMaterial)
						surface.DrawTexturedRect(5, 5, 128, 128)
					elseif LogoImageMaterial then
						surface.SetDrawColor(bKeypads:DarkenForeground(CPanel.AppearanceCategory.BackgroundColor.Color) and bKeypads.COLOR.SLATE or bKeypads.COLOR.WHITE)
						surface.SetMaterial(LogoImageMaterial)
						surface.DrawTexturedRect(5, 5, 128, 128)
					end

					surface.SetDrawColor(0,0,0)
					surface.DrawOutlinedRect(0,0,w,h)
				end

				function LogoImageContainer:PerformLayout()
					LogoImage:Center()
				end

				CPanel.AppearanceCategory.LogoImage:AddItem(LogoImageContainer)

				local setlogo = CPanel.AppearanceCategory.LogoImage:Button(L"SetLogoImage")
				setlogo:SetIcon("icon16/picture.png")
				setlogo.DoClick = function()
					if bKeypads.KeypadImages.Bans:Check(LocalPlayer()) then
						Derma_Message(L"BannedFromFeature", L"Error", L"Dismiss")
						surface.PlaySound("buttons/button2.wav")
					else
						bKeypads.STOOL.BlockSpawnmenuClose = true
						bKeypads.KeypadImages:Open(function(selected, url, mat)
							bKeypads.STOOL.BlockSpawnmenuClose = false
							if selected then
								CustomLogoImageMaterial = mat
								bkeypads_image_url:SetString(url)
								CPanel.AppearanceCategory.RemoveLogo:SetDisabled(false)
							end
						end)
					end
				end

				CPanel.AppearanceCategory.RemoveLogo = CPanel.AppearanceCategory.LogoImage:Button(L"Remove")
				CPanel.AppearanceCategory.RemoveLogo:SetIcon("icon16/delete.png")
				CPanel.AppearanceCategory.RemoveLogo:SetDisabled(bkeypads_image_url:GetString() == "")
				CPanel.AppearanceCategory.RemoveLogo.DoClick = function()
					bkeypads_image_url:SetString("")
					CustomLogoImageMaterial = nil
					CPanel.AppearanceCategory.RemoveLogo:SetDisabled(true)
				end

				if bkeypads_image_url:GetString() ~= "" and bKeypads.KeypadImages:VerifyURL(bkeypads_image_url:GetString()) then
					bKeypads.KeypadImages:GetImage(bkeypads_image_url:GetString(), function(success, mat)
						if success then
							CustomLogoImageMaterial = mat
						end
					end, false, true)
				end

				function CPanel.AppearanceCategory:AuthModeChanged(authMode)
					LogoImageMaterial = Material(authMode == bKeypads.AUTH_MODE.FACEID and "bkeypads/face_id" or "bkeypads/keycard")
				end
				CPanel.AppearanceCategory:AuthModeChanged(bkeypads_auth_mode:GetInt())
			end

			CPanel.AppearanceCategory:AddItem(CPanel.AppearanceCategory.LogoImage)

		CPanel:AddItem(CPanel.AppearanceCategory)

		local padding = vgui.Create("DPanel", CPanel)
		padding:SetTall(0)
		padding.Paint = nil
		CPanel:AddItem(padding)

		CPanel.LoadSave.DoClick = function(self)
			bKeypads.STOOL.BlockSpawnmenuClose = true

			local _, line = CPanel.FileSelection:GetSelectedLine()
			Derma_Query((bKeypads.L("LoadSaveWarning")):format(line.Name), L"LoadSave", L"Yes", function()
				bKeypads.STOOL.BlockSpawnmenuClose = false

				self:SetDisabled(true)
				CPanel.DeleteSave:SetDisabled(true)
				CPanel.FileSelection:ClearSelection()

				local stool = file.Read("bkeypads/saved/" .. line.Name .. "_stool.json", "DATA")
				local access = file.Read("bkeypads/saved/" .. line.Name .. "_access.dat", "DATA")
				if not stool then Derma_Message(L"LoadSaveFailed" .. " [1]", L"LoadSave", L"Dismiss") return end
				if not access then Derma_Message(L"LoadSaveFailed" .. " [2]", L"LoadSave", L"Dismiss") return end

				stool = util.JSONToTable(stool)
				if not stool then Derma_Message(L"LoadSaveFailed" .. " [3]", L"LoadSave", L"Dismiss") return end

				local success, SavedAccessMatrix = xpcall(bKeypads.KeypadData.File.Deserialize, print_err_stack, bKeypads.KeypadData.File, file.Open("bkeypads/saved/" .. line.Name .. "_access.dat", "rb", "DATA"))
				if not success or not SavedAccessMatrix then Derma_Message(L"LoadSaveFailed" .. " [4]", L"LoadSave", L"Dismiss") return end

				local success = xpcall(function()
					for convar_name, val in pairs(stool) do
						local convar = GetConVar("bkeypads_" .. convar_name)
						if isnumber(val) then
							if val % 1 == 0 then
								convar:SetInt(val)
							else
								convar:SetFloat(val)
							end
						else
							convar:SetString(val)
						end
					end

					local authMode = bkeypads_auth_mode:GetInt()

					AccessTable.AccessMatrices[authMode] = SavedAccessMatrix

					CPanel.AccessCategory:AuthModeChanged(authMode)
					CPanel.AppearanceCategory:AuthModeChanged(authMode)

					if bkeypads_image_url:GetString() ~= "" and bKeypads.KeypadImages:VerifyURL(bkeypads_image_url:GetString()) then
						bKeypads.KeypadImages:GetImage(bkeypads_image_url:GetString(), function(success, mat)
							if success then
								CustomLogoImageMaterial = mat
							end
						end, false, true)
					end

					CPanel.AppearanceCategory.BackgroundColor:SetColors(bKeypads:IntToColor(bkeypads_background_color:GetInt() or 0x0096FF))
				end, print_err_stack)

				if not success then Derma_Message(L"LoadSaveFailed" .. " [5]", L"LoadSave", L"Dismiss") return end

			end, L"Cancel", function() bKeypads.STOOL.BlockSpawnmenuClose = false end)
		end

		CPanel.bKeypads_Think = CPanel.bKeypads_Think or CPanel.Think
		CPanel.Think = function()
			if CPanel.bKeypads_Think then
				CPanel.bKeypads_Think(CPanel)
			end

			local authMode = bkeypads_auth_mode:GetInt()

			-- Wiremod Checkbox
			local can_wiremod = WireLib ~= nil and bKeypads.Config.Wiremod.Enabled == true and bKeypads.Permissions:Cached(LocalPlayer(), "keypads/wiremod")
			if can_wiremod ~= WiremodCheckbox:IsVisible() then
				WiremodCheckbox:SetVisible(can_wiremod)
				WiremodCheckbox:InvalidateParent()
			end

			-- Uncrackable Checkbox
			local can_uncrackable = bKeypads.Permissions:Cached(LocalPlayer(), "keypads/uncrackable_keypads")
			if can_uncrackable ~= UncrackableCheckbox:IsVisible() then
				UncrackableCheckbox:SetVisible(can_uncrackable)
				UncrackableCheckbox:InvalidateParent()
			end

			-- Access Method Selectors
			local can_pin     = bKeypads.Config.Scanning.ScanMethods.EnablePIN and bKeypads.Permissions:Cached(LocalPlayer(), "access_methods/pin")
			local can_faceid  = bKeypads.Config.Scanning.ScanMethods.EnableFaceID and bKeypads.Permissions:Cached(LocalPlayer(), "access_methods/faceid")
			local can_keycard = bKeypads.Config.Scanning.ScanMethods.EnableKeycards and bKeypads.Permissions:Cached(LocalPlayer(), "access_methods/keycard")

			MethodBtnContainer.PIN:SetVisible(can_pin)
			MethodBtnContainer.FaceID:SetVisible(can_faceid)
			MethodBtnContainer.Keycard:SetVisible(can_keycard)

			if bkeypads_auth_mode:GetInt() == bKeypads.AUTH_MODE.PIN and not can_pin then
				bkeypads_auth_mode:SetInt(bKeypads.AUTH_MODE.FACEID)
			end
			if bkeypads_auth_mode:GetInt() == bKeypads.AUTH_MODE.FACEID and not can_faceid then
				bkeypads_auth_mode:SetInt(bKeypads.AUTH_MODE.KEYCARD)
			end
			if bkeypads_auth_mode:GetInt() == bKeypads.AUTH_MODE.KEYCARD and not can_keycard then
				bkeypads_auth_mode:SetInt(bKeypads.AUTH_MODE.PIN)
			end

			-- Appearance Category
			local can_change_appearance = authMode ~= bKeypads.AUTH_MODE.PIN
			local can_rainbow_bg = can_change_appearance and bKeypads.Permissions:Cached(LocalPlayer(), "keypads/appearance/rainbows")
			local can_change_bg  = (not can_rainbow_bg or not CPanel.AppearanceCategory.BackgroundColor.Rainbow.Label.bkeypads_rainbow_background_color:GetBool()) and can_change_appearance and bKeypads.Permissions:Cached(LocalPlayer(), "keypads/appearance/bg_color")
			local can_change_img = can_change_appearance and bKeypads.Config.Appearance.CustomImages.Enable and bKeypads.Permissions:Cached(LocalPlayer(), "keypads/appearance/custom_img")
			local show_bg_category = can_change_bg or can_rainbow_bg
			can_change_appearance = can_change_bg or can_rainbow_bg or can_change_img

			if can_change_appearance ~= CPanel.AppearanceCategory:IsVisible() then
				CPanel.AppearanceCategory:SetVisible(can_change_appearance)
				CPanel.AppearanceCategory:InvalidateParent()
			end
			if show_bg_category ~= CPanel.AppearanceCategory.BackgroundColor:IsVisible() then
				CPanel.AppearanceCategory.BackgroundColor:SetVisible(show_bg_category)
				CPanel.AppearanceCategory.BackgroundColor:InvalidateParent()
			end
			if show_bg_category then
				if can_change_bg ~= CPanel.AppearanceCategory.BackgroundColor.ColorPicker:IsVisible() then
					CPanel.AppearanceCategory.BackgroundColor.ColorPicker:SetVisible(can_change_bg)
					CPanel.AppearanceCategory.BackgroundColor.ColorPicker:InvalidateParent()
				end
				if can_change_bg ~= CPanel.AppearanceCategory.BackgroundColor.ResetBtn:IsVisible() then
					CPanel.AppearanceCategory.BackgroundColor.ResetBtn:SetVisible(can_change_bg)
					CPanel.AppearanceCategory.BackgroundColor.ResetBtn:InvalidateParent()
				end
				if can_rainbow_bg ~= CPanel.AppearanceCategory.BackgroundColor.Rainbow:IsVisible() then
					CPanel.AppearanceCategory.BackgroundColor.Rainbow:SetVisible(can_rainbow_bg)
					CPanel.AppearanceCategory.BackgroundColor.Rainbow:InvalidateParent()
				end
			end
			if can_change_img ~= CPanel.AppearanceCategory.LogoImage:IsVisible() then
				CPanel.AppearanceCategory.LogoImage:SetVisible(can_change_img)
				CPanel.AppearanceCategory.LogoImage:InvalidateParent()
			end
			if can_change_img then
				local img_banned = bKeypads.KeypadImages.Bans:Check(LocalPlayer())
				if img_banned == CPanel.AppearanceCategory.RemoveLogo:IsVisible() then
					CPanel.AppearanceCategory.RemoveLogo:SetVisible(not img_banned)
					CPanel.AppearanceCategory.RemoveLogo:InvalidateParent()
				end
			end

			-- Keyboard Button Simulation
			local can_simulate_keyboard_press = bKeypads.Config.EnableKeyboardPress and bKeypads.Permissions:Cached(LocalPlayer(), "keypads/keyboard_button_simulation")
			if can_simulate_keyboard_press ~= KeyBindersContainer:IsVisible() then
				KeyBindersContainer:SetVisible(can_simulate_keyboard_press)
				KeyBindersContainer:InvalidateParent()
			end

			-- No-collide, freeze
			local can_create_unfrozen_keypads = bKeypads.Permissions:Cached(LocalPlayer(), "keypads/unfrozen_keypads")
			if can_create_unfrozen_keypads ~= FreezeCheckbox:IsVisible() then
				FreezeCheckbox:SetVisible(can_create_unfrozen_keypads)
				FreezeCheckbox:InvalidateParent()
			end
			local can_create_collidable_keypads = bKeypads.Permissions:Cached(LocalPlayer(), "keypads/collidable_keypads")
			if can_create_collidable_keypads ~= NoCollideCheckbox:IsVisible() then
				NoCollideCheckbox:SetVisible(can_create_collidable_keypads)
				NoCollideCheckbox:InvalidateParent()
			end

			-- Payments
			local can_set_payment = bKeypads.Economy:HasCashSystem() and bKeypads.Config.Payments.Enable and bKeypads.Permissions:Cached(LocalPlayer(), "keypads/payments")
			if can_set_payment ~= ChargeUnauthorized:IsVisible() then
				ChargeUnauthorized:SetVisible(can_set_payment)
				ChargeUnauthorized:InvalidateParent()
			end
			if can_set_payment ~= PaymentBtn:IsVisible() then
				PaymentBtn:SetVisible(can_set_payment)
				PaymentBtn:InvalidateParent()
			end

			-- Notifications
			local can_access_granted_notification = bKeypads.Config.Notifications.Enable and bKeypads.Permissions:Cached(LocalPlayer(), "notifications/access_granted")
			local can_access_denied_notification  = bKeypads.Config.Notifications.Enable and bKeypads.Permissions:Cached(LocalPlayer(), "notifications/access_denied")
			local can_notify = can_access_granted_notification or can_access_denied_notification
			if can_notify ~= CPanel.NotificationsCategory:IsVisible() then
				CPanel.NotificationsCategory:SetVisible(can_notify)
				CPanel.NotificationsCategory:InvalidateParent()
			end
			if can_access_granted_notification ~= CPanel.NotificationsCategory.AccessGranted:IsVisible() then
				CPanel.NotificationsCategory.AccessGranted:SetVisible(can_access_granted_notification)
				CPanel.NotificationsCategory.AccessGranted:InvalidateParent()
			end
			if can_access_denied_notification ~= CPanel.NotificationsCategory.AccessDenied:IsVisible() then
				CPanel.NotificationsCategory.AccessDenied:SetVisible(can_access_denied_notification)
				CPanel.NotificationsCategory.AccessDenied:InvalidateParent()
			end

			-- Destruction
			local can_change_destruction = bKeypads.Config.KeypadDestruction.Enable and bKeypads.Permissions:Cached(LocalPlayer(), "destruction/indestructible") or bKeypads.Permissions:Cached(LocalPlayer(), "destruction/destructible")
			if can_change_destruction ~= CPanel.DestructionCategory:IsVisible() then
				CPanel.DestructionCategory:SetVisible(can_change_destruction)
				CPanel.DestructionCategory:InvalidateParent()
			end

			local can_change_destruction_values = bKeypads.Permissions:Cached(LocalPlayer(), "destruction/override_config")
			if can_change_destruction_values ~= CPanel.DestructionCategory.MaxHealth:IsVisible() then
				CPanel.DestructionCategory.MaxHealth:SetVisible(can_change_destruction_values)
				CPanel.DestructionCategory.MaxHealth:InvalidateParent()

				CPanel.DestructionCategory.Shield:SetVisible(can_change_destruction_values)
				CPanel.DestructionCategory.Shield:InvalidateParent()
			end

			if can_change_destruction_values then
				local indestructible
				if bKeypads.Config.KeypadDestruction.Enable then
					indestructible = CPanel.DestructionCategory.Indestructible:GetChecked()
				else
					indestructible = not CPanel.DestructionCategory.Destructible:GetChecked()
				end

				if CPanel.DestructionCategory.MaxHealth:GetDisabled() ~= indestructible then
					CPanel.DestructionCategory.MaxHealth:SetDisabled(indestructible)
				end
				if CPanel.DestructionCategory.Shield:GetDisabled() ~= indestructible then
					CPanel.DestructionCategory.Shield:SetDisabled(indestructible)
				end
			end

			if bKeypads.Config.KeypadDestruction.Enable ~= CPanel.DestructionCategory.Indestructible:IsVisible() then
				CPanel.DestructionCategory.Indestructible:SetVisible(bKeypads.Config.KeypadDestruction.Enable)
				CPanel.DestructionCategory.Indestructible:InvalidateParent()
			end
			if bKeypads.Config.KeypadDestruction.Enable ~= not CPanel.DestructionCategory.Destructible:IsVisible() then
				CPanel.DestructionCategory.Destructible:SetVisible(not bKeypads.Config.KeypadDestruction.Enable)
				CPanel.DestructionCategory.Destructible:InvalidateParent()
			end

			local can_mirror_keypads = bKeypads.Config.KeypadMirroring and bKeypads.Permissions:Cached(LocalPlayer(), "mirror_keypads")
			if can_mirror_keypads ~= MirrorPlacement:IsVisible() then
				MirrorPlacement:SetVisible(can_mirror_keypads)
				MirrorPlacement:InvalidateParent()
			end

			local can_see_auto_fading_door = not bKeypads.Config.KeypadOnlyFadingDoors or bKeypads.Permissions:Cached(LocalPlayer(), "keypads/bypass_keypad_only_fading_doors")
			if can_see_auto_fading_door ~= AutoFadingDoor:IsVisible() then
				AutoFadingDoor:SetVisible(can_see_auto_fading_door)
				AutoFadingDoor:InvalidateParent()
			end

			local can_create_unwelded_keypads = can_see_auto_fading_door and bKeypads.Permissions:Cached(LocalPlayer(), "keypads/unwelded_keypads")
			if can_create_unwelded_keypads ~= WeldCheckbox:IsVisible() then
				WeldCheckbox:SetVisible(can_create_unwelded_keypads)
				WeldCheckbox:InvalidateParent()
			end

			local showConfigurationCategory = can_create_unfrozen_keypads or can_create_unwelded_keypads or can_create_collidable_keypads or WiremodCheckbox:IsVisible()
			if showConfigurationCategory ~= CPanel.ConfigCategory:IsVisible() then
				CPanel.ConfigCategory:SetVisible(showConfigurationCategory)
				CPanel.ConfigCategory:InvalidateParent()
			end
		end

		hook.Run("bKeypads.BuildCPanel", CPanel)
	end

	do
		local initialAccessMatrices = {}
		net.Receive("bKeypads.KeypadData.Fetch", function()
			local token = net.ReadUInt(16)

			if IsValid(bKeypads.AccessTable) and bKeypads.AccessTable:GetAccessMatrix() then
				net.Start("bKeypads.KeypadData.Push")
					net.WriteUInt(token, 16)
					bKeypads.KeypadData.Net:Serialize(bKeypads.AccessTable:GetAccessMatrix())
				net.SendToServer()
			else
				local authMode = GetConVar("bkeypads_auth_mode"):GetInt()
				if not initialAccessMatrices[authMode] then
					if file.Exists("bkeypads/stool/access_matrix_" .. authMode .. ".dat", "DATA") then
						local success, SavedAccessMatrix = pcall(bKeypads.KeypadData.File.Deserialize, bKeypads.KeypadData.File, file.Open("bkeypads/stool/access_matrix_" .. authMode .. ".dat", "rb", "DATA")) --true, bKeypads.KeypadData.File:Deserialize(bKeypads.KeypadData.File:Open("bkeypads/stool_access_matrices.dat", false, "DATA", true)) --
						if success and SavedAccessMatrix then
							initialAccessMatrices[authMode] = SavedAccessMatrix
						else
							file.Delete("bkeypads/stool/access_matrix_" .. authMode .. ".dat")
							initialAccessMatrices[authMode] = bKeypads.KeypadData:AccessMatrix()
						end
					else
						initialAccessMatrices[authMode] = bKeypads.KeypadData:AccessMatrix()
					end
				end

				net.Start("bKeypads.KeypadData.Push")
					net.WriteUInt(token, 16)
					bKeypads.KeypadData.Net:Serialize(initialAccessMatrices[authMode])
				net.SendToServer()
			end
		end)
	end

	local function KeypadAccessMatrixCopy()
		local CPanel
		if not IsValid(bKeypads.AccessTable) then
			CPanel = controlpanel.Get("bkeypads")
			bKeypads.STOOL.BuildCPanel(CPanel)
			CPanel:SetVisible(false)

			if not IsValid(bKeypads.AccessTable) then
				controlpanel.Clear("bkeypads")
				return
			end
		end

		local bkeypads_auth_mode = GetConVar("bkeypads_auth_mode")

		local accessMatrix = bKeypads.KeypadData.Net:Deserialize()
		local authMode = net.ReadUInt(4)

		bKeypads.AccessTable.AccessMatrices[authMode] = table.Copy(accessMatrix)
		bKeypads.AccessTable:SaveAccessMatrix()

		bkeypads_auth_mode:SetInt(0)
		bkeypads_auth_mode:SetInt(authMode)

		surface.PlaySound("garrysmod/content_downloaded.wav")
		notification.AddLegacy(L"KeypadAccessMatrixCopied", NOTIFY_GENERIC, 2)

		if CPanel then controlpanel.Clear("bkeypads") end
	end
	local function KeypadAccessMatrixCopyError(err)
		surface.PlaySound("buttons/button2.wav")
		notification.AddLegacy(L"KeypadAccessMatrixCopyError", NOTIFY_ERROR, 5)

		ErrorNoHalt("ERROR: " .. err .. "\n")
		debug.Trace()
	end
	net.Receive("bKeypads.KeypadAccessMatrix.Copy", function()
		notification.Kill("KeypadAccessMatrixCopying")
		xpcall(KeypadAccessMatrixCopy, KeypadAccessMatrixCopyError)
	end)
end