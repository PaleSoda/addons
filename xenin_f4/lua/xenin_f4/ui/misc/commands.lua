local PANEL = {}

function PANEL:Init()
  self:DockMargin(0, 4, 0, 0)
  self.Hover = XeninUI.Theme.Primary
  self.NonHover = XeninUI.Theme.Navbar
end

function PANEL:OnSwitchedTo()
  self:CreateCommands()
end

vgui.Register("F4Menu.Commands.Standalone", PANEL, "F4Menu.Commands")
