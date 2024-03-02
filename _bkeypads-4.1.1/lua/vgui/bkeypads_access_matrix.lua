local PANEL = {}

local bkeypads_auth_mode
local L
local matKeycard

local function SolidColorPaint(self,w,h)
	surface.SetDrawColor(self.SolidColor)
	surface.DrawRect(0,0,w,h)
end

local function AddAccessGroupIcon(line)
	line.AccessTypeIcon = vgui.Create("DImage", line)
	line.AccessTypeIcon:Dock(LEFT)
	line.AccessTypeIcon:DockMargin(0,0,0,1)
	line.AccessTypeIcon:SetWide(16)
	line.AccessTypeIcon:SetImage(line.AccessType == bKeypads.ACCESS_TYPE.BLACKLIST and "icon16/delete.png" or "icon16/accept.png")
	line.AccessTypeIcon.bKeypads_Tooltip = line.AccessType == bKeypads.ACCESS_TYPE.BLACKLIST and L"Blacklist" or L"Whitelist"
	line.AccessTypeIcon:MoveToBack()
end

local PopulateFunctions = {

	[bKeypads.ACCESS_GROUP.PLAYER] = function(self, AccessType, steamid, name)
		local steamid64 = util.SteamIDTo64(steamid)

		local line = self:AddLine("", "", steamid, name or bKeypads.PlayerSelector:LookupName(steamid64) or "")
		line.bKeypads_Tooltip = L"Player"

		line.AvatarImage = vgui.Create("AvatarImage", line)
		line.AvatarImage:Dock(LEFT)
		line.AvatarImage:SetWide(17)
		line.AvatarImage:SetSteamID(steamid64, 32)

		line.AccessType = AccessType
		line.Type = bKeypads.ACCESS_GROUP.PLAYER
		line.Key = steamid

		AddAccessGroupIcon(line)
	end,

	[bKeypads.ACCESS_GROUP.KEYCARD_LEVEL] = function(self, AccessType, level)
		if bKeypads.Keycards.Levels[level] then
			local line = self:AddLine("", "", level, bKeypads.Keycards.Levels[level].Name)
			line.bKeypads_Tooltip = L"GroupKeycardLevel"

			line.Icon = vgui.Create("DImage", line)
			line.Icon:Dock(LEFT)
			line.Icon:DockMargin(0,0,0,1)
			line.Icon:SetWide(16)
			line.Icon:SetMaterial(matKeycard)
			line.Icon:SetImageColor(bKeypads.Keycards.Levels[level].Color or Color(255,0,0))

			line.AccessType = AccessType
			line.Type = bKeypads.ACCESS_GROUP.KEYCARD_LEVEL
			line.Key = level

			AddAccessGroupIcon(line)
		else
			self:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.KEYCARD_LEVEL][level] = nil
		end
	end,

	[bKeypads.ACCESS_GROUP.SUPERIOR_KEYCARDS] = function(self, AccessType)
		local line = self:AddLine("", "", L"AllSuperiorKeycards")
		line.bKeypads_Tooltip = L"AllSuperiorKeycards"

		line.Icon = vgui.Create("DImage", line)
		line.Icon:Dock(LEFT)
		line.Icon:DockMargin(0,0,0,1)
		line.Icon:SetWide(16)
		line.Icon:SetImage("icon16/sitemap_color.png")

		line.AccessType = AccessType
		line.Type = bKeypads.ACCESS_GROUP.SUPERIOR_KEYCARDS

		AddAccessGroupIcon(line)
	end,

	[bKeypads.ACCESS_GROUP.STEAM_FRIENDS] = function(self, AccessType)
		local line = self:AddLine("", "", L"SteamFriends")
		line.bKeypads_Tooltip = L"SteamFriends"

		line.Icon = vgui.Create("DImage", line)
		line.Icon:Dock(LEFT)
		line.Icon:DockMargin(0,0,0,1)
		line.Icon:SetWide(16)
		line.Icon:SetImage("icon16/emoticon_grin.png")

		line.AccessType = AccessType
		line.Type = bKeypads.ACCESS_GROUP.STEAM_FRIENDS

		AddAccessGroupIcon(line)
	end,

	[bKeypads.ACCESS_GROUP.USERGROUP] = function(self, AccessType, usergroup)
		local line = self:AddLine("", "", usergroup, "")
		line.bKeypads_Tooltip = L"Usergroup"

		line.Icon = vgui.Create("DImage", line)
		line.Icon:Dock(LEFT)
		line.Icon:DockMargin(0,0,0,1)
		line.Icon:SetWide(16)
		line.Icon:SetImage((usergroup == "admin" or usergroup == "superadmin") and "icon16/shield.png" or "icon16/group.png")

		line.AccessType = AccessType
		line.Type = bKeypads.ACCESS_GROUP.USERGROUP
		line.Key = usergroup

		AddAccessGroupIcon(line)
	end,

	[bKeypads.ACCESS_GROUP.DARKRP_JOB] = function(self, AccessType, command)
		local job = DarkRP.getJobByCommand(command)
		if job then
			local line = self:AddLine("", "", "/" .. command, job.name)
			line.bKeypads_Tooltip = L"Job"

			line.EntryColor = vgui.Create("DPanel", line)
			line.EntryColor:Dock(LEFT)
			line.EntryColor:SetWide(17)
			line.EntryColor.SolidColor = job.color
			line.EntryColor.Paint = SolidColorPaint

			line.AccessType = AccessType
			line.Type = bKeypads.ACCESS_GROUP.DARKRP_JOB
			line.Key = command

			AddAccessGroupIcon(line)
		else
			self:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.DARKRP_JOB][command] = nil
		end
	end,

	[bKeypads.ACCESS_GROUP.TEAM] = function(self, AccessType, teamName)
		local teamIndex
		for index, teamTbl in pairs(team.GetAllTeams()) do
			if teamTbl.Name == teamName then
				teamIndex = index
				break
			end
		end
		if teamIndex then
			local line = self:AddLine("", "", teamName, "")
			line.bKeypads_Tooltip = L"Team"

			line.EntryColor = vgui.Create("DPanel", line)
			line.EntryColor:Dock(LEFT)
			line.EntryColor:SetWide(17)
			line.EntryColor.SolidColor = team.GetColor(teamIndex)
			line.EntryColor.Paint = SolidColorPaint

			line.AccessType = AccessType
			line.Type = bKeypads.ACCESS_GROUP.TEAM
			line.Key = teamName

			AddAccessGroupIcon(line)
		else
			self:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.TEAM][teamName] = nil
		end
	end,

	[bKeypads.ACCESS_GROUP.DARKRP_JOB_CATEGORY] = function(self, AccessType, category_name)
		local category = bKeypads.DarkRP.JobCategories.Members[category_name]
		if category then
			local line = self:AddLine("", "", category_name, "")
			line.bKeypads_Tooltip = L"GroupJobCategory"

			line.EntryColor = vgui.Create("DPanel", line)
			line.EntryColor:Dock(LEFT)
			line.EntryColor:SetWide(17)
			line.EntryColor.SolidColor = category.color
			line.EntryColor.Paint = SolidColorPaint

			line.AccessType = AccessType
			line.Type = bKeypads.ACCESS_GROUP.DARKRP_JOB_CATEGORY
			line.Key = category_name

			AddAccessGroupIcon(line)
		else
			self:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.DARKRP_JOB_CATEGORY][category_name] = nil
		end
	end,

	[bKeypads.ACCESS_GROUP.DARKRP_AGENDA_GROUP] = function(self, AccessType, agenda_name)
		local agenda = bKeypads.DarkRP.Agendas.Members[agenda_name]
		if agenda then
			local line = self:AddLine("", "", agenda_name, "")
			line.bKeypads_Tooltip = L"GroupAgendaGroup"

			line.Icon = vgui.Create("DImage", line)
			line.Icon:Dock(LEFT)
			line.Icon:DockMargin(0,0,0,1)
			line.Icon:SetWide(16)
			line.Icon:SetImage("icon16/comments.png")

			line.AccessType = AccessType
			line.Type = bKeypads.ACCESS_GROUP.DARKRP_AGENDA_GROUP
			line.Key = agenda_name

			AddAccessGroupIcon(line)
		else
			self:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.DARKRP_AGENDA_GROUP][agenda_name] = nil
		end
	end,

	[bKeypads.ACCESS_GROUP.DARKRP_DOOR_GROUP] = function(self, AccessType, door_group_name)
		local doorGroup = bKeypads.DarkRP.DoorGroups.Members[door_group_name]
		if doorGroup then
			local line = self:AddLine("", "", door_group_name, "")
			line.bKeypads_Tooltip = L"GroupDoorGroup"

			line.Icon = vgui.Create("DImage", line)
			line.Icon:Dock(LEFT)
			line.Icon:DockMargin(0,0,0,1)
			line.Icon:SetWide(16)
			line.Icon:SetImage("icon16/door.png")

			line.AccessType = AccessType
			line.Type = bKeypads.ACCESS_GROUP.DARKRP_DOOR_GROUP
			line.Key = door_group_name

			AddAccessGroupIcon(line)
		else
			self:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.DARKRP_DOOR_GROUP][door_group_name] = nil
		end
	end,

	[bKeypads.ACCESS_GROUP.DARKRP_DEMOTE_GROUP] = function(self, AccessType, demote_group_name)
		local doorGroup = bKeypads.DarkRP.DemoteGroups[demote_group_name]
		if doorGroup then
			local line = self:AddLine("", "", demote_group_name, "")
			line.bKeypads_Tooltip = L"GroupDemoteGroup"

			line.Icon = vgui.Create("DImage", line)
			line.Icon:Dock(LEFT)
			line.Icon:DockMargin(0,0,0,1)
			line.Icon:SetWide(16)
			line.Icon:SetImage("icon16/user_suit.png")

			line.AccessType = AccessType
			line.Type = bKeypads.ACCESS_GROUP.DARKRP_DEMOTE_GROUP
			line.Key = demote_group_name

			AddAccessGroupIcon(line)
		else
			self:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.DARKRP_DEMOTE_GROUP][demote_group_name] = nil
		end
	end,

	[bKeypads.ACCESS_GROUP.HELIX_FLAG] = function(self, AccessType, flag_name)
		local flag = ix.flag.list[flag_name]
		if flag then
			local line = self:AddLine("", "", flag_name, "")
			line.bKeypads_Tooltip = L"HelixFlag" .. "\n" .. (L"FlagName"):format(flag_name) .. (flag.description ~= nil and ("\n" .. flag.description) or "")

			line.Icon = vgui.Create("DImage", line)
			line.Icon:Dock(LEFT)
			line.Icon:DockMargin(0,0,0,1)
			line.Icon:SetWide(16)
			line.Icon:SetImage("icon16/flag_green.png")

			line.AccessType = AccessType
			line.Type = bKeypads.ACCESS_GROUP.HELIX_FLAG
			line.Key = flag_name

			AddAccessGroupIcon(line)
		else
			self:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.HELIX_FLAG][flag_name] = nil
		end
	end,

	[bKeypads.ACCESS_GROUP.MRS_RANK] = function(self, AccessType, matrix_id)
		local rank, group = matrix_id:match("^(.-)\n(.-)$")

		local rankData = MRS.Ranks[group]
		if rankData and rankData.ranks then
			local ranks = rankData.ranks
			rankData = nil
			for _, v in pairs(ranks) do
				if v.name == rank then
					rankData = v
					break
				end
			end
		end

		if rankData then
			local line = self:AddLine("", "", group, rankData.name)
			line.bKeypads_Tooltip = "Mac's Rank System"

			line.Icon = vgui.Create("DImage", line)
			line.Icon:Dock(LEFT)
			line.Icon:DockMargin(0,0,0,1)
			line.Icon:SetWide(16)
			line.Icon:SetImage("icon16/award_star_gold_1.png")

			line.AccessType = AccessType
			line.Type = bKeypads.ACCESS_GROUP.MRS_RANK
			line.Key = matrix_id

			AddAccessGroupIcon(line)
			return
		end

		self:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.MRS_RANK][matrix_id] = nil
	end,

	[bKeypads.ACCESS_GROUP.MRS_SUPERIOR_RANKS] = function(self, AccessType)
		local line = self:AddLine("", "", L"AllSuperiorRanks")
		line.bKeypads_Tooltip = L"AllSuperiorRanks"

		line.Icon = vgui.Create("DImage", line)
		line.Icon:Dock(LEFT)
		line.Icon:DockMargin(0,0,0,1)
		line.Icon:SetWide(16)
		line.Icon:SetImage("icon16/sitemap_color.png")

		line.AccessType = AccessType
		line.Type = bKeypads.ACCESS_GROUP.MRS_SUPERIOR_RANKS

		AddAccessGroupIcon(line)
	end,

	[bKeypads.ACCESS_GROUP.CUSTOM_TEAM_GROUP] = function(self, AccessType, team_group_name)
		local teamGroup = bKeypads.CustomAccess.UserConfig.TeamGroups[team_group_name]
		if teamGroup then
			local line = self:AddLine("", "", team_group_name, "")
			line.bKeypads_Tooltip = L"GroupCustomTeamGroup"

			line.Icon = vgui.Create("DImage", line)
			line.Icon:Dock(LEFT)
			line.Icon:DockMargin(0,0,0,1)
			line.Icon:SetWide(16)
			line.Icon:SetImage("icon16/script_code_red.png")

			line.AccessType = AccessType
			line.Type = bKeypads.ACCESS_GROUP.CUSTOM_TEAM_GROUP
			line.Key = team_group_name

			AddAccessGroupIcon(line)
		else
			self:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.CUSTOM_TEAM_GROUP][team_group_name] = nil
		end
	end,

	[bKeypads.ACCESS_GROUP.CUSTOM_LUA_FUNCTION] = function(self, AccessType, lua_func_name)
		local LuaFunction = bKeypads.CustomAccess.UserConfig.LuaFunctions[lua_func_name]
		if LuaFunction then
			local line = self:AddLine("", "", lua_func_name, "")
			line.bKeypads_Tooltip = L"GroupCustomLuaFunction"

			line.Icon = vgui.Create("DImage", line)
			line.Icon:Dock(LEFT)
			line.Icon:DockMargin(0,0,0,1)
			line.Icon:SetWide(16)
			line.Icon:SetImage("icon16/script_code.png")

			line.AccessType = AccessType
			line.Type = bKeypads.ACCESS_GROUP.CUSTOM_LUA_FUNCTION
			line.Key = lua_func_name

			AddAccessGroupIcon(line)
		else
			self:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.CUSTOM_LUA_FUNCTION][lua_func_name] = nil
		end
	end,

	[bKeypads.ACCESS_GROUP.CUSTOM_ADDON_FUNCTION] = function(self, AccessType, id)
		local customAddonEntry = bKeypads.CustomAccess.Addons.KeyTable[id]
		if customAddonEntry and customAddonEntry.Addon then
			local line = self:AddLine("", "", customAddonEntry.Name, "")
			line.bKeypads_Tooltip = customAddonEntry.Addon.Name

			if IsColor(customAddonEntry.Icon) or (istable(customAddonEntry.Icon) and customAddonEntry.Icon.r and customAddonEntry.Icon.g and customAddonEntry.Icon.b) then
				line.EntryColor = vgui.Create("DPanel", line)
				line.EntryColor:Dock(LEFT)
				line.EntryColor:SetWide(17)
				line.EntryColor.SolidColor = category.color
				line.EntryColor.Paint = SolidColorPaint
			elseif isstring(customAddonEntry.Icon) then
				line.Icon = vgui.Create("DImage", line)
				line.Icon:Dock(LEFT)
				line.Icon:DockMargin(0,0,0,1)
				line.Icon:SetWide(16)
				line.Icon:SetImage(customAddonEntry.Icon)
			elseif type(customAddonEntry.Icon) == "IMaterial" then
				line.Icon = vgui.Create("DImage", line)
				line.Icon:Dock(LEFT)
				line.Icon:DockMargin(0,0,0,1)
				line.Icon:SetWide(16)
				line.Icon:SetMaterial(customAddonEntry.Icon)
			end

			line.AccessType = AccessType
			line.Type = bKeypads.ACCESS_GROUP.CUSTOM_ADDON_FUNCTION
			line.Key = id

			AddAccessGroupIcon(line)
		else
			self:GetAccessMatrix()[AccessType][bKeypads.ACCESS_GROUP.CUSTOM_ADDON_FUNCTION][id] = nil
		end
	end,

	[bKeypads.ACCESS_GROUP.PAYMENT] = function(self, amount)
		local line = self:AddLine("", "", bKeypads.Economy:formatMoney(amount), L"AccessCharge")
		line.bKeypads_Tooltip = L"Payment"

		line.Icon = vgui.Create("DImage", line)
		line.Icon:Dock(LEFT)
		line.Icon:DockMargin(0,0,0,1)
		line.Icon:SetWide(16)
		line.Icon:SetImage("icon16/money.png")

		line.Type = bKeypads.ACCESS_GROUP.PAYMENT

		AddAccessGroupIcon(line)
	end,

}

function PANEL:SafePopulate()
	local AccessMatrix = self:GetAccessMatrix()

	if AccessMatrix[bKeypads.ACCESS_GROUP.PAYMENT] and bKeypads.Economy:HasCashSystem() then
		PopulateFunctions[bKeypads.ACCESS_GROUP.PAYMENT](self, AccessMatrix[bKeypads.ACCESS_GROUP.PAYMENT])
	end

	for _, AccessType in ipairs(bKeypads.ACCESS_TYPES) do

		for id in pairs(AccessMatrix[AccessType][bKeypads.ACCESS_GROUP.CUSTOM_ADDON_FUNCTION] or {}) do
			PopulateFunctions[bKeypads.ACCESS_GROUP.CUSTOM_ADDON_FUNCTION](self, AccessType, id)
		end
		for lua_func_name in pairs(AccessMatrix[AccessType][bKeypads.ACCESS_GROUP.CUSTOM_LUA_FUNCTION] or {}) do
			PopulateFunctions[bKeypads.ACCESS_GROUP.CUSTOM_LUA_FUNCTION](self, AccessType, lua_func_name)
		end
		for team_group_name in pairs(AccessMatrix[AccessType][bKeypads.ACCESS_GROUP.CUSTOM_TEAM_GROUP] or {}) do
			PopulateFunctions[bKeypads.ACCESS_GROUP.CUSTOM_TEAM_GROUP](self, AccessType, team_group_name)
		end

		if bkeypads_auth_mode:GetInt() == bKeypads.AUTH_MODE.KEYCARD then

			if AccessMatrix[AccessType][bKeypads.ACCESS_GROUP.SUPERIOR_KEYCARDS] then
				PopulateFunctions[bKeypads.ACCESS_GROUP.SUPERIOR_KEYCARDS](self, AccessType)
			end
			for level in pairs(AccessMatrix[AccessType][bKeypads.ACCESS_GROUP.KEYCARD_LEVEL] or {}) do
				PopulateFunctions[bKeypads.ACCESS_GROUP.KEYCARD_LEVEL](self, AccessType, level)
			end

		end

		if AccessMatrix[AccessType][bKeypads.ACCESS_GROUP.STEAM_FRIENDS] then
			PopulateFunctions[bKeypads.ACCESS_GROUP.STEAM_FRIENDS](self, AccessType)
		end

		for steamid, name in pairs(AccessMatrix[AccessType][bKeypads.ACCESS_GROUP.PLAYER] or {}) do
			PopulateFunctions[bKeypads.ACCESS_GROUP.PLAYER](self, AccessType, steamid, name)
		end

		for usergroup in pairs(AccessMatrix[AccessType][bKeypads.ACCESS_GROUP.USERGROUP] or {}) do
			PopulateFunctions[bKeypads.ACCESS_GROUP.USERGROUP](self, AccessType, usergroup)
		end

		if DarkRP then
			for _, access_group in ipairs({
				bKeypads.ACCESS_GROUP.DARKRP_JOB,
				bKeypads.ACCESS_GROUP.DARKRP_JOB_CATEGORY,
				bKeypads.ACCESS_GROUP.DARKRP_AGENDA_GROUP,
				bKeypads.ACCESS_GROUP.DARKRP_DOOR_GROUP,
				bKeypads.ACCESS_GROUP.DARKRP_DEMOTE_GROUP
			}) do
				if not AccessMatrix[AccessType][access_group] then continue end
				for v in pairs(AccessMatrix[AccessType][access_group]) do
					PopulateFunctions[access_group](self, AccessType, v)
				end
			end
		else
			for t in pairs(AccessMatrix[AccessType][bKeypads.ACCESS_GROUP.TEAM] or {}) do
				PopulateFunctions[bKeypads.ACCESS_GROUP.TEAM](self, AccessType, t)
			end
		end

		if ix and ix.flag then
			for flag in pairs(AccessMatrix[AccessType][bKeypads.ACCESS_GROUP.HELIX_FLAG] or {}) do
				PopulateFunctions[bKeypads.ACCESS_GROUP.HELIX_FLAG](self, AccessType, flag)
			end
		end

		if MRS and MRS.Ranks then
			if AccessMatrix[AccessType][bKeypads.ACCESS_GROUP.MRS_SUPERIOR_RANKS] then
				PopulateFunctions[bKeypads.ACCESS_GROUP.MRS_SUPERIOR_RANKS](self, AccessType)
			end
			for rank in pairs(AccessMatrix[AccessType][bKeypads.ACCESS_GROUP.MRS_RANK] or {}) do
				PopulateFunctions[bKeypads.ACCESS_GROUP.MRS_RANK](self, AccessType, rank)
			end
		end
	end
end

local function populateFailed(err)
	ErrorNoHalt("Failed to load data from saved access matrix - it might be from an older/newer version of the addon!\n")
	ErrorNoHalt(err .. "\n")
	debug.Trace()
end
function PANEL:Populate()
	self:Clear()

	local succ = xpcall(self.SafePopulate, populateFailed, self)
	if succ then
		self:SaveAccessMatrix()
	else
		self:ResetAccessMatrix()
	end

	if self.PostPopulate then
		self:PostPopulate()
	end
end

function PANEL:Init()
	bkeypads_auth_mode = bkeypads_auth_mode or GetConVar("bkeypads_auth_mode")
	L = bKeypads.L
	matKeycard = matKeycard or Material("bkeypads/keycard")

	self:SetSortable(false)

	local col = self:AddColumn("")
	col:SetMaxWidth(17)
	col:SetMinWidth(17)

	local col = self:AddColumn("")
	col:SetMaxWidth(17)
	col:SetMinWidth(17)

	self:AddColumn(L"Value")
	self:AddColumn(L"Name")

	self.AccessMatrices = {}
	self:ResetAccessMatrix()
end

function PANEL:SetUseConVar(m_bUseConVar)
	self.m_bUseConVar = m_bUseConVar
end

function PANEL:GetAccessMatrix()
	if self.m_bUseConVar then
		return self.AccessMatrices[bkeypads_auth_mode:GetInt()]
	else
		return self.AccessMatrix
	end
end

function PANEL:ResetAccessMatrix()
	if self.m_bUseConVar then
		self.AccessMatrices[bkeypads_auth_mode:GetInt()] = bKeypads.KeypadData:AccessMatrix()
	else
		self.AccessMatrix = bKeypads.KeypadData:AccessMatrix()
	end
end

function PANEL:SaveAccessMatrix()
	if self.m_bUseConVar then
		local f = bKeypads.KeypadData.File:Open("bkeypads/stool/access_matrix_" .. bkeypads_auth_mode:GetInt() .. ".dat", true, "DATA")
		if f then
			bKeypads.KeypadData.File:Serialize(f, self:GetAccessMatrix())
		else
			ErrorNoHalt("Failed to save to garrysmod/data/bkeypads/stool/access_matrix_" .. bkeypads_auth_mode:GetInt() .. ".dat, file is likely being used by another process\n")
			ErrorNoHalt("Typing spawnmenu_reload in console a couple times might fix this\n")
		end
	end
end

function PANEL:OnRowRightClick()
	for _, line in ipairs(self:GetSelected()) do
		if line.Type == bKeypads.ACCESS_GROUP.PAYMENT then
			self:GetAccessMatrix()[line.Type] = false
		elseif bKeypads.ACCESS_GROUP_BOOL[line.Type] then
			self:GetAccessMatrix()[line.AccessType][line.Type] = false
		else
			self:GetAccessMatrix()[line.AccessType][line.Type][line.Key] = nil
		end
		self:RemoveLine(line:GetID())
	end

	self:SaveAccessMatrix()

	if self.PostPopulate then
		self:PostPopulate()
	end

	surface.PlaySound("friends/friend_join.wav")
end

function PANEL:OnRowSelected(rowIndex, row)
	if input.IsMouseDown(MOUSE_RIGHT) then return end

	surface.PlaySound("garrysmod/ui_return.wav")

	local DMenu = DermaMenu(nil, row)

	local icon = DMenu:AddOption(row.bKeypads_Tooltip)
	icon.DoClick = bKeypads.noop
	if row.Type == bKeypads.ACCESS_GROUP.KEYCARD_LEVEL then
		icon:SetImage("icon16/vcard.png")
	elseif IsValid(row.Icon) then
		icon:SetMaterial(row.Icon:GetMaterial())
	elseif IsValid(row.EntryColor) then
		icon:SetImage("icon16/box.png")
		icon.EntryColor = vgui.Create("DPanel", icon.m_Image)
		icon.EntryColor:Dock(FILL)
		icon.EntryColor.SolidColor = row.EntryColor.SolidColor
		icon.EntryColor.Paint = SolidColorPaint
	elseif IsValid(row.AvatarImage) then
		icon:SetImage("icon16/box.png")
		icon.AvatarImage = vgui.Create("AvatarImage", icon.m_Image)
		icon.AvatarImage:Dock(FILL)
		icon.AvatarImage:SetSteamID(util.SteamIDTo64(row.Key), 32)
	end

	if row.AccessType ~= nil then
		local access_type = DMenu:AddOption(row.AccessType == bKeypads.ACCESS_TYPE.WHITELIST and L"Whitelisted" or L"Blacklisted")
		access_type:SetIcon(row.AccessType == bKeypads.ACCESS_TYPE.WHITELIST and "icon16/accept.png" or "icon16/delete.png")
		access_type.m_Image:SetSize(16, 16)
		access_type.m_Image:InvalidateParent()
		access_type.DoClick = bKeypads.noop
	end

	DMenu:AddSpacer()

	local NameColumn = row:GetColumnText(4)
	local CopyName = DMenu:AddOption(L"CopyName", function()
		if GAS then
			GAS:SetClipboardText(NameColumn)
		else
			surface.PlaySound("garrysmod/content_downloaded.wav")
			SetClipboardText(NameColumn)
		end
	end)
	CopyName:SetIcon("icon16/page_copy.png")
	CopyName:SetDisabled(not NameColumn or (isstring(NameColumn) and #NameColumn == 0))

	local ValueColumn = row:GetColumnText(3)
	local CopyValue = DMenu:AddOption(L"CopyValue", function()
		if GAS then
			GAS:SetClipboardText(ValueColumn)
		else
			surface.PlaySound("garrysmod/content_downloaded.wav")
			SetClipboardText(ValueColumn)
		end
	end)
	CopyValue:SetIcon("icon16/page_copy.png")
	CopyValue:SetDisabled(not ValueColumn or (isstring(ValueColumn) and #ValueColumn == 0))

	DMenu:AddSpacer()

	DMenu:AddOption(L"Remove", function()
		if not IsValid(row) then return end
		self:ClearSelection()
		self:SelectItem(row)
		self:OnRowRightClick()
	end):SetIcon("icon16/delete.png")

	DMenu:Open()
end

function PANEL:ResolveConflicts(AccessType)
	local OppositeAccessMatrix = self:GetAccessMatrix()[AccessType == bKeypads.ACCESS_TYPE.WHITELIST and bKeypads.ACCESS_TYPE.BLACKLIST or bKeypads.ACCESS_TYPE.WHITELIST]
	for Type, Entries in pairs(self:GetAccessMatrix()[AccessType]) do
		if istable(Entries) then
			for Entry in pairs(Entries) do
				if OppositeAccessMatrix[Type] and OppositeAccessMatrix[Type][Entry] then
					OppositeAccessMatrix[Type][Entry] = nil
				end
			end
		elseif isbool(Entries) then
			if OppositeAccessMatrix[Type] then
				OppositeAccessMatrix[Type] = nil
			end
		end
	end
end

function PANEL:LoadAccessMatrix(authMode)
	if not self.AccessMatrices[authMode] then
		if file.Exists("bkeypads/stool/access_matrix_" .. authMode .. ".dat", "DATA") then
			local f = bKeypads.KeypadData.File:Open("bkeypads/stool/access_matrix_" .. authMode .. ".dat", false, "DATA")
			local success, SavedAccessMatrix = pcall(bKeypads.KeypadData.File.Deserialize, bKeypads.KeypadData.File, f)
			if success and SavedAccessMatrix then
				self.AccessMatrices[authMode] = SavedAccessMatrix
			else
				f:Close()
				file.Delete("bkeypads/stool/access_matrix_" .. authMode .. ".dat")
				self.AccessMatrices[authMode] = bKeypads.KeypadData:AccessMatrix()
			end
		else
			self.AccessMatrices[authMode] = bKeypads.KeypadData:AccessMatrix()

			-- Add the local player to the default access matrix for convenience
			if authMode == bKeypads.AUTH_MODE.KEYCARD or authMode == bKeypads.AUTH_MODE.FACEID then
				self.AccessMatrices[authMode][bKeypads.ACCESS_TYPE.WHITELIST][bKeypads.ACCESS_GROUP.PLAYER][LocalPlayer():SteamID()] = LocalPlayer():Nick()
			end
		end
	end

	self:Populate()
end

derma.DefineControl("bKeypads.AccessMatrix", nil, PANEL, "DListView")