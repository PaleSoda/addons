local PANEL = {}

function PANEL:Init()
	self:SetName("entities")
	self:Cache()
end

function PANEL:Cache()
	self.Lookup = {}
	for i, v in pairs(DarkRPEntities) do
		if (!istable(v)) then continue end

		self.Lookup[v.name] = table.Copy(v)
		self.Lookup[v.name].keywords = (self.Lookup[v.name].keywords or ""):lower():Trim()
	end
end

vgui.Register("F4Menu.Items.Entities", PANEL, "F4Menu.Items.Base")
