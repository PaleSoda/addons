AddCSLuaFile()

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

local PANEL = {}
function PANEL:Init()
	self:SetDraggable( false )
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	
end
function PANEL:Paint()
	--Render Invisible
	surface.SetDrawColor( 200, 100, 100, 0 )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
end
function PANEL:DrawElements()

	AWarn.punishmentCreationFields = {}

	local SettingsButtonsDock = vgui.Create( "DPanel", self )
	SettingsButtonsDock:SetWide( 80 * screenscale )
	SettingsButtonsDock:DockMargin( 4 * screenscale, -17, 0, 73 * screenscale)
	SettingsButtonsDock:DockPadding( 0, 4 * screenscale, 3 * screenscale, 0 )
	SettingsButtonsDock.Paint = function()
		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
		surface.DrawRect( 0, 0, SettingsButtonsDock:GetWide() - 3 * screenscale, SettingsButtonsDock:GetTall() - 3 * screenscale )

		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
		surface.DrawRect( SettingsButtonsDock:GetWide() - 3 * screenscale, 0, 3 * screenscale, SettingsButtonsDock:GetTall() - 1 )
		surface.DrawRect( 0, SettingsButtonsDock:GetTall() - 3 * screenscale, SettingsButtonsDock:GetWide() - 3 * screenscale, 3 * screenscale )
	end
	SettingsButtonsDock:Dock( LEFT )

	local navButton = vgui.Create( "awarn3_navbutton_settings", SettingsButtonsDock )
	navButton:SetText(AWarn.Localization:GetTranslation( "clientoptions" ))
	navButton:SetIcon( userOptionsImage )
	navButton:SetEnabled( true )
	navButton.OnSelected = function()
		self.UserSettingsMenuDock:Show()
		if AWarn:CheckPermission( LocalPlayer(), "awarn_options" ) then
			self.ServerSettingsMenuDock:Hide()
			self.PunishmentsSettingsMenuDock:Hide()
			self.PresetsMenuDock:Hide()
		end
	end
	AWarn.lastSelectedSettingsButton = navButton

	if AWarn:CheckPermission( LocalPlayer(), "awarn_options" ) then
		local navButton = vgui.Create( "awarn3_navbutton_settings", SettingsButtonsDock )
		navButton:SetText(AWarn.Localization:GetTranslation( "serveroptions" ))
		navButton:SetIcon( serverOptionsImage )
		navButton:SetEnabled( false )
		navButton.OnSelected = function()
			self.UserSettingsMenuDock:Hide()
			self.ServerSettingsMenuDock:Show()	
			self.PunishmentsSettingsMenuDock:Hide()	
			self.PresetsMenuDock:Hide()
		end

		local navButton = vgui.Create( "awarn3_navbutton_settings", SettingsButtonsDock )
		navButton:SetText(AWarn.Localization:GetTranslation( "punishmentoptions" ))
		navButton:SetIcon( punishmentOptionsImage )
		navButton:SetEnabled( false )
		navButton.OnSelected = function()
			self.UserSettingsMenuDock:Hide()
			self.ServerSettingsMenuDock:Hide()
			self.PunishmentsSettingsMenuDock:Show()
			self.PresetsMenuDock:Hide()
		end

		local navButton = vgui.Create( "awarn3_navbutton_settings", SettingsButtonsDock )
		navButton:SetText(AWarn.Localization:GetTranslation( "warningpresets" ))
		navButton:SetIcon( optionsImage )
		navButton:SetEnabled( false )
		navButton.OnSelected = function()
			self.UserSettingsMenuDock:Hide()
			self.ServerSettingsMenuDock:Hide()
			self.PunishmentsSettingsMenuDock:Hide()
			self.PresetsMenuDock:Show()
		end
	end

	self.SettingsMenuDockMain = vgui.Create( "DPanel", self )
	self.SettingsMenuDockMain:DockMargin(8, -17, 3, 73 * screenscale)
	self.SettingsMenuDockMain:DockPadding( 0, 0, 0, 0 )
	self.SettingsMenuDockMain.Paint = function()
		--surface.SetDrawColor( Color(255,0,0,200) )
		surface.DrawRect( 0, 0, self.SettingsMenuDockMain:GetWide(), self.SettingsMenuDockMain:GetTall() )
	end
	self.SettingsMenuDockMain:Dock( FILL )

	self.UserSettingsMenuDock = vgui.Create( "DPanel", self.SettingsMenuDockMain )
	self.UserSettingsMenuDock:DockMargin( 0,0,0,0 )
	self.UserSettingsMenuDock:DockPadding( 0, 10, 0, 0 )
	self.UserSettingsMenuDock.Paint = function()
		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
		surface.DrawRect( 0, 0, self.SettingsMenuDockMain:GetWide() - 3 * screenscale, self.SettingsMenuDockMain:GetTall() - 3 * screenscale )

		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
		surface.DrawRect( self.SettingsMenuDockMain:GetWide() - 3 * screenscale, 0, 3 * screenscale, self.SettingsMenuDockMain:GetTall() - 1 )
		surface.DrawRect( 0, self.SettingsMenuDockMain:GetTall() - 3 * screenscale, self.SettingsMenuDockMain:GetWide() - 3, 3 * screenscale )
	end
	self.UserSettingsMenuDock:Dock( FILL )
	
	self.ServerSettingsMenuDock = vgui.Create( "DScrollPanel", self.SettingsMenuDockMain )
	self.ServerSettingsMenuDock:DockMargin( 0,0,4*screenscale,0 )
	self.ServerSettingsMenuDock:DockPadding( 0, 10, 0, 10 )
	self.ServerSettingsMenuDock:GetCanvas():DockMargin( 0, 50*screenscale, 0, 150 * screenscale )
	
	
	self.ServerSettingsMenuDock.Paint = function()
		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
		surface.DrawRect( 0, 0, self.SettingsMenuDockMain:GetWide() - 3 * screenscale, self.SettingsMenuDockMain:GetTall() - 3 * screenscale )

		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
		surface.DrawRect( self.SettingsMenuDockMain:GetWide() - 3 * screenscale, 0, 3 * screenscale, self.SettingsMenuDockMain:GetTall() - 1 )
		surface.DrawRect( 0, self.SettingsMenuDockMain:GetTall() - 3 * screenscale, self.SettingsMenuDockMain:GetWide() - 3, 3 * screenscale )
	end
	self.ServerSettingsMenuDock:Dock( FILL )
	self.ServerSettingsMenuDock:Hide()
	
	local ScrollBar = self.ServerSettingsMenuDock:GetVBar()
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

	self.PunishmentsSettingsMenuDock = vgui.Create( "DPanel", self.SettingsMenuDockMain )
	self.PunishmentsSettingsMenuDock:DockMargin( 0,0,0,0 )
	self.PunishmentsSettingsMenuDock:DockPadding( 0, 0, 0, 0 )
	self.PunishmentsSettingsMenuDock.Paint = function()
		--Render Invisible
		--surface.SetDrawColor( Color(0,255,0,100) )
		--surface.DrawRect( 0, 0, self.PunishmentsSettingsMenuDock:GetWide(), self.PunishmentsSettingsMenuDock:GetTall() )
	end
	self.PunishmentsSettingsMenuDock:Dock( FILL )
	self.PunishmentsSettingsMenuDock:Hide()
	

	self.PresetsMenuDock = vgui.Create( "DPanel", self.SettingsMenuDockMain )
	self.PresetsMenuDock:DockMargin( 0,0,0,0 )
	self.PresetsMenuDock:DockPadding( 0, 0, 0, 0 )
	self.PresetsMenuDock.Paint = function()
		--Render Invisible
		--surface.SetDrawColor( Color(0,255,0,100) )
		--surface.DrawRect( 0, 0, self.PresetsMenuDock:GetWide(), self.PresetsMenuDock:GetTall() )
	end
	self.PresetsMenuDock:Dock( FILL )
	self.PresetsMenuDock:Hide()
	
	
	--Client Options
	
	local optionLabel = vgui.Create( "awarn3_configlabel", self.UserSettingsMenuDock )
	optionLabel:SetText( AWarn.Localization:GetTranslation( "languageconfiguration" ) )
	optionLabel:DockMargin( 10, 10 * screenscale, 0, 15 )
	optionLabel:Dock( TOP )
	
	local LanguageOptionsPanel = vgui.Create( "DPanel", self.UserSettingsMenuDock )
	LanguageOptionsPanel:DockPadding( 20, 0, 30 * screenscale, 0 )
	LanguageOptionsPanel.Paint = function()
		--Render Invisible
		--surface.SetDrawColor( 200, 200, 120, 0 )
		--surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	end
	LanguageOptionsPanel:SetHeight( 20 * screenscale )
	LanguageOptionsPanel:Dock( TOP )
	LanguageOptionsPanel:InvalidateParent( true )
	
	local comboBox = vgui.Create( "DComboBox", LanguageOptionsPanel )
	comboBox:SetWidth(180)
	comboBox:SetFont("AWarn3Label2")
	comboBox:SetValue( AWarn.SelectedLanguage or "EN-US")
	
	for k, v in pairs( AWarn.Localization.Languages ) do
		comboBox:AddChoice( AWarn.Localization.LangCodes[k], k )
	end	
	function comboBox:OnSelect( index, text, data )
		AWarn.SelectedLanguage = data
		comboBox:SetValue( data )
		LocalPlayer():SetPData( "awarn3_lang", data )
	end
	comboBox:Dock( RIGHT )
	
	local languageLabel = vgui.Create( "awarn3_configlabel", LanguageOptionsPanel )
	languageLabel:SetText( AWarn.Localization:GetTranslation( "selectlanguage" ) )
	languageLabel:SetFont( "AWarn3Label2" )
	languageLabel:Dock( FILL )
	languageLabel:SetWidth( 100 )
	
	local hdiv = vgui.Create( "awarn3_hdiv", self.UserSettingsMenuDock )
	hdiv:Dock( TOP )
	
	local optionLabel = vgui.Create( "awarn3_configlabel", self.UserSettingsMenuDock )
	optionLabel:SetText( AWarn.Localization:GetTranslation( "theme" ) )
	optionLabel:DockMargin( 10, 10 * screenscale, 0, 15 )
	optionLabel:Dock( TOP )
	
	local ThemeOptionsPanel = vgui.Create( "DPanel", self.UserSettingsMenuDock )
	ThemeOptionsPanel:DockPadding( 20, 0, 30 * screenscale, 0 )
	ThemeOptionsPanel.Paint = function()
		--Render Invisible
		--surface.SetDrawColor( 200, 200, 120, 50 )
		--surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	end
	ThemeOptionsPanel:SetHeight( 20 * screenscale )
	ThemeOptionsPanel:Dock( TOP )
	ThemeOptionsPanel:InvalidateParent( true )
	
	local comboBox = vgui.Create( "DComboBox", ThemeOptionsPanel )
	comboBox:SetWidth(180)
	comboBox:SetFont("AWarn3Label2")
	comboBox:SetValue( AWarn.SelectedTheme or "Light")
	
	for k, v in pairs( AWarn:ReturnThemes() ) do
		comboBox:AddChoice( v.name )
	end	
	function comboBox:OnSelect( index, text, data )
		AWarn.SelectedTheme = text
		LocalPlayer():SetPData( "awarn3_theme", text )
		AWarn:SetTheme( text )
	end
	comboBox:Dock( RIGHT )
	
	local ThemeSelectLabel = vgui.Create( "awarn3_configlabel", ThemeOptionsPanel )
	ThemeSelectLabel:SetText( AWarn.Localization:GetTranslation( "themeselect" ) )
	ThemeSelectLabel:SetFont( "AWarn3Label2" )
	ThemeSelectLabel:Dock( FILL )
	ThemeSelectLabel:SetWidth( 100 )
	
	local hdiv = vgui.Create( "awarn3_hdiv", self.UserSettingsMenuDock )
	hdiv:Dock( TOP )
	
	local optionLabel = vgui.Create( "awarn3_configlabel", self.UserSettingsMenuDock )
	optionLabel:SetText( AWarn.Localization:GetTranslation( "interfacecustomizations" ) )
	optionLabel:DockMargin( 10, 10 * screenscale, 0, 15 )
	optionLabel:Dock( TOP )
	
	local BlurOptionPanel = vgui.Create( "DPanel", self.UserSettingsMenuDock )
	BlurOptionPanel:DockPadding( 20, 0, 30 * screenscale, 0 )
	BlurOptionPanel.Paint = function()
		--Render Invisible
		--surface.SetDrawColor( 200, 200, 120, 50 )
		--surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	end
	BlurOptionPanel:SetHeight( 32 * screenscale )
	BlurOptionPanel:Dock( TOP )
	BlurOptionPanel:InvalidateParent( true )
	
	local BlurSelectLabel = vgui.Create( "awarn3_configlabel", BlurOptionPanel )
	BlurSelectLabel:SetText( AWarn.Localization:GetTranslation( "enableblur" ) )
	BlurSelectLabel:SetFont( "AWarn3Label2" )
	BlurSelectLabel:Dock( FILL )
	BlurSelectLabel:SetWidth( 100 )
	
	self.chkBox = vgui.Create( "awarn3_customcheckbox", BlurOptionPanel )
	self.chkBox:SetSize(52 * screenscale, 36 * screenscale)
	self.chkBox:SetValue( 0 )
	self.chkBox:DockMargin( 0, 4 * screenscale , 52 * screenscale, 4 * screenscale )
	self.chkBox:Dock( RIGHT )
	self.chkBox:SetValue( LocalPlayer():GetPData( "awarn3_blurbackground", true ) )
	self.chkBox:SetTooltip( AWarn.Localization:GetTranslation( "enableblur" ) )
	
	function self.chkBox:OnChange( val )
		LocalPlayer():SetPData( "awarn3_blurbackground", val )
	end	
	
	
	
	
	
	--Server Options	
	
	local kickToggle = vgui.Create( "awarn3_toggleoption", self.ServerSettingsMenuDock )
	kickToggle:SetPrimaryText( AWarn.Localization:GetTranslation( "enablekickpunish" ) )
	kickToggle:SetSecondaryText( AWarn.Localization:GetTranslation( "kickpunishdescription" ) )
	kickToggle:SetOptionString( "awarn_kick" )
	kickToggle:Dock( TOP )
	kickToggle:DrawElements()
	
	local hdiv = vgui.Create( "awarn3_hdiv", self.ServerSettingsMenuDock )
	hdiv:Dock( TOP )	
	
	local banToggle = vgui.Create( "awarn3_toggleoption", self.ServerSettingsMenuDock )
	banToggle:SetPrimaryText( AWarn.Localization:GetTranslation( "enablebanpunish" ) )
	banToggle:SetSecondaryText( AWarn.Localization:GetTranslation( "banpunishdescription" ) )
	banToggle:SetOptionString( "awarn_ban" )
	banToggle:Dock( TOP )
	banToggle:DrawElements()
	
	local hdiv = vgui.Create( "awarn3_hdiv", self.ServerSettingsMenuDock )
	hdiv:Dock( TOP )	
	
	local decayToggle = vgui.Create( "awarn3_toggleoption", self.ServerSettingsMenuDock )
	decayToggle:SetPrimaryText( AWarn.Localization:GetTranslation( "enabledecay" ) )
	decayToggle:SetSecondaryText( AWarn.Localization:GetTranslation( "enabledecaydescription" ) )
	decayToggle:SetOptionString( "awarn_decay" )
	decayToggle:Dock( TOP )
	decayToggle:DrawElements()
	
	local hdiv = vgui.Create( "awarn3_hdiv", self.ServerSettingsMenuDock )
	hdiv:Dock( TOP )	
	
	local reasonReqToggle = vgui.Create( "awarn3_toggleoption", self.ServerSettingsMenuDock )
	reasonReqToggle:SetPrimaryText( AWarn.Localization:GetTranslation( "reasonrequired" ) )
	reasonReqToggle:SetSecondaryText( AWarn.Localization:GetTranslation( "reasonrequireddescription" ) )
	reasonReqToggle:SetOptionString( "awarn_reasonrequired" )
	reasonReqToggle:Dock( TOP )
	reasonReqToggle:DrawElements()
	
	local hdiv = vgui.Create( "awarn3_hdiv", self.ServerSettingsMenuDock )
	hdiv:Dock( TOP )	
	
	local banWarnResetToggle = vgui.Create( "awarn3_toggleoption", self.ServerSettingsMenuDock )
	banWarnResetToggle:SetPrimaryText( AWarn.Localization:GetTranslation( "resetafterban" ) )
	banWarnResetToggle:SetSecondaryText( AWarn.Localization:GetTranslation( "resetafterbandescription" ) )
	banWarnResetToggle:SetOptionString( "awarn_reset_after_ban" )
	banWarnResetToggle:Dock( TOP )
	banWarnResetToggle:DrawElements()
	
	local hdiv = vgui.Create( "awarn3_hdiv", self.ServerSettingsMenuDock )
	hdiv:Dock( TOP )	
	
	local logEventsToggle = vgui.Create( "awarn3_toggleoption", self.ServerSettingsMenuDock )
	logEventsToggle:SetPrimaryText( AWarn.Localization:GetTranslation( "logevents" ) )
	logEventsToggle:SetSecondaryText( AWarn.Localization:GetTranslation( "logeventsdescription" ) )
	logEventsToggle:SetOptionString( "awarn_logging" )
	logEventsToggle:Dock( TOP )
	logEventsToggle:DrawElements()
	
	local hdiv = vgui.Create( "awarn3_hdiv", self.ServerSettingsMenuDock )
	hdiv:Dock( TOP )	
	
	local warnAdminsToggle = vgui.Create( "awarn3_toggleoption", self.ServerSettingsMenuDock )
	warnAdminsToggle:SetPrimaryText( AWarn.Localization:GetTranslation( "allowwarnadmins" ) )
	warnAdminsToggle:SetSecondaryText( AWarn.Localization:GetTranslation( "allowwarnadminsdescription" ) )
	warnAdminsToggle:SetOptionString( "awarn_allow_warn_admins" )
	warnAdminsToggle:Dock( TOP )
	warnAdminsToggle:DrawElements()
	
	local hdiv = vgui.Create( "awarn3_hdiv", self.ServerSettingsMenuDock )
	hdiv:Dock( TOP )
	
	local clientJoinMessageToggle = vgui.Create( "awarn3_toggleoption", self.ServerSettingsMenuDock )
	clientJoinMessageToggle:SetPrimaryText( AWarn.Localization:GetTranslation( "clientjoinmessage" ) )
	clientJoinMessageToggle:SetSecondaryText( AWarn.Localization:GetTranslation( "clientjoinmessagedescription" ) )
	clientJoinMessageToggle:SetOptionString( "awarn_joinmessageclient" )
	clientJoinMessageToggle:Dock( TOP )
	clientJoinMessageToggle:DrawElements()
	
	local hdiv = vgui.Create( "awarn3_hdiv", self.ServerSettingsMenuDock )
	hdiv:Dock( TOP )
	
	local adminJoinMessageToggle = vgui.Create( "awarn3_toggleoption", self.ServerSettingsMenuDock )
	adminJoinMessageToggle:SetPrimaryText( AWarn.Localization:GetTranslation( "adminjoinmessage" ) )
	adminJoinMessageToggle:SetSecondaryText( AWarn.Localization:GetTranslation( "adminjoinmessagedescription" ) )
	adminJoinMessageToggle:SetOptionString( "awarn_joinmessageadmin" )
	adminJoinMessageToggle:Dock( TOP )
	adminJoinMessageToggle:DrawElements()
	
	local hdiv = vgui.Create( "awarn3_hdiv", self.ServerSettingsMenuDock )
	hdiv:Dock( TOP )
	
	local chatPrefixTextOption = vgui.Create( "awarn3_textoption", self.ServerSettingsMenuDock )
	chatPrefixTextOption:SetPrimaryText( AWarn.Localization:GetTranslation( "chatprefix" ) )
	chatPrefixTextOption:SetSecondaryText( AWarn.Localization:GetTranslation( "chatprefixdescription" ) )
	chatPrefixTextOption:SetOptionString( "awarn_chat_prefix" )
	chatPrefixTextOption:Dock( TOP )
	chatPrefixTextOption:StripSpaces( true )
	chatPrefixTextOption:DrawElements()
	
	local hdiv = vgui.Create( "awarn3_hdiv", self.ServerSettingsMenuDock )
	hdiv:Dock( TOP )
	
	local decayRateTextOption = vgui.Create( "awarn3_textoption", self.ServerSettingsMenuDock )
	decayRateTextOption:SetPrimaryText( AWarn.Localization:GetTranslation( "warningdecayrate" ) )
	decayRateTextOption:SetSecondaryText( AWarn.Localization:GetTranslation( "warningdecayratedescription" ) )
	decayRateTextOption:SetOptionString( "awarn_decayrate" )
	decayRateTextOption:Dock( TOP )
	decayRateTextOption:SetNumeric( true )
	decayRateTextOption:DrawElements()
	
	local hdiv = vgui.Create( "awarn3_hdiv", self.ServerSettingsMenuDock )
	hdiv:Dock( TOP )
	
	local serverNameTextOption = vgui.Create( "awarn3_textoption", self.ServerSettingsMenuDock )
	serverNameTextOption:SetPrimaryText( AWarn.Localization:GetTranslation( "servername" ) )
	serverNameTextOption:SetSecondaryText( AWarn.Localization:GetTranslation( "servernamedescription" ) )
	serverNameTextOption:SetOptionString( "awarn_server_name" )
	serverNameTextOption:Dock( TOP )
	serverNameTextOption:SetNumeric( false )
	serverNameTextOption:DrawElements()
	
	local hdiv = vgui.Create( "awarn3_hdiv", self.ServerSettingsMenuDock )
	hdiv:Dock( TOP )
	
	local serverLanguageComboOption = vgui.Create( "awarn3_combooption", self.ServerSettingsMenuDock )
	serverLanguageComboOption:SetPrimaryText( AWarn.Localization:GetTranslation( "selectlanguage" ) )
	serverLanguageComboOption:SetSecondaryText( AWarn.Localization:GetTranslation( "selectlanguagedescription" ) )
	serverLanguageComboOption:SetOptionString( "awarn_server_language" )
	serverLanguageComboOption:Dock( TOP )
	serverLanguageComboOption:SetOptionTable( AWarn.Localization.Languages )
	--serverLanguageComboOption.optionString = "awarn_server_language"
	serverLanguageComboOption:DrawElements()
	
	local hdiv = vgui.Create( "awarn3_hdiv", self.ServerSettingsMenuDock )
	hdiv:Dock( TOP )
	
	
	
	function AWarn:RefreshSettings()
		kickToggle:SetChecked( AWarn.Options.awarn_kick.value )
		banToggle:SetChecked( AWarn.Options.awarn_ban.value )
		decayToggle:SetChecked( AWarn.Options.awarn_decay.value )
		reasonReqToggle:SetChecked( AWarn.Options.awarn_reasonrequired.value )
		banWarnResetToggle:SetChecked( AWarn.Options.awarn_reset_after_ban.value )
		logEventsToggle:SetChecked( AWarn.Options.awarn_logging.value )
		warnAdminsToggle:SetChecked( AWarn.Options.awarn_allow_warn_admins.value )
		clientJoinMessageToggle:SetChecked( AWarn.Options.awarn_joinmessageclient.value )
		adminJoinMessageToggle:SetChecked( AWarn.Options.awarn_joinmessageadmin.value )
		chatPrefixTextOption:SetValue( AWarn.Options.awarn_chat_prefix.value )
		decayRateTextOption:SetValue( AWarn.Options.awarn_decayrate.value )
		serverNameTextOption:SetValue( AWarn.Options.awarn_server_name.value )
		serverLanguageComboOption:SetValue( AWarn.Options.awarn_server_language.value )
	end
	
	local punishmentCardsPanel = vgui.Create( "DPanel", self.PunishmentsSettingsMenuDock)
	punishmentCardsPanel:Dock( FILL )
	punishmentCardsPanel:DockPadding( 0,5,0,10 )
	punishmentCardsPanel.Paint = function()
		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
		surface.DrawRect( 0, 0, punishmentCardsPanel:GetWide() - 3 * screenscale, punishmentCardsPanel:GetTall() - 3 * screenscale )

		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
		surface.DrawRect( punishmentCardsPanel:GetWide() - 3 * screenscale, 0, 3 * screenscale, punishmentCardsPanel:GetTall() - 1 )
		surface.DrawRect( 0, punishmentCardsPanel:GetTall() - 3 * screenscale, punishmentCardsPanel:GetWide() - 3 * screenscale, 3 * screenscale )
	end

	AWarn.menu.configurationview.PunishmentsCardsPanel = vgui.Create( "DScrollPanel", punishmentCardsPanel )
	AWarn.menu.configurationview.PunishmentsCardsPanel:Dock( FILL )
	AWarn.menu.configurationview.PunishmentsCardsPanel:DockPadding( 10,10,10,10 )
	AWarn.menu.configurationview.PunishmentsCardsPanel:GetCanvas():DockPadding( 0, 4 * screenscale, 4 * screenscale, 0 )
	AWarn.menu.configurationview.PunishmentsCardsPanel.Paint = function()
		--surface.SetDrawColor( Color(255,0,0,100) )
		--surface.DrawRect( 0, 0, AWarn.menu.configurationview.PunishmentsCardsPanel:GetWide() , AWarn.menu.configurationview.PunishmentsCardsPanel:GetTall() )
	end
		
	local ScrollBar = AWarn.menu.configurationview.PunishmentsCardsPanel:GetVBar()
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
	
	local punishmentCreationDock = vgui.Create( "DPanel", self.PunishmentsSettingsMenuDock)
	punishmentCreationDock:DockMargin( 0, 5 * screenscale, 0, 0 )
	punishmentCreationDock:Dock( BOTTOM )
	punishmentCreationDock:SetHeight( 195 * screenscale )
	punishmentCreationDock.Paint = function()
		--surface.SetDrawColor( Color(100,0,0,100) )
		--surface.DrawRect( 0, 0, punishmentCreationDock:GetWide() , punishmentCreationDock:GetTall() )
	end
	
	local punishmentCreationTypePanel = vgui.Create( "DPanel", punishmentCreationDock)
	punishmentCreationTypePanel:DockMargin( 0, 0, 5 * screenscale, 0 )
	punishmentCreationTypePanel:DockPadding( 10 * screenscale, 10 * screenscale, 10 * screenscale, 10 * screenscale )
	punishmentCreationTypePanel:SetWidth( 400 * screenscale )
	punishmentCreationTypePanel:Dock( LEFT )
	punishmentCreationTypePanel.Paint = function()
		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
		surface.DrawRect( 0, 0, punishmentCreationTypePanel:GetWide() - 3 * screenscale, punishmentCreationTypePanel:GetTall() - 3 * screenscale )

		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
		surface.DrawRect( punishmentCreationTypePanel:GetWide() - 3 * screenscale, 0, 3 * screenscale, punishmentCreationTypePanel:GetTall() - 1 )
		surface.DrawRect( 0, punishmentCreationTypePanel:GetTall() - 3 * screenscale, punishmentCreationTypePanel:GetWide() - 3 * screenscale, 3 * screenscale )
	end	
	
	local Label = vgui.Create( "awarn3_configlabel", punishmentCreationTypePanel )
	Label:SetText( AWarn.Localization:GetTranslation( "punishtype" ) )
	Label:DockMargin( 0, 0, 0, 6 * screenscale )
	Label:Dock( TOP )
	
	AWarn.punishmentCreationFields.pTypeDropdown = vgui.Create( "DComboBox", punishmentCreationTypePanel )
	AWarn.punishmentCreationFields.pTypeDropdown:SetValue( "Kick" )
	AWarn.punishmentCreationFields.pTypeDropdown:AddChoice( "Kick" )
	AWarn.punishmentCreationFields.pTypeDropdown:AddChoice( "Ban" )
	if CAMI then
		AWarn.punishmentCreationFields.pTypeDropdown:AddChoice( "Group" )
	end
	AWarn.punishmentCreationFields.pTypeDropdown:AddChoice( "Command" )
	
	AWarn.punishmentCreationFields.pTypeDropdown:SetHeight( 26 * screenscale )
	AWarn.punishmentCreationFields.pTypeDropdown:Dock( TOP )
	AWarn.punishmentCreationFields.pTypeDropdown:SetFont( "AWarn3Label2" )
	
	local Label = vgui.Create( "awarn3_configlabel", punishmentCreationTypePanel )
	Label:SetText( AWarn.Localization:GetTranslation( "activewarnings" ) )
	Label:DockMargin( 0, 10 * screenscale, 0, 6 * screenscale )
	Label:Dock( TOP )
	
	AWarn.punishmentCreationFields.pActiveWarningsTxtBox = vgui.Create( "DTextEntry", punishmentCreationTypePanel )
	AWarn.punishmentCreationFields.pActiveWarningsTxtBox:SetTextInset( 8, 0 )
	AWarn.punishmentCreationFields.pActiveWarningsTxtBox:SetHeight( 26 * screenscale )
	AWarn.punishmentCreationFields.pActiveWarningsTxtBox:SetFont( "AWarn3Label2" )
	AWarn.punishmentCreationFields.pActiveWarningsTxtBox:SetNumeric( true )
	AWarn.punishmentCreationFields.pActiveWarningsTxtBox:Dock( TOP )
	AWarn.punishmentCreationFields.pActiveWarningsTxtBox:SetValue( "1" )


	local dockmargin = 6 * screenscale
	local addPunishmentButton = vgui.Create( "awarn3_button", punishmentCreationTypePanel )
	addPunishmentButton:SetText( AWarn.Localization:GetTranslation( "addpunishment" ) )
	addPunishmentButton:Dock( BOTTOM )
	
	
	
	
	
	local CreationDetailsPanelDock = vgui.Create( "DPanel", punishmentCreationDock)
	CreationDetailsPanelDock:DockMargin( 0, 0, 0, 0 )
	CreationDetailsPanelDock:DockPadding( 0,0,0,0 )
	CreationDetailsPanelDock:Dock( FILL )
	CreationDetailsPanelDock.Paint = function()
		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
		surface.DrawRect( 0, 0, CreationDetailsPanelDock:GetWide() - 3 * screenscale, CreationDetailsPanelDock:GetTall() - 3 * screenscale )

		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
		surface.DrawRect( CreationDetailsPanelDock:GetWide() - 3 * screenscale, 0, 3 * screenscale, CreationDetailsPanelDock:GetTall() - 1 )
		surface.DrawRect( 0, CreationDetailsPanelDock:GetTall() - 3 * screenscale, CreationDetailsPanelDock:GetWide() - 3 * screenscale, 3 * screenscale )
	end
	
	local punishmentCreationDetailsPanel = vgui.Create( "DScrollPanel", CreationDetailsPanelDock)
	punishmentCreationDetailsPanel:DockMargin( 0, 0, 0, 8 * screenscale )
	punishmentCreationDetailsPanel:DockPadding( 10 * screenscale, 10 * screenscale, 10 * screenscale, 10 * screenscale )	
	punishmentCreationDetailsPanel:GetCanvas():DockPadding( 10 * screenscale, 10 * screenscale, 14 * screenscale, 10 * screenscale )
	punishmentCreationDetailsPanel:Dock( FILL )
	punishmentCreationDetailsPanel.Paint = function()
		--surface.SetDrawColor( Color(255,0,0,60) )
		--surface.DrawRect( 0, 0, punishmentCreationDetailsPanel:GetWide() - 3 * screenscale, punishmentCreationDetailsPanel:GetTall() - 3 * screenscale )
	end
		
	local ScrollBar = punishmentCreationDetailsPanel:GetVBar()
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
	
	local Label1 = vgui.Create( "awarn3_configlabel", punishmentCreationDetailsPanel )
	Label1:SetText( AWarn.Localization:GetTranslation( "messagetoplayer" ) )
	Label1:DockMargin( 0, 0, 0, 6 * screenscale )
	Label1:Dock( TOP )
	Label1:SetZPos( 1 )
	
	AWarn.punishmentCreationFields.pMessageToPlayerTxtBox = vgui.Create( "DTextEntry", punishmentCreationDetailsPanel )
	AWarn.punishmentCreationFields.pMessageToPlayerTxtBox:SetHeight( 26 * screenscale )
	AWarn.punishmentCreationFields.pMessageToPlayerTxtBox:SetFont( "AWarn3Label2" )
	AWarn.punishmentCreationFields.pMessageToPlayerTxtBox:SetNumeric( false )
	AWarn.punishmentCreationFields.pMessageToPlayerTxtBox:Dock( TOP )
	AWarn.punishmentCreationFields.pMessageToPlayerTxtBox:SetPlaceholderText( AWarn.Localization:GetTranslation( "use%" ) )
	AWarn.punishmentCreationFields.pMessageToPlayerTxtBox:SetZPos( 2 )
	
	local Label2 = vgui.Create( "awarn3_configlabel", punishmentCreationDetailsPanel )
	Label2:SetText( AWarn.Localization:GetTranslation( "messagetoserver" ) )
	Label2:DockMargin( 0, 10 * screenscale, 0, 6 * screenscale )
	Label2:Dock( TOP )
	Label2:SetZPos( 3 )
	
	AWarn.punishmentCreationFields.pMessageToServerTxtBox = vgui.Create( "DTextEntry", punishmentCreationDetailsPanel )
	AWarn.punishmentCreationFields.pMessageToServerTxtBox:SetHeight( 26 * screenscale )
	AWarn.punishmentCreationFields.pMessageToServerTxtBox:SetFont( "AWarn3Label2" )
	AWarn.punishmentCreationFields.pMessageToServerTxtBox:SetNumeric( false )
	AWarn.punishmentCreationFields.pMessageToServerTxtBox:Dock( TOP )
	AWarn.punishmentCreationFields.pMessageToServerTxtBox:SetPlaceholderText( AWarn.Localization:GetTranslation( "use%" ) )
	AWarn.punishmentCreationFields.pMessageToServerTxtBox:SetZPos( 4 )
	
	local Label3 = vgui.Create( "awarn3_configlabel", punishmentCreationDetailsPanel )
	Label3:SetText( AWarn.Localization:GetTranslation( "punishlength" ) .. "  (" .. AWarn.Localization:GetTranslation( "inminutes" ) .. ")")
	Label3:DockMargin( 0, 10 * screenscale, 0, 6 * screenscale )
	Label3:Dock( TOP )
	Label3:SetVisible( false )
	Label3:SetZPos( 5 )
	
	AWarn.punishmentCreationFields.pPunishmentLengthTxtBox = vgui.Create( "DTextEntry", punishmentCreationDetailsPanel )
	AWarn.punishmentCreationFields.pPunishmentLengthTxtBox:SetHeight( 26 * screenscale )
	AWarn.punishmentCreationFields.pPunishmentLengthTxtBox:SetFont( "AWarn3Label2" )
	AWarn.punishmentCreationFields.pPunishmentLengthTxtBox:SetNumeric( true )
	AWarn.punishmentCreationFields.pPunishmentLengthTxtBox:Dock( TOP )
	AWarn.punishmentCreationFields.pPunishmentLengthTxtBox:SetPlaceholderText( AWarn.Localization:GetTranslation( "0equalperma" ) )
	AWarn.punishmentCreationFields.pPunishmentLengthTxtBox:SetVisible( false )
	AWarn.punishmentCreationFields.pPunishmentLengthTxtBox:SetZPos( 6 )
	
	local Label4 = vgui.Create( "awarn3_configlabel", punishmentCreationDetailsPanel )
	Label4:SetText( AWarn.Localization:GetTranslation( "grouptoset" ) )
	Label4:DockMargin( 0, 10 * screenscale, 0, 6 * screenscale )
	Label4:Dock( TOP )
	Label4:SetVisible( false )
	Label4:SetZPos( 7 )
	
	AWarn.punishmentCreationFields.pPunishmentGroupDropdown = vgui.Create( "DComboBox", punishmentCreationDetailsPanel )
	AWarn.punishmentCreationFields.pPunishmentGroupDropdown:SetHeight( 26 * screenscale )
	AWarn.punishmentCreationFields.pPunishmentGroupDropdown:SetFont( "AWarn3Label2" )
	AWarn.punishmentCreationFields.pPunishmentGroupDropdown:Dock( TOP )
	AWarn.punishmentCreationFields.pPunishmentGroupDropdown:SetVisible( false )
	AWarn.punishmentCreationFields.pPunishmentGroupDropdown:SetZPos( 8 )
	if CAMI then
		for k, v in pairs( CAMI.GetUsergroups() ) do
			AWarn.punishmentCreationFields.pPunishmentGroupDropdown:AddChoice( k )
		end
		AWarn.punishmentCreationFields.pPunishmentGroupDropdown:SetValue( AWarn.punishmentCreationFields.pPunishmentGroupDropdown:GetOptionText(1) )
	end
	
	local Label5 = vgui.Create( "awarn3_configlabel", punishmentCreationDetailsPanel )
	Label5:SetText( AWarn.Localization:GetTranslation( "customcommand" ) )
	Label5:DockMargin( 0, 10 * screenscale, 0, 6 * screenscale )
	Label5:Dock( TOP )
	Label5:SetVisible( false )
	Label5:SetZPos( 9 )
	
	AWarn.punishmentCreationFields.pPunishmentCommandTxtBox = vgui.Create( "DTextEntry", punishmentCreationDetailsPanel )
	AWarn.punishmentCreationFields.pPunishmentCommandTxtBox:SetHeight( 26 * screenscale )
	AWarn.punishmentCreationFields.pPunishmentCommandTxtBox:SetFont( "AWarn3Label2" )
	AWarn.punishmentCreationFields.pPunishmentCommandTxtBox:SetNumeric( false )
	AWarn.punishmentCreationFields.pPunishmentCommandTxtBox:Dock( TOP )
	AWarn.punishmentCreationFields.pPunishmentCommandTxtBox:SetPlaceholderText( AWarn.Localization:GetTranslation( "customcommandplaceholder" ) )
	AWarn.punishmentCreationFields.pPunishmentCommandTxtBox:SetVisible( false )
	AWarn.punishmentCreationFields.pPunishmentCommandTxtBox:SetZPos( 11 )
	
	
	
	AWarn.punishmentCreationFields.pTypeDropdown.OnSelect = function( self, index, value )
		if value == "Ban" then
			AWarn.punishmentCreationFields.pPunishmentLengthTxtBox:SetVisible( true )
			AWarn.punishmentCreationFields.pPunishmentGroupDropdown:SetVisible( false )
			AWarn.punishmentCreationFields.pPunishmentCommandTxtBox:SetVisible( false )
			Label3:SetVisible( true )
			Label4:SetVisible( false )
			Label5:SetVisible( false )
		elseif value == "Kick" then
			AWarn.punishmentCreationFields.pPunishmentLengthTxtBox:SetVisible( false )
			AWarn.punishmentCreationFields.pPunishmentGroupDropdown:SetVisible( false )
			AWarn.punishmentCreationFields.pPunishmentCommandTxtBox:SetVisible( false )
			Label3:SetVisible( false )
			Label4:SetVisible( false )
			Label5:SetVisible( false )
		elseif value == "Group" then
			AWarn.punishmentCreationFields.pPunishmentLengthTxtBox:SetVisible( false )
			AWarn.punishmentCreationFields.pPunishmentGroupDropdown:SetVisible( true )
			AWarn.punishmentCreationFields.pPunishmentCommandTxtBox:SetVisible( false )
			Label3:SetVisible( false )
			Label4:SetVisible( true )
			Label5:SetVisible( false )
		elseif value == "Command" then
			AWarn.punishmentCreationFields.pPunishmentLengthTxtBox:SetVisible( false )
			AWarn.punishmentCreationFields.pPunishmentGroupDropdown:SetVisible( false )
			AWarn.punishmentCreationFields.pPunishmentCommandTxtBox:SetVisible( true )
			Label3:SetVisible( false )
			Label4:SetVisible( false )
			Label5:SetVisible( true )
		end
	end
	
	addPunishmentButton.OnSelected = function()

		if AWarn.punishmentCreationFields.pMessageToPlayerTxtBox:GetValue() == "" or AWarn.punishmentCreationFields.pMessageToServerTxtBox:GetValue() == "" then return end
		
		AWarn.Punishments[ tonumber( AWarn.punishmentCreationFields.pActiveWarningsTxtBox:GetValue() ) ] = { pType = AWarn.punishmentCreationFields.pTypeDropdown:GetValue():lower(), warnings = tonumber( AWarn.punishmentCreationFields.pActiveWarningsTxtBox:GetValue() ), pMessage = AWarn.punishmentCreationFields.pMessageToPlayerTxtBox:GetValue(), sMessage = AWarn.punishmentCreationFields.pMessageToServerTxtBox:GetValue() }
		
    if AWarn.punishmentCreationFields.pTypeDropdown:GetValue() == "Ban" then
			AWarn.Punishments[ tonumber( AWarn.punishmentCreationFields.pActiveWarningsTxtBox:GetValue() ) ].pLength = tonumber( AWarn.punishmentCreationFields.pPunishmentLengthTxtBox:GetValue() or 0 )
		end
		
		if AWarn.punishmentCreationFields.pTypeDropdown:GetValue() == "Group" then
			AWarn.Punishments[ tonumber( AWarn.punishmentCreationFields.pActiveWarningsTxtBox:GetValue() ) ].pGroup =  AWarn.punishmentCreationFields.pPunishmentGroupDropdown:GetValue()
		end
		
		if AWarn.punishmentCreationFields.pTypeDropdown:GetValue() == "Command" then
			AWarn.Punishments[ tonumber( AWarn.punishmentCreationFields.pActiveWarningsTxtBox:GetValue() ) ].pCommand =  AWarn.punishmentCreationFields.pPunishmentCommandTxtBox:GetValue()
		end
		
		
		
		AWarn:RefreshPunishments()
		AWarn:SavePunishments()
		timer.Simple( 0.1, function() AWarn3_ResetPunishmentCreationFields() end )
	end
	
	
	
	
	
	local presetCardsPanel = vgui.Create( "DPanel", self.PresetsMenuDock)
	presetCardsPanel:Dock( FILL )
	presetCardsPanel:DockMargin( 0, 0, 0, 4 * screenscale )
	presetCardsPanel.Paint = function()
		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
		surface.DrawRect( 0, 0, presetCardsPanel:GetWide() - 3 * screenscale, presetCardsPanel:GetTall() - 3 * screenscale )

		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
		surface.DrawRect( presetCardsPanel:GetWide() - 3 * screenscale, 0, 3 * screenscale, presetCardsPanel:GetTall() - 1 )
		surface.DrawRect( 0, presetCardsPanel:GetTall() - 3 * screenscale, presetCardsPanel:GetWide() - 3 * screenscale, 3 * screenscale )
	end

	AWarn.menu.configurationview.PresetsCardsPanel = vgui.Create( "DScrollPanel", presetCardsPanel )
	AWarn.menu.configurationview.PresetsCardsPanel:Dock( FILL )
	AWarn.menu.configurationview.PresetsCardsPanel:DockPadding( 10,10,10,10 )
	AWarn.menu.configurationview.PresetsCardsPanel:GetCanvas():DockPadding( 0, 4 * screenscale, 4 * screenscale, 0 )
		
	local ScrollBar = AWarn.menu.configurationview.PresetsCardsPanel:GetVBar()
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
	
	
	local presetCreationPanel = vgui.Create( "DPanel", self.PresetsMenuDock)
	presetCreationPanel:SetHeight( 100 * screenscale )
	presetCreationPanel:Dock( BOTTOM )
	presetCreationPanel.Paint = function()
		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY )
		surface.DrawRect( 0, 0, presetCreationPanel:GetWide() - 3 * screenscale, presetCreationPanel:GetTall() - 3 * screenscale )

		surface.SetDrawColor( AWarn.Colors.COLOR_THEME_PRIMARY_SHADOW )
		surface.DrawRect( presetCreationPanel:GetWide() - 3 * screenscale, 0, 3 * screenscale, presetCreationPanel:GetTall() - 1 )
		surface.DrawRect( 0, presetCreationPanel:GetTall() - 3 * screenscale, presetCreationPanel:GetWide() - 3 * screenscale, 3 * screenscale )
	
	end
		
	local addEditPresetButton = vgui.Create( "awarn3_button", presetCreationPanel )
	addEditPresetButton:SetText( AWarn.Localization:GetTranslation( "addeditpreset" ) )
	addEditPresetButton:DockMargin( 8 * screenscale, 0, 10 * screenscale, 10 * screenscale )
	addEditPresetButton:Dock( BOTTOM )
	
	local presetCreationTextBoxesPanel = vgui.Create( "DPanel", presetCreationPanel)
	presetCreationTextBoxesPanel:SetHeight( 26 * screenscale )	
	presetCreationTextBoxesPanel:Dock( FILL )
	presetCreationTextBoxesPanel:DockMargin( 8 * screenscale, 8 * screenscale, 10 * screenscale, 10 * screenscale )
	presetCreationTextBoxesPanel:DockPadding(0,0,0,0 )
	presetCreationTextBoxesPanel.Paint = function()
		--surface.SetDrawColor( Color(255,255,255,100) )
		--surface.DrawRect( 0, 0, presetCreationTextBoxesPanel:GetWide(), presetCreationTextBoxesPanel:GetTall() )
		surface.SetFont( "AWarn3Label1" )
		surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
		local x = self.presetNameTxtBox:GetX()
		local text = AWarn.Localization:GetTranslation( "presetname" ) .. ":"
		local tW, tH = surface.GetTextSize( text )
		surface.SetTextPos( x , 0 )
		surface.DrawText( text )
		
		local x = self.presetValueTxtBox:GetX()
		local text = AWarn.Localization:GetTranslation( "presetreason" ) .. ":"
		local tW, tH = surface.GetTextSize( text )
		surface.SetTextPos( x , 0 )
		surface.DrawText( text )
	end	

	self.presetNameTxtBox = vgui.Create( "DTextEntry", presetCreationTextBoxesPanel )
	self.presetNameTxtBox:SetFont( "AWarn3Label2" )
	self.presetNameTxtBox:SetWide( 200 * screenscale )
	self.presetNameTxtBox:SetPlaceholderText( " " .. AWarn.Localization:GetTranslation( "presetname" ) )	
	self.presetNameTxtBox:DockMargin( 0, 25 * screenscale, 0, 0 )
	self.presetNameTxtBox:Dock( LEFT )

	self.presetValueTxtBox = vgui.Create( "DTextEntry", presetCreationTextBoxesPanel )
	self.presetValueTxtBox:SetFont( "AWarn3Label2" )
	self.presetValueTxtBox:SetPlaceholderText( " " .. AWarn.Localization:GetTranslation( "presetreason" ) )	
	self.presetValueTxtBox:DockMargin( 8 * screenscale, 25 * screenscale, 0, 0 )
	self.presetValueTxtBox:Dock( FILL )	
	
	addEditPresetButton.OnSelected = function()

		if AWarn.menu.configurationview.presetNameTxtBox:GetValue() == "" or AWarn.menu.configurationview.presetValueTxtBox:GetValue() == "" then return end
		
		AWarn.Presets[ AWarn.menu.configurationview.presetNameTxtBox:GetValue() ] = {
			pName = AWarn.menu.configurationview.presetNameTxtBox:GetValue(),
			pReason = AWarn.menu.configurationview.presetValueTxtBox:GetValue(),
		}		
		
		AWarn:RefreshPresets()
		AWarn:SavePresets()
		timer.Simple( 0.1, function() AWarn3_ResetPresetCreationFields() end )
	end

	
end
vgui.Register( "awarn3_configurationview", PANEL, "DFrame" )
	
function AWarn3_ResetPunishmentCreationFields()
	AWarn.punishmentCreationFields.pActiveWarningsTxtBox:SetValue("1")
	AWarn.punishmentCreationFields.pMessageToPlayerTxtBox:SetValue("")
	AWarn.punishmentCreationFields.pMessageToServerTxtBox:SetValue("")
	AWarn.punishmentCreationFields.pPunishmentLengthTxtBox:SetValue("")
	AWarn.punishmentCreationFields.pPunishmentCommandTxtBox:SetValue("")
end
	
function AWarn3_ResetPresetCreationFields()
	AWarn.menu.configurationview.presetNameTxtBox:SetValue("")
	AWarn.menu.configurationview.presetValueTxtBox:SetValue("")
end


local PANEL = {}
function PANEL:Init()
	self:SetHeight(45 * screenscale)
	self.MainText = "Option Title"
	self.SecondaryText = "Option Description String Goes Here"
	self.optionString = "nnn"
end
function PANEL:SetOptionString( str )
	self.optionString = str
end
function PANEL:GetOptionString()
	return self.optionString
end
function PANEL:SetPrimaryText( str )
	self.MainText = str
end
function PANEL:SetSecondaryText( str )
	self.SecondaryText = str
end
function PANEL:SetChecked( bool )
	self.chkBox:SetChecked( bool )
end
function PANEL:Paint()
	--surface.SetDrawColor( 200, 200, 120, 0 )
	--surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
	surface.SetFont( "AWarn3ToggleText1" )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	surface.SetTextPos( 10 * screenscale, 7 * screenscale)
	surface.DrawText( self.MainText )
	surface.SetFont( "AWarn3ToggleText2" )
	surface.SetTextPos( 10* screenscale, 27 * screenscale)
	surface.DrawText( self.SecondaryText )
	
end
function PANEL:DrawElements()
	local chkBoxPanel = vgui.Create( "DPanel", self )
	chkBoxPanel:SetWidth(80 * screenscale)
	chkBoxPanel:DockMargin(0,14*screenscale,0,0)
	chkBoxPanel:Dock( RIGHT )
	chkBoxPanel.Paint = function()
	end
	
	self.chkBox = vgui.Create( "awarn3_customcheckbox", chkBoxPanel )
	self.chkBox:SetSize(48 * screenscale, 24 * screenscale)
	self.chkBox:SetValue( 0 )
	
	local function GetOptionString()
		return self.optionString
	end
	
	function self.chkBox:OnChange( val )
		AWarn:SendOptionUpdate( GetOptionString(), val )
	end
	
	local function SetInitialValue()
		self.chkBox:SetChecked( AWarn.Options[self.optionString].value )
	end
	--SetInitialValue()
end
vgui.Register( "awarn3_toggleoption", PANEL, "DPanel" )



local PANEL = {}
function PANEL:Init()
	self:SetHeight(45 * screenscale)
	self.MainText = "Option Title"
	self.SecondaryText = "Option Description String Goes Here"
	self.optionString = "nnn"
	self.numeric = false
	self.stripSpaces = false
end
function PANEL:SetOptionString( str )
	self.optionString = str
end
function PANEL:GetOptionString()
	return self.optionString
end
function PANEL:SetPrimaryText( str )
	self.MainText = str
end
function PANEL:SetSecondaryText( str )
	self.SecondaryText = str
end
function PANEL:SetValue( str )
	if self.stripSpaces then
		self.optionTextBox:SetValue( tostring(str):gsub( " ", "" ) )
	else
		self.optionTextBox:SetValue( tostring(str) )
	end
end
function PANEL:SetNumeric( bool )
	self.numeric = bool
end
function PANEL:StripSpaces( bool )
	self.stripSpaces = bool
end

function PANEL:Paint()
	--surface.SetDrawColor( 200, 200, 120, 0 )
	--surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
	surface.SetFont( "AWarn3ToggleText1" )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	surface.SetTextPos( 10 * screenscale, 7 * screenscale)
	surface.DrawText( self.MainText )
	surface.SetFont( "AWarn3ToggleText2" )
	surface.SetTextPos( 10* screenscale, 27 * screenscale)
	surface.DrawText( self.SecondaryText )
		
	if self.optionTextBox:IsEditing() then
		surface.SetFont( "AWarn3CardText1" )
		local tW, tH = surface.GetTextSize( AWarn.Localization:GetTranslation( "pressenter" ) )
		
		local x = self:GetWide() - ( 210 * screenscale ) - tW
		local y = 16 * screenscale
		surface.SetTextColor( AWarn.Colors.COLOR_LABEL_VALUE_TEXT )
		surface.SetTextPos( x, y )
		surface.DrawText( AWarn.Localization:GetTranslation( "pressenter" ) )
	end
	
end
function PANEL:DrawElements()
	local txtBoxPanel = vgui.Create( "DPanel", self )
	txtBoxPanel:SetWidth(200 * screenscale)
	txtBoxPanel:DockMargin(0,7*screenscale,0,0)
	txtBoxPanel:Dock( RIGHT )
	txtBoxPanel.Paint = function()
		--surface.SetDrawColor( 200, 200, 120, 50 )
		--surface.DrawRect( 0, 0, txtBoxPanel:GetWide(), txtBoxPanel:GetTall() )
	end
	
	self.optionTextBox = vgui.Create( "DTextEntry", txtBoxPanel )
	self.optionTextBox:SetSize( 180 * screenscale, 30 * screenscale )
	self.optionTextBox:SetMultiline( false )
	self.optionTextBox:SetFont( "AWarn3Label2" )
	self.optionTextBox:SetPos( 0, 0 )	
	self.optionTextBox:SetEnterAllowed( true )
	self.optionTextBox:SetPlaceholderText( "Test" )
	self.optionTextBox:SetPaintBackground( true )
	self.optionTextBox:DockMargin(10,0,0,0)
	self.optionTextBox:SetNumeric( self.numeric )
	self.optionTextBox.OnEnter = function( val )
		self.optionTextBox:SetTextColor( Color( 0, 200, 0, 255 ) )
		if self.stripSpaces then
			self.optionTextBox:SetValue( val:GetText():gsub( " ", "" ) )
			AWarn:SendOptionUpdate( self.optionString, val:GetText():gsub( " ", "" ) )
		else
			self.optionTextBox:SetValue( val:GetText() )
			AWarn:SendOptionUpdate( self.optionString, val:GetText() )
		end
	end
	
	local function SetInitialValue()
		self.optionTextBox:SetValue( AWarn.Options[self.optionString].value )
	end
	--SetInitialValue()

end
vgui.Register( "awarn3_textoption", PANEL, "DPanel" )



local PANEL = {}
function PANEL:Init()
	self:SetHeight(45 * screenscale)
	self.MainText = "Option Title"
	self.SecondaryText = "Option Description String Goes Here"
	self.optionString = "nnn"
	self.optionTable = {}
end
function PANEL:SetOptionString( str )
	self.optionString = str
end
function PANEL:GetOptionString()
	return self.optionString
end
function PANEL:SetPrimaryText( str )
	self.MainText = str
end
function PANEL:SetSecondaryText( str )
	self.SecondaryText = str
end
function PANEL:SetOptionTable( tbl )
	self.optionTable = tbl
end
function PANEL:SetValue( str )
	self.comboBox:SetValue( str )
end

function PANEL:Paint()
	--surface.SetDrawColor( 200, 200, 120, 0 )
	--surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
	surface.SetFont( "AWarn3ToggleText1" )
	surface.SetTextColor( AWarn.Colors.COLOR_LABEL_TEXT )
	surface.SetTextPos( 10 * screenscale, 7 * screenscale)
	surface.DrawText( self.MainText )
	surface.SetFont( "AWarn3ToggleText2" )
	surface.SetTextPos( 10* screenscale, 27 * screenscale)
	surface.DrawText( self.SecondaryText )
	
end
function PANEL:DrawElements()
	local cmboBoxPanel = vgui.Create( "DPanel", self )
	cmboBoxPanel:SetWidth(200 * screenscale)
	cmboBoxPanel:DockMargin(0,7*screenscale,0,0)
	cmboBoxPanel:Dock( RIGHT )
	cmboBoxPanel.Paint = function()
		--surface.SetDrawColor( 200, 200, 120, 50 )
		--surface.DrawRect( 0, 0, cmboBoxPanel:GetWide(), cmboBoxPanel:GetTall() )
	end
	
	self.comboBox = vgui.Create( "DComboBox", cmboBoxPanel )
	self.comboBox:SetWidth( 180 * screenscale )
	self.comboBox:SetHeight( 30 * screenscale )
	self.comboBox:SetValue( "EN-US" )
	self.comboBox:SetFont( "AWarn3Label2" )
	for k, v in pairs( self.optionTable ) do
		self.comboBox:AddChoice( AWarn.Localization.LangCodes[k], k )
	end
	function self.comboBox:OnSelect( index, text, data )
		local optionstring = self:GetParent():GetParent().optionString
		AWarn:SendOptionUpdate( optionstring, data )
	end
	
end
vgui.Register( "awarn3_combooption", PANEL, "DPanel" )