local AdminMenus = {}

TOOL.Category = "Billy's Keypads"
TOOL.Name = "#tool.bkeypads_admin_tool.name"
TOOL.AddToMenu = false

if CLIENT then
	TOOL.Information = nil
	TOOL.Information = {
		{ name = "focus", icon = "gui/lmb.png", op = 0, stage = 0 },
		{ name = "unfocus", icon = "gui/rmb.png", op = 0, stage = 1 },
		{ name = "menu", icon = "gui/r.png", op = 0 }
	}
end

function TOOL:LeftClick(tr)
	if (SERVER or IsFirstTimePredicted()) and IsValid(tr.Entity) and tr.Entity.bKeypad then
		if IsValid(self.m_eFocusKeypad) and tr.Entity == self.m_eFocusKeypad then
			self.m_eFocusKeypad = nil
			self:SetStage(0)
		elseif bKeypads.Permissions:Check(self:GetOwner(), "tools/admin_tool") then
			self.m_eFocusKeypad = tr.Entity
			self:SetStage(1)
		else
			return false
		end
		return true
	end

	return false
end

function TOOL:RightClick(tr)
	if (SERVER or IsFirstTimePredicted()) and IsValid(self.m_eFocusKeypad) then
		self.m_eFocusKeypad = nil
		self:SetStage(0)
		return true
	end

	return false
end

function TOOL:Reload(tr)
	if CLIENT and not IsFirstTimePredicted() then return end
	if not bKeypads.Permissions:Check(self:GetOwner(), "tools/admin_tool") then
		return false
	elseif SERVER then
		return true
	end

	local keypad = (IsValid(tr.Entity) and tr.Entity.bKeypad == true and tr.Entity) or (IsValid(self.m_eFocusKeypad) and self.m_eFocusKeypad)
	if not IsValid(keypad) then return false end

	local L = bKeypads.L

	local AdminMenu = vgui.Create("DFrame")
	AdminMenus[keypad] = AdminMenu
	AdminMenu:SetIcon("icon16/shield.png")
	AdminMenu:SetTitle("Billy's Keypads - " .. L"AdminMenu")
	AdminMenu:SetSize(500, 600)
	AdminMenu:SetSizable(true)
	AdminMenu:MakePopup()

	AdminMenu:SetPos((ScrW() - AdminMenu:GetWide()) / 2, ScrH())

	local y = (ScrH() + AdminMenu:GetTall()) / 2
	AdminMenu:NewAnimation(1, 0, .5).Think = function(_, pnl, f)
		local f = bKeypads.ease.OutBack(f)

		local x = pnl:GetPos()
		pnl:SetPos(x, ScrH() - (y * f))

		pnl:SetAlpha(f * 255)
	end

	local Tabs = vgui.Create("DPropertySheet", AdminMenu)
	Tabs:Dock(FILL)

	--## Properties ##--

	local PropertiesPanel = vgui.Create("DPanel", Tabs)
	PropertiesPanel.Paint = nil

		keypad.m_pKeypadProperties = (IsValid(keypad.m_pKeypadProperties) and keypad.m_pKeypadProperties) or self:CreatePropertiesPanel(keypad)
		keypad.m_pKeypadProperties:SetAlpha(255)
		keypad.m_pKeypadProperties:Dock(FILL)
		keypad.m_pKeypadProperties:SetPaintedManually(false)
		keypad.m_pKeypadProperties:SetParent(PropertiesPanel)
		keypad.m_pKeypadProperties.PerformLayout = DProperties.PerformLayout
		keypad.m_pKeypadProperties.m_b3D2D = nil

	--## Access Matrix ##--

	local AccessMatrixPanel = vgui.Create("DPanel", Tabs)
	AccessMatrixPanel.Paint = nil

		local owner = keypad:GetKeypadOwner()

		if IsValid(owner) and owner:IsPlayer() then
			local OwnedBy = vgui.Create("DLabel", AccessMatrixPanel)
			OwnedBy:Dock(TOP)
			OwnedBy:DockMargin(0, 0, 0, 10)
			OwnedBy:SetFont("DermaDefaultBold")
			OwnedBy:SetTextColor(bKeypads.COLOR.WHITE)
			OwnedBy:SetContentAlignment(4)
			OwnedBy:SetText(bKeypads.L"OwnedBy")
			OwnedBy:SizeToContentsY()

			local CreatorRow = vgui.Create("DPanel", AccessMatrixPanel)
			CreatorRow:Dock(TOP)
			CreatorRow:SetTall(32)
			CreatorRow:DockMargin(0, 0, 0, 10)
			CreatorRow.OnMousePressed = function(self, m)
				if m == MOUSE_LEFT then
					self._m = true
				end
			end
			CreatorRow.OnMouseReleased = function(self, m)
				if m == MOUSE_LEFT and self._m then
					self._m = nil
					surface.PlaySound("garrysmod/balloon_pop_cute.wav")
					gui.OpenURL("https://steamcommunity.com/profiles/" .. owner:SteamID64())
				end
			end

			CreatorRow.Paint = nil

				local CreatorAvatar = vgui.Create("AvatarImage", CreatorRow)
				CreatorAvatar:Dock(LEFT)
				CreatorAvatar:SetWide(32)
				CreatorAvatar:DockMargin(0, 0, 10, 0)
				CreatorAvatar:SetSteamID(owner:SteamID64(), 64)
				CreatorAvatar:SetMouseInputEnabled(false)

				local CreatorName = vgui.Create("DLabel", CreatorRow)
				CreatorName:Dock(FILL)
				CreatorName:SetTextColor(bKeypads.COLOR.WHITE)
				CreatorName:SetContentAlignment(4)
				CreatorName:SetText(owner:Nick() .. "\n" .. owner:SteamID())
		end

		AccessMatrixPanel.AccessTable = vgui.Create("bKeypads.AccessMatrix", AccessMatrixPanel)
		AccessMatrixPanel.AccessTable.OnRowRightClick = bKeypads.noop
		AccessMatrixPanel.AccessTable:Dock(FILL)
		function AdminMenu:SetAccessMatrix(accessMatrix)
			AccessMatrixPanel.AccessTable.AccessMatrix = accessMatrix
			AccessMatrixPanel.AccessTable:Populate()
		end

	--## Access Logs ##--

	local AccessLogsPanel = vgui.Create("DPanel", Tabs)
	AccessLogsPanel.Paint = nil

		bKeypads.AccessLogs:OpenUI(keypad, false, AccessLogsPanel)

	--## Tabs ##--

	Tabs:AddSheet(L"Properties", PropertiesPanel, "icon16/application_view_gallery.png")
	Tabs:AddSheet(L"AccessTable", AccessMatrixPanel, "icon16/group_key.png")
	Tabs:AddSheet(L"AccessLogs", AccessLogsPanel, "icon16/chart_curve.png")

	AdminMenu.OnClose = function()
		if not IsValid(keypad) then return end

		AdminMenus[keypad] = nil
		if IsValid(keypad.m_pKeypadProperties) then
			keypad.m_pKeypadProperties:Dock(NODOCK)
			keypad.m_pKeypadProperties:SetPaintedManually(true)
			keypad.m_pKeypadProperties:SetParent(vgui.GetWorldPanel())
		end
	end

	net.Start("bKeypads.AdminTool.Fetch")
		net.WriteEntity(keypad)
	net.SendToServer()

	return true
end

function TOOL:Deploy()
	self:SetStage(0)
	self.m_eFocusKeypad = nil
end
function TOOL:Holster()
	self:SetStage(0)
	self.m_eFocusKeypad = nil
end

if CLIENT then
	function TOOL:Deployed()
		bKeypads.ESP:Activate()

		hook.Add("PostDrawTranslucentRenderables", "bKeypads.AdminTool.DrawProperties", self.DrawProperties)
	end

	function TOOL:Holstered()
		bKeypads.ESP:Deactivate()

		hook.Remove("PostDrawTranslucentRenderables", "bKeypads.AdminTool.DrawProperties")

		for _, keypad in ipairs(bKeypads.Keypads) do
			if not IsValid(keypad) then continue end

			if IsValid(keypad.m_pKeypadProperties) then
				keypad.m_pKeypadProperties:Remove()
			end
			keypad.m_pKeypadProperties = nil
		end
	end
end
bKeypads_Prediction(TOOL)

if CLIENT then
	function TOOL:GetFocusKeypad()
		if IsValid(self.m_eFocusKeypad) then
			return self.m_eFocusKeypad
		else
			local nearestDist, nearestX, nearestY, nearestKeypad = math.huge
			for _, keypad in ipairs(bKeypads.Keypads) do
				if not IsValid(keypad) then continue end

				local ScreenPos = keypad:LocalToWorld(keypad:OBBCenter()):ToScreen()
				if not ScreenPos.visible then continue end

				local dist3D = keypad:GetPos():DistToSqr(EyePos())

				local xDist = (ScrW() / 2) - ScreenPos.x
				local yDist = (ScrH() / 2) - ScreenPos.y
				local perceivedDist = (math.abs(xDist) + math.abs(yDist)) * dist3D
				if perceivedDist < nearestDist then
					nearestDist, nearestX, nearestY = perceivedDist, xDist, yDist
					nearestKeypad = keypad
				end
			end

			return nearestKeypad, nearestX, nearestY
		end
	end

	local gmod_toolmode

	function TOOL.BuildCPanel(CPanel)
		bKeypads:InjectSmoothScroll(CPanel)

		local L = bKeypads.L

		bKeypads:STOOLMatrix(CPanel)

		local Help = vgui.Create("DForm", CPanel)
			Help:SetExpanded(true)
			Help:SetLabel(L"Help")
			local label = Help:Help("#tool.bkeypads_admin_tool.help")
			label:GetParent():DockMargin(0, 0, 0, 8)
			label:DockMargin(0, 0, 0, 0)
		CPanel:AddItem(Help)

		hook.Run("bKeypads.BuildCPanel", CPanel)
	end
	bKeypads_AdminTool_BuildCPanel = TOOL.BuildCPanel

	local matAdminTool = Material("bkeypads/admin_tool")
	function TOOL:DrawToolScreen(w,h)
		surface.SetDrawColor(0,150,255)
		surface.DrawRect(0,0,w,h)

		if not self.Matrix then
			self.Matrix = bKeypads_Matrix("STOOL_Screen", w, h)
		end
		self.Matrix:Draw(w,h)

		surface.SetMaterial(matAdminTool)
		surface.DrawTexturedRect(0, 0, w, h)

		if not bKeypads.Permissions:Cached(LocalPlayer(), "tools/admin_tool") then
			bKeypads:ToolScreenNoPermission(w,h)
		end
	end

	local propertiesW, propertiesPadding, propertiesScale = 300, 25, 0.05

	local function propertiesH(keypad)
		return keypad.m_pKeypadProperties:GetTall()
	end

	local keypad_w, keypad_h
	local function FindDirection(keypad, ang, x, y, isBehind)
		local center = keypad:LocalToWorld(keypad:OBBCenter())

		local propertiesH = propertiesH(keypad)

		local origin, directionID

		if x and y then
			local mins, maxs = keypad:OBBMins(), keypad:OBBMaxs()

			if not keypad_w then
				keypad_w = (maxs.y - mins.y) / propertiesScale / 2
			end
			if not keypad_h then
				keypad_h = (maxs.z - mins.z) / propertiesScale / 2
			end

			if y >= keypad_h then
				--print("bottom")

				origin = center + (ang:Right() * (keypad_h + propertiesPadding) * propertiesScale)
				directionID = 0
			elseif y < -keypad_h then
				--print("top")

				origin = center - (ang:Right() * (keypad_h + propertiesPadding + propertiesH) * propertiesScale)
				directionID = 1
			elseif x * (isBehind and -1 or 1) >= keypad_w then
				--print("right")

				origin = center + (ang:Forward() * (keypad_w + propertiesPadding + (propertiesW * .5)) * propertiesScale) - (ang:Right() * propertiesH * .5 * propertiesScale)
				directionID = 2
			elseif x * (isBehind and -1 or 1) < -keypad_w then
				--print("left")

				origin = center - (ang:Forward() * (keypad_w + propertiesPadding + (propertiesW * .5)) * propertiesScale) - (ang:Right() * propertiesH * .5 * propertiesScale)
				directionID = 3
			end
		end

		if not origin then
			--print("center")

			origin = center - (ang:Right() * propertiesH * .5 * propertiesScale)
			directionID = 4
		end

		return origin, directionID
	end

	local UNSET = 42069
	local fadeAnimStart, slideAnimStart, slideAnimFrom
	local prevKeypad, prevDirectionID, prevOrigin = UNSET, UNSET
	local sizeChanges
	local function KeypadPropertiesPerformLayout(self, w, h)
		DProperties.PerformLayout(self, w, h)

		if self:GetCanvas():GetVBar():IsVisible() then
			self:GetCanvas():SizeToChildren(false, true)
			self:SizeToChildren(false, true)
		end

		if sizeChanges == nil then
			sizeChanges = true
		end
	end

	function TOOL.DrawProperties(bDrawingDepth, bDrawingSkybox)
		if bDrawingSkybox then return end
		if not bKeypads.Permissions:Cached(LocalPlayer(), "tools/admin_tool") then return end
		if render.GetRenderTarget() ~= nil then return end

		local self = LocalPlayer():GetTool("bkeypads_admin_tool")
		if not self then return end

		gmod_toolmode = gmod_toolmode or GetConVar("gmod_toolmode")

		local wep = LocalPlayer():GetActiveWeapon()
		if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" or gmod_toolmode:GetString() ~= "bkeypads_admin_tool" then
			self.LinkingKeypad = nil
			return
		end

		local nearestKeypad, nearestX, nearestY = self:GetFocusKeypad()
		if nearestKeypad ~= nil and halo.RenderedEntity() == nearestKeypad then return end

		self.LinkingKeypad = nearestKeypad

		if nearestKeypad ~= prevKeypad then
			slideAnimStart = SysTime()
			prevDirectionID = nil
			if prevKeypad ~= UNSET then
				sizeChanges = false
			end
		end

		if nearestKeypad then
			local keypad = nearestKeypad

			keypad.m_pKeypadProperties = bKeypads.Properties:Update(keypad)

			local isInWorldSpace = keypad.m_pKeypadProperties:GetParent() == vgui.GetWorldPanel()
			if isInWorldSpace then
				keypad.m_pKeypadProperties.PerformLayout = KeypadPropertiesPerformLayout

				bKeypads.cam.IgnoreZ(true)

					local isBehind = keypad:IsPlayerBehind(LocalPlayer())

					local ang = keypad:GetAngles()
					ang:RotateAroundAxis(keypad:GetUp(), 90)
					ang:RotateAroundAxis(keypad:GetRight(), -90)
					if keypad:GetBroken() and keypad.HackedAngle then
						ang:RotateAroundAxis(keypad:GetRight(), -keypad.HackedAngle)
						ang:RotateAroundAxis(keypad:GetForward(), -keypad.HackedAngle)
					end

					local origin, directionID = FindDirection(keypad, ang, nearestX, nearestY, isBehind)

					if IsValid(self.m_eFocusKeypad) and IsValid(keypad.m_pKeypadProperties) then
						local viewDelta = (keypad:GetPos() - EyePos()):Angle() - keypad:GetAngles()
						ang:RotateAroundAxis(ang:Right(), -viewDelta.y - 180)
					elseif isBehind then
						ang:RotateAroundAxis(ang:Right(), 180)
					end

					origin = origin - (ang:Forward() * propertiesW * .5 * propertiesScale)

					local slideAnimFrac = 1
					fadeAnimStart = fadeAnimStart or SysTime()

					if bKeypads.Performance:Optimizing() then
						keypad.m_pKeypadProperties:SetAlpha(255)

						prevOrigin = origin
					else

						local fadeAnimFrac = bKeypads.ease.OutQuint(math.min(math.TimeFraction(fadeAnimStart, fadeAnimStart + 1, SysTime()), 1))
						keypad.m_pKeypadProperties:SetAlpha(255 * fadeAnimFrac)

						if directionID ~= prevDirectionID or not slideAnimFrom then
							slideAnimStart = SysTime()
							slideAnimFrom = prevOrigin or origin
						end

						slideAnimFrac = bKeypads.ease.OutQuint(math.min(math.TimeFraction(slideAnimStart, slideAnimStart + 1, SysTime()), 1))
						if sizeChanges then
							if keypad == prevKeypad then
								slideAnimFrom = origin
								sizeChanges = nil
							else
								sizeChanges = false
							end
						end

						prevOrigin = LerpVector(slideAnimFrac, slideAnimFrom, origin)
					end

					cam.Start3D2D(prevOrigin, ang, propertiesScale)
						keypad.m_pKeypadProperties:PaintManual()
					cam.End3D2D()

					prevDirectionID = directionID

				bKeypads.cam.IgnoreZ(false)

				if directionID == 4 or slideAnimFrac ~= 1 then
					render.SetBlend(.25)
					surface.SetAlphaMultiplier(0)
						keypad:DrawModel()
					surface.SetAlphaMultiplier(1)
				end
			end
		end

		prevKeypad = nearestKeypad
	end

	if hook.GetTable()["PostDrawTranslucentRenderables"] and hook.GetTable()["PostDrawTranslucentRenderables"]["bKeypads.AdminTool.DrawProperties"] then
		hook.Remove("PostDrawTranslucentRenderables", "bKeypads.AdminTool.DrawProperties")
		hook.Add("PostDrawTranslucentRenderables", "bKeypads.AdminTool.DrawProperties", TOOL.DrawProperties)
	end
end

if SERVER then
	util.AddNetworkString("bKeypads.AdminTool.Fetch")

	net.Receive("bKeypads.AdminTool.Fetch", function(_, ply)
		local keypad = net.ReadEntity()
		if not bKeypads.Permissions:Check(ply, "tools/admin_tool") or not IsValid(keypad) then return end

		net.Start("bKeypads.AdminTool.Fetch")
			net.WriteEntity(keypad)
			bKeypads.KeypadData.Net:Serialize(keypad.AccessMatrix or bKeypads.KeypadData:AccessMatrix())
		net.Send(ply)
	end)
else
	net.Receive("bKeypads.AdminTool.Fetch", function(_, ply)
		local keypad = net.ReadEntity()
		if not IsValid(keypad) or not IsValid(AdminMenus[keypad]) then return end

		local accessMatrix = bKeypads.KeypadData.Net:Deserialize()
		AdminMenus[keypad]:SetAccessMatrix(accessMatrix)
	end)
end