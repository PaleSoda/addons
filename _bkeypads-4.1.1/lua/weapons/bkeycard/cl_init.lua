include("shared.lua")

function SWEP:Reload()
	if IsFirstTimePredicted() and LocalPlayer():KeyPressed(IN_RELOAD) then
		if IsValid(bKeypads_Keycard_Inventory) then
			bKeypads_Keycard_Inventory:Remove()
			surface.PlaySound("weapons/smg1/switch_single.wav")
		elseif not self:GetBeingScanned() then
			local heldKeycards = bKeypads.Keycards.Inventory:GetHeldKeycards(LocalPlayer())
			if bKeypads.Config.Keycards.CanDropKeycard then
				if not self:GetWasPickedUp() or heldKeycards then
					bKeypads.Keycards.Inventory:Show()
				end
			else
				if heldKeycards and (not self:GetWasPickedUp() or next(heldKeycards, next(heldKeycards))) then
					bKeypads.Keycards.Inventory:Show()
				end
			end
		end
	end
	return true
end

do
	local WorldModelPos = Vector(5.5, -2.5, -1.5)
	local WorldModelAng = Angle(5, 0, 10)

	-- x = forward
	-- y = right
	-- z = down
	local KeycardSlotPosMins = Vector(-0.04, 0, 5.6)

	function SWEP:DrawWorldKeycard(keypad)
		if not IsValid(self.ClientWorldModel) then return end

		local ply = self:GetOwner()
		if IsValid(ply) then
			self.ClientWorldModel:SetOwner(ply)

			local pos, ang
			if keypad then
				pos = keypad:GetPos()
				ang = keypad:GetAngles()

				pos = keypad:LocalToWorld(KeycardSlotPosMins)

				ang:RotateAroundAxis(ang:Up(), 180)
				ang:RotateAroundAxis(ang:Right(), 90)

				self.ClientWorldModel:SetModelScale(0.74)
			else
				self.ClientWorldModel:SetModelScale(1)

				local boneID = ply:LookupBone("ValveBiped.Bip01_R_Hand")
				if not boneID then return end

				local boneMatrix = ply:GetBoneMatrix(boneID)
				if not boneMatrix then return end

				pos, ang = LocalToWorld(WorldModelPos, WorldModelAng, boneMatrix:GetTranslation(), boneMatrix:GetAngles())
			end

			self.ClientWorldModel:SetPos(pos)
			self.ClientWorldModel:SetAngles(ang)

			self.ClientWorldModel:DrawModel()
		else
			self.ClientWorldModel:SetOwner(NULL)

			self.ClientWorldModel:SetPos(self:GetPos())
			self.ClientWorldModel:SetAngles(self:GetAngles())

			self.ClientWorldModel:DrawModel()
		end

		self:DrawIdentification(self.ClientWorldModel)
		bKeypads.Keycards.Textures:Draw(bKeypads.Keycards.Textures.BOTH, self.ClientWorldModel, self)
	end
end

function SWEP:DrawWorldModel()
	if not self:GetBeingScanned() then
		self:DrawWorldKeycard()
	end
end
SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel

function SWEP:ShouldDrawViewModel()
	return self:GetBeingScanned() ~= true
end

function SWEP:DoDrawCrosshair()
	return self:GetBeingScanned()
end

function SWEP:DrawIdentification(keycard)
	if not bKeypads.Config.Keycards.ShowID.AllowIndentification then return end
	if halo.RenderedEntity() == self or halo.RenderedEntity() == keycard or not IsValid(self:GetOwner()) then return end

	local alpha_3d2d = (bKeypads.Performance:Optimizing() and bKeypads.Performance:Alpha3D2D(EyePos():DistToSqr(keycard:LocalToWorld(keycard:OBBCenter()))) or 1) * 255
	if alpha_3d2d == 0 then return end

	if not self:GetBeingScanned() and (self:GetIdentifying() or (self.IdentifyingAnimEnd and SysTime() <= self.IdentifyingAnimEnd)) then
		self:DrawIdentificationBubble(alpha_3d2d, keycard)
	end
end

do
	surface.CreateFont("bKeypads.ID.Identification", {
		font = "Verdana",
		size = 100,
		weight = 700,
		shadow = true
	})

	local bubbleWorldOffset = Vector(0,0,1.5)
	local bubbleViewOffset  = Vector(1,1,1)

	local bubbleWidth, bubblePadding = 2250, 100
	local bubbleTailWidth, bubbleTailHeight, bubbleTailPoly = 100, 75, {{},{},{}}

	function SWEP:DrawIdentificationBubble(alpha_3d2d, keycard)
		if not self.IdentifyingAnimStart or not self.IdentifyingAnimEnd then return end

		local viewEnt = GetViewEntity()
		if not IsValid(viewEnt) then return end

		local viewOrigin = viewEnt:IsPlayer() and viewEnt:EyePos() or viewEnt:GetPos()

		local pos, ang, scale = keycard:LocalToWorld(keycard:OBBCenter())

		if keycard == self.ClientViewModel then
			scale = .005

			ang = EyeAngles()

			ang:RotateAroundAxis(ang:Forward(), 90)
			ang:RotateAroundAxis(ang:Right(), 90)
			ang:RotateAroundAxis(ang:Right(), -15)

			pos = pos - (ang:Right() * bubbleViewOffset)
		else
			scale = .01

			pos = pos + bubbleWorldOffset

			ang = (pos - viewOrigin):Angle()
			ang:RotateAroundAxis(ang:Forward(), 90)
			ang:RotateAroundAxis(ang:Right(), 90)
		end

		local dist = viewOrigin:DistToSqr(pos)
		local distFrac = math.Clamp(1 - (dist / bKeypads.Config.Keycards.ShowID.Distance), 0, 1)
		local animFrac = math.abs(self.IdentifyingAnim - math.min(math.TimeFraction(self.IdentifyingAnimStart, self.IdentifyingAnimEnd, SysTime()), 1))
		local borderFrac = distFrac * animFrac * math.Clamp(1 - (dist / 10000), 0.05, 1)

		local bubble_alpha = distFrac * animFrac * (alpha_3d2d / 255)
		if (bubble_alpha == 0) then return end

		cam.Start3D2D(pos, ang, scale)
			surface.SetAlphaMultiplier(bubble_alpha)

			draw.NoTexture()

			local txt = self:GetShowIDMessage()

			local w,h = txt:GetWidth(), txt:GetHeight()
			local totalW, totalH = w + bubblePadding, h + bubblePadding
			local centerOffset = totalW / 2

			surface.SetDrawColor(0,0,0,200)
			surface.DrawRect(-centerOffset, -totalH, totalW, totalH)

			bubbleTailPoly[1].x = -bubbleTailWidth / 2
			bubbleTailPoly[1].y = 0
			bubbleTailPoly[2].x = bubbleTailWidth / 2
			bubbleTailPoly[2].y = 0
			bubbleTailPoly[3].x = 0
			bubbleTailPoly[3].y = bubbleTailHeight
			surface.DrawPoly(bubbleTailPoly)

			txt:Draw((bubblePadding / 2) - centerOffset, (bubblePadding / 2) - totalH)

			surface.SetAlphaMultiplier(borderFrac)
			surface.SetDrawColor(keycard:GetKeycardColor())
			surface.DrawLine(-centerOffset, -totalH, totalW - centerOffset, -totalH)
			surface.DrawLine(-centerOffset, -totalH, -centerOffset, 0)
			surface.DrawLine(totalW - centerOffset, -totalH, totalW - centerOffset, 0)

			surface.DrawLine(-centerOffset, 0, bubbleTailPoly[1].x, 0)
			surface.DrawLine(bubbleTailPoly[2].x, 0, totalW - centerOffset, 0)
			surface.DrawLine(bubbleTailPoly[1].x, 0, 0, bubbleTailPoly[3].y)
			surface.DrawLine(0, bubbleTailPoly[3].y, bubbleTailPoly[2].x, 0)

			surface.SetAlphaMultiplier(1)
		cam.End3D2D()
	end

	do
		local markupSafeShowIDMessage
		local function escapeShowIDMessage()
			markupSafeShowIDMessage = bKeypads.Config.Keycards.ShowID.MessageMarkup and bKeypads.Config.Keycards.ShowID.Message or bKeypads.markup.Escape(bKeypads.Config.Keycards.ShowID.Message)
		end
		escapeShowIDMessage()
		hook.Add("bKeypads.ConfigUpdated", "bKeypads.ShowIDMessage", escapeShowIDMessage)

		local function getKeycardTeamName(ply, plyTeam)
			if DarkRP and RPExtraTeams and RPExtraTeams[plyTeam] and RPExtraTeams[plyTeam].KeycardIdentifiesAs ~= nil then
				return tostring(RPExtraTeams[plyTeam].KeycardIdentifiesAs)
			end
			return DarkRP and bKeypads.Config.Keycards.ShowCustomJobName and ply.getDarkRPVar and ply:getDarkRPVar("job") or team.GetName(plyTeam)
		end

		function SWEP:GetShowIDMessage()
			local ply = self:GetOwner()
			local plyTeam = ply:Team()
			local str = (
				markupSafeShowIDMessage
				:gsub("%%keycard%%",   "<color=" .. bKeypads.markup.Color(self:GetKeycardColor()) .. ">" .. bKeypads.markup.Escape(self:GetKeycardName()) .. "</color>")
				:gsub("%%level%%",     "<color=" .. bKeypads.markup.Color(self:GetKeycardColor()) .. ">" .. bKeypads.markup.Escape(self:GetPrimaryLevel()) .. "</color>")
				:gsub("%%name%%",      "<color=" .. bKeypads.markup.Color(team.GetColor(plyTeam)) .. ">" .. bKeypads.markup.Escape(ply:Nick()) .. "</color>")
				:gsub("%%team%%",      "<color=" .. bKeypads.markup.Color(team.GetColor(plyTeam)) .. ">" .. bKeypads.markup.Escape(getKeycardTeamName(ply, plyTeam)) .. "</color>")
				:gsub("%%usergroup%%", "<color=" .. bKeypads.markup.Color(self:GetKeycardColor()) .. ">" .. bKeypads.markup.Escape(ply:GetUserGroup()) .. "</color>")
			)
			if self.ShowIDMessage ~= str then
				self.ShowIDMessage = markup.Parse("<font=bKeypads.ID.Identification>" .. str .. "</font>", bubbleWidth)
			end
			return self.ShowIDMessage
		end
	end

	function SWEP:IdentifyingStatusChanged(_, __, isIdentifying)
		if not bKeypads.Config.Keycards.ShowID.AllowIndentification then return end
		if self:GetBeingScanned() then return end

		local viewEnt = GetViewEntity()
		if not IsValid(viewEnt) then return end

		local distFrac
		if viewEnt == LocalPlayer() or not IsValid(self.ClientWorldModel) then
			distFrac = 1
		else
			local viewOrigin = viewEnt:IsPlayer() and viewEnt:EyePos() or viewEnt:GetPos()

			local pos = self.ClientWorldModel:LocalToWorld(self.ClientWorldModel:OBBCenter()) + bubbleWorldOffset
			local dist = viewOrigin:DistToSqr(pos)
			distFrac = math.Clamp(1 - (dist / bKeypads.Config.Keycards.ShowID.Distance), 0, 1)
		end

		self:EmitSound(isIdentifying and "buttons/button9.wav" or "buttons/combine_button1.wav", nil, nil, distFrac)

		self.IdentifyingAnimStart = SysTime()
		self.IdentifyingAnimEnd = SysTime() + (isIdentifying and .1 or .5)
		self.IdentifyingAnim = isIdentifying and 0 or 1
	end
end

surface.CreateFont("bKeypads.ID.WeaponSelection.Level", {
	font = "Consolas",
	shadow = true,
	size = 22
})

surface.CreateFont("bKeypads.ID.WeaponSelection.Name", {
	font = "Consolas",
	weight = 700,
	bold = true,
	shadow = true,
	size = 24
})

local refresh = true
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	if refresh then
		refresh = nil
		if IsValid(self.WeaponSelection) then
			self.WeaponSelection:Remove()
		end
	end
	if not IsValid(self.WeaponSelection) then
		self.WeaponSelection = vgui.Create("DModelPanel")
		self.WeaponSelection:SetMouseInputEnabled(false)
		self.WeaponSelection:SetPaintedManually(true)
		self.WeaponSelection:SetModel(bKeypads.MODEL.KEYCARD)

		local mn, mx = self.WeaponSelection.Entity:GetRenderBounds()
		local size = 0
		size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
		size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
		size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

		self.WeaponSelection:SetFOV(60)
		self.WeaponSelection:SetCamPos(Vector(size, size, size))
		self.WeaponSelection:SetLookAt((mn + mx) * 0.5)

		self.WeaponSelection.Entity.bKeycard = true
		self.WeaponSelection.PreDrawModel = function()
			self.WeaponSelection.Entity.KeycardColor = self:GetKeycardColor()
			bKeypads.Keycards.Textures:Draw(bKeypads.Keycards.Textures.TOP, self.WeaponSelection.Entity, self)
		end
	end

	self.WeaponSelection:SetSize(w, h)
	self.WeaponSelection:SetPos(x, y)
	self.WeaponSelection:PaintManual()

	local levels = self:GetLevels()
	if #levels > 1 and #levels < 9 then
		surface.SetFont("bKeypads.ID.WeaponSelection.Level")
		local levels_x = x + (((((25 + 5) * #levels) - 5) + w) / 2)
		for i, level in ipairs(levels) do
			local level_x, level_y = levels_x - (i * 25) - ((i - 1) * 5), y + h - 25 - 30
			surface.SetDrawColor(0,0,0,150)
			surface.DrawRect(level_x, level_y, 25, 25)

			surface.SetTextColor(bKeypads.Keycards.Levels[level].Color or color_white)
			local txtW, txtH = surface.GetTextSize(tostring(level))
			surface.SetTextPos(level_x + ((25 - txtW) / 2), level_y + ((25 - txtH) / 2))
			surface.DrawText(level)
		end
	else
		local keycardMetadata = self:GetKeycardMetadata()
		local txt = keycardMetadata.Name or bKeypads.L("KeycardLevel"):format(tonumber(self:GetKeycardLevel()) or 1)
		surface.SetFont("bKeypads.ID.WeaponSelection.Name")
		surface.SetTextColor(keycardMetadata.Color)
		local txtW, txtH = surface.GetTextSize(txt)
		surface.SetTextPos(x + ((w / 2) - (txtW / 2)), y + h - txtH * 2 - 10)
		surface.DrawText(txt)
	end

	if self.Instructions ~= bKeypads.L("KeycardInstructions") then -- hacky fix for weapon info not handling language strings properly
		self.Instructions = bKeypads.L("KeycardInstructions")
		self.InfoMarkup = nil
	end
	self:PrintWeaponInfo(x + w + 20, y + h * 0.95, alpha)
end

local ViewModelPos = Vector(5.5,-1.4,-1.9)
function SWEP:PreDrawViewModel(vm, _, ply)
	if IsValid(self.ClientViewModel) then
		self.ClientViewModel:SetOwner(ply)

		local boneID = vm:LookupBone("ValveBiped.Bip01_R_Hand")
		if not boneID then return end

		local boneMatrix = vm:GetBoneMatrix(boneID)
		if not boneMatrix then return end

		local pos, ang = LocalToWorld(ViewModelPos, angle_zero, boneMatrix:GetTranslation(), boneMatrix:GetAngles())

		self.ClientViewModel:SetPos(pos)
		self.ClientViewModel:SetAngles(ang)
		self.ClientViewModel:DrawModel()

		self:DrawIdentification(self.ClientViewModel)

		bKeypads.Keycards.Textures:Draw(bKeypads.Keycards.Textures.BOTTOM, self.ClientViewModel, self)
	end
end
