local function L(phrase)
	return GAS:Phrase(phrase, "adminsits")
end

if (IsValid(GAS.AdminSits.SitUI)) then
	GAS.AdminSits.SitUI:Close()
end
if (GAS.AdminSits.SitInvites) then
	for _,v in ipairs(GAS.AdminSits.SitInvites) do v:Remove() end
end

local function EndSitConfirmation()
	GAS:PlaySound("flash")
	Derma_Query(L"EndSitAreYouSure", L"EndSit", L"Yes", function()
		GAS:PlaySound("delete")
		GAS:netStart("AdminSits.EndSit")
		net.SendToServer()
	end, L"No")
end

do
	local blur = Material("pp/blurscreen")
	local function UI_Paint(self, w, h)
		surface.SetMaterial(blur)
		surface.SetDrawColor(255,255,255)

		for i=0.33, 1, 0.33 do
			local x,y = self:ScreenToLocal(0,0)
			blur:SetFloat("$blur", 3 * i)
			blur:Recompute()
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x,y,ScrW(),ScrH())
		end

		surface.SetDrawColor(26,26,26)
		surface.DrawRect(0,0,w,24)

		surface.SetDrawColor(26,26,26,150)
		surface.DrawRect(0,24,w,h-24)

		surface.SetDrawColor(26,26,26)
		surface.DrawOutlinedRect(0,23,w,h-23)
	end
	local function AddPlayerLinePaint(self, w, h)
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
	function GAS.AdminSits:CreateSitUI()
		system.FlashWindow()

		if (IsValid(GAS.AdminSits.SitUI)) then
			GAS.AdminSits.SitUI:Close()
		end

		GAS.AdminSits.SitUI = vgui.Create("bVGUI.Frame") local UI = GAS.AdminSits.SitUI
		UI:SetSize(500, 24 + 16 + 10)
		UI:AlignTop(100)
		UI:CenterHorizontal()
		UI:ShowFullscreenButton(false)
		UI:ShowPinButton(false)
		UI:ShowCloseButton(GAS.AdminSits:IsStaff(LocalPlayer()))
		UI:SetTitle("GmodAdminSuite - " .. L"AdminSit")
		UI:DockPadding(0, 24, 0, 0)
		UI:SetZPos(1)
		UI.Paint = UI_Paint

		function UI.bVGUI_CloseButton:DoClick()
			if (GAS.AdminSits:IsStaff(LocalPlayer())) then
				if (UI.SitCreator == LocalPlayer()) then
					EndSitConfirmation()
				else
					GAS:netStart("AdminSits.LeaveSit")
					net.SendToServer()
				end
			end
		end

		function UI:SetSitCreator(creator)
			self.SitCreator = creator

			if (self.SitCreator == LocalPlayer()) then
				bVGUI.AttachTooltip(UI.bVGUI_CloseButton, { Text = L"EndSit" })
			else
				bVGUI.AttachTooltip(UI.bVGUI_CloseButton, { Text = L"LeaveSit" })
			end
		end

		UI.lblTitle:SetFont(bVGUI.FONT(bVGUI.FONT_RUBIK, "REGULAR", 14))
		UI.lblTitle:SetTextColor(bVGUI.COLOR_WHITE)

		UI.Tabs = vgui.Create("DPanel", UI)
		UI.Tabs:Dock(TOP)
		UI.Tabs:SetTall(0)
		UI.Tabs.Paint = UI_Tabs_Paint

		UI.Tabs.Players = vgui.Create("DButton", UI.Tabs)
		UI.Tabs.Players:Dock(LEFT)
		UI.Tabs.Players:SetText(L"players_tab")
		UI.Tabs.Players:SetTextColor(bVGUI.COLOR_WHITE)
		UI.Tabs.Players:SetContentAlignment(5)
		UI.Tabs.Players:SizeToContentsX()

		UI.Tabs.Players.Content = vgui.Create("GAS.AdminSits.SitPlayers", UI)
		UI.Tabs.Players.Content:Dock(FILL)
		function UI.Tabs.Players.Content:LayoutSize(created)
			if (created) then
				UI:SetTall(UI:GetTall() + 16 + 10)
			else
				UI:SetTall(UI:GetTall() - 16 - 10)
			end
		end
	
		local AddPlayerLine = vgui.Create("DPanel", UI.Tabs.Players.Content)
		AddPlayerLine:Dock(BOTTOM)
		AddPlayerLine:SetTall(16 + 10)
		AddPlayerLine:DockPadding(5, 5, 5, 5)
		AddPlayerLine:SetCursor("hand")
		AddPlayerLine.AlphaLerp = 75
		AddPlayerLine.Paint = AddPlayerLinePaint
		function AddPlayerLine:DoClick()
			GAS.SelectionPrompts:PromptAccountID(function(account_id)
				local target = player.GetByAccountID(account_id)
				if (IsValid(target)) then
					if (not GAS.AdminSits:IsInSit(target)) then
						GAS:netStart("AdminSits.AddPlayerToSit")
							net.WriteEntity(target)
						net.SendToServer()

						if (GAS.AdminSits:IsStaff(target) and not GAS.AdminSits:CanTargetStaff(LocalPlayer())) then
							GAS:PlaySound("success")
							Derma_Message(L"PlayerInvitedToSit", L"AddPlayer", L"Dismiss")
						end
					else
						GAS:PlaySound("error")
						Derma_Message(L"PlayerAlreadyInSit", L"AddPlayer", L"Dismiss")
					end
				else
					GAS:PlaySound("error")
				end
			end, nil, nil, UI.Tabs.Players.Content.PlayerLines:dictionary())
		end
		function AddPlayerLine:OnMousePressed(m)
			self.mousePressed = m
		end
		function AddPlayerLine:OnMouseReleased(m)
			if (self.mousePressed == m and m == MOUSE_LEFT) then
				self:DoClick()
			end
			self.mousePressed = nil
		end

		AddPlayerLine.Icon = vgui.Create("DImage", AddPlayerLine)
		AddPlayerLine.Icon:Dock(LEFT)
		AddPlayerLine.Icon:SetMouseInputEnabled(false)
		AddPlayerLine.Icon:SetWide(16)
		AddPlayerLine.Icon:DockMargin(1, 0, 4, 0)
		AddPlayerLine.Icon:SetImage("icon16/add.png")

		AddPlayerLine.Name = vgui.Create("DLabel", AddPlayerLine)
		AddPlayerLine.Name:Dock(FILL)
		AddPlayerLine.Name:SetText(L"AddPlayerEllipsis")
		AddPlayerLine.Name:SetFont(bVGUI.FONT(bVGUI.FONT_RUBIK, "REGULAR", 14))
		AddPlayerLine.Name:SetTextColor(bVGUI.COLOR_WHITE)
		AddPlayerLine.Name:SetContentAlignment(4)
	end
end

local function JoinedSit()
	if (not IsValid(GAS.AdminSits.SitUI)) then
		GAS.AdminSits:CreateSitUI()
	end

	GAS.AdminSits.SitUI:SetSitCreator(net.ReadEntity())

	local ply = net.ReadEntity()
	local country if (net.ReadBool()) then country = net.ReadString() end
	local OS if (net.ReadBool()) then OS = net.ReadUInt(2) end
	GAS.AdminSits.SitUI.Tabs.Players.Content:AddPlayer(ply, false, country, OS)

	hook.Run("GAS.AdminSits.SitJoined", ply, country, OS)

	GAS:PlaySound("flash")
end
GAS:netReceive("AdminSits.JoinedSit", JoinedSit)

local function JoinedSitArray()
	if (not IsValid(GAS.AdminSits.SitUI)) then
		GAS.AdminSits:CreateSitUI()
	end

	GAS.AdminSits.SitUI:SetSitCreator(net.ReadEntity())

	for i=1,net.ReadUInt(7) do
		local ply = net.ReadEntity()
		local country if (net.ReadBool()) then country = net.ReadString() end
		local OS if (net.ReadBool()) then OS = net.ReadUInt(2) end
		GAS.AdminSits.SitUI.Tabs.Players.Content:AddPlayer(ply, false, country, OS)

		hook.Run("GAS.AdminSits.SitJoined", ply, country, OS)
	end
end
GAS:netReceive("AdminSits.JoinedSit[]", JoinedSitArray)

local function InvitedToSit()
	if (not IsValid(GAS.AdminSits.SitUI)) then
		GAS.AdminSits:CreateSitUI()
	end

	GAS.AdminSits.SitUI:SetSitCreator(net.ReadEntity())

	local ply = net.ReadEntity()
	local expiry = net.ReadUInt(32)
	local country if (net.ReadBool()) then country = net.ReadString() end
	local OS if (net.ReadBool()) then OS = net.ReadUInt(2) end
	GAS.AdminSits.SitUI.Tabs.Players.Content:AddPlayer(ply, expiry, country, OS)
end
GAS:netReceive("AdminSits.InvitedToSit", InvitedToSit)

local function SitInviteDeclined()
	if (IsValid(GAS.AdminSits.SitUI)) then
		GAS.AdminSits.SitUI.Tabs.Players.Content:RemovePlayer(net.ReadEntity())
	end
end
GAS:netReceive("AdminSits.SitInvite.Declined", SitInviteDeclined)

local function LeftSit()
	local ply = net.ReadEntity()

	if (ply == LocalPlayer()) then
		if (IsValid(GAS.AdminSits.SitUI)) then
			GAS.AdminSits.SitUI:Close()
		end
	else
		if (not IsValid(GAS.AdminSits.SitUI)) then
			GAS.AdminSits:CreateSitUI()
		end

		GAS.AdminSits.SitUI.Tabs.Players.Content:RemovePlayer(ply)
	end

	hook.Run("GAS.AdminSits.SitLeft", ply)
end
GAS:netReceive("AdminSits.LeftSit", LeftSit)

do
	GAS.AdminSits.SitInvites = {}
	GAS.AdminSits.SitInvitesIndexed = {}

	surface.CreateFont("GAS.AdminSits.JoinSitFont", {
		size = 30,
		bold = true,
		font = "Circular Std Medium"
	})

	local function RepositionInvites()
		local posIndex = 0
		for tblIndex,inviteContainer in ipairs(GAS.AdminSits.SitInvites) do
			inviteContainer:Reposition(posIndex)
			if (tblIndex > 1) then
				inviteContainer:MoveToBefore(GAS.AdminSits.SitInvites[tblIndex - 1])
			end
			if (not inviteContainer.Invite.Closing and not inviteContainer.Invite.Expired) then
				posIndex = posIndex + 1
				inviteContainer:SetMouseInputEnabled(posIndex == 1)
			end
		end
		for tblIndex,inviteContainer in ipairs(GAS.AdminSits.SitInvites) do
			if (inviteContainer.Invite.Closing or inviteContainer.Invite.Expired) then
				table.remove(GAS.AdminSits.SitInvites, tblIndex)
			end
		end
	end

	local InviteBGColor = Color(41,47,79)
	local InviteBorderColor = Color(39,45,76)

	local function Invite_Paint(self, w, h)
		draw.RoundedBox(50, 0, 0, w, h, InviteBorderColor)
		draw.RoundedBox(45, 5, 5, w-10, h-10, InviteBGColor)
	end
	local function Invite_PaintOver(self, w, h)
		if (self:IsHovered() or self.Dismissing or self.Joining) then
			self.JoinBGColor_uh_a = nil
			self.JoinBGColor_h_a = self.JoinBGColor_h_a or self.JoinBGColor.a

			self.InviteUnhovered = nil
			if (not self.InviteHovered) then
				self.InviteHovered = SysTime()
			end

			self.JoinBGColor.a = Lerp(math.TimeFraction(self.InviteHovered, self.InviteHovered + .25, SysTime()), self.JoinBGColor_h_a, 255)

			self.SitPlayersContainer:SetMouseInputEnabled(false)

			self.Text_L = L"JoinSit"
			self.Text_L_Dismiss = (L"Dismiss"):upper()
		elseif (self.InviteHovered or self.InviteUnhovered) then
			self.JoinBGColor_h_a = nil
			self.JoinBGColor_uh_a = self.JoinBGColor_uh_a or self.JoinBGColor.a

			self.InviteHovered = nil
			if (not self.InviteUnhovered) then
				self.InviteUnhovered = SysTime()
			end

			self.JoinBGColor.a = Lerp(math.TimeFraction(self.InviteUnhovered, self.InviteUnhovered + .25, SysTime()), self.JoinBGColor_uh_a, 0)

			self.SitPlayersContainer:SetMouseInputEnabled(true)
		end

		if (self.JoinBGColor.a > 0) then
			self.JoinTextColor.a = self.JoinBGColor.a
			self.DismissBGColor.a = self.JoinBGColor.a
			self.JoinBGColorHover.a = self.JoinBGColor.a
			self.DismissBGColorHover.a = self.JoinBGColor.a

			draw.RoundedBoxEx(45, w / 2, 5, (w / 2) - 5, h - 10, (self.Dismissing and self.DismissBGColorHover) or self.DismissBGColor, false, true, false, true)
			draw.RoundedBoxEx(45, 5, 5, (w / 2) - 5, h - 10, (self.Joining and self.JoinBGColorHover) or self.JoinBGColor, true, false, true, false)

			draw.SimpleText(self.Text_L, "GAS.AdminSits.JoinSitFont", (w / 4) + 5, h / 2, self.JoinTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(self.Text_L_Dismiss, "GAS.AdminSits.JoinSitFont", (w - (w / 4)) - 5, h / 2, self.JoinTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			self.InviteUnhovered = nil
		end
	end

	local AvatarImageCirclePoly = {}
	do
		local wedges = 36
		local wedge_angle = math.pi*2/wedges
		local r = 80 * 0.5
		for i=1, wedges do
			table.insert(AvatarImageCirclePoly, {
				x = math.cos(i*wedge_angle) * r + r,
				y = math.sin(i*wedge_angle) * r + r,
			})
		end
	end

	local InvolvedPlayersAvatarImageCirclePoly = {}
	do
		local wedges = 36
		local wedge_angle = math.pi*2/wedges
		local r = 22 * 0.5
		for i=1, wedges do
			table.insert(InvolvedPlayersAvatarImageCirclePoly, {
				x = math.cos(i*wedge_angle) * r + r,
				y = math.sin(i*wedge_angle) * r + r,
			})
		end
	end

	local function CircleAvatarImage(self, w, h)
		render.SetStencilEnable(true)
		
		render.ClearStencil()

		render.SetStencilWriteMask(1)
		render.SetStencilTestMask(1)
		render.SetStencilReferenceValue(1)

		render.SetStencilCompareFunction(STENCIL_ALWAYS)
		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)

		surface.SetDrawColor(0,0,0,255)
		draw.NoTexture()
		surface.DrawPoly(AvatarImageCirclePoly)

		render.SetStencilCompareFunction(STENCIL_EQUAL)
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)

		self.Avatar:SetPaintedManually(false)
		self.Avatar:PaintManual()
		self.Avatar:SetPaintedManually(true)

		render.SetStencilEnable(false)
	end

	local function InvolvedPlayersCircleAvatarImage(self, w, h)
		render.SetStencilEnable(true)
		
		render.ClearStencil()

		render.SetStencilWriteMask(1)
		render.SetStencilTestMask(1)
		render.SetStencilReferenceValue(1)

		render.SetStencilCompareFunction(STENCIL_ALWAYS)
		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)

		surface.SetDrawColor(0,0,0,255)
		draw.NoTexture()
		surface.DrawPoly(InvolvedPlayersAvatarImageCirclePoly)

		render.SetStencilCompareFunction(STENCIL_EQUAL)
		render.SetStencilPassOperation(STENCIL_KEEP)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)

		self.Avatar:SetPaintedManually(false)
		self.Avatar:PaintManual()
		self.Avatar:SetPaintedManually(true)

		render.SetStencilEnable(false)
	end

	local function SitPlayersContainerLayout(self, w, h)
		local space = w
		local overflow = 0
		for _,AvatarContainer in ipairs(self:GetChildren()) do
			local _,__,r = AvatarContainer:GetDockMargin()
			space = space - AvatarContainer:GetWide() - r
			if (space <= AvatarContainer:GetWide()) then
				overflow = overflow + 1
				self.Overflow:SetVisible(true)
				self.Overflow:SetText("+" .. overflow)
				AvatarContainer:SetVisible(false)
			else
				self.Overflow:MoveToAfter(AvatarContainer)
			end
		end
	end

	local function ExpiryBarPaint(self, w, h)
		local frac = math.max(math.min((SysTime() - self.Start) / 30, 1), 0)
		if (frac < 1) then
			--[[if (self:GetParent().Invite:IsHovered()) then
				if (not self.OnHoverTimeLeft) then
					self.OnHoverTimeLeft = math.max(self.Expires - SysTime(), 0)
					self.OnHoverTimeDelta = SysTime() - self.Start
				end
				self.Expires = SysTime() + self.OnHoverTimeLeft
				self.Start = SysTime() - self.OnHoverTimeDelta
			else
				self.OnHoverTimeLeft = nil
				self.OnHoverTimeDelta = nil
			end]]

			surface.SetDrawColor(frac * 255, (1 - frac) * 255, 0)
			local barWidth = w * (1 - frac)
			surface.DrawRect((w - barWidth) / 2, 0, barWidth, h)
		else
			local invite = self:GetParent().Invite
			if (not invite.Expired) then
				GAS:PlaySound("jump")
				invite.Expired = true
				invite:SetMouseInputEnabled(false)
				RepositionInvites()
			end
		end
	end

	local function InviteStaffToSit()
		local SitID = net.ReadUInt(24)
		local inviter = net.ReadEntity()
		if (not IsValid(inviter)) then return end
		local involved = {}
		for i=1,net.ReadUInt(7) do
			table.insert(involved, net.ReadUInt(32))
		end

		GAS:PlaySound("alert")
		system.FlashWindow()

		local inviteContainer = vgui.Create("DPanel")
		table.insert(GAS.AdminSits.SitInvites, inviteContainer)
		GAS.AdminSits.SitInvitesIndexed[SitID] = inviteContainer
		inviteContainer:SetSize(350, 100 + 5 + 5)
		inviteContainer:SetPos((ScrW() - inviteContainer:GetWide()) / 2, ScrH())
		inviteContainer.Paint = nil
		function inviteContainer:Reposition(i)
			inviteContainer:Stop()
			if (self.Invite.Closing or self.Invite.Expired) then
				inviteContainer:MoveTo(((ScrW() - inviteContainer:GetWide()) / 2) - (i * 20), ScrH(), .25, 0, -1, function()
					inviteContainer:Remove()
				end)
			else
				inviteContainer:MoveTo(((ScrW() - inviteContainer:GetWide()) / 2) - (i * 20), ScrH() - inviteContainer:GetTall() - 10 - (i * 20), .5, 0, -1)
			end
		end

		inviteContainer.ExpiryBar = vgui.Create("DPanel", inviteContainer)
		inviteContainer.ExpiryBar:Dock(BOTTOM)
		inviteContainer.ExpiryBar:SetTall(5)
		inviteContainer.ExpiryBar:DockMargin(50 - 10, 5, 50 - 10, 0)
		inviteContainer.ExpiryBar.Start = SysTime()
		inviteContainer.ExpiryBar.Expires = SysTime() + 30
		inviteContainer.ExpiryBar.Paint = ExpiryBarPaint

		local invite = vgui.Create("DPanel", inviteContainer)
		inviteContainer.Invite = invite

		invite.JoinBGColor = Color(46,204,113,0)
		invite.JoinBGColorHover = Color(32,142,78,0)
		invite.DismissBGColor = Color(204,46,46,0)
		invite.DismissBGColorHover = Color(145,33,33,0)
		invite.JoinTextColor = Color(255,255,255,0)

		invite:SetCursor("hand")
		invite:Dock(FILL)
		invite:DockPadding(10,10,10,10)
		invite.Paint = Invite_Paint
		invite.PaintOver = Invite_PaintOver
		function invite:OnMousePressed(m)
			if (m == MOUSE_LEFT) then
				local sX, sY = gui.MousePos()
				local x = self:ScreenToLocal(sX, sY)
				
				self.Closing = true
				if (x >= self:GetWide() / 2) then
					self.Dismissing = true
					GAS:PlaySound("delete")

					GAS:netStart("AdminSits.DismissSitInvite")
						net.WriteUInt(SitID, 24)
					net.SendToServer()
				else
					self.Joining = true
					GAS:PlaySound("success")

					GAS:netStart("AdminSits.AcceptSitInvite")
						net.WriteUInt(SitID, 24)
					net.SendToServer()
				end
				self:GetParent():SetMouseInputEnabled(false)
				RepositionInvites()
			end
		end

		invite.AvatarContainer = vgui.Create("DPanel", invite)
		invite.AvatarContainer:Dock(LEFT)
		invite.AvatarContainer:SetSize(80,80)
		invite.AvatarContainer:DockMargin(0,0,10,0)
		invite.AvatarContainer:SetMouseInputEnabled(false)
		invite.AvatarContainer.Paint = CircleAvatarImage

		invite.AvatarContainer.Avatar = vgui.Create("AvatarImage", invite.AvatarContainer)
		invite.AvatarContainer.Avatar:Dock(FILL)
		invite.AvatarContainer.Avatar:SetSteamID(inviter:SteamID64(), 184)
		invite.AvatarContainer.Avatar:SetMouseInputEnabled(false)

		invite.Title = vgui.Create("DLabel", invite)
		invite.Title:Dock(TOP)
		invite.Title:SetText(L"SitInviteReceivedTitle")
		invite.Title:SetFont(bVGUI.FONT(bVGUI.FONT_RUBIK, "BOLD", 16))
		invite.Title:SetTextColor(bVGUI.COLOR_WHITE)
		invite.Title:SetContentAlignment(4)
		invite.Title:SizeToContents()
		invite.Title:SetMouseInputEnabled(false)

		invite.Description = vgui.Create("DLabel", invite)
		invite.Description:SetText((L"SitInviteReceived"):format(inviter:Nick()))
		invite.Description:SetFont(bVGUI.FONT(bVGUI.FONT_RUBIK, "REGULAR", 14))
		invite.Description:SetTextColor(Color(255,255,255,180))
		invite.Description:SetContentAlignment(4)
		invite.Description:SetWrap(true)
		invite.Description:Dock(FILL)
		invite.Description:SetMouseInputEnabled(false)

		invite.SitPlayersContainer = vgui.Create("DPanel", invite)
		invite.SitPlayersContainer:Dock(BOTTOM)
		invite.SitPlayersContainer:SetTall(22)
		invite.SitPlayersContainer:DockMargin(0, 5, 0, 0)
		invite.SitPlayersContainer.Paint = nil
		invite.SitPlayersContainer.PerformLayout = SitPlayersContainerLayout
		invite.SitPlayersContainer:SetMouseInputEnabled(true)

		invite.SitPlayersContainer.Overflow = vgui.Create("DLabel", invite.SitPlayersContainer)
		invite.SitPlayersContainer.Overflow:Dock(LEFT)
		invite.SitPlayersContainer.Overflow:SetWide(22)
		invite.SitPlayersContainer.Overflow:SetFont(bVGUI.FONT(bVGUI.FONT_RUBIK, "REGULAR", 16))
		invite.SitPlayersContainer.Overflow:SetTextColor(bVGUI.COLOR_WHITE)
		invite.SitPlayersContainer.Overflow:SetText("")
		invite.SitPlayersContainer.Overflow:SetContentAlignment(5)
		invite.SitPlayersContainer.Overflow:DockMargin(0, 0, 5, 0)
		invite.SitPlayersContainer.Overflow:SetMouseInputEnabled(false)

		for _,AccountID in ipairs(involved) do
			local AvatarContainer = vgui.Create("DPanel", invite.SitPlayersContainer)
			AvatarContainer:SetWide(22)
			AvatarContainer:Dock(LEFT)
			AvatarContainer:DockMargin(0, 0, 5, 0)
			AvatarContainer:SetMouseInputEnabled(false)
			AvatarContainer.Paint = InvolvedPlayersCircleAvatarImage

			AvatarContainer.Avatar = vgui.Create("AvatarImage", AvatarContainer)
			AvatarContainer.Avatar:SetSteamID(GAS:AccountIDToSteamID64(AccountID), 32)
			AvatarContainer.Avatar:Dock(FILL)
			AvatarContainer.Avatar:SetMouseInputEnabled(false)
		end

		RepositionInvites()
	end
	GAS:netReceive("AdminSits.InviteToSit", InviteStaffToSit)

	local function DismissSitInvite()
		local SitID = net.ReadUInt(24)
		if (IsValid(GAS.AdminSits.SitInvitesIndexed[SitID])) then
			GAS.AdminSits.SitInvitesIndexed[SitID].Invite.Closing = true
			GAS.AdminSits.SitInvitesIndexed[SitID]:SetMouseInputEnabled(false)
			RepositionInvites()
		end
	end
	GAS:netReceive("AdminSits.DismissSitInvite", DismissSitInvite)
end

local function CountryReceived()
	if (IsValid(GAS.AdminSits.SitUI)) then
		local ply = net.ReadEntity()
		local country = net.ReadString()
		local PlayerLine = GAS.AdminSits.SitUI.Tabs.Players.Content.PlayerLines[ply]
		if (IsValid(PlayerLine)) then
			PlayerLine:SetCountry(country)
		end
	end
end
GAS:netReceive("AdminSits.GetCountry", CountryReceived)

local function OSReceived()
	if (IsValid(GAS.AdminSits.SitUI)) then
		local ply = net.ReadEntity()
		local OS = net.ReadUInt(2)
		local PlayerLine = GAS.AdminSits.SitUI.Tabs.Players.Content.PlayerLines[ply]
		if (IsValid(PlayerLine)) then
			PlayerLine:SetOS(OS)
		end
	end
end
GAS:netReceive("AdminSits.GetOS", OSReceived)

do
	local function ReloadTipWeaponColor(self)
		self:SetTextColor(LocalPlayer():GetWeaponColor():ToColor())
	end

	local function ReloadTip()
		if (not IsValid(GAS.AdminSits.ReloadTip)) then
			local ReloadTip = vgui.Create("DLabel")
			GAS.AdminSits.ReloadTip = ReloadTip

			ReloadTip:SetText(net.ReadBool() and L"ReloadTip" or L"ReloadTipRemove")
			ReloadTip:SetFont(bVGUI.FONT(bVGUI.FONT_CIRCULAR, "REGULAR", 14))
			ReloadTip:SetTextColor(LocalPlayer():GetWeaponColor():ToColor())
			ReloadTip:SizeToContents()
			ReloadTip:SetPos((ScrW() - ReloadTip:GetWide()) / 2, ((ScrH() - ReloadTip:GetTall()) / 2) + ReloadTip:GetTall() + 10)
			ReloadTip:SetAlpha(0)
			ReloadTip.PaintOver = ReloadTipWeaponColor
		else
			GAS.AdminSits.ReloadTip:Stop()
		end
		GAS.AdminSits.ReloadTip:AlphaTo(255, .25, 0)
	end
	GAS:netReceive("AdminSits.ReloadTip", ReloadTip)

	local function HardRemoveReloadTip()
		if (IsValid(GAS.AdminSits.ReloadTip)) then
			GAS.AdminSits.ReloadTip:Remove()
		end
	end
	local function RemoveReloadTip()
		if (IsValid(GAS.AdminSits.ReloadTip)) then
			GAS.AdminSits.ReloadTip:Stop()
			GAS.AdminSits.ReloadTip:AlphaTo(0, .25, 0, HardRemoveReloadTip)
		end
	end
	GAS:hook("PhysgunDrop", "AdminSits.ReloadTip.Remove", RemoveReloadTip)
	GAS:netReceive("AdminSits.ReloadTip.Remove", RemoveReloadTip)

	local function KeyRelease(key)
		if (key == IN_ATTACK) then
			RemoveReloadTip()
		end
	end
	GAS:hook("KeyRelease", "AdminSits.ReloadTip.Remove.KeyRelease", KeyRelease)
	
	HardRemoveReloadTip()
end

local function KillUI()
	if (IsValid(GAS.AdminSits.SitUI)) then
		GAS.AdminSits.SitUI:Close()
	end
end
GAS:netReceive("AdminSits.KillUI", KillUI)

GAS:netReceive("AdminSits.EndSit", EndSitConfirmation)