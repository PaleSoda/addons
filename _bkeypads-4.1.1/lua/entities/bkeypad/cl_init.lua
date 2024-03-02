include("shared.lua")

local bkeypads_fullbright = CreateConVar("bkeypads_fullbright", 0, FCVAR_CHEAT)

local wireframe = Material("models/wireframe")
local matFaceID = Material("bkeypads/face_id")

local KeypadID = 0

local scale_3d2d = 0.02

function ENT:ClientInitialize()
	KeypadID = KeypadID + 1
	self.KeypadID = KeypadID

	self.BackgroundColor = Color(bKeypads.COLOR.SLATE:Unpack())
	self.ForegroundColor = Color(bKeypads.COLOR.WHITE:Unpack())

	self.Face = matFaceID

	self:SetLEDColor(false)

	self.AnimStart = CurTime()
	self.AnimEnd = CurTime() + .5

	self.ColorAnimStart = CurTime()
	self.ColorAnimEnd = CurTime() + (.5 * .56)

	self:CheckModel()

	self:BackgroundColorChanged(nil, nil, self:GetBackgroundColor())
	self:KeypadCrackableChanged()
	self:OnShieldChanged(nil, nil, self:GetShield())
	self:OnKeypadLinked()

	self.SparksTimer = "bKeypads.Sparks." .. self.KeypadID .. ":" .. self:GetCreationTime()
	timer.Create(self.SparksTimer, 3, 0, function()
		if not IsValid(self) then
			timer.Remove(SparksTimer)
		elseif not IsValid(self.m_eDeployedCracker) then
			self:Sparks()
		end
	end)
	timer.Stop(self.SparksTimer)
end

function ENT:TutorialInitialize()
	self:SetModel(bKeypads.MODEL.KEYPAD)
end

function ENT:ClientOnRemove()
	local SparksTimer = self.SparksTimer
	local KeypadPropertiesPanel = self.m_pKeypadProperties

	bKeypads:nextTick(function()
		if not IsValid(self) then
			if bKeypads.LOCKED_KEYPAD == self then
				bKeypads.LOCKED_KEYPAD = nil
				gui.EnableScreenClicker(false)
			end

			if SparksTimer then
				timer.Remove(SparksTimer)
			end

			if IsValid(KeypadPropertiesPanel) then
				KeypadPropertiesPanel:Remove()
			end

			bKeypads.KeypadsRegistry[self] = nil
			table.RemoveByValue(bKeypads.Keypads, self)
		end
	end)
end

function ENT:BackgroundColorChanged()
	self.CustomBackgroundColor = bKeypads:IntToColor(self:GetBackgroundColor())

	if self:GetScanningStatus() ~= bKeypads.SCANNING_STATUS.LOADING then
		self.BackgroundTargetColor = self:LinkProxy():GetAuthMode() == bKeypads.AUTH_MODE.PIN and Color(32, 32, 32) or self.CustomBackgroundColor

		self:CalculateForegroundColor()

		self.BackgroundAnimFrom = Color(self.BackgroundColor:Unpack())
		self.ForegroundAnimFrom = Color(self.ForegroundColor:Unpack())

		self.ColorAnimStart = CurTime()
		self.ColorAnimEnd = CurTime() + (.5 * .56)
	end
end

function ENT:ScanningStatusChanged(_, prevScanStatus, scanStatus)
	local authMode = self:LinkProxy():GetAuthMode()

	if scanStatus == bKeypads.SCANNING_STATUS.LOADING then

		self:SetLEDColor(false)
		self.BackgroundTargetColor = bKeypads.COLOR.SLATE

	elseif scanStatus == bKeypads.SCANNING_STATUS.IDLE then

		self:SetLEDColor(false)
		self.BackgroundTargetColor = authMode == bKeypads.AUTH_MODE.PIN and bKeypads.COLOR.SLATE or self.CustomBackgroundColor

		self.ForegroundTargetAlpha = 1

	elseif scanStatus == bKeypads.SCANNING_STATUS.SCANNING then

		self:SetLEDColor(bKeypads.Config.Appearance.LEDColors.Scanning)
		self.BackgroundTargetColor = bKeypads.Config.Appearance.ScreenColors.Scanning

		if authMode == bKeypads.AUTH_MODE.FACEID then
			self.ScanStart = CurTime()
		end

		self.GrantedDenied = nil

	elseif scanStatus == bKeypads.SCANNING_STATUS.GRANTED then

		self:SetLEDColor(bKeypads.Config.Appearance.LEDColors.Granted)
		self.BackgroundTargetColor = bKeypads.Config.Appearance.ScreenColors.Granted
		self.GrantedDenied = bKeypads.SCANNING_STATUS.GRANTED

	elseif scanStatus == bKeypads.SCANNING_STATUS.DENIED then

		self:SetLEDColor(bKeypads.Config.Appearance.LEDColors.Denied)
		self.BackgroundTargetColor = bKeypads.Config.Appearance.ScreenColors.Denied
		self.GrantedDenied = bKeypads.SCANNING_STATUS.DENIED

	end

	self:CalculateForegroundColor()

	self.AnimStart = CurTime()
	self.AnimEnd = CurTime() + .5

	self.ColorAnimStart = CurTime()
	self.ColorAnimEnd = CurTime() + (.5 * .56)

	self.ForegroundAnimFrom = Color(self.ForegroundColor:Unpack())
	self.BackgroundAnimFrom = Color(self.BackgroundColor:Unpack())
end

function ENT:HasRainbowBackground()
	return self:GetBackgroundColor() == bKeypads.STOOL.RainbowBackgroundColor
end

function ENT:CalculateForegroundColor()
	if self:HasRainbowBackground() then
		self.ForegroundColor = bKeypads.COLOR.SLATE
		self.GrantedForegroundColor = bKeypads.COLOR.SLATE
		self.DeniedForegroundColor = bKeypads.COLOR.SLATE
	else
		if self.CustomBackgroundColor then
			self.ForegroundColor = bKeypads:DarkenForeground(self.CustomBackgroundColor) and bKeypads.COLOR.SLATE or bKeypads.COLOR.WHITE
		end
		self.GrantedForegroundColor = bKeypads:DarkenForeground(bKeypads.Config.Appearance.ScreenColors.Granted) and bKeypads.COLOR.SLATE or bKeypads.COLOR.WHITE
		self.DeniedForegroundColor = bKeypads:DarkenForeground(bKeypads.Config.Appearance.ScreenColors.Denied) and bKeypads.COLOR.SLATE or bKeypads.COLOR.WHITE
	end

	self.ForegroundHackedColor = bKeypads:DarkenForeground(bKeypads.Config.Appearance.ScreenColors.Hacked) and bKeypads.COLOR.SLATE or bKeypads.COLOR.WHITE
end

function ENT:GetScreenColor()
	return self:LinkProxy():GetAuthMode() ~= bKeypads.AUTH_MODE.PIN and (self.BackgroundColor or self.BackgroundTargetColor or self.CustomBackgroundColor) or bKeypads.COLOR.SLATE
end

function ENT:SetLEDColor(col)
	if col == false then
		if self:LinkProxy():GetAuthMode() == bKeypads.AUTH_MODE.PIN then
			self:ShowTopLED(true)
			self.LEDColor = bKeypads.COLOR.LCDSCREEN
		else
			self:ShowTopLED(false)
		end
		self:ShowBottomLED(false)
	else
		self:ShowTopLED(true)
		self:ShowBottomLED(true)
		self.LEDColor = col
	end
end

function ENT:GetLEDColor()
	return self.LEDColor
end

function ENT:Emote(face, time)
	self.Face = bKeypads.Emotes[face]
	self.FaceTime = CurTime() + time
end

do
	local matBeam = Material("effects/lamp_beam")
	local matLight = Material("sprites/light_ignorez")

	local matFaceIDSad = Material("bkeypads/face_id_sad")
	local matKeycard = Material("bkeypads/keycard")

	local matLoading = Material("bkeypads/loading")
	local matTick = Material("bkeypads/tick")
	local matCross = Material("bkeypads/cross")

	--[[local function print_flags(flags)
		print("Flags = ", flags)
		print("STUDIO_RENDER", bit.band(flags, STUDIO_RENDER) ~= 0)
		print("STUDIO_VIEWXFORMATTACHMENTS", bit.band(flags, STUDIO_VIEWXFORMATTACHMENTS) ~= 0)
		print("STUDIO_DRAWTRANSLUCENTSUBMODELS", bit.band(flags, STUDIO_DRAWTRANSLUCENTSUBMODELS) ~= 0)
		print("STUDIO_TWOPASS", bit.band(flags, STUDIO_TWOPASS) ~= 0)
		print("STUDIO_STATIC_LIGHTING", bit.band(flags, STUDIO_STATIC_LIGHTING) ~= 0)
		print("STUDIO_WIREFRAME", bit.band(flags, STUDIO_WIREFRAME) ~= 0)
		print("STUDIO_ITEM_BLINK", bit.band(flags, STUDIO_ITEM_BLINK) ~= 0)
		print("STUDIO_NOSHADOWS", bit.band(flags, STUDIO_NOSHADOWS) ~= 0)
		print("STUDIO_WIREFRAME_VCOLLIDE", bit.band(flags, STUDIO_WIREFRAME_VCOLLIDE) ~= 0)
		print("STUDIO_GENERATE_STATS", bit.band(flags, STUDIO_GENERATE_STATS) ~= 0)
		print("STUDIO_SSAODEPTHTEXTURE", bit.band(flags, STUDIO_SSAODEPTHTEXTURE) ~= 0)
		print("STUDIO_SHADOWDEPTHTEXTURE", bit.band(flags, STUDIO_SHADOWDEPTHTEXTURE) ~= 0)
		print("STUDIO_TRANSPARENCY", bit.band(flags, STUDIO_TRANSPARENCY) ~= 0)
	end]]

	function ENT:Draw(flags)
		--print_flags(flags)

		if self:GetBroken() and not self:GetHacked() then
			if self:GetSlanted() then
				self.ResetRenderAngles = true
				self:SetRenderAngles(nil)

				if not self.HackedAngle then
					self.HackedAngle = math.random(1,2) == 1 and math.random(-5, -2) or math.random(2, 5)
				end

				local ang = self:GetAngles()
				ang:RotateAroundAxis(ang:Forward(), -self.HackedAngle)
				self:SetRenderAngles(ang)
			end
		elseif self.ResetRenderAngles then
			self.ResetRenderAngles = nil
			self.HackedAngle = nil
			self:SetRenderAngles(nil)
		end

		if bit.band(flags, STUDIO_TRANSPARENCY) == 0 or bit.band(flags, STUDIO_TWOPASS) == 0 then
			local scanStatus = self:GetScanningStatus()

			render.SuppressEngineLighting(
				self.m_ForceSupressEngineLighting or
				bkeypads_fullbright:GetBool() or
				not bKeypads.Config.AlwaysEngineLighting and (
					bKeypads.LOCKED_KEYPAD == self or
					(scanStatus ~= bKeypads.SCANNING_STATUS.IDLE and scanStatus ~= bKeypads.SCANNING_STATUS.LOADING)
				)
			)

			if not self.m_DrawFallbackModel then
				self:DrawModel()
			end

			if self.RenderCable then
				self:RenderCable(flags)
			end

			if scanStatus == bKeypads.SCANNING_STATUS.SCANNING and self:LinkProxy():GetAuthMode() == bKeypads.AUTH_MODE.KEYCARD then
				local keycard = self:GetScanningEntity()
				if keycard.bKeycard then
					keycard:DrawWorldKeycard(self)
				end
			end

			render.SuppressEngineLighting(false)

			local IgnoreZ = bKeypads.cam.IgnoreZ(false)
				self:Draw3D2DUI(flags)
			bKeypads.cam.IgnoreZ(IgnoreZ)
		end
	end

	function ENT:DrawTranslucent(flags)
		self:Draw(flags)

		if self.DrawShield then self:DrawShield(scale_3d2d) end

		local didDraw = self:DrawPayment3D2DUI()
		self:DrawKeypadLabel(didDraw)

		self:DrawScanningBeam()
	end

	local ui_w, ui_h = 370, 537
	local ui_w_half = ui_w / 2

	-- x = forward
	-- y = right
	-- z = down
	local mdl_ui_pos_mins = Vector(.33, -3.705, 5.415)
	local mdl_ui_pos_maxs = Vector(mdl_ui_pos_mins.x, mdl_ui_pos_mins.y + (ui_w * scale_3d2d), mdl_ui_pos_mins.z - (ui_h * scale_3d2d))

	local mdl_keypad_led_pos_mins = Vector(0.65, -1.410797, 5.31)
	local mdl_keypad_led_pos_maxs = Vector(0.65, 1.410797, 4.8)
	local led_w, led_h = (mdl_keypad_led_pos_maxs.y - mdl_keypad_led_pos_mins.y) / scale_3d2d, -(mdl_keypad_led_pos_maxs.z - mdl_keypad_led_pos_mins.z) / scale_3d2d
	local asterisk_offset = 2

	local scan_method_w, scan_method_h = 256, 256
	local scan_method_x, scan_method_y = (ui_w - scan_method_w) / 2, (ui_h - scan_method_h) / 2

	local keypad_btn_size = 85
	local keypad_btn_spacing = 10
	local keypad_btn_p_size = keypad_btn_size + keypad_btn_spacing
	local keypad_btn_p_frac = keypad_btn_size / keypad_btn_p_size

	local keypad_btn_cross_size = 40
	local keypad_btn_tick_size = 50

	local keypad_btn_cross_pos = (keypad_btn_size - keypad_btn_cross_size) / 2
	local keypad_btn_tick_pos = (keypad_btn_size - keypad_btn_tick_size) / 2

	local keypad_w, keypad_h = (keypad_btn_p_size * 2) + keypad_btn_size, (keypad_btn_p_size * 3) + keypad_btn_size

	local keypad_top_left_x, keypad_top_left_y = (ui_w - keypad_w) / 2, ((ui_h - keypad_h) / 2)
	local keypad_top_right_x = keypad_top_left_x + (keypad_btn_p_size * 2) + keypad_btn_size
	local keypad_bottom_left_x = keypad_top_left_y + (keypad_btn_p_size * 3) + keypad_btn_size

	local keypad_slide_offset = (ui_h + keypad_h) / 2

	local keypad_btn_hovered_col = Color(255,255,255)
	local keypad_btn_col = Color(100,100,100)

	local keypad_matrix_translate = { {7,8,9}, {4,5,6}, {1,2,3}, {10,0,11} }
	local keypad_numpad_translate = { KEY_PAD_0, KEY_PAD_1, KEY_PAD_2, KEY_PAD_3, KEY_PAD_4, KEY_PAD_5, KEY_PAD_6, KEY_PAD_7, KEY_PAD_8, KEY_PAD_9 }

	local paymentPolyHeight = 80

	local paymentPoly = {
		{ x = 0,				y = 0 },
		{ x = ui_w,				y = 0 },
		{ x = ui_w,				y = paymentPolyHeight },
		{ x = 0,				y = paymentPolyHeight },
	}

	local paymentPolyLeft = {
		{ x = ui_w_half,		y = paymentPolyHeight },
		{ x = ui_w_half,		y = paymentPolyHeight + 20 },
		{ x = ui_w_half - 20,	y = paymentPolyHeight }
	}

	local paymentPolyRight = {
		{ x = ui_w_half,		y = paymentPolyHeight },
		{ x = ui_w_half + 20,	y = paymentPolyHeight },
		{ x = ui_w_half,		y = paymentPolyHeight + 20 }
	}

	ENT.PaymentPolyHeight = ((paymentPolyHeight + 20) * scale_3d2d) + .5

	local function initRainbow()
		local function ang2D(P11, P12, P21, P22)
			return math.deg(math.atan((P22 - P12) / (P21 - P11)))
		end

		local function DrawTexturedRectRotatedPoint(x, y, w, h, rot, x0, y0)
			local c = math.cos(math.rad(rot))
			local s = math.sin(math.rad(rot))
			local newx = y0 * s - x0 * c
			local newy = y0 * c + x0 * s
			surface.DrawTexturedRectRotated(x + newx, y + newy, w, h, rot)
		end

		local screenLength = math.floor(math.sqrt((ui_h ^ 2) + (ui_w ^ 2)))

		local RT = GetRenderTargetEx("bKeypads_RainbowBackground", screenLength, screenLength, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_NONE, 32768, CREATERENDERTARGETFLAGS_HDR, IMAGE_FORMAT_DEFAULT)

		local RTRainbow = CreateMaterial("bKeypads.Rainbow", "UnlitGeneric", {
			["$basetexture"] = RT:GetName(),
			["$translucent"] = 1,
			["$vertexalpha"] = 1
		})

		local RenderRainbow = false
		local RainbowRendered
		local RainbowWidth
		hook.Add("PostRender", "bKeypads.RenderRainbow", function()
			if render.GetRenderTarget() ~= nil and (not bKeypads.Tutorial.SCENE_RT or render.GetRenderTarget():GetName() ~= bKeypads.Tutorial.SCENE_RT:GetName()) then return end
			if RainbowRendered == FrameNumber() then return end

			if not RenderRainbow then return end
			RenderRainbow = false

			RainbowRendered = FrameNumber()
			RainbowWidth = 0

			render.PushRenderTarget(RT)
			cam.Start2D()

				render.OverrideAlphaWriteEnable(true, true)
				render.OverrideColorWriteEnable(true, true)
				render.Clear(0, 0, 0, 255)
				render.SetWriteDepthToDestAlpha(false)
				render.OverrideAlphaWriteEnable(true, false)

				local timeStep = ((CurTime() / 4) % 2) * math.pi
				local barWidth = Lerp(((math.sin((CurTime() % 2) * math.pi) + 1) / 2), 15, 50)
				local barNum = math.ceil((screenLength / barWidth / 2) * math.pi)
				local frequency = (1 / (barNum * bKeypads.phi)) * math.pi

				for i = 1, barNum - 1 do
					local thicc = math.sin((i / barNum) * math.pi) * barWidth

					surface.SetDrawColor(bKeypads:Rainbow((-i * frequency) + timeStep))
					surface.DrawRect(RainbowWidth - 1, 0, thicc + 2, screenLength)

					RainbowWidth = RainbowWidth + thicc
				end

				render.OverrideAlphaWriteEnable(false)
				render.OverrideColorWriteEnable(false)

			cam.End2D()
			render.PopRenderTarget()
		end)
		if bKeypads then
			function bKeypads:DrawRainbow(w, h)
				RenderRainbow = true

				local size = w and h and math.sqrt((w ^ 2) + (h ^ 2)) or screenLength

				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(RTRainbow)
				DrawTexturedRectRotatedPoint(0, 0, size, size, ang2D(0, 0, h or ui_h, w or ui_w), 0, size / 2)
			end
		end
	end
	initRainbow() hook.Add("bKeypads.Ready", "bKeypads.RainbowInit", initRainbow)

	local function GetViewData()
		local mouseX, mouseY = gui.MouseX(), gui.MouseY()
		if bKeypads.Settings:Get("pin_input_mode") == "look" and mouseX == 0 and mouseY == 0 then
			return bKeypads.FakeAngles:GetEyeData()
		end
		return LocalPlayer():EyePos(), gui.ScreenToVector(mouseX, mouseY)
	end

	local cursorPosTr = {}
	function ENT:GetCursorPos(mouseMode)
		if LocalPlayer():KeyDown(IN_ATTACK) then return end

		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		local EyePos, AimVector = GetViewData()

		cursorPosTr.start = EyePos
		cursorPosTr.endpos = EyePos + AimVector * 65
		cursorPosTr.filter = ply
		local tr = util.TraceLine(cursorPosTr)
		if tr.Entity ~= self then return end

		local pos, ang = self:_LocalToWorld(mdl_ui_pos_mins), self:GetAngles()
		ang:RotateAroundAxis(self:GetUp(), 90)
		ang:RotateAroundAxis(self:GetRight(), -90)
		if self.HackedAngle then
			ang:RotateAroundAxis(self:GetRight(), -self.HackedAngle)
			ang:RotateAroundAxis(self:GetForward(), -self.HackedAngle)
		end

		local intersection = util.IntersectRayWithPlane(EyePos, AimVector, pos, self:GetForward())
		if not intersection then return end

		local localIntersection = WorldToLocal(intersection, angle_zero, pos, self:GetAngles())
		local x, y = localIntersection.y / scale_3d2d, -localIntersection.z / scale_3d2d
		if x > 0 and y > 0 and x <= ui_w and y <= ui_h then
			return x, y
		end
	end

	function ENT:ClearInput()
		if self:GetPINDigitsInput() ~= 0 then
			net.Start("bKeypads.PIN.InputKey")
				net.WriteEntity(self)
				net.WriteUInt(10, 4)
			net.SendToServer()
		end
	end

	function ENT:StartInteraction()
		if self:LinkProxy():GetAuthMode() == bKeypads.AUTH_MODE.PIN then
			bKeypads.LOCKED_KEYPAD = self

			gui.EnableScreenClicker(true)
		end
	end

	function ENT:FinishInteraction()
		bKeypads.LOCKED_KEYPAD = nil

		gui.EnableScreenClicker(false)
		self:ClearInput()
	end

	function ENT:NetworkPINInput()
		local pressed = self.PINNumpadPressed or self.PINButtonPressed
		if (pressed ~= 10 and pressed ~= 11) or self:GetPINDigitsInput() ~= 0 then
			net.Start("bKeypads.PIN.InputKey")
				net.WriteEntity(self)
				net.WriteUInt(pressed, 4)
			net.SendToServer()
		end
	end

	local CanDraw3D2D, CanDraw3D2DAlpha, CanDraw3D2DFrame
	function ENT:CanDraw3D2D()
		if halo.RenderedEntity() == self then return end
		if CanDraw3D2DFrame ~= FrameNumber() then
			local entPos = self:GetPos()
			CanDraw3D2D = entPos:ToScreen().visible
			if CanDraw3D2D then
				CanDraw3D2DAlpha = surface.GetAlphaMultiplier() * (self:EntIndex() == -1 and 1 or (bKeypads.Performance:Optimizing() and bKeypads.ease.InOutSine(bKeypads.Performance:Alpha3D2D(entPos:DistToSqr(LocalPlayer():GetPos()))) or 1))
				CanDraw3D2D = CanDraw3D2D and CanDraw3D2DAlpha > 0
			end
		end
		return CanDraw3D2D, CanDraw3D2DAlpha
	end

	do
		local keypadImageEasterEggs = {
			["2148855444"] = "https://i.imgur.com/5cN1cgq.png"
		}
		local keypadImageEasterEgg, keypadImageEasterEggEnd
		function ENT:GetImageURLEasterEgg()
			if keypadImageEasterEgg and keypadImageEasterEggEnd and CurTime() < keypadImageEasterEggEnd then
				return keypadImageEasterEgg
			else
				return self:GetImageURL()
			end
		end

		hook.Add("OnPlayerChat", "bKeypads.PlayerChat.EasterEgg", function(ply, text)
			if ply ~= LocalPlayer() then return end

			local egg = keypadImageEasterEggs[util.CRC(text:lower())]
			if egg then
				keypadImageEasterEgg = egg
				keypadImageEasterEggEnd = CurTime() + 20

				local fx = EffectData()
				for _, ent in ipairs(ents.GetAll()) do
					if ent.bKeypad then
						ent:EmitSound("garrysmod/save_load1.wav", 60)

						fx:SetEntity(ent)
						util.Effect("entity_remove", fx)
					end
				end
			end
		end)
	end

	local requiresPaymentFocus
	function ENT:Draw3D2DUI()
		local authMode = self:LinkProxy():GetAuthMode()
		if authMode ~= self._authMode then
			if self._authMode ~= nil then
				self:ScanningStatusChanged(nil, nil, scanStatus)
			end
			self._authMode = authMode
		end

		local isFaceID        = authMode == bKeypads.AUTH_MODE.FACEID
		local isPIN           = authMode == bKeypads.AUTH_MODE.PIN
		--local isKeycard       = authMode == bKeypads.AUTH_MODE.KEYCARD

		local isBroken  = self:GetBroken()
		local isHacked  = self:GetHacked()

		local isRainbow = not isPIN and (not isBroken and not isHacked) and self:HasRainbowBackground()

		local r, g, b
		if isRainbow then
			r, g, b = bKeypads:Rainbow((((CurTime() - 1) / 4) % 2) * math.pi)
		end

		local canDraw, ui_alpha = self:CanDraw3D2D()
		if not canDraw then return end

		if self:GetBodygroup(bKeypads.BODYGROUP.PANEL) == 1 then return end

		if not self.CustomBackgroundColor then
			self:BackgroundColorChanged(nil, nil, self:GetBackgroundColor())
		end

		local playerLooking = LocalPlayer():GetEyeTrace().Entity == self

		local scanStatus = self:GetScanningStatus()

		local isIdle          = scanStatus == bKeypads.SCANNING_STATUS.IDLE
		local isScanning      = scanStatus == bKeypads.SCANNING_STATUS.SCANNING
		local isLoading       = scanStatus == bKeypads.SCANNING_STATUS.LOADING
		local isAccessGranted = scanStatus == bKeypads.SCANNING_STATUS.GRANTED
		local isAccessDenied  = scanStatus == bKeypads.SCANNING_STATUS.DENIED
		local displayAccess   = isAccessGranted or isAccessDenied

		local mouseMode       = isPIN and bKeypads.Settings:Get("pin_input_mode") == "mouse"

		local imageURL = self:GetImageURLEasterEgg()
		if imageURL and #imageURL > 0 and bKeypads.KeypadImages:VerifyURL(imageURL) then
			if (self.ImageURLLoaded == nil or (isnumber(self.ImageURLLoaded) and os.time() > self.ImageURLLoaded) or (isstring(self.ImageURLLoaded) and imageURL ~= self.ImageURLLoaded)) then
				local loading = imageURL
				self.ImageURLLoaded = loading
				self.CustomImage = nil
				bKeypads.KeypadImages:GetImage(loading, function(success, mat, retry)
					if imageURL ~= loading then return end
					if success then
						self.CustomImage = mat
					else
						self.ImageURLLoaded = retry
						bKeypads:print("Failed to get custom image for keypad #" .. self:EntIndex() .. " - \"" .. mat .. "\"", bKeypads.PRINT_TYPE_BAD, "ERROR")
					end
				end)
			end
		else
			self.CustomImage = nil
			self.ImageURLLoaded = nil
		end

		local plyBehind = self:IsPlayerBehind(LocalPlayer())

		local AnimFrac = math.Clamp(math.TimeFraction(self.AnimStart, self.AnimEnd, CurTime()), 0, 1)
		local ColorAnimFrac = math.Clamp(math.TimeFraction(self.ColorAnimStart, self.ColorAnimEnd, CurTime()), 0, 1)

		local AnimFracEaseBack = bKeypads.ease.OutBack(AnimFrac)
		local AnimFracEaseBackInverse = 1 - AnimFracEaseBack

		local displayAccessAnim = displayAccess and AnimFracEaseBackInverse or AnimFracEaseBack

		local pos, pos_max = self:_LocalToWorld(mdl_ui_pos_mins)--, self:_LocalToWorld(mdl_ui_pos_maxs)

		local ang = self:GetAngles()
		ang:RotateAroundAxis(self:GetUp(), 90)
		ang:RotateAroundAxis(self:GetRight(), -90)
		if self.HackedAngle then
			ang:RotateAroundAxis(self:GetRight(), -self.HackedAngle)
			ang:RotateAroundAxis(self:GetForward(), -self.HackedAngle)
		end

		self.Start3D2D(pos, ang, scale_3d2d)
			self:Scissor2D(ui_w, ui_h)

			if self.m_bPlayTVAnimation and (not self.m_tTVAnimation or CurTime() < self.m_tTVAnimation.Start + 0.15) then
				bKeypads:TVAnimation(self, 0.15, ui_w, ui_h)
			else
				self.m_bPlayTVAnimation = nil
				self.m_tTVAnimation = nil
				self.m_bTVAnimation = nil
			end

			local mouseX, mouseY
			if isPIN then
				mouseX, mouseY = self:GetCursorPos(mouseMode)
				if bKeypads.LOCKED_KEYPAD == self and not mouseX and not mouseY then
					self:FinishInteraction()
				end
			end

			surface.SetAlphaMultiplier(ui_alpha)

			if isPIN and not isBroken then
				surface.SetDrawColor(bKeypads.COLOR.SLATE)
				surface.DrawRect(0, 0, ui_w, ui_h)
			elseif isRainbow then
				if bKeypads.Performance:Optimizing() then
					surface.SetDrawColor(r, g, b)
					surface.DrawRect(0, 0, ui_w, ui_h)
				else
					local rainbow_alpha = self:EntIndex() == -1 and 1 or bKeypads.ease.InOutSine(bKeypads.Performance:Alpha3D2D(self:WorldSpaceCenter():DistToSqr(LocalPlayer():GetPos())))
					if rainbow_alpha < 1 then
						surface.SetDrawColor(r, g, b)
						surface.DrawRect(0, 0, ui_w, ui_h)
					end

					surface.SetAlphaMultiplier(math.min(ui_alpha, rainbow_alpha))
						surface.SetDrawColor(bKeypads.COLOR.SLATE)
						surface.DrawRect(0, 0, ui_w, ui_h)

						bKeypads:DrawRainbow()
					surface.SetAlphaMultiplier(ui_alpha)
				end
			else
				surface.SetDrawColor(self.BackgroundColor)
				surface.DrawRect(0, 0, ui_w, ui_h)
			end

			if self.SlideText and CurTime() <= self.SlideText.finish then
				local slideFrac = math.min(math.TimeFraction(self.SlideText.start, self.SlideText.finish, CurTime()), 1)

				surface.SetFont("bKeypads.SlideTextFont")
				surface.SetTextColor(self.ForegroundColor)

				local text_w, text_h = surface.GetTextSize(self.SlideText.text)
				local slide_x = (-ui_w * (self.SlideText.index - 1)) + (ui_w * #self.SlideText.keypads) - ((text_w + (ui_w * #self.SlideText.keypads)) * slideFrac)
				surface.SetTextPos(slide_x, (ui_h - text_h) / 2)

				surface.DrawText(self.SlideText.text)
			else
				if isBroken or (not isPIN and isScanning) then
					surface.SetAlphaMultiplier(ui_alpha / 2)
					if not self.Matrix then
						self.Matrix = bKeypads_Matrix("KEYPAD", ui_w, ui_h)
						self.Matrix:SetRainSize(24)
					end
					self.Matrix:Draw(ui_w, ui_h)
					surface.SetAlphaMultiplier(ui_alpha)
				end

				local slideOffset = scan_method_y + scan_method_h

				if isLoading or not self.GrantedDenied then
					local slide = (displayAccess and -1 or 1) * ((isScanning or isLoading) and AnimFracEaseBackInverse or AnimFracEaseBack)
					surface.SetDrawColor(isRainbow and bKeypads.COLOR.SLATE or bKeypads.COLOR.WHITE)
					surface.SetMaterial(matLoading)
					surface.DrawTexturedRectRotated(scan_method_x + (scan_method_w / 2), scan_method_y + (scan_method_h / 2) - (slideOffset * slide), scan_method_w * .75, scan_method_h * .75, (SysTime() * 100) % 360)
				end

				if not isLoading then
					if isBroken then
						surface.SetDrawColor(self.ForegroundColor)
						surface.SetMaterial(isHacked and matTick or (isFaceID and matFaceIDSad or matCross))
						surface.DrawTexturedRect(scan_method_x, scan_method_y, scan_method_w, scan_method_h)
					else
						if not isPIN then
							local slide = displayAccess and 1 or (isScanning and AnimFracEaseBack or AnimFracEaseBackInverse)
							if (self.CustomImage ~= nil) then
								surface.SetDrawColor(255,255,255)
								surface.SetMaterial(self.CustomImage)
							else
								surface.SetDrawColor(self.ForegroundColor)
								surface.SetMaterial(isFaceID and ((not self.FaceTime or CurTime() > self.FaceTime) and bKeypads.Emotes["default"] or self.Face) or matKeycard)
							end
							surface.DrawTexturedRect(scan_method_x, scan_method_y + (slideOffset * slide), scan_method_w, scan_method_h)
						else
							local slide = self.GrantedDenied and 0 or AnimFracEaseBackInverse
							local pin_y = keypad_top_left_y + (keypad_slide_offset * slide)

							local hoveredKey
							if playerLooking and vgui.GetKeyboardFocus() == nil and not gui.IsConsoleVisible() and not gui.IsGameUIVisible() then
								-- Only make these calculations when:
								-- * The player is looking at the keypad
								-- * They are not focused on any text boxes
								-- * The console is not open
								-- * The escape menu is not open

								local USE_KEY_DOWN = LocalPlayer():KeyDown(IN_USE) and not LocalPlayer():KeyDown(IN_ATTACK)

								-- Figure out if player has +use on the keypad and lock them into it
								if bKeypads.Settings:Get("pin_input_mode") == "mouse" and LocalPlayer():GetUseEntity() == self then
									if not self.USE_KEY_HELD and USE_KEY_DOWN then
										self.USE_KEY_HELD = true
										if LocalPlayer():KeyDown(IN_ATTACK) and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "weapon_physgun" then
											self.USE_KEY_PHYSGUN_BLOCK = true
										end
									elseif self.USE_KEY_HELD and not USE_KEY_DOWN then
										self.USE_KEY_HELD = false

										if bKeypads.LOCKED_KEYPAD ~= self then
											if not plyBehind and not self.USE_KEY_PHYSGUN_BLOCK then
												self:StartInteraction()
											end
										else
											self:FinishInteraction()
										end

										self.USE_KEY_PHYSGUN_BLOCK = nil
									end
								end

								-- Calculate which PIN button is hovered by the mouse
								if isIdle and (mouseX and mouseY) and (mouseX >= keypad_top_left_x and mouseX <= keypad_top_right_x) and (mouseY >= pin_y and mouseY <= keypad_bottom_left_x) then
									local column = 1 + ((mouseX - keypad_top_left_x) / keypad_btn_p_size)
									local row = 1 + ((mouseY - pin_y) / keypad_btn_p_size)
									if column % 1 < keypad_btn_p_frac and row % 1 < keypad_btn_p_frac then
										column = math.floor(column)
										row = math.floor(row)
										if keypad_matrix_translate[row] and keypad_matrix_translate[row][column] then
											hoveredKey = keypad_matrix_translate[row][column]
										end
									end
								end

								-- PIN button pressing logic
								if hoveredKey then
									local pressedKey
									if mouseMode or (gui.MouseX() ~= 0 and gui.MouseY() ~= 0) then
										pressedKey = input.IsMouseDown(MOUSE_LEFT)
									else
										pressedKey = USE_KEY_DOWN
									end
									if pressedKey then
										if self.PINButtonPressed == nil then
											self.PINButtonPressed = hoveredKey
											self:NetworkPINInput()
										end
									else
										self.PINButtonPressed = nil
									end
								else
									self.PINButtonPressed = false
								end

								-- Numpad button pressing logic
								if not self.PINButtonPressed then
									if input.IsButtonDown(KEY_PAD_ENTER) then
										if self.PINNumpadPressed == nil then
											self.PINNumpadPressed = 11
											self:NetworkPINInput()
										end
									elseif input.IsButtonDown(KEY_PAD_DECIMAL) or input.IsButtonDown(KEY_PAD_MINUS) then
										if self.PINNumpadPressed == nil then
											self.PINNumpadPressed = 10
											self:ClearInput()
										end
									else
										local btn_down
										for matrix_key, numpad_key in ipairs(keypad_numpad_translate) do
											if input.IsButtonDown(numpad_key) then
												btn_down = true
												if self.PINNumpadPressed == nil then
													self.PINNumpadPressed = matrix_key - 1

													if self:GetPINDigitsInput() < 6 then
														self:NetworkPINInput()
													end
												end
												break
											end
										end
										if btn_down == nil then
											self.PINNumpadPressed = nil
										end
									end
								end
							end

							-- If access has been granted to the keypad, unlock the player
							if isAccessGranted and bKeypads.LOCKED_KEYPAD == self then
								self:FinishInteraction()
							end

							surface.SetFont("bKeypads.PINBtn")
							for i=0,11 do
								local isHovered = hoveredKey == i
								if i <= 9 then
									local x, y
									if i == 0 then
										x, y = keypad_top_left_x + keypad_btn_p_size, pin_y + (keypad_btn_p_size * 3)
									else
										x = keypad_top_left_x + (((i - 1) % 3) * keypad_btn_p_size)
										y = pin_y + (math.ceil(2 - ((i - 1) / 3)) * keypad_btn_p_size)
									end
									if isHovered then
										surface.SetDrawColor(keypad_btn_hovered_col)
										if self.PINButtonPressed == i then
											surface.DrawRect(x + 5, y + 5, keypad_btn_size - 10, keypad_btn_size - 10)
										else
											surface.DrawRect(x, y, keypad_btn_size, keypad_btn_size)
										end
									else
										surface.SetDrawColor(keypad_btn_col)
										surface.DrawRect(x, y, keypad_btn_size, keypad_btn_size)
									end

									draw.SimpleText(i, "bKeypads.PINBtn", x + (keypad_btn_size / 2), y + (keypad_btn_size / 2), bKeypads.COLOR.SLATE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
								else
									local x,y
									if i == 10 then
										x,y = keypad_top_left_x, pin_y + (keypad_btn_p_size * 3)
										if isHovered then
											surface.SetDrawColor(255, 0, 0)
										else
											surface.SetDrawColor(120, 25, 25)
										end
									else
										x,y = keypad_top_left_x + (keypad_btn_p_size * 2), pin_y + (keypad_btn_p_size * 3)
										if isHovered then
											surface.SetDrawColor(0, 225, 0)
										else
											surface.SetDrawColor(25, 120, 25)
										end
									end
									if self.PINButtonPressed == i then
										surface.DrawRect(x + 5, y + 5, keypad_btn_size - 10, keypad_btn_size - 10)
									else
										surface.DrawRect(x, y, keypad_btn_size, keypad_btn_size)
									end

									local icon = i == 10 and matCross or matTick
									local iconPos = i == 10 and keypad_btn_cross_pos or keypad_btn_tick_pos
									local iconSize = i == 10 and keypad_btn_cross_size or keypad_btn_tick_size
									surface.SetDrawColor(255, 255, 255)
									surface.SetMaterial(icon)
									surface.DrawTexturedRect(x + iconPos, y + iconPos, iconSize, iconSize)
								end
							end
						end

						if self.GrantedDenied then
							local slide = isScanning and 1 or displayAccessAnim

							if isPIN then
								surface.SetDrawColor(self.BackgroundColor)
								surface.DrawRect(0, math.min(-ui_h * slide, 0), ui_w, ui_h)
							end

							surface.SetDrawColor(self.GrantedDenied == bKeypads.SCANNING_STATUS.GRANTED and self.GrantedForegroundColor or self.DeniedForegroundColor)
							surface.SetMaterial(self.GrantedDenied == bKeypads.SCANNING_STATUS.GRANTED and matTick or matCross)
							if isPIN then
								surface.DrawTexturedRect(scan_method_x, (-ui_h * slide) + ((ui_h - scan_method_h) / 2), scan_method_w, scan_method_h)
							else
								surface.DrawTexturedRect(scan_method_x, scan_method_y - (slideOffset * slide), scan_method_w, scan_method_h)
							end
						end
					end
				end
			end

			surface.SetAlphaMultiplier(1)

			--[[
			if mouseX and mouseY then
				print(mouseX, mouseY)

				surface.SetDrawColor(255,0,255)
				surface.DrawLine(mouseX, mouseY, mouseX, mouseY + 5) -- ^
				surface.DrawLine(mouseX, mouseY, mouseX + 5, mouseY) -- ->
				surface.DrawLine(mouseX, mouseY, mouseX - 5, mouseY) -- <-
				surface.DrawLine(mouseX, mouseY, mouseX, mouseY - 5) -- V
			end
			]]

			bKeypads:TVAnimation(self)
			self:Scissor2D()
		self.End3D2D()

		local pin_digits_num = self:GetPINDigitsInput()
		if isPIN and isIdle and pin_digits_num > 0 then
			self.Start3D2D(self:_LocalToWorld(mdl_keypad_led_pos_mins), ang, scale_3d2d)
				surface.SetAlphaMultiplier(ui_alpha)

				local pin_digits = pin_digits_num == 1 and "*" or ("* "):rep(pin_digits_num - 1) .. "*"

				surface.SetTextColor(bKeypads.COLOR.WHITE)
				surface.SetFont("bKeypads.PINAsterisk")
				local x,y = surface.GetTextSize(pin_digits)
				surface.SetTextPos((led_w - x) / 2, ((led_h - y) / 2) - asterisk_offset)
				surface.DrawText(pin_digits)

				--surface.SetDrawColor(255, 0, 0, 50)
				--surface.DrawRect(0, 0, led_w, led_h)

				surface.SetAlphaMultiplier(1)
			self.End3D2D()
		end

		if not isLoading and self.ColorAnimEnd then
			local hacked = (isBroken and not isHacked)
			if hacked or not isRainbow then
				local BackgroundTargetColor = hacked and bKeypads.Config.Appearance.ScreenColors.Hacked or self.BackgroundTargetColor
				if CurTime() <= self.ColorAnimEnd then
					self.BackgroundColor:SetUnpacked(
						Lerp(ColorAnimFrac, self.BackgroundAnimFrom.r, BackgroundTargetColor.r),
						Lerp(ColorAnimFrac, self.BackgroundAnimFrom.g, BackgroundTargetColor.g),
						Lerp(ColorAnimFrac, self.BackgroundAnimFrom.b, BackgroundTargetColor.b)
					)
				else
					self.BackgroundColor:SetUnpacked(
						BackgroundTargetColor.r,
						BackgroundTargetColor.g,
						BackgroundTargetColor.b
					)
				end
			else
				self.BackgroundColor:SetUnpacked(r, g, b)
			end
		end
	end

	local requiresPaymentFocus
	function ENT:DrawPayment3D2DUI()
		local canDraw, ui_alpha = self:CanDraw3D2D()
		if not canDraw then return end
		if self:GetBroken() or self:IsPlayerBehind(LocalPlayer()) then return end

		local playerLooking = LocalPlayer():GetEyeTrace().Entity == self

		local authMode   = self:GetAuthMode()
		local scanStatus = self:GetScanningStatus()
		local isFaceID   = authMode == bKeypads.AUTH_MODE.FACEID
		local isKeycard  = authMode == bKeypads.AUTH_MODE.KEYCARD
		local isIdle     = scanStatus == bKeypads.SCANNING_STATUS.IDLE
		local isScanning = scanStatus == bKeypads.SCANNING_STATUS.SCANNING

		local requiresPaymentTransmit = true
		if requiresPaymentFocus == self and not playerLooking then
			requiresPaymentFocus = nil
			requiresPaymentTransmit = false
		end

		local requiresPayment
		if self:EntIndex() ~= -1 then
			if requiresPaymentTransmit and requiresPaymentFocus ~= self and playerLooking and not isLoading then
				requiresPaymentFocus = self
				requiresPayment = bKeypads.Economy:RequiresPayment(self, true)
			else
				requiresPayment = bKeypads.Economy:RequiresPayment(self)
			end
		elseif self.m_bRequiresPayment ~= nil then
			requiresPayment = self.m_bRequiresPayment
		else
			requiresPayment = true
		end
		if (isFaceID or isKeycard) and self:GetPaymentAmount() > 0 and (isIdle or (isFaceID and isScanning)) and bKeypads.Economy:HasCashSystem() then
			local ang = self:GetAngles()
			ang:RotateAroundAxis(self:GetUp(), 90)
			ang:RotateAroundAxis(self:GetRight(), -90)

			local pos = self:OBBCenter()
			pos.z = self:OBBMaxs().z + .5

			local pos, ang = self:_LocalToWorld(pos), ang
			pos = pos - (ang:Forward() * ui_w_half * scale_3d2d)
			pos = pos - (ang:Right() * paymentPolyLeft[2].y * scale_3d2d)

			bKeypads.cam.IgnoreZ(playerLooking)
				self.Start3D2D(pos, ang, scale_3d2d)
					surface.SetAlphaMultiplier(ui_alpha)
					draw.NoTexture()

					if not requiresPayment or bKeypads.Economy:canAfford(LocalPlayer(), self:GetPaymentAmount()) then
						surface.SetDrawColor(45,203,112,170)
					else
						surface.SetDrawColor(215,0,0,170)
					end

					surface.DrawPoly(paymentPolyLeft)
					surface.DrawPoly(paymentPolyRight)
					surface.DrawPoly(paymentPoly)

					surface.SetFont("bKeypads.PaymentFont")
					local txt = bKeypads.Economy:formatMoney(self:GetPaymentAmount())
					local w, h = surface.GetTextSize(txt)

					if not requiresPayment then
						local zeroDollars = " " .. bKeypads.Economy:formatMoney(0)
						local zW, zH = surface.GetTextSize(zeroDollars)

						local combinedW = (w + zW + 10 + 5)

						surface.SetDrawColor(255, 255, 255, 150)
						surface.DrawRect((ui_w - combinedW) / 2, ((80 - math.max(h, zH)) / 2) + ((h - 4) / 2), w, 4)

						surface.SetTextColor(255, 255, 255, 150)
						surface.SetTextPos((ui_w - combinedW) / 2, ((80 - math.max(h, zH)) / 2))
						surface.DrawText(txt)

						surface.SetTextColor(255, 255, 255, 255)
						surface.DrawText(zeroDollars)
					else
						surface.SetTextColor(255, 255, 255, 255)
						surface.SetTextPos((ui_w - w) / 2, ((80 - h) / 2))
						surface.DrawText(txt)
					end

					surface.SetAlphaMultiplier(1)
				self.End3D2D()
			bKeypads.cam.IgnoreZ(false)

			return true
		end
	end

	function ENT:DrawKeypadLabel(drawingPaymentUI)
		local keypadName = self:GetKeypadName():Trim()
		if keypadName == "" and not self:GetDestructible() then return end

		local canDraw, ui_alpha = self:CanDraw3D2D()
		if not canDraw then return end

		local playerLooking = LocalPlayer():GetEyeTrace().Entity == self
		if playerLooking then
			local center = self:OBBCenter()
			local positioning = self:OBBCenter()
			local mins, maxs = self:GetModelBounds()

			mins.z = mins.z - .5
			mins.y = mins.y - .5
			maxs.z = maxs.z + .5
			maxs.y = maxs.y + .5
			if drawingPaymentUI then
				maxs.z = maxs.z - (paymentPoly[1].y * scale_3d2d) + .5
			end

			positioning.z = mins.z
			local top = self:_LocalToWorld(positioning)

			positioning.z = maxs.z
			local bottom = self:_LocalToWorld(positioning)

			positioning.z = center.z
			positioning.y = maxs.y
			local left = self:_LocalToWorld(positioning)

			positioning.z = center.z
			positioning.y = mins.y
			local right = self:_LocalToWorld(positioning)

			local pos = left
			if right.z >= pos.z then pos = right end
			if bottom.z >= pos.z then pos = bottom end
			if top.z >= pos.z then pos = top end

			local ang = (EyePos() - pos):Angle()
			ang:RotateAroundAxis(ang:Up(), 90)
			ang:RotateAroundAxis(ang:Forward(), 90)
			if self:GetSlanted() and self.HackedAngle then ang:RotateAroundAxis(ang:Up(), -self.HackedAngle) end

			local txtColor = self.CustomBackgroundColor or bKeypads.COLOR.WHITE
			if not bKeypads:DarkenForeground(txtColor) then
				txtColor = bKeypads.COLOR.WHITE
			end

			bKeypads.cam.IgnoreZ(true)
				self.Start3D2D(pos, ang, scale_3d2d)
					surface.SetAlphaMultiplier(ui_alpha)
						local offsetY = self:DrawHealth() or 0
						if keypadName ~= "" then draw.SimpleTextOutlined(keypadName, "bKeypads.KeypadLabelFont", 0, -offsetY + (math.min(offsetY, 1) * 20), txtColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, bKeypads.COLOR.BLACK) end
					surface.SetAlphaMultiplier(1)
				self.End3D2D()
			bKeypads.cam.IgnoreZ(false)
		end
	end

	local boneLocalToWorldVec = Vector()
	local function boneLocalToWorld(x, y, z, bonePos, boneAng)
		boneLocalToWorldVec.x, boneLocalToWorldVec.y, boneLocalToWorldVec.z = x,y,z
		return LocalToWorld(boneLocalToWorldVec, angle_zero, bonePos, boneAng)
	end

	local prevFrameManipulations
	local hideBone = Vector(0,0,0)
	local function showBones(ply, show)
		if not show then prevFrameManipulations = {} end

		for i=0,ply:GetBoneCount()-1 do
			local boneName = ply:GetBoneName(i)
			if boneName ~= "__INVALIDBONE__" and boneName ~= "ValveBiped.Bip01_Head1" and boneName ~= "ValveBiped.Bip01_Neck1" then
				if show then
					if prevFrameManipulations[i] then
						ply:ManipulateBoneScale(i, prevFrameManipulations[i])
					end
				else
					prevFrameManipulations[i] = ply:GetManipulateBoneScale(i)
					ply:ManipulateBoneScale(i, hideBone)
				end
			end
		end

		ply:SetupBones()

		if show then prevFrameManipulations = nil end
	end

	local beamColor = Color(255,255,255)

	local wireframeRange = Vector(5, 5, 5)

	local scanDeltaFallback     = Vector(-6, -0.4, 7)
	local scanPosFallbackOffset = Vector(5, 5, 5)
	local firstPersonScanOffset = Vector(4, 4, 4)

	function ENT:DrawScanningBeam()
		if self:GetScanningStatus() ~= bKeypads.SCANNING_STATUS.SCANNING or not self.ScanStart or self:LinkProxy():GetAuthMode() ~= bKeypads.AUTH_MODE.FACEID then return end

		local ply = self:GetScanningPlayer()
		if not IsValid(ply) then return end

		local cam_pos = self:GetCamPos()

		local scanCos = math.TimeFraction(self.ScanStart, self.ScanStart + bKeypads.Config.Scanning.ScanTimes.FaceID, CurTime())
		local scanAnim = math.cos(scanCos * 2 * math.pi)

		if self:ScanningBeamLOS(LocalPlayer()) then
			matLight:SetInt("$translucent", 1)
			matLight:Recompute()
			render.SetMaterial(matLight)
			render.DrawSprite(cam_pos, 32, 32, bKeypads.COLOR.WHITE)
		end

		if ply ~= LocalPlayer() or GetViewEntity() ~= LocalPlayer() then
			local scan_pos, beamDelta

			local head = ply:LookupBone("ValveBiped.Bip01_Head1")
			if head then
				local boneMatrix = ply:GetBoneMatrix(head)
				if boneMatrix then
					local headHitBox, headHitBoxGroup
					for group = 0, ply:GetHitboxSetCount()-1 do
						for hitbox = 0, ply:GetHitBoxCount(group)-1 do
							if ply:GetHitBoxBone(hitbox, group) == head then
								headHitBoxGroup, headHitBox = group, hitbox
								break
							end
						end
					end

					local mins, maxs
					if headHitBox and headHitBoxGroup then
						mins, maxs = ply:GetHitBoxBounds(headHitBox, headHitBoxGroup)
						mins = mins * ply:GetModelScale()
						maxs = maxs * ply:GetModelScale()
					end
					if mins and maxs then
						local ec = render.EnableClipping(true)

						local headPos, headAng = boneMatrix:GetTranslation(), boneMatrix:GetAngles()

						local scanTopBack = boneLocalToWorld(maxs.x, maxs.y, mins.z + maxs.z, headPos, headAng)
						local scanTopFront = boneLocalToWorld(maxs.x, mins.y, mins.z + maxs.z, headPos, headAng)

						local scanBottomBack = boneLocalToWorld(mins.x, maxs.y, mins.z + maxs.z, headPos, headAng)
						local scanBottomFront = boneLocalToWorld(mins.x, mins.y, mins.z + maxs.z, headPos, headAng)

						local beamRange = wireframeRange * ply:GetModelScale() * .5

						local scanTop    = cam_pos.z >= (scanTopFront.z + (scanTopFront:Angle():Up() * beamRange).z) and scanTopBack or scanTopFront
						local scanBottom = cam_pos.z >= (scanBottomFront.z - (scanBottomFront:Angle():Up() * beamRange).z) and scanBottomFront or scanBottomBack

						--[[render.DrawLine(cam_pos, scanTop, Color(255,0,0), false)
						render.DrawLine(cam_pos, scanBottom, Color(255,0,0), false)]]

						local scanDelta  = scanTop - scanBottom
						local scanCenter = scanTop - (scanDelta / 2)

						scan_pos = scanCenter + ((scanDelta / 2) * scanAnim)

						local beamTop    = scan_pos + ((scanTop - scan_pos):Angle():Forward() * beamRange)
						local beamBottom = scan_pos + ((scanBottom - scan_pos):Angle():Forward() * beamRange)

						--[[render.DrawLine(cam_pos, scan_pos, Color(0,0,255), false)
						render.DrawLine(cam_pos, beamTop, Color(0,255,0), false)
						render.DrawLine(cam_pos, beamBottom, Color(0,255,0), false)]]

						beamDelta = scan_pos - cam_pos

						-- Top beam clip
						local beamTopNormal = -headAng:Forward()
						render.PushCustomClipPlane(beamTopNormal, beamTopNormal:Dot(beamTop))
						-- Bottom beam clip
						local beamBottomNormal = headAng:Forward()
						render.PushCustomClipPlane(beamBottomNormal, beamBottomNormal:Dot(beamBottom))

						if system.IsWindows() then -- OSX/POSIX cannot handle more than 2 clip planes
							local boneForward, boneRight, boneUp = headAng:Forward(), headAng:Right(), headAng:Up()

							-- Clip bottom of head
							render.PushCustomClipPlane(boneForward, boneForward:Dot(scanBottomBack))

							-- Clip in front of head
							render.PushCustomClipPlane(-boneRight, -boneRight:Dot(boneLocalToWorld(mins.x, mins.y * 1.5, mins.z + maxs.z, headPos, headAng)))

							-- Clip right side of head
							render.PushCustomClipPlane(-boneUp, -boneUp:Dot(boneLocalToWorld(mins.x, maxs.y, maxs.z * 1.5, headPos, headAng)))

							-- Clip neck at 45 degrees
							local neckClip = Angle(headAng)
							neckClip:RotateAroundAxis(neckClip:Up(), 45)
							neckClip = neckClip:Right()
							render.PushCustomClipPlane(neckClip, neckClip:Dot(scanBottomBack))
						end

						render.SetBlend(math.Remap(math.cos((scanCos * 8 * math.pi) - math.pi), -1, 1, .01, 1))

						render.ModelMaterialOverride(wireframe)
							if not bKeypads.Performance:Optimizing() then showBones(ply, false) end
								ply:DrawModel()
							if not bKeypads.Performance:Optimizing() then showBones(ply, true) end
						render.ModelMaterialOverride(nil)

						render.PopCustomClipPlane()
						render.PopCustomClipPlane()
						if system.IsWindows() then
							render.PopCustomClipPlane()
							render.PopCustomClipPlane()
							render.PopCustomClipPlane()
							render.PopCustomClipPlane()
						end

						render.SetBlend(1)

						render.EnableClipping(ec)

						--[[render.SetColorMaterial()
						render.DrawQuadEasy(beamBottom, beamBottomNormal, 100, 100, Color(0,255,0,50), 0)
						render.DrawQuadEasy(beamTop, beamTopNormal, 100, 100, Color(255,0,0,50), 0)]]
					end
				end
			end

			if not scan_pos then
				scan_pos = (ply:EyePos() - (ply:EyeAngles():Up() * scanPosFallbackOffset)) + (((scanDeltaFallback * ply:GetModelScale()) / 2) * scanAnim)
				beamDelta = scan_pos - cam_pos
			end

			local beamNormal = beamDelta:Angle():Forward()
			local beamLength = beamDelta:Length()

			render.SetMaterial(matBeam)
			render.StartBeam(2)
				beamColor.a = 255 * 0.33
				render.AddBeam(cam_pos, 8, 0, beamColor)

				beamColor.a = 255
				render.AddBeam(cam_pos + beamNormal * beamLength, 8, .99, beamColor)
			render.EndBeam()
		else
			local scan_pos = ply:EyePos()
			scan_pos = scan_pos - (ply:EyeAngles():Up() * firstPersonScanOffset) * -scanAnim

			render.SetMaterial(matBeam)
			render.StartBeam(2)
				beamColor.a = 255 * 0.33
				render.AddBeam(cam_pos, 12, 0, beamColor)

				beamColor.a = 255
				render.AddBeam(scan_pos, 12, .35, beamColor)
			render.EndBeam()
		end
	end
end

function ENT:Sparks()
	if self:GetScanningStatus() == bKeypads.SCANNING_STATUS.LOADING or bKeypads.Performance:Optimizing() then return end

	local ang = self:GetAngles()
	ang:RotateAroundAxis(self:GetUp(), 90)
	ang:RotateAroundAxis(self:GetRight(), -90)

	local fx = EffectData()
	fx:SetEntity(self)
	fx:SetOrigin(LocalToWorld(self:OBBCenter(), angle_zero, self:GetPos(), ang))
	fx:SetRadius(1)
	fx:SetMagnitude(1)
	fx:SetScale(1)
	fx:SetNormal(ang:Up())
	util.Effect("cball_bounce", fx)

	self:EmitSound("ambient/energy/spark" .. math.random(1,6) .. ".wav", 60)
end

function ENT:BrokenStatusChanged(_, prevHacked, hacked)
	if prevHacked == hacked then return end

	self:CalculateForegroundColor()

	self.BackgroundAnimFrom = Color(self.BackgroundColor:Unpack())
	self.ForegroundAnimFrom = Color(self.ForegroundColor:Unpack())

	self.ColorAnimStart = CurTime()
	self.ColorAnimEnd = CurTime() + (.5 * .56)

	bKeypads.ESP:Refresh()

	if hacked then
		self:Sparks()
		timer.Start(self.SparksTimer)
	else
		timer.Stop(self.SparksTimer)
	end
end

function ENT:GetHoveredElement()
	-- if Willox's keypad is installed, error spam occurs if this isn't defined
end
function ENT:SendCommand()
	-- if Willox's keypad is installed, error spam occurs if this isn't defined
end

net.Receive("bKeypads.UseKeycard", function()
	notification.AddLegacy(bKeypads.Config.Keycards.InsertKeycardMessage, NOTIFY_ERROR, 2)
	surface.PlaySound("buttons/button14.wav")
end)

do
	local ScanDeniedSoundDuration = 0.69687074422836
	net.Receive("bKeypads.ScanDenied", function()
		local keypad = net.ReadEntity()
		if not keypad.ScanDenied or SysTime() > keypad.ScanDenied then
			keypad:EmitSound("buttons/button2.wav", 60)
			keypad.ScanDenied = SysTime() + ScanDeniedSoundDuration + .1
		end
	end)
end

do
	local invnext = input.LookupBinding("invnext", true)
	invnext = invnext and input.GetKeyCode(invnext)

	local invprev = input.LookupBinding("invprev", true)
	invprev = invprev and input.GetKeyCode(invprev)

	local function WasButtonPressed(code)
		if code >= MOUSE_FIRST and code <= MOUSE_LAST then
			return input.WasMousePressed(code)
		elseif code >= KEY_FIRST and code <= KEY_LAST then
			return input.WasKeyPressed(code)
		else
			return input.IsButtonDown(code)
		end
	end

	hook.Add("SetupMove", "bKeypads.KeypadUnlock", function(ply, mv, cmd)
		if IsValid(bKeypads.LOCKED_KEYPAD) then
			if invnext and WasButtonPressed(invnext) then
				RunConsoleCommand("invnext")
			elseif invprev and WasButtonPressed(invprev) then
				RunConsoleCommand("invprev")
			elseif not (cmd:GetForwardMove() ~= 0 or cmd:GetSideMove() ~= 0 or cmd:GetUpMove() ~= 0) then
				return
			end
			bKeypads.LOCKED_KEYPAD:FinishInteraction()
		end
	end)
end

do
	local keypadModelMesh

	local vtxstruct, physstruct
	local downloaded = false

	local drawing = false
	local function DrawFallbackModel()
		render.SetColorModulation(1,1,1)
		render.SetMaterial(wireframe)

		for _, keypad in ipairs(bKeypads.Keypads) do
			if not IsValid(keypad) then continue end

			local matrix = Matrix()
			matrix:Translate(keypad:GetPos())
			matrix:Rotate(keypad:GetAngles())
			matrix:ScaleTranslation(keypad:GetModelScale())

			cam.PushModelMatrix(matrix)
				keypadModelMesh:Draw()
			cam.PopModelMatrix()
		end
	end

	function ENT:CheckModel()
		if LeySexyErrors then return end

		local mdl = self:GetModel() or bKeypads.MODEL.KEYPAD
		if mdl == "models/error.mdl" or not util.IsValidModel(mdl) then
			if not downloaded then
				net.Start("bKeypads.KeypadModelFallback")
					net.WriteEntity(self)
				net.SendToServer()
			else
				self:DrawFallbackModel()
			end
		end
	end

	function ENT:DrawFallbackModel()
		self.m_DrawFallbackModel = true
		self:SetModel("models/Gibs/HGIBS.mdl")

		self:PhysicsInitMultiConvex(physstruct)

		if not drawing then
			hook.Add("PostDrawOpaqueRenderables", "bKeypads.KeypadModelFallback", DrawFallbackModel)
		end
	end

	net.Receive("bKeypads.KeypadModelFallback", function()
		local keypad = net.ReadEntity()

		vtxstruct = {}
		for i=1,net.ReadUInt(16) do
			vtxstruct[i] = { pos = net.ReadVector() }
		end

		physstruct = {}
		while net.ReadBool() do
			local convex = {}
			for i=1,net.ReadUInt(16) do
				convex[i] = { pos = net.ReadVector() }
			end
			table.insert(physstruct, convex)
		end

		keypadModelMesh = Mesh()
		keypadModelMesh:BuildFromTriangles(vtxstruct)

		downloaded = true
		if IsValid(keypad) then
			keypad:DrawFallbackModel()
		end
	end)
end

--## Destruction ##--

local PITCH_SHIFT = 255 - 100

function ENT:DrawHealth()
	if not self:GetDestructible() then return end
	if self:Health() > 0 then
		local w, h = (self:OBBMaxs().y - self:OBBMins().y) / scale_3d2d, 50
		bKeypads:DrawHealth(self, w, h)
		return (-50 * 2 * scale_3d2d) - 1.5
	else
		return 0
	end
end

local shootEmotes = {
	withShield = {
		"angry",
		"confused",
		"surprised"
	},

	withoutShield = {
		"shocked"
	}
}
function ENT:ImpactTrace(tr)
	if not self:GetDestructible() or self:GetShield() > 0 then
		self:Emote(shootEmotes.withShield[math.random(1, #shootEmotes.withShield)], 0.25)
	else
		self:Emote(shootEmotes.withoutShield[math.random(1, #shootEmotes.withoutShield)], 0.25)
	end

	if self:GetShield() > 0 then
		self.m_iDrawShield = CurTime()
		self.m_iDrawShieldDuration = nil
		self.m_BulletImpactPos = tr.HitPos

		self:EmitSound("weapons/physcannon/energy_bounce" .. math.random(1,2) .. ".wav", 60, 100 + (PITCH_SHIFT * .25))

		return true
	end
end

function ENT:ShieldBrokenEffect(duration)
	self.m_iDrawShield = CurTime()
	self.m_iDrawShieldDuration = duration
	self.m_BulletImpactPos = self:WorldSpaceCenter()
end

local function generateCircle(x, y, radius, seg)
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad(0)
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	return cir
end

local shieldMat = Material("models/props_combine/portalball001_sheet")
local bulletCircleMatrix, bulletLaggedCircleMatrix = Matrix(), Matrix()
local bulletCircleDuration = .5
local bulletCircle = {}
function ENT:DrawShield(scale_3d2d)
	if not self:GetDestructible() then return end

	local duration = self.m_iDrawShieldDuration or bulletCircleDuration
	if self.m_BulletImpactPos and self.m_iDrawShield and CurTime() <= self.m_iDrawShield + duration then
		self:RemoveAllDecals()

		local shieldBroken = self:GetShield() == 0

		local maxs = select(2, self:GetModelBounds())

		local scale = self:GetModelScale() or 1
		if not bulletCircle[scale] then
			bulletCircle[scale] = generateCircle(0, 0, (math.sqrt((maxs.y ^ 2) + (maxs.z ^ 2)) * 2) / scale_3d2d, 25)
		end

		local center = self:WorldSpaceCenter()
		local centerDist = math.sqrt(((center.y - self.m_BulletImpactPos.y) ^ 2) + ((center.z - self.m_BulletImpactPos.z) ^ 2))
		local circleRadius = math.sqrt((maxs.y ^ 2) + (maxs.z ^ 2))
		local circleScaleFactor = (centerDist + circleRadius) / (circleRadius * 2)

		local bulletCircleScalar = math.Remap(math.sin(math.TimeFraction(self.m_iDrawShield, self.m_iDrawShield + (duration / 2), CurTime())), -1, 1, 0, 1) * circleScaleFactor
		local bulletCircleLaggedScalar = math.Remap(math.sin(math.TimeFraction(self.m_iDrawShield + (duration / 2), self.m_iDrawShield + duration, CurTime())), -1, 1, 0, 1) * circleScaleFactor

		bulletCircleMatrix:SetUnpacked(
			bulletCircleScalar, 0, 0, 0,
			0, bulletCircleScalar, 0, 0,
			0, 0, bulletCircleScalar, 0,
			0, 0, 0, 1
		)

		bulletLaggedCircleMatrix:SetUnpacked(
			bulletCircleLaggedScalar, 0, 0, 0,
			0, bulletCircleLaggedScalar, 0, 0,
			0, 0, bulletCircleLaggedScalar, 0,
			0, 0, 0, 1
		)

		render.SetStencilWriteMask(0xFF)
		render.SetStencilTestMask(0xFF)
		render.SetStencilReferenceValue(0)
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)
		render.ClearStencil()

		render.SetStencilEnable(true)
		render.SetStencilReferenceValue(1)

		render.CullMode(self:IsPlayerBehind(LocalPlayer()) and MATERIAL_CULLMODE_CW or MATERIAL_CULLMODE_CCW)

		local ang = self:GetAngles()
		ang:RotateAroundAxis(self:GetUp(), 90)
		ang:RotateAroundAxis(self:GetRight(), -90)

		cam.IgnoreZ(true)
			self.Start3D2D(self.m_BulletImpactPos, ang, scale_3d2d)
				draw.NoTexture()
				surface.SetDrawColor(255, 255, 255)

				render.SetStencilCompareFunction(STENCIL_NEVER)
				if not shieldBroken then
					render.SetStencilFailOperation(STENCIL_REPLACE)

					cam.PushModelMatrix(bulletCircleMatrix, true)
						surface.DrawPoly(bulletCircle[scale])
					cam.PopModelMatrix()
				end

				render.SetStencilFailOperation(shieldBroken and STENCIL_REPLACE or STENCIL_INVERT)

				cam.PushModelMatrix(bulletLaggedCircleMatrix, true)
					surface.DrawPoly(bulletCircle[scale])
				cam.PopModelMatrix()
			self.End3D2D()
		cam.IgnoreZ(false)

		render.CullMode(MATERIAL_CULLMODE_CCW)

		render.SetStencilCompareFunction(shieldBroken and STENCIL_NOTEQUAL or STENCIL_EQUAL)
		render.SetStencilFailOperation(STENCIL_KEEP)

			render.SuppressEngineLighting(true)
				render.MaterialOverride(shieldMat)
					self:DrawModel()
				render.MaterialOverride(nil)
			render.SuppressEngineLighting(false)

		render.SetStencilEnable(false)
	end
end

net.Receive("bKeypads.PaymentPrompt", function()
	local keypad = net.ReadEntity()
	if not IsValid(keypad) then return end

	local amount = net.ReadUInt(32)
	local authMode = net.ReadBool()

	surface.PlaySound("common/warning.wav")

	local windowText
	if #keypad:GetKeypadName():Trim() > 0 then
		windowText = bKeypads.L("PaymentNamedPrompt"):format(keypad:GetKeypadName(), bKeypads.Economy:formatMoney(amount))
	else
		windowText = bKeypads.L("PaymentPrompt"):format(bKeypads.Economy:formatMoney(amount))
	end

	local Window = Derma_Query(windowText, bKeypads.L"PaymentPromptTitle", bKeypads.L"Yes", function()
		if not IsValid(keypad) then return end
		net.Start("bKeypads.PaymentPrompt")
			net.WriteEntity(keypad)
			net.WriteUInt(amount, 32) -- nope sorry buddy this isn't actually used as the payment amount
			net.WriteBool(authMode)
		net.SendToServer()
	end, bKeypads.L"No")

	Window:SetBackgroundBlur(false)

	Window:SetPos((ScrW() - Window:GetWide()) / 2, ScrH())
	local y = (ScrH() + Window:GetTall()) / 2
	Window:NewAnimation(1, 0, .25).Think = function(_, pnl, f)
		local f = bKeypads.ease.OutSine(f)

		local x = pnl:GetPos()
		pnl:SetPos(x, ScrH() - (y * f))

		pnl:SetAlpha(f * 255)
	end
end)

-- For overriding in tutorial render target
function ENT.Start3D2D(pos, ang, scale)
	cam.Start3D2D(pos, ang, scale)
end
function ENT.End3D2D()
	cam.End3D2D()
end
function ENT:Scissor2D(w, h)
	bKeypads.clip:Scissor2D(w, h)
end

function bKeypads:SlideText(keypads, text, time)
	for i, keypad in ipairs(keypads) do
		keypad.SlideText = {
			index = i,
			keypads = keypads,
			text = text,
			start = CurTime(),
			finish = CurTime() + time
		}
	end
end
concommand.Add("bkeypads_msg", function(ply, _, args)
	-- Just a little easter egg that allows me to put a sliding message across my keypads in-game :D
	-- Removing this won't break anything
	if not IsValid(ply) or ply:SteamID() ~= "STEAM_0:1:40314158" then return end

	local myKeypads = {}
	for _, keypad in ipairs(bKeypads.Keypads) do
		if keypad:GetKeypadOwner() == LocalPlayer() then
			table.insert(myKeypads, keypad)
		end
	end

	bKeypads:SlideText(myKeypads, table.concat(args, " ", 2), tonumber(args[1]))
end)