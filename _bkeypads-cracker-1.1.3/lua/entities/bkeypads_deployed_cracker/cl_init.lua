include("shared.lua")

local RenderCable

function ENT:Draw(flags)
	local drawOpaque = bit.band(flags, STUDIO_TRANSPARENCY) == 0 or bit.band(flags, STUDIO_TWOPASS) == 0
	local drawTranslucent = bit.band(flags, STUDIO_TRANSPARENCY) == STUDIO_TRANSPARENCY or bit.band(flags, STUDIO_TWOPASS) == STUDIO_TWOPASS

	if not self:GetConsumed() then
		self:DrawScreenClipPlane()
			if drawOpaque then
				self:DrawModel()
				self:DrawWorldScreen()
			end
			if drawTranslucent then
				self:DrawLED()
				self:DrawHealth()
			end
		self:DrawScreenClipPlane()
	else
		self:DestroyShadow()
	end

	if drawOpaque and IsValid(self.m_ePoppedOffKeypad) then
		RenderCable(self, flags)
	end
end
function ENT:DrawTranslucent(flags)
	self:Draw(flags)
end

do
	if IsValid(bKeypads_DeployedCrackerMatrix) then bKeypads_DeployedCrackerMatrix:Remove() end
	function ENT:DrawMatrix(w, h)
		if bKeypads.Performance:Optimizing() then return end
		if not IsValid(bKeypads_DeployedCrackerMatrix) then
			bKeypads_DeployedCrackerMatrix = vgui.Create("bKeypads.Matrix")
			bKeypads_DeployedCrackerMatrix:SetMatrixID("DeployedCracker")
			bKeypads_DeployedCrackerMatrix:SetRainSize(20)
			bKeypads_DeployedCrackerMatrix:SetPaintedManually(true)
		end
		bKeypads_DeployedCrackerMatrix:SetSize(w, h)
		bKeypads_DeployedCrackerMatrix:PaintAt(0, 0)
	end

	local worldScreenPos = Vector(1.59, 1.77, 3.1)
	local worldScreenW, worldScreenH = 515, 230
	local scale_3d2d = 0.005
	local faceSize = .8
	function ENT:DrawWorldScreen()
		if not self.m_bSetupDataTables then return end

		local alpha_3d2d = (bKeypads.Performance:Optimizing() and bKeypads.Performance:Alpha3D2D(EyePos():DistToSqr(self:WorldSpaceCenter())) or 1)
		if alpha_3d2d == 0 then return end

		local isCracking = self.m_iAnimationStage == 0

		local ang = self:GetAngles()
		ang:RotateAroundAxis(self:GetUp(), -90)

		local w = worldScreenW
		local h = worldScreenH
		
		cam.Start3D2D(self:LocalToWorld(worldScreenPos), ang, scale_3d2d)
			surface.SetAlphaMultiplier(alpha_3d2d)
			if self.GetDestroyed and self:GetDestroyed() then
				if bKeypads:TVAnimation(self, 0.15, w, h, true) then cam.End3D2D() return end
				
				surface.SetDrawColor(255, 255, 255)
				surface.SetMaterial(bKeypads.Cracker.Materials.SCREEN_RED)
				surface.DrawTexturedRect(0, 0, w, h)

				self.Face = bKeypads.Emotes["shocked"]
			elseif isCracking then
				if not self.m_iStartCracking then
					self.m_iStartCracking = CurTime()
				end

				local frac = bKeypads.ease.InCirc(math.Clamp(math.TimeFraction(self.m_iStartCracking, self:GetCrackCompleteTime(), CurTime()), 0, 1))

				surface.SetDrawColor(255, 255, 255)
				surface.SetMaterial(bKeypads.Cracker.Materials.SCREEN_GREEN)
				surface.DrawTexturedRect(0, 0, w, h)
				
				surface.SetDrawColor(255, 255, 255, 255 * (1 - frac))
				surface.SetMaterial(bKeypads.Cracker.Materials.SCREEN_RED)
				surface.DrawTexturedRect(0, 0, w, h)

				self:DrawMatrix(w, h)

				if not self.m_iNextEmote or CurTime() >= self.m_iNextEmote then
					self.m_iNextEmote = CurTime() + math.Rand(0.5, 1)
					while true do
						local newFace = bKeypads.Emotes[bKeypads.Cracker.CrackingEmotes[math.random(1, #bKeypads.Cracker.CrackingEmotes)]]
						if #bKeypads.Emotes <= 1 or self.Face ~= newFace then
							self.Face = newFace
							break
						end
					end
				end
			else
				surface.SetDrawColor(255, 255, 255)
				surface.SetMaterial(bKeypads.Cracker.Materials.SCREEN_BLUE)
				surface.DrawTexturedRect(0, 0, w, h)

				self.m_iStartCracking = nil
				self.m_iNextEmote = nil

				self.Face = bKeypads.Emotes["sorry"]
			end

			local faceSize = h * faceSize
			local y = (h - faceSize) / 2
			surface.SetDrawColor(bKeypads.COLOR.SLATE)
			surface.SetMaterial(self.Face)
			surface.DrawTexturedRect((w - faceSize) / 2, y, faceSize, faceSize)
			
			if bKeypads.Cracker.Config.SpecialSunglasses and self:GetSpecialCrackTime() then
				surface.SetMaterial(bKeypads.Sunglasses)
				surface.DrawTexturedRect((w - faceSize) / 2, y, faceSize, faceSize)
			end
			
			bKeypads:TVAnimation(self)
			surface.SetAlphaMultiplier(1)
		cam.End3D2D()
	end
end

do
	if IsValid(bKeypads_CrackerCablePlug) then bKeypads_CrackerCablePlug:Remove() end
	function ENT:GetCablePlug()
		if not IsValid(bKeypads_CrackerCablePlug) then
			bKeypads_CrackerCablePlug = ClientsideModel("models/props_lab/tpplug.mdl", RENDERGROUP_OTHER)
			bKeypads_CrackerCablePlug:SetNoDraw(true)
			bKeypads_CrackerCablePlug:SetModelScale(.15)
		end
		return bKeypads_CrackerCablePlug
	end

	local matCable = Material("cable/cable2")
	local cableFrame
	local cableRendered = false
	function RenderCable(self, flags)
		if cableFrame ~= FrameNumber() then
			cableFrame = FrameNumber()
			cableRendered = false
		end
		if not cableRendered then
			if not IsValid(self.m_eDeployedCracker) or not IsValid(self.m_eDeployedCracker.m_ePoppedOffKeypad) or not IsValid(self.m_eDeployedCracker.m_eCrackingKeypad) then return end
			if render.GetRenderTarget() == nil then cableRendered = true end
			if not self.m_eDeployedCracker.m_tCablePath or #self.m_eDeployedCracker.m_tCablePath ~= 3 then return end

			local cablePlug = self.m_eDeployedCracker:GetCablePlug()

			local clipNormal = self.m_eDeployedCracker.m_eCrackingKeypad:GetForward()
			local clipPos = self.m_eDeployedCracker.m_eCrackingKeypad:WorldSpaceCenter()
			clipPos = clipPos - (clipNormal * .25)
			render.PushCustomClipPlane(clipNormal, clipNormal:Dot(clipPos))

				local ang = self.m_eDeployedCracker.m_ePoppedOffKeypad:GetAngles()
				ang:RotateAroundAxis(self.m_eDeployedCracker.m_ePoppedOffKeypad:GetUp(), 180)

				cablePlug:SetPos(self.m_eDeployedCracker.m_ePoppedOffKeypad:GetPos())
				cablePlug:SetAngles(ang)
				cablePlug:DrawModel()

				render.SetMaterial(matCable)
				render.StartBeam(4)

					for i = 0, 2 do
						render.AddBeam(self.m_eDeployedCracker.m_tCablePath[i], 0.5, 0, color_white)
					end

					render.AddBeam(self.m_eDeployedCracker:GetCablePlugPoint(), 0.5, 0, color_white)

				render.EndBeam()

			render.PopCustomClipPlane()
		end
	end

	function ENT:GetCablePlugPoint()
		local cablePlug = self.m_eDeployedCracker:GetCablePlug()
		local plugMins, plugMaxs = cablePlug:GetModelBounds()
		local plugSize = (plugMins - plugMaxs) * .15
		local poppedPlug = self.m_eDeployedCracker.m_ePoppedOffKeypad:GetPos()
		poppedPlug = poppedPlug + (self.m_eDeployedCracker.m_ePoppedOffKeypad:GetForward() * plugSize.y)
		return poppedPlug
	end

	function ENT:CableThink()
		if IsValid(self.m_eCrackingKeypad) and IsValid(self.m_ePoppedOffKeypad) and self.m_tCablePath then
			local cableOrigin = self.m_eCrackingKeypad:WorldSpaceCenter()
			local cablePlug = self:GetCablePlugPoint()
			local cableDir = cableOrigin - cablePlug
			local cableLength = cableDir:Length()
			local cableAngle = cableDir:Angle():Forward()

			self.m_tCablePath[0] = cableOrigin
			self.m_tCablePath[3] = cablePlug

			for i = 1, 2 do
				local cableFrac = i * (1 / 3)
				local cablePoint = cableOrigin - (cableAngle * cableLength * cableFrac)
				cablePoint.z = cablePoint.z - (math.abs(cablePoint.z - cablePlug.z) * cableFrac)
				self.m_tCablePath[i] = cablePoint
			end
		end
	end
end

do
	local LEDSprite = Material("sprites/light_glow02_add")
	local LEDColor  = Color(255, 0, 0)
	local LEDPos    = Vector(1.0795739889145, -1.4562743902206, 3)
	function ENT:DrawLED()
		if self.m_iAnimationStage ~= self.ANIM.CRACKING or CurTime() > (self.m_fNextBlip - 1) + 0.25 then return end
		render.SetMaterial(LEDSprite)
		render.DrawSprite(self:LocalToWorld(LEDPos), 4, 4, LEDColor)
	end
end

do
	local scale_3d2d   = 0.02
	local top_left     = Vector(-1.5, -4.0125, -0.075)
	local bottom_right = Vector(2.25, 2.85, 3.3)
	local top_right    = Vector(bottom_right.x, -4.0125, bottom_right.z)
	local bottom_left  = Vector(top_left.x, 2.85, top_left.z)

	function ENT:DrawHealth()
		if self:GetMaxHealth() == 0 or (not bKeypads.Cracker.Config.Damage.CanDestroyDropped and (self.m_bIsWeapon or not IsValid(self:GetKeypad()))) then return end

		local center = self:OBBCenter()

		local pos = self:LocalToWorld(center)
		pos.z = math.max(self:LocalToWorld(top_left).z, self:LocalToWorld(top_right).z, self:LocalToWorld(bottom_left).z, self:LocalToWorld(bottom_right).z) + .5
		
		local ang = (EyePos() - pos):Angle()
		ang:RotateAroundAxis(ang:Up(), 90)
		ang:RotateAroundAxis(ang:Forward(), 90)

		local playerLooking = LocalPlayer():GetEyeTrace().Entity == self
		if playerLooking then bKeypads.cam.IgnoreZ(true) end

			local w, h = 300, 50
			cam.Start3D2D(pos, ang, scale_3d2d)
				bKeypads:DrawHealth(self, w, h)
			cam.End3D2D()

		if playerLooking then bKeypads.cam.IgnoreZ(false) end
	end
end

function ENT:CrackingSoundThink()
	if self.m_iAnimationStage ~= self.ANIM.CRACKING then
		if self.m_fCrackingSoundEnd and CurTime() <= self.m_fCrackingSoundEnd then
			self.m_fCrackingSoundEnd = nil
			self:StopSound(self.m_tCrackingSound.path)
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
		self:EmitSound(self.m_tCrackingSound.path)
	end

	if not self.m_fNextBlip or CurTime() >= self.m_fNextBlip then
		self.m_fNextBlip = CurTime() + (bKeypads.Cracker.Config.Beeps.BeepInterval == 0 and 1 or bKeypads.Cracker.Config.Beeps.BeepInterval)
		if bKeypads.Cracker.Config.Beeps.Enable then
			self:EmitSound("buttons/blip2.wav", 100)
		end
	end
end

function ENT:PopOffKeypad(keypad)
	self.m_tCablePath = {}

	self.m_eCrackingKeypad = keypad
	self.m_eCrackingKeypad:ShowInternals(true)
	self.m_eCrackingKeypad.m_eDeployedCracker = self

	self.m_ePoppedOffKeypad = ents.CreateClientside("bkeypads_popped_keypad")
	self.m_ePoppedOffKeypad.m_eDeployedCracker = self
	self.m_ePoppedOffKeypad:SetPos(keypad:WorldSpaceCenter())
	self.m_ePoppedOffKeypad:SetAngles(keypad:GetAngles())

	self.m_ePoppedOffKeypad:Spawn()
	if keypad:LinkProxy():GetAuthMode() == bKeypads.AUTH_MODE.FACEID then
		self.m_ePoppedOffKeypad:SetBodygroup(bKeypads.BODYGROUP.CAMERA, 1)
	end

	self.m_eCrackingKeypad.RenderCable = RenderCable
	self.m_ePoppedOffKeypad.RenderCable = RenderCable
end
function ENT:DrawScreenClipPlane()
	if self.m_bScreenClipPlanePushed then
		self.m_bScreenClipPlanePushed = nil
		render.PopCustomClipPlane()
		return
	end

	if not IsValid(self.m_eDeployedCracker) or not IsValid(self.m_eDeployedCracker.m_ePoppedOffKeypad) then return end
	if self.m_iAnimationStage >= self.ANIM.POP_OFF_CRACKER then return end

	if self.m_iAnimationStage == self.ANIM.CRACKING and CurTime() >= self.m_fAnimationStart + self.AnimationStages[self.ANIM.OPEN_PANEL].Duration then
		return
	end

	local clipNormal = -self.m_eDeployedCracker.m_ePoppedOffKeypad:GetForward()
	local clipPos = self.m_eDeployedCracker.m_ePoppedOffKeypad:WorldSpaceCenter()
	clipPos = clipPos - (clipNormal * .25)
	render.PushCustomClipPlane(clipNormal, clipNormal:Dot(clipPos))

	self.m_bScreenClipPlanePushed = true
end

function ENT:CleanUp()
	self.m_bPreventPopOff = true

	if IsValid(self.m_ePoppedOffKeypad) then
		self.m_ePoppedOffKeypad:Remove()
	end
	if IsValid(self.m_eCrackingKeypad) then
		self.m_eCrackingKeypad.RenderCable = nil
		self.m_eCrackingKeypad:ShowInternals(false)
		self.m_eCrackingKeypad:RemoveCallOnRemove("bKeypads.KeypadCrackerPlant")
	end
	
	self.m_tCablePath = nil
	self.m_eCrackingKeypad = nil

	if self.m_tCrackingSound then
		self:StopSound(self.m_tCrackingSound.path)
	end
	self:StopSound("buttons/blip2.wav")
end

function ENT:OnRemove()
	self:CleanUp()

	local modelPanel = self.m_pModelPanel
	bKeypads:nextTick(function()
		if IsValid(self) then
			self.m_bPreventPopOff = nil
		else
			if bKeypads.Cracker.DroppedDict[self] then
				bKeypads.Cracker.DroppedDict[self] = nil
				table.RemoveByValue(bKeypads.Cracker.Dropped, self)
			end
			if IsValid(modelPanel) then
				modelPanel:SetEntity(nil)
				modelPanel:Remove()
			end
		end
	end)
end

function ENT:NetworkedAnimationStage(_, __, stage)
	self:SkipToAnimationStage(stage)
end
function ENT:NetworkedAnimationStart(_, __, start)
	self.m_fAnimationStart = start
end

function ENT:OnDeployedBySet(_, __, deployedBy)
	if deployedBy == LocalPlayer() and not bKeypads.Cracker.DroppedDict[self] then
		bKeypads.Cracker.DroppedDict[self] = true
		table.insert(bKeypads.Cracker.Dropped, self)
	end
end

bKeypads_Initialize_Fix(ENT)