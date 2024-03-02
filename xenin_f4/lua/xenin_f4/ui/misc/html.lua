local PANEL = {}

function PANEL:OnSwitchedTo(tbl)
	if (!self.Set) then
		self.Set = true

		self:OpenURL(tbl.url)
	end
end

function PANEL:Paint(w, h)
	XeninUI:DrawLoadingCircle(w / 2, h / 2, 128, XeninUI.Theme.Green)
end

vgui.Register("F4Menu.Website", PANEL, "DHTML")
