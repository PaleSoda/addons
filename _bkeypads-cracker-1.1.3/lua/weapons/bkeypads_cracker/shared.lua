SWEP.PrintName    = "#bKeypads_KeypadCracker"
SWEP.Category     = "Billy's Keypads"
SWEP.Author       = "Billy"
SWEP.Instructions = "Left click to crack a keypad"

SWEP.UseHands = true

SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/cstrike/c_c4.mdl")
SWEP.WorldModel = Model("models/bkeypads/cracker.mdl")

SWEP.Primary.ClipSize    = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic   = false
SWEP.Primary.Ammo        = "none"

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

SWEP.Spawnable = true
SWEP.AutoSwitchTo = false

SWEP.PLANT = {}
SWEP.PLANT.CRACKING = -1
SWEP.PLANT.IDLE     = 0
SWEP.PLANT.PUNCH    = 1
SWEP.PLANT.DEPLOY   = 2
SWEP.PLANT.FINISH   = 3

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("bkeypads/keypad_cracker_selection")
	SWEP.BounceWeaponIcon = true
end

function SWEP:Initialize()
	self:SetModelScale(0.75)
	self:SetHoldType("slam")
	self:SetDeploySpeed(1)

	self.m_iPlantingStage = self.PLANT.IDLE
	
	if CLIENT then
		self:SetFace("default")
		self:SetScreenText(bKeypads.L"CrackerWaiting")
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Entity", 0, "CrackingKeypad")
	self:NetworkVar("Float", 0, "CrackCompleteTime")
	self:NetworkVar("Bool", 0, "SpecialCrackTime")
	self:NetworkVar("Bool", 1, "Cracking")

	self:NetworkVarNotify("Cracking", self.OnCrackingChanged)
	if CLIENT then
		self:NetworkVarNotify("CrackCompleteTime", self.OnCrackTimeDataReceived)
		self:NetworkVarNotify("CrackingKeypad", self.OnCrackingKeypadSet)
	end
end

function SWEP:CrackingSoundThink()
	if self.m_iPlantingStage ~= self.PLANT.CRACKING then
		self.m_iCrackingSound = nil
		if self.m_tCrackingSound then
			if self.m_fCrackingSoundEnd and CurTime() <= self.m_fCrackingSoundEnd then
				self.m_fCrackingSoundEnd = nil
				self:StopSound(self.m_tCrackingSound.path)
			end
			self.m_tCrackingSound = nil
		end
		if self.m_fNextBlip and CurTime() <= self.m_fNextBlip then
			self.m_fNextBlip = nil
			self:StopSound("buttons/blip2.wav")
		end
		return
	end
	
	if not self.m_fCrackingSoundEnd or CurTime() >= self.m_fCrackingSoundEnd then
		self.m_iCrackingSound = math.max(((self.m_iCrackingSound or 0) + 1) % (#bKeypads.Cracker.Sounds["typing"] + 1), 1)
		self.m_tCrackingSound = bKeypads.Cracker.Sounds["typing"][self.m_iCrackingSound]
		self.m_fCrackingSoundEnd = CurTime() + self.m_tCrackingSound.duration
		self:EmitSound(self.m_tCrackingSound.path, 75, 100, 1, CHAN_WEAPON)
	end

	if bKeypads.Cracker.Config.Beeps.Enable then
		local doBlip = self.m_fNextBlip ~= nil
		if not self.m_fNextBlip or CurTime() >= self.m_fNextBlip then
			self.m_fNextBlip = CurTime() + (bKeypads.Cracker.Config.Beeps.BeepInterval == 0 and 1 or bKeypads.Cracker.Config.Beeps.BeepInterval)
			if doBlip then
				self:EmitSound("buttons/blip2.wav", bKeypads.Cracker.Config.Beeps.BeepVolume, 100, 1, CHAN_WEAPON)
			end
		end
	end
end

function SWEP:PlaySound(name, volume)
	if not IsFirstTimePredicted() then return end
	local snd = bKeypads.Cracker.Sounds[name] and bKeypads.Cracker.Sounds[name].path or name
	if self.m_sPlayedSound ~= snd then
		if self.m_sPlayedSound then
			self:StopSound(self.m_sPlayedSound)
		end
		self.m_sPlayedSound = snd
		self:EmitSound(self.m_sPlayedSound, 75, 100, volume, CHAN_WEAPON)
	end
end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:PrimaryAttack()
	if not IsValid(self:GetOwner()) or not self:GetOwner():IsPlayer() then return false end

	self:SetNextPrimaryFire(CurTime() + 0.4)

	if not self:GetCracking() then
		if self:ComputeCanCrack() then
			if SERVER or IsFirstTimePredicted() then
				self:StartCracking()
			end
			return true
		elseif CLIENT and IsFirstTimePredicted() then
			self:CantCrack()
		end
	end

	return false
end

function SWEP:CancelCracking()
	local wasStartingCrack = self:GetCracking()
	local wasCracking = self:GetCrackCompleteTime() > 0
	
	if SERVER then
		self:SetCracking(false)
		self:SetCrackCompleteTime(0)
		self.m_bCrackingKeypadSet = nil
	else
		self.m_fCrackStart = nil
		self.m_fNextCrackingFace = nil
		self.CrackingFace = nil

		if self.BlockC4Typing then hook.Remove("EntityEmitSound", self.BlockC4Typing) end
	end

	self.m_iPlantingStage = self.PLANT.IDLE
	self.m_iPlantingNextStage = nil

	self:SendWeaponAnim(ACT_VM_IDLE)
	if self.m_sPlayedSound then self:StopSound(self.m_sPlayedSound) end
	if wasStartingCrack then
		if CLIENT then self.m_fErrorScreenEnd = CurTime() + 0.5 end

		timer.Simple(0, function()
			if not IsValid(self) then return end
			self:EmitSound(bKeypads.Cracker.Sounds["error"].path, 75, 100, .5, CHAN_WEAPON)
		end)

		if SERVER and wasCracking then
			hook.Run("bKeypads.Cracker.Abort", self, self:GetCrackingKeypad(), self:GetOwner())
		end
	end
	
	self.m_sPlayedSound = nil
	
	self:CrackingSoundThink()
end

function SWEP:StartCracking()
	if not IsValid(self.m_eTargetKeypad) then
		self:CancelCracking()
		return
	end
	if SERVER then
		self:SetCracking(true)
	end
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	if bKeypads.Cracker.Config.Deployed then
		self.m_iPlantingStage = self.PLANT.PUNCH
		self.m_iPlantingNextStage = CurTime() + 2.4
		self:PlaySound("whirr", .5)
	else
		if SERVER then
			self.m_iPlantingStage = self.PLANT.CRACKING
			self:SetCrackingKeypad(self.m_eTargetKeypad)
			self:SetCrackCompleteTime(CurTime() + bKeypads.Cracker:GetCrackTime(self:GetOwner(), self.m_eTargetKeypad))
			self.m_bCrackingKeypadSet = true
			self.m_iPlantingNextStage = self:GetCrackCompleteTime()
		else
			if self.m_iPlantingStage ~= self.PLANT.CRACKING then
				self.m_iPlantingStage = self.PLANT.CRACKING
				self.m_iPlantingNextStage = nil
			end

			-- HACK!
			-- Fixes c4 typing sound from overriding keypad cracker sounds
			local ply = self:GetOwner()
			local sequenceStarted = false
			local seq = self:LookupSequence("pressbutton")
			self.BlockC4Typing = "bKeypads.BlockC4Typing:" .. string.format("%p", self)
			hook.Add("EntityEmitSound", self.BlockC4Typing, function(snd)
				if IsValid(self) and self:GetOwner() == ply then
					if snd.OriginalSoundName == "c4.click" and snd.Entity == ply then
						sequenceStarted = true
						snd.Channel = CHAN_AUTO
						return true
					elseif not sequenceStarted or self:GetSequence() == seq then
						return
					end
				end

				hook.Remove("EntityEmitSound", self.BlockC4Typing)
			end)
		end
		self:PlaySound("charge", .5)
	end
end

function SWEP:StartPlanting()
	self.m_iPlantingStage = self.PLANT.DEPLOY
	self.m_iPlantingNextStage = CurTime() + .7

	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self:PlaySound("charge", .5)
end

function SWEP:FinishPlanting()
	self.m_iPlantingStage = self.PLANT.FINISH
	
	if IsValid(self.m_eTargetKeypad) and self.m_eTargetKeypad.bKeypad then
		if CLIENT then return end

		local deployedCracker = ents.Create("bkeypads_deployed_cracker")
		deployedCracker:Spawn()
		deployedCracker:Activate()
		deployedCracker:PlantOnKeypad(self.m_eTargetKeypad, self)

		self.Think = nil

		local ply = self:GetOwner()
		if IsValid(ply) and ply:IsPlayer() then
			ply:StripWeapon("bkeypads_cracker")

			if self.m_OldWeapon then
				local wep = ply:GetWeapon(self.m_OldWeapon)
				if IsValid(wep) then
					ply:SelectWeapon(self.m_OldWeapon)
					return
				end
			end
			
			ply:SwitchToDefaultWeapon()
			return
		else
			self:Remove()
		end
	else
		self:CancelCracking()
	end
end

function SWEP:FinishCracking()
	self:ComputeCanCrack()

	if IsValid(self:GetCrackingKeypad()) and IsValid(self:GetOwner()) and self:GetOwner():GetEyeTrace().Entity == self:GetCrackingKeypad() then
		self:SendWeaponAnim(ACT_VM_IDLE)

		if SERVER then
			if bKeypads.Cracker:CrackComplete(self, self:GetCrackingKeypad(), self:GetOwner()) then
				self:CrackingSucceeded()
				
				hook.Run("bKeypads.Cracker.Succeeded", self, self:GetCrackingKeypad(), self:GetOwner())
			else
				self:CrackingFailed()
				
				hook.Run("bKeypads.Cracker.Failed", self, self:GetCrackingKeypad(), self:GetOwner())
			end
			self:SetCracking(false)

			self:HideCrackingScreen()
		end
	else
		self:CancelCracking()
	end
end

function SWEP:HideCrackingScreen()
	if CLIENT then
		self.m_fCrackStart = nil
		self.m_fNextCrackingFace = nil
		self.CrackingFace = nil
	end
	
	self.m_iPlantingStage = self.PLANT.IDLE
end
function SWEP:CrackingSucceeded()
	self:EmitSound(bKeypads.Cracker.Sounds["success"].path, 75, 100, 1, CHAN_WEAPON)
	if CLIENT then
		self.m_fSuccessScreenEnd = CurTime() + 3
		self:Emote("happy", 3, "#bKeypads_CrackSuccess")
		self:HideCrackingScreen()
	else
		self:CallOnClient("CrackingSucceeded")
	end
end
function SWEP:CrackingFailed()
	self:EmitSound(bKeypads.Cracker.Sounds["critical"].path, 75, 100, 1, CHAN_WEAPON)
	if CLIENT then
		self.m_fErrorScreenEnd = CurTime() + 3
		self:Emote("sad", 3, "#bKeypads_CrackFailed")
		self:HideCrackingScreen()
	else
		self:CallOnClient("CrackingFailed")
	end
end

function SWEP:Think()
	if SERVER then
		local targetKeypad = self.m_eTargetKeypad
		self:ComputeCanCrack()
		if bKeypads.Cracker.Config.SpecialSunglasses and targetKeypad ~= self.m_eTargetKeypad then
			self:SetSpecialCrackTime(select(2, bKeypads.Cracker:GetCrackTime(self:GetOwner(), self.m_eTargetKeypad)))
		end
	else
		self:ComputeCanCrack()
	end

	if CLIENT then self:ClientThink() end
	
	if self.m_iPlantingStage ~= self.PLANT.IDLE and (
		not self.m_bIsWithinDist or
		not IsValid(self:GetOwner()) or not IsValid(self:GetOwner():GetEyeTrace().Entity) or
		(self.m_iPlantingStage == self.PLANT.CRACKING and self.m_bCrackingKeypadSet and (not IsValid(self:GetCrackingKeypad()) or self:GetCrackingKeypad() ~= self:GetOwner():GetEyeTrace().Entity))
	) then
		self:CancelCracking()
		return
	end

	if not bKeypads.Cracker.Config.Deployed then self:CrackingSoundThink() end
	
	if self.m_iPlantingNextStage and CurTime() >= self.m_iPlantingNextStage then
		self.m_iPlantingNextStage = nil

		self.m_iPlantingStage = self.m_iPlantingStage + 1

		if self.m_iPlantingStage == self.PLANT.IDLE then
			self:FinishCracking()
		elseif self.m_iPlantingStage == self.PLANT.DEPLOY then
			self:StartPlanting()
		elseif self.m_iPlantingStage == self.PLANT.FINISH then
			self:FinishPlanting()
		end
	end

	if self:GetCracking() then
		self:SetHoldType("pistol")
	else
		self:SetHoldType("slam")
	end
end

do
	local CacheFrame
	function SWEP:ComputeCanCrack()
		if SERVER or FrameNumber() ~= CacheFrame then
			local ply = self:GetOwner()
			if not IsValid(ply) then
				self.m_bIsKeypad, self.m_bIsWithinDist, self.m_bCanCrack, self.m_eTargetKeypad = false, false, false, nil
			else
				local tr = ply:GetEyeTrace()
				self.m_bIsKeypad       = IsValid(tr.Entity) and tr.Entity.bKeypad == true
				self.m_bIsWithinDist   = self.m_bIsKeypad and tr.HitPos:DistToSqr(ply:GetShootPos()) <= bKeypads.Cracker.Settings.CrackDistance
				self.m_bNotUncrackable = self.m_bIsWithinDist and not tr.Entity:GetUncrackable()
				self.m_bIsLinked       = self.m_bNotUncrackable and tr.Entity:GetIsLinked()
				self.m_bCanCrack       = self.m_bIsLinked and tr.Entity.IsKeypad and not IsValid(tr.Entity.m_eDeployedCracker)
				self.m_eTargetKeypad   = self.m_bCanCrack and tr.Entity or nil
			end
			if CLIENT then
				CacheFrame = FrameNumber()
			end
		end

		return self.m_bCanCrack
	end
end

if SERVER then
	hook.Add("PlayerSwitchWeapon", "bKeypads.Cracker.PlayerSwitchWeapon", function(ply, oldWep, newWep)
		if IsValid(newWep) and IsValid(oldWep) then
			if newWep:GetClass() == "bkeypads_cracker" then
				newWep.m_eOldWeapon = oldWep:GetClass()
			elseif oldWep:GetClass() == "bkeypads_cracker" then
				oldWep.m_eOldWeapon = newWep:GetClass()
			end
		end
	end)
end

function SWEP:Deploy()
	self:CancelCracking()
	self:SendWeaponAnim(ACT_VM_DRAW)
	if CLIENT then
		self.m_tTVAnimation = nil
		self.m_sPlayedSound = nil
		self.m_bDeployed = nil
		self.m_bPlayHello = true
	elseif IsValid(self:GetOwner()) then
		self:SetSpecialCrackTime(select(2, bKeypads.Cracker:GetCrackTime(self:GetOwner(), NULL)))
	end
	return true
end

function SWEP:Holster()
	self.m_bIsKeypad, self.m_bIsWithinDist, self.m_bCanCrack, self.m_eTargetKeypad = false, false, false, nil
	self:CancelCracking()
	if self.BlockC4Typing then hook.Remove("EntityEmitSound", self.BlockC4Typing) end
	return true
end

if CLIENT then
	function SWEP:Deployed()
		self:Deploy()
	end
	function SWEP:Holstered()
		self:Holster()
	end
end
bKeypads_Prediction(SWEP)