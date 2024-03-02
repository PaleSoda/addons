TOOL.Category = "Billy's Keypads"
TOOL.Name = "#tool.bkeypads_persistence.name"
TOOL.AddToMenu = false

if CLIENT then
	TOOL.Information = nil
	TOOL.Information = {
		{ name = "make_persistent", icon = "gui/lmb.png", op = 0 },
		{ name = "delete", icon = "gui/rmb.png", op = 0 },
		{ name = "update", icon = "gui/r.png", op = 0 }
	}
end

local function NoneProfileActive()
	if CLIENT then
		return bKeypads.PersistenceProfile == "none"
	else
		return bKeypads.Persistence.Profile == "none"
	end
end

function TOOL:LeftClick(tr)
	if NoneProfileActive() then
		if CLIENT and IsFirstTimePredicted() then
			notification.AddLegacy(bKeypads.L"NoneProfileError", NOTIFY_ERROR, 2)
			surface.PlaySound("buttons/button8.wav")
		end
		return
	end
	if not IsValid(self:GetOwner()) or not bKeypads.Permissions:Check(self:GetOwner(), "persistence/manage_persistent_keypads") then return false end

	if IsValid(tr.Entity) and tr.Entity.bKeypad and not tr.Entity:GetPersist() then
		if SERVER then
			bKeypads.Persistence:SaveKeypad(tr.Entity)
		elseif IsFirstTimePredicted() then
			notification.AddLegacy(bKeypads.L("tool.bkeypads_persistence.notification.created"):format(bKeypads.PersistenceProfile or "UNKNOWN"), NOTIFY_GENERIC, 2)
		end
		return true
	end

	return false
end

function TOOL:RightClick(tr)
	if not IsValid(self:GetOwner()) or not bKeypads.Permissions:Check(self:GetOwner(), "persistence/manage_persistent_keypads") then return false end

	if IsValid(tr.Entity) then
		if tr.Entity.bKeypad and tr.Entity:GetPersist() then
			if NoneProfileActive() then return end
			if SERVER then
				local fx = EffectData()
					fx:SetOrigin(tr.Entity:GetPos())
					fx:SetEntity(tr.Entity)
				util.Effect("entity_remove", fx, true, true)

				bKeypads.Persistence:ForgetKeypad(tr.Entity)
			elseif IsFirstTimePredicted() then
				notification.AddLegacy(bKeypads.L("tool.bkeypads_persistence.notification.deleted"):format(bKeypads.PersistenceProfile or "UNKNOWN"), NOTIFY_GENERIC, 2)
			end
			return true
		elseif tr.Entity.bKeycard and tr.Entity:GetPersist() then
			if SERVER then
				local fx = EffectData()
					fx:SetOrigin(tr.Entity:GetPos())
					fx:SetEntity(tr.Entity)
				util.Effect("entity_remove", fx, true, true)

				tr.Entity:Remove()
			end
			return true
		end
	end

	return false
end

function TOOL:Reload(tr)
	if NoneProfileActive() then return end
	if not IsValid(self:GetOwner()) or not bKeypads.Permissions:Check(self:GetOwner(), "persistence/manage_persistent_keypads") then return false end

	if IsValid(tr.Entity) and tr.Entity.bKeypad and tr.Entity:GetPersist() then
		if SERVER then
			bKeypads.Persistence:CommitKeypad(tr.Entity)
			bKeypads.Persistence:WriteToFile()
		elseif IsFirstTimePredicted() then
			notification.AddLegacy(bKeypads.L("tool.bkeypads_persistence.notification.updated"):format(bKeypads.PersistenceProfile or "UNKNOWN"), NOTIFY_GENERIC, 2)
		end
		return true
	end

	return false
end

function TOOL:Deploy()
	if CLIENT and not self.m_Deployed then
		net.Start("bKeypads.Persistence.FetchProfiles")
			net.WriteBool(false)
		net.SendToServer()
	end

	self.m_Deployed = true
	if CLIENT then bKeypads.ESP:Activate() end

	self:SetStage(0)
	self:SetOperation(0)
end

function TOOL:Holster()
	self.m_Deployed = nil
	if CLIENT then bKeypads.ESP:Deactivate() end

	self:SetStage(0)
	self:SetOperation(0)
end

if CLIENT then
	function TOOL:Think()
		if not self.m_Deployed then
			self:Deploy()
		end
	end

	local matPadlockPNG = Material("bkeypads/padlock.png", "smooth")
	local matPadlock

	function TOOL:DrawToolScreen(w,h)
		if not matPadlock then
			matPadlock = CreateMaterial("bkeypads_persistence", "UnlitGeneric", {
				["$ignorez"] = 1,
				["$vertexalpha"] = 1,
				["$vertexcolor"] = 1,
				["$translucent"] = 1
			})
			matPadlock:SetTexture("$basetexture", matPadlockPNG:GetTexture("$basetexture"))
			matPadlock:Recompute()
		end

		surface.SetDrawColor(bKeypads.COLOR.GMODBLUE)
		surface.DrawRect(0,0,w,h)

		if not self.Matrix then
			self.Matrix = bKeypads_Matrix("STOOL_Screen", w, h)
		end
		self.Matrix:Draw(w,h)

		surface.SetDrawColor(bKeypads.COLOR.SLATE)
		surface.SetMaterial(matPadlock)
		surface.DrawTexturedRect((w - (w * .6)) / 2, (h - (h * .6)) / 2, w * .6, h * .6)

		if not bKeypads.Permissions:Cached(LocalPlayer(), "persistence/manage_persistent_keypads") then
			bKeypads:ToolScreenNoPermission(w, h)
		elseif NoneProfileActive() then
			bKeypads:ToolScreenWarning(bKeypads.L"NoneProfileToolscreen", w, h)
		end
	end

	do
		local function DrawLine(y, line)
			local w,h = surface.GetTextSize(line)
			y = y + h + 5

			surface.SetTextPos((ScrW() - w) / 2, y)
			surface.DrawText(line)

			return y
		end
		function TOOL:DrawHUD()
			if
				not bKeypads.Permissions:Cached(LocalPlayer(), "persistence/manage_persistent_keypads") and
				not bKeypads.Permissions:Cached(LocalPlayer(), "persistence/switch_profile") and
				not bKeypads.Permissions:Cached(LocalPlayer(), "persistence/manage_profiles")
			then return end

			surface.SetFont("BudgetLabel")
			surface.SetTextColor(bKeypads.COLOR.GMODBLUE)

			local y = ScrH() / 2

			local tr = LocalPlayer():GetEyeTrace()
			if IsValid(tr.Entity) and tr.Entity.bKeypad then
				y = DrawLine(y, tr.Entity:GetKeypadName() == "" and bKeypads.L"Unnamed" or tr.Entity:GetKeypadName())
				if tr.Entity:GetPersist() then
					y = DrawLine(y, bKeypads.L"Persistent")
				else
					y = DrawLine(y, bKeypads.L"NotPersistent")
				end
			end

			if not NoneProfileActive() then
				if bKeypads.PersistenceProfileLastSaved then
					y = DrawLine(y, bKeypads.L("LastSaved"):format(bKeypads:FormatTimeDelta(os.time(), bKeypads.PersistenceProfileLastSaved)))
				end
				y = DrawLine(y, game.GetMap() .. "/profiles/" .. (bKeypads.PersistenceProfile or "UNKNOWN") .. ".json")
			end
		end
	end

	local matCheck = Material("icon16/accept.png")
	local function ProfilesPaintSelected(self)
		if not bKeypads.PersistenceProfile then return end
		for _, line in ipairs(self:GetLines()) do
			local profile = line:GetColumnText(2)
			if profile == bKeypads.PersistenceProfile then
				local x, y = self:ScreenToLocal(line:LocalToScreen(0, 0))
				surface.SetMaterial(matCheck)
				surface.DrawTexturedRect(x, y, 16, 16)
				break
			end
		end
	end

	function TOOL.BuildCPanel(CPanel)
		local L = bKeypads._L

		bKeypads:InjectSmoothScroll(CPanel)
		bKeypads:STOOLMatrix(CPanel)

		local Help = vgui.Create("DForm", CPanel)
			Help:SetExpanded(true)
			Help:SetLabel(L"Help")
			Help:Help(L"PersistenceHelp"):DockMargin(0, 0, 0, 0)
		CPanel:AddItem(Help)

		local Profiles
		local Profile = vgui.Create("DForm", CPanel)
			Profile:SetExpanded(true)
			Profile:SetLabel(L"Profile")

				local Save = vgui.Create("DButton", BtnContainer)
				Save:SetIcon("icon16/disk.png")
				Save:SetText(L"SavePersistentKeypads")
				Save.DoClick = function()
					if not bKeypads.Permissions:Check(LocalPlayer(), "persistence/manage_persistent_keypads") then return end

					surface.PlaySound("garrysmod/content_downloaded.wav")

					bKeypads.PersistenceProfileLastSaved = os.time()

					for i, line in ipairs(Profiles:GetLines()) do
						if line:GetColumnText(2) == bKeypads.PersistenceProfile then
							line:SetColumnText(3, os.date("%c"))
							break
						end
					end

					net.Start("bKeypads.Persistence.SaveProfile")
					net.SendToServer()
				end

			Profile:AddItem(Save)

				Profiles = vgui.Create("DListView", Profile)
				Profiles:SetTall(300)
				local checkedColumn = Profiles:AddColumn("") checkedColumn:SetMinWidth(16) checkedColumn:SetMaxWidth(16)
				Profiles:AddColumn(L"Profile")
				Profiles:AddColumn(L"LastUpdated")
				Profiles:SetMultiSelect(false)
				Profiles:SelectItem(Profiles:AddLine("", "default"))
				Profiles:AddLine("", "none")
				Profiles.PaintOver = ProfilesPaintSelected

			Profile:AddItem(Profiles)

				local BtnContainer = vgui.Create("DPanel", Profile)
				BtnContainer.Paint = nil

				local Switch = vgui.Create("DButton", BtnContainer)
				Switch:Dock(LEFT)
				Switch:DockMargin(0, 0, 10, 0)
				Switch:SetIcon("icon16/arrow_refresh.png")
				Switch:SetText(L"Switch")
				Switch:SetDisabled(true)
				Switch.DoClick = function()
					if not bKeypads.Permissions:Check(LocalPlayer(), "persistence/switch_profile") then return end

					surface.PlaySound("garrysmod/save_load" .. math.random(1,4) .. ".wav")

					net.Start("bKeypads.Persistence.SwitchProfile")
						net.WriteString(Profiles:GetLine(Profiles:GetSelectedLine()):GetColumnText(2))
					net.SendToServer()
				end

				local Delete = vgui.Create("DButton", BtnContainer)
				Delete:Dock(LEFT)
				Delete:SetIcon("icon16/delete.png")
				Delete:SetText(L"Delete")
				Delete:SetDisabled(true)
				Delete.DoClick = function()
					if not bKeypads.Permissions:Check(LocalPlayer(), "persistence/manage_profiles") then return end

					surface.PlaySound("friends/friend_join.wav")

					local profile = Profiles:GetLine(Profiles:GetSelectedLine()):GetColumnText(2)

					if profile ~= "default" then
						Profiles:RemoveLine(Profiles:GetSelectedLine())
					else
						Profiles:GetLine(1):SetColumnText(3, "")
					end

					if profile == bKeypads.PersistenceProfile then
						Profiles:SetSelected(Profiles:GetLine(1))
					end

					net.Start("bKeypads.Persistence.DeleteProfile")
						net.WriteString(profile)
					net.SendToServer()
				end

				BtnContainer.PerformLayout = function(self, w)
					local btn_w = (w - 10) / 2
					Switch:SetWide(btn_w)
					Delete:SetWide(btn_w)
				end

			Profile:AddItem(BtnContainer)
			BtnContainer:SetTall(25)

		CPanel:AddItem(Profile)

		CPanel._Think = CPanel.Think
		CPanel.Think = function(self)
			CPanel._Think(self)

			Save:SetDisabled(not bKeypads.Permissions:Cached(LocalPlayer(), "persistence/manage_persistent_keypads") or bKeypads.PersistenceProfile == "none")
			Delete:SetDisabled(not bKeypads.Permissions:Cached(LocalPlayer(), "persistence/manage_profiles") or Profiles:GetSelectedLine() == 2)
			Switch:SetDisabled(not bKeypads.Permissions:Cached(LocalPlayer(), "persistence/switch_profile"))
		end

		hook.Add("bKeypads.Persistence.ProfileSwitched", "bKeypads.Persistence.CPanel", function(profile, time)
			local found = false
			local lines = Profiles:GetLines()
			for i, line in ipairs(lines) do
				if line:GetColumnText(2) == profile then
					found = true

					Profiles:SelectItem(line)
					if time then line:SetColumnText(3, os.date("%c", time)) end

					break
				end
			end

			if not found then
				Profiles:SelectItem(Profiles:AddLine("", profile, time and os.date("%c", time) or nil))
			end
		end)

		net.Receive("bKeypads.Persistence.DeleteProfile", function()
			if not IsValid(Profiles) then return end

			local profile = net.ReadString()
			if profile == "default" then
				Profiles:GetLine(1):SetColumnText(3, "")
				return
			end

			local lines = Profiles:GetLines()
			for i = 3, #lines, 1 do
				if lines[i]:GetColumnText(2) == profile then
					if Profiles:GetSelectedLine() == i then
						Profiles:SelectItem(Profiles:GetLine(1))
					end
					Profiles:RemoveLine(i)
					break
				end
			end
		end)

		net.Receive("bKeypads.Persistence.FetchProfiles", function()
			bKeypads.PersistenceProfile = net.ReadString()
			if net.ReadBool() then
				bKeypads.PersistenceProfileLastSaved = net.ReadUInt(32)
			end

			while net.ReadBool() do
				local profile = net.ReadString()
				if profile == "default" then
					Profiles:GetLine(1):SetColumnText(3, os.date("%c", net.ReadUInt(32)))
					Profiles:SelectItem(Profiles:GetLine(1))
				else
					local line = Profiles:AddLine("", profile, os.date("%c", net.ReadUInt(32)))
					if profile == bKeypads.PersistenceProfile then
						Profiles:SelectItem(line)
					end
				end
			end
		end)

		net.Start("bKeypads.Persistence.FetchProfiles")
			net.WriteBool(true)
		net.SendToServer()

		hook.Run("bKeypads.BuildCPanel", CPanel)
	end
	bKeypads_Persistence_BuildCPanel = TOOL.BuildCPanel

	net.Receive("bKeypads.Persistence.FetchProfiles", function()
		bKeypads.PersistenceProfile = net.ReadString()
		if net.ReadBool() then
			bKeypads.PersistenceProfileLastSaved = net.ReadUInt(32)
		end
	end)

	net.Receive("bKeypads.Persistence.SwitchProfile", function()
		local profile = net.ReadString()

		bKeypads.PersistenceProfile = profile

		local time
		if profile ~= "none" then
			time = net.ReadUInt(32)
			if time == 0 then time = nil end
		end
		hook.Run("bKeypads.Persistence.ProfileSwitched", profile, time)
		bKeypads.PersistenceProfileLastSaved = time
	end)

	hook.Add("bKeypads.Persistence.ProfileSwitched", "bKeypads.Persistence.ProfileSwitched.ChatMsg", function(profile)
		if (
			bKeypads.Permissions:Check(LocalPlayer(), "persistence/manage_persistent_keypads") or
			bKeypads.Permissions:Check(LocalPlayer(), "persistence/switch_profile") or
			bKeypads.Permissions:Check(LocalPlayer(), "persistence/manage_profiles")
		) then
			bKeypads:chat(bKeypads.L("ProfileSwitchedChat"):format(profile), bKeypads.PRINT_TYPE_SPECIAL, "PERSISTENCE")
		end
	end)
end

do
	if SERVER then
		util.AddNetworkString("bKeypads.PermaProps.No")
	else
		net.Receive("bKeypads.PermaProps.No", function()
			surface.PlaySound("common/warning.wav")
			Derma_Message(bKeypads.L"PermaProps_AlreadySaved", "Billy's Keypads", bKeypads.L"Dismiss")
		end)
	end

	local function Switch()
		surface.PlaySound("npc/combine_soldier/gear5.wav")
		RunConsoleCommand("gmod_tool", "bkeypads_persistence")
	end
	hook.Add("CanTool", "bKeypads.CanTool.Persistence", function(ply, tr, tool)
		if tool == "bkeypads_persistence" then
			return bKeypads.Permissions:Check(ply, "persistence/manage_persistent_keypads")
		elseif tool == "permaprops" then
			if IsValid(tr.Entity) then
				if tr.Entity.bKeypad or bKeypads.FadingDoors:IsFadingDoor(tr.Entity) then
					if CLIENT and IsFirstTimePredicted() and ply == LocalPlayer() then
						surface.PlaySound("common/warning.wav")
						Derma_Query(bKeypads.L"PermaProps", "Billy's Keypads", bKeypads.L"Switch", Switch, bKeypads.L"Nevermind")
					end
					return false
				elseif SERVER and bKeypads_Persistence_SaveEntities[tr.Entity] then
					net.Start("bKeypads.PermaProps.No")
					net.Send(ply)
					return false
				end
			end
		end
	end)
end

hook.Add("CanProperty", "bKeypads.Persistentence.BlockSandbox", function(ply, prop, ent)
	if ent.bKeypad and (prop == "persist" or prop == "persist_end") then
		return false
	end
end)

do
	local persistence = bKeypads.ContextMenu:AddMember("#bKeypads_Persistence", "icon16/disk.png", function(self, ent, ply)
		if not IsValid(ent) or not ent.bKeypad then return false end

		local tr = util.TraceLine(util.GetPlayerTrace(ply))
		tr.Entity = ent
		if not gamemode.Call("CanTool", ply, tr, "bkeypads_persistence") then return false end

		return true
	end)

	local function PersistentKeypadOnly(self, ent, ply)
		return ent:GetPersist() == true
	end

	local function NonPersistentKeypadOnly(self, ent, ply)
		return ent:GetPersist() == false
	end

	persistence:AddMember("#tool.bkeypads_persistence.update", "icon16/arrow_refresh.png", PersistentKeypadOnly, function(self, ent, ply)
		if CLIENT then
			self:Network() self:Network()

			notification.AddLegacy(bKeypads.L("tool.bkeypads_persistence.notification.updated"):format(bKeypads.PersistenceProfile or "UNKNOWN"), NOTIFY_GENERIC, 2)
			surface.PlaySound("garrysmod/ui_click.wav")
		else
			bKeypads.Persistence:CommitKeypad(ent)
			bKeypads.Persistence:WriteToFile()
		end
	end, true)

	persistence:AddMember("#stoppersisting", "icon16/lock_delete.png", PersistentKeypadOnly, function(self, ent, ply)
		if CLIENT then
			self:Network() self:Network()

			notification.AddLegacy(bKeypads.L("tool.bkeypads_persistence.notification.deleted"):format(bKeypads.PersistenceProfile or "UNKNOWN"), NOTIFY_ERROR, 2)
			surface.PlaySound("friends/friend_join.wav")
		else
			bKeypads.Persistence:ForgetKeypad(ent)
		end
	end, true)

	persistence:AddMember("#makepersistent", "icon16/lock_add.png", NonPersistentKeypadOnly, function(self, ent, ply)
		if CLIENT then
			self:Network() self:Network()

			notification.AddLegacy(bKeypads.L("tool.bkeypads_persistence.notification.created"):format(bKeypads.PersistenceProfile or "UNKNOWN"), NOTIFY_GENERIC, 2)
			surface.PlaySound("garrysmod/ui_click.wav")
		else
			bKeypads.Persistence:SaveKeypad(ent)
		end
	end, true)
end