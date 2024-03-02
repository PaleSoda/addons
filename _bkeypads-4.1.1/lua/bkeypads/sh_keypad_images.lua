bKeypads.KeypadImages = {}

function bKeypads.KeypadImages:VerifyURL(_url, ignore_force_imgur)
	if not bKeypads.Config.Appearance.CustomImages.Enable or (CLIENT and not bKeypads.Settings:Get("custom_images")) then return false end

	local url = _url:lower()
	if url:find("%.%.%/") then return false end

	local domain = url:match("^https?:%/%/(.-)$")
	if not domain then return false end
	domain = (domain:gsub("%/(.-)$", ""))

	local verified = false
	if CLIENT and ignore_force_imgur ~= true and bKeypads.Settings:Get("force_imgur") == true and domain ~= "i.imgur.com" then
		return verified, domain
	end
	for _, whitelisted in ipairs(bKeypads.Config.Appearance.CustomImages.URLWhitelist) do
		if domain:StartWith(whitelisted) then
			verified = true
			break
		end
	end

	return verified, domain
end

if CLIENT then
	local L = bKeypads.L

	function bKeypads.KeypadImages:GetURLHash(url)
		return bKeypads.md5.sumhexa((url:gsub("^[hH][tT][tT][pP][sS]?:%/%/", "")))
	end

	for _, f in ipairs((file.Find("bkeypads/keypad_img/*", "DATA"))) do
		file.Delete("bkeypads/keypad_img/" .. f)
	end

	do
		local getImageDimensions do
			local max_image_search = 1024 -- we'll search this many bytes for the image dimensions

			local function getPNGDimensions(f)
				f:Skip(4)

				while not f:EndOfFile() and f:Tell() <= max_image_search do
					local chunkLength = f:ReadULong()
					local chunkType = f:Read(4)

					if chunkType == "IHDR" then
						local width = bit.bswap(f:ReadULong())
						local height = bit.bswap(f:ReadULong())
						return width, height
					end

					f:Skip(chunkLength) -- skip chunk data
					f:Skip(4) -- skip CRC
				end
			end

			local function getJPEGDimensions(f)
				local byte1, byte2

				while not f:EndOfFile() and f:Tell() <= max_image_search do
					byte1 = f:ReadByte()

					if byte1 == 0xFF then
						byte2 = f:ReadByte()

						if byte2 >= 0xC0 and byte2 <= 0xCF and byte2 ~= 0xC4 and byte2 ~= 0xC8 then
							f:Skip(3)

							local height = bit.bswap(bit.lshift(f:ReadUShort(), 16))
							local width = bit.bswap(bit.lshift(f:ReadUShort(), 16))
							return width, height
						end
					end
				end
			end

			function getImageDimensions(path)
				local f = file.Open(path, "rb", "DATA")
				if not f then return end

				local succ, width, height

				local sig = f:Read(4)
				if sig == "\xff\xd8\xff\xe0" then
					succ, width, height = pcall(getJPEGDimensions, f)
				elseif sig == "\x89\x50\x4e\x47" then
					succ, width, height = pcall(getPNGDimensions, f)
				end

				f:Close()

				if not succ then return end
				return width, height
			end
		end

		local failures = {}
		local cached = {}
		function bKeypads.KeypadImages:GetImage(url, callback, force, save)
			local function failed(reason)
				failures[url] = failures[url] or os.time() + 900
				callback(false, reason, failures[url])
			end

			if not force and failures[url] and failures[url] > os.time() then failed("Waiting " .. failures[url] - os.time() .. " seconds before trying again") return end
			failures[url] = nil

			local hash = bKeypads.KeypadImages:GetURLHash(url)

			local dir = save and "bkeypads/keypad_img/saved/" or "bkeypads/keypad_img/"

			local filename = (file.Exists(dir .. hash .. ".png", "DATA") and (dir .. hash .. ".png")) or (file.Exists(dir .. hash .. ".jpg", "DATA") and (dir .. hash .. ".jpg"))

			if filename then
				if not cached[filename] then
					local mat = Material("data/" .. filename, "mips")
					if mat:IsError() then failed("Gmod failed to initialize a Material for this image") return end
					cached[filename] = mat
				end

				callback(true, cached[filename])
			else
				http.Fetch(
					url,

					function(body, size, headers, httpCode)
						if size == 0 then failed("Empty response") return end
						if size > 2097152 then failed("File must be smaller than 2 MB") return end
						if httpCode < 200 or httpCode > 299 then failed("Error (HTTP " .. httpCode .. ")") return end

						local ContentType = headers["Content-Type"] or headers["content-type"]
						if not ContentType then
							for header, value in pairs(headers) do
								if header:lower() == "content-type" then
									ContentType = value
									break
								end
							end
						end

						if not ContentType then failed("Could not determine file type of image (PNG/JPG)") return end
						ContentType = ContentType:lower()

						local extension
						if ContentType == "image/jpeg" then
							extension = "jpg"
						elseif ContentType == "image/png" then
							extension = "png"
						else
							failed("Image must be a JPG or PNG") return
						end

						local filename = dir .. hash .. "." .. extension
						file.Write(filename, body)

						-- Before we convert this to a material, we need to check
						-- its dimensions, otherwise this could crash the client
						-- if the image is too large.
						local width, height = getImageDimensions(filename)
						if not width or not height then
							failed("Could not determine image dimensions") return
						elseif width > 1024 or height > 1024 then
							failed("Image dimensions must be smaller than or equal to 1024x1024") return
						end

						local mat = Material("data/" .. filename, "smooth mips")
						if mat:IsError() then failed("Gmod failed to initialize a Material for this image") return end

						cached[filename] = mat

						callback(true, cached[filename], nil, extension)
					end,

					function(err)
						failed("Gmod HTTP API Error: " .. err)
					end
				)
			end
		end
	end

	local authMode, backgroundColor

	local function picPreviewPaint(self, w, h)
		local backgroundColorInt = backgroundColor:GetInt()
		if self._backgroundColorInt ~= backgroundColorInt then
			self._backgroundColorInt = backgroundColorInt
			self._backgroundColor = bKeypads:IntToColor(backgroundColorInt)
			self._shouldDarkenForeground = bKeypads:DarkenForeground(self._backgroundColor)
		end

		surface.SetDrawColor(self._backgroundColor)
		surface.DrawRect(0,0,w,h)

		if self.CustomImage and not self.CustomImage:IsError() then
			surface.SetMaterial(self.CustomImage)
			surface.SetDrawColor(255,255,255)
			surface.DrawTexturedRect(5,5,128,128)
		elseif self.Image then
			if self._Image ~= authMode:GetInt() then
				self._Image = authMode:GetInt()
				self.Image = Material(authMode:GetInt() == bKeypads.AUTH_MODE.FACEID and "bkeypads/face_id" or "bkeypads/keycard")
			end
			surface.SetMaterial(self.Image)
			surface.SetDrawColor(self._shouldDarkenForeground and bKeypads.COLOR.SLATE or bKeypads.COLOR.WHITE)
			surface.DrawTexturedRect(5,5,128,128)
		end

		surface.SetDrawColor(0,0,0)
		surface.DrawOutlinedRect(0,0,w,h)
	end

	local function picURLPaintOver(self, w, h)
		if self:IsHovered() then
			surface.SetTextColor(255,255,255)
			surface.SetFont("bKeypads.PicURLFont")

			local txtW, txtH = surface.GetTextSize(self:GetText())

			if txtW + 10 > self:GetWide() then
				DisableClipping(true)

					local txtHCenter = (h - txtH) / 2

					surface.SetDrawColor(0,0,0)
					surface.DrawRect(0, 0, txtW + 10, h)

					surface.SetTextPos(txtHCenter, txtHCenter)
					surface.DrawText(self:GetText())

				DisableClipping(false)
			end
		end
	end

	local function picNameAllowInput(self, char)
		return not char:match("[A-Za-z0-9-_]")
	end

	function bKeypads.KeypadImages:Open(callback)
		authMode, backgroundColor = GetConVar("bkeypads_auth_mode"), GetConVar("bkeypads_background_color")

		if IsValid(self.UI) then
			self.UI:Close()
		end

		local savedPicManifest = {}
		local picHashTable = {}
		if file.Exists("bkeypads/keypad_img/saved/manifest.json", "DATA") then
			local manifest = file.Read("bkeypads/keypad_img/saved/manifest.json", "DATA")
			if manifest then
				manifest = util.JSONToTable(manifest)
				if manifest then
					savedPicManifest = manifest
				end
			end
		end

		self.UI = vgui.Create("DFrame")
		self.UI:SetTitle(L"SetLogoImage")
		self.UI:SetIcon("icon16/picture.png")
		self.UI:SetSize(650, 341)
		self.UI:DockPadding(10, 10 + 24, 10, 10)
		self.UI:Center()
		self.UI:MakePopup()
		self.UI:SetDrawOnTop(true)
		self.UI:MoveToFront()
		self.UI:DoModal()
		self.UI.OnClose = function()
			if callback then callback(false) end
		end

		local whitelistedDomainsContainer = vgui.Create("DPanel", self.UI)
		whitelistedDomainsContainer:Dock(LEFT)
		whitelistedDomainsContainer:DockMargin(0, 0, 10, 0)
		whitelistedDomainsContainer:SetWide(150)
		whitelistedDomainsContainer.Paint = nil

			local whitelistedDomainsTip = vgui.Create("DLabel", whitelistedDomainsContainer)
			whitelistedDomainsTip:Dock(TOP)
			whitelistedDomainsTip:SetWrap(true)
			whitelistedDomainsTip:SetAutoStretchVertical(true)
			whitelistedDomainsTip:SetText(L"WhitelistedDomainsTip")
			whitelistedDomainsTip:SetContentAlignment(7)
			whitelistedDomainsTip:DockMargin(0, 0, 0, 10)

			local whitelistedDomains = vgui.Create("DListView", whitelistedDomainsContainer)
			whitelistedDomains:Dock(FILL)
			whitelistedDomains:AddColumn(L"WhitelistedDomains")
			for _, whitelisted in ipairs(bKeypads.Config.Appearance.CustomImages.URLWhitelist) do
				whitelistedDomains:AddLine(whitelisted)
			end

		local listContainer = vgui.Create("DPanel", self.UI)
		listContainer.Paint = nil
		listContainer:Dock(LEFT)
		listContainer:DockMargin(0, 0, 10, 0)
		listContainer:SetWide(250)

			local picList = vgui.Create("DListView", listContainer)
			picList:Dock(FILL)
			picList:DockMargin(0, 0, 0, 10)
			picList:AddColumn(L"Name")
			picList:AddColumn(L"Added")
			picList:AddColumn(L"Size")
			picList:SetMultiSelect(false)
			function picList:Populate(selectFile)
				self:Clear()

				local selectRow
				for name, manifest in pairs(savedPicManifest) do
					if not manifest.hash or not manifest.extension or not manifest.URL then continue end

					local filename = "bkeypads/keypad_img/saved/" .. manifest.hash .. "." .. manifest.extension

					local row = self:AddLine(name, os.date("%x %X", file.Time(filename, "DATA")), string.NiceSize(file.Size(filename, "DATA")))
					row.Hash = manifest.hash
					row.PicName = name
					row.URL = manifest.URL
					row.FileName = filename

					picHashTable[manifest.hash] = name

					if selectFile == name then
						selectRow = row
					end
				end
				if selectRow then self:SelectItem(selectRow) end

				self:SortByColumn(1, true)
			end
			picList:Populate()

			local newBtn = vgui.Create("DButton", listContainer)
			newBtn:Dock(BOTTOM)
			newBtn:SetTall(25)
			newBtn:SetText(L"NewImage")
			newBtn:SetIcon("icon16/add.png")
			newBtn.DoClick = function()
				Derma_StringRequest(L"NewImageTitle", L"NewImageSubtitle", "", function(url)
					if url and #url > 0 then
						local verified, domain = bKeypads.KeypadImages:VerifyURL(url, true)
						if verified then
							local hash = bKeypads.KeypadImages:GetURLHash(url)
							if picHashTable[hash] then
								Derma_Message(string.format(L"ImageAlreadyExists", picHashTable[hash]), L"NewImageTitle", L"Dismiss")
							else
								local loading = Derma_Message(L"CheckingURL", L"NewImageTitle", L"Cancel")
								bKeypads.KeypadImages:GetImage(url, function(success, mat, retry, extension)

									if not IsValid(loading) then return end

									loading:Close()

									if not success then Derma_Message(L"InvalidImage" .. mat, L"NewImageTitle", L"Dismiss") return end

									savedPicManifest[hash] = {
										hash = hash,
										URL = url,
										extension = extension
									}

									file.Write("bkeypads/keypad_img/saved/manifest.json", util.TableToJSON(savedPicManifest))

									picList:Populate(hash)

								end, true, true)
							end
						elseif domain then
							Derma_Message(L"DomainNotWhitelisted", L"NewImageTitle", L"Dismiss")
						else
							Derma_Message(L"InvalidURL", L"NewImageTitle", L"Dismiss")
						end
					end
				end)
			end

		local rightPanel = vgui.Create("DPanel", self.UI)
		rightPanel:Dock(FILL)
		rightPanel.Paint = nil

			local picPreviewPanel = vgui.Create("DPanel", rightPanel)
			picPreviewPanel:Dock(FILL)
			picPreviewPanel:DockPadding(10, 10, 10, 10)

				local picPreview = vgui.Create("DPanel", picPreviewPanel)
				picPreview:SetSize(128 + 10, 128 + 10)
				picPreview.Image = true
				picPreview.Paint = picPreviewPaint

				local picName = vgui.Create("DTextEntry", picPreviewPanel)
				picName:DockMargin(0, 128 + 10 + 10, 0, 0)
				picName:Dock(TOP)
				picName:SetTall(25)
				picName:SetDisabled(true)
				picName:SetPlaceholderText(L"ImageName")
				picName:SetUpdateOnType(true)
				picName.AllowInput = picNameAllowInput

				local picURL = vgui.Create("DTextEntry", picPreviewPanel)
				picURL:DockMargin(0, 10, 0, 0)
				picURL:Dock(TOP)
				picURL:SetTall(25)
				picURL:SetDisabled(true)
				picURL:SetPlaceholderText("URL...")
				picURL:SetUpdateOnType(true)
				picURL.PaintOver = picURLPaintOver
				picURL.AllowInput = function() return true end
				picURL.OnValueChange = function()
					if picURL.URL and picURL:GetText() ~= picURL.URL then
						picURL:SetText(picURL.URL)
					end
				end

				local btnContainer = vgui.Create("DPanel", picPreviewPanel)
				btnContainer:DockMargin(0, 10, 0, 10)
				btnContainer:Dock(TOP)
				btnContainer:SetTall(25)

					local save = vgui.Create("DButton", btnContainer)
					save:Dock(LEFT)
					save:SetText(L"Save")
					save:SetIcon("icon16/disk.png")
					save:SetDisabled(true)
					save.DoClick = function()
						save:SetDisabled(true)

						local oldName = picPreview.CustomImageName
						picPreview.CustomImageName = picName:GetText()

						savedPicManifest[picPreview.CustomImageName] = savedPicManifest[oldName]
						savedPicManifest[oldName] = nil

						picList:Populate(picPreview.CustomImageName)

						file.Write("bkeypads/keypad_img/saved/manifest.json", util.TableToJSON(savedPicManifest))
					end

					local delete = vgui.Create("DButton", btnContainer)
					delete:Dock(RIGHT)
					delete:SetText(L"Delete")
					delete:SetIcon("icon16/cancel.png")
					delete:SetDisabled(true)

				function btnContainer:PerformLayout(w,h)
					save:SetWide((w / 2) - 5)
					delete:SetWide((w / 2) - 5)
				end

				local done = vgui.Create("DButton", picPreviewPanel)
				done:Dock(TOP)
				done:SetTall(25)
				done:SetText(L"SetLogoImage")
				done:SetIcon("icon16/picture.png")
				done:SetDisabled(true)
				done.DoClick = function()
					callback(true, savedPicManifest[picPreview.CustomImageName].URL, picPreview.CustomImage)
					callback = nil
					self.UI:Close()
				end

				delete.DoClick = function()
					Derma_Query(L"AreYouSureDeleteImage", L"DeleteImage", L"Delete", function()

						local manifest = savedPicManifest[picPreview.CustomImageName]
						file.Delete("bkeypads/keypad_img/saved/" .. manifest.hash .. "." .. manifest.extension)

						savedPicManifest[picPreview.CustomImageName] = nil
						if table.IsEmpty(savedPicManifest) then
							file.Delete("bkeypads/keypad_img/saved/manifest.json")
						else
							file.Write("bkeypads/keypad_img/saved/manifest.json", util.TableToJSON(savedPicManifest))
						end

						picList:Populate()

						picPreview.CustomImage = nil
						picPreview.CustomImageName = nil
						picName:SetText("")
						picURL:SetText("")
						delete:SetDisabled(true)
						save:SetDisabled(true)
						done:SetDisabled(true)

					end, L"Cancel")
				end

			function rightPanel:PerformLayout()
				picPreview:CenterHorizontal()
				picPreview:AlignTop(10)
			end

		local function checkFields()
			local success = picName:GetText() ~= picPreview.CustomImageName and #string.Trim(picName:GetText()) > 0 and bKeypads.KeypadImages:VerifyURL(picURL:GetText(), true)
			save:SetDisabled(not success)
			done:SetDisabled(picPreview.CustomImage == nil or success)
		end

		picName.OnValueChange = checkFields
		picName.OnEnter = checkFields
		picName.OnFocusChanged = checkFields

		picList.OnRowSelected = function(self, index, pnl)
			picPreview.CustomImage = Material("data/" .. pnl.FileName, "smooth mip")
			picPreview.CustomImageName = pnl.PicName

			picName:SetText(pnl.PicName)
			picURL.URL = pnl.URL
			picURL:SetText(pnl.URL)

			picURL:SetDisabled(false)
			picName:SetDisabled(false)
			delete:SetDisabled(false)
			done:SetDisabled(false)

			checkFields()
		end
	end
end

do
	bKeypads.KeypadImages.Bans = {}
	bKeypads.KeypadImages.Bans.List = {}

	function bKeypads.KeypadImages.Bans:Check(ply)
		if SERVER then
			return bKeypads.KeypadImages.Bans.List[ply:SteamID()] == true
		else
			return bKeypads.KeypadImages.Bans.List[ply] == true
		end
	end

	if CLIENT then
		net.Receive("bKeypads.KeypadImages.Bans", function()
			if net.ReadBool() then
				-- Downloading all bans
				for i = 1, net.ReadUInt(8) do
					bKeypads.KeypadImages.Bans.List[net.ReadEntity()] = true
				end
			else
				-- Receiving single ban
				local banned = net.ReadBool()
				local ply = net.ReadEntity()
				bKeypads.KeypadImages.Bans.List[ply] = banned or nil
			end
		end)

		bKeypads:InitPostEntity(function()
			net.Start("bKeypads.KeypadImages.Bans")
			net.SendToServer()
		end)
	else
		util.AddNetworkString("bKeypads.KeypadImages.Bans")

		file.CreateDir("bkeypads/keypad_img")
		if file.Exists("bkeypads/keypad_img/bans.json", "DATA") then
			local banList = file.Read("bkeypads/keypad_img/bans.json", "DATA")
			if banList then
				banList = util.JSONToTable(banList)
				if banList then
					bKeypads.KeypadImages.Bans.List = banList
				end
			end
		else
			file.Write("bkeypads/keypad_img/bans.json", "{}")
		end

		function bKeypads.KeypadImages:Save()
			file.Write("bkeypads/keypad_img/bans.json", util.TableToJSON(bKeypads.KeypadImages.Bans.List))
		end

		bKeypads.KeypadImages.Bans.Players = {}

		do
			local downloaded = {}
			net.Receive("bKeypads.KeypadImages.Bans", function(_, ply)
				if downloaded[ply] then return end
				downloaded[ply] = true

				net.Start("bKeypads.KeypadImages.Bans")
					net.WriteBool(true)
					net.WriteUInt(#bKeypads.KeypadImages.Bans.Players, 8)
					for _, banPly in ipairs(bKeypads.KeypadImages.Bans.Players) do net.WriteEntity(banPly) end
				net.Send(ply)
			end)
		end

		hook.Add("PlayerDisconnected", "bKeypads.KeypadImages.Bans", function(ply)
			local sid = ply:SteamID()
			if sid and bKeypads.KeypadImages.Bans.List[sid] then
				table.RemoveByValue(bKeypads.KeypadImages.Bans.Players, ply)
			else
				for i = #bKeypads.KeypadImages.Bans.Players, 1, -1 do
					if not IsValid(bKeypads.KeypadImages.Bans.Players[i]) then
						table.remove(bKeypads.KeypadImages.Bans.Players, i)
					end
				end
			end
		end)

		hook.Add("PlayerInitialSpawn", "bKeypads.KeypadImages.Bans", function(ply)
			local sid = ply:SteamID()
			if bKeypads.KeypadImages.Bans.List[sid] then
				table.insert(bKeypads.KeypadImages.Bans.Players, ply)

				net.Start("bKeypads.KeypadImages.Bans")
					net.WriteBool(false)
					net.WriteEntity(ply)
					net.WriteBool(true)
				net.Broadcast()
			end
		end)

		function bKeypads.KeypadImages:Ban(ply, admin)
			if ply == admin then return end

			local sid = ply:SteamID()
			if not bKeypads.KeypadImages.Bans.List[sid] then
				bKeypads.KeypadImages.Bans.List[sid] = true
				table.insert(bKeypads.KeypadImages.Bans.Players, ply)

				net.Start("bKeypads.KeypadImages.Bans")
					net.WriteBool(false)
					net.WriteEntity(ply)
					net.WriteBool(true)
				net.SendOmit(admin)

				bKeypads.KeypadImages:Save()

				hook.Run("bKeypads.KeypadImages.Ban", ply, admin)
			end
		end

		function bKeypads.KeypadImages:Unban(ply, admin)
			if ply == admin then return end

			local sid = ply:SteamID()
			if bKeypads.KeypadImages.Bans.List[sid] then
				bKeypads.KeypadImages.Bans.List[sid] = nil
				table.RemoveByValue(bKeypads.KeypadImages.Bans.Players, ply)

				net.Start("bKeypads.KeypadImages.Bans")
					net.WriteBool(false)
					net.WriteEntity(ply)
					net.WriteBool(false)
				net.SendOmit(admin)

				bKeypads.KeypadImages:Save()

				hook.Run("bKeypads.KeypadImages.Unban", ply, admin)
			end
		end
	end

	do
		local keypadImages = bKeypads.ContextMenu:AddMember("#bKeypads_KeypadImages", "icon16/picture.png", function(self, ent, ply)
			return ent.bKeypad or (ent:IsPlayer() and ent ~= ply)
		end)

		keypadImages:AddMember(
			"#bKeypads_Remove",
			"icon16/delete.png",

			function(self, ent, ply)
				return ent.bKeypad and ((SERVER and ent:GetImageURL() ~= "") or (CLIENT and ent.CustomImage)) and bKeypads.Permissions:Check(ply, "administration/custom_img/remove") and (not IsValid(ent:GetKeypadOwner()) or (ent:GetKeypadOwner() ~= LocalPlayer() and not bKeypads.Permissions:Check(ent:GetKeypadOwner(), "administration/custom_img/remove")))
			end,

			function(self, ent, ply)
				if CLIENT then
					self:Network() self:Network()
				else
					ent:SetImageURL("")
					if IsValid(ent:GetKeypadOwner()) then
						hook.Run("bKeypads.KeypadImages.Removed", ent:GetKeypadOwner(), ply, ent)
					end
				end
			end,

			true
		)

		keypadImages:AddMember(
			"#bKeypads_BanFromFeature",
			"icon16/user_delete.png",

			function(self, ent, ply)
				if not bKeypads.Permissions:Check(ply, "administration/custom_img/ban") then return false end
				if ent:IsPlayer() and ent ~= LocalPlayer() and not bKeypads.Permissions:Check(ent, "administration/custom_img/ban") then
					return not bKeypads.KeypadImages.Bans:Check(ent)
				elseif ent.bKeypad and ((SERVER and ent:GetImageURL() ~= "") or (CLIENT and ent.CustomImage)) and IsValid(ent:GetKeypadOwner()) and ent:GetKeypadOwner() ~= LocalPlayer() and not bKeypads.Permissions:Check(ent:GetKeypadOwner(), "administration/custom_img/ban") then
					return not bKeypads.KeypadImages.Bans:Check(ent:GetKeypadOwner())
				end
			end,

			function(self, ent, ply)
				if CLIENT then
					local banPly = ent:GetKeypadOwner()

					self:Network()
						net.WriteEntity(banPly)
					self:Network()

					bKeypads.KeypadImages.Bans.List[banPly] = true

					notification.AddLegacy(bKeypads.L"BannedFromFeatureAdmin", NOTIFY_ERROR, 3)
				else
					local banPly = net.ReadEntity()
					if IsValid(banPly) and banPly:IsPlayer() then
						bKeypads.KeypadImages:Ban(banPly, ply)

						for _, keypad in ipairs(bKeypads.Keypads) do
							if keypad:GetKeypadOwner() == banPly then
								keypad:SetImageURL("")
							end
						end
					end
				end
			end,

			true
		)

		keypadImages:AddMember(
			"#bKeypads_UnbanFromFeature",
			"icon16/user_add.png",

			function(self, ent, ply)
				if not bKeypads.Permissions:Check(ply, "administration/custom_img/ban") then return false end
				if ent:IsPlayer() and ent ~= LocalPlayer() and not bKeypads.Permissions:Check(ent, "administration/custom_img/ban") then
					return bKeypads.KeypadImages.Bans:Check(ent)
				elseif ent.bKeypad and IsValid(ent:GetKeypadOwner()) and ent:GetKeypadOwner() ~= LocalPlayer() and not bKeypads.Permissions:Check(ent:GetKeypadOwner(), "administration/custom_img/ban") then
					return bKeypads.KeypadImages.Bans:Check(ent:GetKeypadOwner())
				end
			end,

			function(self, ent, ply)
				if CLIENT then
					local banPly = ent:GetKeypadOwner()

					self:Network()
						net.WriteEntity(banPly)
					self:Network()

					bKeypads.KeypadImages.Bans.List[banPly] = nil

					notification.AddLegacy(bKeypads.L"UnbannedFromFeatureAdmin", NOTIFY_HINT, 3)
				else
					local banPly = net.ReadEntity()
					if IsValid(banPly) and banPly:IsPlayer() then
						bKeypads.KeypadImages:Unban(banPly, ply)
					end
				end
			end,

			true
		)
	end
end