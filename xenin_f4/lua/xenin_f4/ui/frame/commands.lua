local PANEL = {}

XeninUI:CreateFont("F4Menu.Dashboard.Commands", 15)
XeninUI:CreateFont("F4Menu.Dashboard.Commands.Title", 22)

function PANEL:Init()
	self.Hover = Color(0, 0, 0, 200)
	self.NonHover = Color(0, 0, 0, 100)

	self.Scroll = self:Add("XeninUI.ScrollPanel")
	self.Scroll:Dock(FILL)
	self.Scroll:DockMargin(0, 0, 0, 8)
	self.Scroll.VBar:SetWide(0)

	self.Layout = self.Scroll:Add("DIconLayout")
	self.Layout:Dock(FILL)
	self.Layout:DockMargin(12, 0, 12, 0)
	self.Layout:SetSpaceY(4)
	self.Layout:SetSpaceX(4)
	self.Layout.PerformLayout = function(pnl, w, h)
		local children = pnl:GetChildren()
		local count = 1
		local amount = math.max(1, math.floor(#children / count)) * 276
		local width = w / math.min(count, #children)

		local x = 0
		local y = 0

		local spacingX = pnl:GetSpaceX()
		local spacingY = pnl:GetSpaceY()
		local border = pnl:GetBorder()
		local innerWidth = w - border * 2 - spacingX * (count - 1)

		for i, child in ipairs(children) do
			if (!IsValid(child)) then continue end

			child:SetPos(border + x * innerWidth / count + spacingX * x, border + y * child:GetTall() + spacingY * y)
			child:SetSize(innerWidth / count, 32)

			x = x + 1
			if (x >= count) then
				x = 0
				y = y + 1
			end
		end

		pnl:SizeToChildren(false, true)
	end
end

function PANEL:CreateCommands()
	self.Layout:Clear()

	local ply = LocalPlayer()

	for k, cat in ipairs(F4Menu.Commands) do
		if (cat.customCheck and !cat.customCheck(ply)) then continue end

		local panel = self.Layout:Add("DLabel")
		panel:SetText(cat.dontTranslate and cat.name or F4Menu:GetPhrase(cat.name))
		panel:SetTextColor(color_white)
		panel:SetFont("F4Menu.Dashboard.Commands.Title")
		panel:SetContentAlignment(5)

		for i, v in pairs(cat.commands) do
			if (v.customCheck and !cat.customCheck(ply)) then continue end

			local panel = self.Layout:Add("DButton")
			panel:SetText("")
			panel.Background = self.NonHover
			panel.TextColor = Color(200, 200, 200)
			panel.Paint = function(pnl, w, h)
				pnl.Text:SetTextColor(pnl.TextColor)

				XeninUI:DrawRoundedBox(6, 0, 0, w, h, pnl.Background)
			end
			panel.OnCursorEntered = function(pnl)
				pnl:LerpColor("Background", self.Hover)
				pnl:LerpColor("TextColor", color_white)
			end
			panel.OnCursorExited = function(pnl)
				pnl:LerpColor("Background", self.NonHover)
				pnl:LerpColor("TextColor", Color(200, 200, 200))
			end
			panel.DoClick = function(pnl)
				if v.input then
					local input = istable(v.input) and v.input or {}

					local translate = function(str)
						if (!str) then return ""end

						if v.dontTranslate then
							return str or ""
						else
							return F4Menu:GetPhrase(str) or ""
						end
					end

					F4Menu:Modal(translate(v.name) or "", translate(input.desc or v.name) or "", translate(isfunction(input.str) and input.str(ply) or input.str or "") or "", translate(isfunction(input.placeholder) and input.placeholder(ply) or input.placeholder or "") or "", input.numeric, function(value, pnl, sid64)
						v.func(ply, value, pnl, sid64)
					end, v.option, input.removeField)
				else
					v.func(ply, nil, pnl)
				end
			end

			panel.Text = panel:Add("DLabel")
			panel.Text:SetMouseInputEnabled(false)
			panel.Text:Dock(FILL)
			panel.Text:SetText(v.dontTranslate and v.name or F4Menu:GetPhrase(v.name))
			panel.Text:SetFont("F4Menu.Dashboard.Commands")
			panel.Text:SetContentAlignment(5)
		end
	end
end

vgui.Register("F4Menu.Commands", PANEL)

local PANEL = {}

function F4Menu:Modal(title, text, str, placeholder, numeric, acceptFunc, options, removeInput)
	str = str or ""

	local modal = vgui.Create("XeninUI.Query")
	modal:SetSize(ScrW(), ScrH())
	modal:SetCustomWidth(400)
	local increasedHeight = !removeInput and 48 or 0
	increasedHeight = increasedHeight + (options and 48 or 0)
	modal:SetBackgroundHeight(140 + increasedHeight)
	modal:SetTitle(title)
	modal:SetText(text)
	modal:SetAccept("Accept", function(self, pnl, value, sid64)
		acceptFunc(value, pnl, sid64)
	end)
	modal:SetDecline("Decline", function() end)
	if (!removeInput) then
		modal:SetInput(str, placeholder, numeric)
	end
	if options then
		local tbl = {}
		local isFunc = isfunction(options)
		for i, v in ipairs(player.GetHumans()) do
			if (!IsValid(v)) then continue end
			if isFunc then
				if (!options(v)) then continue end
			end

			table.insert(tbl, v)
		end

		modal:SetOption(tbl)
	end
	modal:MakePopup()

	modal.background.input.textentry:RequestFocus()
end
