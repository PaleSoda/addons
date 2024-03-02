local function L(phrase)
	return GAS:Phrase(phrase, "adminsits")
end

GAS:hook("gmodadminsuite:ModuleSize:adminsits", "AdminSits.FrameSize", function()
	return 400,500
end)

local function SitPanel_Paint(self, w, h)
	surface.SetDrawColor(41,47,79)
	surface.DrawRect(0,0,w,h)
end

local function JoinSitLinePaint(self, w, h)
	if (self:IsHovered()) then
		self.AlphaLerp_uh = nil
		if (not self.AlphaLerp_h) then
			self.AlphaLerp_h = SysTime()
		end

		self.AlphaLerp = Lerp(math.TimeFraction(self.AlphaLerp_h, self.AlphaLerp_h + .15, SysTime()), self.AlphaLerp, 150)
	else
		self.AlphaLerp_h = nil
		if (not self.AlphaLerp_uh) then
			self.AlphaLerp_uh = SysTime()
		end

		self.AlphaLerp = Lerp(math.TimeFraction(self.AlphaLerp_uh, self.AlphaLerp_uh + .15, SysTime()), self.AlphaLerp, 75)
	end
	surface.SetDrawColor(26, 26, 26, self.AlphaLerp)
	surface.DrawRect(0, 0, w, h)
end

GAS:hook("gmodadminsuite:ModuleFrame:adminsits", "AdminSits.Menu", function(ModuleFrame)
	local RefreshContainer = vgui.Create("bVGUI.BlankPanel", ModuleFrame)
	RefreshContainer:Dock(TOP)
	RefreshContainer:SetTall(25)
	RefreshContainer:DockMargin(11,10,16,0)
	
	local Refresh = vgui.Create("bVGUI.Button", RefreshContainer)
	Refresh:SetText(L"Refresh")
	Refresh:SetColor(bVGUI.BUTTON_COLOR_BLUE)
	Refresh:SetSize(120,25)
	
	function RefreshContainer:PerformLayout()
		Refresh:Center()
	end

	local SitContainer = vgui.Create("bVGUI.LoadingScrollPanel", ModuleFrame)
	SitContainer:Dock(FILL)
	SitContainer:SetLoading(true)

	local NoSits = vgui.Create("DLabel", ModuleFrame)
	NoSits:Dock(FILL)
	NoSits:SetMouseInputEnabled(false)
	NoSits:SetVisible(false)
	NoSits:SetText(L"NoActiveSits")
	NoSits:SetFont(bVGUI.FONT(bVGUI.FONT_RUBIK, "REGULAR", 16))
	NoSits:SetTextColor(bVGUI.COLOR_WHITE)
	NoSits:SetContentAlignment(5)

	function Refresh:DoClick()
		GAS:PlaySound("success")

		NoSits:SetVisible(false)
		SitContainer:SetVisible(true)
		SitContainer:Clear()
		SitContainer:SetLoading(true)

		GAS:netStart("AdminSits.GetSits")
		net.SendToServer()
	end

	GAS:netReceive("AdminSits.GetSits", function()
		if (not IsValid(SitContainer)) then return end

		local Sits = {}
		for i=1,net.ReadUInt(7) do
			local Sit = {}

			Sit.ID = net.ReadUInt(24)
			Sit.Creator = player.GetByAccountID(net.ReadUInt(31)) or nil
			Sit.Started = net.ReadUInt(32)

			Sit.InvolvedPlayers = {}
			for ply_i=1,net.ReadUInt(7) do
				local InvolvedPlayer = player.GetByAccountID(net.ReadUInt(31)) or nil
				local InvolvedPlayerTbl = {
					ply = InvolvedPlayer,
					country = net.ReadBool() and net.ReadString() or nil,
					OS = net.ReadBool() and net.ReadUInt(2) or nil,
					invited = net.ReadBool() and net.ReadUInt(32) or nil,
				}
				if (IsValid(InvolvedPlayer)) then
					table.insert(Sit.InvolvedPlayers, InvolvedPlayerTbl)
				end
			end

			if (IsValid(Sit.Creator)) then
				table.insert(Sits, Sit)
			end
		end

		NoSits:SetVisible(#Sits == 0)
		SitContainer:SetVisible(#Sits > 0)
	
		for _,Sit in ipairs(Sits) do
			local SitPanel = vgui.Create("bVGUI.Frame", SitContainer)
			SitPanel:Dock(TOP)
			SitPanel:DockMargin(11,10,16,0)
			SitPanel:SetTitle((L"SitID"):format(Sit.ID))
			SitPanel:ShowCloseButton(false)
			SitPanel:ShowPinButton(false)
			SitPanel:ShowFullscreenButton(false)
			SitPanel.Paint = SitPanel_Paint

			SitPanel.PlayerLines = vgui.Create("GAS.AdminSits.SitPlayers", SitPanel)
			SitPanel.PlayerLines.EnableSitControls = false
			SitPanel.PlayerLines:Dock(FILL)
			function SitPanel.PlayerLines:LayoutSize(created)
				if (created) then
					SitPanel:SetTall(SitPanel:GetTall() + 16 + 10)
				else
					SitPanel:SetTall(SitPanel:GetTall() - 16 - 10)
				end
			end

			for _,InvolvedPlayer in ipairs(Sit.InvolvedPlayers) do
				if (not InvolvedPlayer.invited or InvolvedPlayer.invited > os.time()) then
					SitPanel.PlayerLines:AddPlayer(InvolvedPlayer.ply, InvolvedPlayer.invited or false, InvolvedPlayer.country, InvolvedPlayer.OS)
				end
			end

			if (GAS.AdminSits:CanJoinSit(LocalPlayer()) and not SitPanel.PlayerLines.PlayerLines[LocalPlayer()]) then
				local JoinSitLine = vgui.Create("DPanel", SitPanel.PlayerLines)
				JoinSitLine:Dock(BOTTOM)
				JoinSitLine:SetTall(16 + 10)
				JoinSitLine:DockPadding(5, 5, 5, 5)
				JoinSitLine:SetCursor("hand")
				JoinSitLine.AlphaLerp = 75
				JoinSitLine.Paint = JoinSitLinePaint
				function JoinSitLine:DoClick()
					GAS:netStart("AdminSits.JoinSit")
						net.WriteUInt(Sit.ID, 24)
					net.SendToServer()
					Refresh:DoClick()
				end
				function JoinSitLine:OnMousePressed(m)
					self.mousePressed = m
				end
				function JoinSitLine:OnMouseReleased(m)
					if (self.mousePressed == m and m == MOUSE_LEFT) then
						self:DoClick()
					end
					self.mousePressed = nil
				end

				JoinSitLine.Icon = vgui.Create("DImage", JoinSitLine)
				JoinSitLine.Icon:Dock(LEFT)
				JoinSitLine.Icon:SetMouseInputEnabled(false)
				JoinSitLine.Icon:SetWide(16)
				JoinSitLine.Icon:DockMargin(1, 0, 4, 0)
				JoinSitLine.Icon:SetImage("icon16/add.png")

				JoinSitLine.Name = vgui.Create("DLabel", JoinSitLine)
				JoinSitLine.Name:Dock(FILL)
				JoinSitLine.Name:SetText(L"JoinSitLine")
				JoinSitLine.Name:SetFont(bVGUI.FONT(bVGUI.FONT_RUBIK, "REGULAR", 14))
				JoinSitLine.Name:SetTextColor(bVGUI.COLOR_WHITE)
				JoinSitLine.Name:SetContentAlignment(4)

				SitPanel.PlayerLines:LayoutSize(true)
			end
		end

		SitContainer:SetLoading(false)
	end)

	GAS:netStart("AdminSits.GetSits")
	net.SendToServer()
end)