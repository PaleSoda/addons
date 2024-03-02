local PANEL = {}

XeninUI:CreateFont("F4Menu.Dashboard.Stats.Circle.Title", 18)
XeninUI:CreateFont("F4Menu.Dashboard.Stats.Circle", 24)

PANEL.Graphs = {
	["Online"] = function(self)
		self:CreateStat(F4Menu:GetPhrase("dashboard.tabs.general.online.title"), XeninUI.Theme.Blue, function(pnl)
			if (!pnl.Frac) then
				pnl.CalculateFrac = function()
					pnl.Frac = player.GetCount() / game.MaxPlayers()
				end
				pnl:CalculateFrac()

				pnl:AddTimer("F4Menu.Dashboard.Online.Title", 1, 0, function()
					pnl:CalculateFrac()
				end)
			end

			return pnl.Frac
		end, function(pnl)
			if (!pnl.Value) then
				pnl.CalculateValue = function()
					pnl.Value = F4Menu:GetPhrase("dashboard.tabs.general.online.data", {
						online = player.GetCount(),
						max = game.MaxPlayers()
					})
				end
				pnl:CalculateValue()

				pnl:AddTimer("F4Menu.Dashboard.Online.Value", 1, 0, function()
					pnl:CalculateValue()
				end)
			end

			return pnl.Value
		end)
	end,
	["Money"] = function(self)
		self:CreateStat(F4Menu:GetPhrase("dashboard.tabs.general.totalMoney.title"), XeninUI.Theme.Green, nil, function(pnl)
			if (!pnl.Value) then
				pnl.CalculateValue = function()
					local money = tonumber(F4Menu.PlayersMoney) or 0
					if (!F4Menu.Config.UseOfflineMoney) then


						for i, v in ipairs(player.GetAll()) do
							money = money + (v:getDarkRPVar("money") or 0)
						end
					end

					local val
					if (money >= 10 ^ 12) then
						val = DarkRP.formatMoney(math.Round(money / (10 ^ 12), 2)) .. "T"
					elseif (money >= 10 ^ 9) then
						val = DarkRP.formatMoney(math.Round(money / (10 ^ 9), 2)) .. "B"
					elseif (money >= 10 ^ 6) then
						val = DarkRP.formatMoney(math.Round(money / (10 ^ 6), 2)) .. "M"
					elseif (money >= 10 ^ 3) then
						val = DarkRP.formatMoney(math.Round(money / (10 ^ 3), 2)) .. "K"
					end

					pnl.Value = val or DarkRP.formatMoney(money)
				end
				pnl:CalculateValue()

				pnl:AddTimer("F4Menu.Dashboard.TotalMoney", 1, 0, function()
					pnl:CalculateValue()
				end)
			end

			return pnl.Value
		end)
	end,
	["Jobs"] = function(self)
		self:CreateStat(F4Menu:GetPhrase("dashboard.tabs.general.jobDistribution.title"), nil, nil)
	end,
	["Richest Player"] = function(self)
		local richestPlayer = F4Menu.RichestPlayer
		if richestPlayer then
			self:AddPlayer(richestPlayer)
		else
			F4Menu.Network:sendRequestRichestPlayer()
		end

		self:AddHook("F4Menu.RichestPlayer", "F4Menu.Stats.General", function(self, richestPlayer)
			self:AddPlayer(richestPlayer)
		end)
	end
}

function PANEL:Init()
	F4Menu.Network:sendRequestTotalMoney()

	self.Holder = self:Add("Panel")

	self.Stats = {}

	for i, v in ipairs(F4Menu.Config.DashboardGeneralInfoOrder) do
		if (!isfunction(self.Graphs[v])) then continue end

		self.Graphs[v](self)
	end
end

function PANEL:CreateStat(stat, color, func, value)
	color = color or XeninUI.Theme.Red
	func = func or function()
		return 1 end
	value = value or function()
		return ""end

	local panel = self.Holder:Add("DPanel")
	panel:Dock(LEFT)
	panel.CalculatePolygons = function(pnl, w, h)
		pnl.InnerCircle = XeninUI:CalculateCircle(w / 2, h / 2, h / 2 - 30, 45)
		pnl.OuterCircle = XeninUI:CalculateCircle(w / 2, h / 2, h / 2 - 10, 45)
	end
	panel.Paint = function(pnl, w, h)
		XeninUI:MaskInverse(function()
			XeninUI:DrawCachedCircle(pnl.InnerCircle, color_white)
		end, function()
			XeninUI:DrawCachedCircle(pnl.OuterCircle, XeninUI.Theme.Primary)
		end)

		local frac = func(pnl)

		if (stat == F4Menu:GetPhrase("dashboard.tabs.general.jobDistribution.title")) then
			local ang = 0
			local playerCount = player.GetCount()
			local jobs = {}
			for i, v in ipairs(RPExtraTeams or {}) do
				local amt = team.NumPlayers(v.team)

				if (amt > 0) then
					table.insert(jobs, {
						team = v.team,
						col = team.GetColor(v.team),
						amt = amt
					})
				end
			end

			for i, v in ipairs(jobs) do
				local frac = v.amt / playerCount
				local angles = frac * 360
				XeninUI:DrawArc(w / 2, h / 2, ang, angles, h / 2 - 30, ColorAlpha(v.col, 100), 45)
				XeninUI:MaskInverse(function()
					XeninUI:DrawCachedCircle(pnl.InnerCircle, color_white)
				end, function()
					XeninUI:DrawArc(w / 2, h / 2, ang, angles, h / 2 - 10, v.col, 45)
				end)

				ang = ang + angles
			end
		else
			XeninUI:DrawArc(w / 2, h / 2, 0, frac * 360, h / 2 - 30, ColorAlpha(color, 100), 45)
			XeninUI:MaskInverse(function()
				XeninUI:DrawCachedCircle(pnl.InnerCircle, color_white)
			end, function()
				XeninUI:DrawArc(w / 2, h / 2, 0, frac * 360, h / 2 - 10, color, 45)
			end)
		end

		local val = value(pnl)
		XeninUI:DrawShadowText(stat, "F4Menu.Dashboard.Stats.Circle.Title", w / 2, h / 2, Color(215, 215, 215), TEXT_ALIGN_CENTER, val == "" and TEXT_ALIGN_CENTER or TEXT_ALIGN_BOTTOM, 1, 150)
		if (val != "") then
			XeninUI:DrawShadowText(val, "F4Menu.Dashboard.Stats.Circle", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, 150)
		end
	end
	panel.PerformLayout = function(pnl, w, h)
		pnl:CalculatePolygons(w, h)
	end

	table.insert(self.Stats, panel)
end

XeninUI:CreateFont("F4Menu.Dashboard.Stats.Player.Title", 24)
XeninUI:CreateFont("F4Menu.Dashboard.Stats.Player", 20)
XeninUI:CreateFont("F4Menu.Dashboard.Stats.Player.Money", 16)
XeninUI:CreateFont("F4Menu.Dashboard.Stats.Player.Percentage", 12)

function PANEL:AddPlayer(tbl)
	if self.RichestPlayer then
		for i, v in pairs(self.Stats) do
			if (v == self.RichestPlayer) then
				table.remove(self.Stats, i)
			end
		end

		self.RichestPlayer:Remove()
	end

	local sid64 = tbl.sid64
	local ply = player.GetBySteamID64(sid64)
	local name = ply and ply:Nick() or tbl.name
	local money = ply and (ply:getDarkRPVar("money") or tbl.money) or tbl.money or 0

	local panel = self.Holder:Add("Panel")
	panel:Dock(LEFT)
	panel.Avatar = panel:Add("XeninUI.Avatar")
	panel.Avatar.avatar:SetSteamID(sid64, 128)
	panel.Avatar:SetVertices(90)
	panel.Avatar.CalculateMoney = function(pnl)
		return tonumber(F4Menu.PlayersMoney) or 0
	end
	panel.Avatar.avatar.CalculatePolygons = function(pnl, w, h)
		pnl.Circle = XeninUI:CalculateCircle(h / 2 - 1, h / 2, h / 2 + 1, 45)
	end
	panel.Avatar.avatar.PaintOver = function(pnl, w, h)
		pnl:NoClipping(false)
		XeninUI:DrawCachedCircle(pnl.Circle, Color(0, 0, 0, 225))
		pnl:NoClipping(true)

		XeninUI:DrawShadowText(F4Menu:GetPhrase("dashboard.tabs.general.richestPlayer.title"), "F4Menu.Dashboard.Stats.Player.Title", w / 2, h / 2 - 8, Color(160, 160, 160), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, 255)
		XeninUI:DrawShadowText(name, "F4Menu.Dashboard.Stats.Player", w / 2, h / 2 - 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, 255)
		XeninUI:DrawShadowText(DarkRP.formatMoney(money), "F4Menu.Dashboard.Stats.Player.Money", w / 2, h / 2 + 16, XeninUI.Theme.Green, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, 255)

		local frac = math.Clamp(money / panel.Avatar:CalculateMoney(), 0, 1)
		XeninUI:DrawShadowText(F4Menu:GetPhrase("dashboard.tabs.general.richestPlayer.economy", {
		percentage = math.Round(frac * 100, 2) }), "F4Menu.Dashboard.Stats.Player.Percentage", w / 2, h - 32, Color(185, 185, 185), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, 255)
	end
	panel.PerformLayout = function(pnl, w, h)
		local size = h - 10

		panel.Avatar:SetPos(w - size - 20, h - size)
		panel.Avatar:SetSize(size, size - 10)
		panel.Avatar.avatar:CalculatePolygons(w, h)
	end

	self.RichestPlayer = panel

	table.insert(self.Stats, panel)

	self:InvalidateLayout()
end

function PANEL:PerformLayout(w, h)
	self.Holder:SetTall(h)
	self.Holder:SetWide(w * (#self.Stats * 0.25))
	self.Holder:CenterHorizontal()

	for i, v in ipairs(self.Stats) do
		v:SetWide(w * 0.25)
	end
end

vgui.Register("F4Menu.Dashboard.Stats.General", PANEL)
