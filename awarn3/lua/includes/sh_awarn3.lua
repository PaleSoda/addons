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


function AWarn:CheckDirectory()
	if not file.Exists( "awarn3", "DATA" ) then file.CreateDir( "awarn3" ) end
end

function AWarn:FindPlayerByName( plName )
	local pl = nil
	local plCount = 0
	for k, v in pairs( player.GetAll() ) do
		if string.find( string.lower( v:GetName() ), string.lower( plName ) ) then
			pl = v
			plCount = plCount + 1
		end
	end
	if plCount == 1 then
		return pl
	elseif plCount > 1 then
		MsgC( Color(0,255,0), "[AWarn3] ", AWARN3_WHITE, "Multiple players found\n" )
		return nil
	else
		MsgC( Color(0,255,0), "[AWarn3] ", AWARN3_WHITE, "No players found\n" )
		return nil
	end
end

function AWarn:GetIDFromNameOrSteamID( str )
	local str = str
	local id = nil
	if str:lower():Left(7) == "steam_0" then
		id = util.SteamIDTo64( str )
	else
		if self:FindPlayerByName( str ) then
			id = AWarn:SteamID64( self:FindPlayerByName( str ) )
		end
	end
	
	return id
end

function AWarn:GetPlayerFromID64( id )
	local pl = nil
	for k, v in pairs( player.GetAll() ) do
		if AWarn:SteamID64( v ) == id then
			pl = v
			break
		end
	end
	
	return pl
end

function AWarn:SteamID64( pl )

	if pl:IsBot() then 
		return pl:GetName()
	else
		return pl:SteamID64()
	end
	

end

function AWarn:RegisterAdminModPermissions()
	MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, "Registering Admin Mod Access Permissions\n" )
	if ulx then
		if SERVER then
			for k, v in pairs( self.Permissions ) do
				ULib.ucl.registerAccess( self.Permissions[k].permissionString, ULib.ACCESS_SUPERADMIN, self.Permissions[k].description, "AWarn" )
			end
		end
	elseif serverguard then
		for k, v in pairs( self.Permissions ) do
			serverguard.permission:Add(self.Permissions[k].permissionString)
		end
	elseif sAdmin then
		for k, v in pairs( self.Permissions ) do
			sAdmin.registerPermission(self.Permissions[k].permissionString, "AWarn3", false, true)
		end
	elseif CAMI then
		for k, v in pairs( self.Permissions ) do
			CAMI.RegisterPrivilege({
				Name = self.Permissions[k].permissionString,
				MinAccess = "superadmin",
				Description = self.Permissions[k].description
			})
		end
	end	
end

timer.Simple( 3, function() AWarn:RegisterAdminModPermissions() end )