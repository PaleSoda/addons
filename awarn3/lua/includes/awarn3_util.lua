--[[
      __          __              ____  
     /\ \        / /             |___ \ 
    /  \ \  /\  / /_ _ _ __ _ __   __) |
   / /\ \ \/  \/ / _` | '__| '_ \ |__ < 
  / ____ \  /\  / (_| | |  | | | |___) |
 /_/    \_\/  \/ \__,_|_|  |_| |_|____/ 

	AWarn3 by Mr.President
]]

MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, "Loading Utilities Module\n" )


if CLIENT then return end
util.AddNetworkString( "awarn3_clientmessage" )
util.AddNetworkString( "awarn3_warningmessage" )
util.AddNetworkString( "awarn3_chatmessagecolor" )

util.AddNetworkString( "awarn3_createwarningid" )
util.AddNetworkString( "awarn3_addactivewarning" )
util.AddNetworkString( "awarn3_deleteallplayerwarnings" )
util.AddNetworkString( "awarn3_deletesinglewarning" )
util.AddNetworkString( "awarn3_updateplayernotes" )
util.AddNetworkString( "awarn3_notesrequest" )

util.AddNetworkString( "awarn3_requestplayerwarnings" )
util.AddNetworkString( "awarn3_requestplayersearchdata" )
util.AddNetworkString( "awarn3_requestownwarnings" )
util.AddNetworkString( "awarn3_openmenu" )

util.AddNetworkString( "awarn3_playerjoinandleave" )

util.AddNetworkString( "awarn3_networkoptions" )
util.AddNetworkString( "awarn3_networkpunishments" )
util.AddNetworkString( "awarn3_networkpresets" )

local PLAYER = FindMetaTable( "Player" )

function PLAYER:GetTeamColor()

	return team.GetColor( self:Team() )

end