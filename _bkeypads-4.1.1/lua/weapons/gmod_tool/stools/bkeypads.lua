cleanup.Register("_bkeypads")

TOOL.Category = "Billy's Keypads"
TOOL.Name = "#bKeypads_SpawnMenuKeypad"

bKeypads_STOOL_CONVARS = {
	["name"] = "",

	["weld"] = 1,
	["freeze"] = 1,
	["wiremod"] = 0,
	["uncrackable"] = 0,

	["granted_hold_time"] = 5,
	["granted_initial_delay"] = 0,
	["granted_repeats"] = 0,
	["granted_repeat_delay"] = 0,

	["denied_hold_time"] = 1,
	["denied_initial_delay"] = 0,
	["denied_repeats"] = 0,
	["denied_repeat_delay"] = 0,

	["granted_key"] = 0,
	["denied_key"] = 0,
	["auth_mode"] = 1,

	["charge_unauthorized"] = 0,

	["background_color"] = 0x0096FF,
	["rainbow_background_color"] = 0,
	["image_url"] = "",

	["pin"] = "",

	["granted_notification"] = 1,
	["denied_notification"] = 0,

	["auto_fading_door"] = 1,
	["mirror"] = 0,
	["nocollide"] = 1,

	["indestructible"] = 0,
	["destructible"] = 0,
	["max_health"] = 200,
	["shield"] = 0,
}
for i, v in pairs(bKeypads_STOOL_CONVARS) do TOOL.ClientConVar[i] = v end

if CLIENT then
	TOOL.Information = nil
	TOOL.Information = {
		{ name = "create_update", icon = "gui/lmb.png", op = 0 },
		{ name = "copy", icon = "gui/rmb.png", op = 0 },
		{ name = "switch_linker", icon = "gui/r.png", op = 0 },
	}
end

function TOOL:LeftClick(tr)
	return bKeypads.STOOL.LeftClick(self, tr)
end

function TOOL:RightClick(tr)
	return bKeypads.STOOL.RightClick(self, tr)
end

function TOOL:Reload(tr)
	if CLIENT and IsFirstTimePredicted() then
		RunConsoleCommand("gmod_tool", "bkeypads_linker")
		surface.PlaySound("npc/combine_soldier/gear5.wav")
	end
	return false
end

function TOOL:AutoFadingDoor()
	if bKeypads.Config.KeypadOnlyFadingDoors and not bKeypads.Permissions:Cached(self:GetOwner(), "keypads/bypass_keypad_only_fading_doors") then
		return true, true
	end
	return self:GetClientNumber("auto_fading_door") == 1, false
end

local fadingDoorHalo
if CLIENT then
	hook.Remove("PreDrawHalos", "bKeypads.STOOL.AutoFadingDoor")

	fadingDoorHalo = {}
	local function AutoFadingDoorHalo()
		if not fadingDoorHalo then return end
		halo.Add(fadingDoorHalo, bKeypads.COLOR.GREEN, 1, 1, 1, true)
	end

	function TOOL:DrawHUD()
		if self.m_bBlockGhostEntity then return end
		local auto_fading_door, inform = self:AutoFadingDoor()
		if auto_fading_door then
			surface.SetFont("BudgetLabel")

			local tr = LocalPlayer():GetEyeTrace()
			if bKeypads.FadingDoors:CanFadingDoor(tr.Entity) then
				local txt = bKeypads.L"AutoFadingDoor"

				local colorFlash = math.Remap(math.cos(SysTime() * math.pi), -1, 1, 0, 1) * 255
				surface.SetTextColor(colorFlash, 255, colorFlash)

				local w = surface.GetTextSize(txt)
				surface.SetTextPos((ScrW() - w) / 2, (ScrH() / 2) + 20)
				surface.DrawText(txt)

				if fadingDoorHalo == nil or fadingDoorHalo[1] ~= tr.Entity then
					fadingDoorHalo = fadingDoorHalo or {}
					fadingDoorHalo[1] = tr.Entity
					hook.Add("PreDrawHalos", "bKeypads.STOOL.AutoFadingDoor", AutoFadingDoorHalo)
				end
				return
			elseif inform and (not IsValid(tr.Entity) or not tr.Entity.bKeypad) then
				local txt = bKeypads.L"KeypadOnlyFadingDoors"

				local colorFlash = math.Remap(math.cos(SysTime() * math.pi), -1, 1, 0, 1) * 255
				surface.SetTextColor(255, colorFlash, colorFlash)

				local w = surface.GetTextSize(txt)
				surface.SetTextPos((ScrW() - w) / 2, (ScrH() / 2) + 20)
				surface.DrawText(txt)
			end
		end
		if fadingDoorHalo ~= nil then
			fadingDoorHalo = nil
			hook.Remove("PreDrawHalos", "bKeypads.STOOL.AutoFadingDoor")
		end
	end
end

function TOOL:Deploy()
	self.m_bBlockGhostEntity = nil

	self:SetStage(0)
	self:SetOperation(0)
end

function TOOL:Holster()
	self.m_bBlockGhostEntity = true

	self:SetStage(0)
	self:SetOperation(0)
end

function TOOL:Deployed()
	self.m_bBlockGhostEntity = nil

	if CLIENT then
		fadingDoorHalo = nil
		hook.Add("PostDrawTranslucentRenderables", "bKeypads.Create.DrawProperties", self.DrawProperties)
	end
end

function TOOL:Holstered()
	if CLIENT then
		bKeypads.STOOL.BlockSpawnmenuClose = false

		fadingDoorHalo = nil
		hook.Remove("PostDrawTranslucentRenderables", "bKeypads.Create.DrawProperties")
		hook.Remove("PreDrawHalos", "bKeypads.STOOL.AutoFadingDoor")
	end

	self.m_bBlockGhostEntity = true
	self:ReleaseGhostEntity()
end
bKeypads_Prediction(TOOL)

local keypadThickness = Vector(0.4813505, 0.4813505, 0.4813505)
function TOOL:CalculateKeypadPos(tr)
	local tr = tr or self:GetOwner():GetEyeTrace()

	if not IsValid(tr.Entity) or tr.Entity:IsWorld() then

		local normAng = tr.HitNormal:Angle()
		local isWall = normAng:Up().z == 1

		local Pos, Angles = tr.HitPos, normAng

		if not isWall then
			local EyePosNoZ = self:GetOwner():EyePos()
			local PosNoZ = Vector(Pos)
			EyePosNoZ.z = 0
			PosNoZ.z = 0

			local eyeDelta = (math.floor(Angles:Forward().z) == -1 and (PosNoZ - EyePosNoZ) or (EyePosNoZ - PosNoZ)):Angle()
			Angles:RotateAroundAxis(Angles:Forward(), math.NormalizeAngle(math.Round(((eyeDelta.y - Angles.y) * math.Round(Angles:Forward().z)) / 90) * 90))
		end

		Pos = Pos + (tr.HitNormal:Angle():Forward() * keypadThickness)

		return Pos, Angles

	else

		local Pos, Angles = tr.HitPos, tr.HitNormal:Angle()
		Pos = Pos + (tr.HitNormal:Angle():Forward() * keypadThickness)

		return Pos, Angles

	end
end

do
	local developer = GetConVar("developer")
	local _debug = { render = { DrawLine = function(...)
		if CLIENT and developer:GetInt() > 1 then
			render.SetColorMaterialIgnoreZ()
			return render.DrawLine(...)
		end
	end, DrawBox = function(...)
		if CLIENT and developer:GetInt() > 1 then
			render.SetColorMaterialIgnoreZ()
			return render.DrawBox(...)
		end
	end } }

	local trInverseFilterEnt
	local trInverseFilter = function(ent) return ent == trInverseFilterEnt end

	local mirrorTrResult = {}
	local mirrorBounceTrResult = {}
	local mirrorTr = {
		ignoreworld = true,
		filter = trInverseFilter,
		mins = Vector(), maxs = Vector()
	}

	local function tryMirrorTrace(tool, keypad, tr, modelLength, _ang, _dn)
		mirrorTr.output = mirrorBounceTrResult

		local tr = mirrorTrResult

		local symmetryDir = tr.Entity:GetUp()
		local dn = _dn or mirrorTrResult.Normal:Dot(symmetryDir)
		local dnAbs = math.abs(dn)
		if dnAbs + 0.01 < 1 - 0.01 or dnAbs - 0.01 > 1 + 0.01 then
			local reflectionLength = (mirrorTr.endpos - mirrorTrResult.HitPos):Length() * .5
			local symmetryPoint = mirrorTr.endpos - (mirrorTrResult.Normal * reflectionLength)
			local R = (mirrorTrResult.Normal - 2 * dn * symmetryDir)

			_debug.render.DrawLine(mirrorTr.endpos, symmetryPoint, Color(0,255,0,255), false)
			_debug.render.DrawLine(symmetryPoint, symmetryPoint + (5 * symmetryDir), Color(0,255,255,255), false)
			_debug.render.DrawLine(symmetryPoint, symmetryPoint - (5 * symmetryDir), Color(0,255,255,255), false)

			local reflectedPos = symmetryPoint - (R * reflectionLength)
			_debug.render.DrawLine(symmetryPoint, reflectedPos, Color(0,255,255,255), false)

			mirrorTr.endpos = symmetryPoint
			mirrorTr.start = mirrorTr.endpos - (R * (reflectionLength + keypadThickness[1] + keypadThickness[1]))

			_debug.render.DrawLine(mirrorTr.endpos, mirrorTr.start, Color(255,0,255,255), false)

			util.TraceLine(mirrorTr)

			tr = mirrorBounceTrResult
		else
			local Pos = tool:CalculateKeypadPos(tr)

			local mins, maxs = keypad:GetCollisionBounds()

			local trPos = Vector(Pos)
			local thicc = maxs.x - mins.x
			thicc = Vector(thicc, thicc, thicc) * _ang:Forward()
			trPos:Add(thicc)

			mirrorTr.start, mirrorTr.endpos = trPos, trPos
			mirrorTr.mins:SetUnpacked(mins.x, mins.x, mins.x)
			mirrorTr.maxs:SetUnpacked(maxs.x, maxs.x, maxs.x)
			util.TraceHull(mirrorTr)

			_debug.render.DrawBox(trPos, angle_zero, mirrorTr.mins, mirrorTr.maxs, Color(255,0,0,25), false)

			if mirrorBounceTrResult.Entity == tr.Entity then return end

			return Pos, _ang
		end

		local Pos, Ang = tool:CalculateKeypadPos(tr)

		local __ang = Angle(_ang)
		__ang:SnapTo("p", 10) __ang:SnapTo("y", 10) __ang:SnapTo("r", 10)
		local _Ang = Angle(Ang)
		_Ang:SnapTo("p", 10) _Ang:SnapTo("y", 10) _Ang:SnapTo("r", 10)

		local delta = (__ang - _Ang)
		delta:Normalize()

		if delta.p < 90 and delta.p > -90 then
			return Pos, Ang
		elseif _dn == nil then
			return tryMirrorTrace(tool, keypad, tr, modelLength, _ang, -dn)
		end
	end

	function TOOL:CalculateMirroredKeypadPos(keypad, tr)
		local tr = tr or self:GetOwner():GetEyeTrace()

		mirrorTr.output = mirrorTrResult

		local ang = keypad:GetAngles()
		local _ang = Angle(ang)
		_ang:RotateAroundAxis(_ang:Up(), 180)

		local mins, maxs = tr.Entity:GetCollisionBounds()
		local modelLength = (mins - maxs):Length()

		trInverseFilterEnt = tr.Entity

		mirrorTr.endpos = keypad:WorldSpaceCenter()
		mirrorTr.start = mirrorTr.endpos - (keypad:GetForward() * modelLength)

		util.TraceLine(mirrorTr)

		if mirrorTrResult.Hit then
			return tryMirrorTrace(self, keypad, tr, modelLength, _ang)
		end
	end
end

if CLIENT then
	function TOOL.BuildCPanel(CPanel)
		return bKeypads.STOOL.BuildCPanel(CPanel)
	end

	local logoWhitePNG = Material("bkeypads/logo_tall_white.png", "noclamp smooth")
	local logoBlackPNG = Material("bkeypads/logo_tall_black.png", "noclamp smooth")

	local logoWhite, logoBlack

	function TOOL:DrawToolScreen(w,h)
		if not logoWhite or not logoBlack then
			logoWhite = CreateMaterial("bKeypads.LogoWhite", "UnlitGeneric", {
				["$ignorez"] = 1,
				["$translucent"] = 1
			})
			logoWhite:SetTexture("$basetexture", logoWhitePNG:GetName())
			logoWhite:Recompute()

			logoBlack = CreateMaterial("bKeypads.LogoBlack", "UnlitGeneric", {
				["$ignorez"] = 1,
				["$translucent"] = 1
			})
			logoBlack:SetTexture("$basetexture", logoBlackPNG:GetName())
			logoBlack:Recompute()
		end

		local backgroundColor = bKeypads:IntToColor(tonumber(self:GetClientNumber("background_color")) or 38655)

		surface.SetDrawColor(backgroundColor)
		surface.DrawRect(0,0,w,h)

		if not self.MatrixRain then
			self.MatrixRain = bKeypads_Matrix("STOOL_Screen_CustomBackgroundColor", w, h)
		end
		self.MatrixRain:ContrastRainColor(backgroundColor)
		self.MatrixRain:Draw(w,h)

		surface.SetDrawColor(255,255,255,255)
		bKeypads:DrawSubpixelClippedMaterial(
			bKeypads:GetLuminance(backgroundColor) >= 0.65 and logoBlack or logoWhite,
			(w - (w * .75)) / 2, (h - (h * .75)) / 2, w * .75, h * .75
		)

		if not bKeypads.Permissions:Cached(LocalPlayer(), "create_keypads") then
			bKeypads:ToolScreenNoPermission(w, h)
		elseif not bKeypads.STOOL:CheckLimit(LocalPlayer(), bKeypads.STOOL.LIMIT_KEYPADS) then
			bKeypads:ToolScreenWarning(bKeypads.L("SBoxLimit_bKeypads"), w, h)
		end
	end

	local propertiesW, propertiesPadding, propertiesScale = 300, 25, 0.05

	local gmod_toolmode
	local originAnim, sizeChanges, prevDirectionID, fadeAnimStart, slideAnimStart, slideAnimFrom
	local function KeypadPropertiesPerformLayout(self, w, h)
		DProperties.PerformLayout(self, w, h)

		if self:GetCanvas():GetVBar():IsVisible() then
			self:GetCanvas():SizeToChildren(false, true)
			self:SizeToChildren(false, true)
		end

		if sizeChanges == nil then
			sizeChanges = true
		end
	end
	function TOOL.DrawProperties(bDrawingDepth, bDrawingSkybox)
		if bDrawingSkybox then return end
		if not bKeypads.Settings:Get("draw_properties") then return end

		local self = LocalPlayer():GetTool("bkeypads")
		if not self then return end

		gmod_toolmode = gmod_toolmode or GetConVar("gmod_toolmode")

		local wep = LocalPlayer():GetActiveWeapon()
		if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" or gmod_toolmode:GetString() ~= "bkeypads" then return end

		local keypad = self.GhostEntity
		if not IsValid(keypad) or keypad:GetNoDraw() then
			slideAnimFrom = nil
			originAnim = nil
			return
		end

		local ConVarProperties = bKeypads.Properties:Update(nil, true)
		ConVarProperties.PerformLayout = KeypadPropertiesPerformLayout

		local ang = keypad:GetAngles()
		ang:RotateAroundAxis(keypad:GetUp(), 90)
		ang:RotateAroundAxis(keypad:GetRight(), -90)

		local center = keypad:LocalToWorld(keypad:OBBCenter())

		--render.SetColorMaterialIgnoreZ()
		--render.DrawBox(keypad:GetPos(), keypad:GetAngles(), keypad:OBBMins(), keypad:OBBMaxs(), Color(0,255,0,10), false)

		--render.DrawLine(keypad:GetPos(), keypad:GetPos() + (10 * keypad:GetUp()), Color(255,0,0), false)

		local propertiesH = ConVarProperties:GetTall()

		local origin, directionID = center

		local viewDelta = (keypad:GetAngles() - LocalPlayer():GetAngles()):Forward()
		if viewDelta.y >= -.33 and viewDelta.y <= .33 then

			local keypadH = keypad:OBBMaxs().z - keypad:OBBMins().z
			if viewDelta.z >= .66 then
				--print("top")
				origin = origin - (ang:Forward() * propertiesW * .5 * propertiesScale)
				origin = origin - (ang:Right() * ((keypadH * .5) + (propertiesH + propertiesPadding) * propertiesScale))
				directionID = 1
			else
				--print("bottom")
				--origin.z = keypad:LocalToWorld(keypad:OBBMaxs()).z
				origin = origin - (ang:Forward() * propertiesW * .5 * propertiesScale)
				origin = origin + (ang:Right() * ((keypadH * .5) + (propertiesPadding * propertiesScale)))
				directionID = 2
			end

		else
			origin = origin - (ang:Right() * propertiesH * .5 * propertiesScale)

			if viewDelta.y > 0 then
				--print("left")
				origin = origin + (ang:Forward() * (keypad:OBBMaxs().y + (propertiesPadding * propertiesScale)))
				directionID = 3
			else
				--print("right")
				origin = origin - (ang:Forward() * (keypad:OBBMaxs().y + ((propertiesPadding + propertiesW) * propertiesScale)))
				directionID = 4
			end
		end

		if bKeypads.Performance:Optimizing() then
			ConVarProperties:SetAlpha(255)

			originAnim = origin

			bKeypads.cam.IgnoreZ(true)
				cam.Start3D2D(origin, ang, propertiesScale)
					ConVarProperties:PaintManual()
				cam.End3D2D()
			bKeypads.cam.IgnoreZ(false)
		else

			fadeAnimStart = fadeAnimStart or SysTime()
			local fadeAnimFrac = bKeypads.ease.OutQuint(math.min(math.TimeFraction(fadeAnimStart, fadeAnimStart + 1, SysTime()), 1))
			ConVarProperties:SetAlpha(255 * fadeAnimFrac)

			if directionID ~= prevDirectionID or not slideAnimFrom then
				slideAnimStart = SysTime()
				slideAnimFrom = originAnim or origin
			end

			local slideAnimFrac = bKeypads.ease.OutQuint(math.min(math.TimeFraction(slideAnimStart, slideAnimStart + 1, SysTime()), 1))
			if sizeChanges then
				if keypad == prevKeypad then
					slideAnimFrom = origin
					sizeChanges = nil
				else
					sizeChanges = false
				end
			end

			originAnim = LerpVector(slideAnimFrac, slideAnimFrom, origin)

			bKeypads.cam.IgnoreZ(true)
				cam.Start3D2D(originAnim, ang, propertiesScale)
					ConVarProperties:PaintManual()
				cam.End3D2D()
			bKeypads.cam.IgnoreZ(false)
		end

		prevDirectionID = directionID
	end
	if hook.GetTable()["PostDrawTranslucentRenderables"] and hook.GetTable()["PostDrawTranslucentRenderables"]["bKeypads.Create.DrawProperties"] then
		hook.Remove("PostDrawTranslucentRenderables", "bKeypads.Create.DrawProperties")
		hook.Add("PostDrawTranslucentRenderables", "bKeypads.Create.DrawProperties", TOOL.DrawProperties)
	end
end

if CLIENT then
	function TOOL:UpdateGhostKeypad(ent, ply)
		if not IsValid(ent) or not IsValid(ply) then return end

		local tr = bKeypads:GetToolTrace(ply)
		if not tr.Hit or (bKeypads.Config.KeypadOnlyFadingDoors and not bKeypads.Permissions:Cached(ply, "keypads/bypass_keypad_only_fading_doors") and not bKeypads.FadingDoors:CanFadingDoor(tr.Entity)) or (IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity.bKeypad)) then
			ent:SetNoDraw(true)
			return
		end

		local Pos, Ang = self:CalculateKeypadPos(tr)
		ent:SetPos(Pos)
		ent:SetAngles(Ang)
		ent:SetNoDraw(false)
		ent.TraceResult = tr

		local authMode = self:GetClientNumber("auth_mode")
		ent:SetBodygroup(bKeypads.BODYGROUP.CAMERA, authMode == bKeypads.AUTH_MODE.FACEID and 1 or 0)
		ent:SetBodygroup(bKeypads.BODYGROUP.KEYCARD_SLOT, authMode == bKeypads.AUTH_MODE.KEYCARD and 1 or 0)
	end

	local function GhostEntityRenderOverride(self)
		render.SuppressEngineLighting(true)
			if bKeypads.Config.KeypadMirroring and self.TOOL and self.TOOL:GetClientNumber("mirror") == 1 and bKeypads.Permissions:Cached(LocalPlayer(), "mirror_keypads") and self.TraceResult and IsValid(self.TraceResult.Entity) then
				local pos, ang = self:GetPos(), self:GetAngles()
				local mirrorPos, mirrorAng = self.TOOL:CalculateMirroredKeypadPos(self, self.TraceResult)
				if mirrorPos and mirrorAng then
					bKeypads.cam.IgnoreZ(true)
						self:SetPos(mirrorPos)
						self:SetAngles(mirrorAng)
						self:SetupBones()
						self:DrawModel()
					bKeypads.cam.IgnoreZ(false)

					self:SetPos(pos)
					self:SetAngles(ang)
					self:SetupBones()
				end
			end
			self:DrawModel()
		render.SuppressEngineLighting(false)
	end
	function TOOL:Think()
		if not self.m_bBlockGhostEntity then
			if not IsValid(self.GhostEntity) then
				local Pos, Ang = self:CalculateKeypadPos()
				self:MakeGhostEntity(bKeypads.MODEL.KEYPAD, Pos, Ang)

				if IsValid(self.GhostEntity) then
					self.GhostEntity.bKeypadOff = true
					self.GhostEntity.RenderOverride = GhostEntityRenderOverride
					self.GhostEntity:SetSubMaterial(4, "models/bkeypads/keypad_screen")
					self.GhostEntity.TOOL = self
				end
			end
			self:UpdateGhostKeypad(self.GhostEntity, self:GetOwner())
		end
	end
end