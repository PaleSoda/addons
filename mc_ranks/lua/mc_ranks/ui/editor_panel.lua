-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║╚═╝║╚══╗──By MacTavish <3──────
-- ║║║║║║╔╗╔╩══╗║───────────────────────
-- ║║║║║║║║╚╣╚═╝║───────────────────────
-- ╚╝╚╝╚╩╝╚═╩═══╝───────────────────────

local Ln = MSD.GetPhrase
local ranks_1 = Material("ranks_ui/rank_low.png", "smooth")
local ranks_2 = Material("ranks_ui/rank.png", "smooth")
local ranks_3 = Material("ranks_ui/rank_sup.png", "smooth")

local empty_group = {
	id = "New Group",
	job = {},
	icon = nil,
	urlicon = false,
	cansee = true,
	show_sn = false,
	ranks = {},
}

local empty_rank = {
	name = "New rank #",
	srt_name = "nrk",
	icon = "",
	can_promote = false,
	can_demote = false,
	autoprom = false,
	stats = {},
	models = {},
}

local active_group

local function FetchRanks(panel, k, v)
	panel:Close()
	http.Fetch("http://macnco.one/rankup/" .. v.link .. ".txt", function(body, size, headers, code)
		local tbl = util.JSONToTable(body)

		if tbl then
			if MRS.Ranks[tbl.id] then return end
			tbl.icon = "http://macnco.one/rankup/" .. v.link .. ".png"
			tbl.urlicon = true
			MRS.Ranks[tbl.id] = tbl

			MRS.RanksSubmit(MRS.Ranks[tbl.id])
		end
	end)
end

local function RanksListPanel(parent, k, v, openPage)
	local button = vgui.Create("DButton")
	button:SetText("")
	button.StaticScale = {
		w = 4,
		fixed_h = 120,
		minw = 200,
		minh = 120
	}
	button.alpha = 0
	button.color_idle = color_white

	local icon = v.icon or ranks_3
	local icons = v.icon and 64 or 48

	button.Paint = function(self, wd, hd)
		if self.hover and not self.disable then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		if v.urlicon and v.icon then
			icon = MSD.ImgLib.GetMaterial(v.icon)
		end

		draw.RoundedBox(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["d"])

		if self.alpha > 0.01 then
			draw.RoundedBox(MSD.Config.Rounded, 0, 0, self.alpha * (24 + icons), hd, MSD.Theme["d"])
			draw.DrawText(k, "MSDFont.26", 24 + icons, hd / 2 - 13, MSD.ColorAlpha(color or MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_LEFT)
		end

		MSD.DrawTexturedRect(12, hd / 2 - icons / 2, icons, icons, icon, color_white)

		draw.DrawText(k, "MSDFont.26", 24 + icons, hd / 2 - 13, MSD.ColorAlpha(self.color_idle, 255 - self.alpha * 255), TEXT_ALIGN_LEFT)

	end

	button.OnCursorEntered = function(self)
		self.hover = true
	end
	button.OnCursorExited = function(self)
		self.hover = false
	end

	button.DoClick = function(self)
		openPage("edit", true, true, k, v)
	end
	parent:AddItem(button)

	return button
end

function MRS.ButtonPresets(parent, pth, txt, func)

	local button = vgui.Create( "DButton" )
	button.StaticScale = {
		w = 3,
		fixed_h = 120,
		minw = 120,
		minh = 120
	}
	button:SetText( "" )
	button.alpha = 0
	button.font = "MSDFont.26"
	button.Paint = function( self, w, h )

		local icon = MSD.ImgLib.GetMaterial("http://macnco.one/rankup/" .. pth .. ".png")

		if self.hover or self.hovered then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["d"])
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, w * self.alpha, h, MSD.Theme["d"])

		MSD.DrawTexturedRect(w / 2 - h / 4, h / 4, h / 2, h / 2, icon, color_white)

		local wd = draw.SimpleText(txt, self.font, w / 2, h - h / 4, color_white, TEXT_ALIGN_CENTER)
		if wd > w then
			self.font = "MSDFont.18"
		end
		return true

	end
	button.DoClick = func
	button.DoRightClick = func
	button.OnCursorEntered = function( self ) self.hover = true end
	button.OnCursorExited = function( self ) self.hover = false end
	parent:AddItem(button)

	return button
end

function MRS.OpenAdminMenu(panel, mainPanel)
	if not panel then return end
	MRS.SetupMenu = panel
	MRS.SetupMenu.mainPanel = mainPanel

	function mainPanel.ModuleSwitch()
		MRS.SetupMenu = nil
		MRS.UpdateMenuElements = nil
	end

	panel.Canvas = vgui.Create("MSDPanelList", panel)
	panel.Canvas:SetSize(panel:GetWide() - 252, panel:GetTall())
	panel.Canvas:SetPos(252, 0)
	panel.Canvas:EnableVerticalScrollbar()
	panel.Canvas:EnableHorizontal(true)
	panel.Canvas:SetSpacing(2)
	panel.Canvas.IgnoreVbar = true
	panel.Canvas.Paint = function() end
	local pages = {}
	local cur_page = nil

	local function openPage(id, animate, ...)
		panel.Canvas:Clear()
		back_page = cur_page
		pages[id](...)
		cur_page = id

		if animate then
			panel.Canvas:SetAlpha(1)
			panel.Canvas:AlphaTo(255, 0.2)
		end
	end

	local buttons = {}

	buttons[1] = {
		Ln("rank_edit"), ranks_2, function()
			openPage("ranks", true)
		end,
		true
	}

	buttons[2] = {
		Ln("user_data"), MSD.Icons48.account_edit, function()
			openPage("user_data", true)
		end
	}

	buttons[3] = {
		Ln("settings"), MSD.Icons48.cog, function()
			openPage("settings", true)
		end
	}

	function MRS.SetupMenu.OnRanksUpdate()
		if cur_page == "ranks" then
			openPage("ranks")
		end
	end

	panel.Menu = vgui.Create("MSDPanelList", panel)
	panel.Menu:SetSize(250, panel:GetTall())
	panel.Menu:SetPos(0, 0)
	panel.Menu:EnableVerticalScrollbar()
	panel.Menu:EnableHorizontal(false)
	panel.Menu:SetSpacing(0)
	panel.Menu.IgnoreVbar = true

	panel.Menu.Paint = function(self, w, h)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["l"])
	end

	panel.Menu.Deselect = function(but)
		if not but then return end
		but.hovered = true

		for k, v in pairs(panel.Menu:GetItems()) do
			if v and v:IsValid() and v ~= but then
				v.hovered = false
			end
		end
	end

	local function PopupMenu(text, x, y, w, dwd)
		local pl, child = MSD.WorkSpacePanel(mainPanel, text, x, y, false)
		local sub_list = vgui.Create("MSDPanelList", child)
		sub_list:SetSize(dwd and child:GetWide() / dwd or child:GetWide() - 10, child:GetTall() - w)
		sub_list:SetPos(5, w)
		sub_list:EnableVerticalScrollbar()
		sub_list:EnableHorizontal(true)
		sub_list:SetSpacing(2)
		sub_list.IgnoreVbar = true

		return sub_list, child, pl
	end

	pages["ranks"] = function()
		MSD.Header(panel.Canvas, Ln("group_list"), function()
			openPage("search")
		end, MSD.Icons48.search)

		MSD.BigButton(panel.Canvas, "static", nil, 4, 120, Ln("group_addnew"), MSD.Icons48.layers_plus, function()
			local sub_list, _, plm = PopupMenu(Ln("group_addnew"), 2, 2, 50)

			MSD.BigButton(sub_list, "static", nil, 3, 120, Ln("blank"), MSD.Icons48.file_document, function()
				MRS.Ranks["New Group"] = table.Copy(empty_group)
				MRS.RanksSubmit(MRS.Ranks["New Group"])
				plm:Close()
			end)

			http.Post("http://macnco.one/gmod/rankup/test.php", {
				v = MRS.Version,
				id = MRS.MainUserID
			}, function(result)
				if not result or not IsValid(sub_list) then return end

				local tbl = util.JSONToTable(result)

				for k, v in pairs(tbl) do
					MRS.ButtonPresets(sub_list, v.link, v.name, function()
						FetchRanks(plm, k, v)
					end)
				end
			end)
		end)

		for k, v in pairs(MRS.Ranks) do
			RanksListPanel(panel.Canvas, k, v, openPage)
		end
	end

	pages["search"] = function()
		local obj_sets

		MSD.Header(panel.Canvas, Ln("search"), function()
			openPage("ranks")
		end)

		MSD.TextEntry(panel.Canvas, "static", nil, 1, 50, Ln("enter_group"), Ln("search") .. ":", "", function(self, value)
			obj_sets.Update(value)
		end, true)

		obj_sets = vgui.Create("MSDPanelList")
		obj_sets:SetSize(panel.Canvas:GetWide(), panel.Canvas:GetTall() - 110)
		obj_sets:EnableVerticalScrollbar()
		obj_sets:EnableHorizontal(true)
		obj_sets:SetSpacing(2)
		obj_sets:SetPadding(0)
		obj_sets.IgnoreVbar = true
		obj_sets.Update = function(value)
			obj_sets:Clear()
			for k, v in pairs(MRS.Ranks) do
				if not value then continue end
				if not string.find(string.lower(k), string.lower(value), 1, true) and not string.find(string.lower(k), string.lower(value), 1, true) then continue end
				RanksListPanel(obj_sets, k, v, openPage)
			end
		end
		obj_sets.Update("")
		panel.Canvas:AddItem(obj_sets)
	end

	pages["edit"] = function(open, id, group)
		if open then
			active_group = group
			active_group.id = id
		end
		MSD.Header(panel.Canvas, active_group.id, function()
			openPage("ranks", true)
		end)

		MSD.BigButton(panel.Canvas, "static", nil, 2, 180, Ln("main_opt"), MSD.Icons48.playlist_edit, function()
			openPage("edit_page1", true)
		end)

		MSD.BigButton(panel.Canvas, "static", nil, 2, 180, Ln("rank_edit"), ranks_2, function()
			openPage("edit_page2", true)
		end)

		MSD.BigButton(panel.Canvas, "static", nil, 3, 100, Ln("save_chng"), MSD.Icons48.save, function()
			openPage("ranks", true)
			MRS.RanksSubmit(active_group)
		end)

		MSD.BigButton(panel.Canvas, "static", nil, 3, 100, Ln("copy_data"), MSD.Icons48.copy, function(self)
			if (IsValid(self.Menu)) then
				self.Menu:Remove()
				self.Menu = nil
			end

			self.Menu = MSD.MenuOpen(false, self)

			for k, v in pairs(MRS.Ranks) do
				if k == id then continue end
				self.Menu:AddOption(k, function()
					local pl, _, plm = PopupMenu(Ln("confirm_action"), 3, 5, 55)

					MSD.Button(pl, "static", nil, 1, 50, Ln("copy_data"), function()
						active_group = table.Copy(v)
						active_group.job = {}
						active_group.id = id
						plm.Close()
					end)

					MSD.Button(pl, "static", nil, 1, 50, Ln("cancel"), function()
						plm.Close()
					end)
				end)
			end

			local x, y = self:LocalToScreen(0, self:GetTall())
			self.Menu:SetMinimumWidth(self:GetWide())
			self.Menu:Open(x, y, false, self)
		end)

		MSD.BigButton(panel.Canvas, "static", nil, 3, 100, Ln("remove"), MSD.Icons48.layers_remove, function()
			local pl, _, plm = PopupMenu(Ln("confirm_action"), 3, 5, 55)

			MSD.Button(pl, "static", nil, 1, 50, Ln("remove"), function()
				openPage("ranks", true)
				net.Start("MRS.RanksRemove")
				net.WriteString(active_group.id)
				net.SendToServer()
				plm.Close()
			end)

			MSD.Button(pl, "static", nil, 1, 50, Ln("cancel"), function()
				plm.Close()
			end)
		end)

		-- MSD.BigButton(panel.Canvas, "static", nil, 3, 100, Ln("save_preset"), MSD.Icons48.save, function()
		-- 	openPage("ranks", true)
		-- 	MRS.RanksSubmit(active_group)
		-- end)
	end

	pages["edit_page1"] = function()
		MSD.Header(panel.Canvas, Ln("main_opt"), function()
			openPage("edit", true)
		end)
		local ops_panel = vgui.Create("DPanel")
		ops_panel:SetSize(panel.Canvas:GetWide(), panel.Canvas:GetTall() - 55)

		ops_panel.Paint = function(self, w, h)
			draw.RoundedBox(MSD.Config.Rounded, 0, 0, w / 2 - 2, h, MSD.Theme["l"])
			draw.RoundedBox(MSD.Config.Rounded, w / 2, 0, w / 2 - 2, h, MSD.Theme["l"])
		end

		local list_right, list_left
		list_left = vgui.Create("MSDPanelList", ops_panel)
		list_left:SetSize(ops_panel:GetWide() / 2, ops_panel:GetTall() - 2)
		list_left:SetPos(0, 0)
		list_left:EnableVerticalScrollbar()
		list_left:EnableHorizontal(true)
		list_left:SetSpacing(2)
		list_left:SetPadding(0)
		list_left.IgnoreVbar = true

		list_right = vgui.Create("MSDPanelList", ops_panel)
		list_right:SetSize(ops_panel:GetWide() / 2 - 2, ops_panel:GetTall() - 2)
		list_right:SetPos(ops_panel:GetWide() / 2, 0)
		list_right:EnableVerticalScrollbar()
		list_right:EnableHorizontal(true)
		list_right:SetSpacing(2)
		list_right:SetPadding(0)
		list_right.IgnoreVbar = true

		if not active_group.oldid then
			active_group.oldid = active_group.id
		end

		-- Settings

		MSD.TextEntry(list_left, "static", nil, 1, 50, Ln("enter_id"), "ID:", active_group.id, function(self, value)
			if not MRS.CheckID(value) then
				self.error = Ln("inv_quest") .. " ID"
				return
			end

			if MRS.Ranks[value] and active_group.oldid ~= value then
				self.error = Ln("q_id_unique")
				return
			end

			active_group.id = value
			self.error = nil
		end, true)

		MSD.DTextSlider(list_left, "static", nil, 1, 50, Ln("mrs_show_all"), Ln("mrs_show_team"), active_group.cansee, function(self, value)
			active_group.cansee = value
		end)

		MSD.BoolSlider(list_left, "static", nil, 1, 50, Ln("mrs_use_sn"), active_group.show_sn, function(self, value)
			active_group.show_sn = value
		end)

		MSD.TextEntry(list_left, "static", nil, 1, 50, Ln("q_icon68"), Ln("e_url"), active_group.icon, function(self, val)
			if val ~= "" then
				active_group.icon = val
			end
		end, true)

		MSD.BoolSlider(list_left, "static", nil, 1, 50, Ln("use_url"), active_group.urlicon, function(self, value)
			active_group.urlicon = value
		end)

		local iconp = vgui.Create("DPanel")
		iconp.StaticScale = {
			w = 1,
			fixed_h = 120,
			minw = 200,
			minh = 120
		}
		iconp.Paint = function(self, w, h)
			draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["l"])
			if not active_group.icon or active_group.icon == "" then return end
			local icon = active_group.icon
			if active_group.urlicon then
				icon = MSD.ImgLib.GetMaterial(active_group.icon)
			end
			MSD.DrawTexturedRect(w / 2 - 32, h / 4, 64, 64, icon, color_white)
		end

		list_left:AddItem(iconp)

		MSD.Button(list_left, "static", nil, 1, 50, Ln("s_team_whitelist"), function()
			local sub_list = PopupMenu(Ln("s_team_whitelist"), 2, 1.1, 50)

			MSD.InfoText(sub_list, Ln("mrs_whilelist"))

			for name, selected in pairs(active_group.job) do
				local combo = MSD.ComboBox(sub_list, "static", nil, 2, 50, name .. ":", Ln("none"))
				combo:AddChoice(Ln("none"), true)
				combo.OnSelect = function(self, index, text, data)
					active_group.job[name] = data
				end
				for k, v in pairs(active_group.ranks) do
					if tonumber(selected) and selected == k then
						combo:SetValue(v.name)
					end
					combo:AddChoice(v.name, k)
				end
			end
		end)

		-- Job list
		for id, tm in SortedPairsByMemberValue(team.GetAllTeams(), "Name", true) do
			if not tm.Joinable then continue end

			local sld = MSD.BoolSlider(list_right, "static", nil, 1, 50, tm.Name, active_group.job[tm.Name], function(self, var)
				active_group.job[tm.Name] = var or nil
			end)

			for k, grp in pairs(MRS.Ranks) do
				if k == active_group.id then continue end

				if grp.job[tm.Name] then
					sld.disabled = true
				end
			end
		end

		panel.Canvas:AddItem(ops_panel)
	end

	pages["edit_page2"] = function(open_rank)
		MSD.Header(panel.Canvas, Ln("rank_edit"), function()
			openPage("edit", true)
		end)
		local ops_panel = vgui.Create("DPanel")
		ops_panel:SetSize(panel.Canvas:GetWide(), panel.Canvas:GetTall() - 55)

		ops_panel.Paint = function(self, w, h)
			draw.RoundedBox(MSD.Config.Rounded, 0, 0, w / 2 - 2, h, MSD.Theme["l"])
			draw.RoundedBox(MSD.Config.Rounded, w / 2, 0, w / 2 - 2, h, MSD.Theme["l"])
		end

		local list_right, list_left
		list_left = vgui.Create("MSDPanelList", ops_panel)
		list_left:SetSize(ops_panel:GetWide() / 2, ops_panel:GetTall() - 2)
		list_left:SetPos(0, 0)
		list_left:EnableVerticalScrollbar()
		list_left:EnableHorizontal(true)
		list_left:SetSpacing(2)
		list_left:SetPadding(0)
		list_left.IgnoreVbar = false

		list_right = vgui.Create("MSDPanelList", ops_panel)
		list_right:SetSize(ops_panel:GetWide() / 2 - 2, ops_panel:GetTall() - 2)
		list_right:SetPos(ops_panel:GetWide() / 2, 0)
		list_right:EnableVerticalScrollbar()
		list_right:EnableHorizontal(true)
		list_right:SetSpacing(2)
		list_right:SetPadding(0)
		list_right.IgnoreVbar = true

		list_left.Populate = function()
			list_left:Clear()
			MSD.ButtonIcon(list_left, "static", nil, 1, 50, Ln("create_new"), MSD.Icons48.plus, function()
				local nid = table.insert(active_group.ranks, table.Copy(empty_rank))
				active_group.ranks[nid].name = "New rank #" .. nid
				list_left.Populate()
			end)

			for k,v in SortedPairs(active_group.ranks, true) do
				local rankicon = ranks_2

				if k == 1 then rankicon = ranks_1 end
				if k == #active_group.ranks or v.can_promote or v.can_demote then rankicon = ranks_3 end

				if v.icon and v.icon ~= "" then
					if string.StartWith(v.icon, "http") then
						rankicon = MSD.ImgLib.GetMaterial(v.icon)
					else
						rankicon = v.icon
					end
				end

				if open_rank and k == open_rank then list_right.Populate(k, v) end

				MSD.ButtonIcon(list_left, "static", nil, 1, 50, v.name, rankicon, function()
					list_right.Populate(k, v)
				end, nil, nil, color_white)
			end
		end

		list_right.Populate = function(id, rank)
			list_right:Clear()

			MSD.TextEntry(list_right, "static", nil, 1, 50, Ln("enter_name"), Ln("name") .. ":", rank.name, function(self, value)
				rank.name = value
			end, true)

			MSD.TextEntry(list_right, "static", nil, 1, 50, Ln("enter_srt_name"), Ln("srt_name") .. ":", rank.srt_name, function(self, value)
				rank.srt_name = value
			end, true)

			MSD.TextEntry(list_right, "static", nil, 1, 50, Ln("enter_path_or_url"), Ln("enter_path_or_url") .. ":", rank.icon, function(self, value)
				rank.icon = value
			end, true)

			MSD.BoolSlider(list_right, "static", nil, 1, 50, Ln("rank_hide"), rank.hidden, function(self, value)
				rank.hidden = value
			end)

			if rank.can_promote or rank.can_demote then
				MSD.InfoText(list_right, Ln("mrs_prom_demote"), 1)
			end

			local combo
			MSD.BoolSlider(list_right, "static", nil, 1, 50, Ln("can_promote"), rank.can_promote, function(self, value)
				rank.can_promote = value
				combo.disabled = not value
				list_left.Populate()
			end)

			combo = MSD.ComboBox(list_right, "static", nil, 1, 50, Ln("promote_limit"), Ln("none"))
			combo:AddChoice(Ln("none"), nil)
			combo.OnSelect = function(self, index, text, data)
				rank.promote_limit = data
			end
			for k, v in SortedPairs(active_group.ranks) do
				if id <= k then continue end
				if rank.promote_limit == k then
					combo:SetValue(v.name)
				end
				combo:AddChoice(v.name, k)
			end

			combo.disabled = not rank.can_promote

			local combo2
			MSD.BoolSlider(list_right, "static", nil, 1, 50, Ln("can_demote"), rank.can_demote, function(self, value)
				rank.can_demote = value
				combo2.disabled = not value
				list_left.Populate()
			end)

			combo2 = MSD.ComboBox(list_right, "static", nil, 1, 50, Ln("demote_limit"), Ln("none"))
			combo2:AddChoice(Ln("none"), nil)
			combo2.OnSelect = function(self, index, text, data)
				rank.demote_limit = data
			end
			for k, v in SortedPairs(active_group.ranks) do
				if id <= k then continue end
				if rank.demote_limit == k then
					combo2:SetValue(v.name)
				end
				combo2:AddChoice(v.name, k)
			end

			combo2.disabled = not rank.can_demote

			MSD.ButtonIcon(list_right, "static", nil, 1, 50, Ln("edit_player_model"), MSD.Icons48.account_edit, function()
				openPage("edit_models", true, id, rank)
			end)

			MSD.ButtonIcon(list_right, "static", nil, 1, 50, Ln("edit_custom_stats"), MSD.Icons48.account_plus, function()
				list_right.PopulateStats(id, rank)
			end)

			local combo3 = MSD.ComboBox(list_right, "static", nil, 1, 50, Ln("force_team"), Ln("none"))
			combo3:AddChoice(Ln("none"), nil)
			combo3.OnSelect = function(self, index, text, data)
				rank.force_team = data
			end
			for k, v in pairs(team.GetAllTeams()) do
				if not active_group.job[v.Name] then continue end
				if rank.force_team == k then
					combo3:SetValue(v.Name)
				end
				combo3:AddChoice(v.Name, k)
			end

			if id ~= #active_group.ranks then
				MSD.TextEntry(list_right, "static", nil, 1, 50, Ln("e_blank_dis"), Ln("autoprom") .. " (" .. Ln("in_min") .. "):", rank.autoprom, function(self, value)
					rank.autoprom = tonumber(value) or nil
				end, true, nil, nil, true)

				MSD.ButtonIcon(list_right, "static", nil, id == 1 and 1 or 2, 50, Ln("moveup"), MSD.Icons48.arrow_up, function()
					local new_object = table.Copy(active_group.ranks[id + 1])
					active_group.ranks[id + 1] = rank
					active_group.ranks[id] = new_object
					list_right.Populate(id + 1, active_group.ranks[id + 1])
					list_left.Populate()
				end)
			end

			if id ~= 1 then
				MSD.ButtonIcon(list_right, "static", nil, id == #active_group.ranks and 1 or 2, 50, Ln("movedown"), MSD.Icons48.arrow_down, function()
					local new_object = table.Copy(active_group.ranks[id - 1])
					active_group.ranks[id - 1] = rank
					active_group.ranks[id] = new_object
					list_right.Populate(id - 1, active_group.ranks[id - 1])
					list_left.Populate()
				end)
			end

			MSD.ButtonIcon(list_right, "static", nil, 2, 50, Ln("remove"), MSD.Icons48.cross, function()
				table.remove(active_group.ranks, id)
				list_right:Clear()
				list_left.Populate()
			end)

			local function CopyRankData(new_data)
				local pl, _, plm = PopupMenu(Ln("load_autosave"), 3, 5, 55)

				MSD.Button(pl, "static", nil, 1, 50, Ln("copy_all_data"), function()
					active_group.ranks[id] = new_data
					list_right.Populate(id, active_group.ranks[id])
					list_left.Populate()
					plm.Close()
					return
				end)

				MSD.Button(pl, "static", nil, 1, 50, Ln("copy_only_stats"), function()
					active_group.ranks[id].stats = new_data.stats
					active_group.ranks[id].models = new_data.models
					list_right.Populate(id, active_group.ranks[id])
					list_left.Populate()
					plm.Close()
				end)
			end

			MSD.ButtonIcon(list_right, "static", nil, 2, 50, Ln("copy_data"), MSD.Icons48.copy, function(self)
				if (IsValid(self.Menu)) then
					self.Menu:Remove()
					self.Menu = nil
				end

				self.Menu = MSD.MenuOpen(false, self)

				for k, v in pairs(active_group.ranks) do
					if k == id then continue end
					self.Menu:AddOption("[" .. v.srt_name .. "] " .. v.name, function()
						CopyRankData(table.Copy(v))
					end)
				end

				local x, y = self:LocalToScreen(0, self:GetTall())
				self.Menu:SetMinimumWidth(self:GetWide())
				self.Menu:Open(x, y, false, self)
			end)
		end

		list_right.PopulateStats = function(id, rank)
			list_right:Clear()

			MSD.Header(list_right, Ln("edit_custom_stats"), function()
				list_right.Populate(id, rank)
			end)

			local limited_stats = {}

			for k, stat in pairs(rank.stats) do
				local main_t = MRS.PlayerStats[stat.id]

				if not main_t then continue end
				if main_t.check and main_t.check() then continue end
				MSD.ButtonIcon(list_right, "static", nil, 1, 50, stat.id, main_t.icon, function(self)
					local rwd_list = PopupMenu(Ln("edit_custom_stats"), 2, main_t.uisize or 1.5, 50)
					main_t.buildUI(rwd_list, stat.data)
				end, function(self)
					if (IsValid(self.Menu)) then
						self.Menu:Remove()
						self.Menu = nil
					end
					self.Menu = MSD.MenuOpen(false, self)
					self.Menu:AddOption(Ln("remove"), function()
						table.remove(rank.stats, k)
						list_right.PopulateStats(id, rank)
					end)
					local x, y = self:LocalToScreen(0, self:GetTall())
					self.Menu:SetMinimumWidth(self:GetWide())
					self.Menu:Open(x, y, false, self)
				end)

				if main_t.limited then
					limited_stats[stat.id] = true
				end
			end

			MSD.ButtonIcon(list_right, "static", nil, 1, 50, Ln("create_new"), MSD.Icons48.plus, function(self)
				if (IsValid(self.Menu)) then
					self.Menu:Remove()
					self.Menu = nil
				end

				self.Menu = MSD.MenuOpen(false, self)

				for name, stat in pairs(MRS.PlayerStats) do
					if limited_stats[name] then continue end
					self.Menu:AddOption(name, function()
						table.insert(rank.stats, {
							id = name,
							data = table.Copy(stat.data)
						})
						list_right.PopulateStats(id, rank)
					end)
				end

				local x, y = self:LocalToScreen(0, self:GetTall())
				self.Menu:SetMinimumWidth(self:GetWide())
				self.Menu:Open(x, y, false, self)
			end)
		end

		list_left.Populate()

		panel.Canvas:AddItem(ops_panel)
	end

	pages["edit_models"] = function(rank_id, rank)

		if not rank.models then rank.models = {} end
		if rank.custom_mdl and rank.custom_mdl.model ~= "" then table.insert(rank.models, rank.custom_mdl) rank.custom_mdl = nil end

		MSD.Header(panel.Canvas, Ln("edit_player_model") .. " | " .. rank.name, function()
			openPage("edit_page2", true, rank_id)
		end)

		local ops_panel = vgui.Create("DPanel")
		ops_panel:SetSize(panel.Canvas:GetWide(), panel.Canvas:GetTall() - 55)

		ops_panel.Paint = function(self, w, h)
			draw.RoundedBox(MSD.Config.Rounded, 0, 0, w / 2 - 2, h, MSD.Theme["l"])
			draw.RoundedBox(MSD.Config.Rounded, w / 2, 0, w / 2 - 2, h, MSD.Theme["l"])
		end

		local list_right, list_left
		list_left = vgui.Create("MSDPanelList", ops_panel)
		list_left:SetSize(ops_panel:GetWide() / 2, ops_panel:GetTall() - 2)
		list_left:SetPos(0, 0)
		list_left:EnableVerticalScrollbar()
		list_left:EnableHorizontal(true)
		list_left:SetSpacing(2)
		list_left:SetPadding(0)
		list_left.IgnoreVbar = true

		list_right = vgui.Create("MSDPanelList", ops_panel)
		list_right:SetSize(ops_panel:GetWide() / 2 - 2, ops_panel:GetTall() - 2)
		list_right:SetPos(ops_panel:GetWide() / 2, 0)
		list_right:EnableVerticalScrollbar()
		list_right:EnableHorizontal(true)
		list_right:SetSpacing(2)
		list_right:SetPadding(0)
		list_right.IgnoreVbar = true

		list_left.Populate = function()
			list_left:Clear()
			MSD.ButtonIcon(list_left, "static", nil, 1, 50, Ln("create_new"), MSD.Icons48.plus, function()
				table.insert(rank.models, {
					model = "models/player/group01/male_07.mdl",
					skin = 0,
				 	bgrs = {}
				})
				list_left.Populate()
			end)

			for k,v in ipairs(rank.models, true) do
				MSD.ButtonIcon(list_left, "static", nil, 1, 50, Ln("model") .. " #" .. k, MSD.Icons48.account, function()
					list_right.Populate(k,v)
				end, function(self)
					if (IsValid(self.Menu)) then
						self.Menu:Remove()
						self.Menu = nil
					end
					self.Menu = MSD.MenuOpen(false, self)
					self.Menu:AddOption(Ln("remove"), function()
						table.remove(rank.models, k)
						list_left.Populate()
						list_right:Clear()
					end)
					local x, y = self:LocalToScreen(0, self:GetTall())
					self.Menu:SetMinimumWidth(self:GetWide())
					self.Menu:Open(x, y, false, self)
				end)
			end
		end

		list_right.Populate = function(id, data)
			list_right:Clear()

			MSD.TextEntry(list_right, "static", nil, 1, 50, Ln("e_model"), Ln("model") .. ":", data.model, function(self, value)
				data.model = value
				list_right.Populate(id, data)
			end, false)

			MSD.InfoHeader(list_right, "Press Enter to apply model change")

			local skin_list = vgui.Create("MSDPanelList")
			skin_list.StaticScale = {w = 2, fixed_h = 700, minw = 150, minh = 700}
			skin_list:EnableVerticalScrollbar()
			skin_list:EnableHorizontal(true)
			skin_list:SetSpacing(2)
			skin_list:SetPadding(0)
			list_right:AddItem(skin_list)

			local mdlp = MSD.NPCModelFrame(list_right, "static", nil, 2, 700, data.model, "menu_combine")
			for k,v in pairs(data.bgrs) do
				mdlp.Entity:SetBodygroup(k, v)
			end
			mdlp.Entity:SetSkin(data.skin)

			local nskins = mdlp.Entity:SkinCount() - 1

			if (nskins > 0) then
				MSD.NumberWang(skin_list, "static", nil, 1, 50, 0, nskins, data.skin or 1, "Skin", function(self)
					mdlp.Entity:SetSkin(self:GetValue())
					data.skin = self:GetValue()
				end)
			end

			for k = 0, mdlp.Entity:GetNumBodyGroups() - 1 do
				if (mdlp.Entity:GetBodygroupCount(k) <= 1) then continue end

				MSD.NumberWang(skin_list, "static", nil, 2, 50, 0, mdlp.Entity:GetBodygroupCount(k) - 1, data.bgrs[k] or 0, mdlp.Entity:GetBodygroupName(k), function(self)
					mdlp.Entity:SetBodygroup(k, self:GetValue())
					data.bgrs[k] = self:GetValue()
				end)
			end
		end

		list_left.Populate()

		panel.Canvas:AddItem(ops_panel)
	end

	pages["user_data"] = function()
		MSD.Header(panel.Canvas, Ln("user_data"))
		local sel_ply, list_right, list_left
		local ops_panel = vgui.Create("DPanel")
		ops_panel:SetSize(panel.Canvas:GetWide(), panel.Canvas:GetTall() - 55)

		ops_panel.Paint = function(self, w, h)
			draw.RoundedBox(MSD.Config.Rounded, 0, 0, w / 2 - 2, h, MSD.Theme["l"])
			draw.RoundedBox(MSD.Config.Rounded, w / 2, 0, w / 2 - 2, h, MSD.Theme["l"])

			if sel_ply and not IsValid(sel_ply) then
				sel_ply = nil
				list_left.Populate()
				list_right:Clear()
			end
		end

		MSD.TextEntry(ops_panel, 0, 0, ops_panel:GetWide() / 3 - 2, 50, "SteamID/Name", Ln("Search") .. ":", "", function(self, value)
			list_left.Populate(value)
		end, true)

		MSD.Button(ops_panel, ops_panel:GetWide() / 3, 0, ops_panel:GetWide() / 2 - ops_panel:GetWide() / 3 - 2, 50, Ln("offline_users"), function()
			local sub_list, _, plm = PopupMenu(Ln("group_addnew"), 2, 4, 50)

			MSD.TextEntry(sub_list, "static", nil, 1, 50, "STEAM_0:0:0000", Ln("find_player_id32"), "", function(self, value)
				net.Start("MRS.GetPlayersRanks")
					net.WriteString(value)
				net.SendToServer()
				plm:Close()
			end)
			if MRS.IsCharSystemOn() then
				MSD.InfoText(sub_list, "Your server has a character system enabled! Type a character ID after the steamid like this:\nSTEAM_0:0:00001 - 'STEAM_0:0:0000' is a player steamid and '1' is the character id")
			end
		end)

		list_left = vgui.Create("MSDPanelList", ops_panel)
		list_left:SetSize(ops_panel:GetWide() / 2, ops_panel:GetTall() - 54)
		list_left:SetPos(0, 52)
		list_left:EnableVerticalScrollbar()
		list_left:EnableHorizontal(true)
		list_left:SetSpacing(2)
		list_left:SetPadding(0)
		list_left.IgnoreVbar = true

		list_right = vgui.Create("MSDPanelList", ops_panel)
		list_right:SetSize(ops_panel:GetWide() / 2 - 2, ops_panel:GetTall() - 2)
		list_right:SetPos(ops_panel:GetWide() / 2, 0)
		list_right:EnableVerticalScrollbar()
		list_right:EnableHorizontal(true)
		list_right:SetSpacing(2)
		list_right:SetPadding(0)
		list_right.IgnoreVbar = true

		list_left.Populate = function(info)
			list_left:Clear()
			for _, p in ipairs(player.GetAll()) do
				if info then
					local found = false
					if string.find(string.lower(p:Name()), string.lower(info)) then
						found = true
					end

					if p.SteamName and string.find(string.lower(p:SteamName()), string.lower(info)) then
						found = true
					end

					if string.find(string.lower(p:SteamID()), string.lower(info)) then
						found = true
					end

					if not p:IsBot() and string.find(tostring(p:SteamID64()), info) then
						found = true
					end

					if tonumber(info) == p:UserID() then
						found = true
					end

					if not found then
						continue
					end
				end

				MSD.ButtonIcon(list_left, "static", nil, 1, 50, p:Name(), MSD.Icons48.account, function()
					list_right.Populate(p)
					sel_ply = p

					if IsValid(p) then
						net.Start("MRS.RequestStoredData")
							net.WriteUInt(p:UserID(), 32)
						net.SendToServer()
					end
				end)
			end
		end

		list_right.Populate = function(ply, group)
			list_right:Clear()
			if not IsValid(ply) then return end
			local back
			if group then back = function() list_right.Populate(ply) end end

			local hdr = MSD.Header(list_right, ply:Name() .. " | " .. (ply.SteamName and ply:SteamName() or ""), back)

			if not group then
				for k, v in pairs(MRS.Ranks) do
					local icon = v.icon or ranks_3
					if v.urlicon and v.icon then
						icon = MSD.ImgLib.GetMaterial(v.icon)
					end
					MSD.ButtonIcon(list_right, "static", nil, 1, 50, k, icon, function()
						list_right.Populate(ply, k)
					end, nil, nil, color_white)
				end
				return
			end

			local prank
			local grp = MRS.Ranks[group]

			hdr.Think = function()
				prank = MRS.GetPlyRank(ply, group)
			end

			for k,v in SortedPairs(grp.ranks, true) do
				local rankicon = ranks_2

				if k == 1 then rankicon = ranks_1 end
				if k == #grp.ranks or v.can_promote or v.can_demote then rankicon = ranks_3 end

				if v.icon and v.icon ~= "" then
					if string.StartWith(v.icon, "http") then
						rankicon = MSD.ImgLib.GetMaterial(v.icon)
					else
						rankicon = v.icon
					end
				end

				MSD.ButtonIcon(list_right, "static", nil, 1, 50, v.name, rankicon, function(self)
					if prank == k then return end
					RunConsoleCommand("mrs_setrank", ply:UserID(), group, k)
				end, nil, nil, color_white, function(self, w, h)
					if prank ~= k then return end
					draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["l"])
					draw.DrawText(Ln("active"), "MSDFont.22", w - 20, h / 2 - 11, MSD.Config.MainColor["p"], TEXT_ALIGN_RIGHT)
				end)

			end

		end

		list_left.Populate()

		panel.Canvas:AddItem(ops_panel)
	end

	pages["settings"] = function()
		local oldcfg = table.Copy(MRS.Config)
		MSD.Header(panel.Canvas, Ln("settings"))
		local ops_panel = vgui.Create("DPanel")
		ops_panel:SetSize(panel.Canvas:GetWide(), panel.Canvas:GetTall() - 135)

		ops_panel.Paint = function(self, w, h)
			draw.RoundedBox(MSD.Config.Rounded, 0, 0, w / 2 - 2, h, MSD.Theme["l"])
			draw.RoundedBox(MSD.Config.Rounded, w / 2, 0, w / 2 - 2, h, MSD.Theme["l"])
		end

		local list_right, list_left
		list_left = vgui.Create("MSDPanelList", ops_panel)
		list_left:SetSize(ops_panel:GetWide() / 2, ops_panel:GetTall() - 2)
		list_left:SetPos(0, 0)
		list_left:EnableVerticalScrollbar()
		list_left:EnableHorizontal(true)
		list_left:SetSpacing(2)
		list_left:SetPadding(0)
		list_left.IgnoreVbar = true

		list_left.Populate = function()
			list_left:Clear()

			MSD.Button(list_left, "static", nil, 1, 50, Ln("set_hud"), function()
				list_right.Populate("hud")
			end)

			MSD.Button(list_left, "static", nil, 1, 50, Ln("set_overhead"), function()
				list_right.Populate("ui_ply")
			end)

			MSD.Button(list_left, "static", nil, 1, 50, Ln("set_server"), function()
				list_right.Populate("server")
			end)
		end

		list_right = vgui.Create("MSDPanelList", ops_panel)
		list_right:SetSize(ops_panel:GetWide() / 2 - 2, ops_panel:GetTall() - 2)
		list_right:SetPos(ops_panel:GetWide() / 2, 0)
		list_right:EnableVerticalScrollbar()
		list_right:EnableHorizontal(true)
		list_right:SetSpacing(2)
		list_right:SetPadding(0)
		list_right.IgnoreVbar = true
		list_right.SetingList = {}

		list_right.Populate = function(seting)
			if not list_right.SetingList[seting] then return end
			MRS.PlayerDataPanel = nil
			list_right:Clear()
			list_right.SetingList[seting]()
			last_sm = seting
		end

		list_right.SetingList["hud"] = function()
			MSD.Header(list_right, Ln("set_hud_pos"))

			MSD.BoolSlider(list_right, "static", nil, 1, 50, Ln("enable"), MRS.Config.HUD.Show, function(self, value)
				MRS.Config.HUD.Show = value
			end)

			local acombo = MSD.ComboBox(list_right, "static", nil, 1, 50, "", "")

			local algm = {
				Ln("set_ui_align_left"),
				Ln("set_ui_align_center"),
				Ln("set_ui_align_right")
			}
			for i,t in pairs(algm) do
				acombo:AddChoice(t, i - 1)
				acombo:SetValue(t)
			end

			acombo.OnSelect = function(self, index, text, data)
				MRS.Config.HUD.AlignX = data
			end

			MSD.DTextSlider(list_right, "static", nil, 1, 50, Ln("set_ui_align_top"), Ln("set_ui_align_bottom"), MRS.Config.HUD.AlignY == 0 and true or false, function(self, value)
				MRS.Config.HUD.AlignY = value and 0 or 1
			end)

			local sld1, txt1, sld2, txt2
			sld1 = MSD.VolumeSlider(list_right, "static", nil, 1.2, 50, Ln("set_ui_offset_h"), MRS.Config.HUD.X, function(self, var)
				var = math.Round(var, 3)
				MRS.Config.HUD.X = var
				txt1:SetText(var * 100)
			end)

			txt1 = MSD.TextEntry(list_right, "static", nil, 6, 50, "", "", MRS.Config.HUD.X * 100, function(self, value)
				value = math.Clamp((tonumber(value) or 0) / 100,0,1)
				sld1.value = value
				MRS.Config.HUD.X = value
			end, true, nil, nil, true)

			sld2 = MSD.VolumeSlider(list_right, "static", nil, 1.2, 50, Ln("set_ui_offset_v"), MRS.Config.HUD.Y, function(self, var)
				var = math.Round(var, 3)
				MRS.Config.HUD.Y = var
				txt2:SetText(var * 100)
			end)

			txt2 = MSD.TextEntry(list_right, "static", nil, 6, 50, "", "", MRS.Config.HUD.Y * 100, function(self, value)
				value = math.Clamp((tonumber(value) or 0) / 100,0,1)
				sld2.value = value
				MRS.Config.HUD.Y = value
			end, true, nil, nil, true)

			local combo = MSD.ComboBox(list_right, "static", nil, 1, 50, Ln("set_hud_themes"), Ln("theme") .. " " .. MRS.Config.HUD.Theme + 1 )
			for i = 0,5 do
				combo:AddChoice(Ln("theme") .. " " .. i + 1, i)
			end

			combo.OnSelect = function(self, index, text, data)
				MRS.Config.HUD.Theme = data
			end

			MSD.BoolSlider(list_right, "static", nil, 1, 50, Ln("show_group"), MRS.Config.HUD.ShowGroup, function(self, value)
				MRS.Config.HUD.ShowGroup = value
			end)

			MSD.BoolSlider(list_right, "static", nil, 1, 50, Ln("hide_rank"), MRS.Config.HUD.HideName, function(self, value)
				MRS.Config.HUD.HideName = value
			end)

			MSD.BoolSlider(list_right, "static", nil, 1, 50, Ln("icon_right"), MRS.Config.HUD.IconRight, function(self, value)
				MRS.Config.HUD.IconRight = value
			end)

			MSD.VolumeSlider(list_right, "static", nil, 1, 50, Ln("icon_size"), (MRS.Config.HUD.IconSize - 24) / 40, function(self, var)
				var = math.Round(var, 3)
				MRS.Config.HUD.IconSize = math.Clamp(24 + math.Round(var * 40), 24, 64)
			end)

			MSD.VolumeSlider(list_right, "static", nil, 1, 50, Ln("font_size"), (MRS.Config.HUD.FontSize - 16) / 30, function(self, var)
				var = math.Round(var, 3)
				MRS.Config.HUD.FontSize = math.Clamp(16 + math.Round(var * 30), 16, 46)
			end)
		end

		list_right.SetingList["ui_ply"] = function()
			MSD.Header(list_right, Ln("set_overhead"))

			MSD.BoolSlider(list_right, "static", nil, 1, 50, Ln("enable"), MRS.Config.plyUI.Show, function(self, value)
				MRS.Config.plyUI.Show = value
			end)

			local acombo = MSD.ComboBox(list_right, "static", nil, 1, 50, "", "")

			local algm = {
				Ln("set_ui_align_left"),
				Ln("set_ui_align_center"),
				Ln("set_ui_align_right")
			}
			for i,t in pairs(algm) do
				acombo:AddChoice(t, i - 1)
				acombo:SetValue(t)
			end

			acombo.OnSelect = function(self, index, text, data)
				MRS.Config.plyUI.AlignX = data
			end

			local sld1, txt1, sld2, txt2
			sld1 = MSD.VolumeSlider(list_right, "static", nil, 1.2, 50, Ln("set_ui_offset_h"), MRS.Config.plyUI.X, function(self, var)
				var = math.Round(var, 3)
				MRS.Config.plyUI.X = var
				txt1:SetText(var * 100)
			end)

			txt1 = MSD.TextEntry(list_right, "static", nil, 6, 50, "", "", MRS.Config.plyUI.X * 100, function(self, value)
				value = math.Clamp((tonumber(value) or 0) / 100,0,1)
				sld1.value = value
				MRS.Config.plyUI.X = value
			end, true, nil, nil, true)

			sld2 = MSD.VolumeSlider(list_right, "static", nil, 1.2, 50, Ln("set_ui_offset_v"), MRS.Config.plyUI.Y, function(self, var)
				var = math.Round(var, 3)
				MRS.Config.plyUI.Y = var
				txt2:SetText(var * 100)
			end)

			txt2 = MSD.TextEntry(list_right, "static", nil, 6, 50, "", "", MRS.Config.plyUI.Y * 100, function(self, value)
				value = math.Clamp((tonumber(value) or 0) / 100,0,1)
				sld2.value = value
				MRS.Config.plyUI.Y = value
			end, true, nil, nil, true)

			local combo = MSD.ComboBox(list_right, "static", nil, 1, 50, Ln("set_hud_themes"), Ln("theme") .. " " .. MRS.Config.plyUI.Theme + 1 )
			for i = 0,4 do
				combo:AddChoice(Ln("theme") .. " " .. i + 1, i)
			end

			combo.OnSelect = function(self, index, text, data)
				MRS.Config.plyUI.Theme = data
			end

			MSD.BoolSlider(list_right, "static", nil, 1, 50, Ln("show_group"), MRS.Config.plyUI.ShowGroup, function(self, value)
				MRS.Config.plyUI.ShowGroup = value
			end)

			MSD.BoolSlider(list_right, "static", nil, 1, 50, Ln("hide_rank"), MRS.Config.plyUI.HideName, function(self, value)
				MRS.Config.plyUI.HideName = value
			end)

			MSD.BoolSlider(list_right, "static", nil, 1, 50, Ln("mrs_hud_follow"), MRS.Config.plyUI.Follow, function(self, value)
				MRS.Config.plyUI.Follow = value
			end)

			MSD.BoolSlider(list_right, "static", nil, 1, 50, Ln("mrs_hud_3d2d"), MRS.Config.Is2d3d, function(self, value)
				MRS.Config.Is2d3d = value
			end)

			MSD.BoolSlider(list_right, "static", nil, 1, 50, Ln("icon_right"), MRS.Config.plyUI.IconRight, function(self, value)
				MRS.Config.plyUI.IconRight = value
			end)

			MSD.VolumeSlider(list_right, "static", nil, 1, 50, Ln("icon_size"), (MRS.Config.plyUI.IconSize - 24) / 40, function(self, var)
				var = math.Round(var, 3)
				MRS.Config.plyUI.IconSize = math.Clamp(24 + math.Round(var * 40), 24, 64)
			end)

			MSD.VolumeSlider(list_right, "static", nil, 1, 50, Ln("font_size"), (MRS.Config.plyUI.FontSize - 16) / 30, function(self, var)
				var = math.Round(var, 3)
				MRS.Config.plyUI.FontSize = math.Clamp(16 + math.Round(var * 30), 16, 46)
			end)
		end

		list_right.SetingList["server"] = function()
			MSD.Header(list_right, Ln("set_server"))

			if not DarkRP then
				MSD.InfoText(list_right, "Warning! Your gamemode may not support these features.")
			end

			local sld
			MSD.BoolSlider(list_right, "static", nil, 1, 50, Ln("mrs_change_jobname"), MRS.Config.ChangeJobName, function(self, value)
				MRS.Config.ChangeJobName = value
				sld.disabled = not value
			end)

			sld = MSD.BoolSlider(list_right, "static", nil, 1, 50, Ln("mrs_set_prefix"), MRS.Config.SetAsPrefix, function(self, value)
				MRS.Config.SetAsPrefix = value
			end)

			sld.disabled = not MRS.Config.ChangeJobName

			local combo
			MSD.BoolSlider(list_right, "static", nil, 1, 50, Ln("mrs_change_plyname"), MRS.Config.ChangePlayerName, function(self, value)
				MRS.Config.ChangePlayerName = value
				combo.disabled = not value
			end)

			combo = MSD.ComboBox(list_right, "static", nil, 1, 50, Ln("format") .. ":", "")
			combo.OnSelect = function(self, index, text, data)
				MRS.Config.PlayerNameFormat = data
			end
			for k, v in pairs(MRS.NameFormats) do
				if MRS.Config.PlayerNameFormat == k then
					combo:SetValue(MRS.StringFormat(v, Ln("rank"), Ln("name") ))
				end
				combo:AddChoice(MRS.StringFormat(v, Ln("rank"), Ln("name") ), k)
			end

			combo.disabled = not MRS.Config.ChangePlayerName

			MSD.TextEntry(list_right, "static", nil, 1, 50, Ln("e_value"), Ln("mrs_chat_command") .. ":", MRS.Config.CommanOpen, function(self, value)
				if value == "" or value == " " then value = "/mrs" end
				MRS.Config.CommanOpen = value
			end, true)

			MSD.TextEntry(list_right, "static", nil, 1, 50, Ln("e_value"), Ln("mrs_promote_command") .. ":", MRS.Config.CommanPromote, function(self, value)
				if value == "" or value == " " then value = "/mrs" end
				MRS.Config.CommanPromote = value
			end, true)

			MSD.TextEntry(list_right, "static", nil, 1, 50, Ln("e_value"), Ln("mrs_demote_command") .. ":", MRS.Config.CommanDemote, function(self, value)
				if value == "" or value == " " then value = "/mrs" end
				MRS.Config.CommanDemote = value
			end, true)
		end

		panel.Canvas:AddItem(ops_panel)
		list_left.Populate()
		list_right.Populate(last_sm)

		-- if MRS.IsAdministrator(LocalPlayer()) then
			MSD.BigButton(panel.Canvas, "static", nil, 2, 80, Ln("upl_changes"), MSD.Icons48.save, function()
				MRS.SaveConfig()
				openPage("settings", true)
			end)

			MSD.BigButton(panel.Canvas, "static", nil, 2, 80, Ln("res_changes"), MSD.Icons48.cross, function()
				MRS.Config = oldcfg
				openPage("settings", true)
			end)
		--end
	end

	for k, v in pairs(buttons) do
		local button = MSD.MenuButton(panel.Menu, v[2], nil, nil, 250, 50, v[1], function(self)
			panel.Menu.Deselect(not v[5] and self or false)
			v[3]()
		end)

		if v[4] then
			panel.Menu.Deselect(button)
			v[3]()
		end
	end
end

local modulid = MSD.AddModule("MRS", MRS.OpenAdminMenu, ranks_3)

net.Receive("MRS.GetPlayersRanks", function()
	if not IsValid(MRS.SetupMenu) then return end
	local sid = net.ReadString()
	local len = net.ReadUInt(32)
	local data = {}
	for i = 1,len do
		local k = net.ReadString()
		local r = net.ReadUInt(32)
		local t = net.ReadUInt(32)
		data[k] = {rank = r, time = t}
	end

	local ply = player.GetBySteamID(sid)
	local pref = "Offline player"

	if IsValid(ply) then
		pref = ply:Name()
	end

	local _, child = MSD.WorkSpacePanel(MRS.SetupMenu.mainPanel, sid .. " | " .. pref, 1, 1.1, false)

	local list_right, list_left
	list_left = vgui.Create("MSDPanelList", child)
	list_left:SetSize(child:GetWide() / 2, child:GetTall() - 50)
	list_left:SetPos(0, 50)
	list_left:EnableVerticalScrollbar()
	list_left:EnableHorizontal(true)
	list_left:SetSpacing(2)
	list_left:SetPadding(0)
	list_left.IgnoreVbar = true

	for k, v in pairs(MRS.Ranks) do
		local icon = v.icon or ranks_3
		if v.urlicon and v.icon then
			icon = MSD.ImgLib.GetMaterial(v.icon)
		end
		MSD.ButtonIcon(list_left, "static", nil, 1, 50, k, icon, function()
			list_right.Populate(k, v)
		end, nil, nil, color_white)
	end

	list_right = vgui.Create("MSDPanelList", child)
	list_right:SetSize(child:GetWide() / 2 - 2, child:GetTall() - 50)
	list_right:SetPos(child:GetWide() / 2, 50)
	list_right:EnableVerticalScrollbar()
	list_right:EnableHorizontal(true)
	list_right:SetSpacing(2)
	list_right:SetPadding(0)
	list_right.IgnoreVbar = true

	list_right.Populate = function(group, grp)
		list_right:Clear()
		for k,v in SortedPairs(grp.ranks, true) do
			local rankicon = ranks_2

			if k == 1 then rankicon = ranks_1 end
			if k == #grp.ranks or v.can_promote or v.can_demote then rankicon = ranks_3 end

			if v.icon and v.icon ~= "" then
				if string.StartWith(v.icon, "http") then
					rankicon = MSD.ImgLib.GetMaterial(v.icon)
				else
					rankicon = v.icon
				end
			end

			MSD.ButtonIcon(list_right, "static", nil, 1, 50, v.name, rankicon, function(self)
				if IsValid(ply) then
					RunConsoleCommand("mrs_setrank", ply:UserID(), group, k)
				else
					net.Start("MRS.SavePlayerRankList")
						net.WriteString(sid)
						net.WriteString(group)
						net.WriteUInt(k, 32)
					net.SendToServer()
				end

				if data[group] then
					data[group].rank = k
				else
					data[group] = {rank = k, time = 0}
				end
			end, nil, nil, color_white, function(self, w, h)
				if not data[group] or data[group].rank ~= k then return end
				draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["l"])
				draw.DrawText(Ln("active"), "MSDFont.22", w - 20, h / 2 - 11, MSD.Config.MainColor["p"], TEXT_ALIGN_RIGHT)
			end)

		end
	end
end)

function MRS.OpenMenuManager(parrent, editor, npc)
	if MRS.IsAdministrator(LocalPlayer()) then
		MSD.OpenMenuManager(nil, modulid)
	else
		MRS.OpenRankMenu()
	end
end

net.Receive("MRS.OpenEditor", function()
	MRS.OpenMenuManager()
end)

net.Receive("MRS.RequestStoredData", function()
	local ply = net.ReadEntity()
	local len = net.ReadUInt(32)

	if not ply.MRSdata then ply.MRSdata = { Stored = {} } end
	if not ply.MRSdata.Stored then ply.MRSdata.Stored = {} end

	for i = 1,len do
		local k = net.ReadString()
		local r = net.ReadUInt(32)
		local t = net.ReadUInt(32)
		ply.MRSdata.Stored[k] = {rank = r, time = t}
	end
end)

concommand.Add("mrs_menu", function(pl, cmd, args)
	MRS.OpenMenuManager()
end)

concommand.Add("mrs_rankmenu", function(pl, cmd, args)
	MRS.OpenRankMenu()
end)