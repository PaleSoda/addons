local PANEL = {}

function PANEL:Init()
	self:SetName("food")
	self:Cache()
end

function PANEL:Cache()
	self.Lookup = {}
	for i, v in pairs(FoodItems or {}) do
		if (!istable(v)) then continue end

		self.Lookup[v.name] = table.Copy(v)
		self.Lookup[v.name].removeMax = true
		self.Lookup[v.name].keywords = (self.Lookup[v.name].keywords or ""):lower():Trim()
	end
end

vgui.Register("F4Menu.Items.Food", PANEL, "F4Menu.Items.Base")
