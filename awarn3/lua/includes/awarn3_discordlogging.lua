--[[
      __          __              ____  
     /\ \        / /             |___ \ 
    /  \ \  /\  / /_ _ _ __ _ __   __) |
   / /\ \ \/  \/ / _` | '__| '_ \ |__ < 
  / ____ \  /\  / (_| | |  | | | |___) |
 /_/    \_\/  \/ \__,_|_|  |_| |_|____/ 

	AWarn3 by Mr.President
]]

----------------------------------------------------------------------
----------------------------------------------------------------------

--Set this to true if you wish to enable discord logging. Note: You'll need to provide a webhook URL below as well.
local enable_discord_logging = false

--Set the Webhook URL for your discord server channel here. To create a webhook:
--Go into Server Settings > Integrations > Click 'View Webhooks' > Click New Webhook.
--Customize the name and channel it posts to, then click copy Webhook URL and paste it below. 
local discord_webhook_url = "**ENTER YOUR WEBHOOK URL HERE**"

--Feel free to keep this using the relay on my server. If you want to use your own server, you can upload the file located in the addon folder to your own server and change the path here.
local discord_webhook_relay_url = "https://g4p.org/awarn3/discordrelay/discordrelay.php"

----------------------------------------------------------------------
----------------------------------------------------------------------



MsgC( AWARN3_STATECOLOR, "[AWarn3] ", AWARN3_WHITE, "Loading Discord Module\n" )


hook.Add( "AWarnPlayerWarned", "AWarn3WarningDiscordRelay", function( pl, aID, reason )
	local admin = AWarn:GetPlayerFromID64( aID )
	if not admin then return end
	
	AWarn:DiscordWarning( pl:GetName(), admin:GetName(), reason )
end )

hook.Add( "AWarnPlayerIDWarned", "AWarn3IDWarningDiscordRelay", function( pID, aID, reason )
	local admin = AWarn:GetPlayerFromID64( aID )
	if not admin then return end
	
	AWarn:DiscordWarning( tostring("ID: " .. pID), admin:GetName(), reason )
end )

function AWarn:DiscordWarning( pl, adm, reason )
	if not enable_discord_logging then return end
	http.Post(discord_webhook_relay_url, {
		log_type = "warning",
		title = "AWarn3 - Warning on " .. AWarn:GetOption( "awarn_server_name" ) or game.GetIPAddress(),
		bar_color = "#FF8C00",
		url = discord_webhook_url,
		warned_player = pl,
		warning_admin = adm,
		warning_reason = reason
		}, function( r ) print(r) end, function( e ) print(e) end
	)
end

function AWarn:DiscordPunishment(pl, str, warnings )
	if not enable_discord_logging then return end
	timer.Simple( 2, function()
		http.Post(discord_webhook_relay_url, {
			log_type = "punishment",
			title = "AWarn3 - Punishment on " .. AWarn:GetOption( "awarn_server_name" ) or game.GetIPAddress(),
			bar_color = "#FF0000",
			url = discord_webhook_url, 
			punished_player = pl,
			punishment = str,
			player_warnings = tostring(warnings)
			}, function( r ) print(r) end, function( e ) print(e) end
		)
	end )
end