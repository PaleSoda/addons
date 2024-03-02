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

MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, "Loading Permissions Module\n" )

AWarn.Permissions = {}

function AWarn:RegisterPermission( pTbl )
	self.Permissions[ pTbl.permissionString ] = pTbl
end

function AWarn:LookupPermission( p )
	return self.Permissions[ p ] or false
end

function AWarn:CheckPermission( pl, p )
	if not self:LookupPermission( p ) then return false end
	return self:LookupPermission( p ).permissionCheck( pl )
end

function AWarn:AdminCompatStringCheck( pl, pString )
	if ulx then
		return ULib.ucl.query( pl, pString ) or false
	elseif sAdmin then
		return sAdmin.hasPermission(pl, pString) or false
	elseif CAMI then
		return CAMI.PlayerHasAccess( pl, pString, nil )
	elseif xAdmin then
		return pl:xAdminHasPermission( pString ) or false
	elseif serverguard then
		return serverguard.player:HasPermission(pl, pString) or false
	elseif SAM then
		return SAM.HasPermission(pl, pString)
	else
		if pl:IsSuperAdmin() then return true end
		if pl:IsAdmin() then return true end
		return false
	end
end

local PERMISSION = {}
PERMISSION.permissionString = "awarn_view"
PERMISSION.shortString = "AWarn View"
PERMISSION.description = "This allows a player to view other players' warnings."
PERMISSION.permissionCheck = function( pl )
	return AWarn:AdminCompatStringCheck( pl, PERMISSION.permissionString )
end
AWarn:RegisterPermission( PERMISSION )


local PERMISSION = {}
PERMISSION.permissionString = "awarn_warn"
PERMISSION.shortString = "AWarn Warn"
PERMISSION.description = "This allows a player to warn other players."
PERMISSION.permissionCheck = function( pl )
	return AWarn:AdminCompatStringCheck( pl, PERMISSION.permissionString )
end
AWarn:RegisterPermission( PERMISSION )


local PERMISSION = {}
PERMISSION.permissionString = "awarn_remove"
PERMISSION.shortString = "AWarn Remove"
PERMISSION.description = "This allows a player to decrease another player's active warnings."
PERMISSION.permissionCheck = function( pl )
	return AWarn:AdminCompatStringCheck( pl, PERMISSION.permissionString )
end
AWarn:RegisterPermission( PERMISSION )


local PERMISSION = {}
PERMISSION.permissionString = "awarn_delete"
PERMISSION.shortString = "AWarn Delete"
PERMISSION.description = "This allows a player to delete all warnings for a player."
PERMISSION.permissionCheck = function( pl )
	return AWarn:AdminCompatStringCheck( pl, PERMISSION.permissionString )
end
AWarn:RegisterPermission( PERMISSION )

local PERMISSION = {}
PERMISSION.permissionString = "awarn_options"
PERMISSION.shortString = "AWarn Options"
PERMISSION.description = "This allows a player to view and change the configurations for this script."
PERMISSION.permissionCheck = function( pl )
	return AWarn:AdminCompatStringCheck( pl, PERMISSION.permissionString )
end
AWarn:RegisterPermission( PERMISSION )

local PERMISSION = {}
PERMISSION.permissionString = "awarn_immune"
PERMISSION.shortString = "AWarn Immune"
PERMISSION.description = "Players with this permission will be immune to being warned by anyone."
PERMISSION.permissionCheck = function( pl )
	return AWarn:AdminCompatStringCheck( pl, PERMISSION.permissionString )
end
AWarn:RegisterPermission( PERMISSION )