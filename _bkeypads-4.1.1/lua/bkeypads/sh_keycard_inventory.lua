bKeypads.Keycards = bKeypads.Keycards or {}
bKeypads.Keycards.Inventory = {}
bKeypads_Keycards_Inventory_Cards = bKeypads_Keycards_Inventory_Cards or {}
bKeypads.Keycards.Inventory.Cards = bKeypads_Keycards_Inventory_Cards

function bKeypads.Keycards.Inventory:Clear(ply)
	bKeypads.Keycards.Inventory.Cards[ply] = nil
end
hook.Add("player_spawn", "bKeypads.Keycards.Inventory.Spawn", function(data)
	if not data or not data.userid then return end
	local ply = Player(data.userid)
	if not IsValid(ply) then return end
	bKeypads.Keycards.Inventory:Clear(ply)
end)
gameevent.Listen("player_spawn")

function bKeypads.Keycards.Inventory:IsHoldingKeycard(ply, keycardID)
	return bKeypads.Keycards.Inventory.Cards[ply] ~= nil and bKeypads.Keycards.Inventory.Cards[ply][keycardID] ~= nil
end

function bKeypads.Keycards.Inventory:PickupKeycard(ply, keycard, keycardIDFallback)
	assert(IsValid(ply), "NULL player tried to pickup a keycard!")

	local keycardID = isnumber(keycard) or (IsValid(keycard) and keycard:GetID() or keycardIDFallback)
	assert(keycardID ~= 0, "Tried to pick up keycard with no ID!")

	if bKeypads.Keycards.Inventory.Cards[ply] and bKeypads.Keycards.Inventory.Cards[ply][keycardID] then return end
	bKeypads.Keycards.Inventory.Cards[ply] = bKeypads.Keycards.Inventory.Cards[ply] or {}
	bKeypads.Keycards.Inventory.Cards[ply][keycardID] = true

	--print("PICKED UP", ply, keycard, keycardIDFallback)

	if IsValid(keycard) then
		if not keycard:GetInfinite() then
			if keycard:GetQuantity() <= 0 then
				return
			elseif SERVER then
				keycard:SetQuantity(keycard:GetQuantity() - 1)

				hook.Run("bKeypads.Keycard.PickedUp", ply, keycard, keycard:GetQuantity())

				if keycard:GetQuantity() == 0 and not keycard:GetPersist() then
					keycard:Remove()
				end
			end
		elseif SERVER then
			hook.Run("bKeypads.Keycard.PickedUp", ply, keycard)
		end
	end

	local keycardData = bKeypads.Keycards:GetByID(keycardID)
	if SERVER and keycardData and IsValid(keycardData.Keycard) and keycardData.Keycard:GetHideToHolders() then
		--keycardData.Keycard:SetCollisionRule(ply, false)
		keycardData.Keycard:SetPreventTransmit(ply, true)
	end

	if (IsValid(keycard) and keycard:GetPlayerKeycardDataBind() == ply:SteamID()) or (keycardData and keycardData.PlayerBind and keycardData.PlayerBind and #keycardData.PlayerBind > 0 and keycardData.PlayerBind == ply:SteamID()) then
		bKeypads_Keycards_Registry[keycardID] = bKeypads.Keycards:GetKeycardData(ply)

		local bkeycard = ply:GetWeapon("bkeycard")
		if IsValid(bkeycard) and not bkeycard:GetWasPickedUp() then
			bKeypads.Keycards.Inventory.Cards[ply][keycardID] = nil
			if table.IsEmpty(bKeypads.Keycards.Inventory.Cards[ply]) then
				bKeypads.Keycards.Inventory.Cards[ply] = nil
			end
		end
	end

	if SERVER then

		net.Start("bKeypads.Keycards.Inventory.Pickup")
			net.WriteEntity(ply)
			net.WriteEntity(keycard or NULL)
			net.WriteUInt(keycardID, 32)
		net.Broadcast()

		if bKeypads.Keycards.Inventory.Cards[ply] and bKeypads.Keycards.Inventory.Cards[ply][keycardID] then
			local bkeycard = ply:GetWeapon("bkeycard")
			if not IsValid(bkeycard) then
				bkeycard = ply:Give("bkeycard")
				bkeycard:EmitSound("weapons/smg1/switch_burst.wav", 55, 100, 1, CHAN_WEAPON)
				if IsValid(bkeycard) then
					bkeycard:SetWasPickedUp(true)
				end
			end

			if IsValid(bkeycard) then
				bkeycard:SetSelectedKeycard(keycardID)
			end
		end

	elseif IsValid(bKeypads_Keycard_Inventory) then

		bKeypads_Keycard_Inventory.keycardsContainer:Populate()

	end
end

function bKeypads.Keycards.Inventory:RemoveKeycard(ply, keycardID)
	--print("REMOVED KEYCARD", ply, keycardID)

	if keycardID ~= 0 then
		if not bKeypads.Keycards.Inventory.Cards[ply] or not bKeypads.Keycards.Inventory.Cards[ply][keycardID] then return false end

		bKeypads.Keycards.Inventory.Cards[ply][keycardID] = nil
		if table.IsEmpty(bKeypads.Keycards.Inventory.Cards[ply]) then
			bKeypads.Keycards.Inventory.Cards[ply] = nil
		end
	end

	if SERVER then

		local rootKeycard = bKeypads.Keycards:GetByID(keycardID)
		if rootKeycard and IsValid(rootKeycard.Keycard) and rootKeycard.Keycard:GetHideToHolders() then
			--rootKeycard.Keycard:SetCollisionRule(ply, true)
			rootKeycard.Keycard:SetPreventTransmit(ply, false)
		end

		if keycardID ~= 0 then
			net.Start("bKeypads.Keycards.Inventory.Remove")
				net.WriteEntity(ply)
				net.WriteUInt(keycardID, 32)
			net.Broadcast()
		end

		local bkeycard = ply:GetWeapon("bkeycard")
		if IsValid(bkeycard) and bkeycard:GetSelectedKeycard() == keycardID then
			if bkeycard:GetWasPickedUp() then
				local heldKeycards = bKeypads.Keycards.Inventory:GetHeldKeycards(ply)
				local switchTo = heldKeycards ~= nil and next(heldKeycards) or nil
				if switchTo then
					bkeycard:SetSelectedKeycard(switchTo)
				else
					ply:StripWeapon("bkeycard")
					if ply:Alive() then ply:SwitchToDefaultWeapon() end
				end
			elseif keycardID ~= 0 then
				bkeycard:SetSelectedKeycard(0)
			else
				ply:StripWeapon("bkeycard")
				if ply:Alive() then ply:SwitchToDefaultWeapon() end
			end
		end

	elseif ply == LocalPlayer() and IsValid(bKeypads_Keycard_Inventory) then

		bKeypads_Keycard_Inventory.keycardsContainer:Populate()

	end

	return true
end

function bKeypads.Keycards.Inventory:DropKeycard(ply, keycardID, force)
	if force ~= true then
		local canDrop
		if keycardID == 0 then
			canDrop = bKeypads.Config.Keycards.CanDropSpawnedWithKeycard and bKeypads.Permissions:Check(ply, "keycards/drop_spawned")
		else
			canDrop = bKeypads.Config.Keycards.CanDropKeycard and bKeypads.Permissions:Check(ply, "keycards/drop")
		end
		if not canDrop then return end
	else
		assert(SERVER, "Can't force drop keycard on the client!")
	end

	local keycard = ply:GetWeapon("bkeycard")
	if not IsValid(keycard) or (force ~= true and keycard:GetBeingScanned()) then return end

	if not bKeypads.Keycards.Inventory:RemoveKeycard(ply, keycardID) then return end

	if SERVER then

		local _, keycard = bKeypads.Keycards:SpawnKeycard(keycardID, ply)
		hook.Run("bKeypads.Keycard.Dropped", ply, keycard)

	elseif ply == LocalPlayer() then

		net.Start("bKeypads.Keycards.Inventory.Drop")
			net.WriteUInt(keycardID, 32)
		net.SendToServer()

	end
end

function bKeypads.Keycards.Inventory:GetHeldKeycards(ply)
	return bKeypads.Keycards.Inventory.Cards[ply]
end

function bKeypads.Keycards.Inventory:SwitchKeycard(ply, keycardID)
	local bkeycard = ply:GetWeapon("bkeycard")
	if not IsValid(bkeycard) or bkeycard:GetBeingScanned() then return end

	if keycardID == 0 then
		if bkeycard:GetWasPickedUp() then return end
	else
		if not bKeypads.Keycards.Inventory:IsHoldingKeycard(ply, keycardID) then return end
	end

	if SERVER then
		bkeycard:SetSelectedKeycard(keycardID)
		hook.Run("bKeypads.Keycard.Selected", ply, keycardID, bkeycard)
	elseif ply == LocalPlayer() then
		net.Start("bKeypads.Keycards.Inventory.Switch")
			net.WriteUInt(keycardID, 32)
		net.SendToServer()
	end
end

if SERVER then
	hook.Add("canDropWeapon", "bKeypads.DarkRP.canDropWeapon", function(ply, wep)
		if wep:GetClass() == "bkeycard" then
			return false
		end
	end)
end

if SERVER then
	util.AddNetworkString("bKeypads.Keycards.Inventory.Pickup")
	util.AddNetworkString("bKeypads.Keycards.Inventory.Drop")
	util.AddNetworkString("bKeypads.Keycards.Inventory.Remove")
	util.AddNetworkString("bKeypads.Keycards.Inventory.Switch")

	net.Receive("bKeypads.Keycards.Inventory.Drop", function(_, ply)
		bKeypads.Keycards.Inventory:DropKeycard(ply, net.ReadUInt(32))
	end)

	net.Receive("bKeypads.Keycards.Inventory.Switch", function(_, ply)
		bKeypads.Keycards.Inventory:SwitchKeycard(ply, net.ReadUInt(32))
	end)
else
	net.Receive("bKeypads.Keycards.Inventory.Pickup", function()
		bKeypads.Keycards.Inventory:PickupKeycard(net.ReadEntity(), net.ReadEntity(), net.ReadUInt(32))
	end)

	net.Receive("bKeypads.Keycards.Inventory.Remove", function()
		bKeypads.Keycards.Inventory:RemoveKeycard(net.ReadEntity(), net.ReadUInt(32))
	end)
end

if CLIENT then
	if IsValid(bKeypads_Keycard_Inventory) then
		bKeypads_Keycard_Inventory:Remove()
	end

	local KeycardModelPanels

	local KEYCARD_ACTIVE = -1
	local KEYCARD_PLAYER = 0

	local width
	local marginBottom

	local tileSpacing
	local tileRowCount
	local tileSize

	local activeTileWidth
	local activeTileHeight
	local activeTileSpacing

	local function InventoryScreenScale()
		width = (800 / 1920) * ScrW()
		marginBottom = (50 / 1920) * ScrW()

		tileSpacing = (10 / 1920) * ScrW()
		tileRowCount = math.ceil((7 / 1920) * ScrW())
		tileSize = (width - ((tileRowCount - 1) * tileSpacing)) / tileRowCount

		activeTileWidth = (300 / 1920) * ScrW()
		activeTileHeight = (200 / 1920) * ScrW()
		activeTileSpacing = marginBottom / 2
	end
	InventoryScreenScale()
	hook.Add("OnScreenSizeChanged", "bKeypads.Keycard.Inventory.ScreenScale", InventoryScreenScale)

	local InventoryThinkCache, InventoryThinkCacheFrame
	local function InventoryThink()
		if not InventoryThinkCache or InventoryThinkCacheFrame ~= FrameNumber() then
			local keycardWeapon = LocalPlayer():GetActiveWeapon()
			InventoryThinkCache = LocalPlayer():Alive() and IsValid(keycardWeapon) and keycardWeapon:GetClass() == "bkeycard"
		end
		return InventoryThinkCache
	end

	local examineKeycardDMenu
	local function GetExaminationKeycard()
		if not InventoryThink() then return end
		if IsValid(examineKeycardDMenu) then
			return examineKeycardDMenu.m_examineKeycard, examineKeycardDMenu.m_examineKeycardID
		else
			local hovered = vgui.GetHoveredPanel()
			if IsValid(hovered) and hovered.m_bIsbKeycardPanel and hovered.m_iKeycardID and hovered.m_iKeycardID ~= KEYCARD_ACTIVE then
				return hovered.Entity, hovered.m_iKeycardID
			end
		end
		return LocalPlayer():GetActiveWeapon(), LocalPlayer():GetActiveWeapon():GetSelectedKeycard()
	end

	local function keycardPanel_Paint(self, w, h)
		if not InventoryThink() then return end

		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawRect(0, 0, w, h)

		if LocalPlayer():GetActiveWeapon():GetSelectedKeycard() == self.m_iKeycardID then
			surface.SetDrawColor(bKeypads.COLOR.GMODBLUE)
			surface.DrawOutlinedRect(0, 0, w, h, 3)
		elseif select(2, GetExaminationKeycard()) == self.m_iKeycardID then
			surface.SetDrawColor(bKeypads.COLOR.GMODBLUE)
			surface.DrawOutlinedRect(0, 0, w, h, 3)
		else
			surface.SetDrawColor(150, 150, 150, 255)
			surface.DrawOutlinedRect(0, 0, w, h)
		end

		DModelPanel.Paint(self, w, h)
	end

	local function keycardPanel_OnMousePressed(self, m)
		if (m == MOUSE_LEFT or m == MOUSE_RIGHT) then self._m = m end
	end
	local function keycardPanel_OnMouseReleased(self, m)
		if self._m == m and InventoryThink() then
			local bkeycard = LocalPlayer():GetActiveWeapon()

			surface.PlaySound("weapons/ar2/ar2_empty.wav")

			local DMenu = DermaMenu(nil, self)

			examineKeycardDMenu = DMenu
			DMenu.m_examineKeycard = self.Entity
			DMenu.m_examineKeycardID = self.m_iKeycardID

			DMenu:AddOption(self.Entity:GetKeycardName()):SetIcon("icon16/tag_blue.png")
			DMenu:AddSpacer()

			local KeycardLevels, SubMenu = DMenu:AddSubMenu(bKeypads.L"KeycardLevels")
			SubMenu:SetIcon("icon16/vcard.png")

			for _, level in ipairs(self.Entity:GetLevels()) do
				bKeypads.DermaMenuOption_Color(KeycardLevels:AddOption("[" .. level .. "] " .. bKeypads.Keycards.Levels[level].Name), bKeypads.Keycards.Levels[level].Color)
			end

			if bkeycard:GetSelectedKeycard() ~= self.m_iKeycardID then
				DMenu:AddOption(bKeypads.L"KeycardSwitch", function()

					bKeypads.Keycards.Inventory:SwitchKeycard(LocalPlayer(), self.m_iKeycardID)

				end):SetIcon("icon16/arrow_switch.png")
			end

			local canDrop
			if self.m_iKeycardID == 0 then
				canDrop = bKeypads.Config.Keycards.CanDropSpawnedWithKeycard and bKeypads.Permissions:Check(LocalPlayer(), "keycards/drop_spawned")
			else
				canDrop = bKeypads.Config.Keycards.CanDropKeycard and bKeypads.Permissions:Check(LocalPlayer(), "keycards/drop")
			end
			if canDrop then
				DMenu:AddOption(bKeypads.L"KeycardDrop", function()

					surface.PlaySound("weapons/iceaxe/iceaxe_swing1.wav")

					bKeypads.Keycards.Inventory:DropKeycard(LocalPlayer(), self.m_iKeycardID)

				end):SetIcon("icon16/delete.png")
			end

			DMenu:Open()
		end
		self._m = nil
	end

	local function keycardPanel_GetKeycardColor(self)
		return (self.m_KeycardMetadata or {}).Color or bKeypads.COLOR.RED
	end
	local function keycardPanel_GetKeycardName(self)
		return self.m_KeycardMetadata.Name or bKeypads.L("KeycardLevel"):format(self.m_iPrimaryLevel)
	end
	local function keycardPanel_GetLevels(self)
		return self.m_KeycardData.Levels
	end
	local function keycardPanel_GetPlayerModel(self)
		return self.m_KeycardData.PlayerModel
	end
	local function keycardPanel_GetSteamID(self)
		return self.m_KeycardData.SteamID
	end
	local function keycardPanel_GetTeam(self)
		return self.m_KeycardData.Team
	end
	local function keycardPanel_GetHash(self)
		return self.m_Hash
	end

	local function activeTile_OnMouseReleased(self, m)
		if self._m == m then
			local KeycardModelPanel = KeycardModelPanels[LocalPlayer():GetActiveWeapon():GetSelectedKeycard()]
			if IsValid(KeycardModelPanel) then
				KeycardModelPanel:OnMousePressed(m)
				KeycardModelPanel:OnMouseReleased(m)
			end
		end
		self._m = nil
	end

	local function KeycardModelPanel_PreDrawModel(self)
		if not InventoryThink() then return end

		if self.m_iKeycardID == KEYCARD_ACTIVE then
			local examineKeycard, examineKeycardID = GetExaminationKeycard()

			if self.m_iTextureKeycardID ~= examineKeycardID then
				self.m_iTextureKeycardID = examineKeycardID
				self.Entity.KeycardColor = examineKeycard:GetKeycardColor()
			end

			bKeypads.Keycards.Textures:Draw(bKeypads.Keycards.Textures.TOP, self.Entity, examineKeycard)
		else
			bKeypads.Keycards.Textures:Draw(bKeypads.Keycards.Textures.TOP, self.Entity)
		end
	end
	local function KeycardModelPanel_SetKeycardID(self, keycardID)
		self.m_iKeycardID = keycardID

		if keycardID ~= KEYCARD_ACTIVE then
			local keycard = keycardID == KEYCARD_PLAYER and bKeypads.Keycards:GetKeycardData(LocalPlayer()) or bKeypads.Keycards:GetByID(keycardID)

			self.Entity.m_iPrimaryLevel   = keycard.PrimaryLevel
			self.Entity.m_KeycardMetadata = bKeypads.Keycards.Levels[keycard.PrimaryLevel]
			self.Entity.m_KeycardData     = keycard
			self.Entity.m_Hash            = util.CRC((keycard.SteamID or "") .. (keycard.PlayerModel or "") .. table.concat(keycard.Levels, ",") .. (keycard.Team or ""))

			self.Entity.GetKeycardColor   = keycardPanel_GetKeycardColor
			self.Entity.GetKeycardName    = keycardPanel_GetKeycardName
			self.Entity.GetLevels         = keycardPanel_GetLevels
			self.Entity.GetPlayerModel    = keycardPanel_GetPlayerModel
			self.Entity.GetSteamID        = keycardPanel_GetSteamID
			self.Entity.GetTeam           = keycardPanel_GetTeam
			self.Entity.GetHash           = keycardPanel_GetHash
		end
	end
	local function KeycardModelPanel_LayoutSpin(self)
		local mn, mx = self.Entity:GetRenderBounds()
		local size = 0
		size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
		size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
		size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

		local CamPos = Vector(size, size, size)
		local LookAt = (mn + mx) * 0.5

		self:SetFOV(45)
		self:SetCamPos(CamPos)
		self:SetLookAt(LookAt)
	end
	local function KeycardModelPanel_LayoutExamine(self)
		self.LayoutEntity = bKeypads.noop
		self:SetFOV(30)
		self:SetCamPos(Vector(0,0,10))
		self:SetLookAng(Angle(90, 270, 0))
	end
	local function KeycardModelPanel(parent, keycardID)
		local keycardPanel = vgui.Create("DModelPanel", parent)

		keycardPanel.m_bIsbKeycardPanel = true

		keycardPanel.SetKeycardID = KeycardModelPanel_SetKeycardID
		keycardPanel.LayoutSpin = KeycardModelPanel_LayoutSpin
		keycardPanel.LayoutExamine = KeycardModelPanel_LayoutExamine

		keycardPanel.PreDrawModel = KeycardModelPanel_PreDrawModel
		keycardPanel.OnMousePressed = keycardPanel_OnMousePressed
		keycardPanel.OnMouseReleased = keycardPanel_OnMouseReleased

		keycardPanel:SetMouseInputEnabled(true)
		keycardPanel:SetCursor("hand")

		keycardPanel:SetModel(bKeypads.MODEL.KEYCARD)
		keycardPanel.Entity.bKeycard = true

		if keycardID then
			keycardPanel:SetKeycardID(keycardID)
		end

		return keycardPanel
	end

	local function bKeypads_Keycard_Inventory_PerformLayout(self, w, h)
		if self._w == w and self._h == h and self._c == #self:GetChildren() then return end
		self._w, self._h, self._c = w, h, #self:GetChildren()

		self:SizeToChildren(false, true)
		self:CenterHorizontal()
		self:AlignBottom(marginBottom)
	end

	local function bKeypads_Keycard_Inventory_Think(self, w, h)
		if not InventoryThink() then
			self:Remove()
		end
	end

	local function keycardsContainer_PerformLayout(self, w, h)
		for i, keycard in ipairs(self:GetChildren()) do
			keycard:SetPos(((i - 1) % (tileRowCount - 1)) * (tileSize + tileSpacing), math.floor(i / tileRowCount) * (tileSize + tileSpacing))
		end

		self:SizeToChildren(true, true)
		self:AlignTop(activeTileHeight + activeTileSpacing)
		self:CenterHorizontal()
		self:InvalidateParent()
	end

	local function focusMouse(self)
		if FrameNumber() - self.m_iFrameStart >= 2 then
			input.SetCursorPos(self:LocalToScreen(self:GetWide() / 2, self:GetTall() / 2))
			self.Think = nil
		end
	end

	function bKeypads.Keycards.Inventory:Show()
		if not InventoryThink() then return end

		if IsValid(bKeypads_Keycard_Inventory) then
			bKeypads_Keycard_Inventory:Remove()
		end

		KeycardModelPanels = {}

		local selectedKeycardPanel

		bKeypads_Keycard_Inventory = vgui.Create("EditablePanel")
		bKeypads_Keycard_Inventory.Paint = nil
		bKeypads_Keycard_Inventory:SetWide(width)
		bKeypads_Keycard_Inventory:MakePopup()
		bKeypads_Keycard_Inventory:SetKeyboardInputEnabled(false)
		bKeypads_Keycard_Inventory:SetMouseInputEnabled(true)
		bKeypads_Keycard_Inventory.PerformLayout = bKeypads_Keycard_Inventory_PerformLayout
		bKeypads_Keycard_Inventory.Think = bKeypads_Keycard_Inventory_Think

		local activeTileContainer = vgui.Create("DPanel", bKeypads_Keycard_Inventory)
		activeTileContainer.Paint = nil
		activeTileContainer:SetSize(activeTileWidth, activeTileHeight + activeTileSpacing)
		activeTileContainer:CenterHorizontal()

			local activeTile = KeycardModelPanel(activeTileContainer, KEYCARD_ACTIVE)
			activeTile:LayoutExamine()
			activeTile:SetSize(activeTileWidth, activeTileHeight)
			activeTile.OnMouseReleased = activeTile_OnMouseReleased

		local keycardsContainer = vgui.Create("DPanel", bKeypads_Keycard_Inventory)
		bKeypads_Keycard_Inventory.keycardsContainer = keycardsContainer
		keycardsContainer.Paint = nil
		keycardsContainer.PerformLayout = keycardsContainer_PerformLayout
		keycardsContainer.Populate = function()
			keycardsContainer:Clear()
			keycardsContainer.m_iTileCount = 0

			if not LocalPlayer():GetActiveWeapon():GetWasPickedUp() then
				local keycardPanel = KeycardModelPanel(keycardsContainer, KEYCARD_PLAYER)
				keycardPanel:LayoutSpin()
				keycardPanel:SetSize(tileSize, tileSize)
				keycardPanel.Paint = keycardPanel_Paint

				KeycardModelPanels[KEYCARD_PLAYER] = keycardPanel

				keycardsContainer.m_iTileCount = keycardsContainer.m_iTileCount + 1

				if not selectedKeycardPanel and LocalPlayer():GetActiveWeapon():GetSelectedKeycard() == 0 then
					selectedKeycardPanel = keycardPanel
				end
			end

			local heldKeycards = bKeypads.Keycards.Inventory:GetHeldKeycards(LocalPlayer())
			if heldKeycards then
				local sortKeycards = {}
				for keycardID in pairs(heldKeycards) do
					local keycardData = bKeypads.Keycards:GetByID(keycardID)
					local power = (keycardData.PrimaryLevel ^ 2) + #keycardData.Levels
					sortKeycards[keycardID] = power
				end
				for keycardID in SortedPairsByValue(sortKeycards, true) do
					local keycardPanel = KeycardModelPanel(keycardsContainer, keycardID)
					keycardPanel:LayoutSpin()
					keycardPanel:SetSize(tileSize, tileSize)
					keycardPanel.Paint = keycardPanel_Paint

					KeycardModelPanels[keycardID] = keycardPanel

					keycardsContainer.m_iTileCount = keycardsContainer.m_iTileCount + 1

					if not selectedKeycardPanel and LocalPlayer():GetActiveWeapon():GetSelectedKeycard() == keycardID then
						selectedKeycardPanel = keycardPanel
					end
				end
			end

			local rows = keycardsContainer.m_iTileCount / (tileRowCount - 1)
			keycardsContainer:SetTall((math.ceil(rows) * tileSize) + ((math.ceil(rows) - 1) * tileSpacing))
			bKeypads_Keycard_Inventory:SetTall(activeTileHeight + activeTileSpacing + keycardsContainer:GetTall())
			bKeypads_Keycard_Inventory:AlignBottom(marginBottom)
		end

		keycardsContainer:Populate()

		if IsValid(selectedKeycardPanel) then
			selectedKeycardPanel.Think = focusMouse
			selectedKeycardPanel.m_iFrameStart = FrameNumber()
		end
		selectedKeycardPanel = true

		surface.PlaySound("npc/combine_soldier/gear5.wav")
	end
end