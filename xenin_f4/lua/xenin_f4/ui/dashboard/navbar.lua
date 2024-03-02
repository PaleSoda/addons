local PANEL = {}
AccessorFunc(PANEL, "m_body", "Body")

XeninUI:CreateFont("F4Menu.Dashboard.Navbar", 24)

function PANEL:Init()
	self.Buttons = {}
	self.Panels = {}
end

function PANEL:AddTab(name, pnlClass)
	if pnlClass == nil then pnlClass = "DPanel"
	end
	local button = self:Add("DButton")
	button:Dock(LEFT)
	button:DockMargin(0, 0, 16, 0)
	button:SetText(name)
	button:SetFont("F4Menu.Dashboard.Navbar")
	button.TextColor = Color(155, 155, 155)
	button:SizeToContentsX()
	button.Paint = function(pnl, w, h)
		pnl:SetTextColor(pnl.TextColor)
	end
	button.OnCursorEntered = function(pnl)
		pnl:LerpColor("TextColor", color_white)
	end
	button.OnCursorExited = function(pnl)
		if (self.Active == pnl.Id) then return end

		pnl:LerpColor("TextColor", Color(155, 155, 155))
	end
	button.DoClick = function(pnl)
		self:SetActive(pnl.Id)
	end

	local id = table.insert(self.Buttons, button)
	self.Buttons[id].Id = id

	local panel = self:GetBody():Add(pnlClass)
	panel:Dock(FILL)
	panel:SetVisible(false)

	table.insert(self.Panels, panel)
end

function PANEL:SetActive(id)
	local active = self.Buttons[self.Active]
	if IsValid(active) then
		active:LerpColor("TextColor", Color(155, 155, 155))

		local activePnl = self.Panels[self.Active]
		if IsValid(activePnl) then
			activePnl:SetVisible(false)
		end
	end

	self.Active = id

	local new = self.Buttons[id]
	if IsValid(new) then
		new:LerpColor("TextColor", color_white)

		local newPnl = self.Panels[id]
		if IsValid(newPnl) then
			newPnl:SetVisible(true)
		end
	end
end

vgui.Register("F4Menu.Dashboard.Navbar", PANEL)
