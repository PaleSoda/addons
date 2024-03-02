local PANEL = {}

function PANEL:Init()
	self.Scroll = self:Add("XeninUI.Scrollpanel.Wyvern")
	self.Scroll:Dock(FILL)
	self.Scroll:DockMargin(0, 40, 0, 0)

	self.Players = {}

	self:AddTimer("F4Menu.Dashboard.Staff", 10, 0, function()
		self:Build()
	end)

	self:Build()
end

function PANEL:Build()
	for i, v in ipairs(self.Players) do
		v:Remove()
		self.Players[i] = nil
	end

	local tbl = {}
	for i, v in ipairs(player.GetAll()) do
		local usergroup = F4Menu.Config.Staff[v:GetUserGroup()]
		if (!usergroup) then continue end

		table.insert(tbl, {
			ply = v,
			usergroup = usergroup
		})
	end

	table.sort(tbl, function(a, b)
		return a.usergroup.sortOrder < b.usergroup.sortOrder end)
	for i, v in ipairs(tbl) do
		self:CreatePlayer(v.ply)
	end
end

function PANEL:CreatePlayer(ply)
	local name = ply:Nick()
	local usergroup = ply:GetUserGroup()
	local rank = F4Menu.Config.Staff[usergroup]
	local rankName = istable(rank) and rank.str or (usergroup:sub(1, 1):upper() .. usergroup:sub(2))
	local rankColor = istable(rank) and rank.color or Color(182, 182, 182)

	local panel = self.Scroll:Add("DButton")
	panel:Dock(TOP)
	panel:DockMargin(0, 0, 8, 8)
	panel:SetText("")
	panel:SetTall(64)
	panel.Paint = function(pnl, w, h)
		XeninUI:DrawRoundedBox(6, 0, 0, w, h, Color(50, 50, 50))

		local x = pnl.Avatar:GetWide() + (pnl.Avatar.x * 2) + 4

		XeninUI:DrawShadowText(name, "F4Menu.Jobs.Row.Name", x, h / 2, Color(231, 231, 235), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, 150)
		XeninUI:DrawShadowText(rankName, "F4Menu.Jobs.Row.Salary", x, h / 2, rankColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, 150)
	end
	panel.DoClick = function(pnl)
		if (!IsValid(ply)) then return end

		ply:ShowProfile()
	end

	panel.Avatar = panel:Add("XeninUI.Avatar")
	panel.Avatar:SetMouseInputEnabled(false)
	panel.Avatar:SetPlayer(ply, 64)
	panel.Avatar:SetVertices(30)

	panel.PerformLayout = function(pnl, w, h)
		pnl.Avatar:SetPos(10, 10)
		pnl.Avatar:SetSize(h - 20, h - 20)
	end

	table.insert(self.Players, panel)
end

function PANEL:Paint(w, h)
	draw.SimpleText(F4Menu:GetPhrase("dashboard.onlineStaff.title"), "F4Menu.Dashboard.Navbar", 0, 32 / 2, Color(212, 212, 212), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("F4Menu.Dashboard.Staff", PANEL)
