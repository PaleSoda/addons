include("shared.lua")

function SWEP:SetFace(face)
	self.Face = bKeypads.Emotes[face]
end

function SWEP:SetScreenText(text)
	self.ScreenText = text
end

function SWEP:Emote(face, time, text)
	self.EmoteFace = bKeypads.Emotes[face]
	self.EmoteEnd = CurTime() + time
	self.EmoteText = text
end

local scale_3d2d = 0.005

local viewScreenPos = Vector(2.33, -1.7, 3.65)
local viewScreenW, viewScreenH = 810, 400

local worldScreenPos = Vector(-9.29, -3.75, 1.5)
local worldScreenW, worldScreenH = 670, 280

local faceSize = .6
local textSpacing = 24
local fontOffsetX = 9

function SWEP:DrawScreen(pos, ang, w, h, world)
	local isEmoting = self.EmoteEnd and CurTime() <= self.EmoteEnd
	
	local isMainView = render.GetRenderTarget() == nil

	cam.Start3D2D(pos, ang, scale_3d2d)
		if isMainView then bKeypads:TVAnimation(self, 0.15, w, h) end

		if self.m_iPlantingStage == self.PLANT.CRACKING then
			self:DrawCrackingScreen(w, h)
		else
			if self.m_fErrorScreenEnd and CurTime() < self.m_fErrorScreenEnd then
				surface.SetMaterial(bKeypads.Cracker.Materials.SCREEN_RED)
			elseif self.m_fSuccessScreenEnd and CurTime() < self.m_fSuccessScreenEnd then
				surface.SetMaterial(bKeypads.Cracker.Materials.SCREEN_GREEN)
			else
				surface.SetMaterial(bKeypads.Cracker.Materials.SCREEN_BLUE)
			end
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(0, 0, w, h)

			if self:GetCracking() or self.m_bCanCrack then
				self:DrawMatrix(w, h)
			end

			local ScreenText = isEmoting and self.EmoteText or self.ScreenText
		
			surface.SetFont("bKeypads.Cracker" .. (world and ".Small" or ""))
			surface.SetTextColor(bKeypads.COLOR.SLATE)
			local txtW, txtH = surface.GetTextSize(ScreenText)
			txtW = txtW - fontOffsetX

			local faceSize = h * faceSize
			local contentSize = faceSize + textSpacing + txtH
			local y = (h - contentSize) / 2

			surface.SetDrawColor(bKeypads.COLOR.SLATE)
			surface.SetMaterial(isEmoting and self.EmoteFace or self.Face)
			surface.DrawTexturedRect((w - faceSize) / 2, y, faceSize, faceSize)

			if bKeypads.Cracker.Config.SpecialSunglasses and self:GetSpecialCrackTime() then
				surface.SetMaterial(bKeypads.Sunglasses)
				surface.DrawTexturedRect((w - faceSize) / 2, y, faceSize, faceSize)
			end

			surface.SetTextPos((w - txtW) / 2, y + faceSize + textSpacing)
			surface.DrawText(ScreenText)
		end

		if isMainView then bKeypads:TVAnimation(self) end
	cam.End3D2D()
end

function SWEP:DrawCrackingScreen(w, h)
	if not self.m_fNextCrackingFace or CurTime() > self.m_fNextCrackingFace then
		self.m_fNextCrackingFace = CurTime() + math.Rand(0.5, 1)
		while true do
			local newFace = bKeypads.Emotes[bKeypads.Cracker.CrackingEmotes[math.random(1, #bKeypads.Cracker.CrackingEmotes)]]
			if #bKeypads.Emotes <= 1 or self.CrackingFace ~= newFace then
				self.CrackingFace = newFace
				break
			end
		end
	end

	self.m_fCrackStart = self.m_fCrackStart or CurTime()
	local crackProgress = bKeypads.ease.InOutSine(math.Clamp(math.TimeFraction(self.m_fCrackStart, self:GetCrackCompleteTime(), CurTime()), 0, 1))

	surface.SetMaterial(bKeypads.Cracker.Materials.SCREEN_RED)
	surface.SetDrawColor(255, 255, 255)
	surface.DrawTexturedRect(0, 0, w, h)

	surface.SetMaterial(bKeypads.Cracker.Materials.SCREEN_GREEN)
	surface.SetDrawColor(255, 255, 255, crackProgress * 255)
	surface.DrawTexturedRect(0, 0, w, h)

	self:DrawMatrix(w, h)

	surface.SetFont("bKeypads.Cracker" .. (world and ".Small" or ""))
	local txtW, txtH = surface.GetTextSize("CRACKING")
	txtW = txtW - fontOffsetX

	local faceSize = h * faceSize
	local contentSize = faceSize + textSpacing + txtH
	local y = (h - contentSize) / 2

	surface.SetDrawColor(bKeypads.COLOR.SLATE)
	surface.SetMaterial(self.CrackingFace or bKeypads.Emotes["default"])
	surface.DrawTexturedRect((w - faceSize) / 2, y, faceSize, faceSize)

	if bKeypads.Cracker.Config.SpecialSunglasses and self:GetSpecialCrackTime() then
		surface.SetMaterial(bKeypads.Sunglasses)
		surface.DrawTexturedRect((w - faceSize) / 2, y, faceSize, faceSize)
	end

	local paddingW = 175
	local x, y = paddingW / 2, y + faceSize + textSpacing
	local fullProgressW = w - paddingW
	local progressW = fullProgressW * crackProgress
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(x + progressW, y, fullProgressW - progressW, txtH)

	surface.SetDrawColor((1 - crackProgress) * 255, crackProgress * 255, 0, 100)
	surface.DrawRect(x, y, progressW, txtH)
end

function SWEP:PostDrawViewModel(vm)
	if not self.m_bDeployed or not IsValid(vm) then return end

	local bone = vm:LookupBone("v_weapon.c4")
	if not bone then return end

	local pos, ang = vm:GetBonePosition(bone)
	if not pos then return end
	
	ang:RotateAroundAxis(ang:Right(), 180)
	ang:RotateAroundAxis(ang:Forward(), -90)

	pos:Add(ang:Forward() * viewScreenPos.x)
	pos:Add(ang:Right() * viewScreenPos.y)
	pos:Add(ang:Up() * viewScreenPos.z)

	self:DrawScreen(pos, ang, viewScreenW, viewScreenH)
end

function SWEP:PreDrawViewModel(vm)
	if not self.m_bDeployed or not IsValid(vm) or self.m_iPlantingStage ~= self.PLANT.CRACKING or not IsValid(self:GetCrackingKeypad()) then return end

	local bone = vm:LookupBone("v_weapon.c4")
	if not bone then return end

	local pos, ang = vm:GetBonePosition(bone)
	if not pos then return end

	pos:Add(ang:Forward() * -viewScreenPos.x)
	pos:Add(ang:Right() * -viewScreenPos.y)
	pos:Add(ang:Up() * -viewScreenPos.z)

	self:DrawCable(pos, true)
end

do
	local forward = Vector(worldScreenPos.x, worldScreenPos.x, worldScreenPos.x)
	local right = Vector(worldScreenPos.y, worldScreenPos.y, worldScreenPos.y)
	local up = Vector(worldScreenPos.z, worldScreenPos.z, worldScreenPos.z)
	function SWEP:DrawWorldModel(flags)
		self:DrawModel(flags)

		if not IsValid(self:GetOwner()) or bKeypads.Performance:Optimizing() then return end

		local bone = self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand")
		if not bone then return end

		local pos, ang = self:GetOwner():GetBonePosition(bone)
		if not pos or not ang then return end

		ang:RotateAroundAxis(ang:Up(), -248)
		ang:RotateAroundAxis(ang:Right(), -10)
		ang:RotateAroundAxis(ang:Forward(), -120)

		pos:Add(ang:Up() * up)
		pos:Add(ang:Right() * right)
		pos:Add(ang:Forward() * forward)

		self:DrawCable(pos)
		self:DrawScreen(pos, ang, worldScreenW, worldScreenH, true)
	end
end

do
	local matCable = Material("cable/cable2")
	function SWEP:DrawCable(origin, vm)
		if self.m_iPlantingStage ~= self.PLANT.CRACKING then return end

		local keypad = self:GetCrackingKeypad()
		if not IsValid(keypad) then return end

		if bKeypads.Performance:Optimizing() then return end

		local pos = keypad:OBBCenter()
		pos.z = pos.z - keypad:OBBMaxs().z

		local seg1 = origin
		local seg4 = keypad:LocalToWorld(pos)

		local seg2
		local seg3

		local cableDir = seg1 - seg4
		local cableLength = cableDir:Length()
		local cableAngle = cableDir:Angle():Forward()
		
		for i = 1, 2 do
			local cableFrac = i * (1 / 3)
			local cablePoint = origin - (cableAngle * cableLength * cableFrac)
			cablePoint.z = cablePoint.z - (math.abs(cablePoint.z - seg4.z) * cableFrac)
			if i == 1 then
				seg2 = cablePoint
			else
				seg3 = cablePoint
			end
		end

		render.SetMaterial(matCable)
		render.StartBeam(4)
			if vm then
				render.AddBeam(bKeypads:TranslateViewModelPosition(self.ViewModelFOV or 62, seg1), 0.5, 0, color_white)
				render.AddBeam(bKeypads:TranslateViewModelPosition(self.ViewModelFOV or 62, seg2), 0.5, 0, color_white)
				render.AddBeam(bKeypads:TranslateViewModelPosition(self.ViewModelFOV or 62, seg3), 0.5, 0, color_white)
				render.AddBeam(bKeypads:TranslateViewModelPosition(self.ViewModelFOV or 62, seg4), 0.5, 0, color_white)
			else
				render.AddBeam(seg1, 0.5, 0, color_white)
				render.AddBeam(seg2, 0.5, 0, color_white)
				render.AddBeam(seg3, 0.5, 0, color_white)
				render.AddBeam(seg4, 0.5, 0, color_white)
			end
		render.EndBeam()

		if vm then render.ClearDepth() end
	end
end

function SWEP:ClientThink()
	if self.m_bPlayHello then
		self:PlaySound("hello", .25)
		self.m_bPlayHello = nil

		self.m_bDeployed = true
	end

	if self.m_iPlantingStage > self.PLANT.IDLE then
		if bKeypads.Cracker.Config.Deployed and not self.m_CrackingText then
			self.m_CrackingText = bKeypads.Cracker:GetCrackingPhrase()
			self:SetFace("happy")
			self:SetScreenText(self.m_CrackingText)
		end
	elseif self.m_iPlantingStage ~= self.PLANT.CRACKING and (not self.m_fSuccessScreenEnd or CurTime() > self.m_fSuccessScreenEnd) then
		self.m_CrackingText = nil

		if self.m_bIsKeypad then
			if not self.m_bIsWithinDist then
				self:SetFace("confused")
				self:SetScreenText(bKeypads.L"CrackerTooFar")
				self:PlaySound("alarm", .25)
			elseif not self.m_bIsLinked then
				self:SetFace("confused")
				self:SetScreenText(bKeypads.L"CrackerNotLinked")
				self:PlaySound("alarm", .25)
			elseif self.m_bCanCrack then
				self:SetFace("evil")
				self:SetScreenText(bKeypads.L"CrackerReady")
				self:PlaySound("success", .25)
			else
				self:SetFace("neutral")
				self:SetScreenText(bKeypads.L"CrackerCantCrack")
				self:PlaySound("warning", .25)
			end
		else
			self:SetFace("default")
			self:SetScreenText(bKeypads.L"CrackerWaiting")
			self.m_sPlayedSound = nil
		end
	end
end

function SWEP:CantCrack()
	self:EmitSound(bKeypads.Cracker.Sounds["alarm"].path, 75, 100, .25, CHAN_WEAPON)
	self.m_fErrorScreenEnd = CurTime() + .165
end

function SWEP:OnCrackTimeDataReceived(_, __, completeTime)
	self.m_iPlantingStage = self.PLANT.CRACKING
	self.m_iPlantingNextStage = math.huge
end
function SWEP:OnCrackingKeypadSet(_, __, crackingKeypad)
	if IsValid(crackingKeypad) then
		self.m_bCrackingKeypadSet = true
	else
		self.m_bCrackingKeypadSet = nil
	end
end

if IsValid(bKeypads_CrackerMatrix) then bKeypads_CrackerMatrix:Remove() end
function SWEP:DrawMatrix(w, h)
	if render.GetRenderTarget() ~= nil or bKeypads.Performance:Optimizing() then return end
	if not IsValid(bKeypads_CrackerMatrix) then
		bKeypads_CrackerMatrix = vgui.Create("bKeypads.Matrix")
		bKeypads_CrackerMatrix:SetMatrixID("Cracker")
		bKeypads_CrackerMatrix:SetRainSize(20)
		bKeypads_CrackerMatrix:SetPaintedManually(true)
	end
	bKeypads_CrackerMatrix:SetSize(w, h)
	bKeypads_CrackerMatrix:PaintAt(0, 0)
end
