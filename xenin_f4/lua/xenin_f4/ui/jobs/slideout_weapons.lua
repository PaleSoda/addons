local PANEL = {}

function PANEL:Init()
	self:DockMargin(24, 16, 16, 24)

	self.Scroll = self:Add("XeninUI.Scrollpanel.Wyvern")
	self.Scroll:Dock(FILL)
end

XeninUI:CreateFont("F4Menu.Jobs.Slideout.Weapons", 16)


PANEL.HL2 = {
	["weapon_bugbait"] = {
		name = "Bugbait",
		model = "models/weapons/w_bugbait.mdl"
	},
	["weapon_357"] = {
		name = ".357 Magnum",
		model = "models/weapons/w_357.mdl"
	},
	["weapon_pistol"] = {
		name = "Pistol",
		model = "models/weapons/w_pistol.mdl"
	},
	["weapon_crossbow"] = {
		name = "Crossbow",
		model = "models/weapons/w_crossbow.mdl"
	},
	["weapon_crowbar"] = {
		name = "Crowbar",
		model = "models/weapons/w_crowbar.mdl"
	},
	["weapon_frag"] = {
		name = "Grenade",
		model = "models/weapons/w_grenade.mdl"
	},
	["weapon_physcannon"] = {
		name = "Gravity Gun",
		model = "models/weapons/w_Physics.mdl"
	},
	["weapon_ar2"] = {
		name = "Pulse-Rifle",
		model = "models/weapons/w_irifle.mdl"
	},
	["weapon_rpg"] = {
		name = "RPG",
		model = "models/weapons/w_rocket_launcher.mdl"
	},
	["weapon_slam"] = {
		name = "S.L.A.M",
		model = "	models/weapons/w_slam.mdl"
	},
	["weapon_shotgun"] = {
		name = "Shotgun",
		model = "models/weapons/w_shotgun.mdl"
	},
	["weapon_smg1"] = {
		name = "SMG",
		model = "models/weapons/w_smg1.mdl"
	},
	["weapon_stunstick"] = {
		name = "Stunstick",
		model = "models/weapons/w_stunbaton.mdl"
	}
}

function PANEL:SetWeapons(tbl)
	for i, v in ipairs(tbl) do
		local wep = weapons.Get(v)
		local mdl = "error.mdl"
		local name = "Unknown name"
		if wep then
			mdl = wep.WorldModel or wep.WM or wep.Model or wep.ViewModel or wep.VM
			name = wep.GetPrintName and wep:GetPrintName() or wep.PrintName or wep.Name or (wep.Primary and wep.Primary.Name) or wep.Print or wep.Display
		elseif self.HL2[v] then
			name = self.HL2[v].name
			mdl = self.HL2[v].model
		end

		local panel = self.Scroll:Add("Panel")
		panel:Dock(TOP)
		panel:SetTall(40)
		panel:DockMargin(0, 0, 0, 4)
		panel.Paint = function(pnl, w, h)
			XeninUI:DrawRoundedBox(6, 0, 0, w, h, XeninUI.Theme.Primary)

			XeninUI:MaskInverse(function()
				XeninUI:DrawRoundedBox(6, 1, 1, w - 2, h - 2, XeninUI.Theme.Primary)
			end, function()
				XeninUI:DrawRoundedBox(6, 0, 0, w, h, Color(65, 65, 65))
			end)
		end
		panel.OnCursorEntered = function(pnl)
			if IsValid(pnl.Preview) then return end

			local panel = vgui.Create("Panel")
			pnl.Preview = panel
			panel:SetSize(166, 150)
			panel:MakePopup()
			panel.Paint = function(pnl, w, h)
				XeninUI:DrawRoundedBox(6, 16, 0, w - 16, h, XeninUI.Theme.Primary)

				XeninUI:MaskInverse(function()
					XeninUI:DrawRoundedBox(6, 17, 1, w - 18, h - 2, XeninUI.Theme.Primary)
				end, function()
					XeninUI:DrawRoundedBox(6, 16, 0, w - 16, h, Color(65, 65, 65))
				end)

				local tbl = {
					{
						x = 4,
						y = 20
					},
					{
						x = 16,
						y = 12
					},
					{
						x = 16,
						y = 28
					}
				}

				draw.NoTexture()
				surface.SetDrawColor(Color(65, 65, 65))
				surface.DrawPoly(tbl)
			end
			panel.Think = function(self)
				if (!IsValid(pnl)) then
					self:Remove()

					return
				end

				local aX, aY = pnl:LocalToScreen()
				aX = aX + pnl:GetWide()
				if (pnl.x != aX) then
					self:SetPos(aX, aY)
				end
			end

			panel.Model = panel:Add("DModelPanel")
			panel.Model:Dock(FILL)
			panel.Model:DockMargin(16, 0, 0, 0)
			panel.Model:SetMouseInputEnabled(false)
			panel.Model.LayoutEntity = function() end
			panel.Model:SetModel(mdl)
			if IsValid(panel.Model.Entity) then
				local mn, mx = panel.Model.Entity:GetRenderBounds()
				local size = 0
				size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
				size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
				size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
				panel.Model:SetFOV(45)
				panel.Model:SetCamPos(Vector(size, size, size))
				panel.Model:SetLookAt((mn + mx) * 0.5)
				panel.Model.Entity:SetPos(Vector(0, 0, 0))
			end
		end
		panel.OnCursorExited = function(pnl)
			if (!IsValid(pnl.Preview)) then return end

			pnl.Preview:Remove()
		end
		panel.OnRemove = function(pnl)
			if (!IsValid(pnl.Preview)) then return end

			pnl.Preview:Remove()
		end

		panel.Model = panel:Add("DModelPanel")
		panel.Model:Dock(LEFT)
		panel.Model:SetMouseInputEnabled(false)
		panel.Model.LayoutEntity = function() end
		panel.Model:SetModel(mdl)
		if IsValid(panel.Model.Entity) then
			local mn, mx = panel.Model.Entity:GetRenderBounds()
			local size = 0
			size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
			size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
			size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
			panel.Model:SetFOV(45)
			panel.Model:SetCamPos(Vector(size, size, size))
			panel.Model:SetLookAt((mn + mx) * 0.5)
			panel.Model.Entity:SetPos(Vector(0, 0, 0))
		end

		panel.Label = panel:Add("DLabel")
		panel.Label:DockMargin(8, 0, 0, 0)
		panel.Label:SetText(name)
		panel.Label:SetFont("F4Menu.Jobs.Slideout.Weapons")
		panel.Label:SetContentAlignment(4)
		panel.Label:SetTextColor(Color(212, 212, 212))
		panel.Label:SetWrap(true)
		panel.Label:SetAutoStretchVertical(true)

		panel.PerformLayout = function(pnl, w, h)
			pnl.Model:SetWide(h)

			pnl.Label:SetPos(h + 8)
			pnl.Label:SetWide(w - h - 8)
			pnl.Label:CenterVertical()
		end
	end
end

vgui.Register("F4Menu.Jobs.Slideout.Weapons", PANEL, "Panel")
