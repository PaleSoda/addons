--[[
      __          __              ____  
     /\ \        / /             |___ \ 
    /  \ \  /\  / /_ _ _ __ _ __   __) |
   / /\ \ \/  \/ / _` | '__| '_ \ |__ < 
  / ____ \  /\  / (_| | |  | | | |___) |
 /_/    \_\/  \/ \__,_|_|  |_| |_|____/ 

	AWarn3 by Mr.President
]]



AWarn.Server = "Server 1"

MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "AWarn3 is loading...\n" )

include( "includes/awarn3_localization.lua" )

include( "includes/sh_awarn3.lua" )

include( "includes/awarn3_util.lua" )
include( "includes/awarn3_options.lua" )
include( "includes/awarn3_punishments.lua" )
include( "includes/awarn3_presets.lua" )
include( "includes/awarn3_permissions.lua" )
include( "includes/awarn3_blacklists.lua" )

include( "includes/awarn3_sql.lua" )
include( "includes/awarn3_concommands.lua" )
include( "includes/awarn3_chatcommands.lua" )
include( "includes/awarn3_discordlogging.lua" )
include( "includes/awarn3_awarn2import.lua" )

include( "includes/awarn3_stats.lua" )

AddCSLuaFile( "includes/cl_awarn3.lua" )
AddCSLuaFile( "includes/sh_awarn3.lua" )
AddCSLuaFile( "includes/awarn3_concommands.lua" )
AddCSLuaFile( "includes/awarn3_permissions.lua" )
AddCSLuaFile( "includes/awarn3_vgui.lua" )
AddCSLuaFile( "includes/awarn3_easings.lua" )
AddCSLuaFile( "includes/awarn3_localization.lua" )
AddCSLuaFile( "includes/awarn3_themes.lua" )
AddCSLuaFile( "includes/vgui/aw3_menu_configuration_settings.lua" )

local PLAYER = FindMetaTable( "Player" )

resource.AddWorkshop( "1853618226" )

local f, d =  file.Find( "materials/vgui/awarn3_*.png", "GAME" )
for k, v in pairs( f ) do
	resource.AddSingleFile( "materials/vgui/" .. v )
end

local f, d =  file.Find( "materials/vgui/aw3_*.png", "GAME" )
for k, v in pairs( f ) do
	resource.AddSingleFile( "materials/vgui/" .. v )
end

function AWarn:SendClientMessage( pl, msgTxt )
	net.Start( "awarn3_clientmessage" )
	net.WriteString( msgTxt )
	net.Send( pl )
end

function AWarn:BroadcastWarningMessage( PlayerID, AdminID, WarningReason )
	net.Start( "awarn3_warningmessage" )
	net.WriteString( PlayerID )
	net.WriteString( AdminID )
	net.WriteString( WarningReason )
	net.Broadcast()
	
	local pl = AWarn:GetPlayerFromID64( PlayerID ) or nil
	local admin = AWarn:GetPlayerFromID64( AdminID ) or nil
	
	local TARGET_COLOR 	= Color( 128,255,0 )
	local ADMIN_COLOR 	= Color( 128,255,0 )
	
	local plName = PlayerID
	local adminName = AdminID
	if IsValid( pl ) then plName = pl:GetName() end
	if IsValid( admin ) then adminName = admin:GetName() end
	
	MsgC( Color(255,100,100), "[AWarn3] ", TARGET_COLOR, plName, AWARN3_WHITE, " was warned by ", AWARN3_CLIENT, adminName, AWARN3_WHITE, " for ", Color(255,100,100), WarningReason, AWARN3_WHITE, ".\n" )
end

function AWarn:SendChatMessage( mTbl, pl )
	if pl then
		if not IsValid( pl ) then return end
		if not pl:IsPlayer() then return end
		net.Start( "awarn3_chatmessagecolor")
		net.WriteTable( mTbl )
		net.Send( pl )
	else
		net.Start( "awarn3_chatmessagecolor")
		net.WriteTable( mTbl )
		net.Broadcast()
	end
end

hook.Add( "PlayerInitialSpawn", "AWarn3_InitialSpawnPlayer", function( pl )
	AWarn:InitialSpawnPlayer( pl )
	
	timer.Simple(1, function()
	net.Start( "awarn3_playerjoinandleave" )
	net.WriteString( "join" )
	net.WriteEntity( pl )
	net.Broadcast()
	end )
	
end )

hook.Add( "PlayerDisconnected", "Awarn3_PlayerDisconnected", function( pl )

	net.Start( "awarn3_playerjoinandleave" )
	net.WriteString( "leave" )
	net.WriteString( AWarn:SteamID64( pl ) )
	net.Broadcast()

end )

function AWarn:SetPlayerActiveWarnings( pl, warnings, shouldWrite )
	if not IsValid( pl ) then return end
	if not tonumber( warnings ) then return end
	pl:SetNW2Int( 'awarn3_activewarnings', warnings )
	if shouldWrite then
		self:UpdatePlayerWarnings( AWarn:SteamID64( pl ), warnings )
	end
end

function AWarn:GetPlayerActiveWarnings( pl )
	return pl:GetNW2Int( 'awarn3_activewarnings', 0 )
end

function PLAYER:GetActiveWarnings()
	return AWarn:GetPlayerActiveWarnings( self )
end

function AWarn:InitialSpawnCheckDecay( pl, lastDecayTime )
	local decayrate = self:GetOption( "awarn_decayrate" )
	local shouldDacay = self:GetOption( "awarn_decay" )
	if not shouldDacay then return end
	if not IsValid( pl ) then return end
	if not lastDecayTime then return end
	lastDecayTime = tonumber(lastDecayTime)
	if not lastDecayTime then return end
	if lastDecayTime == 0 or lastDecayTime == "NULL" then return end
	
	if os.time() >= lastDecayTime + ( decayrate * 60 ) then
		self:TryDecayWarning( pl )
	else
		local dTime = ( lastDecayTime + ( decayrate * 60 ) ) - os.time()
		self:CreateDecayTimerModified( pl, dTime )
	end
end

function AWarn:CreateDecayTimerModified( pl, dTime )
	local decayrate = self:GetOption( "awarn_decayrate" )
	local shouldDacay = self:GetOption( "awarn_decay" )
	if not shouldDacay then return end
	if not IsValid( pl ) then return end

	timer.Create( "awarn3decaytimer_" .. AWarn:SteamID64( pl ), dTime, 1,
		function()
			if IsValid( pl ) then
				AWarn:TryDecayWarning( pl )
			end
		end
	)
end

function AWarn:ResetDecayTimer( pl )
	local decayrate = self:GetOption( "awarn_decayrate" )
	local shouldDacay = self:GetOption( "awarn_decay" )
	if not shouldDacay then return end
	if not IsValid( pl ) then return end
	timer.Create( "awarn3decaytimer_" .. AWarn:SteamID64( pl ), decayrate * 60, 1,
		function()
			if IsValid( pl ) then
				AWarn:TryDecayWarning( pl )
			end
		end
	)
end

function AWarn:TryDecayWarning( pl )
	if not IsValid( pl ) then return end
	local decayrate = self:GetOption( "awarn_decayrate" )
	local shouldDacay = self:GetOption( "awarn_decay" )
	if not shouldDacay then return end
	local plActiveWarnings = self:GetPlayerActiveWarnings( pl ) or 0
	if plActiveWarnings <= 0 then return end
	
	self:DecayWarning( AWarn:SteamID64( pl ), plActiveWarnings - 1 )
	if plActiveWarnings - 1 > 0 then
		self:ResetDecayTimer( pl )
	end
end

function AWarn:OpenMenu( pl )
	net.Start( "awarn3_openmenu" )
	net.Send( pl )
end

function AWarn:AlertAdmins( pl, lastwarn, activeWarnings )
	local alertAdmins = self:GetOption( "awarn_joinmessageadmin" )
	if not alertAdmins then return end
	activeWarnings = activeWarnings or 0
	for k, v in pairs( player.GetAll() ) do
		if pl == v then continue end
		if AWarn:CheckPermission( v, "awarn_view" ) then
			AWarn:SendChatMessage( { pl, " " .. AWarn.Localization:GetTranslation( "joinmessage1" ) }, v )
			AWarn:SendChatMessage( { AWarn.Localization:GetTranslation( "joinmessage2" ) .. " ", Color(255,0,0), os.date( "%d/%m/%Y - %H:%M:%S" , lastwarn ) }, v )
			if tonumber(activeWarnings) > 0 then
				AWarn:SendChatMessage( { AWarn.Localization:GetTranslation( "activewarnings" ) .. ": ", Color(255,0,0), activeWarnings }, v )
			end
		end
	end	
end

function AWarn:WelcomeBackPlayer( pl )
	local alertPlayer = self:GetOption( "awarn_joinmessageclient" )
	if not alertPlayer then return end
	AWarn:SendChatMessage( { AWarn.Localization:GetTranslation( "joinmessage3" ) }, pl )
	AWarn:SendChatMessage( { AWarn.Localization:GetTranslation( "joinmessage4" ) .. " ", Color(255,0,0), AWarn:GetOption( "awarn_chat_prefix" ) }, pl )
end