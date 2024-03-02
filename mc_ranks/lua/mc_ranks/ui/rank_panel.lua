-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║╚═╝║╚══╗──By MacTavish <3──────
-- ║║║║║║╔╗╔╩══╗║───────────────────────
-- ║║║║║║║║╚╣╚═╝║───────────────────────
-- ╚╝╚╝╚╩╝╚═╩═══╝───────────────────────

local RankMenu
local Ln = MSD.GetPhrase
local ranks_1 = Material("ranks_ui/rank_low.png", "smooth")
local ranks_2 = Material("ranks_ui/rank.png", "smooth")
local ranks_3 = Material("ranks_ui/rank_sup.png", "smooth")

function MRS.OpenRankMenu()

	if IsValid(RankMenu) then return end

	local sw, sh = ScrW(), ScrH()

	sw, sh = sw / 2, sh - sh / 3

	RankMenu = vgui.Create("MSDSimpleFrame")
	RankMenu:SetSize(sw, sh)
	RankMenu:SetDraggable(false)
	RankMenu:Center()
	RankMenu:MakePopup()
	RankMenu.OnClose = function()
		RankMenu = nil
	end
	RankMenu:SetAlpha(1)
	RankMenu:AlphaTo(255, 0.4)

	local update = 0
	local group = MRS.GetNWdata(LocalPlayer(), "Group")
	local rank = MRS.GetNWdata(LocalPlayer(), "Rank")

	RankMenu.Paint = function(self, w, h)

		if update < CurTime() then
			update = CurTime() + 1
			group = MRS.GetNWdata(LocalPlayer(), "Group")
			rank = MRS.GetNWdata(LocalPlayer(), "Rank")
		end

		MSD.DrawBG(self, w, h)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h - 0, MSD.Theme["l"])

		if not group or not rank then
			draw.DrawText(Ln("mrs_noranks"), "MSDFont.25", w / 2, h / 2 - 12, color_white, TEXT_ALIGN_CENTER)
			return
		end

		if not MRS.Ranks[group] or not MRS.Ranks[group].ranks[rank] then return end

		draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, 128, MSD.Theme["l"])

		local rank_t = MRS.Ranks[group].ranks[rank]

		if rank_t.icon[1] and rank_t.icon[1] ~= "" then
			local icon = MRS.GetRankIcon(rank_t.icon)
			MSD.DrawTexturedRect(32, 32, 64, 64, icon, color_white)
		end
		draw.SimpleTextOutlined(rank_t.name, "MSDFont.36", 128, 32, color_white, TEXT_ALIGN_LEFT, 0, 1, color_black)
		draw.SimpleTextOutlined(group, "MSDFont.22", 130, 72, color_white, TEXT_ALIGN_LEFT, 0, 1, color_black)

		local prog = MRS.GetSelfNWdata(LocalPlayer(), "progress")
		if rank_t.autoprom and prog  then
			local per = prog / rank_t.autoprom
			draw.RoundedBox(MSD.Config.Rounded, 0, 120, w, 8, MSD.Theme["l"])
			draw.RoundedBox(MSD.Config.Rounded, 0, 120, w * per, 8, MSD.Config.MainColor["p"])

			draw.SimpleTextOutlined(Ln("promotion") .. " (" .. Ln("in_min") .. "): " .. rank_t.autoprom - prog, "MSDFont.25", w - 10, 90, color_white, TEXT_ALIGN_RIGHT, 0, 1, color_black)
		end

		if not rank_t.can_promote and not rank_t.can_demote then
			draw.DrawText(Ln("mrs_nopower"), "MSDFont.25", w / 2, h / 2 - 12, color_white, TEXT_ALIGN_CENTER)
			return
		end

		draw.RoundedBox(MSD.Config.Rounded, 0, 130, w / 2, h - 130, MSD.Theme["l"])
		draw.RoundedBox(MSD.Config.Rounded, w / 2 + 2, 130, w / 2 - 2, h - 130, MSD.Theme["l"])
	end

	RankMenu.clsBut = MSD.IconButton(RankMenu, MSD.Icons48.cross, RankMenu:GetWide() - 34, 10, 25, nil, MSD.Config.MainColor.p, function()
		if RankMenu.OnPress then
			RankMenu.OnPress()

			return
		end

		RankMenu:AlphaTo(0, 0.4, 0, function()
			RankMenu:Close()
		end)
	end)

	if not MRS.Ranks[group] or not MRS.Ranks[group].ranks[rank] then return end

	local rank_t = MRS.Ranks[group].ranks[rank]

	if rank_t.models and #rank_t.models > 0 then
		MSD.ButtonIcon(RankMenu, RankMenu:GetWide() - 125, 65, 120, 50, Ln("model"), MSD.Icons48.account_edit, function(self)
			local pn, child = MSD.WorkSpacePanel(RankMenu, Ln("model"), 2, 1, false)
			local sub_list = vgui.Create("MSDPanelList", child)
			sub_list:SetSize(child:GetWide() - 10, child:GetTall() - 50)
			sub_list:SetPos(5, 50)
			sub_list:EnableVerticalScrollbar()
			sub_list:EnableHorizontal(true)
			sub_list:SetSpacing(2)
			sub_list.IgnoreVbar = true

			for k,v in pairs(rank_t.models) do
				local pnl = MSD.BigModelButton(sub_list, "static", nil, 1, 150, Ln("model") .. " #" .. k, MSD.Icons48.swap, function()
					RunConsoleCommand("mrs_playermodel", k)
					pn:Close()
				end)
				pnl.SetCustomModel(v.model)
				for i,b in pairs(v.bgrs) do
					pnl.Icon.Entity:SetBodygroup(i, b)
				end
				pnl.Icon.Entity:SetSkin(v.skin)
			end

		end)
	end

	if not rank_t.can_promote and not rank_t.can_demote then return end

	local list_right, list_left
	list_left = vgui.Create("MSDPanelList", RankMenu)
	list_left:SetSize(RankMenu:GetWide() / 2, RankMenu:GetTall() - 130)
	list_left:SetPos(0, 130)
	list_left:EnableVerticalScrollbar()
	list_left:EnableHorizontal(true)
	list_left:SetSpacing(2)
	list_left:SetPadding(0)
	list_left.IgnoreVbar = true

	list_right = vgui.Create("MSDPanelList", RankMenu)
	list_right:SetSize(RankMenu:GetWide() / 2 - 2, RankMenu:GetTall() - 130)
	list_right:SetPos(RankMenu:GetWide() / 2 + 2, 130)
	list_right:EnableVerticalScrollbar()
	list_right:EnableHorizontal(true)
	list_right:SetSpacing(2)
	list_right:SetPadding(0)
	list_right.IgnoreVbar = true

	list_left.Populate = function()
		list_left:Clear()

		local others = {}

		local hdr =	MSD.Header(list_left, Ln("on_duty"))
		local delh = true
		for _,p in ipairs(player.GetAll()) do
			if p == LocalPlayer() then continue end
			if MRS.GetNWdata(p, "Group") ~= group then
				table.insert(others,p)
				continue
			end
			if MRS.GetNWdata(p, "Rank") >= rank then continue end
			MSD.ButtonIcon(list_left, "static", nil, 1, 50, p:Name(), ranks_2, function()
				list_right.Populate(p)
			end)
			delh = false
		end

		if delh then hdr:Remove() end
		MSD.Header(list_left, Ln("other_players"))

		for _,p in ipairs(others) do
			MSD.ButtonIcon(list_left, "static", nil, 1, 50, p:Name(), MSD.Icons48.account, function()
				list_right.Populate(p)
			end)
		end
	end

	list_right.Populate = function(ply)
		list_right:Clear()

		local hdr = MSD.Header(list_right, ply:Name() .. " | " .. (ply.SteamName and ply:SteamName() or ""))

		local grp = MRS.Ranks[group]
		local p_group, p_rank

		hdr.Think = function()
			p_group = MRS.GetNWdata(ply, "Group")
			p_rank = MRS.GetNWdata(ply, "Rank")
		end

		for k,v in SortedPairs(grp.ranks, true) do
			if k >= rank then continue end
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
				RunConsoleCommand("mrs_setrank", ply:UserID(), group, k)
			end, nil, nil, color_white, function(self, w, h)
				if p_group ~= group or p_rank ~= k then return end
				draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["l"])
				draw.DrawText(Ln("active"), "MSDFont.22", w - 20, h / 2 - 11, MSD.Config.MainColor["p"], TEXT_ALIGN_RIGHT)
			end)

		end

	end

	list_left.Populate()
end