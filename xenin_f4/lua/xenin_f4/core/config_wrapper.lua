local CONFIG = {}

function CONFIG:Init()
	F4Menu.Config = {}
	F4Menu.Config.Staff = {}
	F4Menu.Config.Tabs = {}
	F4Menu.Config.Rules = {}
	F4Menu.Config.FAQ = {}

	F4Menu:CreateCommands()

	self:SetColumnsPerRow(2)
	self:SetCloseMenuAfterJobChange(false)
	self:SetDefaultJobSequence("pose_standing_02")
	self:SetEasySkins(true)
	self:SetDebounceLength(0.2)
	self:SetEmptySearchOnTabSwitch(true)
	self:SetCategoriesStartExpanded(true)
	self:SetMoneyConfig()
	self:SetItemsOrder()
	self:SetTitle("Xenin F4")
	self:SetResolution(1280, 750)
	self:SetLanguage("english")
	self:SetCategoriesBackgroundFullyColored(false)
	self:SetUseOfflineMoney(true)
	self:SetRealtimeModelsEnabled(true)
	self:SetSidebarColors({
		Player = {
			Color(208, 62, 106),
			Color(200, 60, 123)
		},
		PlayerAvatar = {
			Color(251, 211, 50),
			Color(69, 198, 103)
		},
		Commands = {
			Color(200, 60, 123),
			Color(176, 55, 180)
		}
	})
	self:SetColors({
		Top = XeninUI.Theme.Primary,
		Sidebar = XeninUI.Theme.Primary,
		Background = XeninUI.Theme.Background
	})
	self:SetDisabledCommands({})
	self:SetRichestPlayerConfig({})
	self:SetPrioritizeCanSee(true)
	self:SetShowNeedToChangeFrom(false)
	self:SetHideOnCustomCheckFail(false)
	self:SetJobSortOrder({
		"default",
		"alphabetically",
		"highestSalary",
		"lowestSalary",
		"mostPeople",
		"leastPeople"
	})
	self:SetHideModels(false)
	self:SetDashboardGeneralInfoOrder({
		"Online",
		"Money",
		"Jobs",
		"Richest Player"
	})
	self:SetDashboardTabOrder({
		"General",
		"Economy"
	})
	self:SetCheckboxStates({
		jobFavourite = true,
		jobRecent = true,
		itemsFavourite = true
	})
	self:SetSaveCheckboxStates(true)
	self:SetItemsSortOrder({
		"default",
		"alphabetically",
		"highestPrice",
		"lowestPrice"
	})
	self:SetJobLevelIndictatorEnabled(true)
	self:SetItemsLevelIndicatorEnabled(false)
	self:SetRebuildJobsOnOpen(false)

	if CLIENT then
		if IsValid(F4Menu.Frame) then
			F4Menu.Frame:Remove()
		end
	end

	F4Menu.CFG = self

	hook.Run("F4Menu.ConfigChanged", F4Menu.CFG)
end

function CONFIG:AddCategory(name, customCheck)
	F4Menu:CreateCommandCategory(name, {
		customCheck = customCheck or function()
			return true end,
		dontTranslate = true
	})
end

function CONFIG:AddCommand(category, name, command)
	local cat, id = F4Menu:GetCommandCategoryByName(category)
	if (!cat) then Error("[XENIN F4] Tried to add a command named " .. name .. ", but the category didn't exist\n")end

	F4Menu:AddCommand(id, {
		name = name,
		dontTranslate = true,
		func = function(ply)
			ply:ConCommand("say " .. command)
		end
	})
end

function CONFIG:SetRebuildJobsOnOpen(bool)
	F4Menu.Config.RebuildJobsOnOpen = bool
end

function CONFIG:SetJobLevelIndictatorEnabled(bool)
	F4Menu.Config.JobLevelIndictatorEnabled = bool
end

function CONFIG:SetItemsLevelIndicatorEnabled(bool)
	F4Menu.Config.ItemsLevelIndicatorEnabled = bool
end

function CONFIG:SetItemsSortOrder(tbl)
	F4Menu.Config.ItemsSortOrder = tbl
end

function CONFIG:SetCheckboxStates(tbl)
	F4Menu.Config.CheckboxStates = tbl
end

function CONFIG:SetSaveCheckboxStates(bool)
	F4Menu.Config.SaveCheckboxStates = bool
end

function CONFIG:SetDashboardTabOrder(tbl)
	F4Menu.Config.DashboardTabOrder = tbl
end

function CONFIG:SetDashboardGeneralInfoOrder(tbl)
	F4Menu.Config.DashboardGeneralInfoOrder = tbl
end

function CONFIG:SetHideModels(bool)
	F4Menu.Config.HideModels = bool
end

function CONFIG:SetHideOnCustomCheckFail(bool)
	F4Menu.Config.SetHideOnCustomCheckFail = bool
end

function CONFIG:SetShowNeedToChangeFrom(bool)
	F4Menu.Config.ShowNeedToChangeFrom = bool
end

function CONFIG:SetDisabledCommands(tbl)
	F4Menu.Config.DisabledCommands = tbl
end

function CONFIG:SetResolution(width, height)
	if isfunction(width) then
		F4Menu.Config.Resolution = width
	else
		F4Menu.Config.Resolution = {
			width or 1280,
			height or 750
		}
	end
end

function CONFIG:SetPrioritizeCanSee(bool)
	F4Menu.Config.PrioritizeCanSee = bool
end

function CONFIG:SetRealtimeModelsEnabled(bool)
	F4Menu.Config.RealtimeModels = bool
end

function CONFIG:SetColumnsPerRow(num)
	F4Menu.Config.ColumnsPerRow = num
end

function CONFIG:SetCloseMenuAfterJobChange(bool)
	F4Menu.Config.CloseMenuAfterJobChange = bool
end

function CONFIG:SetDefaultJobSequence(seq)
	F4Menu.Config.DefaultJobSequence = seq
end

function CONFIG:SetEasySkins(bool)
	F4Menu.Config.EasySkins = bool
end

function CONFIG:SetDebounceLength(len)
	F4Menu.Config.DebounceLength = len
end

function CONFIG:SetEmptySearchOnTabSwitch(bool)
	F4Menu.Config.EmptySearchOnTabSwitch = bool
end

function CONFIG:SetCategoriesStartExpanded(bool)
	F4Menu.Config.CategoriesStartExpanded = bool
end

function CONFIG:SetCategoriesBackgroundFullyColored(bool)
	F4Menu.Config.CategoriesBackgroundFullyColored = bool
end

function CONFIG:SetUseOfflineMoney(bool)
	F4Menu.Config.UseOfflineMoney = bool
end

function CONFIG:SetItemsOrder(tbl)
	tbl = tbl or {
		"Entities",
		"Weapons",
		"Shipments",
		"Ammo",
		"Vehicles",
		"Food"
	}

	F4Menu.Config.ItemsOrder = tbl
end

function CONFIG:SetJobSortOrder(tbl)
	tbl = tbl or {
		"default",
		"alphabetically",
		"highestSalary",
		"lowestSalary",
		"mostPeople",
		"leastPeople"
	}

	F4Menu.Config.JobSortOrder = tbl
end

function CONFIG:SetSidebarColors(tbl)
	F4Menu.Config.SidebarColors = tbl
end

function CONFIG:SetColors(tbl)
	F4Menu.Config.Colors = tbl
end

function CONFIG:SetMoneyConfig(tbl)
	tbl = tbl or {}
	tbl.CacheInterval = tbl.CacheInterval or 120
	tbl.DaysSinceLastLogin = tbl.DaysSinceLastLogin or 14
	if (tbl.IncludeBATM == false) then
		tbl.IncludeBATM = false
	else
		tbl.IncludeBATM = tbl.IncludeBATM or true
	end

	F4Menu.Config.TotalMoney = tbl
end

function CONFIG:SetRichestPlayerConfig(tbl)
	tbl = tbl or {}
	tbl.CacheInterval = tbl.CacheInterval or 1800
	if (tbl.IncludeBATM == false) then
		tbl.IncludeBATM = false
	else
		tbl.IncludeBATM = tbl.IncludeBATM or true
	end

	F4Menu.Config.RichestPlayer = tbl
end

function CONFIG:AddStaff(id, name, col, sortOrder)
	F4Menu.Config.Staff[id] = {
		str = name,
		color = col,
		sortOrder = sortOrder or 1
	}
end

function CONFIG:AddTab(tbl)
	local id = #F4Menu.Config.Tabs + 1
	F4Menu.Config.Tabs[id] = tbl
	F4Menu.Config.Tabs[id].type = "tab"
end

function CONFIG:AddURL(tbl)
	local id = #F4Menu.Config.Tabs + 1
	F4Menu.Config.Tabs[id] = tbl
	F4Menu.Config.Tabs[id].type = "url"
end

function CONFIG:AddWebsite(tbl)
	local id = #F4Menu.Config.Tabs + 1
	F4Menu.Config.Tabs[id] = tbl
	F4Menu.Config.Tabs[id].type = "website"
end

function CONFIG:AddDivider(startCol, endCol)
	F4Menu.Config.Tabs[#F4Menu.Config.Tabs + 1] = {
		type = "divider",
		startColor = startCol,
		endColor = endCol
	}
end

function CONFIG:SetActiveTab(name)
	F4Menu.Config.DefaultTab = name
end

function CONFIG:SetTitle(name)
	F4Menu.Config.Title = name
end

function CONFIG:SetXeninInventory(tbl)
	if (!tbl.enabled) then return end
	tbl.panel = "XeninInventory.XeninInventory"
	tbl.recreateOnSwitch = true

	self:AddTab(tbl)
end

function CONFIG:SetXeninBattlePass(tbl)
	if (!tbl.enabled) then return end
	tbl.panel = "BATTLEPASS_Menu.F4"

	self:AddTab(tbl)
end

function CONFIG:SetXeninCoinflips(tbl)
	if (!tbl.enabled) then return end
	tbl.panel = "Coinflip.Frame.F4"
	tbl.recreateOnSwitch = true

	self:AddTab(tbl)
end

function CONFIG:SetXeninDeathscreen(tbl)
	if (!tbl.enabled) then return end
	tbl.panel = "XeninDS.Shop"
	tbl.recreateOnSwitch = true

	self:AddTab(tbl)
end

function CONFIG:AddRule(tbl)
	table.insert(F4Menu.Config.Rules, tbl)
end

function CONFIG:SetLanguage(lang, tbl)
	F4Menu.Language = XeninUI:Language("xenin_f4menu")
	F4Menu.Language:SetURL("https://raw.githubusercontent.com/PatrickRatzow/Xenin-Languages")
	F4Menu.Language:SetFolder("f4menu")
	F4Menu.Language.ComputeURL = function(self, lang)
		local branch = self:GetBranch() or "master"
		local url = self:GetURL()
		local folder = self:GetFolder()

		return tostring(url) .. "/" .. tostring(branch) .. "/" .. tostring(folder) .. "/" .. tostring(lang) .. ".json"
	end

	F4Menu.Language:Download("english", true)
	F4Menu.Language:SetActiveLanguage(lang)
	if (lang != "english" and !tbl) then
		F4Menu.Language:Download(lang, true)
	elseif tbl then
		F4Menu.Language:SetLocalLanguage(lang, tbl)
	end
end

function F4Menu:CreateConfig()
	local tbl = table.Copy(CONFIG)
	tbl:Init()

	return tbl
end

function F4Menu:GetPhrase(phrase, replacement)
	return F4Menu.Language:GetPhrase(phrase, replacement)
end

function F4Menu:CreateCommandCategory(name, options)
	options = options or {}
	table.Merge(options, {
		name = name,
		commands = {}
	})
	local id = table.insert(F4Menu.Commands, options)

	local tbl = {}
	tbl.ID = id
	function tbl:AddCommand(tbl)
		local id = self.ID
		if (!id) then return self, Error("The category for " .. name .. " command doesn't seem to exist")end

		F4Menu:AddCommand(id, tbl)

		return self
	end

	return tbl
end

function F4Menu:AddCommand(cat, tbl)
	self.Commands[cat].commands[#self.Commands[cat].commands + 1] = tbl
end

function F4Menu:GetCommandCategoryByName(name)
	for i, v in ipairs(F4Menu.Commands) do
		if (v.name != name) then continue end

		return v, i
	end
end
