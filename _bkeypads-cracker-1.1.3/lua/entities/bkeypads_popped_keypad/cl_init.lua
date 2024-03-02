ENT.Type = "anim"
ENT.Base = "base_gmodentity"

function ENT:Initialize()
	self.bKeypadOff = true
	self:SetModel(bKeypads.MODEL.KEYPAD)
	self:SetBodygroup(bKeypads.BODYGROUP.KEYPAD, 1)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end

function ENT:RenderOverride(flags)
	self:DrawModel()
	self:RenderCable(flags)
end

function ENT:Think()
	local deployedCracker = self.m_eDeployedCracker
	if not IsValid(deployedCracker) then return end
	if not IsValid(deployedCracker.m_eCrackingKeypad) then
		self:Remove()
		return
	end
	
	if deployedCracker.m_iAnimationStage == deployedCracker.ANIM.CRACKING or
	   deployedCracker.m_iAnimationStage == deployedCracker.ANIM.OPEN_PANEL or
	   deployedCracker.m_iAnimationStage == deployedCracker.ANIM.CLOSE_PANEL then
		self:AnimatePanelSwing()
	elseif  deployedCracker.m_iAnimationStage == deployedCracker.ANIM.POP_IN_PANEL then
		self:AnimatePanelPopIn()
	end
end

function ENT:AnimatePanelSwing()
	local deployedCracker = self.m_eDeployedCracker
	
	local animDuration = deployedCracker.AnimationStages[
		deployedCracker.m_iAnimationStage == deployedCracker.ANIM.CRACKING and deployedCracker.ANIM.OPEN_PANEL or
		deployedCracker.ANIM.CLOSE_PANEL
	].Duration
	
	local f = math.Clamp(math.TimeFraction(deployedCracker.m_fAnimationStart, deployedCracker.m_fAnimationStart + animDuration, CurTime()), 0, 1)

	if self.m_iSwingAnimation ~= deployedCracker.m_iAnimationStage then
		self.m_fSwingAngleStart = self.m_fSwingAngle or 0
		self.m_iSwingAnimation = deployedCracker.m_iAnimationStage
	end
	if deployedCracker.m_iAnimationStage == deployedCracker.ANIM.CRACKING then
		f = bKeypads.ease.OutBack(f)
		self.m_fSwingAngle = bKeypads:LerpUnclamped(f, self.m_fSwingAngleStart, -100)
	elseif deployedCracker.m_iAnimationStage == deployedCracker.ANIM.CLOSE_PANEL then
		f = bKeypads.ease.OutCubic(f)
		self.m_fSwingAngle = Lerp(f, self.m_fSwingAngleStart, 0)
	else
		return
	end

	local ang = deployedCracker.m_eCrackingKeypad:GetAngles()
	ang:RotateAroundAxis(ang:Right(), self.m_fSwingAngle)
	self:SetAngles(ang)

	local pivot = self:OBBMins() * .95
	pivot.y = self:OBBCenter().y

	local pos = deployedCracker.m_eCrackingKeypad:LocalToWorld(pivot)
	pivot:Rotate(ang)
	pos = pos - pivot
	
	if deployedCracker.m_iAnimationStage == deployedCracker.ANIM.CLOSE_PANEL then
		pos = pos + (self:GetForward() * f)
	end

	self:SetPos(pos)
end

function ENT:AnimatePanelPopIn()
	local deployedCracker = self.m_eDeployedCracker
	
	self.m_aPopInAng = self.m_aPopInAng or self:GetAngles()
	self.m_vPopInPos = self.m_vPopInPos or self:GetPos()

	local popInAnimFrac = bKeypads.ease.OutQuint(math.Clamp(math.TimeFraction(deployedCracker.m_fAnimationStart + deployedCracker.AnimationStages[deployedCracker.ANIM.POP_IN_PANEL].Delay, deployedCracker.m_fAnimationStart + deployedCracker.AnimationStages[deployedCracker.ANIM.POP_IN_PANEL].Duration, CurTime()), 0, 1))
	self:SetPos(LerpVector(popInAnimFrac, self.m_vPopInPos, deployedCracker.m_eCrackingKeypad:GetPos()))
	self:SetAngles(LerpAngle(popInAnimFrac, self.m_aPopInAng, deployedCracker.m_eCrackingKeypad:GetAngles()))
end

bKeypads_Initialize_Fix(ENT)