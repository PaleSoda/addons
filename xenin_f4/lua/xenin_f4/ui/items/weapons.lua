local PANEL = {}

function PANEL:Init()
	self:SetName("weapons")
	self:Cache()
end

function PANEL:Cache()
	self.Lookup = {}
	for i, v in pairs(CustomShipments) do
		if (!istable(v)) then continue end
		if (!v.separate) then continue end

		self.Lookup[v.name] = table.Copy(v)
		self.Lookup[v.name].keywords = (self.Lookup[v.name].keywords or ""):lower():Trim()
	end
end

vgui.Register("F4Menu.Items.Weapons", PANEL, "F4Menu.Items.Base")
