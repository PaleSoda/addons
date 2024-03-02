TOOL.Category = "Billy's Keypads"
TOOL.Name = "#bKeypads_Linker"

TOOL.CanLinkDoors = true
TOOL.CanLinkDarkRPDoors = true
TOOL.CanLinkButtons = true
TOOL.CanLinkFadingDoors = true

TOOL.ClientConVar["map_disable"] = 1
TOOL.ClientConVar["map_hide"] = 1
TOOL.ClientConVar["map_hold"] = 0
TOOL.ClientConVar["map_toggle"] = 0
TOOL.ClientConVar["map_double_toggle"] = 0
TOOL.ClientConVar["map_redirect_use"] = 1
TOOL.ClientConVar["map_nolockpick"] = 0
TOOL.ClientConVar["map_pseudolink"] = 0
TOOL.ClientConVar["map_door_toggle"] = 0
TOOL.ClientConVar["map_door_lock"] = 1

if CLIENT then
	TOOL.Information = nil
	TOOL.Information = {
		{ name = "select", icon = "gui/lmb.png", op = 0 },
		{ name = "switch_keypads", icon = "gui/r.png", op = 0 },

		{ name = "link_map_obj_info", icon = "gui/info", op = 1, stage = 2 },
		{ name = "link_map_obj_info", icon = "gui/info", op = 2, stage = 2 },

		{ name = "on_access_granted", icon = "gui/info", op = 1 },
		{ name = "on_access_denied", icon = "gui/info", op = 2 },

		{ name = "switch_access", icon = "gui/rmb.png", op = 1 },
		{ name = "switch_access", icon = "gui/rmb.png", op = 2 },

		{ name = "link_all", icon = "gui/lmb.png", op = 1, stage = 0 },
		{ name = "link_fading_door", icon = "gui/lmb.png", op = 1, stage = 1 },
		{ name = "link_map_obj", icon = "gui/lmb.png", op = 1, stage = 2 },

		{ name = "link_all", icon = "gui/lmb.png", op = 2, stage = 0 },
		{ name = "link_fading_door", icon = "gui/lmb.png", op = 2, stage = 1 },
		{ name = "link_map_obj", icon = "gui/lmb.png", op = 2, stage = 2 },

		{ name = "unlink_fading_door", icon = "gui/lmb.png", op = 3, stage = 0 },
		{ name = "unlink_map_obj", icon = "gui/lmb.png", op = 3, stage = 1 },
		{ name = "unlink_keypad", icon = "gui/lmb.png", op = 3, stage = 2 },

		{ name = "link_keypad", icon = "gui/lmb.png", op = 4 },

		{ name = "finished", icon = "gui/r.png", op = 1 },
		{ name = "finished", icon = "gui/r.png", op = 2 },
		{ name = "finished", icon = "gui/r.png", op = 3 },
		{ name = "finished", icon = "gui/r.png", op = 4 },
	}
end

function TOOL:LeftClick(tr)
	local L = bKeypads.L

	local FirstTimePredicted = SERVER or IsFirstTimePredicted()

	self:Think()

	local ply = self:GetOwner()
	if not IsValid(ply) then return false end

	local ent = self:GetTraceEnt()
	if bKeypads.Config.LinkingDistance > 0 and IsValid(ent) and not bKeypads.Permissions:Check(ply, "linking/max_distance") and ent:WorldSpaceCenter():DistToSqr(ply:GetPos()) > bKeypads.Config.LinkingDistance then return false end

	local op = self:GetOperation()
	local stage = self:GetStage()

	if op == 0 then

		if IsValid(ent) and ent.bKeypad then
			if FirstTimePredicted then
				self.LinkingKeypad = ent
				self:SetOperation(1)

				if CLIENT then
					bKeypads.ESP:Refresh()
					surface.PlaySound("buttons/button3.wav")
				end
			end

			return true
		end

	elseif op == 1 or op == 2 then

		-- Link
		-- 1 = Access Granted
		-- 2 = Access Denied
		if stage ~= 0 then
			if FirstTimePredicted then
				if not self:PermissionCheck(true) then return false end

				if SERVER then
					if stage == 1 then
						bKeypads.FadingDoors:Link(
							self.LinkingKeypad, self.TargetEnt,
							op == 1,
							ply
						)
					elseif stage == 2 then
						bKeypads.MapLinking:Link(
							self.LinkingKeypad, ent,
							self.AccessMode,
							tobool(self:GetClientNumber("map_pseudolink")),
							tobool(self:GetClientNumber("map_disable")),
							tobool(self:GetClientNumber("map_redirect_use")),
							tobool(self:GetClientNumber("map_hold")),
							tobool(self:GetClientNumber("map_toggle")),
							tobool(self:GetClientNumber("map_double_toggle")),
							tobool(self:GetClientNumber("map_hide")),
							tobool(self:GetClientNumber("map_nolockpick")),
							tobool(self:GetClientNumber("map_door_toggle")),
							tobool(self:GetClientNumber("map_door_lock")),
							ply
						)
					end

					if bKeypads.Persistence:IsPersisting(self.LinkingKeypad) then
						bKeypads.Persistence:CommitKeypad(self.LinkingKeypad)
					end
				end

				if CLIENT then
					notification.AddLegacy(L"LinkedSuccessfully", NOTIFY_GENERIC, 2)
					surface.PlaySound("buttons/button5.wav")
				end
			end

			return true
		end

	elseif op == 3 then

		-- Unlink
		if FirstTimePredicted then
			if not self:PermissionCheck(true) then return false end

			if SERVER then
				if stage == 2 then
					bKeypads.KeypadLinking:Unlink(self.LinkingKeypad, self.TargetEnt, ply)

					if bKeypads.Persistence:IsPersisting(self.TargetEnt) then
						bKeypads.Persistence:CommitKeypad(self.TargetEnt)
					end
				elseif stage == 0 then
					bKeypads.FadingDoors:Unlink(self.LinkingKeypad, self.TargetEnt, ply)
				elseif stage == 1 then
					bKeypads.MapLinking:Unlink(self.LinkingKeypad, self.TargetEnt, ply)
				end

				if bKeypads.Persistence:IsPersisting(self.LinkingKeypad) then
					bKeypads.Persistence:CommitKeypad(self.LinkingKeypad)
				end
			end

			if CLIENT then
				notification.AddLegacy(L"UnlinkedSuccessfully", NOTIFY_UNDO, 2)
				surface.PlaySound("buttons/button6.wav")
			end
		end

		return true

	elseif op == 4 then

		-- Link keypads
		if FirstTimePredicted then
			if not self:PermissionCheck(true) then return false end

			local canLink, source, target = bKeypads.KeypadLinking:TranslatePair(self.LinkingKeypad, self.TargetEnt)
			if not canLink then return false end

			if SERVER then
				bKeypads.KeypadLinking:Link(source, target, ply)

				if bKeypads.Persistence:IsPersisting(self.LinkingKeypad) then
					bKeypads.Persistence:CommitKeypad(self.LinkingKeypad)
				end
				if bKeypads.Persistence:IsPersisting(self.TargetEnt) then
					bKeypads.Persistence:CommitKeypad(self.TargetEnt)
				end
			end

			if CLIENT then
				notification.AddLegacy(L"LinkedSuccessfully", NOTIFY_GENERIC, 2)
				surface.PlaySound("buttons/button5.wav")
			end
		end

		return true

	end

	return false
end

function TOOL:RightClick(tr)
	if SERVER or IsFirstTimePredicted() then
		if self:GetOperation() == 1 then
			self:SetOperation(2)
			self.AccessMode = false
		elseif self:GetOperation() == 2 then
			self:SetOperation(1)
			self.AccessMode = true
		else
			return false
		end

		if CLIENT then
			bKeypads.ESP:Refresh()
			surface.PlaySound("weapons/pistol/pistol_empty.wav")
		end
	end

	return false
end

function TOOL:Reload(tr)
	if self:GetOperation() ~= 0 then
		if SERVER or IsFirstTimePredicted() then
			self:SetStage(0)
			self:SetOperation(0)
			self.LinkingKeypad = nil
			self.TargetEnt = nil
			self.AccessMode = true
			self.SnapToEnt = true
			self.DisableTargetESP = false

			if CLIENT then
				bKeypads.ESP:Refresh()
				surface.PlaySound("buttons/combine_button1.wav")
			end
		end
	elseif CLIENT and IsFirstTimePredicted() then
		RunConsoleCommand("gmod_tool", "bkeypads")
		surface.PlaySound("npc/combine_soldier/gear5.wav")
	end
	return false
end

local ExampleImg, Linker_CPanel = {}
do
	local frameCounts = {}
	local materials = {}
	hook.Add("DrawOverlay", "bKeypads.Linker.DrawOverlay", function()
		if not IsValid(Linker_CPanel) or not Linker_CPanel:IsVisible() or not ExampleImg.m_Material then return end

		local mat = materials[ExampleImg.m_Material]
		if not mat then
			if ExampleImg.m_Material:match("%..-$") then

				if not file.Exists("materials/" .. ExampleImg.m_Material, "GAME") then return end

				materials[ExampleImg.m_Material] = Material(ExampleImg.m_Material, "smooth")

			else

				if not file.Exists("materials/" .. ExampleImg.m_Material .. ".vtf", "GAME") then return end

				materials[ExampleImg.m_Material] = Material(ExampleImg.m_Material)

				local f = file.Open("materials/" .. ExampleImg.m_Material .. ".vtf", "rb", "GAME")
				f:Skip(24)
				frameCounts[ExampleImg.m_Material] = { f:ReadUShort(), f:ReadUShort() }
				f:Close()

			end

			mat = materials[ExampleImg.m_Material]
		end

		if frameCounts[ExampleImg.m_Material] then
			mat:SetInt("$frame", (math.floor(SysTime() - ExampleImg.m_AnimStart) + frameCounts[ExampleImg.m_Material][2]) % frameCounts[ExampleImg.m_Material][1])
		end

		local w, h = mat:Width(), mat:Height()

		local _ScrW, _ScrH = ScrW(), ScrH()
		render.SetViewPort(math.min((Linker_CPanel:LocalToScreen(-w + 10, 0)), ScrW() - w), math.min(gui.MouseY() - (181 / 2), ScrH() - 181), w, 181)
			cam.Start2D()
				surface.SetDrawColor(255, 255, 255)
				surface.SetMaterial(mat)
				surface.DrawTexturedRect((ScrW() - w) / 2, 0, w, h)
			cam.End2D()
		render.SetViewPort(0, 0, _ScrW, _ScrH)
	end)
end

function TOOL.BuildCPanel(CPanel)
	Linker_CPanel = CPanel

	local L = bKeypads.L

	bKeypads:InjectSmoothScroll(CPanel)
	bKeypads:STOOLMatrix(CPanel)

	CPanel.HelpCategory = vgui.Create("DForm", CPanel)
	CPanel.HelpCategory:SetLabel(L"Help")
	CPanel.HelpCategory:SetExpanded(cookie.GetNumber("bkeypads_linking_help_viewed", 0) == 0)
	CPanel.HelpCategory.OnToggle = function(self)
		if not self:GetExpanded() then
			cookie.Set("bkeypads_linking_help_viewed", 1)
		end
	end

		CPanel.HelpCategory:Help(L"LinkerHelp"):DockMargin(0, 0, 0, 0)

		CPanel.Tutorial = vgui.Create("DButton", CPanel)
		CPanel.Tutorial:SetText(L"Tutorial")
		CPanel.Tutorial:SetIcon("icon16/emoticon_grin.png")
		CPanel.Tutorial:SetTall(25)
		CPanel.Tutorial.DoClick = function()
			bKeypads.Tutorial:OpenMenu()
		end

		CPanel.HelpCategory:AddItem(CPanel.Tutorial)

	CPanel:AddItem(CPanel.HelpCategory)

	CPanel.MapLinkingCategory = vgui.Create("DForm", CPanel)
	CPanel.MapLinkingCategory:SetExpanded(false)
	CPanel.MapLinkingCategory:SetLabel(L"MapLinking")

		CPanel.MapLinkingCategory.General = vgui.Create("DForm", CPanel)
		CPanel.MapLinkingCategory.General:SetLabel(L"General")

		CPanel.MapLinkingCategory.Doors = vgui.Create("DForm", CPanel)
		CPanel.MapLinkingCategory.Doors:SetLabel(L"Doors")

		CPanel.MapLinkingCategory.Buttons = vgui.Create("DForm", CPanel)
		CPanel.MapLinkingCategory.Buttons:SetLabel(L"Buttons")

		do
			local PseudoMapLink = CPanel.MapLinkingCategory.General:CheckBox(L"PseudoMapLink", "bkeypads_linker_map_pseudolink")
			PseudoMapLink.ExampleImg = "bkeypads/map_linking/pseudo"
			PseudoMapLink.Tip = CPanel.MapLinkingCategory.General:Help(L"PseudoMapLinkTip")
			bKeypads:AddShieldIcon(PseudoMapLink)

			local DisableMapObj = CPanel.MapLinkingCategory.General:CheckBox(L"DisableMapObj", "bkeypads_linker_map_disable")
			DisableMapObj.ExampleImg = "bkeypads/map_linking/disable.png"
			DisableMapObj.Tip = CPanel.MapLinkingCategory.General:Help(L"DisableMapObjTip")
			bKeypads:AddShieldIcon(DisableMapObj)

			local MapRedirectUse = CPanel.MapLinkingCategory.General:CheckBox(L"MapRedirectUse", "bkeypads_linker_map_redirect_use")
			MapRedirectUse.ExampleImg = "bkeypads/map_linking/redirect_use"
			MapRedirectUse.Tip = CPanel.MapLinkingCategory.General:Help(L"MapRedirectUseTip")
			bKeypads:AddShieldIcon(MapRedirectUse)

			local HideMapObj = CPanel.MapLinkingCategory.Buttons:CheckBox(L"HideMapObj", "bkeypads_linker_map_hide")
			HideMapObj.ExampleImg = "bkeypads/map_linking/hide"
			HideMapObj.Tip = CPanel.MapLinkingCategory.Buttons:Help(L"HideMapObjTip")
			bKeypads:AddShieldIcon(HideMapObj)

			local MapHold = CPanel.MapLinkingCategory.Buttons:CheckBox(L"MapHold", "bkeypads_linker_map_hold")
			MapHold.ExampleImg = "bkeypads/map_linking/hold"
			MapHold.Tip = CPanel.MapLinkingCategory.Buttons:Help(L"MapHoldTip")

			local MapToggle = CPanel.MapLinkingCategory.Buttons:CheckBox(L"MapToggle", "bkeypads_linker_map_toggle")
			MapToggle.ExampleImg = "bkeypads/map_linking/toggle"
			MapToggle.Tip = CPanel.MapLinkingCategory.Buttons:Help(L"MapToggleTip")

			local MapDoubleToggle = CPanel.MapLinkingCategory.Buttons:CheckBox(L"MapDoubleToggle", "bkeypads_linker_map_double_toggle")
			MapDoubleToggle.ExampleImg = "bkeypads/map_linking/double_toggle"
			MapDoubleToggle.Tip = CPanel.MapLinkingCategory.Buttons:Help(L"MapDoubleToggleTip")

			local MapDoorLock = CPanel.MapLinkingCategory.Doors:CheckBox(L"DoorLock", "bkeypads_linker_map_door_lock")
			MapDoorLock.Tip = CPanel.MapLinkingCategory.Doors:Help(L"DoorLockTip")

			local MapDoorToggle = CPanel.MapLinkingCategory.Doors:CheckBox(L"MapToggle", "bkeypads_linker_map_door_toggle")
			MapDoorToggle.Tip = CPanel.MapLinkingCategory.Doors:Help(L"MapDoorToggleTip")

			local MapPreventLockpick = CPanel.MapLinkingCategory.Doors:CheckBox(L"MapPreventLockpick", "bkeypads_linker_map_nolockpick")
			MapPreventLockpick.Tip = CPanel.MapLinkingCategory.Doors:Help(L"MapPreventLockpickTip")
			bKeypads:AddShieldIcon(MapPreventLockpick)

			local checkboxes = { DisableMapObj, HideMapObj, MapRedirectUse, PseudoMapLink, MapHold, MapToggle, MapDoubleToggle, MapPreventLockpick, MapDoorToggle, MapDoorLock }

			local rules = {
				[PseudoMapLink] = { MapHold, MapToggle, MapDoubleToggle, MapDoorToggle },
				[MapHold] = { MapToggle, MapDoubleToggle },
				[MapToggle] = { MapHold, MapDoubleToggle },
				[MapDoubleToggle] = { MapHold, MapToggle },
				[DisableMapObj] = { MapPreventLockpick },
			}
			local permissions = {
				[MapPreventLockpick] = "linking/darkrp_prevent_lockpick",
				[PseudoMapLink] = "linking/pseudolink",
				[DisableMapObj] = "linking/disable_map_objects",
				[MapRedirectUse] = "linking/redirect_use",
				[HideMapObj] = "linking/hide_map_object",
			}

			local function ExampleTipImgHover(self)
				ExampleImg.m_Material = self.ExampleImg
				ExampleImg.m_AnimStart = SysTime()
			end
			local function ExampleTipImgRemove(self)
				ExampleImg.m_Material = nil
			end

			for _, control in ipairs(checkboxes) do
				control.Tip:GetParent():DockMargin(0, 0, 0, 8)
				control.Tip:DockMargin(0, 0, 0, 0)

				control.OnChange = bKeypads.ESP.Refresh

				control.Tip.ExampleImg = control.ExampleImg
				control.Label.ExampleImg = control.ExampleImg
				control.Button.ExampleImg = control.ExampleImg
				control:GetParent().ExampleImg = control.ExampleImg

				control:GetParent().OnCursorEntered = ExampleTipImgHover
				control:GetParent().OnCursorExited = ExampleTipImgRemove

				control.Tip:GetParent().OnCursorEntered = ExampleTipImgHover
				control.Tip:GetParent().OnCursorExited = ExampleTipImgRemove
				control.Tip:GetParent().ExampleImg = control.ExampleImg

				control.Tip.OnCursorEntered = ExampleTipImgHover
				control.Tip.OnCursorExited = ExampleTipImgRemove

				control.OnCursorEntered = ExampleTipImgHover
				control.OnCursorExited = ExampleTipImgRemove

				control.Label.OnCursorEntered = ExampleTipImgHover
				control.Label.OnCursorExited = ExampleTipImgRemove

				control.Button.OnCursorEntered = ExampleTipImgHover
				control.Button.OnCursorExited = ExampleTipImgRemove
			end

			local disabledText = Color(0,0,0,100)
			local enabledText  = Color(0,0,0,255)
			CPanel.bKeypads_Think = CPanel.bKeypads_Think or CPanel.Think
			CPanel.Think = function()
				if CPanel.bKeypads_Think then CPanel:bKeypads_Think() end

				local disabled = {}
				for _, checkbox in ipairs(checkboxes) do
					local permission = permissions[checkbox]
					if permission and not bKeypads.Permissions:Cached(LocalPlayer(), permission) then
						disabled[checkbox] = true
						continue
					end

					local rule = rules[checkbox]
					if checkbox:GetChecked() and rule then
						for _, checkbox in ipairs(rule) do
							disabled[checkbox] = true
						end
						continue
					end
				end
				for _, checkbox in ipairs(checkboxes) do
					local disabled = disabled[checkbox] == true
					checkbox:SetDisabled(disabled)
					checkbox.Tip:SetTextColor(disabled and disabledText or enabledText)
					if disabled and checkbox:GetChecked() then
						checkbox:SetChecked(false)
					end
				end
			end
		end

		CPanel.MapLinkingCategory:AddItem(CPanel.MapLinkingCategory.General)
		CPanel.MapLinkingCategory:AddItem(CPanel.MapLinkingCategory.Doors)
		CPanel.MapLinkingCategory:AddItem(CPanel.MapLinkingCategory.Buttons)

		local padding = vgui.Create("DPanel", CPanel.MapLinkingCategory)
		padding:Dock(TOP)
		padding:SetTall(0)
		padding.Paint = nil
		CPanel.MapLinkingCategory:AddItem(padding)

	CPanel:AddItem(CPanel.MapLinkingCategory)

	hook.Run("bKeypads.BuildCPanel", CPanel)
end

function TOOL:Deploy()
	self:SetStage(0)
	self:SetOperation(0)

	self.LinkingKeypad = nil
	self.TargetEnt = nil
	self.AccessMode = true
	self.SnapToEnt = true
	self.DisableTargetESP = false
end

if CLIENT then
	function TOOL:Deployed()
		self:Deploy()
		bKeypads.ESP:Activate()
	end

	function TOOL:Holstered()
		bKeypads.ESP:Deactivate()
	end
end
bKeypads_Prediction(TOOL)

function TOOL:PermissionCheck(skipCache)
	if skipCache then
		if not bKeypads.Permissions:Check(self:GetOwner(), "create_keypads") then return false end

		if IsValid(self.TargetEnt) then
			if self.FadingDoorLinking then
				return bKeypads.Permissions:Check(self:GetOwner(), "fading_doors/create")
			elseif self.KeypadLinking then
				return self.CanLinkKeypads
			elseif self.MapLinking then
				if bKeypads.MapLinking:IsDoor(self.TargetEnt) then
					if (
						bKeypads.Permissions:Check(self:GetOwner(), "linking/doors") or
						(DarkRP and bKeypads.Permissions:Check(self:GetOwner(), "linking/darkrp_doors") and self.TargetEnt.isKeysOwnedBy and self.TargetEnt:isKeysOwnedBy(self:GetOwner()))
					) then
						return true
					end
					return false
				elseif bKeypads.MapLinking:IsSandboxButton(self.TargetEnt) then
					return bKeypads.Permissions:Check(self:GetOwner(), "linking/gmod_button")
				elseif bKeypads.MapLinking:IsMapButton(self.TargetEnt) then
					return bKeypads.Permissions:Check(self:GetOwner(), "linking/buttons")
				end
			end
		end
	else
		if not self.CanLink then return false end

		if IsValid(self.TargetEnt) then
			if self.FadingDoorLinking then
				return self.CanLinkFadingDoors
			elseif self.KeypadLinking then
				return self.CanLinkKeypads
			elseif self.MapLinking then
				if bKeypads.MapLinking:IsDoor(self.TargetEnt) then
					if (
						self.CanLinkDoors or
						(self.CanLinkDarkRPDoors and self.TargetEnt.isKeysOwnedBy and self.TargetEnt:isKeysOwnedBy(self:GetOwner()))
					) then
						return true
					end
					return false
				elseif bKeypads.MapLinking:IsSandboxButton(self.TargetEnt) then
					return self.CanLinkSandboxButtons
				elseif bKeypads.MapLinking:IsMapButton(self.TargetEnt) then
					return self.CanLinkButtons
				end
			end
		end
	end

	return true
end

local LINKABLE_FADING_DOOR = 0
local LINKABLE_MAP_LINK    = 1
local LINKABLE_KEYPAD      = 2
local function GetLinkableEntType(ent)
	if not IsValid(ent) then return end
	if ent.bKeypad then
		return ent, LINKABLE_KEYPAD
	elseif bKeypads.FadingDoors:IsFadingDoor(ent) then
		return ent, LINKABLE_FADING_DOOR
	elseif bKeypads.MapLinking:IsLinkEntity(ent) then
		return ent, LINKABLE_MAP_LINK
	end
end

if SERVER then
	util.AddNetworkString("bKeypads.Linker.TraceEnt")
else
	net.Receive("bKeypads.Linker.TraceEnt", function()
		local tool = LocalPlayer():GetTool("bkeypads_linker")
		if tool then
			tool.m_eServerTraceEnt = net.ReadBool() and net.ReadEntity() or NULL
		end
	end)
end
function TOOL:ResolveTraceEnt()
	local ply = self:GetOwner()
	local tr = ply:GetEyeTrace()

	if SERVER then
		local linkEnt = (IsValid(tr.Entity) and tr.Entity) or (self.m_iFindUseEntityTick ~= nil and self.m_iFindUseEntityTick == engine.TickCount() and IsValid(self.m_eFindUseEntity) and self.m_eFindUseEntity) or (IsValid(ply:GetUseEntity()) and ply:GetUseEntity()) or nil
		if self.m_eServerTraceEnt ~= linkEnt then
			net.Start("bKeypads.Linker.TraceEnt")
				if IsValid(linkEnt) then
					self.m_eServerTraceEnt = linkEnt
					net.WriteBool(true)
					net.WriteEntity(linkEnt)
				else
					self.m_eServerTraceEnt = nil
					net.WriteBool(false)
					net.WriteEntity(linkEnt)
				end
			net.Send(ply)
		end
	elseif IsValid(tr.Entity) then
		return tr.Entity
	end

	return self.m_eServerTraceEnt
end
function TOOL:GetTraceEnt()
	return GetLinkableEntType(self:ResolveTraceEnt())
end

function TOOL:Think()
	self.CanLink = bKeypads.Permissions:Cached(self:GetOwner(), "create_keypads")
	if self.CanLink then
		self.CanLinkDoors = bKeypads.Permissions:Cached(self:GetOwner(), "linking/doors")
		self.CanLinkDarkRPDoors = DarkRP and bKeypads.Permissions:Cached(self:GetOwner(), "linking/darkrp_doors")
		self.CanLinkButtons = bKeypads.Permissions:Cached(self:GetOwner(), "linking/buttons")
		self.CanLinkSandboxButtons = bKeypads.Permissions:Cached(self:GetOwner(), "linking/gmod_button")
		self.CanLinkFadingDoors = bKeypads.Permissions:Cached(self:GetOwner(), "fading_doors/create")
		self.CanLinkKeypads = bKeypads.Permissions:Cached(self:GetOwner(), "linking/link_keypads")
		self.CanLink = self.CanLinkDoors or self.CanLinkDarkRPDoors or self.CanLinkButtons or self.CanLinkFadingDoors or self.CanLinkSandboxButtons
	end

	if
		self.LinkingKeypad ~= nil and (not IsValid(self.LinkingKeypad) or (bKeypads.Config.LinkingDistance > 0 and not bKeypads.Permissions:Cached(self:GetOwner(), "linking/max_distance") and self.LinkingKeypad:WorldSpaceCenter():DistToSqr(self:GetOwner():GetPos()) > bKeypads.Config.LinkingDistance)) or
		self.TargetEnt ~= nil and (not IsValid(self.TargetEnt) or (bKeypads.Config.LinkingDistance > 0 and not bKeypads.Permissions:Cached(self:GetOwner(), "linking/max_distance") and self.TargetEnt:WorldSpaceCenter():DistToSqr(self:GetOwner():GetPos()) > bKeypads.Config.LinkingDistance))
	then
		self.LinkingKeypad = nil
		self:SetOperation(0)
		self:SetStage(0)
		self.TargetEnt = nil
		self.SnapToEnt = true
		self.DisableTargetESP = false
		self.MapLinking = false
		self.FadingDoorLinking = false
		self.KeypadLinking = false
	end

	local op = self:GetOperation()
	if op == 1 or op == 2 or op == 3 or op == 4 then
		local ent, entType = self:GetTraceEnt()
		if ent and ent ~= self.LinkingKeypad then
			if entType == LINKABLE_FADING_DOOR then
				if bKeypads.FadingDoors:IsLinked(ent, self.LinkingKeypad) then
					self:SetOperation(3)
					self:SetStage(0)
					self.TargetEnt = ent
					self.SnapToEnt = true
					self.DisableTargetESP = true
				else
					self:SetOperation(self.AccessMode and 1 or 2)
					self:SetStage(1)
					self.TargetEnt = ent
					self.SnapToEnt = false
					self.DisableTargetESP = false
				end
				self.MapLinking = false
				self.FadingDoorLinking = true
				self.KeypadLinking = false
				return
			elseif not bKeypads.Config.KeypadOnlyFadingDoors or bKeypads.Permissions:Cached(self:GetOwner(), "keypads/bypass_keypad_only_fading_doors") then
				if entType == LINKABLE_MAP_LINK then
					local unlink = bKeypads.MapLinking:IsLinked(self.LinkingKeypad, ent)
					self:SetOperation(unlink and 3 or (self.AccessMode and 1 or 2))
					self:SetStage(unlink and 1 or 2)
					self.TargetEnt = ent
					self.SnapToEnt = true
					self.DisableTargetESP = unlink
					self.MapLinking = true
					self.FadingDoorLinking = false
					self.KeypadLinking = false
					return
				elseif entType == LINKABLE_KEYPAD then
					local canLink = bKeypads.KeypadLinking:TranslatePair(self.LinkingKeypad, ent)
					if canLink then
						local unlink = self.LinkingKeypad:LinkProxy() == ent:LinkProxy()
						self:SetOperation(unlink and 3 or 4)
						self:SetStage(unlink and 2 or 0)
						self.TargetEnt = ent
						self.SnapToEnt = true
						self.DisableTargetESP = false
						self.MapLinking = false
						self.FadingDoorLinking = false
						self.KeypadLinking = true
						return
					end
				end
			end
		end

		self:SetOperation(self.AccessMode and 1 or 2)
		self:SetStage(0)
		self.TargetEnt = nil
		self.SnapToEnt = true
		self.DisableTargetESP = false
		self.MapLinking = false
		self.FadingDoorLinking = false
		self.KeypadLinking = false
	end
end

if CLIENT then
	local matKeypadLinker = Material("bkeypads/linker")
	function TOOL:DrawToolScreen(w,h)
		surface.SetDrawColor(0,150,255)
		surface.DrawRect(0,0,w,h)

		if not self.Matrix then
			self.Matrix = bKeypads_Matrix("STOOL_Screen", w, h)
		end
		self.Matrix:Draw(w,h)

		surface.SetMaterial(matKeypadLinker)
		surface.DrawTexturedRect(0, 0, w, h)

		if self.CanLinkDoors == false and self.CanLinkFadingDoors == false and self.CanLinkButtons == false and self.CanLinkDarkRPDoors == false then
			bKeypads:ToolScreenNoPermission(w,h)
		elseif IsValid(self.TargetEnt) and not self:PermissionCheck() then
			bKeypads:ToolScreenNoPermissionEnt(w,h)
		end
	end

	local matLink = Material("bkeypads/link.png", "noclamp smooth")
	local matUnlink = Material("bkeypads/unlink.png", "noclamp smooth")
	function TOOL:DrawHUD()
		local op, stage, mapLinks = self:GetOperation(), self:GetStage()
		if (op == 4 or op == 3 or ((op == 1 or op == 2) and stage > 0)) then
			local L = bKeypads.L

			local y = (ScrH() / 2) + 20

			local colorFlash = math.Remap(math.cos(SysTime() * math.pi), -1, 1, 0, 1) * 255

			if op == 3 then
				surface.SetTextColor(255, colorFlash, colorFlash)
				surface.SetDrawColor(255, colorFlash, colorFlash)
			else
				surface.SetDrawColor(colorFlash, 255, colorFlash)
				surface.SetTextColor(colorFlash, 255, colorFlash)
			end
			bKeypads:DrawSubpixelClippedMaterial(
				op == 3 and matUnlink or matLink,
				(ScrW() - 24) / 2, y, 24, 24
			)

			y = y + 24

			surface.SetFont("BudgetLabel")

			local txt =
				(
					op == 4 and L"LinkTypeKeypad"
				) or
				(
					(op == 1 or op == 2) and
					(
						(stage == 1 and L"LinkTypeFadingDoor") or
						(
							stage == 2 and IsValid(self.TargetEnt) and (
								(bKeypads.MapLinking:IsDoor(self.TargetEnt) and L"LinkTypeDoor") or
								(bKeypads.MapLinking:IsButton(self.TargetEnt) and L"LinkTypeButton") or
								L"LinkTypeMap"
							)
						)
					)
				) or
				(
					op == 3 and (
						(stage == 0 and L"LinkTypeFadingDoor") or
						(
							stage == 1 and IsValid(self.TargetEnt) and (
								(bKeypads.MapLinking:IsDoor(self.TargetEnt) and L"LinkTypeDoor") or
								(bKeypads.MapLinking:IsButton(self.TargetEnt) and L"LinkTypeButton")
								or L"LinkTypeMap"
							)
						)
					) or
					(stage == 2 and L"LinkTypeKeypad")
				)
			if txt then
				local w, h = surface.GetTextSize(txt)
				y = y + 10
				surface.SetTextPos((ScrW() - w) / 2, y)
				surface.DrawText(txt)
				y = y + h
			end

			local accessType
			if op == 1 or op == 2 then
				accessType = op == 1
			elseif op == 3 and IsValid(self.TargetEnt) then
				if stage ~= 0 then mapLinks = mapLinks or bKeypads.MapLinking:GetLinks(self.LinkingKeypad) end
				local links = stage == 0 and bKeypads.FadingDoors:GetLinks(self.LinkingKeypad) or mapLinks
				if links and links[self.TargetEnt] then
					local link = select(2, next(links[self.TargetEnt]))
					if IsValid(link) then
						accessType = link:GetAccessType()
					end
				end
			end
			if accessType ~= nil then
				if accessType then
					surface.SetTextColor(colorFlash, 255, colorFlash)
				else
					surface.SetTextColor(255, colorFlash, colorFlash)
				end
				local txt = accessType and L"AccessGranted" or L"AccessDenied"
				local w, h = surface.GetTextSize(txt)
				surface.SetTextPos((ScrW() - w) / 2, y)
				surface.DrawText(txt)
				y = y + h
			end

			if self.MapLinking then
				local pseudolink = false

				if op == 1 or op == 2 then
					pseudolink = self:GetClientNumber("map_pseudolink") == 1
				else
					mapLinks = mapLinks or bKeypads.MapLinking:GetLinks(self.LinkingKeypad)
					if mapLinks and mapLinks[self.TargetEnt] then
						local link = select(2, next(mapLinks[self.TargetEnt]))
						if IsValid(link) and link:HasGeneralFlag(bKeypads.MapLinking.F_PSEUDOLINK) then
							pseudolink = true
						end
					end
				end

				if pseudolink then
					local txt = L"PseudoMapLink"
					local w = surface.GetTextSize(txt)
					surface.SetTextColor(255, 0, 255)
					surface.SetTextPos((ScrW() - w) / 2, y)
					surface.DrawText(txt)
				end
			end
		end
	end

	local matUnlinkBox = Material("bkeypads/diagonal")
	local matUnlinkBoxColor = Color(255, 255, 255)
	hook.Add("PreDrawTranslucentRenderables", "bKeypads.Linker.DrawUnlinkBox", function(_, skybox)
		if skybox then return end
		if bKeypads.Performance:Optimizing() then return end

		local tool = LocalPlayer():GetTool()
		if tool and tool.Mode == "bkeypads_linker" and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_tool" and tool:GetOperation() == 3 and IsValid(tool.TargetEnt) then

			bKeypads.cam.IgnoreZ(true)

				local alpha = math.Remap(math.sin(SysTime() * 5), -1, 1, 0, .25)
				render.SetBlend(alpha)

				render.ModelMaterialOverride(matUnlinkBox)

					if tool:GetStage() == 2 then
						local source, target = select(2, bKeypads.KeypadLinking:TranslatePair(tool.LinkingKeypad, tool.TargetEnt))

						source.m_ForceSupressEngineLighting = true
						target.m_ForceSupressEngineLighting = true

							target:SetupBones()
							target:DrawModel()

							source:SetupBones()
							source:DrawModel()

						source.m_ForceSupressEngineLighting = false
						target.m_ForceSupressEngineLighting = false
					else
						tool.TargetEnt.m_ForceSupressEngineLighting = true
						tool.LinkingKeypad.m_ForceSupressEngineLighting = true

							if bKeypads.FadingDoors:IsFadingDoor(tool.TargetEnt) then
								tool.TargetEnt:SetupBones()
								tool.TargetEnt:DrawModel()
							else
								matUnlinkBoxColor.a = 255 * alpha
								render.SetMaterial(matUnlinkBox)
								render.DrawBox(tool.TargetEnt:GetPos(), tool.TargetEnt:GetAngles(), tool.TargetEnt:OBBMins(), tool.TargetEnt:OBBMaxs(), matUnlinkBoxColor, true)
							end

							tool.LinkingKeypad:SetupBones()
							tool.LinkingKeypad:DrawModel()

						tool.TargetEnt.m_ForceSupressEngineLighting = false
						tool.LinkingKeypad.m_ForceSupressEngineLighting = false
					end

				render.ModelMaterialOverride(nil)

			bKeypads.cam.IgnoreZ(false)

		end
	end)
end

-- Small hack to allow client to modify operation and stage
function TOOL:SetOperation(i)
	if CLIENT then
		self.m_Operation = i
	end
	self:GetWeapon():SetNWInt("Op", i, true)
end
function TOOL:GetOperation()
	if CLIENT and self.m_Operation then
		return self.m_Operation
	end
	return self:GetWeapon():GetNWInt("Op", 0)
end
function TOOL:SetStage(i)
	if CLIENT then
		self.m_Stage = i
	end
	self:GetWeapon():SetNWInt("Stage", i, true)
end
function TOOL:GetStage()
	if CLIENT and self.m_Stage then
		return self.m_Stage
	end
	return self:GetWeapon():GetNWInt("Stage", 0)
end