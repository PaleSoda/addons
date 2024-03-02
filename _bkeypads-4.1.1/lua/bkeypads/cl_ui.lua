local L = bKeypads.L

bKeypads.phi = (1 + math.sqrt(5)) / 2

bKeypads.Emotes = {
	["default"]   = Material("bkeypads/face_id.png"),
	["sad"]       = Material("bkeypads/face_id_sad.png"),
	["success"]   = Material("bkeypads/face_id_success.png"),
	["surprised"] = Material("bkeypads/face_id_surprised.png"),
	["angry"]     = Material("bkeypads/face_id_angry.png"),
	["evil"]      = Material("bkeypads/face_id_evil.png"),
	["neutral"]   = Material("bkeypads/face_id_neutral.png"),
	["happy"]     = Material("bkeypads/face_id_happy.png"),
	["sorry"]     = Material("bkeypads/face_id_sorry.png"),
	["shocked"]   = Material("bkeypads/face_id_shocked.png"),
	["confused"]  = Material("bkeypads/face_id_confused.png"),
}

bKeypads.EmoteList = table.GetKeys(bKeypads.Emotes)
bKeypads.Sunglasses = Material("bkeypads/face_id_sunglasses.png")

-- https://wiki.facepunch.com/gmod/Entity:GetAttachment example 2
function bKeypads:TranslateViewModelPosition(nFOV, pos)
	local vEyePos = EyePos()
	local aEyesRot = EyeAngles()

	local vOffset = pos - vEyePos
	local nViewX = math.tan(nFOV * math.pi / 360)
	local nWorldX = math.tan(LocalPlayer():GetFOV() * math.pi / 360)

	local vForward = aEyesRot:Forward()
	local vRight = aEyesRot:Right()
	local vUp = aEyesRot:Up()

	local nFactor = nViewX / nWorldX

	vRight:Mul(vRight:Dot(vOffset) * nFactor)
	vUp:Mul(vUp:Dot(vOffset) * nFactor)
	vForward:Mul(vForward:Dot(vOffset))

	vEyePos:Add(vRight)
	vEyePos:Add(vUp)
	vEyePos:Add(vForward)

	return vEyePos
end

do
	bKeypads.cam = bKeypads.cam or {}

	local IgnoreZ = false
	function bKeypads.cam.IgnoreZ(m_bIgnoreZ)
		local prev = IgnoreZ
		IgnoreZ = m_bIgnoreZ

		cam.IgnoreZ(m_bIgnoreZ)

		return prev
	end
end

do
	local du = 0.5 / 32
	local dv = 0.5 / 32
	local u0, v0 = (0 - du) / (1 - 2 * du), (0 - dv) / (1 - 2 * dv)
	local u1, v1 = (1 - du) / (1 - 2 * du), (1 - dv) / (1 - 2 * dv)
	function bKeypads:DrawSubpixelClippedMaterial(mat, x, y, w, h)
		surface.SetMaterial(mat)
		if system.IsOSX() then
			surface.DrawTexturedRect(x, y, w, h)
		else
			surface.DrawTexturedRectUV(x, y, w, h, u0, v0, u1, v1)
		end
	end
end

function bKeypads:LerpUnclamped(t, from, to)
	return from + (to - from) * t
end

function bKeypads:Rainbow(i)
	local optimizing = bKeypads.Performance:Optimizing()
	local r = math.sin(i + 0) * 127 + 128
	local g = math.sin(i + (optimizing and 2 or (2 * math.pi / 3))) * 127 + 128
	local b = math.sin(i + (optimizing and 4 or (4 * math.pi / 3))) * 127 + 128
	return r, g, b
end

function bKeypads:IntToColor(int)
	local b = int % 256
	local g = ((int - b) / 256) % 256
	local r = ((int - b) / 65536) - g / 256
	return Color(r,g,b)
end

function bKeypads:GetLuminance(col)
	return (0.699 * col.r + 0.587 * col.g + 0.05 * col.b) / 255
end
function bKeypads:DarkenForeground(col)
	return bKeypads:GetLuminance(col) >= 0.28
end

local shieldIcon = Material("icon16/shield.png")
local function PaintShield(self, w, h)
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(shieldIcon)
	surface.DrawTexturedRect((w - 16) / 2, (h - 16) / 2, 16, 16)
end
function bKeypads:AddShieldIcon(pnl)
	if pnl:GetClassName() == "Panel" and IsValid(pnl.Button) then
		pnl.Button:Dock(LEFT)

		local ShieldIcon = vgui.Create("DImage", pnl)
		ShieldIcon:Dock(LEFT)
		ShieldIcon:DockMargin(5, 0, 5, 0)
		ShieldIcon:SetSize(16, 16)
		ShieldIcon:SetImage("icon16/shield.png")

		pnl.Label:Dock(FILL)
	elseif pnl:GetClassName() == "TextEntry" then
		local ShieldIcon = vgui.Create("DPanel", pnl:GetParent())
		ShieldIcon.Paint = PaintShield
		ShieldIcon:Dock(LEFT)
		ShieldIcon:DockMargin(0, 0, 5, 0)
		ShieldIcon:SetSize(16, 16)
		ShieldIcon:MoveToBack()
	end
end

function bKeypads:AddHelp(form, strHelp)
	local left = vgui.Create("bKeypads.WrapLabel", form)
	left:SetDark(true)
	left:SetTextInset(0, 0)
	left:SetText(strHelp)
	left:DockMargin(8, 0, 8, 8)

	form:AddItem(left, nil)

	left:InvalidateLayout(true)

	return left
end

do
	local function CPanel_AddItem(self, left, right)
		self:bKeypads_AddItem(left, right)
		if IsValid(self.Items[#self.Items]) then
			self.Items[#self.Items]:SetParent(self.SmoothScroll)
			self.SmoothScroll:InvalidateLayout()
		end
	end
	local function CPanel_PerformLayout(self, w, h)
		self:Dock(FILL)
		if IsValid(self:GetParent()) then
			self:GetParent():Dock(FILL)
		end
		if self.bKeypads_PerformLayout then
			return self:bKeypads_PerformLayout(self, w, h)
		end
	end
	function bKeypads:InjectSmoothScroll(CPanel)
		CPanel.bKeypads_AddItem = CPanel.bKeypads_AddItem or CPanel.AddItem
		CPanel.bKeypads_PerformLayout = CPanel.bKeypads_PerformLayout or CPanel.PerformLayout
		CPanel.AddItem = CPanel_AddItem
		CPanel.PerformLayout = CPanel_PerformLayout

		CPanel.SmoothScroll = vgui.Create("bKeypads.SmoothScroll", CPanel)
		CPanel.SmoothScroll:Dock(FILL)
	end
end

--## TV Animation ##--

function bKeypads:TVAnimation(animEnt, duration, w, h, reverse, x, y, easeFunc)
	if animEnt.m_bTVAnimationPushed then
		animEnt.m_bTVAnimationPushed = nil
		cam.PopModelMatrix()
		return
	end
	if not duration then return end

	if not animEnt.m_tTVAnimation then
		animEnt.m_tTVAnimation = {
			Start = CurTime(),
			Matrix = Matrix()
		}
	end

	local verticalFrac = math.Clamp(math.TimeFraction(animEnt.m_tTVAnimation.Start + (duration / 2), animEnt.m_tTVAnimation.Start + duration, CurTime()), 0, 1)
	if reverse then
		verticalFrac = 1 - verticalFrac
		if verticalFrac == 0 then
			animEnt.m_bTVAnimation = nil
			return true
		end
	else
		if verticalFrac == 1 then
			animEnt.m_bTVAnimation = nil
			return true
		end
	end

	local horizontalFrac = math.Clamp(math.TimeFraction(animEnt.m_tTVAnimation.Start, animEnt.m_tTVAnimation.Start + (duration / 2), CurTime()), 0, 1) if reverse then horizontalFrac = 1 - horizontalFrac end

	if easeFunc then
		verticalFrac = easeFunc(verticalFrac)
		horizontalFrac = easeFunc(horizontalFrac)
	end

	local verticalScalar = math.max(verticalFrac, 0.05)
	local horizontalScalar = math.max(horizontalFrac, 0.05)

	local verticalTranslation = (h / 2) * (1 - verticalScalar) + ((y or 0) * (1 - verticalScalar))
	local horizontalTranslation = ((w / 2) * (1 - horizontalScalar)) + ((x or 0) * (1 - horizontalScalar))

	animEnt.m_tTVAnimation.Matrix:SetUnpacked(
		horizontalScalar, 0, 0, horizontalTranslation,
		0, verticalScalar, 0, verticalTranslation,
		0, 0, 0, 0,
		0, 0, 0, 1
	)

	cam.PushModelMatrix(animEnt.m_tTVAnimation.Matrix, true)
	animEnt.m_bTVAnimationPushed = true
	animEnt.m_bTVAnimation = true
end

do
	local LogoWhite = Material("bkeypads/logo_wide_white.png", "smooth")
	local function MatrixPaintOver(self, w, h)
		local logo_w = math.min(w - 40, 264)
		local logo_h = math.min(logo_w * (128 / 335), 100)
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(LogoWhite)
		surface.DrawTexturedRect((w - logo_w) / 2, (h - logo_h) / 2, logo_w, logo_h)
	end

	local function MatrixPerformLayout(self, w, h)
		self.Settings:AlignTop(5)
		self.Settings:AlignRight(5)
	end

	local function MatrixOnMousePressed(self,m)
		self._m = m
	end
	local function MatrixOnMouseReleased(self,m)
		if self._m == m and m == MOUSE_LEFT then
			gui.OpenURL("https://gmodstore.com/market/view/billys-keypads")
			surface.PlaySound("garrysmod/balloon_pop_cute.wav")
			self._m = nil
		end
	end

	function bKeypads:OpenSettings()
		for k, v in pairs(g_SpawnMenu:GetToolMenu().Items) do
			if v.Name ~= "Options" then continue end
			v.Tab:DoClick()
			for k, v in pairs(v.Panel.List.pnlCanvas:GetChildren()) do
				if v.Header:GetValue() ~= "Billy's Keypads" then continue end
				local btn = v:Find("DButton")
				btn:DoClick()
				btn:DoClickInternal()
				return
			end
			return
		end
	end

	function bKeypads:STOOLMatrix(CPanel, showCog)
		CPanel.Matrix = vgui.Create("bKeypads.Matrix", CPanel)
		CPanel.Matrix:SetTall(128)
		CPanel.Matrix:SetMatrixID("STOOL")
		CPanel.Matrix:SetBGColor(Color(0,150,255))
		CPanel.Matrix.PaintOver = MatrixPaintOver
		CPanel.Matrix:SetCursor("hand")
		CPanel.Matrix.OnMousePressed = MatrixOnMousePressed
		CPanel.Matrix.OnMouseReleased = MatrixOnMouseReleased
		CPanel:AddItem(CPanel.Matrix)

		if showCog ~= false then
			CPanel.Matrix.PerformLayout = MatrixPerformLayout

			CPanel.Matrix.Settings = vgui.Create("DImageButton", CPanel.Matrix)
			CPanel.Matrix.Settings:SetSize(16, 16)
			CPanel.Matrix.Settings:SetImage("icon16/cog.png")
			CPanel.Matrix.Settings.DoClick = bKeypads.OpenSettings
		end
	end
end

do
	local RoundedBoxColor = Color(26,26,26,225)

	local RTTexture = GetRenderTarget("GModToolgunScreen", 256, 256)

	local matWarning = CreateMaterial("bKeypads.ToolScreenNoPermissionx", "UnlitGeneric", {
		["$basetexture"] = "icon16/error.png",
		["$ignorez"] = "1",
		["$vertexalpha"] = "1",
		["$translucent"] = "1"
	})

	local TextMarkups = {}
	local _w, _h
	function bKeypads:ToolScreenWarning(text, w, h)
		render.BlurRenderTarget(RTTexture, 7, 4, 7)

		local TextMarkup = TextMarkups[text]
		if not TextMarkup or _w ~= w or _h ~= h then
			_w, _h = w, h
			TextMarkups[text] = bKeypads.markup.Parse("<font=bKeypads.ToolScreenNoPermission>" .. bKeypads.markup.Escape(text) .. "</font>", (w * .85) - 20)
			TextMarkup = TextMarkups[text]
		end

		local x,y = (w - (w * .85)) / 2, (h - (TextMarkup:GetHeight() + 20) + 32 + 10) / 2

		RoundedBoxColor.r = Lerp(math.Remap(math.cos(SysTime() * 2 * math.pi), -1, 1, 0, 1), 26, 255)
		draw.RoundedBox(5, x, y, w * .85, TextMarkup:GetHeight() + 20, RoundedBoxColor)

		TextMarkup:Draw(x + 10, y + 10, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 255, TEXT_ALIGN_CENTER)

		surface.SetMaterial(matWarning)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect((w - 32) / 2, y - 32 - 15, 32, 32)
	end

	function bKeypads:ToolScreenNoPermission(w,h)
		return bKeypads:ToolScreenWarning(bKeypads.L("ToolScreenNoPermission"), w, h)
	end

	function bKeypads:ToolScreenNoPermissionEnt(w,h)
		return bKeypads:ToolScreenWarning(bKeypads.L("ToolScreenNoPermissionEnt"), w, h)
	end
end

do
	local function DermaMenuOption_ColorPaint(self,w,h)
		surface.SetDrawColor(self.DermaMenuOption_Color)
		surface.DrawRect(0,0,w,h)
	end
	bKeypads.DermaMenuOption_Color = function(option, color)
		option:SetIcon("icon16/box.png")
		option.m_Image.DermaMenuOption_Color = color
		option.m_Image.Paint = DermaMenuOption_ColorPaint
	end
end

do
	local padding = 20
	function bKeypads:CreateTooltipFont()
		local size = bKeypads.Settings:Get("tooltip_text_size")

		local dyslexia = bKeypads.Settings:Get("dyslexia")
		local dyslexia_weight = dyslexia and 700 or nil
		size = dyslexia and math.max(size, 20) or size

		surface.CreateFont("bKeypads.Tooltip", {
			font = dyslexia and "Comic Sans MS" or "Verdana",
			size = size,
			shadow = true,
			weight = dyslexia_weight
		})

		padding = math.min(math.floor(size * (20 / 14)), 20)
	end
	bKeypads:CreateTooltipFont()

	local BGColor = Color(0, 0, 0, 240)

	hook.Add("DrawOverlay", "bKeypads.Tooltip", function()
		local hovered = vgui.GetHoveredPanel()
		if not IsValid(hovered) or not hovered.bKeypads_Tooltip or (hovered.IsEnabled and not hovered:IsEnabled()) then return end

		local mX, mY = gui.MousePos()
		local text = hovered.bKeypads_Tooltip

		surface.SetFont("bKeypads.Tooltip")
		local w, h = surface.GetTextSize(text)
		local bgW, bgH = w + padding, h + (padding / 2)
		local x, y = math.Clamp(mX - (bgW / 2), 0, ScrW() - bgW), math.Clamp(mY + 20 + 5, 0, ScrH() - bgH)

		draw.RoundedBox(4, x, y, bgW, bgH, BGColor)

		draw.DrawText(text, "bKeypads.Tooltip", x + (padding / 2) + (w / 2), y + (padding / 2 / 2), bKeypads.COLOR.WHITE, TEXT_ALIGN_CENTER)
	end)

	function bKeypads:RecursiveTooltip(tooltip, ...)
		for _, pnl in ipairs({...}) do
			pnl.bKeypads_Tooltip = tooltip
			for _, c in ipairs(pnl:GetChildren()) do
				if not IsValid(c) then continue end
				bKeypads:RecursiveTooltip(tooltip, c)
			end
		end
		return ...
	end
end

local function NodeColorPaint(self,w,h)
	surface.SetDrawColor(self.NodeColor)
	surface.DrawRect(0,0,w,h)
end

do
	local function AvatarImageNode(node, steamid64)
		node.Icon.Paint = nil
		node.Icon.AvatarImage = vgui.Create("AvatarImage", node.Icon)
		node.Icon.AvatarImage:Dock(FILL)
		node.Icon.AvatarImage:SetSteamID(steamid64, 32)
	end

	local function AvatarImageLine(line, steamid64)
		line.AvatarImage = vgui.Create("AvatarImage", line)
		line.AvatarImage:SetSize(17,17)
		line.AvatarImage:SetSteamID(steamid64, 32)
	end

	local function OnNodeSelected(self, node)
		if not node.SteamID64 then
			node:SetExpanded(not node.m_bExpanded)
			node:SetSelected(false)
		end
	end

	bKeypads.PlayerSelector = {}

	do
		local function serialize(f)
			for steamid64, data in pairs(bKeypads.PlayerSelector.Recent) do
				f:Write(steamid64)
				f:WriteULong(data[1])
				if isstring(data[2]) then
					f:WriteByte(#data[2])
					f:Write(data[2])
				else
					f:WriteByte(0)
				end
			end

			bKeypads.KeypadData.File:Close("bkeypads/player_selector_recent.dat", "DATA")
		end
		function bKeypads.PlayerSelector:SerializeRecent()
			local succ = pcall(serialize, bKeypads.KeypadData.File:Open("bkeypads/player_selector_recent.dat", true, "DATA"))
			return succ
		end
	end

	do
		local function deserialize(f)
			local deserialized = {}

			while (f:Tell() < f:Size()) do
				local steamid64, last_seen, nick = f:Read(17), f:ReadULong(), f:Read(f:ReadByte())
				deserialized[steamid64] = {last_seen, nick and #nick > 0 and nick or nil}
				if not deserialized[steamid64][2] then
					steamworks.RequestPlayerInfo(steamid64)
				end
			end

			bKeypads.KeypadData.File:Close("bkeypads/player_selector_recent.dat", "DATA")

			return deserialized
		end
		function bKeypads.PlayerSelector:DeserializeRecent()
			local succ, deserialized = pcall(deserialize, bKeypads.KeypadData.File:Open("bkeypads/player_selector_recent.dat", false, "DATA"))
			if succ then
				return deserialized
			end
		end
	end

	bKeypads.PlayerSelector.Recent = {}
	if file.Exists("bkeypads/player_selector_recent.dat", "DATA") then
		bKeypads.PlayerSelector.Recent = bKeypads.PlayerSelector:DeserializeRecent()
		if not bKeypads.PlayerSelector.Recent then
			bKeypads.PlayerSelector.Recent = {}
			file.Delete("bkeypads/player_selector_recent.dat")
		end
	end

	function bKeypads.PlayerSelector:LookupName(steamid64)
		if bKeypads.PlayerSelector.Recent[steamid64] and bKeypads.PlayerSelector.Recent[steamid64][2] then
			return bKeypads.PlayerSelector.Recent[steamid64] and bKeypads.PlayerSelector.Recent[steamid64][2]
		else
			local steamName = steamworks.GetPlayerName(steamid64)
			if steamName == "[unknown]" or #steamName == 0 then
				steamworks.RequestPlayerInfo(steamid64)
				return nil
			else
				return steamName
			end
		end
	end

	function bKeypads.PlayerSelector:Open(callback)
		if IsValid(self.UI) then
			self.UI:Close()
		end

		local SelectedPlayers = {}

		local function PlayerNodeMouseDown(self)
			self:GetParent():SetSelected(true)
			self.m_mDown = true
		end
		local function PlayerNodeMouseUp(nodeBtn)
			local node = nodeBtn:GetParent()
			if nodeBtn.m_mDown then
				SelectedPlayers[node.SteamID64] = node.Nick
				self.UI.List.Players:Refresh()
			end
			node:SetSelected(false)
			nodeBtn.m_mDown = nil
		end
		local function PlayerNodeClickBind(node)
			node.Label.OnMousePressed = PlayerNodeMouseDown
			node.Label.OnMouseReleased = PlayerNodeMouseUp
		end

		self.UI = vgui.Create("DFrame")
		self.UI:SetDrawOnTop(true)
		self.UI:SetSize(700,500)
		self.UI:SetTitle("Billy's Keypads - " .. L"PlayersSelector")
		self.UI:SetIcon("icon16/group.png")
		self.UI:Center()
		self.UI:MakePopup()
		self.UI:DockPadding(10, 24 + 10, 10, 10)
		self.UI:MoveToFront()
		self.UI:DoModal()
		self.UI.OnClose = function()
			callback({})
			bKeypads.PlayerSelector.UI = nil
		end

		self.UI.List = vgui.Create("DPanel", self.UI)
		self.UI.List:Dock(RIGHT)
		self.UI.List:DockMargin(10,0,0,0)
		self.UI.List:SetWide(350)
		self.UI.List.Paint = nil

			self.UI.List.Done = vgui.Create("DButton", self.UI.List)
			self.UI.List.Done:Dock(TOP)
			self.UI.List.Done:DockMargin(0,0,0,10)
			self.UI.List.Done:SetTall(25)
			self.UI.List.Done:SetText(L"Done")
			self.UI.List.Done:SetIcon("icon16/accept.png")
			self.UI.List.Done:SetDisabled(true)
			self.UI.List.Done.DoClick = function()
				for steamid64, nick in pairs(SelectedPlayers) do
					bKeypads.PlayerSelector.Recent[steamid64] = {os.time(), nick}
				end
				bKeypads.PlayerSelector:SerializeRecent()

				callback(SelectedPlayers)
				self.UI:Close()
				bKeypads.PlayerSelector.UI = nil

				surface.PlaySound("garrysmod/save_load2.wav")
			end

			self.UI.List.Players = vgui.Create("DListView", self.UI.List)
			self.UI.List.Players:Dock(FILL)
			self.UI.List.Players:DockMargin(0,0,0,5)
			local col = self.UI.List.Players:AddColumn("") col:SetMaxWidth(17) col:SetMinWidth(17)
			self.UI.List.Players:AddColumn(L"Name")
			self.UI.List.Players:AddColumn("SteamID")
			self.UI.List.Players:SetMultiSelect(false)
			self.UI.List.Players.OnRowSelected = function(_, lineID, line)
				if input.IsMouseDown(MOUSE_RIGHT) then return end

				surface.PlaySound("garrysmod/ui_return.wav")

				local DMenu = DermaMenu(nil, self.UI)

					DMenu:AddOption(L"ViewProfile", function()
						surface.PlaySound("garrysmod/balloon_pop_cute.wav")
						gui.OpenURL("https://steamcommunity.com/profiles/" .. line.SteamID64)
					end):SetIcon("icon16/page_copy.png")

					DMenu:AddOption(L"CopySteamID", function()
						if GAS then
							GAS:SetClipboardText(util.SteamIDFrom64(line.SteamID64))
						else
							surface.PlaySound("garrysmod/content_downloaded.wav")
							SetClipboardText(util.SteamIDFrom64(line.SteamID64))
						end
					end):SetIcon("icon16/page_copy.png")

					DMenu:AddOption(L"CopySteamID64", function()
						if GAS then
							GAS:SetClipboardText(line.SteamID64)
						else
							surface.PlaySound("garrysmod/content_downloaded.wav")
							SetClipboardText(line.SteamID64)
						end
					end):SetIcon("icon16/page_copy.png")

					DMenu:AddOption(L"Remove", function()
						self.UI.List.Players.OnRowRightClick(_, lineID, line)
					end):SetIcon("icon16/delete.png")

				DMenu:Open()
			end
			self.UI.List.Players.OnRowRightClick = function(_, lineID, line)
				SelectedPlayers[line.SteamID64] = nil
				self.UI.List.Players:RemoveLine(lineID)
				self.UI.List.Done:SetDisabled(table.IsEmpty(SelectedPlayers))
				surface.PlaySound("friends/friend_join.wav")
			end
			self.UI.List.Players.Refresh = function()
				local prevLines = #self.UI.List.Players:GetLines()

				self.UI.List.Players:Clear()
				self.UI.List.Done:SetDisabled(true)
				for steamid64, nick in SortedPairsByValue(SelectedPlayers) do
					self.UI.List.Done:SetDisabled(false)
					local line = self.UI.List.Players:AddLine("", nick == 0 and L"Unknown" or nick == 1 and L"LoadingEllipsis" or nick or L"Unknown", util.SteamIDFrom64(steamid64))
					line.SteamID64 = steamid64
					AvatarImageLine(line, steamid64)
				end

				if #self.UI.List.Players:GetLines() > prevLines then
					surface.PlaySound("garrysmod/ui_click.wav")
				end
			end

			self.UI.List.SteamIDFinder = vgui.Create("DButton", self.UI.List)
			self.UI.List.SteamIDFinder:SetText(L"SteamIDFinder")
			self.UI.List.SteamIDFinder:SetIcon("icon16/world.png")
			self.UI.List.SteamIDFinder:Dock(BOTTOM)
			self.UI.List.SteamIDFinder:SetTall(25)
			self.UI.List.SteamIDFinder.DoClick = function()
				surface.PlaySound("garrysmod/balloon_pop_cute.wav")
				gui.OpenURL("https://steamid.uk")
			end

			self.UI.List.ManualSteamID = vgui.Create("DPanel", self.UI.List)
			self.UI.List.ManualSteamID.Paint = nil
			self.UI.List.ManualSteamID:Dock(BOTTOM)
			self.UI.List.ManualSteamID:DockMargin(0,0,0,5)
			self.UI.List.ManualSteamID:SetTall(25)

				self.UI.List.ManualSteamID.TextEntry = vgui.Create("DTextEntry", self.UI.List.ManualSteamID)
				self.UI.List.ManualSteamID.TextEntry:DockMargin(0,0,-1,0)
				self.UI.List.ManualSteamID.TextEntry:Dock(FILL)
				self.UI.List.ManualSteamID.TextEntry:SetPlaceholderText(L"ManualSteamID")

				self.UI.List.ManualSteamID.Add = vgui.Create("DButton", self.UI.List.ManualSteamID)
				self.UI.List.ManualSteamID.Add:Dock(RIGHT)
				self.UI.List.ManualSteamID.Add:SetSize(25,25)
				self.UI.List.ManualSteamID.Add:SetText("+")
				local SteamworksTimeoutTimers = {}
				self.UI.List.ManualSteamID.Add.OnRemove = function()
					for steamid64 in pairs(SteamworksTimeoutTimers) do
						timer.Remove("bKeypads.PlayerSelector.ManualSteamID.SteamworksTimeout:" .. steamid64)
					end
				end

				local textInput
				self.UI.List.ManualSteamID.Add.Parsed = function(_, steamid64, requestTextInput)
					if not IsValid(self.UI) or (requestTextInput ~= nil and requestTextInput ~= textInput) then return end

					local ply = bKeypads.player.GetBySteamID64(steamid64)

					local nick = IsValid(ply) and ply:Nick() or 1

					SelectedPlayers[steamid64] = nick
					self.UI.List.Players:Refresh()

					if nick == 1 then
						SteamworksTimeoutTimers[steamid64] = true
						timer.Create("bKeypads.PlayerSelector.ManualSteamID.SteamworksTimeout:" .. steamid64, 5, 1, function()
							if not IsValid(self.UI) then return end
							SteamworksTimeoutTimers[steamid64] = nil
							if SelectedPlayers[steamid64] then
								local nick = steamworks.GetPlayerName(steamid64)
								if #nick > 0 and nick ~= "[unknown]" then
									SelectedPlayers[steamid64] = nick
								else
									SelectedPlayers[steamid64] = 0
								end
								self.UI.List.Players:Refresh()
							end
						end)
						steamworks.RequestPlayerInfo(steamid64, function(steamName)
							if not IsValid(self.UI) then return end
							timer.Remove("bKeypads.PlayerSelector.ManualSteamID.SteamworksTimeout:" .. steamid64)
							SteamworksTimeoutTimers[steamid64] = nil
							if SelectedPlayers[steamid64] then
								SelectedPlayers[steamid64] = steamName or 0
								self.UI.List.Players:Refresh()
							end
						end)
					end

					self.UI.List.ManualSteamID.TextEntry:SetValue("")
					self.UI.List.ManualSteamID.Add:SetDisabled(false)
					self.UI.List.ManualSteamID.TextEntry:SetDisabled(false)
				end

				self.UI.List.ManualSteamID.Add.Error = function(_, txt)
					surface.PlaySound("buttons/button2.wav")
					Derma_Message(txt, L"PlayersSelector", L"Dismiss")
					self.UI.List.ManualSteamID.Add:SetDisabled(false)
					self.UI.List.ManualSteamID.TextEntry:SetDisabled(false)
				end

				self.UI.List.ManualSteamID.Add.DoClick = function()
					textInput = string.Trim(self.UI.List.ManualSteamID.TextEntry:GetValue())
					if #textInput == 0 then return end

					self.UI.List.ManualSteamID.Add:SetDisabled(true)
					self.UI.List.ManualSteamID.TextEntry:SetDisabled(true)

					if textInput:upper():match("^STEAM_%d:%d+:%d+$") then
						return self.UI.List.ManualSteamID.Add:Parsed(util.SteamIDTo64(textInput:upper()))
					elseif textInput:match("^7656119%d+$") then
						return self.UI.List.ManualSteamID.Add:Parsed(textInput)
					else
						local url = textInput:lower()
						if (
							url:match("^http://steamcommunity.com/") or
							url:match("^https://steamcommunity.com/") or
							url:match("^http://www.steamcommunity.com/") or
							url:match("^https://www.steamcommunity.com/") or
							url:match("^steamcommunity%.com/")
						) then
							local steamid64 = url:match("/profiles/(7656119%d+)$")
							if steamid64 then
								return self.UI.List.ManualSteamID.Add:Parsed(steamid64)
							else
								local customURL = url:match("/id/(.-)$")
								if customURL then
									local requestTextInput = textInput
									return http.Fetch("https://www.steamcommunity.com/id/" .. customURL, function(body, size, headers, httpCode)
										if httpCode == 200 then
											local steamid64 = body:match("\"steamid\":\"(7656119%d+)\"")
											if steamid64 then
												self.UI.List.ManualSteamID.Add:Parsed(steamid64, requestTextInput)
											else
												self.UI.List.ManualSteamID.Add:Error(L"ManualSteamIDProfileError")
											end
										elseif httpCode == 404 then
											self.UI.List.ManualSteamID.Add:Error(L"ManualSteamIDProfileNotFound")
										else
											self.UI.List.ManualSteamID.Add:Error(L"ManualSteamIDNetworkError")
										end
									end, function()
										self.UI.List.ManualSteamID.Add:Error(L"ManualSteamIDNetworkError")
									end)
								end
							end
						end
					end

					self.UI.List.ManualSteamID.Add:Error((L"ManualSteamIDError"):format(LocalPlayer():SteamID(), LocalPlayer():SteamID64(), "https://steamcommunity.com/profiles/" .. LocalPlayer():SteamID64(), "https://steamcommunity.com/id/DESTROYER_OF_THOTS"))
				end

		self.UI.SelectPlayers = vgui.Create("DPanel", self.UI)
		self.UI.SelectPlayers.Paint = nil
		self.UI.SelectPlayers:Dock(FILL)

			self.UI.RefreshBtn = vgui.Create("DButton", self.UI.SelectPlayers)
			self.UI.RefreshBtn:Dock(TOP)
			self.UI.RefreshBtn:DockMargin(0,0,0,10)
			self.UI.RefreshBtn:SetTall(25)
			self.UI.RefreshBtn:SetIcon("icon16/arrow_refresh.png")
			self.UI.RefreshBtn:SetText(L"Refresh")
			self.UI.RefreshBtn.DoClick = function()
				if self.UI.SelectPlayers.Tabs.Nearby.Activated then
					self.UI.SelectPlayers.Tabs.Nearby:Refresh()
				end
				if self.UI.SelectPlayers.Tabs.Online.Activated then
					self.UI.SelectPlayers.Tabs.Online:Refresh()
				end
				if self.UI.SelectPlayers.Tabs.Recent.Activated then
					self.UI.SelectPlayers.Tabs.Recent:Refresh()
				end
				if self.UI.SelectPlayers.Tabs.Search.Activated then
					self.UI.SelectPlayers.Tabs.Search:Refresh()
					self.UI.SelectPlayers.Tabs.Search.TextEntry:SearchTermUpdated()
				end
			end

			self.UI.SelectPlayers.Tabs = vgui.Create("DPropertySheet", self.UI.SelectPlayers)
			self.UI.SelectPlayers.Tabs:Dock(FILL)
			self.UI.SelectPlayers.Tabs.OnActiveTabChanged = function(self, old, new)
				local pnl = new:GetPanel()
				if not pnl.Activated then
					pnl.Activated = true
					pnl:Refresh()
				end
			end

				self.UI.SelectPlayers.Tabs.Nearby = vgui.Create("DTree", self.UI.SelectPlayers.Tabs)
				self.UI.SelectPlayers.Tabs.Nearby.Activated = true
				self.UI.SelectPlayers.Tabs.Nearby.OnNodeSelected = OnNodeSelected
				self.UI.SelectPlayers.Tabs.Nearby.Refresh = function()
					self.UI.SelectPlayers.Tabs.Nearby:Clear()

					local FriendsNode = self.UI.SelectPlayers.Tabs.Nearby:AddNode(L"Friends", "icon16/emoticon_happy.png")
					local PlayersNode = self.UI.SelectPlayers.Tabs.Nearby:AddNode(L"Players", "icon16/group.png")

					FriendsNode:SetExpanded(true)
					PlayersNode:SetExpanded(true)

					local has_friend_nearby = false

					for _, ply in ipairs(player.GetHumans()) do
						if ply:GetPos():Distance(LocalPlayer():GetPos()) <= 500 then
							local ParentNode
							if ply:GetFriendStatus() == "friend" then
								has_friend_nearby = true
								ParentNode = FriendsNode
							else
								ParentNode = PlayersNode
							end

							local node = ParentNode:AddNode(ply:Nick(), "icon16/box.png")
							node.SteamID64 = ply:SteamID64()
							node.Nick = ply:Nick()
							AvatarImageNode(node, ply:SteamID64())
							PlayerNodeClickBind(node)
						end
					end

					if not has_friend_nearby then
						FriendsNode:Remove()
					end
				end

			self.UI.SelectPlayers.Tabs:AddSheet(L"Nearby", self.UI.SelectPlayers.Tabs.Nearby, "icon16/map.png")

				self.UI.SelectPlayers.Tabs.Online = vgui.Create("DTree", self.UI.SelectPlayers.Tabs)
				self.UI.SelectPlayers.Tabs.Online.OnNodeSelected = OnNodeSelected
				self.UI.SelectPlayers.Tabs.Online.Refresh = function()
					self.UI.SelectPlayers.Tabs.Online:Clear()

					local FriendsNode = self.UI.SelectPlayers.Tabs.Online:AddNode(L"Friends", "icon16/emoticon_happy.png")
					local PlayersNode = self.UI.SelectPlayers.Tabs.Online:AddNode(L"Players", "icon16/group.png")

					FriendsNode:SetExpanded(true)
					PlayersNode:SetExpanded(true)

					local has_friend_online = false

					local TeamsNode = self.UI.SelectPlayers.Tabs.Online:AddNode(DarkRP and L"Jobs" or L"Teams", DarkRP and "icon16/user_gray.png" or "icon16/flag_purple.png")
					TeamsNode:SetExpanded(true)
					local TeamsNodes = {}
					if DarkRP then
						for _, category in SortedPairsByMemberValue(DarkRP.getCategories().jobs, "name") do
							if not table.IsEmpty(category.members) then
								local categoryNode
								for _, job in SortedPairsByMemberValue(category.members, "name") do
									if #team.GetPlayers(job.team) > 0 then
										if categoryNode == nil then
											categoryNode = TeamsNode:AddNode(category.name, "icon16/box.png")
											categoryNode.Icon.NodeColor = category.color
											categoryNode.Icon.Paint = NodeColorPaint
										end
										TeamsNodes[job.team] = categoryNode:AddNode(job.name, "icon16/box.png")
										TeamsNodes[job.team].Icon.NodeColor = job.color
										TeamsNodes[job.team].Icon.Paint = NodeColorPaint
									end
								end
							end
						end
					else
					for i, teamTbl in SortedPairsByMemberValue(team.GetAllTeams(), "Name") do
							if #team.GetPlayers(i) > 0 then
								TeamsNodes[i] = TeamsNode:AddNode(teamTbl.Name, "icon16/box.png")
								TeamsNodes[i].Icon.NodeColor = teamTbl.Color
								TeamsNodes[i].Icon.Paint = NodeColorPaint
							end
						end
					end

					local players = {}
					for _, ply in ipairs(player.GetHumans()) do
						players[ply] = ply:Nick()
					end
					for ply in SortedPairsByValue(players) do
						local ParentNode
						if ply:GetFriendStatus() == "friend" then
							has_friend_online = true
							ParentNode = FriendsNode
						else
							ParentNode = PlayersNode
						end

						for _, ParentNode in ipairs({ParentNode, TeamsNodes[ply:Team()]}) do
							local node = ParentNode:AddNode(ply:Nick(), "icon16/box.png")
							node.SteamID64 = ply:SteamID64()
							node.Nick = ply:Nick()
							AvatarImageNode(node, ply:SteamID64())
							PlayerNodeClickBind(node)
						end
					end

					if not has_friend_online then
						FriendsNode:Remove()
					end
				end

			self.UI.SelectPlayers.Tabs:AddSheet(L"Online", self.UI.SelectPlayers.Tabs.Online, "icon16/world.png")

				self.UI.SelectPlayers.Tabs.Recent = vgui.Create("DTree", self.UI.SelectPlayers.Tabs.Recent)
				self.UI.SelectPlayers.Tabs.Recent.OnNodeSelected = OnNodeSelected
				self.UI.SelectPlayers.Tabs.Recent.Refresh = function()
					self.UI.SelectPlayers.Tabs.Recent:Clear()

					local OnlineNode = self.UI.SelectPlayers.Tabs.Recent:AddNode(L"Online", "icon16/status_online.png")
					local OfflineNode = self.UI.SelectPlayers.Tabs.Recent:AddNode(L"Offline", "icon16/status_offline.png")

					OnlineNode:SetExpanded(true)

					for steamid64, data in SortedPairsByMemberValue(bKeypads.PlayerSelector.Recent, 2) do
						local ply = bKeypads.player.GetBySteamID64(steamid64)
						local ParentNode = IsValid(ply) and OnlineNode or OfflineNode

						local nick = IsValid(ply) and ply:Nick() or bKeypads.PlayerSelector:LookupName(steamid64)

						local node = ParentNode:AddNode(nick)
						node.SteamID64 = steamid64
						node.Nick = nick
						AvatarImageNode(node, steamid64)
						PlayerNodeClickBind(node)
					end
				end

			self.UI.SelectPlayers.Tabs:AddSheet(L"Recent", self.UI.SelectPlayers.Tabs.Recent, "icon16/clock.png")

			self.UI.SelectPlayers.Tabs.Search = vgui.Create("DPanel", self.UI.SelectPlayers.Tabs)
			self.UI.SelectPlayers.Tabs.Search.Paint = nil

				self.UI.SelectPlayers.Tabs.Search.TextEntry = vgui.Create("DTextEntry", self.UI.SelectPlayers.Tabs.Search)
				self.UI.SelectPlayers.Tabs.Search.TextEntry:Dock(TOP)
				self.UI.SelectPlayers.Tabs.Search.TextEntry:DockMargin(0, 0, 0, 10)
				self.UI.SelectPlayers.Tabs.Search.TextEntry:SetTall(25)
				self.UI.SelectPlayers.Tabs.Search.TextEntry:SetPlaceholderText(L"SearchEllipsis")
				self.UI.SelectPlayers.Tabs.Search.TextEntry:SetUpdateOnType(true)
				self.UI.SelectPlayers.Tabs.Search.TextEntry.SearchTermUpdated = function()
					local searchTerm = string.Trim(self.UI.SelectPlayers.Tabs.Search.TextEntry:GetValue()):lower()
					for _, line in ipairs(self.UI.SelectPlayers.Tabs.Search.Table:GetLines()) do
						line:SetVisible(#searchTerm == 0 or string.Trim(line.Columns[2]:GetText()):lower():find(searchTerm) ~= nil)
					end
					self.UI.SelectPlayers.Tabs.Search.Table:InvalidateLayout()
				end
				self.UI.SelectPlayers.Tabs.Search.TextEntry.OnValueChange = self.UI.SelectPlayers.Tabs.Search.TextEntry.SearchTermUpdated
				self.UI.SelectPlayers.Tabs.Search.TextEntry.OnFocusChanged = self.UI.SelectPlayers.Tabs.Search.TextEntry.SearchTermUpdated

				self.UI.SelectPlayers.Tabs.Search.Table = vgui.Create("DListView", self.UI.SelectPlayers.Tabs.Search)
				self.UI.SelectPlayers.Tabs.Search.Table:Dock(FILL)
				local col = self.UI.SelectPlayers.Tabs.Search.Table:AddColumn("") col:SetMinWidth(17) col:SetMaxWidth(17)
				self.UI.SelectPlayers.Tabs.Search.Table:AddColumn(L"Name")
				self.UI.SelectPlayers.Tabs.Search.Table:AddColumn("SteamID")
				self.UI.SelectPlayers.Tabs.Search.Table:AddColumn(L"Online")

				self.UI.SelectPlayers.Tabs.Search.Refresh = function()
					self.UI.SelectPlayers.Tabs.Search.Table:Clear()

					local mergedPlayers = {}
					for steamid64, data in pairs(bKeypads.PlayerSelector.Recent) do
						local ply = bKeypads.player.GetBySteamID64(steamid64)
						local nick = IsValid(ply) and ply:Nick() or bKeypads.PlayerSelector:LookupName(steamid64)
						mergedPlayers[steamid64] = nick
					end
					for _, ply in ipairs(player.GetHumans()) do
						mergedPlayers[ply:SteamID64()] = ply:Nick()
					end

					for steamid64, nick in SortedPairsByValue(mergedPlayers) do
						local line = self.UI.SelectPlayers.Tabs.Search.Table:AddLine("", nick, util.SteamIDFrom64(steamid64), IsValid(bKeypads.player.GetBySteamID64(steamid64)) and L"Online" or L"Offline")
						line.SteamID64 = steamid64
						line.Nick = nick
						AvatarImageLine(line, steamid64)
					end
				end

				self.UI.SelectPlayers.Tabs.Search.Table.OnRowSelected = function()
					for _, line in ipairs(self.UI.SelectPlayers.Tabs.Search.Table:GetSelected()) do
						SelectedPlayers[line.SteamID64] = line.Nick
					end
					self.UI.List.Players:Refresh()
				end

			self.UI.SelectPlayers.Tabs:AddSheet(L"Search", self.UI.SelectPlayers.Tabs.Search, "icon16/magnifier.png")

		self.UI.RefreshBtn:DoClick()
		return self.UI
	end
end

do

	bKeypads.JobSelector = {}
	function bKeypads.JobSelector:Open(callback)
		if IsValid(self.UI) then
			self.UI:Close()
		end

		local SelectedJobCommands = {}

		self.UI = vgui.Create("DFrame")
		self.UI:SetDrawOnTop(true)
		self.UI:SetSize(300,350)
		self.UI:SetTitle("bKeypads - " .. L"JobsSelector")
		self.UI:SetIcon("icon16/user_gray.png")
		self.UI:Center()
		self.UI:MakePopup()
		self.UI:MoveToFront()
		self.UI:DoModal()
		self.UI.OnClose = function()
			callback({})
			bKeypads.JobSelector.UI = nil
		end

		self.UI.Done = vgui.Create("DButton", self.UI)
		self.UI.Done:Dock(TOP)
		self.UI.Done:DockMargin(0,0,0,5)
		self.UI.Done:SetDisabled(true)
		self.UI.Done:SetText(L"Done")
		self.UI.Done:SetIcon("icon16/accept.png")
		self.UI.Done.DoClick = function()
			callback(table.GetKeys(SelectedJobCommands))
			self.UI:Close()
			bKeypads.JobSelector.UI = nil
			surface.PlaySound("garrysmod/save_load2.wav")
		end

		self.UI.JobTree = vgui.Create("DTree", self.UI)
		self.UI.JobTree:Dock(FILL)

		self.UI.JobTree.OnNodeSelected = function(self, node)
			if not node.JobCommand then
				node:SetExpanded(not node.m_bExpanded)
				node:SetSelected(false)
			else
				if SelectedJobCommands[node.JobCommand] then
					SelectedJobCommands[node.JobCommand] = nil
					node:SetSelected(false)
					surface.PlaySound("friends/friend_join.wav")
				else
					SelectedJobCommands[node.JobCommand] = node
					surface.PlaySound("garrysmod/ui_click.wav")
				end
				for command, node in pairs(SelectedJobCommands) do
					node:SetSelected(true)
				end
				bKeypads.JobSelector.UI.Done:SetDisabled(table.IsEmpty(SelectedJobCommands))
			end
		end

		for _, category in SortedPairsByMemberValue(DarkRP.getCategories().jobs, "name") do
			if not table.IsEmpty(category.members) then
				local categoryNode = self.UI.JobTree:AddNode(category.name, "icon16/box.png")
				categoryNode.Icon.NodeColor = category.color
				categoryNode.Icon.Paint = NodeColorPaint
				for _, job in SortedPairsByMemberValue(category.members, "name") do
					local jobNode = categoryNode:AddNode(job.name, "icon16/box.png")
					jobNode.Icon.NodeColor = job.color
					jobNode.Icon.Paint = NodeColorPaint
					jobNode.JobCommand = job.command
				end
			end
		end

		return self.UI
	end
end

--## Dyslexia ##--

function bKeypads.RecursiveDyslexia(pnl) -- R E C U R S I V E   D Y S L E X I A
	if pnl.SetFont and pnl.GetFont and pnl:GetFont() == "DermaDefault" or pnl:GetFont() == "DermaDefaultBold" then
		pnl:SetFont("bKeypads.DermaDefaultDyslexia")
		pnl:InvalidateLayout()
		pnl:InvalidateParent()
	end
	if pnl.GetChildren then
		for _, c in ipairs(pnl:GetChildren()) do
			bKeypads.RecursiveDyslexia(c)
		end
	end
end
hook.Add("bKeypads.BuildCPanel", "bKeypads.Dyslexia", function(CPanel)
	if not bKeypads.Settings:Get("dyslexia") then return end
	bKeypads.RecursiveDyslexia(CPanel)
end)