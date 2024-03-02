include("shared.lua")

function ENT:StopDrawing()
	if self.m_bDrawing ~= false then
		self.m_bDrawing = false

		self:DrawShadow(false)
		self:DestroyShadow()
	end
end

local GhostColor = Color(255,255,255,150)
function ENT:StartDrawing(ghost)
	if self.m_bDrawing ~= true then
		self.m_bDrawing = true

		self:DrawShadow(true)
		self:CreateShadow()
		self:MarkShadowAsDirty()

		self.m_bDrawGhost = nil
	end

	if ghost ~= nil and self.m_bDrawGhost ~= ghost then
		self:SetRenderMode(RENDERMODE_TRANSCOLOR)
		self:SetColor(ghost and GhostColor or color_white)
	end

	self:DrawModel()
	bKeypads.Keycards.Textures:Draw(bKeypads.Keycards.Textures.BOTH, self, self)
end

function ENT:Draw()
	if (not self:GetInfinite() and self:GetQuantity() == 0) or (self:GetHideToHolders() and bKeypads.Keycards.Inventory:IsHoldingKeycard(LocalPlayer(), self:GetID())) then
		if not self:GetPersist() then
			self:StopDrawing()
		else
			local wep = LocalPlayer():GetActiveWeapon()
			if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" or LocalPlayer():GetTool().Mode ~= "bkeypads_persistence" or not bKeypads.Permissions:Cached(LocalPlayer(), "persistence/manage_persistent_keypads") then
				self:StopDrawing()
			else
				self:StartDrawing(true)
			end
		end
	else
		self:StartDrawing(false)
	end
end

function ENT:DrawTranslucent(flags)
	self:Draw(flags)
end

local function LevelPaint(self, w, h)
	surface.SetDrawColor(self.LevelColor)
	local x = self.CheckBox:GetWide() + 5
	surface.DrawRect(x, 0, w - x, h)
end

local function CategoryBackgroundPaint(self, w, h)
	DPanel.Paint(self, w, h)
	DCollapsibleCategory.Paint(self, w, h)
end
local function CategoryBackground(self)
	self.m_bBackground = true
	self.Paint = CategoryBackgroundPaint
	return self
end

local function LevelMousePressed(self, m)
	if m == MOUSE_LEFT then self._m = true end
end
local function LevelMouseReleased(self, m)
	if m == MOUSE_LEFT then
		self._m = nil
		self.CheckBox:Toggle()

		self.SelectedLevels[self.Level] = self.CheckBox:GetChecked() or nil

		surface.PlaySound(self.CheckBox:GetChecked() and "garrysmod/ui_click.wav" or "garrysmod/ui_hover.wav")
	end
end

net.Receive("bKeypads.KeycardPickup.Spawn", function()
	local L = bKeypads.L

	local SpawnWindow = vgui.Create("DFrame")
	SpawnWindow:SetSize(400, 500)
	SpawnWindow:SetIcon("icon16/vcard.png")
	SpawnWindow:SetTitle(L"SpawnDroppedKeycard")
	SpawnWindow:SetSizable(true)
	SpawnWindow:MakePopup()
	SpawnWindow:Center()

	SpawnWindow:SetPos((ScrW() - SpawnWindow:GetWide()) / 2, ScrH())
	local y = (ScrH() + SpawnWindow:GetTall()) / 2
	SpawnWindow:NewAnimation(1, 0, .5).Think = function(_, pnl, f)
		local f = bKeypads.ease.OutBack(f)

		local x = pnl:GetPos()
		pnl:SetPos(x, ScrH() - (y * f))

		pnl:SetAlpha(f * 255)
	end

	local Tabs = vgui.Create("DPropertySheet", SpawnWindow)
	Tabs:Dock(FILL)

		local GeneralTab = vgui.Create("DScrollPanel", Tabs)
		GeneralTab.Paint = nil

			local BehaviourCategory = CategoryBackground(vgui.Create("DForm", GeneralTab))
			BehaviourCategory:Dock(TOP)
			BehaviourCategory:SetExpanded(true)
			BehaviourCategory:SetLabel(L"Behaviour")
			BehaviourCategory:DockMargin(0, 0, 0, 10)

				local TouchToPickup = BehaviourCategory:CheckBox(L"DroppedKeycardTouchToPickup")
				local TouchToPickupTip = BehaviourCategory:Help(L"DroppedKeycardTouchToPickupTip")
				TouchToPickupTip:GetParent():DockPadding(5, 10, 5, 10)

				local Physics = BehaviourCategory:CheckBox(L"DroppedKeycardPhysics")
				local PhysicsTip = BehaviourCategory:Help(L"DroppedKeycardPhysicsTip")
				PhysicsTip:GetParent():DockPadding(5, 10, 5, 10)

				local HideToHolders = BehaviourCategory:CheckBox(L"DroppedKeycardHideToHolders")
				HideToHolders:SetChecked(true)
				local HideToHoldersTip = BehaviourCategory:Help(L"DroppedKeycardHideToHoldersTip")
				HideToHoldersTip:GetParent():DockPadding(5, 10, 5, 10)

			local LevelCategory = CategoryBackground(vgui.Create("DForm", GeneralTab))
			LevelCategory:Dock(TOP)
			LevelCategory:SetExpanded(true)
			LevelCategory:SetLabel(L"DroppedKeycardLevel")
			LevelCategory:DockMargin(0, 0, 0, 10)

				local SelectedLevels = {}
				for level, data in pairs(bKeypads.Keycards.Levels) do
					local Level = vgui.Create("DPanel", LevelCategory)
					Level:SetTall(20)
					Level:SetMouseInputEnabled(true)
					Level:SetCursor("hand")
					Level.Paint = LevelPaint
					Level.OnMousePressed = LevelMousePressed
					Level.OnMouseReleased = LevelMouseReleased
					Level.Level = level
					Level.LevelColor = data.Color
					Level.SelectedLevels = SelectedLevels

						local CheckBox = vgui.Create("DCheckBox", Level)
						Level.CheckBox = CheckBox
						CheckBox:SetMouseInputEnabled(false)
						CheckBox:SetPos(0, (Level:GetTall() - CheckBox:GetTall()) / 2)

						local Label = vgui.Create("DLabel", Level)
						Label:DockMargin(CheckBox:GetWide() + 5 + 5, 1, 0, 0)
						Label:Dock(FILL)
						Label:SetText(data.Name or (L"KeycardLevel"):format(level))
						Label:SetFont(bKeypads:DarkenForeground(data.Color) and "bKeypads.LevelSelect" or "bKeypads.LevelSelect.Shadow")
						Label:SetTextColor(bKeypads:DarkenForeground(data.Color) and bKeypads.COLOR.BLACK or bKeypads.COLOR.WHITE)
						Label:SetContentAlignment(4)
						Label:SetMouseInputEnabled(false)

					LevelCategory:AddItem(Level)
					Level:GetParent():DockPadding(5, 5, 5, next(bKeypads.Keycards.Levels, level) == nil and 5 or 0)
				end

			local QuantityCategory = CategoryBackground(vgui.Create("DForm", GeneralTab))
			QuantityCategory:Dock(TOP)
			QuantityCategory:DockMargin(0, 0, 0, 10)
			QuantityCategory:SetExpanded(true)
			QuantityCategory:SetLabel(L"DroppedKeycardQuantity")

				local Infinite = QuantityCategory:CheckBox(L"DroppedKeycardQuantityInfinite")
				Infinite:SetChecked(true)

				local Quantity = QuantityCategory:NumberWang(L"DroppedKeycardQuantity", nil, 1, 100, 0)
				local p1, p2, p3, p4 = Quantity:GetParent():GetDockPadding()
				Quantity:Dock(TOP)
				Quantity:GetParent():DockPadding(p1, p2, p3, p4 + 10)
				Quantity.Think = function(self)
					self:SetDisabled(Infinite:GetChecked())
					self:SetMouseInputEnabled(not self:GetDisabled())
				end

		local Persistent
		if bKeypads.Permissions:Check(LocalPlayer(), "persistence/manage_persistent_keycards") then
			local PersistenceCategory = CategoryBackground(vgui.Create("DForm", GeneralTab))
			PersistenceCategory:Dock(TOP)
			PersistenceCategory:SetExpanded(true)
			PersistenceCategory:SetLabel(L"Persistence")

				Persistent = PersistenceCategory:CheckBox(L"Persistent")

				local PersistenceTip = PersistenceCategory:Help(L"DroppedKeycardPersistenceTip")
				PersistenceTip:GetParent():DockPadding(5, 10, 5, 10)
		end

		local PlayerModelTab = vgui.Create("DPanel", Tabs)
		PlayerModelTab.Paint = nil

			local CustomInput = vgui.Create("DTextEntry", PlayerModelTab)
			CustomInput:Dock(TOP)
			CustomInput:SetTall(24)
			CustomInput:DockMargin(0, 0, 0, 10)
			CustomInput:SetText("models/player/kleiner.mdl")

			local PanelSelect = PlayerModelTab:Add("DPanelSelect")
			PanelSelect:Dock(FILL)

			for name, model in SortedPairs(player_manager.AllValidModels()) do
				local icon = vgui.Create("SpawnIcon")
				icon:SetModel(model)
				icon:SetSize(64, 64)
				icon.bKeypads_Tooltip = name
				icon.model_path = model

				PanelSelect:AddPanel(icon)

				if model == "models/player/kleiner.mdl" then
					PanelSelect:SelectPanel(icon)
				end
			end

			PanelSelect.OnActivePanelChanged = function(self, _, pnl)
				CustomInput:SetText(pnl.model_path)
				surface.PlaySound("garrysmod/ui_click.wav")
			end

	Tabs:AddSheet(L"General", GeneralTab, "icon16/pencil.png")
	Tabs:AddSheet(L"DroppedKeycardPlayerModel", PlayerModelTab, "icon16/user_suit.png")

	local SpawnBtn = vgui.Create("DButton", SpawnWindow)
	SpawnBtn:Dock(BOTTOM)
	SpawnBtn:DockMargin(0, 5, 0, 0)
	SpawnBtn:SetTall(25)
	SpawnBtn:SetDisabled(true)
	SpawnBtn:SetText(L"Spawn")
	SpawnBtn:SetIcon("icon16/world.png")
	SpawnBtn.Think = function(self)
		self:SetDisabled(#CustomInput:GetValue() == 0 or not CustomInput:GetValue():lower():match("^models/.-%.mdl$") or table.IsEmpty(SelectedLevels))
	end
	SpawnBtn.DoClick = function()
		surface.PlaySound("garrysmod/save_load" .. math.random(1,4) .. ".wav")

		net.Start("bKeypads.KeycardPickup.Spawn")
			net.WriteBool(Persistent and Persistent:GetChecked() or false)
			net.WriteBool(TouchToPickup:GetChecked())
			net.WriteBool(Physics:GetChecked())
			net.WriteBool(HideToHolders:GetChecked())
			net.WriteUInt(Infinite:GetChecked() and 0 or Quantity:GetValue(), 32)
			net.WriteString(CustomInput:GetValue())
			net.WriteUInt(table.Count(SelectedLevels), 32)
			for level in pairs(SelectedLevels) do net.WriteUInt(level, 32) end
		net.SendToServer()

		SpawnWindow:Close()
	end
end)