AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:PlantOnKeypad(keypad, wep)
	local ply = IsValid(wep) and wep:GetOwner() or NULL

	keypad.m_eDeployedCracker = self

	local ang = keypad:GetAngles()
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Forward(), 180)
	ang:RotateAroundAxis(ang:Up(), 45)

	local pos = keypad:WorldSpaceCenter()
	pos = pos - (keypad:GetUp() * .5)
	pos = pos + (keypad:GetForward() * .1)
	pos = pos + (keypad:GetRight() * .4)

	self:SetPos(pos)
	self:SetAngles(ang)
	self:SetKeypad(keypad)

	if IsValid(ply) then
		self:SetDeployedBy(ply)
	end

	local crackTime, specialCrackTime = bKeypads.Cracker:GetCrackTime(ply, keypad)
	self:SetCrackCompleteTime(CurTime() + crackTime)
	self:SetSpecialCrackTime(bKeypads.Cracker.Config.SpecialSunglasses and specialCrackTime)

	self:SetCracking(true)

	self.m_eWeld = constraint.Weld(keypad, self, 0, 0, 0, true, false)
	keypad:CallOnRemove("bKeypads.KeypadCrackerPlant", function()
		if not IsValid(self) then return end
		self:BecomeWeapon(self:GetKeypad())
		self:EmitSound(bKeypads.Cracker.Sounds["critical"].path)
	end)

	if bKeypads.Cracker.Config.Damage.Enable then
		self:SetMaxHealth(bKeypads.Cracker.Config.Damage.Health)
		self:SetHealth(self:GetMaxHealth())
	end

	hook.Run("bKeypads.Cracker.Start", self, keypad, ply)
	if IsValid(ply) then bKeypads.Cracker:RegisterDeployed(ply, self) end
end

function ENT:CanPickup(ply)
	return bKeypads.Cracker.Config.AnyoneCanPickup or self:GetDeployedBy() == ply or (bKeypads.Cracker.Config.LoadoutCanPickup and ply.bKeypads_SpawnsWithCracker) or bKeypads.Permissions:Check(ply, "keypad_cracker/pick_up")
end

function ENT:CanCancelCrack(ply)
	return bKeypads.Cracker.Config.AnyoneCanStopCracker or bKeypads.Permissions:Check(ply, "keypad_cracker/remove")
end

function ENT:Use(ply)
	if not IsValid(ply) or not ply:IsPlayer() or self:GetDestroyed() then return end

	if self.m_bIsWeapon or self:GetDeployedBy() == ply then
		if not self:CanPickup(ply) then return end
		if self:GetConsumed() then return end

		if IsValid(self.m_eWeld) then self.m_eWeld:Remove() end

		EmitSound(self.PickupSounds[math.random(1,6)], self:WorldSpaceCenter(), self:EntIndex())

		if self.m_iAnimationStage == self.ANIM.FINISHED then
			self:Remove()
		else
			self:Abort()
			self:SetConsumed(true)
			self:PhysicsDestroy()
			self:SetSolid(SOLID_NONE)
			self:SetMoveType(MOVETYPE_NONE)
			self:SetSolidFlags(FSOLID_NOT_SOLID)
			self:SetNoDraw(true)
		end

		ply:Give("bkeypads_cracker")

	elseif self:CanCancelCrack(ply) then
		self:BecomeWeapon()
	end
end

function ENT:BecomeWeapon(keypad, crackFinished)
	if self.m_bIsWeapon then return end

	self.m_bIsWeapon = true
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:ClearGameFlag(FVPHYSICS_NO_PLAYER_PICKUP)
	end

	if IsValid(self.m_eWeld) then self.m_eWeld:Remove() end

	self:SetKeypad(nil)
	if IsValid(keypad) then
		keypad:RemoveCallOnRemove("bKeypads.KeypadCrackerPlant")
		keypad.m_eDeployedCracker = nil
	end

	if IsValid(self:GetDeployedBy()) then bKeypads.Cracker:RegisterDropped(self:GetDeployedBy(), self) end

	if self:GetConsumed() or not IsValid(keypad) then return end
	timer.Simple(0, function()
		if not IsValid(self) or self:GetConsumed() then return end

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:ApplyForceCenter(self:GetUp() * math.random(40, 60))
			phys:ApplyForceCenter(self:GetRight() * 30)
		end
	end)

	if not crackFinished then
		self:Abort()
	elseif bKeypads.Cracker.Config.DestroyCrackersWhenFinished then
		self:Destroy()
		return
	end

	if bKeypads.Cracker.Config.DroppedKeypadCrackerTimeout and bKeypads.Cracker.Config.DroppedKeypadCrackerTimeout > 0 then
		self.m_fExpiryTime = CurTime() + bKeypads.Cracker.Config.DroppedKeypadCrackerTimeout
	end
end

local wallCheckResults = {}
local wallCheck = { mask = MASK_SHOT, output = wallCheckResults }
function ENT:CanTakeDamage(dmginfo)
	-- https://github.com/FPtje/DarkRP/issues/3070
	if not self.m_bIsWeapon and DarkRP and IsValid(dmginfo:GetInflictor()) and dmginfo:GetInflictor():IsWeapon() and dmginfo:GetInflictor():GetClass() == "stunstick" then return false end

	if bKeypads.Cracker.Settings.DamageTypeWhitelist and bit.band(bKeypads.Cracker.Settings.DamageTypeWhitelist, dmginfo:GetDamageType()) == 0 then
		return false
	end
	if bKeypads.Cracker.Settings.DamageTypeBlacklist and bit.band(bKeypads.Cracker.Settings.DamageTypeBlacklist, dmginfo:GetDamageType()) ~= 0 then
		return false
	end
	if not bKeypads.Cracker.Config.Damage.DamageThroughWalls and dmginfo:IsBulletDamage() and IsValid(dmginfo:GetAttacker()) then
		local attacker = dmginfo:GetAttacker()
		wallCheck.start = (attacker.GetShootPos and attacker:GetShootPos()) or (attacker.EyePos and attacker:EyePos()) or (attacker.GetPos and attacker:GetPos()) if not wallCheck.start then return end
		wallCheck.endpos = dmginfo:GetDamagePosition()
		wallCheck.filter = { attacker, dmginfo:GetInflictor() }
		util.TraceLine(wallCheck)

		if wallCheckResults.Fraction ~= 1 and (not wallCheckResults.Hit or wallCheckResults.Entity ~= self) then
			return false
		end
	end
	return true
end
function ENT:OnTakeDamage(dmginfo)
	if not bKeypads.Cracker.Config.Damage.Enable then return end
	if not self:CanTakeDamage(dmginfo) then return end

	if bKeypads.Cracker.Config.Damage.CanDestroyDropped or IsValid(self:GetKeypad()) then
		self:SetHealth(math.max(self:Health() - dmginfo:GetDamage() - dmginfo:GetDamageBonus(), 0))

		if self:Health() <= 0 then
			if bKeypads.Cracker.Config.Damage.Destroy then
				self:Destroy()
			else
				self:BecomeWeapon()
				self:EmitSound(bKeypads.Cracker.Sounds["critical"].path)
			end
		end
	end

	if not IsValid(self:GetKeypad()) and bKeypads.Cracker.Config.Damage.DamageForce then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:ApplyForceCenter(dmginfo:GetDamageForce() * .5)
		end
	end
end

function ENT:SeizeReward(ply, dmg)
	if bKeypads.Cracker.Config.StunstickDestroys then
		self:Destroy()
	else
		self:BecomeWeapon()
		self:EmitSound(bKeypads.Cracker.Sounds["critical"].path)
	end
	return isnumber(bKeypads.Cracker.Config.SeizeReward) and bKeypads.Cracker.Config.SeizeReward or 1
end

function ENT:Destroy(forceDestroy)
	if self:GetDestroyed() then return end

	local ply = self:GetDeployedBy()
	if IsValid(ply) then
		bKeypads.Cracker:Forget(ply, self)
		if not forceDestroy and bKeypads.Cracker.Config.ReplaceDestroyedCrackers and ply:Alive() and not ply:HasWeapon("bkeypads_cracker") then
			ply:Give("bkeypads_cracker")
		end
	end

	self:SetDestroyed(true)

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableCollisions(false)
	end

	if IsValid(self.m_eWeld) then
		self.m_eWeld:Remove()
	end

	if self.m_iAnimationStage < self.ANIM.POP_OFF_CRACKER then
		self:SkipToAnimationStage(self.ANIM.POP_OFF_CRACKER)
	end
end

if IsValid(bKeypads_Dissolver) then bKeypads_Dissolver:Remove() end
function ENT:DoDestroy()
	if self.m_bDestroying then return end
	self.m_bDestroying = true

	self:BecomeWeapon(self:GetKeypad())

	self:EmitSound("weapons/physcannon/energy_disintegrate5.wav")
	self:EmitSound(bKeypads.Cracker.Sounds["critical"].path)

	self:SetName("bKeypads_DissolveMe")

	if not IsValid(bKeypads_Dissolver) then
		bKeypads_Dissolver = ents.Create("env_entity_dissolver")
		bKeypads_Dissolver:SetKeyValue("target", "bKeypads_DissolveMe")
		bKeypads_Dissolver:SetKeyValue("magnitude", 250)
		bKeypads_Dissolver:SetKeyValue("dissolvetype", 0)
	end

	bKeypads_Dissolver:SetKeyValue("target", self:GetName())
	bKeypads_Dissolver:Fire("Dissolve")

	self:OnRemove()
end

function ENT:Abort()
	if self.m_iAnimationStage == self.ANIM.CRACKING and not self.m_bAborted then
		hook.Run("bKeypads.Cracker.Abort", self, self:GetKeypad(), self:GetDeployedBy())
	end
	if IsValid(self:GetKeypad()) then
		self:GetKeypad():RemoveCallOnRemove("bKeypads.KeypadCrackerPlant")
		self:GetKeypad().m_eDeployedCracker = nil
	end

	self.m_bAborted = true
end

function ENT:OnRemove()
	if IsValid(self:GetDeployedBy()) then bKeypads.Cracker:Forget(self:GetDeployedBy(), self) end
	self:Abort()
end