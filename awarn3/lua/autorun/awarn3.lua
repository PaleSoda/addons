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

MsgC( Color( 255,255,128 ), "\n      __          __              ", Color(0,255,0), "____  \n" )
MsgC( Color( 255,255,128 ), "     /\\ \\        / /             ", Color(0,255,0), "|___ \\ \n" )
MsgC( Color( 255,255,128 ), "    /  \\ \\  /\\  / /_ _ _ __ _ __   ", Color(0,255,0), "__) |\n" )
MsgC( Color( 255,255,128 ), "   / /\\ \\ \\/  \\/ / _` | '__| '_ \\ ", Color(0,255,0), "|__ < \n" )
MsgC( Color( 255,255,128 ), "  / ____ \\  /\\  / (_| | |  | | | |", Color(0,255,0), "___) |\n" )
MsgC( Color( 255,255,128 ), " /_/    \\_\\/  \\/ \\__,_|_|  |_| |_|", Color(0,255,0), "____/\n" )
MsgC( Color( 255,255,255 ), "────────────────────────────────────────────\n" )
MsgC( Color( 255,0,0 ), "[AWarn3] ", Color( 255, 255, 255 ), "Welcome to AWarn3!\n" )


AWarn = AWarn or {}

AWarn.Version = "2.4.3"

AWARN3_WHITE 	= Color(255,255,255)
AWARN3_SERVER 	= Color(0,200,255)
AWARN3_CLIENT 	= Color(255,136,0)
AWARN3_WARNING	= Color(128,0,0)
AWARN3_CHATTAG	= Color(255,0,0)

if SERVER then
	AWARN3_STATECOLOR = AWARN3_SERVER
	include( "includes/sv_awarn3.lua")
end

if CLIENT then
	AWARN3_STATECOLOR = AWARN3_CLIENT
	include( "includes/cl_awarn3.lua")
end