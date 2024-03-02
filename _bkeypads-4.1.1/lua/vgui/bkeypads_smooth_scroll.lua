--## bKeypads.SmoothScroll ##--

local PANEL = {}

local function VBar_PerformLayout(self)
	local Wide = self:GetWide()
	local BtnHeight = Wide
	if self:GetHideButtons() then BtnHeight = 0 end
	local Scroll = self:GetScroll() / self.CanvasSize
	local BarSize = math.max(self:BarScale() * (self:GetTall() - (BtnHeight * 2)), 10)
	local Track = self:GetTall() - (BtnHeight * 2) - BarSize
	Track = Track + 1

	Scroll = Scroll * Track

	self.TargetY = BtnHeight + Scroll
	self.btnGrip:SetSize(Wide, BarSize)

	if BtnHeight > 0 then
		self.btnUp:SetPos(0, 0, Wide, Wide)
		self.btnUp:SetSize(Wide, BtnHeight)

		self.btnDown:SetPos(0, self:GetTall() - BtnHeight)
		self.btnDown:SetSize(Wide, BtnHeight)

		self.btnUp:SetVisible(true)
		self.btnDown:SetVisible(true)
	else
		self.btnUp:SetVisible(false)
		self.btnDown:SetVisible(false)
		self.btnDown:SetSize(Wide, BtnHeight)
		self.btnUp:SetSize(Wide, BtnHeight)
	end
end

local function VBar_Think(self)
	self.CurrentY = Lerp(FrameTime() * 10, self.CurrentY, self.TargetY)
	self.btnGrip:SetPos(0, math.Round(self.CurrentY))
end

local function pnlCanvas_Think(self)
	self.CurrentOffset = Lerp(FrameTime() * 10, self.CurrentOffset, self.TargetOffset)
	self:SetPos(0, math.Round(self.CurrentOffset))
end

function PANEL:Init()
	self.CurrentOffset = 0
	self.TargetOffset = 0
	self.StartTime = 0
	self.EndTime = 0

	self.VBar.CurrentY = 0
	self.VBar.TargetY = 0
	self.VBar.PerformLayout = VBar_PerformLayout
	self.VBar.Think = VBar_Think

	self.pnlCanvas.CurrentOffset = 0
	self.pnlCanvas.TargetOffset = 0
	self.pnlCanvas.Think = pnlCanvas_Think
end

function PANEL:OnVScroll(offset)
	self.pnlCanvas.TargetOffset = offset
end

function PANEL:PerformLayoutInternal()
	local Tall = self.pnlCanvas:GetTall()
	local Wide = self:GetWide()
	local YPos = 0

	self:Rebuild()

	self.VBar:SetUp(self:GetTall(), self.pnlCanvas:GetTall())
	YPos = self.VBar:GetOffset()

	if self.VBar.Enabled then Wide = Wide - self.VBar:GetWide() end

	self.pnlCanvas:SetPos(0, YPos)
	self.pnlCanvas:SetWide(Wide)

	self:Rebuild()

	if Tall ~= self.pnlCanvas:GetTall() then
		self.VBar:SetScroll(self.VBar:GetScroll())
	end
end

derma.DefineControl("bKeypads.SmoothScroll", nil, PANEL, "DScrollPanel")

--## bKeypads.SmoothScroll.HideVBar ##--

local PANEL = {}

function PANEL:PerformLayout(w, h)
	self.VBar:SetWide(0)
	DScrollPanel.PerformLayout(self, w, h)
end

derma.DefineControl("bKeypads.SmoothScroll.HideVBar", nil, PANEL, "bKeypads.SmoothScroll")

--## bKeypads.SmoothScroll.CategoryList ##--

local PANEL = {}

function PANEL:Init()

	self.pnlCanvas:DockPadding( 2, 2, 2, 2 )

end

function PANEL:AddItem( item )

	item:Dock( TOP )
	DScrollPanel.AddItem( self, item )
	self:InvalidateLayout()

end

function PANEL:Add( name )

	local Category = vgui.Create( "DCollapsibleCategory", self )
	Category:SetLabel( name )
	Category:SetList( self )

	self:AddItem( Category )

	return Category

end

function PANEL:Paint( w, h )

	derma.SkinHook( "Paint", "CategoryList", self, w, h )
	return false

end

function PANEL:UnselectAll()

	for k, v in pairs( self:GetChildren() ) do

		if ( v.UnselectAll ) then
			v:UnselectAll()
		end

	end

end

function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local ctrl = vgui.Create( ClassName )
	ctrl:SetSize( 300, 300 )

	local Cat = ctrl:Add( "Test category with text contents" )
	Cat:Add( "Item 1" )
	Cat:Add( "Item 2" )

	-- The contents can be any panel, even a DPanelList
	local Cat2 = ctrl:Add( "Test category with panel contents" )
	Cat2:SetTall( 100 )
	local Contents = vgui.Create( "DButton" )
	Contents:SetText( "This is the content of the category" )
	Cat2:SetContents( Contents )

	ctrl:InvalidateLayout( true )

	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end

derma.DefineControl( "bKeypads.SmoothScroll.CategoryList", "", PANEL, "bKeypads.SmoothScroll.HideVBar" )