--[[
      __          __              ____  
     /\ \        / /             |___ \ 
    /  \ \  /\  / /_ _ _ __ _ __   __) |
   / /\ \ \/  \/ / _` | '__| '_ \ |__ < 
  / ____ \  /\  / (_| | |  | | | |___) |
 /_/    \_\/  \/ \__,_|_|  |_| |_|____/ 

	AWarn3 by Mr.President
]]

MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "Loading Options Module\n" )


AWarn.Options = {}

function AWarn:RegisterOption( oTbl )
	AWarn.Options[ oTbl.name ] = oTbl
end

function AWarn:GetOption( op )
	if not AWarn.Options[ op ] then
		MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "invalidoption" ) .. "\n" )
		return nil
	end
	return AWarn.Options[ op ].value
end

function AWarn:SetOption( op, value )
	if not AWarn.Options[ op ] then
		MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "invalidoption" ) .. "\n" )
		return nil
	end
	if AWarn.Options[ op ].type == "boolean" then
		AWarn.Options[ op ].value = tobool( value )
	elseif AWarn.Options[ op ].type == "integer" then
		AWarn.Options[ op ].value = tonumber( value )
	elseif AWarn.Options[ op ].type == "string" then
		AWarn.Options[ op ].value = tostring( value )
	else
		MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "invalidoptionvaluetype" ) .. "\n" )
		return
	end
	AWarn:SaveOptions()
	AWarn:SendOptionsToClient( nil )
end

function AWarn:SaveOptions()
	self:CheckDirectory()
	file.Write( "awarn3/options.txt", util.TableToJSON( self.Options, true ) )
end

function AWarn:LoadOptions()
	if file.Exists( "awarn3/options.txt", "DATA" ) then
		loaded_options = util.JSONToTable( file.Read( "awarn3/options.txt", "DATA" ) )
		for k, v in pairs( loaded_options ) do
			if self.Options[k] then
				self.Options[k] = v
			end
		end
		MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "optionsloaded" ) .. "\n" )
	else
		self:SaveOptions()
	end
end

function AWarn:SendOptionsToClient( pl )
	net.Start( "awarn3_networkoptions" )
	net.WriteTable( AWarn.Options )
	if IsValid( pl ) then
		net.Send( pl )
	else
		net.Broadcast()
	end
end

function AWarn:SendNoOptionsToClient( pl )
	net.Start( "awarn3_networkoptions" )
	net.WriteTable( {} )
	if IsValid( pl ) then
		net.Send( pl )
	end
end

net.Receive( "awarn3_networkoptions", function( len, pl )
	if AWarn:CheckPermission( pl, "awarn_options" ) then
	
		local requestType = net.ReadString()
		
		if requestType == "update" then
		
			AWarn:SendOptionsToClient( pl )
			
		elseif requestType == "write" then
			
			local option = net.ReadString()
			local oValue = nil
			
			if AWarn.Options[option].type == "boolean" then
				oValue = net.ReadBool()
			elseif AWarn.Options[option].type == "integer" then
				oValue = net.ReadInt( 32 )
			elseif AWarn.Options[option].type == "string" then
				oValue = net.ReadString()
			end
			
			AWarn:SetOption( option, oValue )
		
		end
	else
		AWarn:SendNoOptionsToClient( pl )
	end
end )


local OP = {}
OP.name = "awarn_kick"
OP.value = true
OP.type = "boolean"
OP.description = "Allow AWarn to kick players."
AWarn:RegisterOption( OP )

local OP = {}
OP.name = "awarn_ban"
OP.value = true
OP.type = "boolean"
OP.description = "Allow AWarn to ban players"
AWarn:RegisterOption( OP )

local OP = {}
OP.name = "awarn_decay"
OP.value = true
OP.type = "boolean"
OP.description = "If enabled, active warnings will decay over time."
AWarn:RegisterOption( OP )

local OP = {}
OP.name = "awarn_reasonrequired"
OP.value = true
OP.type = "boolean"
OP.description = "If enabled, a warning must be provided when warning a player."
AWarn:RegisterOption( OP )

local OP = {}
OP.name = "awarn_decayrate"
OP.value = 30
OP.type = "integer"
OP.description = "How often (in minutes) an active warning decays for a player."
AWarn:RegisterOption( OP )

local OP = {}
OP.name = "awarn_reset_after_ban"
OP.value = false
OP.type = "boolean"
OP.description = "If enabled, a player's active warnings will be reset to 0 after being banned by awarn. Recommend disabled if using multiple levels of banning."
AWarn:RegisterOption( OP )

local OP = {}
OP.name = "awarn_logging"
OP.value = true
OP.type = "boolean"
OP.description = "If enabled, AWarn will log actions to a data file."
AWarn:RegisterOption( OP )

local OP = {}
OP.name = "awarn_joinmessageclient"
OP.value = true
OP.type = "boolean"
OP.description = "If enabled, players who join will see if they have any warnings on the server."
AWarn:RegisterOption( OP )

local OP = {}
OP.name = "awarn_joinmessageadmin"
OP.value = true
OP.type = "boolean"
OP.description = "If enabled, admins will get a message in chat when a player with warnings joins the server."
AWarn:RegisterOption( OP )

local OP = {}
OP.name = "awarn_allow_warn_admins"
OP.value = true
OP.type = "boolean"
OP.description = "If enabled, admins will be able to warn other admins."
AWarn:RegisterOption( OP )

local OP = {}
OP.name = "awarn_chat_prefix"
OP.value = "!warn"
OP.type = "string"
OP.description = "Chat command to warn players and open the warning menu."
AWarn:RegisterOption( OP )

local OP = {}
OP.name = "awarn_server_language"
OP.value = "EN-US"
OP.type = "string"
OP.description = "Language all server messages will be in."
AWarn:RegisterOption( OP )

local OP = {}
OP.name = "awarn_server_name"
OP.value = "Server 1"
OP.type = "string"
OP.description = "Server name for multi-server support"
AWarn:RegisterOption( OP )

AWarn:LoadOptions()