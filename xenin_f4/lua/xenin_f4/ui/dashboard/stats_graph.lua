local PANEL = {}

function PANEL:Init()
	if (!F4Menu.EconomySnapshots) then
		F4Menu.Network:sendRequestEconomySnapshots()
	end

	self.Data = F4Menu.EconomySnapshots or {}

	self:AddHook("F4Menu.EconomySnapshots", "Graph", function(self)
		self.Data = F4Menu.EconomySnapshots
		self:CreateGraph()
	end)

	self:CreateGraph()
end

XeninUI:CreateFont("F4Menu.Dashboard.Graph", 14)

function PANEL:CreateGraph()
	if IsValid(self.Graph) then
		self.Graph:Remove()
		self.Graph = nil
	end

	local data = table.Reverse(self.Data)
	local lowest = math.huge
	local highest = 0
	for i, v in ipairs(data) do
		if (v < lowest) then lowest = v continue end
		if (v > highest) then highest = v continue end
	end

	local steps = 5
	local axisYGrid = {
	lowest }
	for i = 2, steps do
		axisYGrid[i] = math.Round(Lerp(i / steps, lowest, highest))
	end
	axisYGrid = table.Reverse(axisYGrid)

	local stepsX = 7
	local axisXGrid = {
	0 }
	for i = 2, stepsX do
		axisXGrid[i] = i / steps
	end

	self.Graph = self:Add("Panel")
	self.Graph:Dock(FILL)
	self.Graph.Format = function(pnl, number)
		if (number == math.huge or number != number) then
			return F4Menu:GetPhrase("dashboard.tabs.economy.noData")
		end

		if (number >= 10 ^ 12) then
			return DarkRP.formatMoney(math.Round(number / (10 ^ 12), 2)) .. "T"
		elseif (number >= 10 ^ 9) then
			return DarkRP.formatMoney(math.Round(number / (10 ^ 9), 2)) .. "B"
		elseif (number >= 10 ^ 6) then
			return DarkRP.formatMoney(math.Round(number / (10 ^ 6), 2)) .. "M"
		elseif (number >= 10 ^ 3) then
			return DarkRP.formatMoney(math.Round(number / (10 ^ 3), 2)) .. "K"
		end

		return DarkRP.formatMoney(math.Round(number))
	end
	self.Graph.Paint = function(pnl, w, h)
		XeninUI:DrawRoundedBox(6, 0, 0, w, h, XeninUI.Theme.Navbar)

		local y = 18 + 16
		local size = #axisYGrid
		h = pnl.Background:GetTall()

		for i, v in ipairs(axisYGrid) do
			local str = pnl:Format(v)
			draw.SimpleText(str, "F4Menu.Dashboard.Graph", 60 / 2, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			local frac = i / size
			y = y + ((1 / size) * h)
		end

		local x = 60
		w = pnl.Background:GetWide()
		y = h + 5
		h = 24
		surface.SetDrawColor(0, 0, 0, 100)

		surface.SetFont("F4Menu.Dashboard.Graph")
		local tw = surface.GetTextSize(F4Menu:GetPhrase("dashboard.tabs.economy.days")[7])
		for i, v in ipairs(axisXGrid) do
			local j = i - 1
			local str = F4Menu:GetPhrase("dashboard.tabs.economy.days")[8 - i]

			draw.SimpleText(str, "F4Menu.Dashboard.Graph", x + ((j / stepsX) * (w * 1.115)), y + h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end

	self.Graph.Background = self.Graph:Add("DPanel")
	self.Graph.Background:Dock(FILL)
	self.Graph.Background:DockMargin(60, 16, 16, 16)
	self.Graph.Background.Paint = function(pnl, w, h)
		local y = 18
		local size = #axisYGrid

		surface.SetDrawColor(0, 0, 0, 100)

		for i, v in ipairs(axisYGrid) do
			surface.SetDrawColor(125, 125, 125)
			surface.DrawLine(0, y, w, y)

			local frac = i / size
			y = y + ((1 / size) * h)
		end

		y = 18
		h = h - y * 2
		surface.SetDrawColor(255, 0, 0, 100)



		local size = 168 - 1
		local tbl = {}
		for i, v in ipairs(self.Data) do
			local x = (1 - ((i - 1) / size)) * w
			local y
			if (lowest == highest) then
				y = (1 - 1) * h
			else
				y = (1 - ((v - lowest) / (highest - lowest))) * h
			end

			table.insert(tbl, {
				x,
				y
			})
		end

		for i, v in ipairs(tbl) do
			local startPoint = tbl[i]
			local endPoint = tbl[i + 1]
			if (i == #tbl) then
				endPoint = v
			end

			surface.SetDrawColor(XeninUI.Theme.Accent)
			surface.DrawLine(startPoint[1], startPoint[2] + y, endPoint[1], endPoint[2] + y)
			surface.DrawLine(startPoint[1], startPoint[2] + 1 + y, endPoint[1], endPoint[2] + 1 + y)
			surface.DrawLine(startPoint[1], startPoint[2] - 1 + y, endPoint[1], endPoint[2] - 1 + y)
		end
	end
end

vgui.Register("F4Menu.Dashboard.Stats.Graph", PANEL)
