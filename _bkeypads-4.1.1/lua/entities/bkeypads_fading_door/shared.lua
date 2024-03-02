AddCSLuaFile()

ENT.Type = "point"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Fading Door (Billy's Keypads)"
ENT.Author = "Billy"

ENT.Spawnable = false

ENT.RenderGroup = RENDERGROUP_OTHER

function ENT:Initialize()
	self:SetTransmitWithParent(true)

	self:DrawShadow(false)
	self:SetRenderMode(RENDERMODE_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)

	if CLIENT and IsValid(self:GetFadeEnt()) then
		self:FadeEntChanged(nil, nil, self:GetFadeEnt())
		bKeypads.ESP:Refresh()
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "FadeEnt")

	self:NetworkVar("Bool", 0, "Toggle")
	self:NetworkVar("Bool", 1, "Reversed")

	self:NetworkVar("String", 0, "FadeMaterial")
	self:NetworkVar("String", 1, "OpenSound")
	self:NetworkVar("String", 2, "ActiveSound")
	self:NetworkVar("String", 3, "CloseSound")

	self:NetworkVar("Int", 0, "KeyboardButton")

	if CLIENT then
		self:NetworkVarNotify("FadeEnt", self.FadeEntChanged)
	else
		self:NetworkVarNotify("KeyboardButton", self.KeyboardButtonChanged)
	end
	self:NetworkVarNotify("Toggle", self.RebuildConfig)
	self:NetworkVarNotify("Reversed", self.RebuildConfig)
	self:NetworkVarNotify("FadeMaterial", self.RebuildConfig)
	self:NetworkVarNotify("OpenSound", self.RebuildConfig)
	self:NetworkVarNotify("ActiveSound", self.RebuildConfig)
	self:NetworkVarNotify("CloseSound", self.RebuildConfig)
end

if CLIENT then
	function ENT:FadeEntChanged(_, __, FadeEnt)
		self:ParentTo(FadeEnt)
		bKeypads.ESP:Refresh()
	end
else
	function ENT:RemoveKeyBinds()
		if self.BindUp then
			numpad.Remove(self.BindUp)
			self.BindUp = nil
		end
		if self.BindDown then
			numpad.Remove(self.BindDown)
			self.BindDown = nil
		end
	end

	function ENT:AddKeyBinds(key)
		local ply = self:GetCreator()
		if IsValid(ply) then
			self.BindUp = numpad.OnUp(ply, key, "bKeypads.FadingDoor.Up", self)
			self.BindDown = numpad.OnDown(ply, key, "bKeypads.FadingDoor.Down", self)
		end
	end

	function ENT:KeyboardButtonChanged(_, oldKey, newKey)
		self:RebuildConfig("KeyboardButton", oldKey, newKey)

		if oldKey == newKey then return end
		self:RemoveKeyBinds()
		if newKey > 0 then
			self:AddKeyBinds(newKey)
		end
	end

	local function BtnDown(ply, controller)
		if not IsValid(controller) then return end
		local ent = controller:GetFadeEnt()
		if not IsValid(ent) or not bKeypads.FadingDoors:IsFadingDoor(ent) then return end

		if not controller.m_bBindPressed and bKeypads.Config.FadingDoors.EnableKeyboardPress and bKeypads.Permissions:Check(ply, "fading_doors/keyboard") then
			controller.m_bBindPressed = true
			if controller:GetToggle() then
				ent:fadeToggleActive()
			elseif controller:GetReversed() then
				ent:fadeDeactivate()
			else
				ent:fadeActivate()
			end
		end
	end

	local function BtnUp(ply, controller)
		if not IsValid(controller) then return end
		local ent = controller:GetFadeEnt()
		if not IsValid(ent) or not bKeypads.FadingDoors:IsFadingDoor(ent) then return end

		if controller.m_bBindPressed then
			controller.m_bBindPressed = nil
			if not controller:GetToggle() then
				if controller:GetReversed() then
					ent:fadeActivate()
				else
					ent:fadeDeactivate()
				end
			end
		end
	end

	numpad.Register("bKeypads.FadingDoor.Down", BtnDown)
	numpad.Register("bKeypads.FadingDoor.Up", BtnUp)
end

do
	local fadeBroadcast, fadeActivate, fadeDeactivate, fadeToggleActive
	if SERVER then
		function fadeBroadcast(self)
			net.Start("bKeypads.FadingDoors.Fade")
				net.WriteEntity(self)
				net.WriteBool(self.fadeActive)
			net.Broadcast()
		end

		function fadeActivate(self)
			self.fadeActive = true
			fadeBroadcast(self)
			bKeypads.FadingDoors:DoFade(self)
		end

		function fadeDeactivate(self)
			self.fadeActive = false
			fadeBroadcast(self)
			bKeypads.FadingDoors:DoFade(self)
		end

		function fadeToggleActive(self)
			self.fadeActive = not self.fadeActive
			fadeBroadcast(self)
			bKeypads.FadingDoors:DoFade(self)
		end

		function fadeCancel(self)
			self.fadeActive = self.fadeReversed
			fadeBroadcast(self)
			bKeypads.FadingDoors:DoFade(self)
		end
	end

	function ENT:ParentTo(ent)
		ent.bKeypads_FadingDoor = self

		self:SetParent(ent)

		ent.isFadingDoor = true
		ent.fadeActive = false
		if SERVER then
			self:SetFadeEnt(ent)

			ent:DeleteOnRemove(self)

			ent.fadeDeactivate = fadeDeactivate
			ent.fadeActivate = fadeActivate
			ent.fadeToggle = fadeToggle
			ent.fadeToggleActive = fadeToggleActive
			ent.fadeCancel = fadeCancel

			self.StuckTickTimer = "bKeypads.FadingDoors.StuckTick:" .. self:GetCreationID()
		else
			bKeypads.ESP:Refresh()
		end

		self:RebuildConfig()

		bKeypads_FadingDoors_Registry[ent] = self
	end
end

function ENT:SaveRestoreData()
	local ent = self:GetFadeEnt()
	if not IsValid(ent) then return end

	self.m_FadingDoorData.Restore = {
		Material = ent:GetMaterial(),
		DrawShadow = not ent:IsEffectActive(EF_NOSHADOW),
		Solid = ent:GetSolid(),
		SolidFlags = ent:GetSolidFlags(),
		CollisionGroup = ent:GetCollisionGroup()
	}

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		self.m_FadingDoorData.Restore.Moveable = phys:IsMoveable()
	end
end

function ENT:GetRestoreData()
	return self.m_FadingDoorData.Restore
end

function ENT:Restore()
	if self.m_FadingDoorData.Restore then
		local ent = self:GetFadeEnt()
		if not IsValid(ent) then return end

		ent:SetMaterial(self.m_FadingDoorData.Restore.Material)

		ent:DrawShadow(self.m_FadingDoorData.Restore.DrawShadow)
		if CLIENT then ent:MarkShadowAsDirty() end

		ent:SetSolid(self.m_FadingDoorData.Restore.Solid)
		ent:SetSolidFlags(self.m_FadingDoorData.Restore.SolidFlags)
		ent:SetCollisionGroup(self.m_FadingDoorData.Restore.CollisionGroup)

		if self.m_FadingDoorData.Restore.Moveable then
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(self.m_FadingDoorData.Restore.Moveable)
				phys:Wake()
			end
		end

		self.m_FadingDoorData.Restore = nil
	end
end

function ENT:RebuildConfig(varName, _, newVal)
	if not self.m_FadingDoorData then
		self.m_FadingDoorData = {}
	end

	if not self.m_FadingDoorData.Config then
		if not IsValid(self:GetFadeEnt()) then return end
		self.m_FadingDoorData.Config = {}
	end

	if varName then
		self.m_FadingDoorData.Config[varName] = newVal
	else
		self.m_FadingDoorData.Config.Player = self:GetPlayer()
		self.m_FadingDoorData.Config.Toggle = self:GetToggle()
		self.m_FadingDoorData.Config.Reversed = self:GetReversed()
		self.m_FadingDoorData.Config.FadeMaterial = self:GetFadeMaterial()
		self.m_FadingDoorData.Config.OpenSound = self:GetOpenSound()
		self.m_FadingDoorData.Config.ActiveSound = self:GetActiveSound()
		self.m_FadingDoorData.Config.CloseSound = self:GetCloseSound()
		self.m_FadingDoorData.Config.KeyboardButton = self:GetKeyboardButton()
	end

	self:GetFadeEnt().fadeToggle = self:GetToggle()
	self:GetFadeEnt().fadeReversed = self:GetReversed()

	if SERVER then
		duplicator.StoreEntityModifier(self:GetFadeEnt(), "bKeypads.FadingDoor", self.m_FadingDoorData.Config)
	end

	return self.m_FadingDoorData.Config
end

function ENT:GetConfig()
	return self.m_FadingDoorData.Config or self:RebuildConfig()
end

do
	local function CleanParent(ent)
		if not IsValid(ent) then return end

		ent.bKeypads_FadingDoor = nil

		if ent.FadeDoorSound then
			ent.FadeDoorSound:Stop()
			ent.FadeDoorSound = nil
		end

		ent.isFadingDoor = nil
		ent.fadeActive = nil
		if SERVER then
			ent.fadeDeactivate = nil
			ent.fadeActivate = nil
			ent.fadeToggle = nil
			ent.fadeToggleActive = nil

			duplicator.ClearEntityModifier(ent, "bKeypads.FadingDoor")
		end
	end

	if SERVER then
		function ENT:OnRemove()
			self:RemoveKeyBinds()

			self:Restore()
			CleanParent(self:GetFadeEnt())
			timer.Remove(self.StuckTickTimer)

			bKeypads_FadingDoors_Registry[self] = nil
		end
	else
		function ENT:OnRemove()
			bKeypads.ESP:Refresh()

			local ent = self:GetFadeEnt()
			if not IsValid(ent) then return end

			bKeypads:nextTick(function()
				if not IsValid(self) then
					CleanParent(ent)
					bKeypads_FadingDoors_Registry[self] = nil
				end
			end)
		end
	end
end

bKeypads_Initialize_Fix(ENT)