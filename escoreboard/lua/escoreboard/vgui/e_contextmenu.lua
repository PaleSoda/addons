local PANEL={}

function PANEL:Init()
	local parent = self:GetParent()
	local outpnl = vgui.Create("DButton",parent)
	outpnl:SetSize(parent:GetWide(),parent:GetTall())
	outpnl:SetText("")
	outpnl.Paint = nil
	self.contextbackground = outpnl
	function outpnl:Close()
		self:SizeTo(1,1,escore.config.animtime*1.1,0,-1,function()
			self:Remove()
		end)
	end
	function outpnl.DoClick()
		outpnl:Close()
		if IsValid(self) then self:Close(true) end
	end
	function outpnl.DoRightClick()
		outpnl:Close()
		if IsValid(self) then self:Close(true) end
	end
	parent.contextbg = outpnl

	self.buttonheight = 30
	self.sepheight = 2
	self.spacey = 1
	self.notify = true

	self.player = LocalPlayer()
	self:SetParent(outpnl)

	self:SetSize(100,self.buttonheight)
	self.list = vgui.Create("DIconLayout", self)
	self.list:SetSpaceY(self.spacey)
	self.list:SetSize(self:GetWide(),self:GetSize())
end

function PANEL:SetWide(wide)
	self:SetSize(wide,self:GetTall())
	self.list:SetSize(wide,self:GetTall())
end

function PANEL:SetNotify(bool)
	self.notify = bool
end

function PANEL:GetNotify()
	return self.notify
end

function PANEL:Close(anim)
	if anim then
		self:SizeTo(1,1,escore.config.animtime,0,-1,function()
			self:Remove()
			self.contextbackground:Remove()
		end)
	else
		self:Remove()
		self.contextbackground:Remove()
	end
end

function PANEL:SetPly(ply)
	self.player = ply
end

function PANEL:GetPly(ply)
	return self.player
end

function PANEL:SetPosClamped(posx,posy)
	local x = math.Clamp( posx, 0, ScrW() - self:GetWide() )
	local y = math.Clamp( posy, 0, ScrH() - self:GetTall() )
	self:SetPos(x,y)
end

function PANEL:E_InvalidateLayout()
	local size = 0
	for _,v in ipairs(self.list:GetChildren()) do
		size = size + v:GetTall() + self.spacey
	end

	self:SetSize(self:GetWide(), size )
	self.list:SetSize(self:GetWide(),self:GetSize())
end

function PANEL:AddButton(text,func)
	local button = vgui.Create("DButton",self.list)
	button:SetSize(self.list:GetWide(), self.buttonheight)
	button:SetText("")
	button.TextColor = escore.colors.context.text
	button.TextHoverColor = escore.colors.context.texthover
	function button:Paint(w,h)
		local hover = self:IsHovered()
		draw.RoundedBox(0,0,0,w,h,
			hover and escore.colors.context.buttonhover or escore.colors.context.button
		)
		draw.SimpleText(
			text,
			"escore_18_500",
			w*0.5,h*0.5,
			hover and self.TextHoverColor or self.TextColor,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)
	end
	function button.DoClick()
		self:Close()
		func(self.player)
		if self.notify then
			eboard:Notify(text,1)
		end
	end
	function button:SetTextColor(col)
		if IsColor(col) then self.TextColor = col end
	end
	function button:GetTextColor(col) return self.TextColor end
	function button:SetTextHoverColor(col)
		if IsColor(col) then self.TextHoverColor = col end
	end
	function button:GetTextColor(col) return self.TextHoverColor end

	self:E_InvalidateLayout()
	return button
end

function PANEL:OnClick()
end

function PANEL:AddHeader(text)
	local pnl = vgui.Create("DPanel",self.list)
		pnl:SetSize(self.list:GetWide(), self.buttonheight)
		function pnl:Paint(w,h)
			draw.RoundedBox(0,0,0,w,h,escore.colors.context.header)
			draw.SimpleText(text,"escore_20_500",w*0.5,h*0.5,escore.colors.context.headertext, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	self:E_InvalidateLayout()
end

function PANEL:AddSeparator()
	local pnl = vgui.Create("DPanel",self.list)
		pnl:SetSize(self.list:GetWide(), self.sepheight)
		function pnl:Paint(w,h)
			surface.SetDrawColor(escore.colors.context.separator:Unpack())
			surface.DrawRect(0,0,w,h)
		end
	self:E_InvalidateLayout()
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(escore.colors.context.bg:Unpack())
	surface.DrawRect(0,0,w,h)
end


vgui.Register( "escore.contextmenu", PANEL );