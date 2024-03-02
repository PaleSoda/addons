return {
	Name = "English",
	Flag = "flags16/gb.png",
	Phrases = function() return {

		module_name = "Admin Sits",

		NotAllowedInSit = "You can't do this during a sit!",
		PlayerMayBeStuck = "PLY_NAME was teleported, but they're stuck!",
		DisconnectedPlayerReconnected = "PLY_NAME PLY_STEAMID from sit SIT_ID has reconnected!",
		NoSitPosition = "There is no sit position set for this map! Type !sitpos to set a sit position.",

		AdminSit = "Admin Sit",
		Unknown = "Unknown",
		Dismiss = "Dismiss",
		Error = "Error",
		Yes = "Yes",
		No = "No",

		LeaveSit = "Leave Sit",

		Hours = "%s hours",
		Never = "Never",
		VACBans = "VAC Bans: %s",
		LastBan = "Days since last ban: %s",
		GameBans = "Game Bans: %s",
		TradeBanned = "Trade Banned: %s",
		MemberSince = "Member Since: %s",
		CheckPocketNone = "No items in pocket",
		NoSteamAPIKey = "The server owner has not set their Steam API key, so this feature is unavailable :(\nPlease ask the server owner/developer to configure gmodadminsuite_steam_apikey.lua in their GmodAdminSuite config addon.",
		CheckSteamFamilySharing_Error = "An error occured while trying to retrieve data from Steam servers. They might be unavailable.\nPlease ensure the server owner has set the correct Steam API Key in the gmodadminsuite_steam_apikey.lua file in the GmodAdminSuite config addon.",
		CheckSteamFamilySharingYes = "%s is Steam Family Sharing Garry's Mod with %s.",
		CheckSteamFamilySharingNo = "%s is NOT Steam Family Sharing Garry's Mod with anyone.",

		SteamFriendStatusYes = "%s is friends with %s on Steam!",
		SteamFriendStatusNo = "%s is NOT friends with %s on Steam!",
		PlayerOfflineError = "The target player must be on the server to perform this action.",

		SteamProfile_Failure = "Failed to retrieve Steam profile! (%s)\nCheck Steam status or your network connection.",
		SteamProfile_CheckGmodPlaytime_Failed = "Failed to retrieve Gmod playtime from Steam profile.\nThe user may not have set up their community profile, or has their privacy settings set to hide this data.",
		SteamProfile_CheckSteamAge_Failed = "Failed to retrieve Steam account age from Steam profile.\nThe user may not have set up their community profile, or has their privacy settings set to hide this data.",

		NoWeapons = "No Weapons",
		Screenshot = "Screenshot",
		ScreenshotTip = "Screenshot from %s [%s] taken on %s",
		ScreenshotTip2 = "If the screenshot is black, a cheat may be blocking the screenshot from being taken.",

		PlayerLine_Active = "Active",
		PlayerLine_Inactive = "AFK / Tabbed Out",
		PlayerLine_Unreachable = "Timing Out",

		RemoveFromSit      = "Remove from Sit",
		TeleportToSit      = "Teleport to Sit",
		MuteMicrophone     = "Mute Microphone",
		UnmuteMicrophone   = "Unmute Microphone",
		DisableTextChat    = "Disable Text Chat",
		EnableTextChat     = "Enable Text Chat",
		SteamProfile       = "Steam Profile",
		CopySteamID        = "Copy SteamID",
		CopySteamID64      = "Copy SteamID64",
		CopyIPAddress      = "Copy IP Address",
		TakeScreenshot     = "Take Screenshot",
		CheckWeapons       = "Check Weapons",
		CheckSteamFriends  = "Check Steam Friends",
		CheckSteamGroups   = "Check Steam Groups",
		CheckSteamAge      = "Check Steam Account Age",
		CheckWallet        = "Check Wallet",
		CheckPocket        = "Check Pocket",
		CheckValveBans     = "Check Valve Bans",
		CheckGmodPlaytime  = "Check GMod Playtime",
		CheckSteamFamShare = "Check Steam Family Sharing",
		FlashWindow        = "Flash Windows Taskbar",

		NoPermission = "You don't have permission to use the sit system!",
		NoPermission_TargetStaff = "You don't have permission to remove PLY_NAME from a sit.",
		ChatCommand_MultipleMatches = "Found ARG_COUNT conflicting player names: MATCH_FAILS - try being more specific",
		ChatCommand_MatchFailed = "Failed to find MATCH_COUNT player with name containing: MATCH_FAILS",
		ChatCommand_MatchFailed_Plural = "Failed to find MATCH_COUNT players with names containing: MATCH_FAILS",
		ChatCommand_AlreadyInSit = "PLY_NAME is already in a sit! Type !sits to see a list of currently active sits.",
		ChatCommand_Clash = "We couldn't work out what you wanted to do with these players because they're in different situations - try !sit with one player at a time.",
		ChatCommand_Clash_AddToSit = "PLY_NAME is NOT in a sit (MATCH_FAIL)",
		ChatCommand_Clash_RemoveFromSit = "PLY_NAME is in a sit (MATCH_FAIL)",
		ChatCommand_NoResitArgs = "You have no known previous sit, or your previous sit went stale (all players disconnected)",
		ChatCommand_InviteSent = "An invite to join the sit has been sent to PLY_NAME!",

		SitInviteReceivedTitle = "Admin Sit Invite",
		SitInviteReceived = "You've been invited to a sit by %s, click to join!",
		JoinSit = "JOIN",

		AddPlayer = "Add Player",
		AddPlayerEllipsis = "Add player...",
		EndSit = "End Sit",
		EndSitAreYouSure = "Are you sure you want to end this sit?",
		PlayerAlreadyInSit = "This player is already in a sit; type !sits to see which sit they're in.",
		PlayerInvitedToSit = "Player has been invited to sit!",

		ScreenshotFailedText = "Failed to upload screenshot to server!\nEither the screenshot server is down or the player's/server's network is blocking connections to the screenshot server.\nCheaters may be able to cause this by blocking the screenshot server on their network, or by breaking this feature through Lua.",
		ScreenshotFailed = "Screenshot Failed",

		AllStaffDisconnected = "All staff in the sit have disconnected; the sit has been ended.",
		AllPlayersDisconnected = "All players in the sit have disconnected, they will be added back if they rejoin.",
		AllPlayersDisconnected2 = "If you end the sit, if the player(s) rejoin, you will be notified.",

		TakingScreenshot = "Taking screenshot...",
		Staff = "Staff",

		ShowDisconnectReason = "PLY_NAME disconnected from the server during sit (DISCONNECT_REASON)",
		ShowDisconnectReason_NoReason = "PLY_NAME disconnected from the server during sit",

		ReloadTip = "Reload for admin sit",
		ReloadTipRemove = "Reload to remove from sit",

		SitID = "Sit #%d",
		JoinSitLine = "Join Sit",

		Refresh = "Refresh",

		SitPosFailed = "Failed to set sit position! Make sure you are in the world, and not stuck.",
		SitPosSuccess = "Set sit position successfully!",

		NoActiveSits = "There are no active sits",

		--## Admin Prison ##--

		AdminPrison = "Admin Prison",
		AdminPrison_ChatCommand_NoMatches = "Failed to find a player matching that name, SteamID or SteamID64!",
		AdminPrison_ChatCommand_OverQualified = "Found ARG_COUNT conflicting player names: MATCH_FAILS - try being more specific",
		AdminPrison_Prisoner = "Prisoner",
		AdminPrison_ImprisonmentTime = "Imprisonment Time",
		AdminPrison_Reason = "Reason",
		AdminPrison_Imprison = "Imprison",
		AdminPrison_PlayerDisconnected = "The player disconnected as you were about to imprison them :(",
		AdminPrison_ClickToFocus = "Click to focus",
		AdminPrison_NoPermission = "You don't have permission to use this!",
		AdminPrison_SentToPrison_Success = "PLY_NAME has been sent to prison for RELEASE_TIME",
		AdminPrison_ReleasedFromPrison = "You've been released from prison!",

} end }