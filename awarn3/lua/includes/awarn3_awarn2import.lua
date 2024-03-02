--[[
      __          __              ____  
     /\ \        / /             |___ \ 
    /  \ \  /\  / /_ _ _ __ _ __   __) |
   / /\ \ \/  \/ / _` | '__| '_ \ |__ < 
  / ____ \  /\  / (_| | |  | | | |___) |
 /_/    \_\/  \/ \__,_|_|  |_| |_|____/ 

	AWarn3 by Mr.President
]]

MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "Loading AWarn2 Import Module\n" )

--[[
	EDIT THE FOLLOWING IF YOU WANT TO USE MySQL Server
]]

local isMySQL = AWarn3_MySQLite.isMySQL()

concommand.Add( "awarn3_import", function( ply, com, args )
	if not ply:IsSuperAdmin() then
		MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "This command can only be run by SuperAdmins.\n" )
		return
	end
	AWarn:ImportAWarn2()
end )

concommand.Add( "awarn3_import_confirm", function( ply, com, args )
	if not ply:IsSuperAdmin() then
		MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "This command can only be run by SuperAdmins.\n" )
		return
	end
	if not AWarn.importData then
		MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "Please run awarn3_import first.\n" )
		return
	end
	
	AWarn:ImportAWarn2_WarningData()
end )


function AWarn:ImportAWarn2()
	if isMySQL then
		MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "Sorry, but this import script does NOT support MySQL.\n" )
		return
	end
	local awarn2_data = sql.Query( "SELECT * FROM awarn_warnings" )
	local awarn2_pdata = sql.Query( "SELECT * FROM awarn_offlinedata" )
	local awarn2_pdata2 = sql.Query( "SELECT * FROM awarn_playerdata" )
	
	MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "Discovered ", Color(255,100,100), #awarn2_data, AWARN3_WHITE, " legacy warnings from AWarn2\n" )
	MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "Run command awarn3_import_confirm to confirm and run this import.\n" )
	
	AWarn.importData = awarn2_data
	AWarn.importPData = awarn2_pdata
	AWarn.importPData2 = awarn2_pdata2
end

function AWarn:ImportAWarn2_WarningData()
	if not AWarn.importData then return end
	sql.Begin()
	for k, v in pairs( AWarn.importData ) do
		local str = ("INSERT INTO awarn3_warningtable ( PlayerID, AdminID, WarningReason, WarningServer, WarningDate ) VALUES ( %s, %s, %s, %s, %u )"):format( sql.SQLStr(v.unique_id), sql.SQLStr("awarn2_import"), sql.SQLStr(v.reason), sql.SQLStr("Imported"), os.time() )
		sql.Query( str )
	end
	sql.Commit()
	
	AWarn:ImportAWarn2_PlayerData()
end

function AWarn:ImportAWarn2_PlayerData()
	if not AWarn.importPData then return end
	if not AWarn.importPData2 then return end
	sql.Begin()
	sql.Query( "INSERT INTO awarn3_playertable ( PlayerID, PlayerName, PlayerWarnings, LastPlayed ) VALUES ( 'awarn2_import', 'AWarn2 Legacy Warning', 0, 0 )" )
	for k, v in pairs( AWarn.importPData ) do
		local str = ("INSERT INTO awarn3_playertable ( PlayerID, PlayerName, PlayerWarnings, LastPlayed ) VALUES ( %s, %s, %u, %u )"):format( sql.SQLStr(v.unique_id), sql.SQLStr(v.playername), 0, v.lastplayed )
		sql.Query( str )
	end
	sql.Commit()
	
	
	sql.Begin()
	for k, v in pairs( AWarn.importPData2 ) do
		local str = ("UPDATE awarn3_playertable SET PlayerWarnings = %u, LastWarningDecay = %u, LastWarning = %u WHERE PlayerID = %s"):format( v.warnings, tonumber(v.lastwarn), tonumber(v.lastwarn), sql.SQLStr(v.unique_id) )
		sql.Query( str )
	end
	sql.Commit()
end