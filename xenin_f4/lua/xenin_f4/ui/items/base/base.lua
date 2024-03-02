local PANEL = {}
AccessorFunc(PANEL, "m_name", "Name")

XeninUI:CreateFont("F4Menu.Sort", 18)

function PANEL:Init()
	self:SetName("base")

	self.Scroll = self:Add("XeninUI.Scrollpanel.Wyvern")
	self.Scroll:Dock(FILL)

	self.Rebuild = true
end

function PANEL:Build()
	local name = self:GetName()
	XeninUI:RemoveDebounce("F4Menu." .. name)

	self:AddHook("OnPlayerChangedTeam", "F4Menu.Items." .. name, function(self, ply)
		self.Rebuild = true
	end)
	self:AddHook("F4Menu.Items.Rebuild", "F4Menu.Items." .. name, function(self)
		self:Build()
		self.Rebuild = true
	end)

	self.Scroll:Clear()
	self.Cats = {}

	local showFavourites = F4Menu.ItemsTop.Top.Favourite.State
	local sort = F4Menu.ItemsTop.Top.Sort:GetText()
	local search = F4Menu.ItemsTop.Top.Search:GetText()
	if (#search == 0) then
		search = nil
	end
	local favourites = F4Menu:GetFavourites(name)
	local favouritesLookup = {}
	for i, v in ipairs(favourites) do
		favouritesLookup[v] = i
	end

	local buildTree = {}

	if showFavourites then
		local tbl = {}
		for i, v in ipairs(favourites) do
			local lookup = self.Lookup[v]
			if (!lookup) then continue end

			if (!F4Menu["CanBuy" .. name](F4Menu, lookup)) then
				continue
			end

			if search then
				if (!self:FindBySearch(lookup, search)) then continue end
			end
			lookup.favourite = true
			lookup.deleteOnFavouriteRemove = true
			lookup.identifier = name

			table.insert(tbl, lookup)
		end

		table.insert(buildTree, {
			name = F4Menu:GetPhrase("items.favourites"),
			color = XeninUI.Theme.Accent,
			content = tbl,
			hook = function(h, cat)
				hook.Add("F4Menu.Items.FavouriteAdded." .. name, cat, function(pnl, data)
					pnl:SetExpanded(true)
					local panel = pnl.Layout:Add(pnl:GetLayoutPanel())
					data.favourite = true
					data.deleteOnFavouriteRemove = true
					if panel.HandleData then
						panel:HandleData(data, 1)
					end
					panel.Data.deleteOnFavouriteRemove = true
					panel.Alpha = 0
					panel:LerpAlpha(255, 0.3)

					local height = pnl:CalculateHeight()


					pnl.Top.NextHeight = pnl.Top.NextHeight or 48
					pnl.Top:LerpColor("background", pnl:GetTopColorActive())
					pnl.Top:Lerp("NextHeight", height, 0.3)

					pnl.Layout:InvalidateLayout(true)
					panel:InvalidateParent(true)
				end)
			end
		})
	end

	local cats = self:GetData()
	cats = self:SortCategory(cats, sort)

	for i, v in ipairs(cats or {}) do
		if (#v.members == 0) then continue end
		local members = v.members

		if search then
			members = {}

			for k, entry in ipairs(v.members) do
				if self:FindBySearch(entry, search) then
					entry.deleteOnFavouriteRemove = nil

					table.insert(members, entry)
				end
			end
		else
			for k, entry in ipairs(v.members) do
				entry.deleteOnFavouriteRemove = nil
			end
		end

		local copy = {}
		for i, v in ipairs(members) do
			if (!F4Menu["CanBuy" .. name](F4Menu, v)) then
				continue
			end

			if favouritesLookup[v.name] then
				v.favourite = true
			end

			v.identifier = name

			table.insert(copy, v)
		end

		table.insert(buildTree, {
			name = v.name,
			color = v.color,
			content = copy
		})
	end

	for i, v in ipairs(buildTree) do
		local canSee = F4Menu.Config.PrioritizeCanSee and (v.canSee and v.canSee(LocalPlayer()))
		if (v.canSee and !canSee) then continue end
		if (#v.content == 0 and !v.hook) then continue end
		if (v.canSee and !v.canSee(LocalPlayer())) then continue end

		local cat = self.Scroll:Add("XeninUI.Category")
		cat:Dock(TOP)
		cat:DockMargin(0, 0, 8, 8)
		cat:SetTopColor(F4Menu.Config.CategoriesBackgroundFullyColored and ColorAlpha(v.color, 150) or XeninUI.Theme.Navbar)
		cat:SetTopColorHover(F4Menu.Config.CategoriesBackgroundFullyColored and ColorAlpha(v.color, 200) or XeninUI.Theme.Primary)
		cat:SetTopColorActive(F4Menu.Config.CategoriesBackgroundFullyColored and v.color or Color(56, 56, 56))
		cat:SetLayoutType(XENINUI_LAYOUT_GRID)
		cat:SetColumns(F4Menu.Config.ColumnsPerRow)
		cat:SetGridColumnHeight(64)
		if (!F4Menu.Config.CategoriesBackgroundFullyColored) then
			cat:SetCategoryColor(v.color)
		end
		cat:SetFont("F4Menu.Category.Title")
		cat:SetLayoutPanel("F4Menu.Items.Row")
		cat.Top.background = cat:GetTopColor()
		cat:SetName(v.name)
		local columns = F4Menu.Config.ColumnsPerRow
		local w = (columns == 1 and 80 or 76) * columns

		local content = self:Sort(v.content)
		cat:SetInstantExpandWidth(w)
		local expand = v.startExpanded
		if (expand == nil) then
			expand = F4Menu.Config.CategoriesStartExpanded
		end
		cat:FeedData(content, 1, expand and #v.content > 0)


		if v.hook then
			v:hook(cat)
		end
	end

	self:InvalidateLayout(true)
end

function PANEL:FindBySearch(tbl, search)
	local keywords = tbl.keywords or ""
	local name = tbl.name
	name = name:lower():Trim()

	return keywords:find(search) or name:find(search)
end

function PANEL:OnSwitchedTo()
	if F4Menu.Config.EmptySearchOnTabSwitch then
		F4Menu.ItemsTop.Top.Search:SetText("")
		XeninUI:RemoveDebounce("F4Menu.Items.Build")
	end

	if self.Rebuild then
		self:Build()

		self.Rebuild = nil
	end
end

function PANEL:OnSwitchedFrom()
	if F4Menu.Config.EmptySearchOnTabSwitch then
		self.Rebuild = true
	end
end

function PANEL:Cache()
	self.Lookup = {}
	for i, v in pairs(DarkRPEntities) do
		if (!istable(v)) then continue end

		self.Lookup[v.name] = table.Copy(v)
		self.Lookup[v.name].keywords = (self.Lookup[v.name].keywords or ""):lower():Trim()
	end
end

function PANEL:GetData()
	local name = self:GetName()
	local cats
	if (name == "food") then
		cats = {
		{
			name = F4Menu:GetPhrase("items.food.categoryName"),
			color = XeninUI.Theme.Yellow,
			members = FoodItems
		}
		}
	elseif (name == "vehicles") then
		cats = {
		{
			name = F4Menu:GetPhrase("items.vehicles.categoryName"),
			color = XeninUI.Theme.Purple,
			members = CustomVehicles
		}
		}
	else
		cats = DarkRP.getCategories()[name]
	end
	cats = self:SortCategory(cats)

	return cats
end


function PANEL:SortCategory(tbl)
	if (!tbl) then return end
	if (#tbl == 0) then return tbl end
	local sortType = F4Menu.ItemsTop.Top.Sort:GetText()
	local temp = table.Copy(tbl)

	if (sortType == F4Menu:GetPhrase("items.top.sort.alphabetically")) then
		table.sort(temp, function(a, b)
			return b.name > a.name
		end)
	else
		table.sort(temp, function(a, b)
			local aSO = a.sortOrder or 100
			local bSO = b.sortOrder or 100

			return aSO < bSO or aSO == bSO and a.name < b.name
		end)
	end

	return temp
end

function PANEL:Sort(tbl)
	if (!tbl) then return end
	if (#tbl == 0) then return tbl end
	local sortType = F4Menu.ItemsTop.Top.Sort:GetText()
	local temp = table.Copy(tbl)
	local name = self:GetName()

	if (sortType == F4Menu:GetPhrase("items.top.sort.default")) then
		table.sort(temp, function(a, b)
			local aSO = a.sortOrder or 100
			local bSO = b.sortOrder or 100

			return aSO < bSO or aSO == bSO and a.name < b.name
		end)
	elseif (sortType == F4Menu:GetPhrase("items.top.sort.alphabetically")) then
		table.sort(temp, function(a, b)
			return b.name > a.name
		end)
	elseif (sortType == F4Menu:GetPhrase("items.top.sort.highestPrice")) then
		table.sort(temp, function(a, b)
			if (name == "weapons") then
				return b.pricesep < a.pricesep
			else
				return b.price < a.price
			end
		end)
	elseif (sortType == F4Menu:GetPhrase("items.top.sort.lowestPrice")) then
		table.sort(temp, function(a, b)
			if (name == "weapons") then
				return b.pricesep > a.pricesep
			else
				return b.price > a.price
			end
		end)
	end

	return temp
end

vgui.Register("F4Menu.Items.Base", PANEL, "Panel")
