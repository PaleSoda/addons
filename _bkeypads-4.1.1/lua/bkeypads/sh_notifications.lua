bKeypads.Notifications = {}

bKeypads.Notifications.ACCESS_GRANTED      = 0
bKeypads.Notifications.ACCESS_DENIED       = 1
bKeypads.Notifications.PAYMENT_TAKEN       = 2
bKeypads.Notifications.PAYMENT_RECEIVED    = 3
bKeypads.Notifications.PAYMENT_CANT_AFFORD = 4

bKeypads.Notifications.MoneyTypes = {
	[bKeypads.Notifications.PAYMENT_TAKEN] = true,
	[bKeypads.Notifications.PAYMENT_RECEIVED] = true,
	[bKeypads.Notifications.PAYMENT_CANT_AFFORD] = true,
}
bKeypads.Notifications.AccessTypes = {
	[bKeypads.Notifications.ACCESS_GRANTED] = true,
	[bKeypads.Notifications.ACCESS_DENIED] = true
}
bKeypads.Notifications.PlayerTypes = {
	[bKeypads.Notifications.ACCESS_GRANTED] = true,
	[bKeypads.Notifications.ACCESS_DENIED] = true,
	[bKeypads.Notifications.PAYMENT_RECEIVED] = true,
}
bKeypads.Notifications.KeypadTypes = {
	[bKeypads.Notifications.ACCESS_GRANTED] = true,
	[bKeypads.Notifications.ACCESS_DENIED] = true,
	[bKeypads.Notifications.PAYMENT_RECEIVED] = true,
	[bKeypads.Notifications.PAYMENT_CANT_AFFORD] = true,
}

if CLIENT then
	function bKeypads.Notifications:GetText(type, keypad, ply)
		if (
			not IsValid(keypad) or
			(bKeypads.Notifications.PlayerTypes[type] and not IsValid(ply))
		) then return end

		local moneyText, plyText, keypadText

		if bKeypads.Notifications.PlayerTypes[type] then plyText = "<color=" .. bKeypads.markup.Color(team.GetColor(ply:Team())) .. ">" .. bKeypads.markup.Escape(ply:Nick()) .. "</color>" end
		if bKeypads.Notifications.MoneyTypes[type] then moneyText = "<color=0,200,0>" .. bKeypads.markup.Escape(bKeypads.Economy:formatMoney(keypad:GetPaymentAmount())) .. "</color>" end
		if bKeypads.Notifications.KeypadTypes[type] and keypad:GetKeypadName() ~= "" then keypadText = ("<color=" .. bKeypads.markup.Color(bKeypads:IntToColor(keypad:GetBackgroundColor())) .. ">" .. bKeypads.markup.Escape(keypad:GetKeypadName()) .. "</color>") end

		local keypadTextLangAppend = keypadText and "_Named" or ""

		if type == bKeypads.Notifications.PAYMENT_TAKEN then
			return bKeypads.L("Notification_PaymentTaken" .. keypadTextLangAppend):format(moneyText, keypadText)
		elseif type == bKeypads.Notifications.ACCESS_GRANTED then
			return bKeypads.L("Notification_Access" .. keypadTextLangAppend):format("<color=0,200,0>" .. bKeypads.L("Notification_GRANTED") .. "</color>", plyText, keypadText)
		elseif type == bKeypads.Notifications.ACCESS_DENIED then
			return bKeypads.L("Notification_Access" .. keypadTextLangAppend):format("<color=200,0,0>" .. bKeypads.L("Notification_DENIED") .. "</color>", plyText, keypadText)
		elseif type == bKeypads.Notifications.PAYMENT_RECEIVED then
			return bKeypads.L("Notification_PaymentReceived" .. keypadTextLangAppend):format(moneyText, plyText, keypadText)
		elseif type == bKeypads.Notifications.PAYMENT_CANT_AFFORD then
			return bKeypads.L("Notification_PaymentCantAfford" .. keypadTextLangAppend):format(moneyText, keypadText)
		else return	end
	end

	bKeypads_Notifications_Stack = bKeypads_Notifications_Stack or {}
	for _, notif in ipairs(bKeypads_Notifications_Stack) do notif:Remove() end
	bKeypads_Notifications_Stack = {}
	bKeypads.Notifications.Stack = bKeypads_Notifications_Stack

	function bKeypads.Notifications:Show(type, keypad, ply)
		local text = bKeypads.Notifications:GetText(type, keypad, ply)
		if not text then return end

		if bKeypads.Config.Notifications.UseChat then

			local args = {bKeypads.COLOR.PINK, "[bKeypads] "}
			for _, block in ipairs(markup.Parse(text).blocks) do
				table.insert(args, Color(block.colour.r, block.colour.g, block.colour.b))
				table.insert(args, block.text)
			end

			chat.AddText(unpack(args))

		else

			local notif = vgui.Create("bKeypads.Notification")
			notif:SetExpire(bKeypads.Settings:Get("notification_time"))
			notif:SetIcon(type, keypad)
			notif:SetText(text)
			table.insert(bKeypads.Notifications.Stack, notif)

			bKeypads.Notifications:Shuffle()

		end
	end

	net.Receive("bKeypads.Notification", function()
		bKeypads.Notifications:Show(net.ReadUInt(3), net.ReadEntity(), net.ReadEntity())
	end)

	--## Notification Panel ##--

	function bKeypads.Notifications:CreateFont()
		surface.CreateFont("bKeypads.NotificationText", {
			font = "Circular Std Medium",
			size = bKeypads.Settings:Get("notification_text_size")
		})

		for _, notif in ipairs(bKeypads.Notifications.Stack) do
			notif:SetText(notif.m_Text)
		end

		bKeypads.Notifications:Shuffle()
	end

	bKeypads_Notifications_ID = bKeypads_Notifications_ID or 0

	local PANEL = {}

	local BGColor = Color(41, 47, 79)
	local BGColorDark = Color(32, 38, 70)
	local IconContainerBG = Color(37, 42, 71, 255)
	local SoftGreen, SoftRed = Color(0, 200, 0), Color(255, 0, 0)

	local padding = 15
	local progressHeight = 3

	local animInDuration = .5
	local animOutDuration = .25

	do
		local function ShuffleAnim(anim, pnl, f)
			pnl:SetPos(anim.TargetX, anim.StartY + (anim.TargetY - anim.StartY) * bKeypads.ease.OutBack(f))
		end
		function bKeypads.Notifications:Shuffle()
			local y = 0
			local stackSize = #bKeypads.Notifications.Stack
			for i = stackSize, 1, -1 do
				local notif = bKeypads.Notifications.Stack[i]
				if not IsValid(notif) then ErrorNoHalt("Tried to remove a NULL notification\n") continue end

				if ((stackSize - (i - 1)) > bKeypads.Settings:Get("notification_max")) then
					notif:Expire()
				end

				y = y + notif:GetTall() + 20

				notif:Stop()

				local anim = notif:NewAnimation(animInDuration, 0, 1)
				anim.Think = ShuffleAnim
				anim.TargetX, anim.StartY = notif:GetPos()
				anim.TargetY = ScrH() - y
			end
		end
	end

	local matPIN     = Material("bkeypads/notification_pin.png", "smooth")
	local matKeycard = Material("bkeypads/keycard.png", "smooth")
	local matSmile   = Material("bkeypads/face_id.png", "smooth")
	local matSad     = Material("bkeypads/face_id_sad.png", "smooth")
	local matDollar  = Material("bkeypads/dollar.png", "smooth")

	function PANEL:Init()
		self:SetMouseInputEnabled(false)
		self:SetKeyboardInputEnabled(false)
		self:SetDrawOnTop(true)
		self:MoveToFront()

		self:SetSize(ScrW() * .25, 45)
		self:SetPos(self:CenterHorizontal(), ScrH())
	end

	function PANEL:CenterHorizontal()
		local x = ScrW() * .375
		self:AlignLeft(x)
		return x
	end

	function PANEL:SetText(text)
		self.m_Text = text
		self.m_Markup = markup.Parse("<font=bKeypads.NotificationText>" .. text .. "</font>", self:GetWide() - self:GetIconPadding() - self:GetIconPadding() - self:GetIconSize() - padding - padding - padding)
		self:SetTall(self.m_Markup:GetHeight() + padding + padding + progressHeight)
	end


	function PANEL:SetIcon(type, keypad)
		self.m_Type = type

		if bKeypads.Notifications.MoneyTypes[type] then

			self.m_Material = matDollar
			self.m_Color = type == bKeypads.Notifications.PAYMENT_CANT_AFFORD and SoftRed or SoftGreen

			if bKeypads.Settings:Get("notification_sounds") then
				if type == bKeypads.Notifications.PAYMENT_CANT_AFFORD then
					surface.PlaySound("buttons/button2.wav")
				elseif type == bKeypads.Notifications.PAYMENT_TAKEN then
					surface.PlaySound("garrysmod/content_downloaded.wav")
				else
					surface.PlaySound("garrysmod/save_load4.wav")
					timer.Simple(bKeypads.Settings:Get("notification_time"), function()
						surface.PlaySound("bkeypads/cash.wav")
					end)
				end
			end

			return

		elseif bKeypads.Notifications.AccessTypes[type] and IsValid(keypad) then

			local authMode = keypad:LinkProxy():GetAuthMode()
			self.m_Material = (
				authMode == bKeypads.AUTH_MODE.PIN and matPIN or
				authMode == bKeypads.AUTH_MODE.KEYCARD and matKeycard or
				authMode == bKeypads.AUTH_MODE.FACEID and (
					type == bKeypads.Notifications.ACCESS_GRANTED and matSmile or matSad
				)
			)
			self.m_Color = type == bKeypads.Notifications.ACCESS_GRANTED and SoftGreen or SoftRed

			if bKeypads.Settings:Get("notification_sounds") then
				surface.PlaySound(type == bKeypads.Notifications.ACCESS_GRANTED and "buttons/button9.wav" or "buttons/button11.wav")
			end

			return

		end

		self.m_Color = color_white
		self.m_Material = matSmile
	end

	function PANEL:GetIconSize()
		return math.min(self:GetTall() - self:GetIconPadding() - self:GetIconPadding(), 48)
	end

	function PANEL:GetIconPadding()
		return self.m_Markup and self.m_Markup:GetHeight() > bKeypads.Settings:Get("notification_text_size") and 15 or 10
	end

	function PANEL:SetExpire(seconds)
		self.m_LifeStart = CurTime()
		self.m_LifeEnd   = animInDuration + self.m_LifeStart + seconds + animOutDuration

		bKeypads_Notifications_ID = bKeypads_Notifications_ID + 1

		self.TimerID = "bKeypads.Notification:" .. bKeypads_Notifications_ID
		timer.Create("bKeypads.Notification:" .. bKeypads_Notifications_ID, seconds + animOutDuration + animInDuration, 1, function()
			if IsValid(self) then
				table.RemoveByValue(bKeypads.Notifications.Stack, self)
				self:Remove()

				bKeypads.Notifications:Shuffle()
			end
		end)
	end

	function PANEL:Expire()
		self.m_LifeEnd = math.min(self.m_LifeEnd, CurTime() + animOutDuration)
		timer.Adjust(self.TimerID, math.max((self.m_LifeEnd - CurTime()) + animOutDuration, animOutDuration))
	end

	function PANEL:Paint(w, h)
		local lifeFrac = math.Clamp(math.TimeFraction(self.m_LifeStart, self.m_LifeEnd, CurTime()), 0, 1)
		local fadeFrac = 1 - math.Clamp(math.TimeFraction(self.m_LifeEnd - animOutDuration, self.m_LifeEnd, CurTime()), 0, 1)

		local alpha = surface.GetAlphaMultiplier()
		surface.SetAlphaMultiplier(alpha * fadeFrac)

		local iconSize, iconPadding = self:GetIconSize(), self:GetIconPadding()
		local iconContainerW = iconPadding + iconSize + iconPadding

		surface.SetDrawColor(IconContainerBG)
		surface.DrawRect(0, 0, iconContainerW, h)

		surface.SetMaterial(self.m_Material)
		surface.SetDrawColor(self.m_Color)
		surface.DrawTexturedRect(iconPadding, (h - iconSize) / 2, iconSize, iconSize)

		surface.SetDrawColor(BGColor)
		surface.DrawRect(iconContainerW, 0, w, h - progressHeight)

		if self.m_Markup then
			self.m_Markup:Draw(iconContainerW + padding, (h - progressHeight) / 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 255, self.m_Markup:GetHeight() > bKeypads.Settings:Get("notification_text_size") and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER)
		end

		surface.SetDrawColor(BGColorDark)
		surface.DrawRect(iconContainerW, h - progressHeight, w - iconPadding - iconSize - iconPadding, progressHeight)

		surface.SetAlphaMultiplier(alpha * fadeFrac * (BGColor.a / 255))
		surface.SetDrawColor(self.m_Color)
		surface.DrawRect(iconContainerW, h - progressHeight, (w - iconPadding - iconSize - iconPadding) * lifeFrac, progressHeight)

		surface.SetAlphaMultiplier(alpha)
	end

	vgui.Register("bKeypads.Notification", PANEL, "DPanel")

	bKeypads.Notifications:CreateFont()
end