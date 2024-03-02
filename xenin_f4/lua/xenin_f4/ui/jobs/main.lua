local PANEL = {}

function PANEL:Build()
	XeninUI:RemoveDebounce("F4Menu.Build")

	if F4Menu.Config.SetHideOnCustomCheckFail then
		self:AddHook("OnPlayerChangedTeam", "F4Menu.Jobs", function(pnl, ply)
			self:Build()
		end)
	end

	local favourites = F4Menu:GetFavouriteJobs()
	local favouritesLookup = {}
	for i, v in ipairs(favourites) do
		favouritesLookup[v] = i
	end

	local showFavourites = self.Top.Favourite.State
	local showRecent = self.Top.Recent.State
	local sort = self.Top.Sort:GetText()
	local search = self.Top.Search:GetText():lower():Trim()
	if (#search == 0) then
		search = nil
	end

	local plyTeam = LocalPlayer():Team()

	self.Scroll:Clear()
	self.Cats = {}

	local buildTree = {}

	if showFavourites then
		local tbl = {}
		for i, v in ipairs(favourites) do
			local lookup = self.Lookup[v]
			if (!lookup) then continue end

			if search then
				if (!self:FindBySearch(lookup, search)) then continue end
			end
			lookup.favourite = true
			lookup.deleteOnFavouriteRemove = true

			table.insert(tbl, lookup)
		end

		table.insert(buildTree, {
			name = F4Menu:GetPhrase("jobs.favouriteJobs"),
			color = XeninUI.Theme.Accent,
			content = tbl,
			hook = function(h, cat)
				hook.Add("F4Menu.FavouriteAdded", cat, function(pnl, data)
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

	if showRecent then
		local recentJobs = {}
		for i, v in ipairs(F4Menu:GetRecentJobs()) do
			local lookup = RPExtraTeams[v]

			if (!lookup) then continue end
			if search then
				if (!self:FindBySearch(lookup, search)) then continue end
			end
			if favouritesLookup[lookup.name] then
				lookup.favourite = true
			end

			table.insert(recentJobs, lookup)
		end
		recentJobs = table.Reverse(recentJobs)

		table.insert(buildTree, {
			name = F4Menu:GetPhrase("jobs.recentJobs"),
			color = XeninUI.Theme.Purple,
			content = recentJobs,
			hook = function(self, cat)
				cat:AddHook("F4Menu.RecentChanged", "F4Menu.RecentJobs", function(pnl, id)
					local layout = pnl.Layout
					local children = layout:GetChildren()
					local childrenNum = #children

					if (childrenNum <= 3) then
						local panel = pnl.Layout:Add(pnl:GetLayoutPanel())
						local data = table.Copy(RPExtraTeams[id])
						local tbl = {}
						for i, v in ipairs(children) do
							if (v.Data.name == data.name) then return end
						end

						for i, v in ipairs(F4Menu:GetFavouriteJobs()) do
							if (v == data.name) then
								data.favourite = true

								break
							end
						end
						if panel.HandleData then
							panel:HandleData(data, 1)
						end
						panel.Alpha = 0
						panel:LerpAlpha(255, 0.3)

						local height = pnl:CalculateHeight()


						pnl.Top.NextHeight = pnl.Top.NextHeight or 48
						pnl.Top:LerpColor("background", pnl:GetTopColorActive())
						pnl.Top:Lerp("NextHeight", height, 0.3)
						pnl.Layout:InvalidateLayout(true)
						panel:InvalidateParent(true)
					else
						local tbl = {}
						for i = 1, 3 do
							tbl[i + 1] = children[i].Data
						end
						tbl[1] = table.Copy(RPExtraTeams[id])

						for i, v in ipairs(tbl) do
							children[i]:HandleData(v)
						end
					end
				end)
			end
		})
	end

	local cats = DarkRP.getCategories().jobs
	cats = self:SortCategory(cats, sort)

	for i, v in ipairs(cats) do
		if (#v.members == 0) then continue end
		local members = v.members
		if search then
			members = {}

			for k, job in ipairs(v.members) do
				if self:FindBySearch(job, search) then
					job.deleteOnFavouriteRemove = nil

					table.insert(members, job)
				end
			end
		else
			for k, job in ipairs(v.members) do
				job.deleteOnFavouriteRemove = nil
			end
		end

		local tbl = {}
		for i, v in ipairs(members) do
			if v.__isCustomXeninJob then
				if (v.disabled) then continue end
				if (!v.customCheck) then continue end
				if (!v.customCheck(LocalPlayer())) then continue end
			end

			if (v.NeedToChangeFrom and !F4Menu.Config.ShowNeedToChangeFrom) then
				if (istable(v.NeedToChangeFrom) and !table.HasValue(v.NeedToChangeFrom, plyTeam) or (!istable(v.NeedToChangeFrom) and v.NeedToChangeFrom != plyTeam)) then
					continue
				end
			end

			if favouritesLookup[v.name] then
				v.favourite = true
			end

			if v.customCheck then
				if (F4Menu.Config.SetHideOnCustomCheckFail and !v.customCheck(LocalPlayer())) then
					continue
				end
			end

			table.insert(tbl, v)
		end

		table.insert(buildTree, {
			name = v.name,
			color = v.color,
			content = tbl
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
		cat:SetLayoutPanel("F4Menu.Jobs.Row")
		cat.Top.background = cat:GetTopColor()
		cat:SetName(v.name)
		local columns = F4Menu.Config.ColumnsPerRow
		local w = (columns == 1 and 80 or 76) * columns

		local content = self:Sort(v.content, sort)
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

function PANEL:SortCategory(tbl, sortType)
	if (#tbl == 0) then return tbl end
	local temp = table.Copy(tbl)

	if (sortType == F4Menu:GetPhrase("jobs.top.sort.alphabetically")) then
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

function PANEL:Sort(tbl, sortType)
	if (#tbl == 0) then return tbl end
	local temp = table.Copy(tbl)

	if (sortType == F4Menu:GetPhrase("jobs.top.sort.default")) then
		table.sort(temp, function(a, b)
			local aSO = a.sortOrder or 100
			local bSO = b.sortOrder or 100

			return aSO < bSO or aSO == bSO and a.name < b.name
		end)
	elseif (sortType == F4Menu:GetPhrase("jobs.top.sort.alphabetically")) then
		table.sort(temp, function(a, b)
			return b.name > a.name
		end)
	elseif (sortType == F4Menu:GetPhrase("jobs.top.sort.highestSalary")) then
		table.sort(temp, function(a, b)
			return b.salary < a.salary
		end)
	elseif (sortType == F4Menu:GetPhrase("jobs.top.sort.lowestSalary")) then
		table.sort(temp, function(a, b)
			return b.salary > a.salary
		end)
	elseif (sortType == F4Menu:GetPhrase("jobs.top.sort.mostPeople")) then

		table.sort(temp, function(a, b)
			return #team.GetPlayers(b.team) < #team.GetPlayers(a.team)
		end)
	elseif (sortType == F4Menu:GetPhrase("jobs.top.sort.leastPeople")) then

		table.sort(temp, function(a, b)
			return #team.GetPlayers(b.team) > #team.GetPlayers(a.team)
		end)
	end

	return temp
end

function PANEL:FindBySearch(tbl, search)
	local keywords = tbl.keywords or ""
	local name = tbl.name
	name = name:lower():Trim()

	return keywords:find(search) or name:find(search)
end

function PANEL:Init()
	self.Lookup = {}
	for i, v in pairs(RPExtraTeams or {}) do
		if (!istable(v)) then continue end

		self.Lookup[v.name] = table.Copy(v)
		self.Lookup[v.name].keywords = (self.Lookup[v.name].keywords or ""):lower():Trim()
	end

	local ply = LocalPlayer()

	self:DockPadding(16, 16, 16, 16)

	self.Top = self:Add("DPanel")
	self.Top:Dock(TOP)
	self.Top:DockMargin(0, 0, 0, 8)
	self.Top:DockPadding(8, 8, 8, 8)
	self.Top:SetTall(52)
	self.Top.Paint = function(pnl, w, h)
		XeninUI:DrawRoundedBox(6, 0, 0, w, h, XeninUI.Theme.Primary)
	end

	self.Top.Search = self.Top:Add("XeninUI.TextEntry")
	self.Top.Search:Dock(LEFT)
	self.Top.Search:SetPlaceholder(F4Menu:GetPhrase("jobs.top.search"))
	self.Top.Search:SetIcon(XeninUI.Materials.Search, true)
	self.Top.Search.textentry:SetUpdateOnType(true)
	self.Top.Search.textentry.OnValueChange = function(pnl, text)
		XeninUI:Debounce("F4Menu.Build", F4Menu.Config.DebounceLength, function()
			if (!IsValid(self)) then return end

			self:Build()
		end)
	end

	self.Top.Favourite = self.Top:Add("XeninUI.CheckboxV2")
	self.Top.Favourite:Dock(RIGHT)
	self.Top.Favourite:DockMargin(8, 8, 8, 8)
	self.Top.Favourite.TextColor = Color(225, 225, 225)
	self.Top.Favourite.Text = F4Menu:GetPhrase("jobs.top.showFavouriteJobs")
	self.Top.Favourite:SetState(F4Menu:GetCheckboxState("jobsFavourite"), true)
	self.Top.Favourite.OnStateChanged = function(pnl, state)
		self:Build()

		F4Menu:SetCheckboxState("jobsFavourite", state)
	end

	self.Top.Recent = self.Top:Add("XeninUI.CheckboxV2")
	self.Top.Recent:Dock(RIGHT)
	self.Top.Recent:DockMargin(8, 8, 8, 8)
	self.Top.Recent.TextColor = Color(225, 225, 225)
	self.Top.Recent.Text = F4Menu:GetPhrase("jobs.top.showRecentJobs")
	self.Top.Recent:SetState(F4Menu:GetCheckboxState("jobsRecent"), true)
	self.Top.Recent.OnStateChanged = function(pnl, state)
		self:Build()

		F4Menu:SetCheckboxState("jobsRecent", state)
	end
	self.Top.Sort = self.Top:Add("DButton")
	self.Top.Sort:Dock(LEFT)
	self.Top.Sort:DockMargin(8, 0, 0, 0)
	self.Top.Sort:SetText(F4Menu:GetPhrase("jobs.top.sort." .. F4Menu.Config.JobSortOrder[1]))
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
		for i, v in ipairs(F4Menu.Config.JobSortOrder) do
			panel:AddChoice(F4Menu:GetPhrase("jobs.top.sort." .. v), func, nil, hoverColor)
		end
	end

	self.Top.PerformLayout = function(pnl, w, h)
		pnl.Search:SetWide(200)
		pnl.Favourite:SizeToContentsX()
		pnl.Recent:SizeToContentsX()
		pnl.Sort:SizeToContentsX(24)
	end

	self.Scroll = self:Add("XeninUI.Scrollpanel.Wyvern")
	self.Scroll:Dock(FILL)

	self.Cats = {}

	self:AddHook("F4Menu.Jobs.Selected", "F4Menu", function(self, team, isDashboard)
		if (!isDashboard) then
			self:CreateOverlay(team)
			self:InvalidateLayout(true)
		end
	end)
	self:AddHook("OnPlayerChangedTeam", "F4Menu.JobMain", function(self, ply)
		timer.Simple(0.2, function()
			if (!IsValid(self)) then return end

			self:Build()
		end)
	end)
	self:AddHook("F4Menu.Jobs.Rebuild", "F4Menu", function(self)
		self.Rebuild = true
		self:Build()
	end)

	self:Build()
end

function PANEL:OnSwitchedTo()
	if self.Rebuild then
		self:Build()

		self.Rebuild = nil
	end
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

	hook.Add("F4Menu.CloseMenu", self.Overlay, function(pnl)
		pnl:OnMouseReleased()end)

	self.Overlay.Body = self.Overlay:Add("F4Menu.Jobs.Slideout")
	self.Overlay.Body.Offset = 0
	self.Overlay.Body.Animating = 0
	self.Overlay.Body:Lerp("Offset", 650)
	self.Overlay.Body.Think = function(pnl)
		if (pnl.Animating <= 1) then
			self:InvalidateLayout()
		end
	end
	self.Overlay.Body:SetJob(team)
end

function PANEL:PerformLayout(w, h)
	if (!IsValid(self.Overlay)) then return end

	self.Overlay:SetSize(w, h)
	self.Overlay.Body:SetSize(650, h)
	self.Overlay.Body:SetPos(w - self.Overlay.Body.Offset, 0)
end

vgui.Register("F4Menu.Jobs", PANEL, "Panel")

timer.Simple(0, function()
	function DarkRP.openF4Menu()
		F4Menu:OpenMenu()end
	function DarkRP.closeF4Menu() end
	function DarkRP.toggleF4Menu()
		DarkRP.openF4Menu()end

	GAMEMODE.ShowSpare2 = DarkRP.toggleF4Menu
end)
