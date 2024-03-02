local PANEL = {}

function PANEL:Init()
	self:SetName("shipments")
	self:Cache()
end

function PANEL:Cache()
	self.Lookup = {}
	for i, v in pairs(CustomShipments) do
		if (!istable(v)) then continue end
		if v.noship then continue end

		self.Lookup[v.name] = table.Copy(v)
		self.Lookup[v.name].keywords = (self.Lookup[v.name].keywords or ""):lower():Trim()
	end
end

vgui.Register("F4Menu.Items.Shipments", PANEL, "F4Menu.Items.Base")
