local PANEL = {}

local matTick = Material("xenin/tick.png", "smooth")
local matStar = Material("xenin/f4/star.png", "smooth")
local matStarHollow = Material("xenin/f4/star_hollow.png", "smooth")

local EMPTY_FUNC = function() end

function PANEL:Init()
	self:SetText("")

	if (!F4Menu.Config.HideModels) then
		if F4Menu.Config.RealtimeModels then
			self.ModelPanel = self:Add("DModelPanel")
			self.ModelPanel:SetCamPos(Vector(25, 0, 67))
			self.ModelPanel:SetLookAt(Vector(0, 0, 65))
			self.ModelPanel:SetFOV(50)
			self.ModelPanel:SetMouseInputEnabled(false)
			self.ModelPanel.LayoutEntity = function() end
			local basePaint = baseclass.Get("DModelPanel").Paint
			self.ModelPanel.Paint = function(pnl, w, h)
				if (!self.Data) then return end

				local isTeam = team.GetName(LocalPlayer():Team()) == team.GetName(self.Data.team)
				XeninUI:DrawCircle(h / 2, h / 2, h / 2, 45, XeninUI.Theme.Navbar)

				if (!isTeam) then
					XeninUI:Mask(function()
						XeninUI:DrawCircle(h / 2, h / 2, h / 2, 45, XeninUI.Theme.Navbar)
					end, function()
						local oldClearDepth = render.ClearDepth
						render.ClearDepth = EMPTY_FUNC
						basePaint(pnl, w, h)
						render.ClearDepth = oldClearDepth
					end)
				end

				XeninUI:MaskInverse(function()
					XeninUI:DrawCircle(h / 2, h / 2, h / 2 - 1, 45, color_white)
				end, function()
					XeninUI:DrawCircle(h / 2, h / 2, h / 2, 45, self.Color)
				end)

				if isTeam then
					XeninUI:DrawCircle(h / 2, h / 2, h / 3.2, 45, self.Color)

					surface.SetMaterial(matTick)
					surface.SetDrawColor(color_black)
					local size = h * 0.33
					local x = w / 2 - size / 2
					local y = h / 2 - size / 2
					surface.DrawTexturedRect(x, y, size, size)
				end
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
				F4Menu:AddFavouriteJob(self.Data.name)


				local copy = table.Copy(self.Data)
				copy.deleteOnFavouriteRemove = true
				hook.Run("F4Menu.FavouriteAdded", copy)
			else
				F4Menu:RemoveFavouriteJob(self.Data.name)

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
			hook.Run("F4Menu.FavouriteRemoved", self.Data.name)
		end
	end
	hook.Add("F4Menu.FavouriteRemoved", self.Star, function(pnl, name)
		if (self.Data.name == name) then
			self.Star:EndAnimations()
			self.Star.State = false
			self.Star:Lerp("Overlay", 0, 0.3)

			if self.Data.deleteOnFavouriteRemove then
				local cat = self:GetParent():GetParent()


				if self.Data.hideFavourite then
					self:Remove()
				else
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
		end
	end)
	hook.Add("F4Menu.FavouriteAdded", self.Star, function(pnl, data)
		if (data.name != self.Data.name) then return end

		pnl:Lerp("Overlay", 1, 0.3)
		pnl.State = true
	end)

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
	self.Star:AlignRight(h + (self.Level:IsVisible() and (self.Level:GetWide() - 16) or -4))
	self.Star:CenterVertical()

	self.IsDonator:SetSize(h, h)
	self.IsDonator:CenterVertical()
	local x = self.Star:GetPos()
	self.IsDonator:AlignLeft(x - self.Star:GetWide() - 16)
end

function PANEL:HandleData(data, index)
	local model = istable(data.model) and data.model[1] or data.model
	self.Model = model
	if (!F4Menu.Config.HideModels) then
		self.ModelPanel:SetModel(model)

		if F4Menu.Config.RealtimeModels then
			if data.xeninBodygroups then
				for i, v in pairs(data.xeninBodygroups) do
					self.ModelPanel.Entity:SetBodygroup(i, v)
				end
			end
		else
			self.ModelPanel.Icon.PaintOver = function(pnl, w, h)
				XeninUI:MaskInverse(function()
					XeninUI:DrawRoundedBox(h / 2, 0, 0, w, h, color_white)
				end, function()
					XeninUI:DrawRoundedBox(0, 0, 0, w, h, XeninUI.Theme.Primary)
				end)

				XeninUI:MaskInverse(function()
					XeninUI:DrawCircle(h / 2, h / 2, h / 2 - 1, 45, color_white)
				end, function()
					XeninUI:DrawCircle(h / 2, h / 2, h / 2, 45, self.Color)
				end)
			end
		end
	end

	local ply = LocalPlayer()

	self.Color = data.color
	self.Name = data.name
	self.Salary = F4Menu:GetPhrase("jobs.salary", {
	money = DarkRP.formatMoney(data.salary) })
	self.Limit = data.getMax and data.getMax(ply) or data.max
	self.Data = data
	if data.favourite then
		self.Star.State = true
		self.Star.Overlay = 1
	end
	if data.hideFavourite then
		self.Star:SetVisible(false)
	end

	self.IsDonator:SetVisible(data.ranks and !data.hideFavourite)
	self.Level:SetVisible(isnumber(data.level) and F4Menu.Config.JobLevelIndictatorEnabled)
	XeninUI:DownloadIcon(self.IsDonator, data.ranksIcon or {
		{
		id = "eozBUir" },
		{
			id = "aQK4lU",
			url = "https://i.hizliresim.com",
			type = "png"
		}
	})
end

XeninUI:CreateFont("F4Menu.Jobs.Row.Name", 20)
XeninUI:CreateFont("F4Menu.Jobs.Row.Level", 10)
XeninUI:CreateFont("F4Menu.Jobs.Row.Salary", 16)
XeninUI:CreateFont("F4Menu.Jobs.Row.Limit", 12)

function PANEL:Paint(w, h)
	if (!self.Color) then return end

	XeninUI:MaskInverse(function()
		XeninUI:DrawRoundedBoxEx(0, 4, 0, w * 0.4 - 4, h, self.Color, true, false, true, false)
	end, function()
		XeninUI:DrawRoundedBoxEx(6, 0, 0, w * 0.4, h, self.Color, true, false, true, false)
	end)
	XeninUI:DrawRoundedBoxEx(6, 4, 0, w - 4, h, Color(50, 50, 50), false, true, false, true)

	local x = IsValid(self.ModelPanel) and (self.ModelPanel.x + self.ModelPanel:GetWide() + self.ModelPanel.x) or 16

	XeninUI:DrawShadowText(self.Name, "F4Menu.Jobs.Row.Name", x, h / 2, Color(231, 231, 235), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, 150)
	XeninUI:DrawShadowText(self.Salary, "F4Menu.Jobs.Row.Salary", x, h / 2, Color(182, 182, 182), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, 150)


	local limit = self.Limit
	local frac = 0
	local str = ""
	if (limit == 0) then
		frac = 0
		str = "∞"
	else
		local amount = team.NumPlayers(self.Data.team)

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

function PANEL:DoClick()
	hook.Run("F4Menu.Jobs.Selected", F4Menu:FindJobIndexByName(self.Data.name), self.Data.hideFavourite)
end

vgui.Register("F4Menu.Jobs.Row", PANEL, "DButton")
