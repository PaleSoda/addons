local IsValid = IsValid
local LocalPlayer = LocalPlayer
local HSVToColor = HSVToColor
local Vector = Vector
local FrameTime = FrameTime
local CurTime = CurTime
local HasFocus = system.HasFocus

local entMeta = FindMetaTable("Entity")
local GetPos = entMeta.GetPos
local GetClass = entMeta.GetClass
local IsDormant = entMeta.IsDormant

local vecMeta = FindMetaTable("Vector")
local DistToSqr = vecMeta.DistToSqr

local plyMeta = FindMetaTable("Player")
local SetWeaponColor = plyMeta.SetWeaponColor
local GetWeaponColor = plyMeta.GetWeaponColor
local GetActiveWeapon = plyMeta.GetActiveWeapon

local function L(phrase, ...)
	if (#({...}) == 0) then
		return GAS:Phrase(phrase, "adminphysgun")
	else
		return GAS:PhraseFormat(phrase, "adminphysgun", ...)
	end
end

GAS.AdminPhysgun = {}

--## FREEZE PLAYER ##--

GAS:hook("PlayerBindPress", "adminphysgun:PlayerBindPress", function(ply, bind)
	if (bind == "+attack2" and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_physgun") then
		GAS:netStart("adminphysgun:FreezePlayer")
		net.SendToServer()
	end
end)

GAS:netReceive("adminphysgun:FreezePlayer", function()
	GAS:PlaySound("flash")
	notification.AddLegacy(L"frozen_player", NOTIFY_GENERIC, 4)
end)

--## RAINBOW PHYSGUN ##--

function GAS.AdminPhysgun:RainbowPhysgunInit(enabled)
	GAS:untimer("adminphysgun:RainbowRefresh")
	GAS:untimer("adminphysgun:RainbowFilter")
	GAS:unhook("HUDPaint", "adminphysgun:Rainbow")

	if (not enabled) then
		for _,ply in ipairs(player.GetHumans()) do
			if (ply.GAS_OriginalPhysgunColor) then
				ply:SetWeaponColor(ply.GAS_OriginalPhysgunColor)
				ply.GAS_OriginalPhysgunColor = nil
			end
		end
	else
		local permitted = {}
		local filter = {}
		local active = false
		
		local function StartRainbowPhysgun()
			active = true
		
			local optimized = false
			local colVec = Vector()
			local fpsThreshold = 30
		
			GAS:hook("HUDPaint", "adminphysgun:Rainbow", function()
				if not HasFocus() then return end
		
				if 1 / FrameTime() < fpsThreshold then
					if not optimized then
						optimized = true
						for _, ply in ipairs(filter) do
							if IsValid(ply) and ply.GAS_OriginalPhysgunColor then
								SetWeaponColor(ply, ply.GAS_OriginalPhysgunColor)
								ply.GAS_OriginalPhysgunColor = nil
							end
						end
					end
					return
				else
					optimized = false
				end
		
				if #filter == 0 then return end
		
				local col = HSVToColor(CurTime() % 6 * 60, 1, 1)
				colVec.x = col.r / 255
				colVec.y = col.g / 255
				colVec.z = col.b / 255
		
				for _, ply in ipairs(filter) do
					if (not IsValid(ply) or IsDormant(ply)) then continue end
		
					local wep = GetActiveWeapon(ply)
					if (IsValid(wep) and GetClass(wep) == "weapon_physgun") then
						if (not ply.GAS_OriginalPhysgunColor) then
							ply.GAS_OriginalPhysgunColor = GetWeaponColor(ply)
						end
						SetWeaponColor(ply, colVec)
					elseif ply.GAS_OriginalPhysgunColor then
						SetWeaponColor(ply, ply.GAS_OriginalPhysgunColor)
						ply.GAS_OriginalPhysgunColor = nil
					end
				end
			end)
		end
		
		local function RainbowFilter()
			filter = {}
		
			local localPly = LocalPlayer()
			if IsValid(localPly) then
				local localPos = GetPos(localPly)
		
				for _, ply in ipairs(permitted) do
					if (not IsValid(ply) or IsDormant(ply)) then continue end
					
					if (ply ~= localPly and DistToSqr(GetPos(ply), localPos) > 500000) then continue end
		
					filter[#filter + 1] = ply
				end
			end
			
			if #permitted == 0 or #filter == 0 then
				if active then
					active = false
					hook.Remove("HUDPaint", "adminphysgun:Rainbow")
				end
				return
			end
		
			if not active then
				StartRainbowPhysgun()
			end
		end
		
		local function GetPermitted()
			local newPermitted = {}
			local permittedHashTable = {}
			for _,ply in ipairs(player.GetHumans()) do
				if (OpenPermissions:HasPermission(ply, "gmodadminsuite_adminphysgun/rainbow_physgun")) then
					newPermitted[#newPermitted + 1] = ply
					permittedHashTable[ply] = true
				end
			end
			for _,ply in ipairs(permitted) do
				if (IsValid(ply) and not permittedHashTable[ply] and ply.GAS_OriginalPhysgunColor) then
					SetWeaponColor(ply, ply.GAS_OriginalPhysgunColor)
					ply.GAS_OriginalPhysgunColor = nil
				end
			end
			permitted = newPermitted
			RainbowFilter()
		end
		GAS:timer("adminphysgun:RainbowFilter", 2, 0, RainbowFilter)
		GAS:timer("adminphysgun:RainbowRefresh", 120, 0, GetPermitted)
		GetPermitted()
	end
end
GAS:netReceive("adminphysgun:RainbowPhysgunInit", function()
	GAS.AdminPhysgun:RainbowPhysgunInit(net.ReadBool())
end)
GAS:InitPostEntity(function()
	GAS:netStart("adminphysgun:RainbowPhysgunInit")
	net.SendToServer()
end)

--## MENU ##--

GAS:hook("gmodadminsuite:ModuleSize:adminphysgun", "adminphysgun:framesize", function()
	return 450,495
end)

GAS:hook("gmodadminsuite:ModuleFrame:adminphysgun", "adminphysgun:menu", function(ModuleFrame)
	local LoadingPanel = vgui.Create("bVGUI.LoadingPanel", ModuleFrame)
	LoadingPanel:Dock(FILL)
	LoadingPanel:SetLoading(true)

	GAS:GetConfig("adminphysgun", function(config)
		if (not IsValid(ModuleFrame)) then return end
		LoadingPanel:SetLoading(false)

		local Permissions = vgui.Create("bVGUI.ButtonContainer", LoadingPanel)
		Permissions:Dock(TOP)
		Permissions:DockMargin(10,10,10,0)
		Permissions:SetTall(25)
		Permissions.Button:SetColor(bVGUI.BUTTON_COLOR_ORANGE)
		Permissions.Button:SetText(L"permissions")
		Permissions.Button:SetSize(150,25)
		function Permissions.Button:DoClick()
			GAS:PlaySound("flash")
			RunConsoleCommand("openpermissions", "gmodadminsuite_adminphysgun")
		end

		local PermissionsTip = vgui.Create("DLabel", LoadingPanel)
		PermissionsTip:Dock(TOP)
		PermissionsTip:DockMargin(10,10,10,10)
		PermissionsTip:SetContentAlignment(5)
		PermissionsTip:SetText(L"PermissionsTip")
		PermissionsTip:SetTextColor(bVGUI.COLOR_WHITE)
		PermissionsTip:SetFont(bVGUI.FONT(bVGUI.FONT_CIRCULAR, "REGULAR", 16))
		PermissionsTip:SetWrap(true)
		PermissionsTip:SetAutoStretchVertical(true)
		PermissionsTip:SizeToContents()

		local EnableRainbowPhysgun = vgui.Create("bVGUI.Switch", LoadingPanel)
		EnableRainbowPhysgun:Dock(TOP)
		EnableRainbowPhysgun:SetChecked(config.RainbowPhysgun)
		EnableRainbowPhysgun:SetText(L"EnableRainbowPhysgun")
		EnableRainbowPhysgun:DockMargin(10,10,10,0)
		function EnableRainbowPhysgun:OnChange()
			GAS:netStart("adminphysgun:SetSetting")
				net.WriteString("RainbowPhysgun")
				net.WriteBool(self:GetChecked())
			net.SendToServer()
		end

		local NegateFallDamage = vgui.Create("bVGUI.Switch", LoadingPanel)
		NegateFallDamage:Dock(TOP)
		NegateFallDamage:SetChecked(config.NegateFallDamage)
		NegateFallDamage:SetText(L"NegateFallDamage")
		NegateFallDamage:SetHelpText(L"NegateFallDamage_help")
		NegateFallDamage:DockMargin(10,10,10,0)
		function NegateFallDamage:OnChange()
			GAS:netStart("adminphysgun:SetSetting")
				net.WriteString("NegateFallDamage")
				net.WriteBool(self:GetChecked())
			net.SendToServer()
		end

		local QuickFreeze = vgui.Create("bVGUI.Switch", LoadingPanel)
		QuickFreeze:Dock(TOP)
		QuickFreeze:SetChecked(config.QuickFreeze)
		QuickFreeze:SetText(L"QuickFreeze")
		QuickFreeze:SetHelpText(L"QuickFreeze_help")
		QuickFreeze:DockMargin(10,10,10,0)
		function QuickFreeze:OnChange()
			GAS:netStart("adminphysgun:SetSetting")
				net.WriteString("QuickFreeze")
				net.WriteBool(self:GetChecked())
			net.SendToServer()
		end

		local StripWeapons = vgui.Create("bVGUI.Switch", LoadingPanel)
		StripWeapons:Dock(TOP)
		StripWeapons:SetChecked(config.StripWeapons)
		StripWeapons:SetText(L"StripWeapons")
		StripWeapons:SetHelpText(L"StripWeapons_help")
		StripWeapons:DockMargin(10,10,10,0)
		function StripWeapons:OnChange()
			GAS:netStart("adminphysgun:SetSetting")
				net.WriteString("StripWeapons")
				net.WriteBool(self:GetChecked())
			net.SendToServer()
		end

		local GodPickup = vgui.Create("bVGUI.Switch", LoadingPanel)
		GodPickup:Dock(TOP)
		GodPickup:SetChecked(config.GodPickup)
		GodPickup:SetText(L"GodPickup")
		GodPickup:SetHelpText(L"GodPickup_help")
		GodPickup:DockMargin(10,10,10,0)
		function GodPickup:OnChange()
			GAS:netStart("adminphysgun:SetSetting")
				net.WriteString("GodPickup")
				net.WriteBool(self:GetChecked())
			net.SendToServer()
		end

		local ResetVelocity = vgui.Create("bVGUI.Switch", LoadingPanel)
		ResetVelocity:Dock(TOP)
		ResetVelocity:SetChecked(config.ResetVelocity)
		ResetVelocity:SetText(L"ResetVelocity")
		ResetVelocity:SetHelpText(L"ResetVelocity_help")
		ResetVelocity:DockMargin(10,10,10,0)
		function ResetVelocity:OnChange()
			GAS:netStart("adminphysgun:SetSetting")
				net.WriteString("ResetVelocity")
				net.WriteBool(self:GetChecked())
			net.SendToServer()
		end
	end)
end)