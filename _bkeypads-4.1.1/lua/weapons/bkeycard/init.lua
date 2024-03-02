AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

hook.Add("canDropWeapon", "bKeypads.DarkRP.canDropWeapon", function(ply, wep)
	if not bKeypads.Config.Keycards.CanDropKeycard and wep:GetClass() == "bkeycard" then
		return false
	end
end)

hook.Add("onDarkRPWeaponDropped", "bKeypads.DarkRP.KeycardDropped.PhysFix", function(ply, ent, wep)
	if wep:GetClass() == "bkeycard" then
		timer.Simple(0, function()
			ent:SetModel(bKeypads.MODEL.KEYCARD)
			ent:PhysicsInitBox(ent:OBBMins(), ent:OBBMaxs())
			ent:SetMoveType(MOVETYPE_VPHYSICS)
			ent:SetSolid(SOLID_BBOX)

			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:Wake()
				phys:SetMass(0.05)
			end
		end)
	end
end)

function SWEP:Holster()
	self:SetIdentifying(false)
	timer.Remove("bKeypads.KeycardIdentify:" .. self:GetCreationID())

	return true
end

function SWEP:SecondaryAttack()
	if CLIENT and not IsFirstTimePredicted() then return false end
	if self:GetBeingScanned() then return false end
	if not bKeypads.Config.Keycards.ShowID.AllowIndentification then return false end

	self:SetNextSecondaryFire(CurTime() + bKeypads.Config.Keycards.ShowID.Time + bKeypads.Config.Keycards.ShowID.Cooldown)

	self:SetIdentifying(true)
	timer.Create("bKeypads.KeycardIdentify:" .. self:GetCreationID(), bKeypads.Config.Keycards.ShowID.Time, 1, function()
		if IsValid(self) and self.SetIdentifying then
			self:SetIdentifying(false)
		end
	end)

	hook.Run("bKeypads.Keycard.Identified", self:GetOwner(), self)

	return true
end

function SWEP:ScanInKeypad(keypadTarget)
	if self:GetBeingScanned() then return false end

	local ply = self:GetOwner()
	if not IsValid(ply) or not ply:Alive() then return false end

	local tr = ply:GetEyeTrace()

	local ent = tr.Entity
	if not IsValid(ent) then return false end

	local keypad
	if ent.bKeypad then
		keypad = ent
	else
		local redirect = bKeypads.MapLinking.RedirectUse(ply, ent)
		if redirect then
			keypad = redirect
		end
	end

	if not keypad or keypadTarget ~= nil and keypad ~= keypadTarget then return false end

	if keypad:GetBroken() or keypad:GetScanningStatus() ~= bKeypads.SCANNING_STATUS.IDLE or keypad:LinkProxy():GetAuthMode() ~= bKeypads.AUTH_MODE.KEYCARD then return false end
	if ply:EyePos():DistToSqr(keypad:GetPos()) > bKeypads.Config.Scanning.MaxDistance then return false end

	if bKeypads.Config.Payments.Prompt ~= false and keypadTarget == nil and keypad:PlayerRequiresPayment(ply) then
		net.Start("bKeypads.PaymentPrompt")
			net.WriteEntity(keypad)
			net.WriteUInt(keypad:GetSafePaymentAmount(), 32)
			net.WriteBool(false)
		net.Send(ply)
	else
		keypad:SetScanning(ply)
		self:SetBeingScanned(true)

		self:SetIdentifying(false)
		timer.Remove("bKeypads.KeycardIdentify:" .. self:GetCreationID())
	end

	return true
end

function SWEP:PrimaryAttack()
	if CLIENT and not IsFirstTimePredicted() then return false end
	return self:ScanInKeypad()
end

function SWEP:OnRemove()
	timer.Remove("bKeypads.KeycardIdentify:" .. self:GetCreationID())
end

function SWEP:GetLevelTables()
	self:CacheKeycardLevels()
	return self.CachedKeycardLevels, self.CachedKeycardLevelsDict
end