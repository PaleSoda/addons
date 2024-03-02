AddCSLuaFile()
--[[
      __          __              ____  
     /\ \        / /             |___ \ 
    /  \ \  /\  / /_ _ _ __ _ __   __) |
   / /\ \ \/  \/ / _` | '__| '_ \ |__ < 
  / ____ \  /\  / (_| | |  | | | |___) |
 /_/    \_\/  \/ \__,_|_|  |_| |_|____/ 

	AWarn3 by Mr.President
]]

MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, "Loading VGUI Module\n" )


AWarn.SelectedLanguage = "EN-US"
AWarn.SelectedTheme = "Light"

include( "includes/vgui/aw3_menu_configuration_settings.lua")

hook.Add( "InitPostEntity", "awarn3_loadlanguage", function()
	AWarn.SelectedLanguage = LocalPlayer():GetPData( "awarn3_lang", "EN-US" )
	AWarn.SelectedTheme = LocalPlayer():GetPData( "awarn3_theme", "Light" )
	
end )

local function ScrWM()
	local wid = ScrW()
	if wid > 3840 then wid = 3840 end
	return wid
end

local function ScrHM()
	local hgt = ScrH()
	if hgt > 2160 then hgt = 2160 end
	return hgt
end

local function ScreenScale( size )
	return size * ( ScrWM() / 640.0 )	
end

local screenscale = ScreenScale( 0.4 )

surface.CreateFont( "AWarn3NavButton", {
	font = "Arial",
	size = math.Round(10 * screenscale),
	weight = 800,
} )

surface.CreateFont( "AWarn3NavButton3", {
	font = "Arial",
	size = math.Round(14 * screenscale),
	weight = 800,
} )

surface.CreateFont( "AWarn3NavButton2", {
	font = "Arial",
	size = math.Round(24 * screenscale),
	weight = 800,
} )

surface.CreateFont( "AWarn3Label1", {
	font = "Arial",
	size = math.Round(20 * screenscale),
	weight = 800,
} )

surface.CreateFont( "AWarn3Label2", {
	font = "Arial",
	size = math.Round(16 * screenscale),
	weight = 800,
} )

surface.CreateFont( "AWarn3Label3", {
	font = "Arial",
	size = math.Round(12 * screenscale),
	weight = 600,
} )

surface.CreateFont( "AWarn3CardText1", {
	font = "Arial",
	size = math.Round(14 * screenscale),
	weight = 800,
} )

surface.CreateFont( "AWarn3CardText2", {
	font = "Arial",
	size = math.Round(12 * screenscale),
	weight = 800,
} )

surface.CreateFont( "AWarn3ToggleText1", {
	font = "Arial",
	size = math.Round(18 * screenscale),
	weight = 800,
} )

surface.CreateFont( "AWarn3ToggleText2", {
	font = "Arial",
	size = math.Round(12 * screenscale),
	weight = 600,
} )

surface.CreateFont( "AWarn3NotesTextBoxMono", {
	font = "Lucida Console",
	size = math.Round(12 * screenscale),
	weight = 400,
} )

local logoImage = Material( "materials/vgui/awlogo.png", "noclamp smooth" )
local playerWarningsImage = Material( "materials/vgui/awarn3_playerwarnings.png", "noclamp smooth" )
local optionsImage = Material( "materials/vgui/aw3_options.png", "noclamp smooth" )
local deleteImage = Material( "materials/vgui/awarn3_delete.png", "noclamp smooth" )
local minusImage = Material( "materials/vgui/awarn3_minus.png", "noclamp smooth" )
local searchImage = Material( "materials/vgui/awarn3_search.png", "noclamp smooth" )
local punishmentOptionsImage = Material( "materials/vgui/aw3_punishment_options.png", "noclamp smooth" )
local serverOptionsImage = Material( "materials/vgui/aw3_server_options.png", "noclamp smooth" )
local userOptionsImage = Material( "materials/vgui/aw3_user_options.png", "noclamp smooth" )
local closeImage = Material( "materials/vgui/aw3_close.png", "noclamp smooth" )
local xImage = Material( "materials/vgui/aw3_x.png", "noclamp smooth" )
local activeWarnings = Material( "materials/vgui/aw3_active_warnings.png", "noclamp smooth" )
local playerNotes = Material( "materials/vgui/aw3_notes.png", "noclamp smooth" )

local easings = include("includes/awarn3_easings.lua")

AWarn.Colors = AWarn.Colors or {
	COLOR_SELECTED = Color( 255, 0, 200, 160 ),
	COLOR_BUTTON_SELECTED = Color( 180, 40, 40, 40 ),
	COLOR_BUTTON = Color( 80, 80, 80, 0 ),
	COLOR_BUTTON_2 = Color( 180, 80, 80, 120 ),
	COLOR_BUTTON_2_HOVERED = Color( 180, 80, 80, 180 ),
	COLOR_BUTTON_HOVERED = Color( 80, 80, 80, 30 ),
	COLOR_BUTTON_DISABLED = Color( 120, 120, 120, 40 ),
	COLOR_BUTTON_TEXT = Color( 20, 20, 20, 180 ),
	COLOR_LABEL_TEXT = Color( 180, 80, 160, 255 ),
	COLOR_LABEL_VALUE_TEXT = Color( 220, 80, 220, 220 ),
	COLOR_THEME_PRIMARY = Color( 255, 230, 255, 250 ),
	COLOR_THEME_SECONDARY = Color( 255, 210, 255, 255 ),
	COLOR_THEME_PRIMARY_SHADOW = Color( 235, 216, 234, 250 ),
	COLOR_RED_BUTTON = Color(255,80,80,200),
	COLOR_RED_BUTTON_HOVERED = Color(255,80,80,255),
}

function AWarn:OpenMenu()
	if IsValid( self.menu ) then self.menu:Remove() end
	self.menu = vgui.Create( "awarn3_menu" )
	self.menu:SetWide( ScrWM() * 0.75 )
	self.menu:SetTall( ScrHM() * 0.75 )
	self.menu:Center()
	self.menu:MakePopup()
	self.menu:DrawElements()
	
	AWarn:RequestOptions()
	AWarn:RequestPunishments()
	AWarn:RequestPresets()
	AWarn:RequestOwnWarnings()
end

function AWarn:RequestOptions()
	net.Start( "awarn3_networkoptions" )
	net.WriteString( "update" )
	net.SendToServer()
end

function AWarn:RequestPunishments()
	net.Start( "awarn3_networkpunishments" )
	net.WriteString( "update" )
	net.SendToServer()
end

function AWarn:RequestPresets()
	net.Start( "awarn3_networkpresets" )
	net.WriteString( "update" )
	net.SendToServer()
end

function AWarn:SendOptionUpdate( option, value )
	net.Start( "awarn3_networkoptions" )
	net.WriteString( "write" )
	
	if AWarn.Options[ option ].type == "boolean" then
		net.WriteString( option )
		net.WriteBool( value )
	elseif AWarn.Options[ option ].type == "integer" then
		net.WriteString( option )
		net.WriteInt( value, 32 )
	elseif AWarn.Options[ option ].type == "string" then
		net.WriteString( option )
		net.WriteString( value )
	end
	
	net.SendToServer()
end

net.Receive( "awarn3_networkoptions", function()
	if not IsValid( AWarn.menu ) then return end
	local options = net.ReadTable()
	AWarn.Options = options
	
	if table.Count( AWarn.Options ) > 0 then
		AWarn:RefreshSettings()
	end
end )

net.Receive( "awarn3_networkpunishments", function()
	if not IsValid( AWarn.menu ) then return end
	local punishments = net.ReadTable()
	AWarn.Punishments = punishments
	
	AWarn:RefreshPunishments()
end )


net.Receive( "awarn3_networkpresets", function()
	if not IsValid( AWarn.menu ) then return end
	local presets = net.ReadTable()
	AWarn.Presets = presets
	
	AWarn:RefreshPresets()
end )

net.Receive( "awarn3_openmenu", function( l, pl )
	AWarn:OpenMenu()
end )

function AWarn:CloseMenu()
	if IsValid( self.menu ) then self.menu:Remove() end
	AWarn:SaveClientSettings()
end

local text = "~Rainbow~"
local PANEL = {}
function PANEL:Init()
	self.startTime = SysTime()
	self:SetDraggable( false )
	self:SetTitle( "" )
	self:ShowCloseButton( false )
end
function PANEL:Paint()
	
	if tobool(LocalPlayer():GetPData( "awarn3_blurbackground", true )) then
		Derma_DrawBackgroundBlur( self, self.startTime )
	end
	
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_SECONDARY )
	surface.DrawRect( 80 * screenscale, 70 * screenscale, self:GetWide(), self:GetTall() )  --Main Body
	
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
	surface.DrawRect( 0, 0, self:GetWide(), 70 * screenscale ) --Header
	
	surface.DrawRect( 0, 70 * screenscale, 80 * screenscale, self:GetTall() - 70 * screenscale ) --Left Panel
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
	surface.DrawRect( 80 * screenscale, 70 * screenscale, 3 * screenscale, self:GetTall() - 70 * screenscale ) --Left Panel Shadow
	surface.DrawRect( 80 * screenscale + 3 * screenscale, 70 * screenscale, self:GetWide() - (80 * screenscale + 3 * screenscale), 3 * screenscale ) --Header Shadow
	
	surface.SetDrawColor( AWarn.Colors.COLOR_BUTTON_TEXT )
	surface.SetMaterial( logoImage	)
	surface.DrawTexturedRect( 16 * screenscale, 16 * screenscale, 48 * screenscale, 48 * screenscale )
	
	if AWarn.Outdated then
		surface.SetFont( "AWarn3Label2" )
		surface.SetTextColor( 255, 0, 0 )
		surface.SetTextPos(  self:GetWide() - 350 * screenscale, 30 * screenscale ) 
		surface.DrawText( "A new version of AWarn3 is available for download." )
	end
end
function PANEL:DrawElements()

	local navButtonPanel = vgui.Create( "DPanel", self )
	navButtonPanel:SetPos( 0, 70 * screenscale )
	navButtonPanel:DockPadding( 0, 10, 0, 70 * screenscale )
	navButtonPanel:SetSize( 80 * screenscale, self:GetTall() )
	navButtonPanel.Paint = function()
		--Render Invisible
		surface.SetDrawColor( 200, 200, 200, 0 )
		surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	end

	local mainBodyPanel = vgui.Create( "DPanel", self )
	mainBodyPanel:SetPos( 80 * screenscale, 70 * screenscale )
	mainBodyPanel:DockPadding( 0, 0, 0, 0 )
	mainBodyPanel:SetSize( self:GetWide() - 80 * screenscale, self:GetTall() )
	mainBodyPanel.Paint = function()
		--Render Invisible
		surface.SetDrawColor( 200, 0, 200, 0 )
		surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	end
	
	if AWarn:CheckPermission( LocalPlayer(), "awarn_view" ) then
		if IsValid( self.adminWarningsView ) then self.adminWarningsView:Remove() end
		self.adminWarningsView = vgui.Create( "awarn3_adminwarningsview", mainBodyPanel )
	else
		if IsValid( self.selfWarningsView ) then self.selfWarningsView:Remove() end
		self.selfWarningsView = vgui.Create( "awarn3_selfwarningsview", mainBodyPanel )	
	end
	
	if IsValid( self.configurationview ) then self.configurationview:Remove() end
	self.configurationview = vgui.Create( "awarn3_configurationview", mainBodyPanel )
	self.configurationview:Dock( FILL )
	self.configurationview:InvalidateParent( true )
	self.configurationview:InvalidateLayout( true )
	self.configurationview:DrawElements()
	self.configurationview:Hide()
	
	local navButton = vgui.Create( "awarn3_navbutton", navButtonPanel )
	navButton:SetText(AWarn.Localization:GetTranslation( "viewwarnings" ))
	navButton:SetIcon( playerWarningsImage )
	navButton:SetEnabled( true )
	navButton.OnSelected = function()
		if AWarn:CheckPermission( LocalPlayer(), "awarn_view" ) then
			self.adminWarningsView:Show()
		else
			self.selfWarningsView:Show()
		end
		self.configurationview:Hide()
	end
	AWarn.lastSelectedNavButton = navButton
	
	local navButton = vgui.Create( "awarn3_navbutton", navButtonPanel )
	navButton:SetText(AWarn.Localization:GetTranslation( "configuration" ))
	navButton:SetIcon( optionsImage )
	navButton.OnSelected = function()
		if AWarn:CheckPermission( LocalPlayer(), "awarn_view" ) then
			self.adminWarningsView:Hide()
		else
			self.selfWarningsView:Hide()		
		end		
		self.configurationview:Show()
	end
	
	local navButton = vgui.Create( "awarn3_navbutton2", navButtonPanel )
	navButton:SetText( AWarn.Localization:GetTranslation( "closemenu" ) )
	navButton:SetIcon( closeImage )
	navButton.OnSelected = function()
		AWarn:CloseMenu()
	end
	
	
	if AWarn:CheckPermission( LocalPlayer(), "awarn_view" ) then
		local navButton = vgui.Create( "awarn3_navbutton2", navButtonPanel )
		navButton:SetText( AWarn.Localization:GetTranslation( "searchplayers" ) )
		navButton:SetIcon( searchImage )
		navButton.OnSelected = function()
			if IsValid( AWarn.menu.playerwarndialogue ) then AWarn.menu.playerwarndialogue:Remove() end
			if IsValid( AWarn.menu.playersearch ) then AWarn.menu.playersearch:Remove() end
			AWarn.menu.playersearch = vgui.Create( "awarn3_playersearch" )
			AWarn.menu.playersearch:MakePopup()
			AWarn.menu.playersearch:SetParent( AWarn.menu )
		end
	end

	
end
function PANEL:Think()
	self:MoveToBack()
end
vgui.Register( "awarn3_menu", PANEL, "DFrame" )




function AWarn:CreatePunishmentCard( tblInfo )
	local searchPlayerCard = vgui.Create( "awarn3_punishmentcard" )
	AWarn.menu.configurationview.PunishmentsCardsPanel:AddItem( searchPlayerCard )
	searchPlayerCard:SetInfo( tblInfo )
	searchPlayerCard:Dock( TOP )
	local cardNum = #AWarn.menu.configurationview.PunishmentsCardsPanel:GetCanvas():GetChildren()
	AWarn.menu.configurationview.PunishmentsCardsPanel:SetHeight( math.Clamp( ( 60 * screenscale ) * cardNum, 100, 300 ) )
	searchPlayerCard:DrawElements()
		
	searchPlayerCard.hdiv = vgui.Create( "awarn3_hdiv", self.ServerSettingsMenuDock )
	searchPlayerCard.hdiv:Dock( TOP )
	AWarn.menu.configurationview.PunishmentsCardsPanel:AddItem( searchPlayerCard.hdiv )
end

function AWarn:RefreshPunishments()

	AWarn.menu.configurationview.PunishmentsCardsPanel:Clear()
	for k, v in SortedPairs( AWarn.Punishments ) do
		AWarn:CreatePunishmentCard( v )
	end

end


function AWarn:CreatePresetCard( tblInfo )
	local presetCard = vgui.Create( "awarn3_presetcard" )
	AWarn.menu.configurationview.PresetsCardsPanel:AddItem( presetCard )
	presetCard:SetInfo( tblInfo )
	presetCard:Dock( TOP )
	local cardNum = #AWarn.menu.configurationview.PresetsCardsPanel:GetCanvas():GetChildren()
	AWarn.menu.configurationview.PresetsCardsPanel:SetHeight( math.Clamp( ( 60 * screenscale ) * cardNum, 100, 300 ) )
	presetCard:DrawElements()
		
	presetCard.hdiv = vgui.Create( "awarn3_hdiv", self.ServerSettingsMenuDock )
	presetCard.hdiv:Dock( TOP )
	AWarn.menu.configurationview.PresetsCardsPanel:AddItem( presetCard.hdiv )
end

function AWarn:RefreshPresets()

	AWarn.menu.configurationview.PresetsCardsPanel:Clear()
	for k, v in SortedPairs( AWarn.Presets ) do
		AWarn:CreatePresetCard( v )
	end

end


local PANEL = {}
function PANEL:Init()
	local dockMargin = 4 * screenscale
	self:DockMargin( dockMargin, dockMargin, dockMargin, dockMargin )
	self:SetHeight( 42 * screenscale )
	self:Dock( TOP )
	
	self.hovered = false
	
	self.start = RealTime()
	self.stop = RealTime() + 0.1
	self.animating = true

	self.pName = "NULL"
	self.pReason = "NULL"

end
function PANEL:SetInfo( tbl )
	self.pName = tbl.pName or "NULL"
	self.pReason = tbl.pReason or "NULL"
	
	
	self:SetTooltip( ([[
	%s: %s
	%s: %s]]):format(AWarn.Localization:GetTranslation( "presetname" ), self.pName, AWarn.Localization:GetTranslation( "presetreason" ), self.pReason ) )
end
function PANEL:Paint()
	
	if self.hovered == true then
		surface.SetDrawColor( AWarn.Colors.COLOR_BUTTON_HOVERED )
	else
		surface.SetDrawColor( AWarn.Colors.COLOR_BUTTON )
	end
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
		
	surface.SetFont( "AWarn3Label2" )
	local text = self.pName
	local x = 10 * screenscale
	local y = 6 * screenscale
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	surface.SetTextPos( x, y )
	surface.DrawText( text )
	
	surface.SetFont( "AWarn3CardText2" )
	local text = self.pReason
	local x = 10 * screenscale
	local y = 24 * screenscale
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	surface.SetTextPos( x, y )
	surface.DrawText( text )

end
function PANEL:Think()
	if self:IsHovered() and not self.hovered then
		self.hovered = true
	elseif self.hovered and not self:IsHovered() then
		self.hovered = false
	end
	self:AnimateThink()
end
function PANEL:AnimateThink()
	if not self.animating then return end
	if RealTime() < self.stop then
		local easingsX = easings.outCubic( RealTime() - self.start, 0, self:GetWide(), 0.1 )
		local x, y = self:GetPos()
		local easeAmt = ( easingsX * -1 ) + self:GetWide()
		self:SetPos( easeAmt, y )
	else
		local x, y = self:GetPos()
		self.animating = false
	end
end
function PANEL:DrawElements( pl )
	local deleteButtonFrame = vgui.Create( "DPanel", self )
	deleteButtonFrame:SetWidth( 80 * screenscale )
	deleteButtonFrame:Dock( RIGHT )
	deleteButtonFrame.Paint = function()
	end

	local deleteButton = vgui.Create( "awarn3_iconbutton", deleteButtonFrame )
	deleteButton:SetTooltip(AWarn.Localization:GetTranslation( "deletewarning" ))
	deleteButton:SetSize(24 * screenscale, 24 * screenscale)
	deleteButton:SetIcon( xImage )
	deleteButton:SetPos( 10 * screenscale, 10 * screenscale )
	deleteButton.OnSelected = function()
		AWarn.Presets[ self.pName ] = nil
		self.hdiv:Remove()
		self:Remove()
		local cardNum = #AWarn.menu.configurationview.PresetsCardsPanel:GetCanvas():GetChildren()
		AWarn.menu.configurationview.PresetsCardsPanel:SetHeight( math.Clamp( ( 60 * screenscale ) * cardNum, 100, 300 ) )
		AWarn:SavePresets()
	end
end
function PANEL:OnMousePressed( key )
	if key == MOUSE_LEFT then
		AWarn.menu.configurationview.presetNameTxtBox:SetValue( self.pName )
		AWarn.menu.configurationview.presetValueTxtBox:SetValue( self.pReason )
	end
end
vgui.Register( "awarn3_presetcard", PANEL )

function AWarn:SavePresets()
	net.Start( "awarn3_networkpresets" )
	net.WriteString( "write" )
	net.WriteTable( AWarn.Presets )
	net.SendToServer()
end


local PANEL = {}
function PANEL:Init()
	local dockMargin = 4 * screenscale
	self:DockMargin( dockMargin, dockMargin, dockMargin, 0 )
	self:SetHeight( 55 * screenscale )
	self:Dock( TOP )
	
	self.hovered = false
	
	self.start = RealTime()
	self.stop = RealTime() + 0.1
	self.animating = true

	self.wNum = 0
	self.pType = "NULL"
	self.pLength = 0
	self.pMessage = ""
	self.sMessage = ""

end
function PANEL:SetInfo( tbl )
	self.wNum = tbl.warnings or 0
	self.pType = tbl.pType or "NULL"
	self.pLength = tbl.pLength or 0
	self.pMessage = tbl.pMessage or "NULL"
	self.sMessage = tbl.sMessage or "NULL"
	self.pGroup = tbl.pGroup or "NULL"
	self.pCommand = tbl.pCommand or "NULL"
	
	
	self:SetTooltip( ([[
	%s: %u     %s: %s     %s: %u
	%s: %s
	%s: %s]]):format(AWarn.Localization:GetTranslation( "warnings" ), self.wNum, AWarn.Localization:GetTranslation( "punishtype" ), self.pType, AWarn.Localization:GetTranslation( "punishlength" ), self.pLength, AWarn.Localization:GetTranslation( "playermessage" ), self.pMessage, AWarn.Localization:GetTranslation( "servermessage" ), self.sMessage) )
end
function PANEL:Paint()
	
	if self.hovered == true then
		surface.SetDrawColor( AWarn.Colors.COLOR_BUTTON_HOVERED )
	else
		surface.SetDrawColor( AWarn.Colors.COLOR_BUTTON )
	end
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
		
	surface.SetFont( "AWarn3CardText2" )
	local text = AWarn.Localization:GetTranslation( "warnings" ) .. ":"
	local tW, tH = surface.GetTextSize( text )
	local x = 10 * screenscale
	local y = 6 * screenscale
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	surface.SetTextPos( x, y )
	surface.DrawText( text )
		
	text = self.wNum 
	x = x + tW + 6 * screenscale
	y = y
	tW, tH = surface.GetTextSize( text )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
	surface.SetTextPos( x, y )
	surface.DrawText( text )
	
	
	text = AWarn.Localization:GetTranslation( "punishtype" ) .. ":"
	x = x + tW + 30 * screenscale
	y = y
	tW, tH = surface.GetTextSize( text )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	surface.SetTextPos( x, y )
	surface.DrawText( text )
		
	text = self.pType
	x = x + tW + 6 * screenscale
	y = y
	tW, tH = surface.GetTextSize( text )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
	surface.SetTextPos( x, y )
	surface.DrawText( text )
	
	if self.pType == "ban" then

		text = AWarn.Localization:GetTranslation( "punishlength" ) .. ":"
		x = x + tW + 30 * screenscale
		y = y
		tW, tH = surface.GetTextSize( text )
		surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
		surface.SetTextPos( x, y )
		surface.DrawText( text )
			
		text = self.pLength
		x = x + tW + 6 * screenscale
		y = y
		tW, tH = surface.GetTextSize( text )
		surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
		surface.SetTextPos( x, y )
		surface.DrawText( text )
	
	end
	
	if self.pType == "group" then

		text = AWarn.Localization:GetTranslation( "punishgroup" ) .. ":"
		x = x + tW + 30 * screenscale
		y = y
		tW, tH = surface.GetTextSize( text )
		surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
		surface.SetTextPos( x, y )
		surface.DrawText( text )
			
		text = self.pGroup
		x = x + tW + 6 * screenscale
		y = y
		tW, tH = surface.GetTextSize( text )
		surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
		surface.SetTextPos( x, y )
		surface.DrawText( text )
	
	end
	
	if self.pType == "command" then

		text = AWarn.Localization:GetTranslation( "customcommand" ) .. ":"
		x = x + tW + 30 * screenscale
		y = y
		tW, tH = surface.GetTextSize( text )
		surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
		surface.SetTextPos( x, y )
		surface.DrawText( text )
			
		text = self.pCommand
		x = x + tW + 6 * screenscale
		y = y
		tW, tH = surface.GetTextSize( text )
		surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
		surface.SetTextPos( x, y )
		surface.DrawText( text )
	
	end
	
				
	local text = AWarn.Localization:GetTranslation( "playermessage" ) .. ":"
	local x = 10 * screenscale
	local y = 22 * screenscale
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	surface.SetTextPos( x, y )
	surface.DrawText( text )
		
	text = self.pMessage
	x = x + tW + 6 * screenscale
	y = y
	tW, tH = surface.GetTextSize( text )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
	surface.SetTextPos( x, y )
	surface.DrawText( text )
	
			
	local text = AWarn.Localization:GetTranslation( "servermessage" ) .. ":"
	local x = 10 * screenscale
	local y = 38 * screenscale
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	surface.SetTextPos( x, y )
	surface.DrawText( text )
		
	text = self.sMessage
	x = x + tW + 6 * screenscale
	y = y
	tW, tH = surface.GetTextSize( text )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
	surface.SetTextPos( x, y )
	surface.DrawText( text )

end
function PANEL:Think()
	if self:IsHovered() and not self.hovered then
		self.hovered = true
	elseif self.hovered and not self:IsHovered() then
		self.hovered = false
	end
	self:AnimateThink()
end
function PANEL:AnimateThink()
	if not self.animating then return end
	if RealTime() < self.stop then
		local easingsX = easings.outCubic( RealTime() - self.start, 0, self:GetWide(), 0.1 )
		local x, y = self:GetPos()
		local easeAmt = ( easingsX * -1 ) + self:GetWide()
		self:SetPos( easeAmt, y )
	else
		local x, y = self:GetPos()
		self.animating = false
	end
end
function PANEL:DrawElements( pl )
	local deleteButtonFrame = vgui.Create( "DPanel", self )
	deleteButtonFrame:SetWidth( 80 * screenscale )
	deleteButtonFrame:Dock( RIGHT )
	deleteButtonFrame.Paint = function()
	end

	local deleteButton = vgui.Create( "awarn3_iconbutton", deleteButtonFrame )
	deleteButton:SetTooltip(AWarn.Localization:GetTranslation( "deletewarning" ))
	deleteButton:SetSize(24 * screenscale, 24 * screenscale)
	deleteButton:SetIcon( xImage )
	deleteButton:SetPos( 10 * screenscale, 12 * screenscale )
	deleteButton.OnSelected = function()
		AWarn.Punishments[ self.wNum ] = nil
		self.hdiv:Remove()
		self:Remove()
		local cardNum = #AWarn.menu.configurationview.PunishmentsCardsPanel:GetCanvas():GetChildren()
		AWarn.menu.configurationview.PunishmentsCardsPanel:SetHeight( math.Clamp( ( 60 * screenscale ) * cardNum, 100, 300 ) )
		AWarn:SavePunishments()
	end
end
function PANEL:OnMousePressed( key )
	--self.wNum = tbl.warnings or 0
	--self.pType = tbl.pType or "NULL"
	--self.pLength = tbl.pLength or 0
	--self.pMessage = tbl.pMessage or "NULL"
	--self.sMessage = tbl.sMessage or "NULL"
	if key == MOUSE_LEFT then
		AWarn.punishmentCreationFields.pActiveWarningsTxtBox:SetValue( self.wNum )
		AWarn.punishmentCreationFields.pMessageToPlayerTxtBox:SetValue( self.pMessage )
		AWarn.punishmentCreationFields.pMessageToServerTxtBox:SetValue( self.sMessage )
		AWarn.punishmentCreationFields.pPunishmentLengthTxtBox:SetValue( self.pLength )
		AWarn.punishmentCreationFields.pTypeDropdown:ChooseOptionID( table.KeyFromValue( AWarn.punishmentCreationFields.pTypeDropdown.Choices, string.SetChar( self.pType, 1, string.upper( string.Left( self.pType, 1 ) ) ) ) )
		if self.pType == "group" then
			AWarn.punishmentCreationFields.pPunishmentGroupDropdown:ChooseOptionID( table.KeyFromValue( AWarn.punishmentCreationFields.pPunishmentGroupDropdown.Choices, self.pGroup, 1 ) )
		end
		if self.pType == "command" then
			AWarn.punishmentCreationFields.pPunishmentCommandTxtBox:SetValue( self.pCommand )
		end
	end
end
vgui.Register( "awarn3_punishmentcard", PANEL )

function AWarn:SavePunishments()
	net.Start( "awarn3_networkpunishments" )
	net.WriteString( "write" )
	net.WriteTable( AWarn.Punishments )
	net.SendToServer()
end



local PANEL = {}
function PANEL:Init()
	self.start = RealTime()
	self.stop = RealTime() + 0.5
	self.animating = true
	self:SetWide( ScrWM() * 0.25 )
	self:SetTall( ScrHM() * 0.28 )
	self.dX = ScrWM() / 2 - self:GetWide() / 2
	self.dY = ScrHM() / 2 - self:GetTall() / 2
	self:SetPos( ScrWM(), self.dY )
	self:DrawElements()
	self.animspeed = 30
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	
	self.ptype = "kick"

end
function PANEL:Paint()
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
	surface.SetFont( "AWarn3Label2" )
	local text = AWarn.Localization:GetTranslation( "punishaddmenu" )
	local x = 12 * screenscale
	local y = 8 * screenscale
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	surface.SetTextPos( x, y )
	surface.DrawText( text )
	
	surface.SetFont( "AWarn3CardText1" )
	
	local text = AWarn.Localization:GetTranslation( "warnings" ) .. ":"
	local x = 18 * screenscale
	local y = 35 * screenscale
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	surface.SetTextPos( x, y )
	surface.DrawText( text )
	
	local text = AWarn.Localization:GetTranslation( "punishtype" ) .. ":"
	local x = 115 * screenscale
	local y = 35 * screenscale
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	surface.SetTextPos( x, y )
	surface.DrawText( text )
	
	if self.ptype == "ban" then
		local text = AWarn.Localization:GetTranslation( "punishlength" ) .. ":"
		local x = 250 * screenscale
		local y = 35 * screenscale
		surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
		surface.SetTextPos( x, y )
		surface.DrawText( text )
		
		surface.SetFont( "AWarn3CardText2" )
		local text = "(" .. AWarn.Localization:GetTranslation( "inminutes" ) .. ")"
		local x = 318 * screenscale
		local y = 54 * screenscale
		surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
		surface.SetTextPos( x, y )
		surface.DrawText( text )
		
		local text = AWarn.Localization:GetTranslation( "0equalperma" )
		local x = 312 * screenscale
		local y = 65 * screenscale
		surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
		surface.SetTextPos( x, y )
		surface.DrawText( text )
		
		
		surface.SetFont( "AWarn3CardText1" )
		
	end
	
	local text = AWarn.Localization:GetTranslation( "messagetoplayer" ) .. ":"
	local x = 18 * screenscale
	local y = 85 * screenscale
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	surface.SetTextPos( x, y )
	surface.DrawText( text )
	
	local text = AWarn.Localization:GetTranslation( "messagetoserver" ) .. ":"
	local x = 18 * screenscale
	local y = 130 * screenscale
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	surface.SetTextPos( x, y )
	surface.DrawText( text )
	
	surface.SetFont( "AWarn3CardText2" )
	
	local text = AWarn.Localization:GetTranslation( "use%" ) .. ":"
	local x = 20 * screenscale
	local y = 172 * screenscale
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
	surface.SetTextPos( x, y )
	surface.DrawText( text )
	
	surface.SetFont( "AWarn3CardText1" )
	
end
function PANEL:Think()
	if not self.animating then return end
	if RealTime() < self.stop then
		local easingsX = easings.outCubic( RealTime() - self.start, 0, self.dX + self:GetWide(), 0.5 )
		local x, y = self:GetPos()
		self:SetPos( ScrWM() + easingsX * -1, y )
	else
		local x, y = self:GetPos()
		self:SetPos( self.dX, y )
		self.animating = false
	end
end
function PANEL:DrawElements()
	local dockmargin = 6 * screenscale
		
	local closeButton = vgui.Create( "awarn3_iconbutton", self )
	closeButton:SetTooltip( AWarn.Localization:GetTranslation( "closemenu" ) )
	closeButton:SetSize(16 * screenscale, 16 * screenscale)
	closeButton:SetPos( self:GetWide() - closeButton:GetWide() - 6 * screenscale, 6 * screenscale )
	closeButton.OnSelected = function()
		self:Remove()
	end
	
	local x = 20 * screenscale
	
	local txtWarningNum = vgui.Create( "DTextEntry", self )
	txtWarningNum:SetPos( 20 * screenscale, 55 * screenscale)
	txtWarningNum:SetSize( 50 * screenscale, 20 * screenscale )
	txtWarningNum:SetText( "1" )
	txtWarningNum:SetNumeric( true )
	
	local comboBoxPunishType = vgui.Create( "DComboBox", self )
	comboBoxPunishType:SetPos( 117 * screenscale, 55 * screenscale )
	comboBoxPunishType:SetSize( 50 * screenscale, 20 * screenscale )
	comboBoxPunishType:SetValue( "Kick" )
	comboBoxPunishType:AddChoice( "Kick" )
	comboBoxPunishType:AddChoice( "Ban" )
	comboBoxPunishType:AddChoice( "Rank" )
	
	local txtPunishLen = vgui.Create( "DTextEntry", self )
	txtPunishLen:SetPos( 252 * screenscale, 55 * screenscale)
	txtPunishLen:SetSize( 50 * screenscale, 20 * screenscale )
	txtPunishLen:SetText( "1" )
	txtPunishLen:SetNumeric( true )
	txtPunishLen:SetVisible( false )
	comboBoxPunishType.OnSelect = function( self, index, value )
		if value == "Ban" then
			txtPunishLen:SetVisible( true )
			self:GetParent().ptype = "ban"
		else
			txtPunishLen:SetVisible( false )
			self:GetParent().ptype = "kick"
		end
	end
	
	local txtPlayerMessage = vgui.Create( "DTextEntry", self )
	txtPlayerMessage:SetPos( 20 * screenscale, 105 * screenscale)
	txtPlayerMessage:SetSize( self:GetWide() - 40, 20 * screenscale )
	
	local txtServerMessage = vgui.Create( "DTextEntry", self )
	txtServerMessage:SetPos( 20 * screenscale, 150 * screenscale)
	txtServerMessage:SetSize( self:GetWide() - 40, 20 * screenscale )
	
	
	local addPunishmentButton = vgui.Create( "awarn3_button", self )
	addPunishmentButton:SetText( AWarn.Localization:GetTranslation( "addpunishment" ) )
	addPunishmentButton:Dock( BOTTOM )
	addPunishmentButton:DockMargin( dockmargin, 0, dockmargin, dockmargin )
	addPunishmentButton.OnSelected = function()
		if txtPlayerMessage:GetValue() == "" or txtServerMessage:GetValue() == "" then return end
		AWarn.Punishments[ tonumber( txtWarningNum:GetValue() ) ] = { pType = comboBoxPunishType:GetValue():lower(), warnings = tonumber( txtWarningNum:GetValue() ), pMessage = txtPlayerMessage:GetValue(), sMessage = txtServerMessage:GetValue() }
		if comboBoxPunishType:GetValue() == "Ban" then
			AWarn.Punishments[ tonumber( txtWarningNum:GetValue() ) ].pLength = tonumber( txtPunishLen:GetValue() )
		end
		self:Remove()
		AWarn:RefreshPunishments()
		AWarn:SavePunishments()
	end
	
end
vgui.Register( "awarn3_addpunishmentdialog", PANEL, "DFrame" )


local PANEL = {}
function PANEL:Init()
	self.text = ""
	self:SetHeight( 30 )
	self.font = "AWarn3Label1"
	self.align = "left"
end
function PANEL:Paint()
	surface.SetFont( self.font )
	local tW, tH = surface.GetTextSize( self.text )
	local x = self:GetWide() / 2 - tW / 2
	if self.align == "left" then
		x = 4
	end
	local y = self:GetTall() / 2 - tH / 2
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	surface.SetTextPos( x, y )
	surface.DrawText( self.text )
end
function PANEL:SetFont( font )
	self.font = font
end
function PANEL:SetText( txt )
	self.text = txt
end
vgui.Register( "awarn3_configlabel", PANEL )



local PANEL = {}
function PANEL:Init()
	self:SetHeight( 10 * screenscale )
end
function PANEL:Paint()
	--Render Invisible
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_SECONDARY )
	surface.DrawRect( 3 * screenscale, self:GetTall() / 2 - 1 * screenscale, self:GetWide() - 6 * screenscale, 3 * screenscale )
end
vgui.Register( "awarn3_hdiv", PANEL )


local PANEL = {}
function PANEL:Init()
	self:SetWidth( 2 * screenscale )
end
function PANEL:Paint()
	--Render Invisible
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
	surface.DrawRect( self:GetWide() / 2 - 1 * screenscale, 2 * screenscale, 2 * screenscale, self:GetTall() - 74 * screenscale )
end
vgui.Register( "awarn3_vdiv", PANEL )



local PANEL = {}
function PANEL:Init()
	self.paused = true
	self.start = RealTime()
	self.stop = RealTime() + 0.5
	self.animating = true
	self:SetWide( 250 * screenscale )
	self:SetTall( 225 * screenscale )
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self.optionColor = nil
	self:DrawElements()
	self.parentbutton = nil
end
function PANEL:Paint()
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
		
	surface.SetFont( "AWarn3Label1" )
	local text = AWarn.Localization:GetTranslation( "colorselection" ) 
	local tW, tH = surface.GetTextSize( text )
	local x = self:GetWide() / 2 - tW / 2
	local y = 6 * screenscale
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	surface.SetTextPos( x, y )
	surface.DrawText( text )
end
function PANEL:SetOptionColor( col )
	self.optionColor = col
	self.Mixer:SetColor( AWarn.Colors[ col ] )
	self.paused = false
end
function PANEL:SetParentButton( pnl )
	self.parentbutton = pnl
end
function PANEL:Think()
	self:AnimatePanel()
	self:CheckClose()
end
function PANEL:CheckClose()
    if not input.IsMouseDown( MOUSE_LEFT ) then return end

    local x, y = self:GetPos()
    local mx, my = input.GetCursorPos()
    local w, h = self:GetSize()

    local minsX = x
    local maxsX = x + w
    local minsY = y
    local maxsY = y + h
	
    if mx < minsX or mx > maxsX then
        return self:Remove()
    end

    if my < minsY or my > maxsY then
        return self:Remove()
    end
end
function PANEL:AnimatePanel()
	if not self.animating then return end
	if RealTime() < self.stop then

	else
		self.animating = false
	end
end
function PANEL:DrawElements()
	local dockmargin = 6 * screenscale
	
	self.Mixer = vgui.Create( "DColorMixer", self )
	self.Mixer:Dock( TOP )
	self.Mixer:SetTall( 160 )
	self.Mixer:SetPalette( false )
	self.Mixer:SetAlphaBar( false )
	self.Mixer:SetWangs( true )
	self.Mixer:SetColor( Color( 30, 100, 160 ) )
	function self.Mixer:ValueChanged( col )
		if self:GetParent().paused then return end
		local nC = Color( col.r, col.g, col.b, AWarn.ColorsBackup[ self:GetParent().optionColor ].a )
		self:GetParent().parentbutton:SetColor( nC )
		AWarn.Colors[ self:GetParent().optionColor ] = nC
	end
		
	local warnButton = vgui.Create( "awarn3_button", self )
	warnButton:SetText( AWarn.Localization:GetTranslation( "setdefault" ) )
	warnButton:Dock( BOTTOM )
	warnButton:DockMargin( 0, 0, 0, 0 )
	warnButton:SetEnabled( true )
	warnButton.OnSelected = function()
		self.Mixer:SetColor( AWarn.ColorsBackup[ self.optionColor ] )
	end
end
vgui.Register( "awarn3_colorpicker", PANEL, "DFrame" )





local PANEL = {}
function PANEL:Init()
	self:Dock( FILL )
	self:DrawElements()
end
function PANEL:Paint()
	--Render Invisible
	surface.SetDrawColor( 200, 100, 100, 50 )
	--surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
end
function PANEL:DrawElements()

	local headerPanel = vgui.Create( "DPanel", self )
	headerPanel:SetHeight( 60 * screenscale )
	headerPanel:Dock( TOP )
	headerPanel:DockMargin( 8 * screenscale, 8 * screenscale, 8 * screenscale, 8 * screenscale )
	headerPanel.Paint = function()	
		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
		surface.DrawRect( 0, 0, headerPanel:GetWide() - 3 * screenscale, headerPanel:GetTall() - 3 * screenscale )

		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
		surface.DrawRect( headerPanel:GetWide() - 3 * screenscale, 0, 3 * screenscale, headerPanel:GetTall() - 1 )
		surface.DrawRect( 0, headerPanel:GetTall() - 3 * screenscale, headerPanel:GetWide() - 3 * screenscale, 3 * screenscale )
			
		surface.SetFont( "AWarn3Label1" )
		local text = AWarn.Localization:GetTranslation( "showingownwarnings" )
		local tW, tH = surface.GetTextSize( text )
		local x = headerPanel:GetWide() / 2 - tW / 2
		local y = headerPanel:GetTall() / 2 - tH / 2
		surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
		surface.SetTextPos( x, y )
		surface.DrawText( text )
		
		
						
		surface.SetDrawColor( AWarn.Colors.COLOR_RED_BUTTON )
		surface.SetMaterial( activeWarnings )
		surface.DrawTexturedRect( headerPanel:GetWide() - 60 * screenscale , headerPanel:GetTall() - 26 * screenscale, 16 * screenscale, 16 * screenscale )
				
		surface.SetFont( "AWarn3Label1" )
		surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
		local text = LocalPlayer():GetActiveWarnings()
		surface.SetTextPos( headerPanel:GetWide() - 40 * screenscale, headerPanel:GetTall() - 27 * screenscale )
		surface.DrawText( text )
	end

	self.WarningCardsPanel = vgui.Create( "DScrollPanel", self )
	self.WarningCardsPanel:Dock( FILL )
	self.WarningCardsPanel:DockMargin( 8 * screenscale, 0 * screenscale, 8 * screenscale, 75 * screenscale )
	self.WarningCardsPanel:GetCanvas():DockPadding( 0, 0, 0, 6 * screenscale )
	self.WarningCardsPanel.Paint = function()	
		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
		surface.DrawRect( 0, 0, self.WarningCardsPanel:GetWide() - 3 * screenscale, self.WarningCardsPanel:GetTall() - 3 * screenscale )

		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
		surface.DrawRect( self.WarningCardsPanel:GetWide() - 3 * screenscale, 0, 3 * screenscale, self.WarningCardsPanel:GetTall() - 1 )
		surface.DrawRect( 0, self.WarningCardsPanel:GetTall() - 3 * screenscale, self.WarningCardsPanel:GetWide() - 3 * screenscale, 3 * screenscale )
	end
	
	local ScrollBar = self.WarningCardsPanel:GetVBar()
	ScrollBar:SetHideButtons( true )
	ScrollBar:SetWidth( 6 * screenscale )
	function ScrollBar:Paint( w, h )
		surface.SetDrawColor( 0, 0, 0, 0 )
		surface.DrawRect( 0, 0, w, h )
	end
	function ScrollBar.btnGrip:Paint( w, h )
		surface.SetDrawColor( AWarn.Colors.COLOR_SELECTED )
		surface.DrawRect( 0, 0, w, h )
	end
	
end
vgui.Register( "awarn3_selfwarningsview", PANEL )


function AWarn:AddSelfWarningCard( tbl )
	if not IsValid( self.menu ) then return end
	if not IsValid( self.menu.selfWarningsView ) then return end
	if not IsValid( self.menu.selfWarningsView.WarningCardsPanel ) then return end

	local warningCard = vgui.Create( "awarn3_selfwarningcard" )
	self.menu.selfWarningsView.WarningCardsPanel:AddItem( warningCard )
	warningCard:Dock( TOP )
	warningCard:SetInfo( tbl )	
	
	warningCard.hdiv = vgui.Create( "awarn3_hdiv", self.ServerSettingsMenuDock )
	warningCard.hdiv:Dock( TOP )
	self.menu.selfWarningsView.WarningCardsPanel:AddItem( warningCard.hdiv )
	
end

net.Receive( "awarn3_requestownwarnings", function()
	local warningsTable = net.ReadTable()
	AWarn:PopulateOwnWarnings( warningsTable )	
end )

function AWarn:PopulateOwnWarnings( tbl )

	if not IsValid( self.menu ) then return end
	if not IsValid( self.menu.selfWarningsView ) then return end
	if not IsValid( self.menu.selfWarningsView.WarningCardsPanel ) then return end
	self.menu.selfWarningsView.WarningCardsPanel:Clear()
	
	for k, v in pairs( tbl ) do
		timer.Simple( k * 0.1, function()
			AWarn:AddSelfWarningCard( v )
		end )
	end

end

function AWarn:RequestOwnWarnings()
	net.Start("awarn3_requestownwarnings")
	net.SendToServer()
end


local PANEL = {}
function PANEL:Init()
	local dockMargin = 4 * screenscale
	self:DockMargin( dockMargin, dockMargin, dockMargin, 0 )
	self:SetHeight( 60 * screenscale )
	self:Dock( TOP )
	self.hovered = false
	self.buttonEnabled = false
	self.warninginfotbl = {}
	
	self.start = RealTime()
	self.stop = RealTime() + 0.25
	self.animating = true
	
	self.dX, self.dY = self:GetPos()
end
function PANEL:Paint()
	
	if self.hovered == true then
		surface.SetDrawColor( AWarn.Colors.COLOR_BUTTON_HOVERED )
	else
		surface.SetDrawColor( AWarn.Colors.COLOR_BUTTON )
	end
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
	if self.buttonEnabled then
		surface.SetDrawColor( AWarn.Colors.COLOR_SELECTED )
		surface.DrawRect( self:GetWide() - 10 * screenscale, 0, 8 * screenscale, self:GetTall() )
	end
		
	surface.SetFont( "AWarn3CardText1" )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	
	local x = 110 * screenscale
	
	local text = AWarn.Localization:GetTranslation( "warnedby" ) .. ":"
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( x - tW, 6 * screenscale )
	surface.DrawText( text )
	
	local text = AWarn.Localization:GetTranslation( "warningserver" ) .. ":"
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( x - tW, 22 * screenscale )
	surface.DrawText( text )	
	
	local text = AWarn.Localization:GetTranslation( "warningreason" ) .. ":"
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( x - tW, 38 * screenscale )
	surface.DrawText( text )
	
	local x = 800 * screenscale
	
	local text = AWarn.Localization:GetTranslation( "warningdate" ) .. ":"
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( x - tW, 6 * screenscale )
	surface.DrawText( text )	
	
	
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
	
	local x = 115 * screenscale
	
	local text = self.warninginfotbl.PlayerName or AWarn.Localization:GetTranslation( "nothing" )
	surface.SetTextPos( x , 6 * screenscale )
	surface.DrawText( text )	
	
	local text = self.warninginfotbl.WarningServer or AWarn.Localization:GetTranslation( "nothing" )
	surface.SetTextPos( x , 22 * screenscale )
	surface.DrawText( text )	
	
	local text = self.warninginfotbl.WarningReason or AWarn.Localization:GetTranslation( "nothing" )
	surface.SetTextPos( x , 38 * screenscale )
	surface.DrawText( text )
	
	local x = 805 * screenscale
	
	local text = os.date( "%d/%m/%Y %H:%M:%S" , self.warninginfotbl.WarningDate or 111111111 )
	surface.SetTextPos( x , 6 * screenscale )
	surface.DrawText( text )
	
	
end
function PANEL:SetEnabled( bool )
	self.buttonEnabled = bool
end
function PANEL:SetInfo( tbl )
	self.warninginfotbl = tbl
end
function PANEL:Think()
	if self:IsHovered() and not self.hovered then
		self.hovered = true
	elseif self.hovered and not self:IsHovered() then
		self.hovered = false
	end
	self:AnimateThink()
end
function PANEL:AnimateThink()
	if not self.animating then return end
	if RealTime() < self.stop then
		local easingsX = easings.outCubic( RealTime() - self.start, 0, self:GetWide(), 0.25 )
		local x, y = self:GetPos()
		local easeAmt = ( easingsX * -1 ) + self:GetWide()
		self:SetPos( easeAmt, y )
	else
		local x, y = self:GetPos()
		self.animating = false
	end
end
vgui.Register( "awarn3_selfwarningcard", PANEL )



local PANEL = {}
function PANEL:Init()
	self:Dock( FILL )
	self:DrawElements()
	self.selectedplayer = nil
	self.selectedplayerid = nil
	self.selectedplayerwarns = 0
end
function PANEL:Paint()
	--Render Invisible
	--surface.SetDrawColor( 200, 100, 100, 200 )
	--surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
end
function PANEL:DrawElements()


	local PlayerListDockPanel = vgui.Create( "DPanel", self )
	PlayerListDockPanel:SetWide( 200 * screenscale )
	PlayerListDockPanel:Dock( RIGHT )
	PlayerListDockPanel:DockMargin( 0, 8 * screenscale, 5 * screenscale, 76 * screenscale )
	PlayerListDockPanel:DockPadding( 4 * screenscale, 30 * screenscale, 4 * screenscale, 4 * screenscale )
	PlayerListDockPanel.Paint = function()
		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
		surface.DrawRect( 0, 0, PlayerListDockPanel:GetWide() - 3 * screenscale, PlayerListDockPanel:GetTall() - 3 * screenscale )

		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
		surface.DrawRect( PlayerListDockPanel:GetWide() - 3 * screenscale, 0, 3 * screenscale, PlayerListDockPanel:GetTall() - 1 )
		surface.DrawRect( 0, PlayerListDockPanel:GetTall() - 3 * screenscale, PlayerListDockPanel:GetWide() - 3 * screenscale, 3 * screenscale )
			
		surface.SetFont( "AWarn3Label2" )
		local tW, tH = surface.GetTextSize( AWarn.Localization:GetTranslation( "connectedplayers" ) )
		local x = PlayerListDockPanel:GetWide() - ( 200 * screenscale / 2 ) - tW / 2
		local y = 8 * screenscale
		surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
		surface.SetTextPos( x, y )
		surface.DrawText( AWarn.Localization:GetTranslation( "connectedplayers" ) )
	end

	self.PlayerListPanel = vgui.Create( "DScrollPanel", PlayerListDockPanel )
	self.PlayerListPanel:Dock( FILL )
	self.PlayerListPanel:DockMargin( 0, 0, 0, 10 * screenscale )
	self.PlayerListPanel:GetCanvas():DockPadding( 0, 0, 0, 6 * screenscale )
	self.PlayerListPanel.Paint = function()
		surface.SetDrawColor( 200, 200, 200, 0 )
		surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	end
	
	local warnButton = vgui.Create( "awarn3_button", PlayerListDockPanel )
	warnButton:SetText(AWarn.Localization:GetTranslation( "warnplayer" ))
	warnButton:Dock( BOTTOM )
	--warnButton.buttoncoloroverride = Color( 120, 0, 0, 200 )
	--warnButton.buttoncolorhoveroverride = Color( 140, 20, 20, 200 )
	warnButton:SetEnabled( false )
	warnButton.PostThink = function()
		if not warnButton.enabled then 
			if self.selectedplayer then warnButton:SetEnabled( true ) end
		end
	end
	warnButton.OnSelected = function()
		if IsValid( AWarn.menu.playerwarndialogue ) then AWarn.menu.playerwarndialogue:Remove() end
		AWarn.menu.playerwarndialogue = vgui.Create( "awarn3_warndialogue" )
		AWarn.menu.playerwarndialogue:MakePopup()
		AWarn.menu.playerwarndialogue:SetParent( AWarn.menu )
		AWarn.menu.playerwarndialogue:SetPlayer( self.selectedplayerid )
		AWarn.menu.playerwarndialogue:SetPlayerName( self.selectedplayer )
	end
	
	timer.Simple( 0, function() AWarn:PopulatePlayers() end ) --This needs to run in the next frame.
	
	local ScrollBar = self.PlayerListPanel:GetVBar()
	ScrollBar:SetHideButtons( true )
	ScrollBar:SetWidth( 6 * screenscale )
	function ScrollBar:Paint( w, h )
		surface.SetDrawColor( 0, 0, 0, 0 )
		surface.DrawRect( 0, 0, w, h )
	end
	function ScrollBar.btnGrip:Paint( w, h )
		surface.SetDrawColor( AWarn.Colors.COLOR_SELECTED )
		surface.DrawRect( 0, 0, w, h )
	end
	
	local playerInfoPanel = vgui.Create( "DPanel", self )
	playerInfoPanel:SetHeight( 100 * screenscale )
	playerInfoPanel:Dock( TOP )
	playerInfoPanel:DockMargin( 8 * screenscale, 8 * screenscale, 5 * screenscale, 0 )
	playerInfoPanel:DockPadding( 4 * screenscale, 30 * screenscale, 4 * screenscale, 4 * screenscale )
	playerInfoPanel.Paint = function()
		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
		surface.DrawRect( 0, 0, playerInfoPanel:GetWide() - 3 * screenscale, playerInfoPanel:GetTall() - 3 * screenscale )

		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
		surface.DrawRect( playerInfoPanel:GetWide() - 3 * screenscale, 0, 3 * screenscale, playerInfoPanel:GetTall() - 1 )
		surface.DrawRect( 0, playerInfoPanel:GetTall() - 3 * screenscale, playerInfoPanel:GetWide() - 3 * screenscale, 3 * screenscale )
		
		if AWarn.menu.adminWarningsView.selectedplayer then
			surface.SetFont( "AWarn3Label1" )
			surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
			local text = self.selectedplayer
			surface.SetTextPos( 120 * screenscale, 26 * screenscale )
			surface.DrawText( text )
			
			surface.SetFont( "AWarn3Label3" )
			local text = self.selectedplayerid
			surface.SetTextPos( 120 * screenscale, 48 * screenscale )
			surface.DrawText( text )
			
			local text = util.SteamIDFrom64( self.selectedplayerid )
			surface.SetTextPos( 120 * screenscale, 62 * screenscale )
			surface.DrawText( text )
						
			surface.SetDrawColor( AWarn.Colors.COLOR_RED_BUTTON )
			surface.SetMaterial( activeWarnings )
			surface.DrawTexturedRect( playerInfoPanel:GetWide() - 60 * screenscale , playerInfoPanel:GetTall() - 26 * screenscale, 16 * screenscale, 16 * screenscale )
					
			surface.SetFont( "AWarn3Label1" )
			surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
			local text = self.selectedplayerwarns
			surface.SetTextPos( playerInfoPanel:GetWide() - 32 * screenscale, playerInfoPanel:GetTall() - 27 * screenscale )
			surface.DrawText( text )	
		else
			surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
			surface.SetFont( "AWarn3Label1" )
			local text = AWarn.Localization:GetTranslation( "selectplayerseewarnings" )
			local tW, tH = surface.GetTextSize( text )
			surface.SetTextPos( playerInfoPanel:GetWide() / 2 - tW / 2, playerInfoPanel:GetTall() / 2 - tH / 2 )
			surface.DrawText( text )
		end
	end
	
	self.PlayerInfoAvatar = vgui.Create("AWEnhancedAvatarImage", playerInfoPanel)
	self.PlayerInfoAvatar:SetPos( playerInfoPanel:GetTall() / 2 - 40 * screenscale, playerInfoPanel:GetTall() / 2 - 40 * screenscale)
	self.PlayerInfoAvatar:SetVertices( 64 )
	--self.PlayerInfoAvatar:SetSteamID("7656197971242745", 184)
	self.PlayerInfoAvatar:SetSize(80 * screenscale, 80 * screenscale)
	
	self.WarningCardsPanel = vgui.Create( "DScrollPanel", self )
	self.WarningCardsPanel:Dock( FILL )
	self.WarningCardsPanel:DockMargin( 8 * screenscale, 5 * screenscale, 5 * screenscale, 76 * screenscale )
	self.WarningCardsPanel:GetCanvas():DockPadding( 0, 0, 0, 6 * screenscale )
	self.WarningCardsPanel.Paint = function()
		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
		surface.DrawRect( 0, 0, self.WarningCardsPanel:GetWide() - 3 * screenscale, self.WarningCardsPanel:GetTall() - 3 * screenscale )
		
		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
		surface.DrawRect( self.WarningCardsPanel:GetWide() - 3 * screenscale, 0, 3 * screenscale, self.WarningCardsPanel:GetTall() - 1 )
		surface.DrawRect( 0, self.WarningCardsPanel:GetTall() - 3 * screenscale, self.WarningCardsPanel:GetWide() - 3 * screenscale, 3 * screenscale )	
		
		if AWarn.menu.adminWarningsView.selectedplayer then	
			
			if AWarn.menu.adminWarningsView.WarningCardsPanel:GetCanvas():ChildCount() == 0 then
				surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
				surface.SetFont( "AWarn3Label1" )
				local text = AWarn.Localization:GetTranslation( "selectedplayernowarnings" )
				local tW, tH = surface.GetTextSize( text )
				local x = AWarn.menu.adminWarningsView.WarningCardsPanel:GetWide() / 2 - tW / 2
				surface.SetTextPos( x, 40 * screenscale )
				surface.DrawText( text )
			end
		
		end
		
	end
	
	local ScrollBar = self.WarningCardsPanel:GetVBar()
	ScrollBar:SetHideButtons( true )
	ScrollBar:SetWidth( 6 * screenscale )
	function ScrollBar:Paint( w, h )
		surface.SetDrawColor( 0, 0, 0, 0 )
		surface.DrawRect( 0, 0, w, h )
	end
	function ScrollBar.btnGrip:Paint( w, h )
		surface.SetDrawColor( AWarn.Colors.COLOR_SELECTED )
		surface.DrawRect( 0, 0, w, h )
	end
		
	self.subWarningButton = vgui.Create( "awarn3_iconbutton", playerInfoPanel )
	self.subWarningButton:SetTooltip(AWarn.Localization:GetTranslation( "reduceactiveby1" ))
	self.subWarningButton:SetSize(12 * screenscale, 12 * screenscale)
	self.subWarningButton:SetPos( 840 * screenscale, 8 * screenscale )
	self.subWarningButton:SetIcon( minusImage )
	self.subWarningButton:SetVisible( false )
	self.subWarningButton.OnSelected = function()
		if tonumber(self.selectedplayerwarns) > 0 then
			AWarn:AddActiveWarning( self.selectedplayerid, -1 )
			self.selectedplayerwarns = self.selectedplayerwarns - 1
		end
	end
		
	self.deleteWarningButton = vgui.Create( "awarn3_iconbutton", playerInfoPanel )
	self.deleteWarningButton:SetTooltip(
		[[Delete ALL warnings for player.
		This completely deletes their entire warning history.]]
	)
	self.deleteWarningButton:SetSize(12 * screenscale, 12 * screenscale)
	self.deleteWarningButton:SetPos( 880 * screenscale, 8 * screenscale )
	self.deleteWarningButton:SetIcon( deleteImage )
	self.deleteWarningButton:SetVisible( false )
	self.deleteWarningButton.OnSelected = function()
		AWarn:DeleteAllPlayerWarnings( self.selectedplayerid )
		self.selectedplayerwarns = 0
		self.WarningCardsPanel:Clear()
	end
		
	self.playerNotesButton = vgui.Create( "awarn3_iconbutton", playerInfoPanel )
	self.playerNotesButton:SetTooltip(AWarn.Localization:GetTranslation( "viewnotes" ))
	self.playerNotesButton:SetSize(16 * screenscale, 16 * screenscale)
	self.playerNotesButton:SetPos( 80 * screenscale, 8 * screenscale )
	self.playerNotesButton:SetIcon( playerNotes )
	self.playerNotesButton:SetVisible( false )
	self.playerNotesButton:SetIconColor( Color(0,128,255,255), Color(0,128,255,180) )
	self.playerNotesButton.OnSelected = function()
		if IsValid( AWarn.menu.playernotesdialogue ) then AWarn.menu.playernotesdialogue:Remove() end
		AWarn.menu.playernotesdialogue = vgui.Create( "awarn3_playernotesdialogue" )
		AWarn.menu.playernotesdialogue:MakePopup()
		AWarn.menu.playernotesdialogue:SetParent( AWarn.menu )
		AWarn.menu.playernotesdialogue:SetPlayer( self.selectedplayerid )
		AWarn.menu.playernotesdialogue:SetPlayerName( self.selectedplayer )
		AWarn.menu.playernotesdialogue.PlayerInfoAvatar:SetSteamID( self.selectedplayerid, 184)
		AWarn.menu.playernotesdialogue:RequestNotes( self.selectedplayerid )
	end
end
vgui.Register( "awarn3_adminwarningsview", PANEL )

function ReturnSortedPlayerTable()	
	local playerinfo = {}
	local playertable = {}
	
	for _, pl in pairs( player.GetAll() ) do
		playerinfo = { Name = pl:GetName(), Entity = pl }
		table.insert( playertable, playerinfo )
	end
	
	table.SortByMember(playertable, "Name", function(a, b) return a > b end)
	return playertable
end

function AWarn:PopulatePlayers()

	for k, v in SortedPairs( ReturnSortedPlayerTable() ) do
		AWarn:AddPlayerCard( v.Entity )
	end
end

function AWarn:AddPlayerCard( pl )
	if not IsValid( self.menu ) then return end
	if not IsValid( self.menu.adminWarningsView ) then return end
	if not IsValid( self.menu.adminWarningsView.PlayerListPanel ) then return end
	
	if not IsValid( pl ) then return end
	
	local PButton = vgui.Create( "awarn3_playerbutton" )
	self.menu.adminWarningsView.PlayerListPanel:AddItem( PButton )
	PButton:SetText( pl:GetName() )
	PButton:Dock( TOP )
	PButton:DrawElements( pl )
	PButton:SetPlayerID( AWarn:SteamID64( pl ) )
end

function AWarn:RemovePlayerCard( id )
	if not IsValid( self.menu ) then return end
	if not IsValid( self.menu.adminWarningsView ) then return end
	if not IsValid( self.menu.adminWarningsView.PlayerListPanel ) then return end
	
	for k, v in pairs( self.menu.adminWarningsView.PlayerListPanel:GetCanvas():GetChildren() ) do
		if v.playerid == id then v:Remove() end
	end
end

net.Receive( "awarn3_playerjoinandleave", function()
	local state = net.ReadString()
	
	if state == "join" then
		local pl = net.ReadEntity()
		AWarn:AddPlayerCard( pl )
	elseif state == "leave" then
		local id = net.ReadString()
		AWarn:RemovePlayerCard( id )
	end
end )

function AWarn:PopulatePlayerWarnings( tbl )

	if not IsValid( self.menu ) then return end
	if not IsValid( self.menu.adminWarningsView ) then return end
	if not IsValid( self.menu.adminWarningsView.WarningCardsPanel ) then return end
	self.menu.adminWarningsView.WarningCardsPanel:Clear()
	
	for k, v in pairs( tbl ) do
		timer.Simple( k * 0.1, function()
			AWarn:AddWarningCard( v )
		end )
	end

end

function AWarn:AddWarningCard( tbl )

	if not IsValid( self.menu ) then return end
	if not IsValid( self.menu.adminWarningsView ) then return end
	if not IsValid( self.menu.adminWarningsView.WarningCardsPanel ) then return end

	local warningCard = vgui.Create( "awarn3_adminwarningcard" )
	self.menu.adminWarningsView.WarningCardsPanel:AddItem( warningCard )
	warningCard:Dock( TOP )
	warningCard:SetInfo( tbl )
	warningCard:DrawElements()
	
	warningCard.hdiv = vgui.Create( "awarn3_hdiv", self.ServerSettingsMenuDock )
	warningCard.hdiv:Dock( TOP )
	self.menu.adminWarningsView.WarningCardsPanel:AddItem(warningCard.hdiv)
	
end

net.Receive( "awarn3_requestplayerwarnings", function()
	local netType = net.ReadString()
	
	if netType == "warnings" then
		local warningsTable = net.ReadTable()
		AWarn:PopulatePlayerWarnings( warningsTable )
	elseif netType == "info" then
		local infoTable = net.ReadTable()
		if not IsValid( AWarn.menu ) then return end
		if not IsValid( AWarn.menu.adminWarningsView ) then return end
		if #infoTable == 1 then
			AWarn.menu.adminWarningsView.selectedplayer = infoTable[1].PlayerName
			AWarn.menu.adminWarningsView.selectedplayerwarns = infoTable[1].PlayerWarnings
			AWarn.menu.adminWarningsView.selectedplayerlastwarn = infoTable[1].LastWarning
		else
			AWarn.menu.adminWarningsView.selectedplayerwarns = 0
			AWarn.menu.adminWarningsView.selectedplayerlastwarn = "N/A"
		end
	end
	
end )


local PANEL = {}
function PANEL:Init()
	local dockMargin = 4 * screenscale
	self:DockMargin( 4 * screenscale, 4 * screenscale, 7 * screenscale, 0 )
	self:SetHeight( 60 * screenscale )
	self:Dock( TOP )
	self.hovered = false
	self.buttonEnabled = false
	self.warninginfotbl = {}
	
	self:DrawElements()
	
	
	self.start = RealTime()
	self.stop = RealTime() + 0.25
	self.animating = true
	
	self.dX, self.dY = self:GetPos()
end
function PANEL:Paint()
	
	if self.hovered == true then
		surface.SetDrawColor( AWarn.Colors.COLOR_BUTTON_HOVERED )
	else
		surface.SetDrawColor( AWarn.Colors.COLOR_BUTTON )
	end
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
	if self.buttonEnabled then
		surface.SetDrawColor( AWarn.Colors.COLOR_SELECTED )
		surface.DrawRect( self:GetWide() - 10 * screenscale, 0, 8 * screenscale, self:GetTall() )
	end
		
	surface.SetFont( "AWarn3CardText1" )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	
	
	local l, _ = surface.GetTextSize( AWarn.Localization:GetTranslation( "warnedby" ) .. ":" )
	local l2, _ = surface.GetTextSize( AWarn.Localization:GetTranslation( "warningserver" ) .. ":" )
	local l3, _ = surface.GetTextSize( AWarn.Localization:GetTranslation( "warningreason`" ) .. ":" )
	
	local x = l
	if l2 > x then x = l2 end
	if l3 > x then x = l3 end
	
	
	x = x + 15 * screenscale
	--local x = 110 * screenscale
	
	local text = AWarn.Localization:GetTranslation( "warnedby" ) .. ":"
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( x - tW, 6 * screenscale )
	surface.DrawText( text )
	
	local text = AWarn.Localization:GetTranslation( "warningserver" ) .. ":"
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( x - tW, 22 * screenscale )
	surface.DrawText( text )	
	
	local text = AWarn.Localization:GetTranslation( "warningreason" ) .. ":"
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( x - tW, 38 * screenscale )
	surface.DrawText( text )
	
	local x2 = 700 * screenscale
	
	local text = AWarn.Localization:GetTranslation( "warningdate" ) .. ":"
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( x2 - tW, 6 * screenscale )
	surface.DrawText( text )	
	
	
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
	
	local x = x + 5 * screenscale
	
	local text = self.warninginfotbl.PlayerName or AWarn.Localization:GetTranslation( "nothing" )
	surface.SetTextPos( x , 6 * screenscale )
	surface.DrawText( text )	
	
	local text = self.warninginfotbl.WarningServer or AWarn.Localization:GetTranslation( "nothing" )
	surface.SetTextPos( x , 22 * screenscale )
	surface.DrawText( text )	
	
	local text = self.warninginfotbl.WarningReason or AWarn.Localization:GetTranslation( "nothing" )
	surface.SetTextPos( x , 38 * screenscale )
	surface.DrawText( text )
	
	local x = 705 * screenscale
	
	local text = os.date( "%d/%m/%Y %H:%M:%S" , self.warninginfotbl.WarningDate or 111111111 )
	surface.SetTextPos( x , 6 * screenscale )
	surface.DrawText( text )
	
	
end
function PANEL:SetEnabled( bool )
	self.buttonEnabled = bool
end
function PANEL:SetInfo( tbl )
	self.warninginfotbl = tbl
end
function PANEL:Think()
	if self:IsHovered() and not self.hovered then
		self.hovered = true
	elseif self.hovered and not self:IsHovered() then
		self.hovered = false
	end
	self:AnimateThink()
end
function PANEL:AnimateThink()
	if not self.animating then return end
	if RealTime() < self.stop then
		local easingsX = easings.outCubic( RealTime() - self.start, 0, self:GetWide(), 0.25 )
		local x, y = self:GetPos()
		local easeAmt = ( easingsX * -1 ) + self:GetWide()
		self:SetPos( easeAmt, y )
	else
		local x, y = self:GetPos()
		self.animating = false
	end
end
function PANEL:DrawElements( pl )
	local deleteButton = vgui.Create( "awarn3_iconbutton", self )
	deleteButton:SetTooltip(AWarn.Localization:GetTranslation( "deletewarning" ))
	deleteButton:SetSize(12 * screenscale, 12 * screenscale)
	deleteButton:SetPos( self:GetParent():GetWide() - deleteButton:GetWide() - 14 * screenscale, 6 * screenscale )
	deleteButton.OnSelected = function()
		AWarn:DeleteSingleWarning( self.warninginfotbl.WarningID, pl )
		self.hdiv:Remove()
		self:Remove()
	end
end
function PANEL:OnMousePressed( key )
	if key == MOUSE_RIGHT then
	
	end
end
vgui.Register( "awarn3_adminwarningcard", PANEL )




function AWarn:DeleteSingleWarning( warningID, pl )
	net.Start( "awarn3_deletesinglewarning" )
	net.WriteInt( warningID, 32 )
	net.SendToServer()
end




local PANEL = {}
function PANEL:Init()
	local dockMargin = 4 * screenscale
	self:DockMargin( 0, dockMargin, dockMargin, 0 )
	self:SetHeight( 24 * screenscale )
	self:Dock( TOP )
	self.buttonLabel = AWarn.Localization:GetTranslation( "playername" )
	self.playerid = 0
	self.buttonEnabled = false
	self.hovered = false
end
function PANEL:Paint()
	
	if self.hovered == true then
		surface.SetDrawColor( AWarn.Colors.COLOR_BUTTON_HOVERED )
	else
		surface.SetDrawColor( AWarn.Colors.COLOR_BUTTON )
	end
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
	if self.buttonEnabled then
		surface.SetDrawColor( AWarn.Colors.COLOR_SELECTED )
		surface.DrawRect( self:GetWide() - 10 * screenscale, 0, 8 * screenscale, self:GetTall() )
	end
	
	surface.SetFont( "AWarn3NavButton" )
	local tW, tH = surface.GetTextSize( self.buttonLabel or "" )
	
	surface.SetTextColor( AWarn.Colors.COLOR_BUTTON_TEXT )
	surface.SetTextPos( 30 * screenscale, ( self:GetTall() / 2 ) - tH / 2 )
	surface.DrawText( self.buttonLabel )
end
function PANEL:SetText( txt )
	self.buttonLabel = txt
end
function PANEL:SetPlayerID( id )
	self.playerid = id
end
function PANEL:SetEnabled( bool )
	self.buttonEnabled = bool
end
function PANEL:Think()
	if self:IsHovered() and not self.hovered then
		self.hovered = true
	elseif self.hovered and not self:IsHovered() then
		self.hovered = false
	end
end
function PANEL:DrawElements( pl )
	self.Avatar = vgui.Create( "AvatarImage", self )
	self.Avatar:SetSize( 20 * screenscale, 20 * screenscale )
	self.Avatar:SetPos( 2 * screenscale, 2 * screenscale )
	self.Avatar:SetPlayer( pl, 16 * screenscale )
end
function PANEL:OnMousePressed( key )
	if key == MOUSE_LEFT then
		if IsValid( AWarn.lastSelectedPlayerButton ) then AWarn.lastSelectedPlayerButton:SetEnabled( false ) end
		self:SetEnabled( true )
		AWarn.lastSelectedPlayerButton = self
		AWarn:RequestWarningsForPlayer( self.playerid )
		if string.Left(tostring(self.playerid), 3) == "Bot" then
			AWarn.menu.adminWarningsView.PlayerInfoAvatar:SetPlayer(Entity(0))
		else
			AWarn.menu.adminWarningsView.PlayerInfoAvatar:SetSteamID(tostring(self.playerid), 184)	
		end
		AWarn.menu.adminWarningsView.selectedplayerid = self.playerid
		AWarn.menu.adminWarningsView.subWarningButton:SetVisible( true )
		AWarn.menu.adminWarningsView.deleteWarningButton:SetVisible( true )
		AWarn.menu.adminWarningsView.playerNotesButton:SetVisible( true )
	end
end
vgui.Register( "awarn3_playerbutton", PANEL )

function AWarn:RequestWarningsForPlayer( PlayerID )
	net.Start( "awarn3_requestplayerwarnings" )
	net.WriteString( PlayerID or "BOT" )
	net.SendToServer()
end

function AWarn:UnselectPlayer()

	AWarn.menu.adminWarningsView.selectedplayer = nil
	AWarn.menu.adminWarningsView.selectedplayerwarns = 0
	AWarn.menu.adminWarningsView.selectedplayerid = nil
	AWarn.menu.adminWarningsView.subWarningButton:SetVisible( false )
	AWarn.menu.adminWarningsView.deleteWarningButton:SetVisible( false )
	AWarn.menu.adminWarningsView.playerNotesButton:SetVisible( false )
	if IsValid( AWarn.lastSelectedPlayerButton ) then AWarn.lastSelectedPlayerButton:SetEnabled( false ) end
	AWarn.lastSelectedPlayerButton = nil
	AWarn.menu.adminWarningsView.WarningCardsPanel:Clear()
end





local PANEL = {}
function PANEL:Init()
	local dockMargin = 4 * screenscale
	self:DockMargin( 0, dockMargin, dockMargin, dockMargin )
	self:SetHeight( 24 * screenscale )
	self.buttonLabel = "DEFAULT"
	self.hovered = false
	self.buttoncoloroverride = nil
	self.buttoncolorhoveroverride = nil
	self.buttoncolordisabledoverride = nil
	self.enabled = true
end
function PANEL:Paint()
	if self.enabled then
		if self.hovered == true then
			surface.SetDrawColor( self.buttoncolorhoveroverride or AWarn.Colors.COLOR_BUTTON_2_HOVERED )
		else
			surface.SetDrawColor( self.buttoncoloroverride or AWarn.Colors.COLOR_BUTTON_2 )
		end
	else
		surface.SetDrawColor( self.buttoncolordisabledoverride or AWarn.Colors.COLOR_BUTTON_DISABLED )
	end
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
	surface.SetFont( "AWarn3NavButton3" )
	local tW, tH = surface.GetTextSize( self.buttonLabel or "" )
	
	surface.SetTextColor( AWarn.Colors.COLOR_BUTTON_TEXT )
	surface.SetTextPos( ( self:GetWide() / 2 ) - tW / 2, ( self:GetTall() / 2 ) - tH / 2 )
	surface.DrawText( self.buttonLabel )
end
function PANEL:SetText( txt )
	self.buttonLabel = txt
end
function PANEL:Think()
	if self:IsHovered() and not self.hovered then
		self.hovered = true
	elseif self.hovered and not self:IsHovered() then
		self.hovered = false
	end
	self:PostThink()
end
function PANEL:PostThink()

end
function PANEL:SetEnabled( enabled )
	self.enabled = enabled
end
function PANEL:OnSelected()
end
function PANEL:OnMousePressed( key )
	if key == MOUSE_LEFT then
		if not self.enabled then return end
		self:OnSelected()
	end
end
vgui.Register( "awarn3_button", PANEL )


local PANEL = {}
function PANEL:Init()
	local dockMarginX = 5 * screenscale
	local dockMarginY = 3 * screenscale
	self:SetHeight( 64 * screenscale )
	self:DockMargin( dockMarginX, 0, dockMarginX, dockMarginY * 2 )
	self:Dock( TOP )
	self:DrawElements()
	self.buttonLabel = "This is a test"
	self.buttonEnabled = false
	self.hovered = false
	self.iconsize = 24
end
function PANEL:Paint()
	local bColor
	if self.buttonEnabled then
		bColor = AWarn.Colors.COLOR_BUTTON_SELECTED
	else
		if self.hovered == true then
			bColor = AWarn.Colors.COLOR_BUTTON_HOVERED
		else
			bColor = AWarn.Colors.COLOR_BUTTON
		end
	end
	
	draw.RoundedBox( 16, 0, 0, self:GetWide(), self:GetTall(), bColor)	
		
	surface.SetDrawColor( AWarn.Colors.COLOR_BUTTON_TEXT )
	surface.SetMaterial( self.icon )
	surface.DrawTexturedRect( self:GetWide() / 2 - self.iconsize * screenscale / 2, self:GetTall() / 2 - self.iconsize * screenscale / 2, self.iconsize * screenscale, self.iconsize * screenscale )
		
	surface.SetFont( "AWarn3NavButton" )
	local tW, tH = surface.GetTextSize( self.buttonLabel or "" )
	
	surface.SetTextColor( AWarn.Colors.COLOR_BUTTON_TEXT )
	surface.SetTextPos( self:GetWide() / 2 - tW / 2, self:GetTall() - tH - 10  )
	surface.DrawText( self.buttonLabel )
end
function PANEL:SetText( txt )
	self.buttonLabel = txt
end
function PANEL:SetIcon( icon, size )
	self.icon = icon
	if size then self.iconsize = size end
end
function PANEL:SetEnabled( bool )
	self.buttonEnabled = bool
end
function PANEL:DrawElements()
	
end
function PANEL:Think()
	if self:IsHovered() and not self.hovered then
		self.hovered = true
	elseif self.hovered and not self:IsHovered() then
		self.hovered = false
	end
end
function PANEL:OnSelected()
end
function PANEL:OnMousePressed( key )
	if key == MOUSE_LEFT then
		if IsValid( AWarn.lastSelectedNavButton ) then AWarn.lastSelectedNavButton:SetEnabled( false ) end
		self:SetEnabled( true )
		AWarn.lastSelectedNavButton = self
		self:OnSelected()
	end
end
vgui.Register( "awarn3_navbutton", PANEL )


local PANEL = {}
function PANEL:Init()
	local dockMarginX = 5 * screenscale
	local dockMarginY = 3 * screenscale
	self:SetHeight( 64 * screenscale )
	self:DockMargin( dockMarginX, 0, dockMarginX, dockMarginY * 2 )
	self:Dock( TOP )
	self:DrawElements()
	self.buttonLabel = "This is a test"
	self.buttonEnabled = false
	self.hovered = false
	self.iconsize = 24
end
function PANEL:Paint()
	local bColor
	if self.buttonEnabled then
		bColor = AWarn.Colors.COLOR_BUTTON_SELECTED
	else
		if self.hovered == true then
			bColor = AWarn.Colors.COLOR_BUTTON_HOVERED
		else
			bColor = AWarn.Colors.COLOR_BUTTON
		end
	end
	
	draw.RoundedBox( 16, 0, 0, self:GetWide(), self:GetTall(), bColor)	
		
	surface.SetDrawColor( AWarn.Colors.COLOR_BUTTON_TEXT )
	surface.SetMaterial( self.icon )
	surface.DrawTexturedRect( self:GetWide() / 2 - self.iconsize * screenscale / 2, self:GetTall() / 2 - self.iconsize * screenscale / 2, self.iconsize * screenscale, self.iconsize * screenscale )
		
	surface.SetFont( "AWarn3NavButton" )
	local tW, tH = surface.GetTextSize( self.buttonLabel or "" )
	
	surface.SetTextColor( AWarn.Colors.COLOR_BUTTON_TEXT )
	surface.SetTextPos( self:GetWide() / 2 - tW / 2, self:GetTall() - tH - 10  )
	surface.DrawText( self.buttonLabel )
end
function PANEL:SetText( txt )
	self.buttonLabel = txt
end
function PANEL:SetIcon( icon, size )
	self.icon = icon
	if size then self.iconsize = size end
end
function PANEL:SetEnabled( bool )
	self.buttonEnabled = bool
end
function PANEL:DrawElements()
	
end
function PANEL:Think()
	if self:IsHovered() and not self.hovered then
		self.hovered = true
	elseif self.hovered and not self:IsHovered() then
		self.hovered = false
	end
end
function PANEL:OnSelected()
end
function PANEL:OnMousePressed( key )
	if key == MOUSE_LEFT then
		if IsValid( AWarn.lastSelectedSettingsButton ) then AWarn.lastSelectedSettingsButton:SetEnabled( false ) end
		self:SetEnabled( true )
		AWarn.lastSelectedSettingsButton = self
		self:OnSelected()
	end
end
vgui.Register( "awarn3_navbutton_settings", PANEL )


local PANEL = {}
function PANEL:Init()
	local dockMarginX = 5 * screenscale
	local dockMarginY = 3 * screenscale
	self:SetHeight( 64 * screenscale )
	self:DockMargin( dockMarginX, 0, dockMarginX, dockMarginY * 2 )
	self:Dock( BOTTOM )
	self:DrawElements()
	self.buttonLabel = "This is a test"
	self.hovered = false
end
function PANEL:Paint()
	local bColor
	if self.hovered == true then
		bColor = AWarn.Colors.COLOR_BUTTON_HOVERED
	else
		bColor = AWarn.Colors.COLOR_BUTTON
	end
	
	draw.RoundedBox( 16, 0, 0, self:GetWide(), self:GetTall(), bColor)	
		
	surface.SetDrawColor( AWarn.Colors.COLOR_BUTTON_TEXT )
	surface.SetMaterial( self.icon )
	surface.DrawTexturedRect( self:GetWide() / 2 - 24 * screenscale / 2, self:GetTall() / 2 - 24 * screenscale / 2, 24 * screenscale, 24 * screenscale )
		
	surface.SetFont( "AWarn3NavButton" )
	local tW, tH = surface.GetTextSize( self.buttonLabel or "" )
	
	surface.SetTextColor( AWarn.Colors.COLOR_BUTTON_TEXT )
	surface.SetTextPos( self:GetWide() / 2 - tW / 2, self:GetTall() - tH - 10  )
	surface.DrawText( self.buttonLabel )
end
function PANEL:SetText( txt )
	self.buttonLabel = txt
end
function PANEL:SetIcon( icon )
	self.icon = icon
end
function PANEL:DrawElements()
	
end
function PANEL:Think()
	if self:IsHovered() and not self.hovered then
		self.hovered = true
	elseif self.hovered and not self:IsHovered() then
		self.hovered = false
	end
end
function PANEL:OnSelected()
end
function PANEL:OnMousePressed( key )
	if key == MOUSE_LEFT then
		self:OnSelected()
	end
end
vgui.Register( "awarn3_navbutton2", PANEL )



local PANEL = {}
function PANEL:Init()
	self.hovered = false
	self.icon = deleteImage
	self.iconcolor = AWarn.Colors.COLOR_RED_BUTTON
	self.iconcolorhovered = AWarn.Colors.COLOR_RED_BUTTON_HOVERED
end
function PANEL:Paint()
	if self.hovered then
		surface.SetDrawColor( self.iconcolorhovered )
	else
		surface.SetDrawColor( self.iconcolor )
	end
	
	surface.SetMaterial( self.icon )
	surface.DrawTexturedRect( 0, 0, self:GetWide(), self:GetTall() )
end
function PANEL:SetIcon( icon )
	self.icon = icon
end
function PANEL:SetIconColor( color, color2 )
	if color then self.iconcolor = color end
	if color2 then self.iconcolorhovered = color2 end
end
function PANEL:Think()
	if self:IsHovered() and not self.hovered then
		self.hovered = true
	elseif self.hovered and not self:IsHovered() then
		self.hovered = false
	end
end
function PANEL:OnSelected()

end
function PANEL:OnMousePressed( key )
	if key == MOUSE_LEFT then
		self:OnSelected()
	end
end
vgui.Register( "awarn3_iconbutton", PANEL )



local PANEL = {}
function PANEL:Init()
	self.start = RealTime()
	self.stop = RealTime() + 0.5
	self.animating = true
	self:SetWide( 750 * screenscale )
	self:SetTall( 410 * screenscale)
	self.dX = ScrWM() / 2 - self:GetWide() / 2
	self.dY = ScrHM() / 2 - self:GetTall() / 2
	self:SetPos( ScrWM(), self.dY )
	self:DrawElements()
	self.animspeed = 30
	self.playerid = nil
	self:SetTitle( "" )
	self:ShowCloseButton( false )

end
function PANEL:Paint()
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
	surface.DrawRect( 0, 0, self:GetWide(), 4 )
	surface.DrawRect( 0, self:GetTall() - 4, self:GetWide(), 4 )
	surface.DrawRect( 0, 0, 4, self:GetTall() )
	surface.DrawRect( self:GetWide() - 4, 0, 4, self:GetTall() )
	
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_SECONDARY )
	surface.DrawRect( 4, 4, self:GetWide() - 8, self:GetTall() - 8)
	
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
	surface.DrawRect( 4, 4, self:GetWide() - 8, 26 * screenscale)
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
	surface.DrawRect( 4, 4 + 26 * screenscale, self:GetWide() - 8, 3 * screenscale)
	
	
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
	surface.DrawRect( 4 + 4 * screenscale, 4 + 35 * screenscale, self:GetWide() - 16 * screenscale, 78 * screenscale)
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
	surface.DrawRect( self:GetWide() - 9 * screenscale, 4 + 35 * screenscale, 3 * screenscale, 78 * screenscale)
	surface.DrawRect( 4 + 4 * screenscale, 4 + 35 * screenscale + 78 * screenscale, self:GetWide() - 13 * screenscale, 3 * screenscale)
	

	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
	local x = 5 + 4 * screenscale
	local y = 5 + 35 * screenscale + 78 * screenscale + 4 + 4 * screenscale
	surface.DrawRect( x, y, self:GetWide() - 16 * screenscale, self:GetTall() - 130 * screenscale)
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
	surface.DrawRect( x, y + self:GetTall() - 130 * screenscale, self:GetWide() - 13 * screenscale, 3 * screenscale)
	surface.DrawRect( x + self:GetWide() - 16 * screenscale, y, 3 * screenscale, self:GetTall() - 130 * screenscale)

	
	surface.SetFont( "AWarn3Label2" )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	
	local x = 12 * screenscale
	local text = AWarn.Localization:GetTranslation( "playernotes" )
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( x , 8 * screenscale )
	surface.DrawText( text )
	
	surface.SetFont( "AWarn3Label1" )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
	local text = self.playerName  or "AAA"
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( 84 * screenscale, 60 * screenscale )
	surface.DrawText( text )
	
	surface.SetFont( "AWarn3Label2" )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
	local text = self.playerid  or "AAA"
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( 84 * screenscale, 78 * screenscale )
	surface.DrawText( text )
	
end
function PANEL:SetPlayer( id )
	self.playerid = id
end
function PANEL:SetPlayerName( str )
	self.playerName = str or "ERROR"
end
function PANEL:SetNotes( str )
	self.textReason:SetValue( str or "ERROR" )
end
function PANEL:RequestNotes( id )
	AWarn:RequestNotes( id )
end
function PANEL:Think()
	if not self.animating then return end
	if RealTime() < self.stop then
		local easingsX = easings.outCubic( RealTime() - self.start, 0, self.dX + self:GetWide(), 0.5 )
		local x, y = self:GetPos()
		self:SetPos( ScrWM() + easingsX * -1, y )
	else
		local x, y = self:GetPos()
		self:SetPos( self.dX, y )
		self.animating = false
	end
end
function PANEL:DrawElements()
	
	
	local closeButton = vgui.Create( "awarn3_iconbutton", self )
	closeButton:SetTooltip(AWarn.Localization:GetTranslation( "closemenu" ))
	closeButton:SetSize( 16 * screenscale, 16 * screenscale )
	closeButton:SetPos( self:GetWide() - closeButton:GetWide() - 8 * screenscale, 8 * screenscale )
	closeButton.OnSelected = function()
		self:Remove()
	end
	
	self.PlayerInfoAvatar = vgui.Create("AWEnhancedAvatarImage", self)
	self.PlayerInfoAvatar:SetPos( 12 * screenscale, 44 * screenscale )
	self.PlayerInfoAvatar:SetVertices( 64 )
	self.PlayerInfoAvatar:SetSize(64 * screenscale, 64 * screenscale)
	
	local submitButton = vgui.Create( "awarn3_button", self )
	submitButton:SetText(AWarn.Localization:GetTranslation( "submit" ))
	submitButton:Dock( BOTTOM )
	submitButton:DockMargin( 10 * screenscale, 0, 14 * screenscale, 10 * screenscale )
	
	self.textReason = vgui.Create( "DTextEntry", self )
	self.textReason:SetHeight( self:GetTall() - 172 * screenscale )
	self.textReason:SetMultiline( true )
	self.textReason:DockMargin( 10 * screenscale, 6 * screenscale, 14 * screenscale, 6 * screenscale )
	self.textReason:Dock( BOTTOM )
	self.textReason:SetFont( "AWarn3NotesTextBoxMono" )
	
	submitButton.OnSelected = function()
		AWarn:SavePlayerNotes( self.playerid, self.textReason:GetValue() or "" )
		self:Remove()
	end

	
end
vgui.Register( "awarn3_playernotesdialogue", PANEL, "DFrame" )

net.Receive( "awarn3_notesrequest", function()
	if not IsValid( AWarn.menu.playernotesdialogue ) then return end
	local notes = net.ReadString()
	local playerID = net.ReadString()
	if not (AWarn.menu.playernotesdialogue.playerid == playerID) then return end
	AWarn.menu.playernotesdialogue:SetNotes( notes )
end )

local PANEL = {}
function PANEL:Init()
	self.start = RealTime()
	self.stop = RealTime() + 0.5
	self.animating = true
	self:SetWide( ScrWM() * 0.25 )
	self:SetTall( 240 * screenscale )
	self.dX = ScrWM() / 2 - self:GetWide() / 2
	self.dY = ScrHM() / 2 - self:GetTall() / 2
	self:SetPos( ScrWM(), self.dY )
	self:DrawElements()
	self.animspeed = 30
	self.playerid = nil
	self:SetTitle( "" )
	self:ShowCloseButton( false )

end
function PANEL:Paint()
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
	surface.DrawRect( 0, 0, self:GetWide(), 4 )
	surface.DrawRect( 0, self:GetTall() - 4, self:GetWide(), 4 )
	surface.DrawRect( 0, 0, 4, self:GetTall() )
	surface.DrawRect( self:GetWide() - 4, 0, 4, self:GetTall() )
	
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_SECONDARY )
	surface.DrawRect( 4, 4, self:GetWide() - 8, self:GetTall() - 8)
	
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
	surface.DrawRect( 4, 4, self:GetWide() - 8, 26 * screenscale)
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
	surface.DrawRect( 4, 4 + 26 * screenscale, self:GetWide() - 8, 3 * screenscale)
	
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
	surface.DrawRect( 4 + 4 * screenscale, 4 + 35 * screenscale, self:GetWide() - 16 * screenscale, self:GetTall() - 46 * screenscale)
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
	surface.DrawRect( 4 + 4 * screenscale, 4 + 35 * screenscale + self:GetTall() - 46 * screenscale, self:GetWide() - 13 * screenscale, 3 * screenscale)
	surface.DrawRect( self:GetWide() - 9 * screenscale, 4 + 35 * screenscale, 3 * screenscale,self:GetTall() - 46 * screenscale)
	
	
	surface.SetFont( "AWarn3Label2" )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	
	local x = 12 * screenscale
	local text = AWarn.Localization:GetTranslation( "playerwarningmenu" )
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( x , 8 * screenscale )
	surface.DrawText( text )
	
	
	local x = 65 * screenscale
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
	local text = self.playerName  or "AAA"
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( x + 5 * screenscale, 60 * screenscale )
	surface.DrawText( text )
	
	
	surface.SetFont( "AWarn3Label3" )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
	local text = self.playerid
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( x + 5 * screenscale, 75 * screenscale )
	surface.DrawText( text )
	
end
function PANEL:SetPlayer( id )
	self.playerid = id
	self.PlayerInfoAvatar:SetSteamID( id, 184 )
end
function PANEL:SetPlayerName( str )
	self.playerName = str or "ERROR"
end
function PANEL:Think()
	if not self.animating then return end
	if RealTime() < self.stop then
		local easingsX = easings.outCubic( RealTime() - self.start, 0, self.dX + self:GetWide(), 0.5 )
		local x, y = self:GetPos()
		self:SetPos( ScrWM() + easingsX * -1, y )
	else
		local x, y = self:GetPos()
		self:SetPos( self.dX, y )
		self.animating = false
	end
end
function PANEL:DrawElements()
	
	
	local closeButton = vgui.Create( "awarn3_iconbutton", self )
	closeButton:SetTooltip(AWarn.Localization:GetTranslation( "closemenu" ))
	closeButton:SetSize( 16 * screenscale, 16 * screenscale )
	closeButton:SetPos( self:GetWide() - closeButton:GetWide() - 8 * screenscale, 8 * screenscale )
	closeButton.OnSelected = function()
		self:Remove()
	end
	
	self.PlayerInfoAvatar = vgui.Create("AWEnhancedAvatarImage", self)
	self.PlayerInfoAvatar:SetPos( 17 * screenscale, 49 * screenscale )
	self.PlayerInfoAvatar:SetVertices( 64 )
	self.PlayerInfoAvatar:SetSize(48 * screenscale, 48 * screenscale)
	
	local warnButton = vgui.Create( "awarn3_button", self )
	warnButton:SetText(AWarn.Localization:GetTranslation( "submit" ))
	warnButton:Dock( BOTTOM )
	warnButton:DockMargin( 10 * screenscale, 0, 14 * screenscale, 10 * screenscale )
	warnButton:SetZPos(1)
	
	local textReason = vgui.Create( "DTextEntry", self )
	textReason:SetHeight( 70 * screenscale )
	textReason:SetMultiline( true )
	textReason:DockMargin( 10 * screenscale, 2 * screenscale, 14 * screenscale, 4 * screenscale )
	textReason:Dock( BOTTOM )
	textReason:SetFont( "AWarn3CardText1" )
	textReason:SetZPos(2)
	
	local presetComboBox = vgui.Create( "DComboBox", self )
	presetComboBox:SetHeight( 20 * screenscale )
	presetComboBox:DockMargin( 10 * screenscale, 6 * screenscale, 14 * screenscale, 2 * screenscale )
	presetComboBox:Dock( BOTTOM )
	presetComboBox:SetFont( "AWarn3CardText1" )
	presetComboBox:SetZPos(3)
	presetComboBox:SetValue(AWarn.Localization:GetTranslation( "chooseapreset" ))
	function presetComboBox:OnSelect( index, text, data )
		textReason:SetValue( data )
	end
	if AWarn.Presets then
		for k, v in pairs( AWarn.Presets ) do
			presetComboBox:AddChoice( k, v.pReason )
		end
	end	
	
	warnButton.OnSelected = function()
		AWarn:CreateWarningID( self.playerid, LocalPlayer():SteamID64(), textReason:GetValue() or "" )
		if self.playerid == AWarn.menu.adminWarningsView.selectedplayerid then
			AWarn:RequestWarningsForPlayer( self.playerid )
		end
		self:Remove()
	end

	
end
vgui.Register( "awarn3_warndialogue", PANEL, "DFrame" )


local PANEL = {}
function PANEL:Init()
	self.start = RealTime()
	self.stop = RealTime() + 0.5
	self.animating = true
	self:SetWide( ScrWM() * 0.5 )
	self:SetTall( ScrHM() * 0.5 )
	self.dX = ScrWM() / 2 - self:GetWide() / 2
	self.dY = ScrHM() / 2 - self:GetTall() / 2
	self:SetPos( ScrWM(), self.dY )
	self:DrawElements()
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:DockPadding(0,0,0,0)
	
	
	
	self.panelQueue = {}
	self.nextProcessTime = RealTime()
end
function PANEL:Paint()
	
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_SECONDARY )
	surface.DrawRect( 80 * screenscale, 70 * screenscale, self:GetWide(), self:GetTall() )  --Main Body
	
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
	surface.DrawRect( 0, 0, self:GetWide(), 70 * screenscale ) --Header
	
	surface.DrawRect( 0, 70 * screenscale, 80 * screenscale, self:GetTall() - 70 * screenscale ) --Left Panel
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
	surface.DrawRect( 80 * screenscale, 70 * screenscale, 3 * screenscale, self:GetTall() - 70 * screenscale ) --Left Panel Shadow
	surface.DrawRect( 80 * screenscale + 3 * screenscale, 70 * screenscale, self:GetWide() - (80 * screenscale + 3 * screenscale), 3 * screenscale ) --Header Shadow
	
	surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
	surface.DrawRect( 0, 0, self:GetWide(), 4 )
	surface.DrawRect( 0, self:GetTall() - 4, self:GetWide(), 4 )
	surface.DrawRect( 0, 0, 4, self:GetTall() )
	surface.DrawRect( self:GetWide() - 4, 0, 4, self:GetTall() )
		
	surface.SetFont( "AWarn3Label2" )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )

	local x = 420 * screenscale
	local text = AWarn.Localization:GetTranslation( "excludeplayers" )
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( x , 26 * screenscale )
	surface.DrawText( text )
	
end
function PANEL:Think()
	self:ProcessPanelQueue()
	self:AnimatePanel()
end
function PANEL:AnimatePanel()
	if not self.animating then return end
	if RealTime() < self.stop then
		local easingsX = easings.outCubic( RealTime() - self.start, 0, self.dX + self:GetWide(), 0.5 )
		local x, y = self:GetPos()
		self:SetPos( ScrWM() + easingsX * -1, y )
	else
		local x, y = self:GetPos()
		self:SetPos( self.dX, y )
		self.animating = false
	end
end
function PANEL:ProcessPanelQueue()
	if self.nextProcessTime > RealTime() then return end
	self.nextProcessTime = RealTime() + 0.02
	if #self.panelQueue <= 0 then return end
	AWarn:AddSearchPlayerCard( self.panelQueue[1] )
	table.remove( self.panelQueue, 1 )
end
function PANEL:DrawElements()


	local dockmargin = 6 * screenscale
	
	local navButtonPanel = vgui.Create( "DPanel", self )
	navButtonPanel:SetPos( 0, 70 * screenscale )
	navButtonPanel:DockPadding( 0, 10, 0, 70 * screenscale )
	navButtonPanel:SetSize( 80 * screenscale, self:GetTall() )
	navButtonPanel.Paint = function()
		--Render Invisible
		--surface.SetDrawColor( 200, 200, 200, 100 )
		--surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	end
	
	local navButton = vgui.Create( "awarn3_navbutton2", navButtonPanel )
	navButton:SetText( AWarn.Localization:GetTranslation( "closemenu" ) )
	navButton:SetIcon( closeImage )
	navButton.OnSelected = function()
		self:Remove()
	end
	
	self.PlayerCardsPanel = vgui.Create( "DScrollPanel", self )
	self.PlayerCardsPanel:SetPos( 80 * screenscale + 7 * screenscale, 70 * screenscale + 7 * screenscale )
	self.PlayerCardsPanel:SetHeight( self:GetTall() - 82 * screenscale )
	self.PlayerCardsPanel:SetWidth( self:GetWide() - (80 * screenscale + 12 * screenscale) )
	self.PlayerCardsPanel:GetCanvas():DockPadding( 0, 0, 0, 6 * screenscale )
	self.PlayerCardsPanel.Paint = function()
		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
		surface.DrawRect( 0, 0, self.PlayerCardsPanel:GetWide() - 3 * screenscale, self.PlayerCardsPanel:GetTall() - 3 * screenscale )

		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
		surface.DrawRect( self.PlayerCardsPanel:GetWide() - 3 * screenscale, 0, 3 * screenscale, self.PlayerCardsPanel:GetTall() - 1 )
		surface.DrawRect( 0, self.PlayerCardsPanel:GetTall() - 3 * screenscale, self.PlayerCardsPanel:GetWide() - 3 * screenscale, 3 * screenscale )
	end
	
	local ScrollBar = self.PlayerCardsPanel:GetVBar()
	ScrollBar:SetHideButtons( true )
	ScrollBar:SetWidth( 6 * screenscale )
	function ScrollBar:Paint( w, h )
		surface.SetDrawColor( 0, 0, 0, 0 )
		surface.DrawRect( 0, 0, w, h )
	end
	function ScrollBar.btnGrip:Paint( w, h )
		surface.SetDrawColor( AWarn.Colors.COLOR_SELECTED )
		surface.DrawRect( 0, 0, w, h )
	end
	
	local chkBox = vgui.Create( "awarn3_customcheckbox", self )// Create the checkbox
	chkBox:SetPos( 360 * screenscale, 24 * screenscale )// Set the position
	chkBox:SetSize(48 * screenscale, 24 * screenscale)
	chkBox:SetValue( 0 )
	
	local playerSearchText = vgui.Create( "DTextEntry", self )
	playerSearchText:SetSize( 300 * screenscale, 30 * screenscale )
	playerSearchText:SetMultiline( false )
	playerSearchText:SetFont( "AWarn3Label2" )
	playerSearchText:SetPos( 10 * screenscale, 20 * screenscale )	
	playerSearchText:SetEnterAllowed( true )
	playerSearchText:SetPlaceholderText( " Search by Name/SteamID64" )
	playerSearchText:SetPaintBackground(true)
	playerSearchText.OnEnter = function()
		if not ( playerSearchText:GetValue() == "" ) then
			AWarn:SendSearchString( playerSearchText:GetValue(), chkBox:GetChecked() )
		else
			return false
		end
	end
	
	local searchButton = vgui.Create( "awarn3_iconbutton", self )
	searchButton:SetTooltip(AWarn.Localization:GetTranslation( "searchforplayers" ))
	searchButton:SetIcon( searchImage )
	searchButton:SetIconColor( AWarn.Colors.COLOR_BUTTON_TEXT )
	searchButton:SetSize( 20 * screenscale, 20 * screenscale )
	searchButton:SetPos( 320 * screenscale, 25 * screenscale )
	searchButton.OnSelected = function()
		AWarn:SendSearchString( playerSearchText:GetValue(), chkBox:GetChecked() )
	end
	
end
vgui.Register( "awarn3_playersearch", PANEL, "DFrame" )




local PANEL = {}
function PANEL:Init()
	local dockMargin = 4 * screenscale
	self:DockMargin( dockMargin, dockMargin, dockMargin, 0 )
	self:SetHeight( 40 * screenscale )
	self:Dock( TOP )
	
	self.lastclicked = RealTime()
	
	self.hovered = false
	
	self.warninginfotbl = {}
		
	self.start = RealTime()
	self.stop = RealTime() + 0.1
	self.animating = true
	
	self.dX, self.dY = self:GetPos()
	
	timer.Simple( 0.5, function() if IsValid(self) then self:DrawElements() end end )
	
end
function PANEL:Paint()
	
	if self.hovered == true then
		surface.SetDrawColor( AWarn.Colors.COLOR_BUTTON_HOVERED )
	else
		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
	end
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
	surface.SetFont( "AWarn3CardText1" )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	
	
		
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	local text = AWarn.Localization:GetTranslation( "name" ) .. ":"
	local tW, tH = surface.GetTextSize( text )
	local x = tW + 5 * screenscale
	surface.SetTextPos( x - tW, 5 * screenscale )
	surface.DrawText( text )
	
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
	local text = self.warninginfotbl.PlayerName or "ERROR"
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( x + 4 * screenscale, 5 * screenscale )
	surface.DrawText( text )
	
	
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	local text = AWarn.Localization:GetTranslation( "activewarnings" ) .. ":"
	local tW, tH = surface.GetTextSize( text )
	local x = tW + 5 * screenscale
	surface.SetTextPos( x - tW, 22 * screenscale)
	surface.DrawText( text )
	
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
	local text = self.warninginfotbl.PlayerWarnings or "ERROR"
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( x + 4 * screenscale, 22 * screenscale )
	surface.DrawText( text )
	
	
	
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	local text = AWarn.Localization:GetTranslation( "lastplayed" ) .. ":"
	local tW, tH = surface.GetTextSize( text )
	local x = tW + 400 * screenscale
	surface.SetTextPos( x - tW, 5 * screenscale )
	surface.DrawText( text )
	
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
	local text = AWarn.Localization:GetTranslation( "never" )
	if self.warninginfotbl.LastPlayed and not ( self.warninginfotbl.LastPlayed == "NULL" ) then
		text = os.date( "%m/%d/%Y" , self.warninginfotbl.LastPlayed or 111111111 )
	end
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( x + 4 * screenscale, 5 * screenscale )
	surface.DrawText( text )
	
	
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	local text = AWarn.Localization:GetTranslation( "lastwarned" ) .. ":"
	local tW, tH = surface.GetTextSize( text )
	local x = tW + 400 * screenscale
	surface.SetTextPos( x - tW, 22 * screenscale )
	surface.DrawText( text )
	
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
	local text = AWarn.Localization:GetTranslation( "never" )
	if self.warninginfotbl.LastWarning and not ( self.warninginfotbl.LastWarning == "NULL" ) then
		text = os.date( "%m/%d/%Y %H:%M" , self.warninginfotbl.LastWarning or 111111111 )
	end
	local tW, tH = surface.GetTextSize( text )
	surface.SetTextPos( x + 4 * screenscale, 22 * screenscale )
	surface.DrawText( text )


end
function PANEL:SetInfo( tbl )
	self.warninginfotbl = tbl
	self:SetTooltip( AWarn.Localization:GetTranslation( "playerid" ) .. ": " .. tbl.PlayerID )
end
function PANEL:Think()
	if self:IsHovered() and not self.hovered then
		self.hovered = true
	elseif self.hovered and not self:IsHovered() then
		self.hovered = false
	end
	self:AnimateThink()
end
function PANEL:AnimateThink()
	if not self.animating then return end
	if RealTime() < self.stop then
		local easingsX = easings.outCubic( RealTime() - self.start, 0, self:GetWide(), 0.1 )
		local x, y = self:GetPos()
		local easeAmt = ( easingsX * -1 ) + self:GetWide()
		self:SetPos( easeAmt, y )
	else
		local x, y = self:GetPos()
		self.animating = false
	end
end
function PANEL:DrawElements( pl )

end
function PANEL:DoSelect()
	AWarn:UnselectPlayer()
	AWarn:RequestWarningsForPlayer( self.warninginfotbl.PlayerID )
	AWarn.menu.adminWarningsView.selectedplayerid = self.warninginfotbl.PlayerID
	AWarn.menu.adminWarningsView.subWarningButton:SetVisible( true )
	AWarn.menu.adminWarningsView.deleteWarningButton:SetVisible( true )
	AWarn.menu.adminWarningsView.playerNotesButton:SetVisible( true )
	if string.Left(tostring(self.warninginfotbl.PlayerID), 3) == "Bot" then
		AWarn.menu.adminWarningsView.PlayerInfoAvatar:SetPlayer(Entity(0))
	else
		AWarn.menu.adminWarningsView.PlayerInfoAvatar:SetSteamID(tostring(self.warninginfotbl.PlayerID), 184)	
	end
	if AWarn:CheckPermission( LocalPlayer(), "awarn_view" ) then
		AWarn.menu.adminWarningsView:Show()
	else
		AWarn.menu.selfWarningsView:Show()
	end
	AWarn.menu.configurationview:Hide()
	AWarn.menu.playersearch:Remove()
end
function PANEL:OnMousePressed( key )
	if key == MOUSE_LEFT then
			self:DoSelect()
	end
end
vgui.Register( "awarn3_searchplayercard", PANEL )






local function drawCircle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

local PANEL = {}
function PANEL:Init()
	self:SetHeight(10)
	self:SetWidth(10)
	self.Gray1 = Color(80,80,80,255)
	self.Gray2 = Color(200,200,200,255)
	self.Green1 = Color(80,110,80,255)
	self.Green2 = Color(160,255,160,255)
	self.circlePos = 3 + self:GetTall() / 2
	self.circleNewPos = self.circlePos
end
function PANEL:Paint()
	local r = self:GetTall() / 2
	if self:GetChecked() then
		draw.RoundedBox( 24, 5, (self:GetTall() / 2) - ( (self:GetTall() / 1.5) / 2 ) , self:GetWide() - 10, self:GetTall() / 1.5, self.Green1 )
		surface.SetDrawColor( self.Green2 )	
		draw.NoTexture()
		self.circleNewPos = math.floor(self:GetWide() - (r+3))
	else
		draw.RoundedBox( 24, 5, (self:GetTall() / 2) - ( (self:GetTall() / 1.5) / 2 ) , self:GetWide() - 10, self:GetTall() / 1.5, self.Gray1 )
		surface.SetDrawColor( self.Gray2 )	
		draw.NoTexture()
		self.circleNewPos = math.ceil(3 + r)
	end
	if self.circleNewPos > self.circlePos then
		self.circlePos = self.circlePos + 1
	elseif self.circleNewPos < self.circlePos then
		self.circlePos = self.circlePos - 1		
	end
	drawCircle( self.circlePos, self:GetTall() / 2 , r, 32 )
end
vgui.Register( "awarn3_customcheckbox", PANEL, "DCheckBox" )




















function AWarn:PopulateSearchPlayerWarnings( tbl, clear )
	if not IsValid( self.menu ) then return end
	if not IsValid( self.menu.playersearch ) then return end
	
	if clear then
		self.menu.playersearch.panelQueue = {}
		self.menu.playersearch.PlayerCardsPanel:Clear()
	end
	

	if #tbl > 0 then
		table.Add( self.menu.playersearch.panelQueue, tbl )
	end
end

function AWarn:AddSearchPlayerCard( tbl )

	local searchPlayerCard = vgui.Create( "awarn3_searchplayercard" )
	self.menu.playersearch.PlayerCardsPanel:AddItem( searchPlayerCard )
	searchPlayerCard:Dock( TOP )
	searchPlayerCard:SetInfo( tbl )
	
	searchPlayerCard.hdiv = vgui.Create( "awarn3_hdiv" )
	searchPlayerCard.hdiv:Dock( TOP )
	self.menu.playersearch.PlayerCardsPanel:AddItem( searchPlayerCard.hdiv )
	
end

function AWarn:SendSearchString( str, excludePlayers )
	net.Start( "awarn3_requestplayersearchdata" )
	net.WriteString( str )
	net.WriteBool( excludePlayers )
	net.SendToServer()
end

net.Receive( "awarn3_requestplayersearchdata", function()
	local page = net.ReadInt(8)
	local data = net.ReadTable()
	local toClear = false
	if page == 1 then toClear = true end
	AWarn:PopulateSearchPlayerWarnings( data, toClear )
end )


local PANEL = {}

AccessorFunc(PANEL, "vertices", "Vertices", FORCE_NUMBER) -- so you can call panel:SetVertices and panel:GetRotation
AccessorFunc(PANEL, "rotation", "Rotation", FORCE_NUMBER) -- so you can call panel:SetRotation and panel:GetRotation

function PANEL:Init()
  self.rotation = 0
  self.vertices = 4
  self.avatar = vgui.Create("AvatarImage", self)
  self.avatar:SetPaintedManually(true)
end

function PANEL:CalculatePoly(w, h)
  local poly = {}

  local x = w/2
  local y = h/2
  local radius = h/2

  table.insert(poly, { x = x, y = y })

  for i = 0, self.vertices do
    local a = math.rad((i / self.vertices) * -360) + self.rotation;
    table.insert(poly, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius })
  end

  local a = math.rad(0)
  table.insert(poly, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius })
  self.data = poly;
end

function PANEL:PerformLayout()
  self.avatar:SetSize(self:GetWide(), self:GetTall())
  self:CalculatePoly(self:GetWide(), self:GetTall())
end

function PANEL:SetPlayer(ply, size)
  self.avatar:SetPlayer(ply, size)
end

function PANEL:SetSteamID(id, size)
  self.avatar:SetSteamID(id, size)
end

function PANEL:DrawPoly( w, h )
  if (!self.data) then
    self:CalculatePoly(w, h)
  end

  surface.DrawPoly(self.data)
end

function PANEL:Paint(w, h)
	if not AWarn.menu.adminWarningsView.selectedplayer then return end
	render.ClearStencil()
	render.SetStencilEnable(true)

	render.SetStencilWriteMask(1);
	render.SetStencilTestMask(1);

	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(STENCILOPERATION_ZERO)
	render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
	render.SetStencilReferenceValue(1)

	draw.NoTexture()
	surface.SetDrawColor(color_white)
	self:DrawPoly(w, h)

	render.SetStencilFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilReferenceValue(1)

	self.avatar:PaintManual()

	render.SetStencilEnable(false)
	render.ClearStencil()
end
vgui.Register("AWEnhancedAvatarImage", PANEL)