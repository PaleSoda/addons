local FPSThink, FPSPaint, OptimizingThink

bKeypads.Settings = {}

hook.Add("AddToolMenuTabs", "bKeypads.Spawnmenu.Options", function()
	spawnmenu.AddToolTab("Options", "Options", "icon16/wrench.png")
end)
hook.Add("AddToolMenuCategories", "bKeypads.Spawnmenu.Options", function()
	spawnmenu.AddToolCategory("Options", "Billy's Keypads", "Billy's Keypads")
end)
hook.Add("PopulateToolMenu", "bKeypads.Spawnmenu.Options.Settings", function()
	spawnmenu.AddToolMenuOption("Options", "Billy's Keypads", "bKeypads.Settings", "#bKeypads_Settings", "", "", function(CPanel)
		bKeypads:InjectSmoothScroll(CPanel)
		bKeypads.Settings:BuildCPanel(CPanel)
	end)
end)

function bKeypads.Settings:Init()
	bKeypads.Settings.Registry = {
		["#bKeypads_Setting_Other"] = {
			{
				key = "tooltip_text_size",
				name = "#bKeypads_Setting_TooltipSize",

				type = "number",
				default = 13,
				min = 8,
				max = 24,

				onChange = function(val)
					bKeypads:CreateTooltipFont()
				end,

				postPanel = function(categoryPanel, settingPanel)
					bKeypads:RecursiveTooltip(bKeypads.L"Preview", settingPanel)
				end,
			},

			{
				key = "draw_properties",
				name = "#bKeypads_Setting_DrawKeypadProperties",
				tip = "#bKeypads_Setting_DrawKeypadPropertiesTip",

				type = "boolean",
				default = false
			}
		},

		["#bKeypads_Setting_CustomImages"] = {
			{
				key = "custom_images",
				name = "#bKeypads_Enable",
				tip = "#bKeypads_Setting_CustomImagesTip",

				type = "boolean",
				default = true
			},

			{
				key = "force_imgur",
				name = "#bKeypads_Setting_CustomImages_Imgur",
				tip = "#bKeypads_Setting_CustomImages_ImgurTip",

				type = "boolean",
				default = false
			},
		},

		["#bKeypads_Notifications"] = {
			{
				key = "notification_sounds",
				name = "#bKeypads_Sounds",

				type = "boolean",
				default = true
			},

			{
				key = "notification_time",
				name = "#bKeypads_Setting_NotificationsTime",
				tip = "#bKeypads_Setting_NotificationsTimeTip",

				type = "number",
				default = 3,
				min = 1,
				max = 10,
			},

			{
				key = "notification_max",
				name = "#bKeypads_Setting_NotificationsMax",
				tip = "#bKeypads_Setting_NotificationsMaxTip",

				type = "number",
				default = 4,
				min = 1,
				max = 10,
			},

			{
				key = "notification_text_size",
				name = "#bKeypads_Setting_NotificationsTextSize",

				type = "number",
				default = 18,
				min = 14,
				max = 24,

				onChange = function()
					bKeypads.Notifications:CreateFont()
				end,
			},
		},

		["#bKeypads_Setting_Optimizations"] = {
			{
				key = "optimizations",
				name = "#bKeypads_Setting_Optimizations",
				tip = "#bKeypads_Setting_OptimizationsTip",

				type = "combo",
				default = "auto",
				choices = {
					["auto"] = {
						name = "#bKeypads_Setting_Optimizations_Auto",
						icon = "icon16/wand.png"
					},
					["none"] = {
						name = "#bKeypads_None",
						icon = "icon16/lightning.png"
					},
					["potato"] = {
						name = "#bKeypads_Setting_Optimizations_Potato",
						icon = "icon16/box.png"
					},
				},

				prePanel = function(categoryPanel)
					local FPSPanel = vgui.Create("DPanel", categoryPanel)
					FPSPanel:DockPadding(5, 5, 5, 5)
					FPSPanel.Paint = FPSPaint

					FPSPanel.FPSLabel = vgui.Create("DLabel", FPSPanel)
					FPSPanel.FPSLabel:SetContentAlignment(5)
					FPSPanel.FPSLabel:Dock(TOP)
					FPSPanel.FPSLabel:SetText("FPS: ?")
					FPSPanel.FPSLabel:SetFont("DebugOverlay")
					FPSPanel.FPSLabel:SetTextColor(color_white)
					FPSPanel.FPSLabel.Think = FPSThink

					FPSPanel.OptimizingLabel = vgui.Create("DLabel", FPSPanel)
					FPSPanel.OptimizingLabel:SetContentAlignment(5)
					FPSPanel.OptimizingLabel:Dock(TOP)
					FPSPanel.OptimizingLabel:SetText("Optimizing: ?")
					FPSPanel.OptimizingLabel:SetFont("DebugOverlay")
					FPSPanel.OptimizingLabel:SetTextColor(color_white)
					FPSPanel.OptimizingLabel.Think = OptimizingThink

					categoryPanel:AddItem(FPSPanel)
				end,
			},

			{
				key = "optimizations_fps_threshold",
				name = "#bKeypads_Setting_AutoThreshold",
				tip = "#bKeypads_Setting_AutoThresholdTip",

				type = "number",
				default = 45,
				min = 5,
				max = 100,

				onChange = function(val)
					bKeypads.Performance.FPSThreshold = val
				end,
			},

			{
				key = "optimizations_3d2d_distance",
				name = "#bKeypads_Setting_3D2DDistance",
				tip = "#bKeypads_Setting_3D2DDistanceTip",

				type = "number",
				default = 1000,
				min = 100,
				max = 5000
			},

			{
				key = "optimizations_disable_keycard_textures",
				name = "#bKeypads_Setting_KeycardTextures",
				tip = "#bKeypads_Setting_KeycardTexturesTip",

				type = "boolean",
				default = false,

				onChange = function(disable)
					if disable then
						bKeypads.Keycards.Textures:Reset()
					end
				end,
			},
		},

		["#bKeypads_Setting_Accessibility"] = {
			--[[
			{
				key = "color_blindness",
				name = "#bKeypads_Setting_ColorBlindness",
				tip = "#bKeypads_Setting_ColorBlindnessTip",

				-- TODO
			},
			]]

			{
				key = "pin_input_mode",
				name = "#bKeypads_Setting_PINInputMode",
				tip = "#bKeypads_Setting_PINInputModeTip",
				type = "combo",
				default = "look",
				choices = {
					["look"] = {
						name = "#bKeypads_Look",
						icon = "icon16/eye.png"
					},
					["mouse"] = {
						name = "#bKeypads_Mouse",
						icon = "icon16/mouse.png"
					}
				},
			},

			{
				key = "dyslexia",
				name = "#bKeypads_Setting_Dyslexia",
				tip = "#bKeypads_Setting_DyslexiaTip",
				type = "boolean",
				default = false,

				onChange = function()
					include("bkeypads/cl_fonts.lua")
					RunConsoleCommand("spawnmenu_reload")
				end,

				postPanel = function(categoryPanel, settingPanel, helpPanel)
					bKeypads.RecursiveDyslexia(settingPanel)
					bKeypads.RecursiveDyslexia(helpPanel)
				end,
			},
		},
	}
end
bKeypads.Settings:Init()
bKeypads.Settings.Metadata = {}

bKeypads.Settings.KeyValues = {}
for category, members in pairs(bKeypads.Settings.Registry) do
	for _, setting in ipairs(members) do
		bKeypads.Settings.KeyValues[setting.key] = setting.default
		bKeypads.Settings.Metadata[setting.key] = setting
	end
end

function bKeypads.Settings:Get(key)
	return bKeypads.Settings.KeyValues[key]
end

function bKeypads.Settings:Set(key, val)
	if bKeypads.Settings.Metadata[key] and bKeypads.Settings.Metadata[key].type == "number" then
		bKeypads.Settings.KeyValues[key] = math.Round(val, bKeypads.Settings.Metadata[key].decimals or 0)
	else
		bKeypads.Settings.KeyValues[key] = val
	end
	bKeypads.Settings:Save()
end

function bKeypads.Settings:Save()
	file.Write("bkeypads/settings.json", util.TableToJSON(bKeypads.Settings.KeyValues))
end

function bKeypads.Settings:Load()
	if not file.Exists("bkeypads/settings.json", "DATA") then
		bKeypads.Settings:Save()
	else
		local saved = file.Read("bkeypads/settings.json", "DATA")
		if saved then
			saved = util.JSONToTable(saved)
			if saved then
				table.Merge(bKeypads.Settings.KeyValues, saved)
			end
		end
	end
end
bKeypads.Settings:Load()

do
	local FPSColor = Color(255,255,255)
	function FPSThink(self)
		self.FPSLerp = Lerp(0.05, self.FPSLerp or bKeypads.Performance.FPS, bKeypads.Performance.FPS)
		self:SetText("FPS: " .. math.Round(self.FPSLerp))

		local FPSFrac = bKeypads.Performance.FPSAverage / 120
		FPSColor.r = Lerp(FPSFrac, 255, 0)
		FPSColor.g = Lerp(FPSFrac, 0, 255)
		FPSColor.b = 0
		self:SetTextColor(FPSColor)
	end
	function OptimizingThink(self)
		self:SetText(bKeypads.L("Optimizing"):format(bKeypads.Performance:Optimizing() and bKeypads.L("Yes") or bKeypads.L("No")))
		self:SetTextColor(bKeypads.Performance:Optimizing() and bKeypads.COLOR.RED or bKeypads.COLOR.GREEN)
	end
	function FPSPaint(self, w, h)
		surface.SetDrawColor(0, 0, 0)
		surface.DrawRect(0, 0, w, h)

		self:SetTall(self.FPSLabel:GetTall() + self.OptimizingLabel:GetTall() + 10)
	end

	local function ResetSettings()
		surface.PlaySound("npc/roller/mine/rmine_predetonate.wav")

		bKeypads.STOOL.BlockSpawnmenuClose = true
		Derma_Query("#bKeypads_ResetSettingsAreYouSure", "#bKeypads_ResetSettings", "#bKeypads_Yes", function()

			bKeypads.STOOL.BlockSpawnmenuClose = false

			surface.PlaySound("npc/roller/remote_yes.wav")
			file.Delete("bkeypads/settings.json")

			bKeypads.Settings:Init()
			bKeypads.Settings:Load()

			RunConsoleCommand("spawnmenu_reload")

		end, "#bKeypads_No", function() bKeypads.STOOL.BlockSpawnmenuClose = false end)
	end

	local function recursive_delete(path)
		local fs, ds = file.Find(path .. "/*", "DATA")
		if fs then
			for _, f in ipairs(fs) do
				file.Delete(path .. "/" .. f)
			end
		end
		if ds then
			for _, d in ipairs(ds) do
				recursive_delete(path .. "/" .. d)
			end
		end
	end
	local function ResetAllData()
		surface.PlaySound("npc/roller/mine/rmine_predetonate.wav")

		bKeypads.STOOL.BlockSpawnmenuClose = true
		Derma_Query("#bKeypads_ResetAllDataAreYouSure", "#bKeypads_ResetAllData", "#bKeypads_Yes", function()

			bKeypads.STOOL.BlockSpawnmenuClose = false

			surface.PlaySound("npc/roller/remote_yes.wav")
			recursive_delete("bkeypads")

			bKeypads.Settings:Init()
			bKeypads.Settings:Load()

			-- Reset cvars
			local vdf = file.Read("cfg/client.vdf", "GAME")
			if vdf then
				for cvar in vdf:gmatch("\"(bkeypads_.-)\"") do
					local ConVar = GetConVar(cvar)
					if ConVar then
						ConVar:Revert()
					end
				end
			end

			include("autorun/_bkeypads_load.lua") -- spooky

			RunConsoleCommand("spawnmenu_reload")

		end, "#bKeypads_No", function() bKeypads.STOOL.BlockSpawnmenuClose = false end)
	end

	local function SettingPanelChanged(self, val)
		bKeypads.Settings:Set(self.key, val)
		if (self.settingOnChange) then self.settingOnChange(val) end
	end

	local function ComboBoxChanged(self, _, __, val)
		bKeypads.Settings:Set(self.key, val)
		if (self.settingOnChange) then self.settingOnChange(val) end
	end

	function bKeypads.Settings:BuildCPanel(CPanel)
		bKeypads.Settings.CPanel = CPanel
		CPanel.SettingPanels = {}

		bKeypads:InjectSmoothScroll(CPanel)
		bKeypads:STOOLMatrix(CPanel, false)

		local ResetButton = vgui.Create("DButton", CPanel)
		ResetButton:SetText("#bKeypads_Reset")
		ResetButton:SetIcon("icon16/arrow_refresh.png")
		ResetButton.DoClick = ResetSettings
		CPanel:AddItem(ResetButton)
		CPanel:InvalidateLayout()

		local ResetAllDataButton = vgui.Create("DButton", CPanel)
		ResetAllDataButton:SetText("#bKeypads_ResetAllData")
		ResetAllDataButton:SetIcon("icon16/error.png")
		ResetAllDataButton.DoClick = ResetAllData
		CPanel:AddItem(ResetAllDataButton)
		CPanel:InvalidateLayout()

		timer.Simple(0, function()
			for category, members in pairs(bKeypads.Settings.Registry) do
				local categoryPanel = vgui.Create("DForm", CPanel)
				categoryPanel:SetLabel(category)
				categoryPanel:SetExpanded(true)

				for _, setting in ipairs(members) do
					if setting.prePanel then setting.prePanel(categoryPanel) end

					local settingLabel, settingPanel

					if setting.type == "boolean" then

						local CheckBox = vgui.Create("DCheckBoxLabel", categoryPanel)
						settingPanel = CheckBox

						CheckBox:SetText(setting.name)
						CheckBox:SetChecked(bKeypads.Settings:Get(setting.key))

						CheckBox.OnChange = SettingPanelChanged

					elseif setting.type == "number" then

						setting.decimals = setting.decimals or (setting.default % 1 > 0 and #tostring(setting.default % 1) - 2) or 0

						local NumSlider = vgui.Create("DNumSlider", categoryPanel)
						settingPanel = NumSlider

						NumSlider:SetText(setting.name)
						NumSlider:SetDefaultValue(setting.default)
						if setting.min then NumSlider:SetMin(setting.min) end
						if setting.max then NumSlider:SetMax(setting.max) end
						NumSlider:SetDecimals(setting.decimals)
						NumSlider:SetValue(bKeypads.Settings:Get(setting.key))

						NumSlider.OnValueChanged = SettingPanelChanged

					elseif setting.type == "combo" then

						settingLabel = vgui.Create("DLabel", categoryPanel)
						settingLabel:SetText(setting.name)

						local ComboBox = vgui.Create("DComboBox", categoryPanel)
						settingPanel = ComboBox

						ComboBox:SetMinimumSize(nil, 25)

						local selected = bKeypads.Settings:Get(setting.key)
						for key, choice in pairs(setting.choices) do
							ComboBox:AddChoice(choice.name, key, selected == key, choice.icon)
						end

						ComboBox.OnSelect = ComboBoxChanged

					end

					if settingPanel.SetDark then settingPanel:SetDark(true) end
					settingPanel.key = setting.key
					settingPanel.settingOnChange = setting.onChange

					if IsValid(settingLabel) then
						settingLabel:SetDark(true)
						settingPanel:Dock(FILL)
						categoryPanel:AddItem(settingLabel, settingPanel)

						settingLabel:SetTall(25)
					else
						categoryPanel:AddItem(settingPanel)
					end
					local helpPanel
					if setting.tip then
						helpPanel = categoryPanel:Help(setting.tip)
						helpPanel:DockMargin(0, 0, 0, 0)
					end
					if setting.postPanel then setting.postPanel(categoryPanel, settingPanel, helpPanel) end

					CPanel.SettingPanels[setting.key] = settingPanel
				end

				CPanel:AddItem(categoryPanel)
			end

			local padding = vgui.Create("DPanel", CPanel)
			padding.Paint = nil
			padding:SetTall(10)
			CPanel:AddItem(padding)

			hook.Run("bKeypads.BuildCPanel", CPanel)
		end)
	end
end