local PANEL = {}


XeninUI:CreateFont("F4Menu.Dashboard.Job", 20)

PANEL.Tabs = {
	General = "F4Menu.Dashboard.Stats.General",
	Economy = "F4Menu.Dashboard.Stats.Graph"
}

function PANEL:Init()
	self:DockPadding(16, 16, 16, 16)

	self.Lookup = {}
	for i, v in pairs(RPExtraTeams or {}) do
		if (!istable(v)) then continue end

		self.Lookup[v.name] = table.Copy(v)
	end

	self.TopContainer = self:Add("Panel")
	self.TopContainer:Dock(TOP)

	self.Navbar = self.TopContainer:Add("F4Menu.Dashboard.Navbar")
	self.Navbar:Dock(TOP)
	self.Navbar:DockMargin(0, 0, 0, 8)

	self.NavbarBody = self.TopContainer:Add("Panel")
	self.NavbarBody:Dock(FILL)

	self.BottomContainer = self:Add("Panel")
	self.BottomContainer:Dock(FILL)

	self.BottomContainer.Left = self.BottomContainer:Add("Panel")
	self.BottomContainer.Left:Dock(LEFT)

	self.Favourites = self.BottomContainer.Left:Add("Panel")
	self.Favourites:Dock(FILL)
	self.Favourites:DockMargin(0, 16, 0, 0)
	self.Favourites.Paint = function(pnl, w, h)
		draw.SimpleText(F4Menu:GetPhrase("dashboard.favouriteJobs.title"), "F4Menu.Dashboard.Navbar", 0, 32 / 2, Color(212, 212, 212), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		if (#pnl.Scroll:GetCanvas():GetChildren() == 0) then
			draw.SimpleText(F4Menu:GetPhrase("dashboard.favouriteJobs.none"), "F4Menu.Dashboard.Job", 0, 36, Color(212, 212, 212), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	end

	self.Favourites.Scroll = self.Favourites:Add("XeninUI.Scrollpanel.Wyvern")
	self.Favourites.Scroll:Dock(FILL)
	self.Favourites.Scroll:DockMargin(0, 40, 16, 0)

	self.Favourites.Layout = self.Favourites.Scroll:Add("DIconLayout")
	self.Favourites.Layout:Dock(TOP)
	self.Favourites.Layout:DockMargin(0, 0, 8, 0)
	self.Favourites.Layout:SetSpaceY(4)
	self.Favourites.Layout:SetSpaceX(4)
	self.Favourites.Layout.PerformLayout = function(pnl, w, h)
		local children = pnl:GetChildren()
		local count = 2
		local amount = math.max(1, math.floor(#children / count)) * 276
		local width = w / math.min(count, #children)

		local x = 0
		local y = 0

		local spacingX = pnl:GetSpaceX()
		local spacingY = pnl:GetSpaceY()
		local border = pnl:GetBorder()
		local innerWidth = w - border * 2 - spacingX * (count - 1)

		for i, child in ipairs(children) do
			if (!IsValid(child)) then continue end

			child:SetPos(border + x * innerWidth / count + spacingX * x, border + y * child:GetTall() + spacingY * y)
			child:SetSize(innerWidth / count, 64)

			x = x + 1
			if (x >= count) then
				x = 0
				y = y + 1
			end
		end

		pnl:SizeToChildren(false, true)
	end

	hook.Add("F4Menu.FavouriteAdded", self.Favourites.Layout, function(pnl, data)
		data = table.Copy(data)

		local panel = self.Favourites.Layout:Add("F4Menu.Jobs.Row")
		data.favourite = true
		data.deleteOnFavouriteRemove = true
		data.hideFavourite = true
		if panel.HandleData then
			panel:HandleData(data, 1)
		end

		self:InvalidateLayout(true)
	end)
	hook.Add("F4Menu.FavouriteRemoved", self.Favourites.Layout, function(pnl, name)
		for i, v in ipairs(pnl:GetChildren()) do
			if (v.Data.name == name) then
				v:Remove()
			end
		end
	end)

	local favourites = F4Menu:GetFavouriteJobs()
	for i, v in ipairs(favourites) do
		local lookup = self.Lookup[v]
		if (!lookup) then continue end
		lookup.hideFavourite = true

		local panel = self.Favourites.Layout:Add("F4Menu.Jobs.Row")
		panel:HandleData(lookup, 1)
	end

	self.Staff = self.BottomContainer:Add("F4Menu.Dashboard.Staff")
	self.Staff:Dock(FILL)
	self.Staff:DockMargin(0, 16, 0, 0)

	self.Navbar:SetBody(self.NavbarBody)
	for i, v in ipairs(F4Menu.Config.DashboardTabOrder) do
		local tab = self.Tabs[v]
		if (!tab) then continue end

		self.Navbar:AddTab(F4Menu:GetPhrase("dashboard.tabs." .. v:lower() .. ".name"), tab)
	end
	self.Navbar:SetActive(1)

	self:AddHook("F4Menu.Jobs.Selected", "F4Menu.Dashboard", function(self, team, isDashboard)
		if isDashboard then
			self:CreateOverlay(team)
			self:InvalidateLayout(true)
		end
	end)
end

function PANEL:CreateOverlay(team)
	self.Overlay = self:Add("DPanel")
	self.Overlay.Color = Color(0, 0, 0, 0)
	self.Overlay.Blur = 0
	self.Overlay:LerpColor("Color", Color(0, 0, 0, 150))
	self.Overlay:Lerp("Blur", 2)
	self.Overlay.Paint = function(pnl, w, h)
		XeninUI:DrawBlur(pnl, pnl.Blur)
		XeninUI:DrawRoundedBoxEx(6, 0, 0, w, h, pnl.Color, false, false, false, true)
	end
	self.Overlay.OnMouseReleased = function(pnl)
		if pnl.Closing then return end

		pnl.Closing = true
		pnl.Alpha = 255
		pnl:LerpAlpha(0, 0.15, function()
			pnl:Remove()
		end)
	end

	hook.Add("F4Menu.CloseMenu", self.Overlay, function(pnl, dashboard)
		if dashboard then
			pnl:OnMouseReleased()
		end
	end)

	self.Overlay.Body = self.Overlay:Add("F4Menu.Jobs.Slideout")
	self.Overlay.Body.Offset = 0
	self.Overlay.Body.Animating = 0
	self.Overlay.Body.Dashboard = true
	self.Overlay.Body:Lerp("Offset", 650)
	self.Overlay.Body.Think = function(pnl)
		if (pnl.Animating <= 1) then
			self:InvalidateLayout()
		end
	end
	self.Overlay.Body:SetJob(team)
end


function PANEL:PerformLayout(w, h)
	self.TopContainer:SetTall(h * 0.375)
	self.BottomContainer.Left:SetWide(w * 0.66)

	self.Navbar:SetTall(32)

	if (!IsValid(self.Overlay)) then return end

	self.Overlay:SetSize(w, h)
	self.Overlay.Body:SetSize(650, h)
	self.Overlay.Body:SetPos(w - self.Overlay.Body.Offset, 0)
end

vgui.Register("F4Menu.Dashboard", PANEL)
