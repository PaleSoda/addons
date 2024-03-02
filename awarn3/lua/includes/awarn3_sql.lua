--[[
      __          __              ____  
     /\ \        / /             |___ \ 
    /  \ \  /\  / /_ _ _ __ _ __   __) |
   / /\ \ \/  \/ / _` | '__| '_ \ |__ < 
  / ____ \  /\  / (_| | |  | | | |___) |
 /_/    \_\/  \/ \__,_|_|  |_| |_|____/ 

	AWarn3 by Mr.President
]]

MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "Loading SQL Module\n" )

include( "includes/mysqlite_awarn3.lua" )

--[[
	EDIT THE FOLLOWING IF YOU WANT TO USE MySQL Server
]]

function AWarn:ConnectToDatabase()
	AWarn3_MySQLite.initialize({
	EnableMySQL 		= 	false,
	Host        		= 	"localhost",
	Database_port		=	3306,
	Username    		= 	"root",
	Password    		= 	"",
	Database_name 		=	"awarn3",
	Preferred_module 	= 	"mysqloo",
	MultiStatements 	= 	false
	})
end

--[[
	DO NOT EDIT ANYTHING BELOW THIS LINE!!!
]]

local function SQLErrorFunction( err, query )
	MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, err .. "\n" )
end

local function CreateConsolePlayer()
	local query = ( "SELECT * FROM awarn3_playertable WHERE PlayerID = %s" ):format( "'[CONSOLE]'" )
	AWarn3_MySQLite.query( query,
	function( result )
		if result then
			MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "Console Player Exists\n" )
		else
			AWarn:CreatePlayerEntry( "[CONSOLE]", "Console", 0, false )
		end
	end,
	SQLErrorFunction )
end

local function CreateWarningTable()
	AWarn3_MySQLite.tableExists( "awarn3_warningtable",
	function( result )
		if result then
			MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "Warning Table Exists\n" )		
		else
			MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "Creating Warning Table... Stand By!\n" )
			local query
			if AWarn3_MySQLite.isMySQL() then
				query = "CREATE TABLE awarn3_warningtable ( WarningID INTEGER PRIMARY KEY AUTO_INCREMENT, PlayerID VARCHAR(20), AdminID VARCHAR(20), WarningReason TEXT, WarningServer VARCHAR(255), WarningDate INTEGER )"
			else
				query = "CREATE TABLE awarn3_warningtable ( WarningID INTEGER PRIMARY KEY AUTOINCREMENT, PlayerID VARCHAR(20), AdminID VARCHAR(20), WarningReason TEXT, WarningServer VARCHAR(255), WarningDate INTEGER )"
			end
			AWarn3_MySQLite.query( query, function() CreateWarningTable() end, SQLErrorFunction )
		end
	end,
	SQLErrorFunction )
end

local function CreatePlayerTable()
	AWarn3_MySQLite.tableExists( "awarn3_playertable",
	function( result )
		if result then
			MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "Player Table Exists\n" )
			CreateConsolePlayer()
		else
			MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "Creating Player Table... Stand By!\n" )
			local query = "CREATE TABLE awarn3_playertable ( PlayerID VARCHAR(20) PRIMARY KEY, PlayerName VARCHAR(32), PlayerWarnings SMALLINT, LastWarning INTEGER, LastPlayed INTEGER, LastWarningDecay INTEGER )"
			AWarn3_MySQLite.query( query, function() CreatePlayerTable() end, SQLErrorFunction )
		end
	end,
	function( err )
		MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, err .. "\n" )
	end )
end

local function CreateNotesTable()
	AWarn3_MySQLite.tableExists( "awarn3_notestable",
	function( result )
		if result then
			MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "Player Notes Table Exists\n" )
		else
			MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "Creating Player Notes Table... Stand By!\n" )
			local query = "CREATE TABLE awarn3_notestable ( PlayerID VARCHAR(20) PRIMARY KEY, PlayerNotes MEDIUMTEXT )"
			AWarn3_MySQLite.query( query, function() CreateNotesTable() end, SQLErrorFunction )
		end
	end,
	function( err )
		MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, err .. "\n" )
	end )
end

function AWarn:CreateTables()
	CreateWarningTable()
	CreatePlayerTable()
	CreateNotesTable()
end

function AWarn:ResetToDefaults()
	MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "Resetting AWarn3 to factor defaults.\n" )
	local query = "DROP TABLE IF EXISTS awarn3_warningtable; DROP TABLE IF EXISTS awarn3_playertable"
	AWarn3_MySQLite.query( query, function()
		AWarn:CreateTables()
		MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "Reset complete.. Please restart your server to continue.\n" )
	end, SQLErrorFunction )
end

hook.Add( "AWarn3_DatabaseInitialized", "AWarn3_ConnectToDatabase", function()
	MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, "Successfully connected to the database!\n" )
	AWarn:CreateTables()
end )

function AWarn:CreateWarningID( PlayerID, AdminID, WarningReason )
	if not WarningReason and self:GetOption( "awarn_reasonrequired" ) then
		return
	end
	local WarningReason = WarningReason or "NONE GIVEN"
	local WarningServer = AWarn3_MySQLite.SQLStr( AWarn:GetOption( "awarn_server_name" ) or "UNNAMED" )
	local AdminID = AdminID or "CONSOLE"
	
	if table.HasValue( AWarn.UserBlacklist, util.SteamIDFrom64( PlayerID ) ) then
		AWarn:SendChatMessage( { AWarn.Localization:GetTranslation( "playernotallowedwarn" ) }, pl )
		return
	end
	
	local pl = AWarn:GetPlayerFromID64( PlayerID )
	local admin = AWarn:GetPlayerFromID64( AdminID )
	if pl then
		if table.HasValue( AWarn.GroupBlacklist, pl:GetUserGroup() ) then
			if admin then
				AWarn:SendChatMessage( { AWarn.Localization:GetTranslation( "playernotallowedwarn" ) }, admin )
			end
			return
		end
		
		if AWarn:CheckPermission( pl, "awarn_immune" ) then
			if admin then
				AWarn:SendChatMessage( { AWarn.Localization:GetTranslation( "playernotallowedwarn" ) }, admin )
			end
			return
		end
	end
	
	
	local query = ("INSERT INTO awarn3_warningtable ( PlayerID, AdminID, WarningReason, WarningServer, WarningDate ) VALUES ( %s, %s, %s, %s, %u )"):format( AWarn3_MySQLite.SQLStr( PlayerID ), AWarn3_MySQLite.SQLStr( AdminID ), AWarn3_MySQLite.SQLStr( WarningReason ), WarningServer, os.time() )
	AWarn3_MySQLite.query( query, 
	function()
		AWarn:BroadcastWarningMessage( PlayerID, AdminID, WarningReason )
		AWarn:AddActiveWarning( PlayerID, 1 )
		
		local pl = AWarn:GetPlayerFromID64( PlayerID )
		if pl then
			hook.Run( "AWarnPlayerWarned", pl, AdminID, WarningReason )
		else
			hook.Run( "AWarnPlayerIDWarned", PlayerID, AdminID, WarningReason )
		end		
	end, 
	SQLErrorFunction )
end

net.Receive( "awarn3_createwarningid", function( len, pl )
	if not AWarn:CheckPermission( pl, "awarn_warn" ) then
		AWarn:SendChatMessage( { AWarn.Localization:GetTranslation( "insufficientperms" ) }, pl )
		return
	end
	AWarn:CreateWarningID( net.ReadString(), net.ReadString(), net.ReadString() )
end )

function AWarn:AddActiveWarning( PlayerID, numAdd )
	local query = ( "SELECT * FROM awarn3_playertable WHERE PlayerID = %s" ):format( AWarn3_MySQLite.SQLStr( PlayerID ) )
	AWarn3_MySQLite.query( query,
	function( result )
		if result then
			local currentWarnings = math.Clamp( tonumber(result[1].PlayerWarnings) + numAdd, 0, math.huge )
			if numAdd > 0 then
				AWarn:UpdatePlayerWarnings( PlayerID, currentWarnings, true, true )
			else
				AWarn:UpdatePlayerWarnings( PlayerID, currentWarnings, false, false )
			end
		else
			AWarn:CreatePlayerEntry( PlayerID, "UNKNOWN", math.Clamp( numAdd, 0, math.huge ), true )
		end
	end,
	SQLErrorFunction )
end

function AWarn:SavePlayerNotes( PlayerID, notes )
	local query = ( "SELECT * FROM awarn3_notestable WHERE PlayerID = %s" ):format( AWarn3_MySQLite.SQLStr( PlayerID ) )
	AWarn3_MySQLite.query( query,
	function( result )
		if result then
			local query = ( "UPDATE awarn3_notestable SET PlayerNotes = %s WHERE PlayerID = %s" ):format( AWarn3_MySQLite.SQLStr( notes ), AWarn3_MySQLite.SQLStr( PlayerID ) )
			AWarn3_MySQLite.query( query, function() end, SQLErrorFunction )
		else
			local query = ( "INSERT INTO awarn3_notestable VALUES ( %s, %s )" ):format( AWarn3_MySQLite.SQLStr( PlayerID ), AWarn3_MySQLite.SQLStr( notes ) )
			AWarn3_MySQLite.query( query, function() end, SQLErrorFunction )
		end
	end,
	SQLErrorFunction )
end

function AWarn:RequestPlayerNotes( pl, PlayerID )
	local query = ( "SELECT PlayerNotes FROM awarn3_notestable WHERE PlayerID = %s" ):format( AWarn3_MySQLite.SQLStr( PlayerID ) )
	AWarn3_MySQLite.query( query,
	function( result )
		local notes = ""
		if result then
			notes = result[1].PlayerNotes		
		end
		net.Start( "awarn3_notesrequest" )
		net.WriteString( notes )
		net.WriteString( PlayerID )
		net.Send( pl )
	end,
	SQLErrorFunction )
end

net.Receive( "awarn3_updateplayernotes", function( len, pl )
	if not AWarn:CheckPermission( pl, "awarn_warn" ) then
		AWarn:SendChatMessage( { AWarn.Localization:GetTranslation( "insufficientperms" ) }, pl )
		return
	end
	AWarn:SavePlayerNotes( net.ReadString(), net.ReadString() )
end )

net.Receive( "awarn3_notesrequest", function( len, pl )
	if not AWarn:CheckPermission( pl, "awarn_warn" ) then
		AWarn:SendChatMessage( { AWarn.Localization:GetTranslation( "insufficientperms" ) }, pl )
		return
	end
	AWarn:RequestPlayerNotes( pl, net.ReadString() )
end )

net.Receive( "awarn3_addactivewarning", function( len, pl )
	if not AWarn:CheckPermission( pl, "awarn_remove" ) then
		AWarn:SendChatMessage( { AWarn.Localization:GetTranslation( "insufficientperms" ) }, pl )
		return
	end
	local target_pl = net.ReadString()
	AWarn:AddActiveWarning( target_pl, net.ReadInt( 8 ) )
	
	local player_name = AWarn:GetPlayerFromID64( target_pl )	
	AWarn:SendChatMessage( { AWarn.Localization:GetTranslation( "remove1activewarn" ) .. " ", Color(255,0,0), player_name or target_pl }, pl )
end )

function AWarn:RemoveWarningID( WarningID, admin )
	local query = ( "DELETE FROM awarn3_warningtable WHERE WarningID = %u" ):format( WarningID )
	AWarn3_MySQLite.query( query, function()
		if IsValid( admin ) then
			AWarn:SendChatMessage( {AWarn.Localization:GetTranslation( "deletedwarningid" ) .. " ", Color(255,0,0), tostring(WarningID), AWARN3_WHITE, "."}, admin )
		end
	end,
	SQLErrorFunction )
end

net.Receive( "awarn3_deletesinglewarning", function( l, pl )
	if not AWarn:CheckPermission( pl, "awarn_delete" ) then
		AWarn:SendChatMessage( { AWarn.Localization:GetTranslation( "insufficientperms" ) }, pl )
		return
	end
	local warningID = net.ReadInt( 32 )
	AWarn:RemoveWarningID( warningID, pl )
end )

function AWarn:DeleteAllPlayerWarnings( PlayerID, admin )
	local query = ( "DELETE FROM awarn3_warningtable WHERE PlayerID = %s" ):format( AWarn3_MySQLite.SQLStr( PlayerID ) )
	AWarn3_MySQLite.query( query, function()
		if IsValid( admin ) then
			local tar_pl = AWarn:GetPlayerFromID64( PlayerID )
			if IsValid( tar_pl ) then 
				AWarn:SendChatMessage( {AWarn.Localization:GetTranslation( "deletedwarningsfor" ) .. " ", tar_pl:GetTeamColor(), tar_pl:GetName(), AWARN3_WHITE, "."}, admin )
			else
				AWarn:SendChatMessage( {AWarn.Localization:GetTranslation( "deletedwarningsfor" ) .. " ", Color(255,255,0), PlayerID, AWARN3_WHITE, "."}, admin )
			end
		end
		AWarn:UpdatePlayerWarnings( PlayerID, 0 )
	end,
	SQLErrorFunction )
end

net.Receive( "awarn3_deleteallplayerwarnings", function( len, pl )
	if not AWarn:CheckPermission( pl, "awarn_delete" ) then
		AWarn:SendChatMessage( { AWarn.Localization:GetTranslation( "insufficientperms" ) }, pl )
		return
	end
	local player_id = net.ReadString()
	AWarn:DeleteAllPlayerWarnings( player_id, pl )
end )

function AWarn:CreatePlayerEntry( PlayerID, PlayerName, warningOverride, setLastWarnTime )
	local warnings = warningOverride or 0
	local PlayerID = AWarn3_MySQLite.SQLStr( PlayerID )
	local PlayerName = AWarn3_MySQLite.SQLStr( PlayerName:Left(32) )
	local query = ( "INSERT INTO awarn3_playertable ( PlayerID, PlayerName, PlayerWarnings, LastPlayed ) VALUES ( %s, %s, %u, %u )" ):format( PlayerID, PlayerName, warnings, os.time() )
	if setLastWarnTime then
		query = ( "INSERT INTO awarn3_playertable ( PlayerID, PlayerName, PlayerWarnings, LastPlayed, LastWarning, LastWarningDecay ) VALUES ( %s, %s, %u, %u, %u, %u )" ):format( PlayerID, PlayerName, warnings, os.time(), os.time(), os.time() )
	end	
	AWarn3_MySQLite.query( query, function() end, SQLErrorFunction )
end

function AWarn:UpdatePlayerName( PlayerID, PlayerName )
	local PlayerID = AWarn3_MySQLite.SQLStr( PlayerID )
	local PlayerName = AWarn3_MySQLite.SQLStr( PlayerName:Left(32) )
	local LastPlayed = os.time()
	local query = ( "UPDATE awarn3_playertable SET PlayerName = %s, LastPlayed = %u WHERE PlayerID = %s" ):format( PlayerName, LastPlayed, PlayerID )
	AWarn3_MySQLite.query( query, function() end, SQLErrorFunction )
end

function AWarn:InitialSpawnPlayer( pl )
	if not IsValid( pl ) then return end
	local PlayerID = AWarn:SteamID64( pl )
	
	local query = ( "SELECT * FROM awarn3_playertable WHERE PlayerID = %s" ):format( AWarn3_MySQLite.SQLStr( PlayerID ) )
	AWarn3_MySQLite.query( query,
	function( result )
		if result then
			AWarn:SetPlayerActiveWarnings( pl, result[1].PlayerWarnings, false )
			AWarn:UpdatePlayerName( PlayerID, pl:GetName() )
			AWarn:InitialSpawnCheckDecay( pl, result[1].LastWarningDecay )
			if result[1].LastWarning and not ( result[1].LastWarning == "NULL" ) then
				timer.Simple( 1, function()
					if not IsValid( pl ) then return end
					AWarn:AlertAdmins( pl, result[1].LastWarning, result[1].PlayerWarnings or 0 )
					AWarn:WelcomeBackPlayer( pl )
				end )
			end
		else
			AWarn:SetPlayerActiveWarnings( pl, 0, false )
			AWarn:CreatePlayerEntry( PlayerID, pl:GetName() )
			AWarn:InitialSpawnCheckDecay( pl, 0 )
		end
	end,
	SQLErrorFunction )
end

function AWarn:UpdatePlayerWarnings( PlayerID, PlayerWarnings, setLastWarnTime, checkPunishment )
	local query = ( "UPDATE awarn3_playertable SET PlayerWarnings = %u WHERE PlayerID = %s" ):format( PlayerWarnings, AWarn3_MySQLite.SQLStr( PlayerID ) )
	
	if PlayerWarnings == 0 then
		query = ( "UPDATE awarn3_playertable SET PlayerWarnings = 0, LastWarning = NULL, LastWarningDecay = NULL WHERE PlayerID = %s" ):format( AWarn3_MySQLite.SQLStr( PlayerID ) )
	end
	
	if setLastWarnTime then
		query = ( "UPDATE awarn3_playertable SET PlayerWarnings = %u, LastWarning = %u, LastWarningDecay = %u WHERE PlayerID = %s" ):format( PlayerWarnings, os.time(), os.time(), AWarn3_MySQLite.SQLStr( PlayerID ) )
	end
	AWarn3_MySQLite.query( query,
	function( result )
		if checkPunishment then
			local pl = AWarn:GetPlayerFromID64( PlayerID )
			local plWarnings = PlayerWarnings
			if not IsValid( pl ) then return end
			AWarn:CheckForPunishment( pl, plWarnings )
			AWarn:ResetDecayTimer( pl )
		end
	end,
	SQLErrorFunction )
	
	local pl = AWarn:GetPlayerFromID64( PlayerID )
	if IsValid( pl ) then
		AWarn:SetPlayerActiveWarnings( pl, PlayerWarnings, false )
	end
end

function AWarn:DecayWarning( PlayerID, PlayerWarnings )

	local query = ( "UPDATE awarn3_playertable SET PlayerWarnings = %u, LastWarningDecay = %u WHERE PlayerID = %s" ):format( PlayerWarnings, os.time(), AWarn3_MySQLite.SQLStr( PlayerID ) )

	AWarn3_MySQLite.query( query,
	function( result )
		local pl = AWarn:GetPlayerFromID64( PlayerID )
		if IsValid( pl ) then
			AWarn:SetPlayerActiveWarnings( pl, PlayerWarnings, false )
		end
	end,
	SQLErrorFunction )
end

function AWarn:SetPlayerLastWarned( PlayerID )
	local PlayerID = AWarn3_MySQLite.SQLStr( PlayerID )
	local query = ( "UPDATE awarn3_playertable SET LastWarning = %u WHERE PlayerID = %s" ):format( os.time(), PlayerID )
	AWarn3_MySQLite.query( query, function() end, SQLErrorFunction )	
end

function AWarn:GetPlayerActiveWarningsFromDatabase( pl )
	local PlayerID = AWarn3_MySQLite.SQLStr( AWarn:SteamID64( pl ) )
	local query = ( "SELECT PlayerWarnings FROM awarn3_playertable WHERE PlayerID = %s" ):format( PlayerID )
	AWarn3_MySQLite.queryValue( query, 
		function( result )
			if not IsValid( pl ) then return end
			pl.awarn3 = pl.awarn3 or {}
			pl.awarn3.activewarnings = tonumber( result )
		end, 
		function( err, q ) 
			MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, err .. "\n" ) 
		end
	)
end

function AWarn:GetPlayerWarnings( PlayerID, Admin )
	local PlayerID = AWarn3_MySQLite.SQLStr( PlayerID )
	
	local query = ( "SELECT awarn3_warningtable.WarningID, awarn3_warningtable.AdminID, awarn3_warningtable.WarningReason, awarn3_warningtable.WarningServer, awarn3_warningtable.WarningDate, awarn3_playertable.PlayerName FROM awarn3_warningtable INNER JOIN awarn3_playertable ON awarn3_warningtable.AdminID = awarn3_playertable.PlayerID WHERE awarn3_warningtable.PlayerID = %s" ):format( PlayerID )
	AWarn3_MySQLite.query( query, 
		function( result )
			if not IsValid( Admin ) then return end
			if not result then result = {} end
			net.Start( "awarn3_requestplayerwarnings" )
			net.WriteString( "warnings" )
			net.WriteTable( result )
			net.Send( Admin )
		end, 
		function( err, q ) 
			MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, err .. "\n" ) 
		end
	)
	
	local query = ( "SELECT PlayerName, PlayerWarnings, LastWarning FROM awarn3_playertable WHERE PlayerID = %s" ):format( PlayerID )
	AWarn3_MySQLite.query( query, 
		function( result )
			if not IsValid( Admin ) then return end
			if not result then result = {} end
			net.Start( "awarn3_requestplayerwarnings" )
			net.WriteString( "info" )
			net.WriteTable( result )
			net.Send( Admin )
		end, 
		function( err, q ) 
			MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, err .. "\n" ) 
		end
	)
end

function AWarn:GetOwnWarnings( player )
	local PlayerID = AWarn3_MySQLite.SQLStr( player:SteamID64() )
	
	local query = ( "SELECT awarn3_warningtable.WarningID, awarn3_warningtable.AdminID, awarn3_warningtable.WarningReason, awarn3_warningtable.WarningServer, awarn3_warningtable.WarningDate, awarn3_playertable.PlayerName FROM awarn3_warningtable INNER JOIN awarn3_playertable ON awarn3_warningtable.AdminID = awarn3_playertable.PlayerID WHERE awarn3_warningtable.PlayerID = %s" ):format( PlayerID )
	AWarn3_MySQLite.query( query, 
		function( result )
			if not IsValid( player ) then return end
			if not result then result = {} end
			net.Start( "awarn3_requestownwarnings" )
			net.WriteTable( result )
			net.Send( player )
		end, 
		function( err, q ) 
			MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, err .. "\n" ) 
		end
	)
	
end


net.Receive( "awarn3_requestplayerwarnings", function( len, pl )
	if not IsValid( pl ) then return end
	if not AWarn:CheckPermission( pl, "awarn_view" ) then
		AWarn:SendChatMessage( {AWarn.Localization:GetTranslation( "insufficientperms2" )}, pl )
		return
	end
	AWarn:GetPlayerWarnings( net.ReadString(), pl )
end )

net.Receive( "awarn3_requestownwarnings", function( len, pl )
	if not IsValid( pl ) then return end
	pl.totalOwnRequestsInTime = ( pl.totalOwnRequestsInTime or 0 ) + 1
	if (pl.lastOwnRequest or 0) > (CurTime() - 5) then
		if pl.totalOwnRequestsInTime >= 10 then
			AWarn:Kick( pl, "You were kicked for trying to exploit/crash the server", "%s was kicked for trying to exploit/crash the server" )
		end
		return
	end
	AWarn:GetOwnWarnings( pl )
	pl.lastOwnRequest = CurTime()
	pl.totalOwnRequestsInTime = 0
end )


local function StreamTableToClient( tbl, pl )
	if not IsValid( pl ) then return end
	local newTbl = {}
	local tCounter = 0
	local totalTbls = 1
	local splitNum = 100
	
	if #tbl <= splitNum then
		net.Start( "awarn3_requestplayersearchdata" )
		net.WriteInt( totalTbls, 8 )
		net.WriteTable( tbl )
		net.Send( pl )
	else
		while #tbl > 0 do
			newTbl[ totalTbls ] = newTbl[ totalTbls ] or {}
			table.insert( newTbl[ totalTbls ], tbl[1] )
			table.remove( tbl, 1 )
			tCounter = tCounter + 1
			if tCounter >= splitNum then
				tCounter = 0
				if #tbl > 0 then
					totalTbls = totalTbls + 1
				end
			end
		end
		
		for i = 1, totalTbls do
			if newTbl[i] then
				timer.Simple( i * 0.3, function()
					net.Start( "awarn3_requestplayersearchdata" )
					net.WriteInt( i, 8 )
					net.WriteTable( newTbl[i] )
					net.Send( pl )
				end )
			end
		end
	end
end

function AWarn:GetSearchPlayerInfo( SearchString, exclude, Admin )
	local query = ""
	if exclude then
		if SearchString then
			local SearchString = AWarn3_MySQLite.SQLStr( "%" .. SearchString .. "%" )
			query = ("SELECT PlayerID, PlayerName, PlayerWarnings, LastWarning, LastPlayed FROM awarn3_playertable WHERE ( PlayerID LIKE %s OR PlayerName LIKE %s ) AND LastWarning <> 'NULL'"):format( SearchString, SearchString )
		else
			query = "SELECT PlayerID, PlayerName, PlayerWarnings, LastWarning, LastPlayed FROM awarn3_playertable WHERE LastWarning <> 'NULL'"
		end
	else
		if SearchString then
			local SearchString = AWarn3_MySQLite.SQLStr( "%" .. SearchString .. "%" )
			query = ("SELECT PlayerID, PlayerName, PlayerWarnings, LastWarning, LastPlayed FROM awarn3_playertable WHERE PlayerID LIKE %s OR PlayerName LIKE %s"):format( SearchString, SearchString )
		else
			query = "SELECT PlayerID, PlayerName, PlayerWarnings, LastWarning, LastPlayed FROM awarn3_playertable"
		end	
	end
	
	AWarn3_MySQLite.query( query, 
		function( result )
			if not IsValid( Admin ) then return end
			if not result then result = {} end
			StreamTableToClient( result, Admin )
		end, 
		function( err, q ) 
			MsgC( AWARN3_SERVER, "[AWarn3] ", AWARN3_WHITE, err .. "\n" ) 
		end
	)
end



net.Receive( "awarn3_requestplayersearchdata", function( len, pl )
	if not IsValid( pl ) then return end
	if not AWarn:CheckPermission( pl, "awarn_view" ) then
		AWarn:SendChatMessage( {AWarn.Localization:GetTranslation( "insufficientperms" )}, pl )
		return
	end
	AWarn:GetSearchPlayerInfo( net.ReadString(), net.ReadBool(), pl )
end )


AWarn:ConnectToDatabase()