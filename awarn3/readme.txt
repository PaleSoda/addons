Console Commands
----------------
awarn warn <player name/SteamID> <reason>		- Warns a player with given reason.
awarn removewarn <playername/SteamID>			- Removes a single active warning from a player.
awarn deletewarnings <player name/SteamID>		- Deletes all warnings from a player.
awarn menu										- Opens the AWarn3 Menu.




Chat Commands
----------------
!warn 								- Opens the AWarn3 Menu
!warn <player/steamid> <reason>		- Warns a player with given reason.




Methods
-------
PLAYER:GetActiveWarnings()
	--This returns the total active warning count for the player.
	
	
	
	
Hooks
-------
AWarnPlayerWarned( Player targetply, String adminid, String warningreason )
	targetply 		- Player entity that was warned.
	adminid 		- SteamID64 of the admin who did the warning.
	warningreason	- The reason provided for the warning.
	
AWarnPlayerIDWarned( String targetid, String adminid, String warningreason )
	targetid 		- SteamID64 of the player that was warned.
	adminid 		- SteamID64 of the admin who did the warning.
	warningreason	- The reason provided for the warning.
	
	
	
Permissions
------------
These are the permissions you will need to use for whatever admin mod you are using.

awarn_view		-	Players with this permission can view other players' warnings.
awarn_warn		-	Players with this permission can warn other players.
awarn_remove	-	Players with this permission can remove active warnings from players.
awarn_delete	-	Players with this permission can delete the warnings from players.
awarn_options	-	Players with this permission have access to change the server options.
awarn_immune	-	Players with this permission are immune to being warned.
	


MYSQL INSTALLATION INSTRUCTIONS
-------------------------------

1. In your database, create a new database for AWarn3. You can call it whatever you like, but remember that AWarn3 IS NOT COMPATIBLE with AWarn2, so use a new database if updating.
2. Make sure you have an SQL user that has read and write access to that database.
3. Go into awarn3/lua/includes/awarn3_sql.lua and edit the connection info at the top.
4. In game, you can open the AWarn3 menu and configure your server's name (for multiple servers).

Please Note: This is as much support for MySQL as I will give (outside of genuine bugs). I provide support for MYSQL as a convenience, but it is up to you to know how to set up your MySQL server and gmod plugin.



DISCORD LOGGING RELAY INSTRUCTIONS
----------------------------------

1. If you wish to use discord logging, go into lua/includes/awarn3_discordlogging.lua and edit the settings at the top to enable and set your webhook URL.
2. Create (or reuse) a webhook on your discord server and set the URL for the webhook at the top of the awarn3_discordlogging.lua file.
3. Feel free to use the relay I have provided through my web server, but if you want to use your own server, you can upload the file I have provided (along side this readme)
to your own server and set the ULR path in the awarn3_discordlogging.lua file.
 