local PANEL = {}

XeninUI:CreateFont("F4Menu.URL.Title", 48)
XeninUI:CreateFont("F4Menu.URL.URL", 24)

function PANEL:OnSwitchedTo(tbl)
	self.Name = tbl.tabName or tbl.name or ""
	self.URL = tbl.url

	gui.OpenURL(self.URL)
end

function PANEL:Paint(w, h)
	if self.Name then
		XeninUI:DrawShadowText(self.Name, "F4Menu.URL.Title", w / 2, 64, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, 200)
		XeninUI:DrawShadowText(self.URL, "F4Menu.URL.URL", w / 2, 64 + 56, Color(212, 212, 212), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, 200)
	end
end

vgui.Register("F4Menu.URL", PANEL)
