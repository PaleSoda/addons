ENT.Type = "anim"
ENT.Base = "bkeypads_networkvarpostnotify"

ENT.PrintName = "#bKeypads_Keypad"
ENT.Author = "Billy"

ENT.Spawnable = false

ENT.DisableDuplicator = true

ENT.RenderGroup = RENDERGROUP_BOTH -- FIXME RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self.bKeypad = true
	if not bKeypads.KeypadsRegistry[self] then
		bKeypads.KeypadsRegistry[self] = true
		table.insert(bKeypads.Keypads, self)
	end

	if SERVER then
		self:ServerInitialize()
	else
		self:ClientInitialize()
	end

	hook.Run("bKeypads.KeypadCreated", self)
end

function ENT:OnRemove()
	if SERVER then
		self:ServerOnRemove()
	else
		self:ClientOnRemove()
	end

	hook.Run("bKeypads.KeypadRemoved", self)
end

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "KeypadName")
	self:NetworkVar("String", 1, "ImageURL")

	self:NetworkVar("Int", 0, "BackgroundColor")

	self:NetworkVar("Int", 1, "ScanningStatus")
	self:NetworkVar("Int", 2, "AuthMode")

	self:NetworkVar("Int", 3, "PINDigitsInput")

	self:NetworkVar("Int", 4, "GrantedKey")
	self:NetworkVar("Int", 5, "GrantedRepeats")

	self:NetworkVar("Int", 6, "DeniedKey")
	self:NetworkVar("Int", 7, "DeniedRepeats")

	self:NetworkVar("Float", 0, "PaymentAmount")

	self:NetworkVar("Float", 1, "GrantedTime")
	self:NetworkVar("Float", 2, "GrantedDelay")
	self:NetworkVar("Float", 3, "GrantedRepeatDelay")

	self:NetworkVar("Float", 4, "DeniedTime")
	self:NetworkVar("Float", 5, "DeniedDelay")
	self:NetworkVar("Float", 6, "DeniedRepeatDelay")

	self:NetworkVar("Entity", 0, "ScanningEntity")
	self:NetworkVar("Entity", 1, "KeypadOwner")
	self:NetworkVar("Entity", 2, "ParentKeypad")

	self:NetworkVar("Bool", 0, "Broken")
	self:NetworkVar("Bool", 1, "Slanted")
	self:NetworkVar("Bool", 2, "Hacked")
	self:NetworkVar("Bool", 3, "Uncrackable")
	self:NetworkVar("Bool", 4, "IsLinked")
	self:NetworkVar("Bool", 5, "Persist")
	self:NetworkVar("Bool", 6, "GrantedNotifications")
	self:NetworkVar("Bool", 7, "DeniedNotifications")
	self:NetworkVar("Bool", 8, "Welded")
	self:NetworkVar("Bool", 9, "WiremodEnabled")
	self:NetworkVar("Bool", 10, "ChargeUnauthorized")

	self:NetworkVar("Bool", 11, "DestructionMode")
	self:NetworkVar("Float", 7, "Shield")

	self:NetworkVarPostNotify("ParentKeypad", self.OnKeypadLinked)

	self:NetworkVarPostNotify("AuthMode", self.AuthModeChanged)
	self:NetworkVarPostNotify("Broken", self.BrokenStatusChanged)
	self:NetworkVarPostNotify("Shield", self.OnShieldChanged)

	self:NetworkVarPostNotify("Uncrackable", self.KeypadCrackableChanged)
	self:NetworkVarPostNotify("IsLinked", self.KeypadCrackableChanged)

	if CLIENT then
		self:NetworkVarPostNotify("ScanningStatus", self.ScanningStatusChanged)
		self:NetworkVarPostNotify("BackgroundColor", self.BackgroundColorChanged)
	else
		self:NetworkVarPostNotify("Slanted", self.SlantedStatusChanged)
		self:NetworkVarPostNotify("DestructionMode", self.OnDestructionModeChanged)
	end
end

--## Linking ##--

function ENT:GetChildKeypads()
	return istable(bKeypads.KeypadLinking.Links[self]) and bKeypads.KeypadLinking.Links[self] or nil
end

function ENT:IsLinked()
	return IsValid(self:GetParentKeypad()) or self:GetChildKeypads()
end

function ENT:IsParentKeypad()
	return istable(bKeypads.KeypadLinking.Links[self])
end

function ENT:OnKeypadLinked()
	local parent = self:GetParentKeypad()
	if IsValid(parent) and bKeypads:IsKeypad(parent) then
		bKeypads.KeypadLinking.Links[self] = parent
		bKeypads.KeypadLinking.Links[parent] = bKeypads.KeypadLinking.Links[parent] or {}
		bKeypads.KeypadLinking.Links[parent][self] = true

		self:AuthModeChanged(nil, nil, parent:GetAuthMode())
	else
		local parent = bKeypads.KeypadLinking.Links[self]
		if IsValid(parent) then
			bKeypads.KeypadLinking.Links[self] = nil
			if bKeypads.KeypadLinking.Links[parent] then
				bKeypads.KeypadLinking.Links[parent][self] = nil
				if table.IsEmpty(bKeypads.KeypadLinking.Links[parent]) then
					bKeypads.KeypadLinking.Links[parent] = nil
				end
			end
		end
		bKeypads.KeypadLinking.Links[self] = nil

		self:AuthModeChanged(nil, nil, self:GetAuthMode())
	end

	if CLIENT then
		bKeypads.ESP:Refresh()
	end
end

function ENT:LinkProxy()
	local prnt = self:GetParentKeypad()
	if IsValid(prnt) and prnt.bKeypad then
		return prnt
	else
		return self
	end
end

--## Scanning ##--

function ENT:GetScanningPlayer()
	local ent = self:GetScanningEntity()
	if IsValid(ent) then
		if ent.bKeycard then
			return ent:GetOwner()
		elseif ent:IsPlayer() or ent:EntIndex() == -1 then
			return ent
		end
	end
	return NULL
end

--## Utility ##--

-- Fix for keypad breaking render angles
function ENT:_LocalToWorld(pos)
	if SERVER and self.HackedAngle then
		local ang = self:GetAngles()
		ang:RotateAroundAxis(self:GetRight(), -self.HackedAngle)
		ang:RotateAroundAxis(self:GetForward(), -self.HackedAngle)

		return LocalToWorld(pos, angle_zero, self:GetPos(), ang)
	else
		return LocalToWorld(pos, angle_zero, self:GetPos(), self:GetAngles())
	end
end

function ENT:ShowCamera(showCamera)
	if self:IsShowingInternals() then return end
	self:SetBodygroup(bKeypads.BODYGROUP.CAMERA, showCamera and 1 or 0)
end

function ENT:ShowTopLED(showTopLED)
	if self:IsShowingInternals() then return end
	self:SetBodygroup(bKeypads.BODYGROUP.LED_TOP, showTopLED and 1 or 0)
end

function ENT:ShowBottomLED(showBottomLED)
	if self:IsShowingInternals() then return end
	self:SetBodygroup(bKeypads.BODYGROUP.LED_BOTTOM, showBottomLED and 1 or 0)
end

function ENT:ShowKeycardSlot(showKeycardSlot)
	self:SetBodygroup(bKeypads.BODYGROUP.KEYCARD_SLOT, showKeycardSlot and 1 or 0)
end

function ENT:IsShowingInternals()
	return self:GetBodygroup(bKeypads.BODYGROUP.PANEL) == 1
end

function ENT:ShowInternals(showInternals)
	self:ShowCamera(not showInternals and self:LinkProxy():GetAuthMode() == bKeypads.BODYGROUP.CAMERA)
	if showInternals then
		self:SetBodygroup(bKeypads.BODYGROUP.LED_TOP, 0)
		self:SetBodygroup(bKeypads.BODYGROUP.LED_BOTTOM, 0)
		self:RemoveAllDecals()
	end
	self:SetBodygroup(bKeypads.BODYGROUP.PANEL, showInternals and 1 or 0)
	self:SetBodygroup(bKeypads.BODYGROUP.INTERNALS, showInternals and 1 or 0)
end

function ENT:RefreshBodygroups()
	local authMode = self:LinkProxy():GetAuthMode()
	self:ShowTopLED(authMode == bKeypads.AUTH_MODE.PIN)
	self:ShowCamera(authMode == bKeypads.AUTH_MODE.FACEID)
	self:ShowKeycardSlot(authMode == bKeypads.AUTH_MODE.KEYCARD)
	if authMode == bKeypads.AUTH_MODE.PIN then
		if CLIENT and (self:GetScanningStatus() == bKeypads.SCANNING_STATUS.IDLE or self:GetScanningStatus() == bKeypads.SCANNING_STATUS.LOADING) then
			self:SetLEDColor(false)
		end
	else
		self:ShowBottomLED(false)
	end
end

local cam_pos = Vector(0.58824694156647, 0.0051907757297158, 4.1580157279968)
function ENT:GetCamPos()
	return self:_LocalToWorld(cam_pos)
end

local beamSpriteTrace = {filter = {}, mask = MASK_OPAQUE_AND_NPCS}
function ENT:ScanningBeamLOS(ply)
	beamSpriteTrace.filter[1] = ply
	beamSpriteTrace.filter[2] = self
	beamSpriteTrace.start = SERVER and ply:EyePos() or EyePos()
	beamSpriteTrace.endpos = self:GetCamPos()
	return not util.TraceLine(beamSpriteTrace).Hit
end

function ENT:IsPlayerBehind(ply)
	return self:EntIndex() ~= -1 and (ply:EyePos() - self:_LocalToWorld(self:OBBCenter())):Angle():Forward():Dot(self:GetForward()) < 0
end

function ENT:IsPlayerFacing(ply)
	local worldCenter = self:_LocalToWorld(self:OBBCenter())
	local intersectKeypad = util.IntersectRayWithPlane(ply:EyePos(), ply:GetAimVector(), worldCenter, self:GetForward())
	return intersectKeypad and (intersectKeypad - worldCenter):LengthSqr() < 800
end

function ENT:CanFaceScan(ply)
	return
		not self:IsPlayerBehind(ply) and
		self:IsPlayerFacing(ply) and
		ply:EyePos():DistToSqr(self:_LocalToWorld(self:OBBCenter())) <= bKeypads.Config.Scanning.MaxDistance and
		self:ScanningBeamLOS(ply)
end

function ENT:CanKeycardScan(ply)
	return
		not self:IsPlayerBehind(ply) and
		ply:EyePos():DistToSqr(self:_LocalToWorld(self:OBBCenter())) <= bKeypads.Config.Scanning.MaxDistance and
		self:ScanningBeamLOS(ply)
end

function ENT:GetScanPingInterval()
	return math.min((1 / bKeypads.Config.Scanning.ScanTimes.FaceID) * 1.5, bKeypads.Config.Scanning.ScanTimes.FaceID)
end

--## Networking ##--

function ENT:KeypadCrackableChanged()
	self.IsKeypad = self:GetIsLinked() and not self:GetUncrackable() or nil -- hack for Keypad Cracker support
end

function ENT:AuthModeChanged(_, __, authMode)
	self:RefreshBodygroups()
	if CLIENT then
		self.GrantedDenied = nil
	end
end

--## Destruction ##--

function ENT:GetDestructible()
	if bKeypads.Config.KeypadDestruction.Enable then
		return not self:GetDestructionMode()
	else
		return self:GetDestructionMode()
	end
end

function ENT:GetMaxShield()
	if self.m_iMaxShield then
		if bKeypads.Config.KeypadDestruction.MaxShield == 0 then
			return math.max(self.m_iMaxShield, self:GetMaxHealth())
		else
			return math.min(math.max(self.m_iMaxShield, self:GetMaxHealth()), self:GetMaxHealth() * bKeypads.Config.KeypadDestruction.MaxShield)
		end
	else
		return 0
	end
end

function ENT:OnShieldChanged(_, __, m_iShield)
	if m_iShield == 0 then
		self.m_iMaxShield = nil
	else
		self.m_iMaxShield = math.max(self.m_iMaxShield or 0, m_iShield)
	end
end

-- WARNING: Extremely cursed code
-- Not for the faint of heart
-- Do not scroll down if you are using a pacemaker

if bKeypads.Config.ExperimentalKeypadCompatibility then
	local entMeta = FindMetaTable("Entity")
	bKeypads_GetClass = bKeypads_GetClass or entMeta.GetClass
	function entMeta:GetClass()
		if self.bKeypad then
			return "keypad"
		else
			return bKeypads_GetClass(self)
		end
	end
end

bKeypads_Initialize_Fix(ENT)