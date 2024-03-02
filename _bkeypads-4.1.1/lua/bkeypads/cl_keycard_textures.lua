if IsValid(bKeypads_Keycards_TextureSkeleton) then
	bKeypads_Keycards_TextureSkeleton:Remove()
end

bKeypads.Keycards.Textures = {}

bKeypads.Keycards.Textures.KeycardImage = {}

bKeypads.Keycards.Textures.TOP    = 1
bKeypads.Keycards.Textures.BOTTOM = 2
bKeypads.Keycards.Textures.BOTH   = bit.bor(bKeypads.Keycards.Textures.TOP, bKeypads.Keycards.Textures.BOTTOM)

function bKeypads.Keycards.Textures:Apply(keycard, orientation, keycardHash)
	if not keycard.m_KeycardTextures then
		keycard.m_KeycardTextures = {}
	end
	if keycard.m_KeycardTextures[orientation] ~= keycardHash then
		keycard.m_KeycardTextures[orientation] = keycardHash

		-- FIXME https://github.com/Facepunch/garrysmod-issues/issues/3362
		if keycard:EntIndex() == -1 then
			keycard:SetSubMaterial(orientation, nil)
			keycard:SetSubMaterial(orientation, "!bKeypads_Keycard_" .. keycardHash .. "_" .. orientation)
		else
			timer.Simple(1, function() bKeypads:nextTick(function()
				if not IsValid(keycard) then return end
				keycard:SetSubMaterial(orientation, nil)
				keycard:SetSubMaterial(orientation, "!bKeypads_Keycard_" .. keycardHash .. "_" .. orientation)
			end) end)
		end
	end
end

local scale = .01
local magstripeHeight = 0.69
local keycardPad = 0.13
local _keycardPad = math.floor(keycardPad / scale)

do
	local keycardMins, keycardMaxs = Vector(-2.573145, -1.541140, -0.028437), Vector(2.573145, 1.541140, 0.028437)

	local keycardW = math.floor((keycardMaxs.x - keycardMins.x) / scale)
	local keycardH = math.floor((keycardMaxs.y - keycardMins.y - magstripeHeight) / scale)

	function bKeypads.Keycards.Textures:GetDimensions(mins, maxs)
		if mins and maxs then
			return math.floor((maxs.x - mins.x) / scale),
			       math.floor((maxs.y - mins.y - magstripeHeight) / scale)
		else
			return keycardW, keycardH
		end
	end

	bKeypads.Keycards.Textures.DimensionsDirty = true
	function bKeypads.Keycards.Textures:UpdateDimensions(mins, maxs)
		keycardW = math.floor((maxs.x - mins.x) / scale)
		keycardH = math.floor((maxs.y - mins.y - magstripeHeight) / scale)
		bKeypads.Keycards.Textures.DimensionsDirty = nil
	end
end

do
	local function BlackBackgroundPaint(self, w, h)
		surface.SetDrawColor(0, 0, 0)
		surface.DrawRect(0, 0, w, h)
	end
	local function ImageContainerPaint(self, w, h)
		surface.SetDrawColor(bKeypads.Config.Keycards.KeycardImage.BackgroundColor)
		surface.DrawRect(0, 0, w, h)
	end
	local function Identification_PerformLayout(self, w, h)
		self.Model:SetSize(w, w)
		self.ImageContainer:SetSize(w, w)
		self.ImageContainer:AlignBottom(0)
	end
	local function LevelsPaint(self, w, h)
		surface.SetTextColor(255, 255, 255)
		local levelBoxSize = (h - _keycardPad) / 2
		for i = 1, math.min(#self.m_Levels, 11) do
			local level = self.m_Levels[i]

			local x
			if self:GetParent():GetParent().Orientation == bKeypads.Keycards.Textures.TOP then
				x = ((i - 1) % 6) * (levelBoxSize + _keycardPad)
			else
				x = w - levelBoxSize - (((i - 1) % 6) * (levelBoxSize + _keycardPad))
			end

			local y = (math.floor(i / 7) * (levelBoxSize + _keycardPad)) + (#self.m_Levels < 6 and (h - levelBoxSize) or 0)

			surface.SetDrawColor(0,0,0,200)
			surface.DrawRect(x, y, levelBoxSize, levelBoxSize)

			surface.SetDrawColor((bKeypads.Keycards.Levels[level] or bKeypads.Keycards.Levels[1]).Color or bKeypads.Keycards.Levels[1].Color)
			surface.DrawOutlinedRect(x, y, levelBoxSize, levelBoxSize, 2)

			surface.SetFont(level <= 9 and "bKeypads.Keycards.3D2D.Levels.1" or "bKeypads.Keycards.3D2D.Levels.2")
			local txtW, txtH = surface.GetTextSize(tostring(level))
			surface.SetTextPos(x + ((levelBoxSize - txtW) / 2), y + ((levelBoxSize - txtH) / 2))
			surface.DrawText(level)
		end
	end
	local function Get3D2DPanel()
		if not IsValid(bKeypads_Keycards_TextureSkeleton) then
			bKeypads_Keycards_TextureSkeleton = vgui.Create("DPanel")

			local skeleton = bKeypads_Keycards_TextureSkeleton
			skeleton.Paint = nil
			skeleton:SetPaintedManually(true)
			skeleton:SetRenderInScreenshots(false)
			skeleton:DockPadding(_keycardPad, _keycardPad, _keycardPad, _keycardPad)

				skeleton.Content = vgui.Create("DPanel", skeleton)
				skeleton.Content.Paint = nil
				skeleton.Content:Dock(FILL)

					skeleton.Level = vgui.Create("DLabel", skeleton.Content)
					skeleton.Level:Dock(TOP)
					skeleton.Level:SetFont("bKeypads.Keycards.3D2D.Level")

					skeleton.Team = vgui.Create("DLabel", skeleton.Content)
					skeleton.Team:Dock(TOP)
					skeleton.Team:SetFont("bKeypads.Keycards.3D2D.Team")

					skeleton.Levels = vgui.Create("DPanel", skeleton.Content)
					skeleton.Levels:Dock(BOTTOM)
					skeleton.Levels:DockMargin(0, _keycardPad, 0, 0)
					skeleton.Levels.Paint = LevelsPaint

				skeleton.Identification = vgui.Create("DPanel", skeleton)
				skeleton.Identification.Paint = nil
				skeleton.Identification.PerformLayout = Identification_PerformLayout

					skeleton.Identification.Model = vgui.Create("SpawnIcon", skeleton.Identification)
					skeleton.Identification.Model.PaintOver = skeleton.Identification.Model.Paint
					skeleton.Identification.Model.Paint = BlackBackgroundPaint

					skeleton.Identification.ImageContainer = vgui.Create("DPanel", skeleton.Identification)
					skeleton.Identification.ImageContainer.Paint = ImageContainerPaint

					skeleton.Identification.Image = vgui.Create("DImage", skeleton.Identification.ImageContainer)
					skeleton.Identification.Image:Dock(FILL)
					skeleton.Identification.Image:SetVisible(false)

					skeleton.Identification.Avatar = vgui.Create("AvatarImage", skeleton.Identification.ImageContainer)
					skeleton.Identification.Avatar:Dock(FILL)
					skeleton.Identification.Avatar:SetVisible(false)
		end

		return bKeypads_Keycards_TextureSkeleton
	end

	-- Track each keycard's materials and enforce their $basetexture to be the correct RT
	local RT_ID_Materials = {}

	-- ID of any new RTs
	local RT_Pool_Count = 0

	-- Reserved RTs - these are being used for the next draw operation
	local RT_Pool_Reservations = {}

	-- Spare RTs
	local RT_Pool_Available = {}

	local keycardBaseTexture = CreateMaterial("bKeypads.Keycards.Textures.BaseTexture", "UnlitGeneric", {
		["$basetexture"] = "models/bkeypads/keycard_identification",
		["$surfaceprop"] = "Plastic",
		["$blendtintbybasealpha"] = 1,
		["$blendtintcoloroverbase"] = 0
	})

	local RT_Queue_FrameBudget = 3
	local RT_RotationMatrix = Matrix()
	local RT_RotationMatrixTranslate = Vector()
	RT_RotationMatrix:SetAngles(Angle(0, -90, 0))

	local RT_Queue = {}

	local RT_QUEUE_TEXTURE_ID  = 1
	local RT_QUEUE_ORIENTATION = 2
	local RT_QUEUE_KEYCARD     = 3
	local RT_QUEUE_FRAME       = 4

	local function RT_Queue_Render()
		if not bKeypads.Keycards.Textures.KeycardImage.Loaded then return end

		local RT_ID, data
		while not RT_ID do
			RT_ID, data = next(RT_Queue)
			if not RT_ID then return end

			if IsValid(data[RT_QUEUE_KEYCARD]) then
				-- Increment frame number
				data[RT_QUEUE_FRAME] = data[RT_QUEUE_FRAME] + 1

				-- If we've rendered the needed frames, remove from the queue
				if data[RT_QUEUE_FRAME] == RT_Queue_FrameBudget then
					RT_Queue[RT_ID] = nil
				end
			else
				-- keycard is gone, remove from the queue
				RT_Queue[RT_ID] = nil
				RT_ID = nil
			end
		end

		local textureID, orientation, keycard = unpack(data)

		local keycardW, keycardH = bKeypads.Keycards.Textures:GetDimensions()
		local RT = GetRenderTargetEx("bKeypads_KeycardRT_" .. RT_ID, keycardH, keycardW, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_NONE, 32768, CREATERENDERTARGETFLAGS_HDR, IMAGE_FORMAT_DEFAULT)

		RT_RotationMatrixTranslate.y = keycardW
		RT_RotationMatrix:SetTranslation(RT_RotationMatrixTranslate)

		render.PushRenderTarget(RT, 0, 0, keycardH, keycardW)
		cam.Start2D()
			render.PushFilterMag(TEXFILTER.ANISOTROPIC)
			render.PushFilterMin(TEXFILTER.ANISOTROPIC)

			cam.PushModelMatrix(RT_RotationMatrix)

			keycardBaseTexture:SetVector("$color2", keycard:GetKeycardColor():ToVector())
			keycardBaseTexture:Recompute()
			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(keycardBaseTexture)
			surface.DrawTexturedRect(0, 0, ScrH(), ScrW())

			local skeleton = Get3D2DPanel()

			skeleton:SetPos(0, 0)
			skeleton:SetSize(ScrH(), ScrW())

			skeleton.Orientation = orientation
			skeleton.TextColor = bKeypads:GetLuminance(keycard:GetKeycardColor()) > 0.65 and bKeypads.COLOR.BLACK or bKeypads.COLOR.WHITE

			if orientation == bKeypads.Keycards.Textures.TOP then
				skeleton.Identification:Dock(LEFT)
				skeleton.Content:DockPadding(_keycardPad, 0, 0, 0)
				skeleton.Level:SetContentAlignment(7)
				skeleton.Team:SetContentAlignment(7)
			else
				skeleton.Identification:Dock(RIGHT)
				skeleton.Content:DockPadding(0, 0, _keycardPad, 0)
				skeleton.Level:SetContentAlignment(9)
				skeleton.Team:SetContentAlignment(9)
			end
			skeleton.Levels:SetTall((keycardH - _keycardPad - _keycardPad - _keycardPad) / 2)
			skeleton.Identification:SetWide((keycardH - _keycardPad - _keycardPad - _keycardPad) / 2)

			local levels = keycard:GetLevels()
			if levels then
				skeleton.Level:SetText(keycard:GetKeycardName())
				skeleton.Level:SetTextColor(skeleton.TextColor)
				skeleton.Level:SizeToContentsY()
				skeleton.Level:SetVisible(true)

				if levels and #levels > 1 then
					skeleton.Levels.m_Levels = levels
					skeleton.Levels:SetVisible(true)
				else
					skeleton.Levels:SetVisible(false)
				end
			else
				skeleton.Level:SetVisible(false)
			end

			local teamIndex = keycard:GetTeam() ~= 0 and keycard:GetTeam() or nil
			if teamIndex then
				skeleton.Team:SetText(IsValid(keycard:GetOwner()) and DarkRP and bKeypads.Config.Keycards.ShowCustomJobName and keycard:GetOwner().getDarkRPVar and keycard:GetOwner():getDarkRPVar("job") or team.GetName(teamIndex))
				skeleton.Team:SizeToContentsY()
				skeleton.Team:SetTextColor(skeleton.TextColor)
				skeleton.Team:SetVisible(true)
			else
				skeleton.Team:SetVisible(false)
			end

			local model = keycard:GetPlayerModel() ~= "" and keycard:GetPlayerModel() or "models/player/kleiner.mdl"
			if skeleton.Identification.Model.Model ~= model then
				skeleton.Identification.Model:SetModel(model)
				skeleton.Identification.Model.Model = model
			end

			local steamid = keycard:GetSteamID()
			local showImg = bKeypads.Keycards.Textures.KeycardImage.PrimaryImage
			if showImg == "AVATAR" and (not steamid or #steamid == 0) then
				showImg = bKeypads.Keycards.Textures.KeycardImage.SecondaryImage
			end

			if showImg == "AVATAR" then
				if skeleton.Identification.Avatar.SteamID ~= steamid then
					skeleton.Identification.Avatar.SteamID = steamid
					skeleton.Identification.Avatar:SetSteamID(util.SteamIDTo64(steamid), 184)
				end
				skeleton.Identification.ImageContainer:DockPadding(0, 0, 0, 0)
				skeleton.Identification.Avatar:SetVisible(true)
				skeleton.Identification.Image:SetVisible(false)
			else
				if skeleton.Identification.Image:GetMaterial() ~= showImg then
					skeleton.Identification.Image:SetMaterial(showImg)
				end
				skeleton.Identification.ImageContainer:DockPadding(10, 10, 10, 10)
				skeleton.Identification.Avatar:SetVisible(false)
				skeleton.Identification.Image:SetVisible(true)
			end

			skeleton:InvalidateChildren(true)
			skeleton:PaintManual()

			cam.PopModelMatrix()

			render.PopFilterMag()
			render.PopFilterMin()
		cam.End2D()
		render.PopRenderTarget()

		if not RT_ID_Materials[RT_ID][textureID] then
			RT_ID_Materials[RT_ID][textureID] = true

			local mat = Material("!bKeypads_Keycard_" .. textureID)
			mat:SetTexture("$basetexture", "bKeypads_KeycardRT_" .. RT_ID)
			mat:Recompute()
		end
	end

	local createdKeycardMaterials = {}
	local keycardMaterialData = { ["$surfaceprop"] = "Plastic" }
	function bKeypads.Keycards.Textures:Queue(orientation, dataKeycard, keycard, keycardHash, RT_ID)
		if bKeypads.Keycards.Textures.DimensionsDirty and keycard:GetModelScale() == 1 then
			bKeypads.Keycards.Textures:UpdateDimensions(keycard:GetModelBounds())
		end

		local textureID = keycardHash .. "_" .. orientation
		if not createdKeycardMaterials[textureID] then
			createdKeycardMaterials[textureID] = CreateMaterial("bKeypads_Keycard_" .. textureID, "VertexLitGeneric", keycardMaterialData)
		end

		if not RT_Queue[RT_ID] then
			RT_Queue[RT_ID] = { textureID, orientation, dataKeycard or keycard, 0 }
		elseif RT_Queue[RT_ID][RT_QUEUE_TEXTURE_ID] ~= textureID then
			RT_Queue[RT_ID][RT_QUEUE_TEXTURE_ID] = textureID
			RT_Queue[RT_ID][RT_QUEUE_ORIENTATION] = orientation
			RT_Queue[RT_ID][RT_QUEUE_KEYCARD] = dataKeycard or keycard
			RT_Queue[RT_ID][RT_QUEUE_FRAME] = 0
		end
	end

	local ReserveAvailableRT = {}
	local function ClearRTReservations()
		RT_Queue_Render()

		for textureID in pairs(ReserveAvailableRT) do
			local key, RT_ID = next(RT_Pool_Available)
			if key then
				-- There's a spare RT, let's reserve it
				RT_Pool_Reservations[textureID] = RT_ID
				RT_Pool_Available[key] = nil
				RT_ID_Materials[RT_ID] = {}
			else
				-- No spare RTs, let's create a new one
				RT_Pool_Count = RT_Pool_Count + 1

				RT_Pool_Reservations[textureID] = RT_Pool_Count
				RT_ID_Materials[RT_Pool_Count] = {}
			end

			ReserveAvailableRT[textureID] = nil
		end

		-- New frame, clear any reservations
		table.Merge(RT_Pool_Available, RT_Pool_Reservations)
		RT_Pool_Reservations = {}
	end
	bKeypads:InitPostEntity(function()
		timer.Simple(bKeypads_Keycard_Textures_Delayed and 0 or 10, function()
			bKeypads_Keycard_Textures_Delayed = true
			hook.Add("PreRender", "bKeypads.Keycards.Textures.ClearRTReservations", ClearRTReservations) ClearRTReservations()
		end)
	end)

	local function ReserveRT(orientation, keycard, dataKeycard)
		local keycardHash = (dataKeycard or keycard):GetHash()
		local textureID = keycardHash .. "_" .. orientation

		if ReserveAvailableRT[textureID] then
			if keycard.m_KeycardTextures then
				keycard:SetSubMaterial()
				keycard.m_KeycardTextures = nil
			end
			return
		end

		local RT_ID = RT_Pool_Reservations[textureID]
		if not RT_ID then
			RT_ID = RT_Pool_Available[textureID]
			if RT_ID then
				-- We were using this RT in the last frame, let's reserve it again
				RT_Pool_Available[textureID] = nil
				RT_Pool_Reservations[textureID] = RT_ID
			else
				-- Reserve an available RT after this frame
				ReserveAvailableRT[textureID] = true
				if keycard.m_KeycardTextures then
					keycard:SetSubMaterial()
					keycard.m_KeycardTextures = nil
				end
				return
			end
		end

		if not RT_ID_Materials[RT_ID][textureID] then
			bKeypads.Keycards.Textures:Queue(orientation, dataKeycard, keycard, keycardHash, RT_ID)
		end
		bKeypads.Keycards.Textures:Apply(keycard, orientation, keycardHash)
	end

	function bKeypads.Keycards.Textures:Draw(orientations, keycard, dataKeycard)
		if bKeypads.Settings:Get("optimizations_disable_keycard_textures") then return end
		if bit.band(orientations, bKeypads.Keycards.Textures.TOP) ~= 0 then
			ReserveRT(bKeypads.Keycards.Textures.TOP, keycard, dataKeycard)
		end
		if bit.band(orientations, bKeypads.Keycards.Textures.BOTTOM) ~= 0 then
			ReserveRT(bKeypads.Keycards.Textures.BOTTOM, keycard, dataKeycard)
		end
	end

	function bKeypads.Keycards.Textures:Reset()
		RT_ID_Materials = {}
		RT_Pool_Reservations = {}
		RT_Pool_Available = {}
		RT_Queue = {}

		for _, ent in ipairs(ents.GetAll()) do
			if ent.bKeycard then
				ent:SetSubMaterial(bKeypads.Keycards.Textures.TOP, nil)
				ent:SetSubMaterial(bKeypads.Keycards.Textures.BOTTOM, nil)
			end
		end
	end
end

-- Stupid hack to precache AvatarImage
bKeypads_Keycards_Textures_CacheAvatarImage = bKeypads_Keycards_Textures_CacheAvatarImage or {}
local precache_id = 0
local function PrecacheAvatarImage(ply)
	if not IsValid(ply) or ply:IsBot() or bKeypads_Keycards_Textures_CacheAvatarImage[ply] ~= nil then return end

	local id = precache_id
	precache_id = precache_id + 1

	local function precache()
		if IsValid(ply) then
			if not ply:SteamID64() then return end

			bKeypads_Keycards_Textures_CacheAvatarImage[ply] = os.time()

			local AvatarImage = vgui.Create("AvatarImage")
			AvatarImage:SetSteamID(ply:SteamID64(), 184)
			AvatarImage:SetSize(1, 1)
			AvatarImage:SetPos(-2, -2)
			AvatarImage.PaintOver = function(self) self:Remove() end
		end

		timer.Remove("bKeypads.PrecacheAvatarImage:" .. id)
	end

	timer.Create("bKeypads.PrecacheAvatarImage:" .. id, 1, 0, precache)
	precache()
end
hook.Add("PlayerInitialSpawn", "bKeypads.Keycards.3D2D.CacheAvatarImage", PrecacheAvatarImage)
bKeypads:InitPostEntity(function()
	timer.Create("bKeypads.PrecacheAvatarImage", 1, 0, function()
		local test = vgui.Create("AvatarImage")
		if not IsValid(test) then return end
		test:Remove()

		timer.Remove("bKeypads.PrecacheAvatarImage")

		PrecacheAvatarImage(LocalPlayer())
		for _, ply in ipairs(player.GetHumans()) do
			PrecacheAvatarImage(ply)
		end
	end)
end)

local function GetKeycardImage(_imageChoice, callback)
	local imageChoice = _imageChoice:lower():Trim()
	if imageChoice == "avatar" then
		callback("AVATAR")
		return
	end

	local img = Material("bkeypads/keycard.png", "smooth")

	if imageChoice ~= "keycard" then
		if imageChoice == "scp" then
			img = Material("bkeypads/scp.png", "smooth")

		elseif imageChoice:match("^https?://.-$") then

			bKeypads:print("Loading from: " .. _imageChoice, bKeypads.PRINT_TYPE_INFO, "KeycardImage")
			http.Fetch(_imageChoice, function(body, size, headers, code)
				if size > 0 and code >= 200 and code < 300 then
					file.Write("bkeypads/KeycardImage.png", body)
					local customMat = Material("../data/bkeypads/KeycardImage.png", "smooth")
					if customMat and not customMat:IsError() then
						img = customMat
						bKeypads:print("Loaded successfully", bKeypads.PRINT_TYPE_GOOD, "KeycardImage")
					else
						bKeypads:print("Could not load: " .. _imageChoice, bKeypads.PRINT_TYPE_WARN, "KeycardImage")
						bKeypads:print("Gmod was unable to convert the response into a valid texture", bKeypads.PRINT_TYPE_WARN, "KeycardImage")
					end
				else
					bKeypads:print("Could not load: " .. _imageChoice, bKeypads.PRINT_TYPE_WARN, "KeycardImage")
					bKeypads:print("HTTP " .. code, bKeypads.PRINT_TYPE_WARN, "KeycardImage")
				end
				bKeypads:print("Response: " .. string.NiceSize(size), bKeypads.PRINT_TYPE_GOOD, "KeycardImage")

				callback(img)
			end, function(err)
				bKeypads:print("Could not load: " .. _imageChoice, bKeypads.PRINT_TYPE_WARN, "KeycardImage")
				bKeypads:print("\"" .. err .. "\"", bKeypads.PRINT_TYPE_WARN, "KeycardImage")

				callback(img)
			end)
			return

		elseif isstring(imageChoice) and #imageChoice > 0 then

			local customMat = Material(_imageChoice, "smooth")
			if customMat and not customMat:IsError() then
				img = customMat
			else
				bKeypads:print("Could not load material: \"materials/" .. _imageChoice .. "\"", bKeypads.PRINT_TYPE_WARN, "KeycardImage")
			end

		end
	end

	callback(img)
end

local function CacheKeycardImage()
	bKeypads.Keycards.Textures.KeycardImage.Loaded = false

	local primary = bKeypads.Config.Keycards.KeycardImage.Image
	local backup = bKeypads.Config.Keycards.KeycardImage.Backup:lower():Trim() == "avatar" and "keycard" or bKeypads.Config.Keycards.KeycardImage.Backup

	GetKeycardImage(primary, function(img)
		bKeypads.Keycards.Textures.KeycardImage.PrimaryImage = img

		if backup == primary then
			bKeypads.Keycards.Textures.KeycardImage.SecondaryImage = img
			bKeypads.Keycards.Textures.KeycardImage.Loaded = true
		else
			GetKeycardImage(backup, function(img)
				bKeypads.Keycards.Textures.KeycardImage.SecondaryImage = img
				bKeypads.Keycards.Textures.KeycardImage.Loaded = true
			end)
		end
	end)
end
hook.Add("bKeypads.ConfigUpdated", "bKeypads.Keycards.3D2D.KeycardImage", CacheKeycardImage)
CacheKeycardImage()