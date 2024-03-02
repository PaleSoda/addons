--[[
      __          __              ____  
     /\ \        / /             |___ \ 
    /  \ \  /\  / /_ _ _ __ _ __   __) |
   / /\ \ \/  \/ / _` | '__| '_ \ |__ < 
  / ____ \  /\  / (_| | |  | | | |___) |
 /_/    \_\/  \/ \__,_|_|  |_| |_|____/ 

	AWarn3 by Mr.President
]]

MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, "Loading Chat Commands Module\n" )

hook.Add( "PlayerSay", "AWarn3_PlayerSayChatCommand", function( pl, text, team )
	local prefix = AWarn:GetOption( "awarn_chat_prefix" ) or "!warn"
	if string.lower(text:Left( prefix:len() )) == string.lower(prefix) then
		local args = string.Explode( " ", text )
		table.remove( args, 1 )
		if #args > 0 then
			if not AWarn:GetConCommand( "warn" ).permissioncheck( pl ) then
				MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, AWarn.Localization:GetTranslation( "insufficientperms" ) .. "\n")
				AWarn:SendClientMessage( pl, AWarn.Localization:GetTranslation( "insufficientperms" ) )
				return false
			end
			AWarn:GetConCommand( "warn" ).commandfunction( pl, args )
		else
			AWarn:OpenMenu( pl )
		end		
		return false
	end
end )