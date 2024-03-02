--[[
      __          __              ____  
     /\ \        / /             |___ \ 
    /  \ \  /\  / /_ _ _ __ _ __   __) |
   / /\ \ \/  \/ / _` | '__| '_ \ |__ < 
  / ____ \  /\  / (_| | |  | | | |___) |
 /_/    \_\/  \/ \__,_|_|  |_| |_|____/ 

	AWarn3 by Mr.President
]]

MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "Loading Presets Module\n" )


AWarn.Presets = {}

function AWarn:RegisterPreset( pTbl )
	self.Presets[ pTbl.pName ] = pTbl
end

function AWarn:GetPreset( pName )
	if not self.Presets[ pName ] then
		MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "No preset with this name.\n" )
		return nil
	end
	return self.Presets[ pName ]
end

function AWarn:SavePresets()
	self:CheckDirectory()
	file.Write( "awarn3/presets.txt", util.TableToJSON( self.Presets, true ) )
end

function AWarn:LoadPresets()
	if file.Exists( "awarn3/presets.txt", "DATA" ) then
		self.Presets = util.JSONToTable( file.Read( "awarn3/presets.txt", "DATA" ) )
		MsgC( AWARN3_SERVER, "[AWarn3] ", "Presets Loaded\n" )
	else
		self:SavePresets()
	end
end

net.Receive( "awarn3_networkpresets", function( len, pl )
	
	
	local requestType = net.ReadString()
	
	if requestType == "update" then
		if not AWarn:CheckPermission( pl, "awarn_warn" ) then return end
		AWarn:SendPresetsToPlayer( pl )
		
	elseif requestType == "write" then
		if not AWarn:CheckPermission( pl, "awarn_options" ) then return end
		local pTable = net.ReadTable()
		AWarn.Presets = pTable
		AWarn:SavePresets()
	
	end
end )

function AWarn:SendPresetsToPlayer( pl )
	net.Start( "awarn3_networkpresets" )
	net.WriteTable( AWarn.Presets )
	
	if pl then
		net.Send( pl )
	else
		net.Broadcast()
	end
end

local PRESET = {}
PRESET.pName = "RDM"
PRESET.pReason = "Killing random players for no reason."
AWarn:RegisterPreset( PRESET )

local PRESET = {}
PRESET.pName = "OOC"
PRESET.pReason = "Using OOC chat in the main chat."
AWarn:RegisterPreset( PRESET )

local PRESET = {}
PRESET.pName = "Disobeying Staff"
PRESET.pReason = "Not following the instructions of staff members."
AWarn:RegisterPreset( PRESET )

AWarn:LoadPresets()