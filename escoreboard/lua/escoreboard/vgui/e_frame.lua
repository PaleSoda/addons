local x = ScrW()
local y = ScrH()

local PANEL={}

AccessorFunc( PANEL, "m_bDraggable",		"Draggable",		FORCE_BOOL )
AccessorFunc( PANEL, "m_bScreenLock",		"ScreenLock",		FORCE_BOOL )
AccessorFunc( PANEL, "m_bSizable",			"Sizable",			FORCE_BOOL )

AccessorFunc( PANEL, "m_iMinWidth",			"MinWidth",			FORCE_NUMBER )
AccessorFunc( PANEL, "m_iMinHeight",		"MinHeight",		FORCE_NUMBER )

--CLOSE BUTTON
local function addclosebutton(pnl)
	if not IsValid(pnl.closebutton) then
		pnl.closebutton = vgui.Create( "DButton", pnl )
	end
	pnl.closebutton:SetSize( 20, 20 )
	pnl.closebutton:SetText( "" )
	pnl.closebutton.Paint = function(self, w, h)
		draw.SimpleText("r","Marlett",w*0.5,h*0.5,escore.util.TextColMustDark(pnl.titlecolor) and escore.colors.default.black or escore.colors.default.white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	pnl.closebutton.DoClick = function()
		pnl:Close()
	end
end

function PANEL:Init()
	self:SetSize(400,400)
	self.color = escore.colors.playerpanel.bg or Color(13,13,13)
	self.roundsize = 0

	self.title = "Window"
	self.titlecolor = escore.colors.playerpanel.topbar or Color(255,255,255)
	self.titlealignx = TEXT_ALIGN_LEFT
	self.titlealigny = TEXT_ALIGN_CENTER
	self.titlefont = "escore_18_500"
	self.paintbg = true

	--CLOSE BUTTON
	addclosebutton(self)

	--CONTENT
	if not IsValid(self.content) then
		self.content = vgui.Create( "DPanel", self )
	end 
	self.content.Paint = function(self, w, h)
		--for override
	end

	self:PerformLayout()

	self:SetDraggable( true )
	self:SetSizable( false )
	self:SetMinWidth( 100 )
	self:SetMinHeight( 50 )
	self:SetScreenLock( false )
end

function PANEL:ShowCloseButton(bBool)
	if bBool then
		if IsValid(self.closebutton) then
			self.closebutton:Remove()
		end
		addclosebutton(self)
	else
		if IsValid(self.closebutton) then
			self.closebutton:Remove()
		end
	end
end

-- USER INPUT
function PANEL:SetTitle(title,color,font,alignx,aligny)
	if color then
		if IsColor(color) then self.titletextcolor = color end
	end
	if font then
		self.titlefont = font
	end
	if alignx then
		self.titlealignx = alignx
	end
	if aligny then
		self.titlealigny = aligny
	end
	if title then
		self.title = title
	end
	self:PerformLayout()
end
function PANEL:GetTitle() return self.title end


function PANEL:SetColor(col) 
	if IsColor(col) then self.color = col end 
end
function PANEL:GetColor() return self.color end


function PANEL:SetTitleColor(col)
	if IsColor(col) then self.titlecolor = col end
end
function PANEL:GetTitleColor() return self.titlecolor end


function PANEL:GetContent() return self.content end


function PANEL:Close(anim)
	self:OnClose()
	if anim == nil then anim = true end
	if anim then 
		local x, y = self:GetPos()
		self:SizeTo(1,self:GetTall(),escore.config.animtime)
		timer.Simple(escore.config.animtime+(escore.config.animtime/2),function()
			self:Remove()
		end)
	else
		self:Remove()
	end
end

function PANEL:OnClose()
end

--SETTING POSITION AND SIZE OF ELEMENTS
function PANEL:PerformLayout()
	surface.SetFont(self.titlefont or "escore_18_500")
	local wide, height = surface.GetTextSize(self.title)

	self.titlesize = {
		wide = wide+2,
		height = height+2
	}

	local padding = 2
	if IsValid(self.closebutton) then self.closebutton:SetPos( self:GetWide() - self.closebutton:GetWide() - 5, self.titlesize.height/2 - self.closebutton:GetTall()/2 ) end
	self.content:SetSize(self:GetWide(),self:GetTall()-self.titlesize.height)
	self.content:SetPos(0,self.titlesize.height)

	self:DockPadding(0, self.titlesize.height, 0, 0)
end

--MOUSE DRAGGING
function PANEL:OnMousePressed()
	local screenX, screenY = self:LocalToScreen( 0, 0 )
	if ( self.m_bSizable && gui.MouseX() > ( screenX + self:GetWide() - 20 ) && gui.MouseY() > ( screenY + self:GetTall() - 20 ) ) then
		self.Sizing = { gui.MouseX() - self:GetWide(), gui.MouseY() - self:GetTall() }
		self:MouseCapture( true )
		return
	end

	if ( self:GetDraggable() && gui.MouseY() < ( screenY + 24 ) ) then
		self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
		self:MouseCapture( true )
		return
	end
end

function PANEL:OnMouseReleased()
	self.Dragging = nil
	if self.Sizing then
		self.Sizing = nil
		self:InvalidateChildren(true)
	end
	self:MouseCapture( false )
end

function PANEL:Think()

	local mousex = math.Clamp( gui.MouseX(), 1, ScrW() - 1 )
	local mousey = math.Clamp( gui.MouseY(), 1, ScrH() - 1 )

	if ( self.Dragging ) then

		local x = mousex - self.Dragging[1]
		local y = mousey - self.Dragging[2]

		-- Lock to screen bounds if screenlock is enabled
		if ( self:GetScreenLock() ) then

			x = math.Clamp( x, 0, ScrW() - self:GetWide() )
			y = math.Clamp( y, 0, ScrH() - self:GetTall() )

		end

		self:SetPos( x, y )

	end

	if ( self.Sizing ) then

		local x = mousex - self.Sizing[1]
		local y = mousey - self.Sizing[2]
		local px, py = self:GetPos()

		if ( x < self.m_iMinWidth ) then x = self.m_iMinWidth elseif ( x > ScrW() - px && self:GetScreenLock() ) then x = ScrW() - px end
		if ( y < self.m_iMinHeight ) then y = self.m_iMinHeight elseif ( y > ScrH() - py && self:GetScreenLock() ) then y = ScrH() - py end

		self:SetSize( x, y )
		return

	end

	local screenX, screenY = self:LocalToScreen( 0, 0 )
	if ( self.Hovered && self.m_bSizable && mousex > ( screenX + self:GetWide() - 20 ) && mousey > ( screenY + self:GetTall() - 20 ) ) then
		self:SetCursor( "sizenwse" )
		return
	end

	if ( self.Hovered && self:GetDraggable() && mousey < ( screenY + 24 ) ) then
		self:SetCursor( "sizeall" )
		return
	end

	self:SetCursor( "arrow" )

	if ( self.y < 0 ) then
		self:SetPos( self.x, 0 )
	end

end

--BACKGROUND
function PANEL:PaintBG(w,h)
	--bg
	draw.RoundedBox(self.roundsize,0,0,w,h,self.color)
	surface.SetDrawColor(self.titlecolor:Unpack())
	surface.DrawLine(0,0,0,h-1)
	surface.DrawLine(w-1,0,w-1,h-1)
	surface.DrawLine(0,h-1,w-1,h-1)

	--Title bg
	draw.RoundedBoxEx(self.roundsize,0,0,w,self.titlesize.height, self.titlecolor, true,true,false,false)
end

function PANEL:Paint(w,h)
	--background
	if self.PaintBG then self:PaintBG(w,h) end

	--title
	draw.SimpleText(self.title,
		self.titlefont,
		(self.titlealignx == TEXT_ALIGN_CENTER) and (w/2) or 5,
		(self.titlealigny == TEXT_ALIGN_CENTER) and (self.titlesize.height/2) or 0,
		escore.util.TextColMustDark(self.titlecolor) and escore.colors.default.black or escore.colors.default.white,
		self.titlealignx,
		self.titlealigny)

	local posx,posy = self:GetPos()
	local mx,my = input.GetCursorPos()
	if (mx >= posx) and (mx <= posx+w) then
		if (my >= posy) and (my <= posy+h) then
			self.Hovered = true
		else
			self.Hovered = false
		end
	else
		self.Hovered = false
	end

 	
	return true
end

vgui.Register( "escore.window", PANEL );