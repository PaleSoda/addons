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

MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, "Loading ConCommands Module\n" )

local AWarn3Commands = {}

function AWarn:RegisterConCommand( CCTbl )
	AWarn3Commands[ CCTbl.command ] = CCTbl
end

function AWarn:GetConCommand( command )
	return AWarn3Commands[ command ]
end

local function AutoComplete()
	local tbl = {}
	for k, v in pairs( AWarn3Commands ) do
		table.insert( tbl, "awarn " .. k )
	end
	return tbl
end

concommand.Add( "awarn", function( pl, cmd, args )
	if AWarn3Commands[ args[1] ] then
		if not AWarn3Commands[ args[1] ].permissioncheck( pl ) then
			MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "insufficientperms" ) .. "\n")
			return 
		end
		local new_args = table.Copy( args )
		table.remove( new_args, 1 )
		if #new_args < AWarn3Commands[ args[1] ].requiredargs then
			MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "insufficientperms" ) .. "\n")
			MsgC( AWARN3_WARNING, AWarn3Commands[ args[1] ].help .. "\n")
		else
			AWarn3Commands[ args[1] ].commandfunction( pl, new_args )
		end
	else
		MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "commandnonexist" ) .. "\n")
	end
end, AutoComplete )


local CC = {}
CC.command = "warn"
CC.help = "Warn a player. Usage is :: awarn warn <player name> <reason>"
CC.requiredargs = 1
CC.permissioncheck = function( pl )
	if SERVER then
		return AWarn:CheckPermission( pl, "awarn_warn" )
	else
		return true
	end
end
CC.commandfunction = function( pl, args )
	local target_pl = AWarn:GetIDFromNameOrSteamID( args[1] )
	local WarningReason = table.concat( args, " ", 2, #args )
	if WarningReason == "" then WarningReason = nil end
	if target_pl == "0" then
		MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "invalidtargetid" ) .. "\n")
		return
	end
	if target_pl == nil then
		MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "invalidtarget" ) .. "\n")
		return
	end
	
	
	if SERVER then
		if IsValid( pl ) then
			if not WarningReason and AWarn:GetOption( "awarn_reasonrequired" ) then
				MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "reasonrequired" ) .. "\n")
				AWarn:SendChatMessage( { AWarn.Localization:GetTranslation( "reasonrequired" ) }, pl )
				return
			end
			AWarn:CreateWarningID( target_pl, AWarn:SteamID64( pl ), WarningReason )
		else
			if not WarningReason and AWarn:GetOption( "awarn_reasonrequired" ) then
				MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "reasonrequired" ) .. "\n")
				return
			end
			AWarn:CreateWarningID( target_pl, "[CONSOLE]", WarningReason )
		end
	else
		--Clientside Execution
		AWarn:CreateWarningID( target_pl, LocalPlayer():SteamID64(), WarningReason )
	end
end
AWarn:RegisterConCommand( CC )



local CC = {}
CC.command = "removewarn"
CC.help = "Removes a single active warning from a player. Usage is :: awarn removewarn <player name>"
CC.requiredargs = 1
CC.permissioncheck = function( pl )
	if SERVER then
		return AWarn:CheckPermission( pl, "awarn_remove" )
	else
		return true
	end
end
CC.commandfunction = function( pl, args )
	local target_pl = AWarn:GetIDFromNameOrSteamID( args[1] )
	if target_pl == nil then
		MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "invalidtarget" ) .. "\n")
		return
	end
	if target_pl == "0" then
		MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "invalidtargetid" ) .. "\n")
		return
	end
	
	
	if SERVER then
		if IsValid( pl ) then
			AWarn:SendChatMessage( { AWarn.Localization:GetTranslation( "remove1activewarn" ) .. " ", Color(255,0,0), target_pl }, pl )
		else
			MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "remove1activewarn" ) .. " ", Color(255,0,0), target_pl, "\n")
		end
		AWarn:AddActiveWarning( target_pl, -1 )		
	else
		--ClientsideExecution
		AWarn:AddActiveWarning( target_pl, -1 )
	end
	
end
AWarn:RegisterConCommand( CC )


local CC = {}
CC.command = "deletewarnings"
CC.help = " Deletes all warnings from a player. Usage is :: awarn deletewarnings <player name>"
CC.requiredargs = 1
CC.permissioncheck = function( pl )
	if SERVER then
		return AWarn:CheckPermission( pl, "awarn_delete" )
	else
		return true
	end
end
CC.commandfunction = function( pl, args )
	local target_pl = AWarn:GetIDFromNameOrSteamID( args[1] )
	if target_pl == nil then
		MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "invalidtarget" ) .. "\n")
		return
	end
	if target_pl == "0" then
		MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "invalidtargetid" ) .. "\n")
		return
	end
	
	if SERVER then
		if IsValid( pl ) then
			AWarn:SendChatMessage( { AWarn.Localization:GetTranslation( "removeallwarnings" ) .. " ", Color(255,0,0), target_pl }, pl )
		else
			MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "removeallwarnings" ) .. " ", Color(255,0,0), target_pl, "\n")
		end
		AWarn:DeleteAllPlayerWarnings( target_pl )
	else
		--ClientsideExecution
		AWarn:DeleteAllPlayerWarnings( target_pl )
	end
end
AWarn:RegisterConCommand( CC )


local CC = {}
CC.command = "menu"
CC.help = " Opens the AWarn3 Menu for viewing warnings."
CC.requiredargs = 0
CC.permissioncheck = function( pl )
	return true
end
CC.commandfunction = function( pl, args )
	if SERVER then
		if IsValid( pl ) then
			AWarn:OpenMenu( pl )
		else
			MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "cantopenconsole" ) .."\n")
		end
	else
		--ClientsideExecution
		AWarn:OpenMenu()
	end
end
AWarn:RegisterConCommand( CC )


local CC = {}
CC.command = "resettodefault"
CC.help = " Deletes ALL data and resets AWarn3 to factory settings. WARNING: This can not be undone and deletes EVERYTHING."
CC.requiredargs = 0
CC.permissioncheck = function( pl )
	return true
end
CC.commandfunction = function( pl, args )
	if SERVER then
		if IsValid( pl ) then
			if pl:IsListenServerHost() then
				AWarn:ResetToDefaults()
			else
				MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, "This can only be run on the server console.\n")
			end
		else
			AWarn:ResetToDefaults()
		end
	else
		MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, "This can only be run on the server console.\n")
	end
end
AWarn:RegisterConCommand( CC )