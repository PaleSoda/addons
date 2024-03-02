local PANEL = {}

local matStar = Material("xenin/f4/star.png", "smooth")
local matStarHollow = Material("xenin/f4/star_hollow.png", "smooth")

local EMPTY_FUNC = function() end

function PANEL:Init()
	self:SetText("")

	if (!F4Menu.Config.HideModels) then
		if F4Menu.Config.RealtimeModels then
			self.ModelPanel = self:Add("DModelPanel")
			self.ModelPanel:SetMouseInputEnabled(false)
			self.ModelPanel.LayoutEntity = function() end
			local basePaint = baseclass.Get("DModelPanel").Paint
			self.ModelPanel.Paint = function(pnl, w, h)
				XeninUI:DrawCircle(h / 2, h / 2, h / 2, 45, XeninUI.Theme.Navbar)

				XeninUI:Mask(function()
					XeninUI:DrawCircle(h / 2, h / 2, h / 2, 45, XeninUI.Theme.Navbar)
				end, function()
					local oldClearDepth = render.ClearDepth
					render.ClearDepth = EMPTY_FUNC
					basePaint(pnl, w, h)
					render.ClearDepth = oldClearDepth
				end)
			end
		else
			self.ModelPanel = self:Add("SpawnIcon")
			self.ModelPanel:SetMouseInputEnabled(false)
		end
	end

	self.Star = self:Add("DButton")
	self.Star:SetText("")
	self.Star.Overlay = 0
	self.Star.State = false
	self.Star.Paint = function(pnl, w, h)
		surface.SetDrawColor(XeninUI.Theme.Accent)
		surface.SetMaterial(matStarHollow)
		local size = h / 2
		local x = w / 2 - size / 2
		local y = h / 2 - size / 2
		surface.DrawTexturedRect(x, y, size, size)

		XeninUI:Mask(function()
			XeninUI:DrawCircle(h / 2, h / 2, (h / 3.8) * pnl.Overlay, 30, color_white)
		end, function()
			surface.SetDrawColor(XeninUI.Theme.Accent)
			surface.SetMaterial(matStar)
			local size = h / 2
			local x = w / 2 - size / 2
			local y = h / 2 - size / 2
			surface.DrawTexturedRect(x, y, size, size)
		end)
	end
	self.Star.DoClick = function(pnl)
		pnl.State = !pnl.State

		pnl:EndAnimations()

		pnl:Lerp("Overlay", pnl.State and 1 or 0, 0.3, function()
			if pnl.State then
				F4Menu:SaveFavourite(self.Data.identifier, self.Data.name)


				local copy = table.Copy(self.Data)
				copy.deleteOnFavouriteRemove = true
				hook.Run("F4Menu.Items.FavouriteAdded." .. self.Data.identifier, copy)
			else
				F4Menu:RemoveFavourite(self.Data.identifier, self.Data.name)

				if self.Data.deleteOnFavouriteRemove then
					local cat = self:GetParent():GetParent()
					local height, children = cat:CalculateHeight(-1)

					if (children == 0) then
						cat:Expand(false)
						self:Remove()
					else
						self.Alpha = 255
						self:LerpAlpha(0, 0.3)
						cat.Top:Lerp("NextHeight", height, 0.3, function()
							self:Remove()
						end)
						cat:InvalidateLayout(true)
					end
				end
			end
		end)

		if (!pnl.State) then
			hook.Run("F4Menu.Items.FavouriteRemoved." .. self.Data.identifier, self.Data.name)
		end
	end

	self.IsDonator = self:Add("DPanel")
	self.IsDonator:SetMouseInputEnabled(false)
	self.IsDonator:SetVisible(false)
	self.IsDonator.Paint = function(pnl, w, h)
		local size = h / 2
		local x = w / 2 - size / 2
		local y = h / 2 - size / 2

		XeninUI:DrawIcon(x, y, size * 1.1, size, pnl)
	end

	self.Level = self:Add("DPanel")
	self.Level:SetMouseInputEnabled(false)
	self.Level:SetVisible(false)
	local lvl = F4Menu.Levels:getActive()
	self.Level.Paint = function(pnl, w, h)
		local size = (h / 2) - 10
		local level = self.Data.level or 0
		local frac = math.Clamp(((lvl and lvl:getLevel()) or 0) / level, 0, 1)
		local str = "Lvl. " .. level

		XeninUI:MaskInverse(function()
			XeninUI:DrawArc(w - 16 - size / 2 - 8, h / 2, 0, 360, size * 0.8, XeninUI.Theme.Green, 90)
		end, function()
			XeninUI:DrawArc(w - 16 - size / 2 - 8, h / 2, 0, 360, size, XeninUI.Theme.Background, 90)
		end)

		XeninUI:MaskInverse(function()
			XeninUI:DrawArc(w - 16 - size / 2 - 8, h / 2, 0, 360, size * 0.8, XeninUI.Theme.Green, 90)
		end, function()
			XeninUI:DrawArc(w - 16 - size / 2 - 8, h / 2, 0, frac * 360, size, Color(224, 224, 224), 90)
		end)

		XeninUI:DrawShadowText(str, "F4Menu.Jobs.Row.Level", w - 16 - size / 2 - 8, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, 125)
	end

	XeninUI:AddRippleClickEffect(self)
end

function PANEL:PerformLayout(w, h)
	if IsValid(self.ModelPanel) then
		self.ModelPanel:SetPos(12, 8)
		self.ModelPanel:SetSize(h - 16, h - 16)
	end

	self.Level:SetSize(h, h)
	self.Level:AlignRight(h - 10)
	self.Level:CenterVertical()

	self.Star:SetSize(h * 0.66, h * 0.66)
	self.Star:AlignRight(h + (self.Level:IsVisible() and (self.Level:GetWide() - 16) or -(self.Limit and 0 or (h - 8))))
	self.Star:CenterVertical()

	self.IsDonator:SetSize(h, h)
	self.IsDonator:CenterVertical()
	if self.Star:IsVisible() then
		local x = self.Star:GetPos()
		self.IsDonator:AlignLeft(x - self.Star:GetWide() - 16)
	else
		local x = self.Level:GetPos()
		self.IsDonator:AlignLeft(x - self.Level:GetWide() - 16)
	end
end

function PANEL:HandleData(data, index)
	local ply = LocalPlayer()
	local model = data.model
	if (!F4Menu.Config.HideModels) then
		if F4Menu.Config.RealtimeModels then
			self.ModelPanel:SetModel(model)
			if IsValid(self.ModelPanel.Entity) then
				local mn, mx = self.ModelPanel.Entity:GetRenderBounds()
				local size = 0
				size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
				size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
				size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
				self.ModelPanel:SetFOV(45)
				self.ModelPanel:SetCamPos(Vector(size, size, size))
				self.ModelPanel:SetLookAt((mn + mx) * 0.5)

				if (SH_EASYSKINS and F4Menu.Config.EasySkins) then
					local skinTbl = SH_EASYSKINS.GetEnabledPurchasedSkinByClass(ply, data.ent)

					if skinTbl then
						local skin = SH_EASYSKINS.GetSkin(skinTbl.skinID)

						if skin then
							SH_EASYSKINS.ApplySkinToModel(self.ModelPanel.Entity, skin.material.path)
						end
					end
				end
			end
		else
			self.ModelPanel:SetModel(model)
			self.ModelPanel.Icon.PaintOver = function(pnl, w, h)
				XeninUI:MaskInverse(function()
					XeninUI:DrawRoundedBox(h / 2, 0, 0, w, h, color_white)
				end, function()
					XeninUI:DrawRoundedBox(0, 0, 0, w, h, XeninUI.Theme.Primary)
				end)
			end
		end
	end

	self.Name = data.name
	local price = 0
	if (data.identifier == "weapons") then
		price = data.pricesep or data.price
	else
		price = data.price or data.pricesep
	end
	price = tonumber(price)
	if isfunction(data.getPrice) then
		price = tonumber(data.getPrice(ply, price)) or price or 0
	end

	self.Price = price
	self.PriceStr = DarkRP.formatMoney(price)
	self.Limit = data.getMax and data.getMax(ply, data.max) or data.max
	if data.removeMax then
		self.Limit = nil
	end
	self.Data = data
	if data.favourite then
		self.Star.State = true
		self.Star.Overlay = 1
	end

	self.IsDonator:SetVisible(data.ranks)
	self.Level:SetVisible(isnumber(data.level) and F4Menu.Config.ItemsLevelIndicatorEnabled)
	XeninUI:DownloadIcon(self.IsDonator, data.ranksIcon or {
		{
		id = "eozBUir" },
		{
			id = "aQK4lU",
			url = "https://i.hizliresim.com",
			type = "png"
		}
	})
	self.Donator = data.ranks and data.ranks[ply:GetUserGroup()]

	hook.Add("F4Menu.Items.FavouriteRemoved." .. data.identifier, self.Star, function(pnl, name)
		if (self.Data.name == name) then
			self.Star:EndAnimations()
			self.Star.State = false
			self.Star:Lerp("Overlay", 0, 0.3)

			if self.Data.deleteOnFavouriteRemove then
				local cat = self:GetParent():GetParent()
				local height, children = cat:CalculateHeight(-1)

				if (children == 0) then
					cat:Expand(false)
					self:Remove()
				else
					self.Alpha = 255
					self:LerpAlpha(0, 0.3)
					cat.Top:Lerp("NextHeight", height, 0.3, function()
						self:Remove()
					end)
					cat:InvalidateLayout(true)
				end
			end
		end
	end)
	hook.Add("F4Menu.Items.FavouriteAdded." .. data.identifier, self.Star, function(pnl, data)
		if (data.name != self.Data.name) then return end

		pnl:Lerp("Overlay", 1, 0.3)
		pnl.State = true
	end)
end

function PANEL:Paint(w, h)
	XeninUI:DrawRoundedBox(6, 0, 0, w - 0, h, Color(50, 50, 50))

	local x = IsValid(self.ModelPanel) and (self.ModelPanel.x + self.ModelPanel:GetWide() + self.ModelPanel.x) or 16

	XeninUI:DrawShadowText(self.Name, "F4Menu.Jobs.Row.Name", x, h / 2, Color(231, 231, 235), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, 150)
	XeninUI:DrawShadowText(self.PriceStr, "F4Menu.Jobs.Row.Salary", x, h / 2, Color(182, 182, 182), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, 150)


	local limit = self.Limit
	if limit then
		local frac = 0
		local str = ""
		if (limit == 0) then
			frac = 0
			str = "∞"
		else
			local amount = LocalPlayer():getCustomEntity(self.Data)

			frac = math.Clamp(amount / limit, 0, 1)
			str = amount .. "/" .. limit
		end

		local size = h / 2 - 10
		XeninUI:MaskInverse(function()
			XeninUI:DrawArc(w - 16 - size / 2 - 8, h / 2, 0, 360, size * 0.8, XeninUI.Theme.Green, 90)
		end, function()
			XeninUI:DrawArc(w - 16 - size / 2 - 8, h / 2, 0, 360, size, XeninUI.Theme.Background, 90)
		end)

		XeninUI:MaskInverse(function()
			XeninUI:DrawArc(w - 16 - size / 2 - 8, h / 2, 0, 360, size * 0.8, XeninUI.Theme.Green, 90)
		end, function()
			XeninUI:DrawArc(w - 16 - size / 2 - 8, h / 2, 0, frac * 360, size, XeninUI.Theme.Green, 90)
		end)

		XeninUI:DrawShadowText(str, "F4Menu.Jobs.Row.Limit", w - 16 - size / 2 - 8, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, 125)
	end
end

function PANEL:DoClick()
	local name = self.Data.identifier

	if (name == "entities") then
		RunConsoleCommand("darkrp", self.Data.cmd)
	elseif (name == "weapons") then
		RunConsoleCommand("darkrp", "buy", self.Data.name)
	elseif (name == "shipments") then
		RunConsoleCommand("darkrp", "buyshipment", self.Data.name)
	elseif (name == "vehicles") then
		RunConsoleCommand("darkrp", "buyvehicle", self.Data.command or self.Data.name)
	elseif (name == "food") then
		RunConsoleCommand("darkrp", "buyfood", self.Data.name)
	elseif (name == "ammo") then
		RunConsoleCommand("darkrp", "buyammo", self.Data.id)
	end
end

vgui.Register("F4Menu.Items.Row", PANEL, "DButton")
