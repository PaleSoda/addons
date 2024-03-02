ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "#bKeypads_KeypadCracker"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.DisableDuplicator = true

ENT.ANIM = {}
ENT.ANIM.CRACKING        = 0
ENT.ANIM.OPEN_PANEL      = -1
ENT.ANIM.POP_OFF_CRACKER = 1
ENT.ANIM.CLOSE_PANEL     = 2
ENT.ANIM.POP_IN_PANEL    = 3
ENT.ANIM.FINISHED        = ENT.ANIM[table.GetWinningKey(ENT.ANIM)] + 1

ENT.AnimationStages = {
	[ENT.ANIM.CRACKING] = {
		Duration = function(self)
			return self.m_bIsWeapon or (self:GetCracking() and self:GetCrackCompleteTime() ~= 0 and IsValid(self:GetKeypad()) and self:GetKeypad().bKeypad and CurTime() > self:GetCrackCompleteTime())
		end
	},

	[ENT.ANIM.OPEN_PANEL] = {
		Duration = 1,
	},

	[ENT.ANIM.POP_OFF_CRACKER] = {
		Duration = 0.5,
	},

	[ENT.ANIM.CLOSE_PANEL] = {
		Duration = 1,
	},

	[ENT.ANIM.POP_IN_PANEL] = {
		Duration = 1.15,
		Delay = 0.115,
	},
}

ENT.PickupSounds = {
	Sound("npc/combine_soldier/gear1.wav"),
	Sound("npc/combine_soldier/gear2.wav"),
	Sound("npc/combine_soldier/gear3.wav"),
	Sound("npc/combine_soldier/gear4.wav"),
	Sound("npc/combine_soldier/gear5.wav"),
	Sound("npc/combine_soldier/gear6.wav")
}

local PickupSoundsPrecached = false

function ENT:Initialize()
	self:SetModel("models/bkeypads/cracker.mdl")
	self:SetModelScale(0.75, 0.0001)
	self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)

	self.m_iAnimationStage = 0
	self.m_fAnimationStart = CurTime()

	self:EmitSound("weapons/c4/c4_plant.wav", 75, 100, 0.5)

	if SERVER then
		self:SetUseType(SIMPLE_USE)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:AddGameFlag(FVPHYSICS_NO_PLAYER_PICKUP)
		end

		-- Retarded bug means I have to do this
		if not PickupSoundsPrecached then
			PickupSoundsPrecached = true
			for _, snd in ipairs(self.PickupSounds) do
				game.GetWorld():EmitSound(snd, 65, 100, 0)
			end
		end
	else
		self.m_eDeployedCracker = self

		if IsValid(self:GetDeployedBy()) and self:GetDeployedBy() == LocalPlayer() then
			self:OnDeployedBySet(nil, nil, self:GetDeployedBy())
		end

		if self:GetNetworkedAnimationStart() ~= 0 then
			self:NetworkedAnimationStart(nil, nil, self:GetNetworkedAnimationStart())
		end
		if self:GetNetworkedAnimationStage() ~= 0 then
			self:NetworkedAnimationStage(nil, nil, self:GetNetworkedAnimationStage())
		end
	end
end

function ENT:SetupDataTables()
	self.m_bSetupDataTables = true
	
	self:NetworkVar("Entity", 0, "Keypad")
	self:NetworkVar("Entity", 1, "DeployedBy")

	self:NetworkVar("Int", 0, "NetworkedAnimationStage")

	self:NetworkVar("Float", 0, "NetworkedAnimationStart")
	self:NetworkVar("Float", 1, "CrackCompleteTime")

	self:NetworkVar("Bool", 0, "Consumed")
	self:NetworkVar("Bool", 1, "Cracking")
	self:NetworkVar("Bool", 2, "Destroyed")
	self:NetworkVar("Bool", 3, "SpecialCrackTime")

	self:NetworkVarNotify("Consumed", self.OnConsumed)
	self:NetworkVarNotify("Keypad", self.OnKeypadSet)
	if CLIENT then
		self:NetworkVarNotify("NetworkedAnimationStage", self.NetworkedAnimationStage)
		self:NetworkVarNotify("NetworkedAnimationStart", self.NetworkedAnimationStart)
		self:NetworkVarNotify("DeployedBy", self.OnDeployedBySet)
	end
end

function ENT:OnKeypadSet(_, oldKeypad, newKeypad)
	if IsValid(oldKeypad) then
		oldKeypad.m_eDeployedCracker = nil
	end
	if IsValid(newKeypad) then
		newKeypad.m_eDeployedCracker = self
	end
end

function ENT:SkipToAnimationStage(stage)
	self.m_iAnimationStage = stage
	self:NextAnimation(true)
end

function ENT:OnAnimationStageChanged()
	if SERVER then
		self:SetNetworkedAnimationStage(self.m_iAnimationStage)
		self:SetNetworkedAnimationStart(self.m_fAnimationStart)
	end

	if CLIENT then
		if self.m_iAnimationStage == self.ANIM.FINISHED then
			if IsValid(self.m_eCrackingKeypad) then
				local fx = EffectData()
				fx:SetEntity(self.m_eCrackingKeypad)
				util.Effect("bkeypads_panel_attach", fx)

				self.m_eCrackingKeypad.m_bPlayTVAnimation = true
			end

			self:CleanUp()
			self.Think = nil

			return
		end
		
		if self.m_iAnimationStage == self.ANIM.CLOSE_PANEL then
			
			if IsValid(self.m_eCrackingKeypad) then
				self.m_eCrackingKeypad:EmitSound("npc/roller/mine/rmine_blip3.wav", 60)
			end

		elseif self.m_iAnimationStage == self.ANIM.POP_IN_PANEL then

			if IsValid(self.m_eCrackingKeypad) then
				self.m_eCrackingKeypad:EmitSound("ambient/machines/pneumatic_drill_4.wav", 60, 150, 0.5)
			end
			
		end
	else
		if self.m_iAnimationStage == self.ANIM.POP_OFF_CRACKER then

			--[[if GetConVar("developer"):GetInt() > 0 then
				print("Here's why the fuck we're popping off rn")
				print("self.m_bIsWeapon", self.m_bIsWeapon)
				print("self:GetCracking()", self:GetCracking())
				print("self:GetCrackCompleteTime()", self:GetCrackCompleteTime())
				print("CurTime()", CurTime())
				print("CurTime() > self:GetCrackCompleteTime()", CurTime() > self:GetCrackCompleteTime())
				print("self:GetKeypad()", self:GetKeypad())
				print("IsValid(self:GetKeypad())", IsValid(self:GetKeypad()))
				print("IsValid(self:GetKeypad()) and self:GetKeypad().bKeypad", IsValid(self:GetKeypad()) and self:GetKeypad().bKeypad)
				print("FINALLY", self.AnimationStages[self.ANIM.CRACKING].Duration(self))
			end]]

			if self.m_tCrackingSound then
				self:StopSound(self.m_tCrackingSound.path)
			end

			local keypad = self:GetKeypad()
			if IsValid(keypad) then
				local success = not self:GetDestroyed() and bKeypads.Cracker:CrackComplete(self, keypad, self:GetDeployedBy())
				if success then
					self:EmitSound(bKeypads.Cracker.Sounds["success"].path)
				else
					self:EmitSound(bKeypads.Cracker.Sounds["critical"].path)
				end
				keypad.m_eDeployedCracker = nil
			end

			self:BecomeWeapon(keypad, true)

		end
	end
end

function ENT:NextAnimation(skipped)
	if not skipped then
		if self.m_iAnimationStage >= self.ANIM.FINISHED then return end
		self.m_iAnimationStage = self.m_iAnimationStage + 1
		self.m_fAnimationStart = CurTime()
	end
	self:OnAnimationStageChanged()
end
function ENT:Think()
	if SERVER and self.AnimationStages[self.m_iAnimationStage] then
		local duration = self.AnimationStages[self.m_iAnimationStage].Duration
		local nextStage = false
		if isfunction(duration) then
			if duration(self) then
				nextStage = true
			end
		elseif CurTime() >= self.m_fAnimationStart + duration then
			nextStage = true
		end
		if nextStage then
			self:NextAnimation()
			return
		end
	end

	local keypad = self:GetKeypad()
	if CLIENT then

		self:CrackingSoundThink()

		if self.m_iAnimationStage == self.ANIM.FINISHED then return end

		if IsValid(keypad) and not self.m_bPreventPopOff then
			keypad:ShowInternals(true)
			if not IsValid(self.m_ePoppedOffKeypad) then
				self:PopOffKeypad(keypad)
			end
		end

		self:CableThink()

	elseif self.m_iAnimationStage == self.ANIM.FINISHED then
		if self:GetDestroyed() or (self.m_fExpiryTime and CurTime() > self.m_fExpiryTime) then
			self:DoDestroy()
		elseif self:GetConsumed() then
			self:Remove()
		end
	end
end

function ENT:OnConsumed(_, __, consumed)
	if not consumed then return end
	
	if IsValid(self:GetKeypad()) then
		self:GetKeypad().m_eDeployedCracker = nil
	end

	if self.m_iAnimationStage < self.ANIM.CLOSE_PANEL then
		self.m_iAnimationStage = self.ANIM.CLOSE_PANEL - 1
		self:NextAnimation()

		self:EmitSound(bKeypads.Cracker.Sounds["error"].path)
	end
end