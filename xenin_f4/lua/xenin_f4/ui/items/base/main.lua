local PANEL = {}

function PANEL:Init()
	local ply = LocalPlayer()

	F4Menu.ItemsTop = self

	self.Panels = {
		["Entities"] = {
			Name = F4Menu:GetPhrase("items.tabs.entities"),
			Panel = "F4Menu.Items.Entities"
		},
		["Weapons"] = {
			Name = F4Menu:GetPhrase("items.tabs.weapons"),
			Panel = "F4Menu.Items.Weapons"
		},
		["Shipments"] = {
			Name = F4Menu:GetPhrase("items.tabs.shipments"),
			Panel = "F4Menu.Items.Shipments"
		},
		["Ammo"] = {
			Name = F4Menu:GetPhrase("items.tabs.ammo"),
			Panel = "F4Menu.Items.Ammo"
		},
		["Vehicles"] = {
			Name = F4Menu:GetPhrase("items.tabs.vehicles"),
			Panel = "F4Menu.Items.Vehicles",
			Check = function()
				return !table.IsEmpty(CustomVehicles or {})end
		},
		["Food"] = {
			Name = F4Menu:GetPhrase("items.tabs.food"),
			Panel = "F4Menu.Items.Food",
			Check = function()
				return !table.IsEmpty(FoodItems or {})end
		}
	}

	self:DockPadding(16, 16, 16, 16)
	self:BuildTop("F4Menu.Items")
end

function PANEL:Build()
	local active = self.Navbar:GetActive()
	if (!IsValid(active)) then return end

	for i, v in pairs(self.Navbar.panels) do
		if (v == active) then continue end

		v.Rebuild = true
	end

	active:Build()
end

function PANEL:GetPanel(id)
	return self.Panels[id]
end

function PANEL:BuildTop(name)
	self.Top = self:Add("DPanel")
	self.Top:Dock(TOP)
	self.Top:DockPadding(8, 8, 8, 8)
	self.Top:SetTall(52)
	self.Top.Paint = function(pnl, w, h)
		XeninUI:DrawRoundedBoxEx(6, 0, 0, w, h, XeninUI.Theme.Primary, true, true, false, false)
	end

	self.Top.Search = self.Top:Add("XeninUI.TextEntry")
	self.Top.Search:Dock(LEFT)
	self.Top.Search:SetPlaceholder(F4Menu:GetPhrase("items.top.search"))
	self.Top.Search:SetIcon(XeninUI.Materials.Search, true)
	self.Top.Search.textentry:SetUpdateOnType(true)
	self.Top.Search.textentry.OnValueChange = function(pnl, text)
		XeninUI:Debounce(name .. ".Build", F4Menu.Config.DebounceLength, function()
			if (!IsValid(self)) then return end

			self:Build()
		end)
	end

	self.Top.Favourite = self.Top:Add("XeninUI.CheckboxV2")
	self.Top.Favourite:Dock(RIGHT)
	self.Top.Favourite:DockMargin(8, 8, 8, 8)
	self.Top.Favourite.TextColor = Color(225, 225, 225)
	self.Top.Favourite.Text = F4Menu:GetPhrase("items.top.showFavourite")
	self.Top.Favourite:SetState(F4Menu:GetCheckboxState("itemsFavourite"), true)
	self.Top.Favourite.OnStateChanged = function(pnl, state)
		self:Build()

		F4Menu:SetCheckboxState("itemsFavourite", state)
	end

	self.Top.Sort = self.Top:Add("DButton")
	self.Top.Sort:Dock(LEFT)
	self.Top.Sort:DockMargin(8, 0, 0, 0)
	self.Top.Sort:SetText(F4Menu:GetPhrase("items.top.sort." .. F4Menu.Config.ItemsSortOrder[1]))
	self.Top.Sort:SetFont("F4Menu.Sort")
	self.Top.Sort:SetTextColor(Color(190, 190, 190))
	self.Top.Sort:SetContentAlignment(5)
	self.Top.Sort.Paint = function(pnl, w, h)
		draw.RoundedBox(6, 0, 0, w, h, XeninUI.Theme.Navbar)
	end
	self.Top.Sort.SortChanged = function(pnl, text)
		pnl:SetText(text)
		self:Build()
		self.Top:InvalidateLayout()
	end
	self.Top.Sort.DoClick = function(pnl)
		local func = function(btn)
			pnl:SortChanged(btn:GetText())
		end
		local hoverColor = Color(75, 75, 75)

		local panel = XeninUI:DropdownPopup(pnl:LocalToScreen(-12, -12 + pnl:GetTall()))
		panel:SetBackgroundColor(XeninUI.Theme.Navbar)
		panel:SetTextColor(Color(185, 185, 185))
		for i, v in ipairs(F4Menu.Config.ItemsSortOrder) do
			panel:AddChoice(F4Menu:GetPhrase("items.top.sort." .. v), func, nil, hoverColor)
		end
	end

	self.Top.PerformLayout = function(pnl, w, h)
		pnl.Search:SetWide(200)
		pnl.Favourite:SizeToContentsX()
		pnl.Sort:SizeToContentsX(24)
	end

	self.Navbar = self:Add("XeninUI.Navbar")
	self.Navbar:Dock(TOP)
	self.Navbar:DockMargin(0, 0, 0, 8)
	self.Navbar:SetTall(56)
	self.Navbar.padding = 40
	self.Navbar:SetBody(self)

	for i, v in ipairs(F4Menu.Config.ItemsOrder) do
		local panel = self:GetPanel(v)
		if (!panel) then continue end
		if (panel.Check and !panel.Check(LocalPlayer())) then continue end

		self.Navbar:AddTab(panel.Name, panel.Panel)
	end

	local i = 1
	local selected
	repeat
		local panel = self:GetPanel(F4Menu.Config.ItemsOrder[i])
		if panel then
			if (!panel.Check or (panel.Check and panel.Check(LocalPlayer()))) then
				selected = panel.Name
			end
		end

		i = i + 1
	until selected or i >= #F4Menu.Config.ItemsOrder

	if selected then
		self.Navbar:SetActive(selected)
	end

	self.Navbar.Paint = function(pnl, w, h)
		XeninUI:DrawRoundedBoxEx(6, 0, 0, w, h, XeninUI.Theme.Primary, false, false, true, true)

		surface.SetDrawColor(XeninUI.Theme.Navbar)
		surface.DrawRect(0, 4, w, 1)
	end
	self.Navbar.line.Paint = function(pnl, w, h)
		pnl:NoClipping(false)
		XeninUI:Mask(function()
			local _w = self.Navbar:GetWide()
			local _h = self.Navbar:GetTall()
			local x, y = pnl:GetPos()
			XeninUI:DrawRoundedBoxEx(6, -x, -_h + h, _w, _h, color_white, false, false, true, true)
		end, function()
			surface.SetDrawColor(self.Navbar.accent)
			surface.DrawRect(0, 0, w, h)
		end)
		pnl:NoClipping(true)
	end

	hook.Add("OnPlayerChangedTeam", self, function(self, ply, old, new)
		self.RebuildOnSwitchedTo = true
	end)
end

function PANEL:OnSwitchedTo()
	if self.RebuildOnSwitchedTo then
		self:Build()

		self.RebuildOnSwitchedTo = nil
	end
end

vgui.Register("F4Menu.Items", PANEL)
