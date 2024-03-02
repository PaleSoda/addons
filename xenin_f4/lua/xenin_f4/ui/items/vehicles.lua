local PANEL = {}

function PANEL:Init()
	self:SetName("vehicles")
	self:Cache()
end

function PANEL:Cache()
	self.Lookup = {}
	for i, v in pairs(CustomVehicles) do
		if (!istable(v)) then continue end

		self.Lookup[v.name] = table.Copy(v)
		self.Lookup[v.name].keywords = (self.Lookup[v.name].keywords or ""):lower():Trim()
	end
end

vgui.Register("F4Menu.Items.Vehicles", PANEL, "F4Menu.Items.Base")
