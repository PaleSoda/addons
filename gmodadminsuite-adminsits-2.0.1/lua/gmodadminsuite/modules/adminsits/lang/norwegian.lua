return {
	Name = "Norwegian",
	Flag = "flags16/no.png",
	Phrases = function() return {

		module_name = "Admin Sits",

		NotAllowedInSit = "Du kan ikke gjøre dette under et sit!",
		PlayerMayBeStuck = "PLY_NAME ble teleportert, men de sitter fast!",
		DisconnectedPlayerReconnected = "PLY_NAME PLY_STEAMID fra sit SIT_ID har koblet til igjen!",
		NoSitPosition = "Det er ikke satt noen sit stilling for dette kartet! Skriv !Sitpos for å stille en sit stilling.",

		AdminSit = "Admin Sit",
		Unknown = "Ukjent",
		Dismiss = "Avskjedige",
		Error = "Feil",
		Yes = "Ja",
		No = "Nei",

		Hours = "%s timer",
		Never = "Aldri",
		VACBans = "VAC Bans: %s",
		LastBan = "Dager siden siste ban: %s",
		GameBans = "Spillforbud: %s",
		TradeBanned = "Handel forbud: %s",
		MemberSince = "Medlem siden: %s",
		CheckPocketNone = "Ingen ting i lommen",
		NoSteamAPIKey = "Servereieren har ikke satt Steam API-nøkkelen sin, så denne funksjonen er ikke tilgjengelig :(\nSpør servereieren / utvikleren om å konfigurere gmodadminsuite_steam_apikey.lua i deres GmodAdminSuite konfigurasjonsfilen.",
		CheckSteamFamilySharing_Error = "Det oppstod en feil under forsøk på å hente data fra Steam-servere. De kan være utilgjengelige.\nForsikre deg om at servereieren har satt riktig Steam API-nøkkel i gmodadminsuite_steam_apikey.lua-filen i GmodAdminSuite konfigurasjonsfilen.",
		CheckSteamFamilySharingYes = "%s er Familie Deler Garry's Mod med %s.",
		CheckSteamFamilySharingNo = "%s deler ikke Garry's Mod med noen.",

		SteamFriendStatusYes = "%s er venner med %s på Steam!",
		SteamFriendStatusNo = "%s er IKKE VENNER %s på Steam!",
		PlayerOfflineError = "Spilleren må være på serveren for og utføre denne handlingen.",

		SteamProfile_Failure = "Kunne ikke hente Steam-profilen! (%s)\nSjekk Steam-status eller nettverkstilkoblingen din.",
		SteamProfile_CheckGmodPlaytime_Failed = "Kunne ikke hente Gmod-spilletid fra Steam-profilen.\nBrukeren har kanskje ikke satt opp samfunnsprofilen sin, eller har innstillingene for personvern satt til å skjule disse dataene.",
		SteamProfile_CheckSteamAge_Failed = "Kunne ikke hente alderen til Steam Brukeren.\nBrukeren har kanskje ikke satt opp samfunnsprofilen sin, eller har innstillingene for personvern satt til å skjule disse dataene.",

		NoWeapons = "Ingen våpen",
		Screenshot = "Skjermbildet",
		ScreenshotTip = "Ta skjermbildet fra %s [%s] tatt på %s",
		ScreenshotTip2 = "Hvis skjermbildet er svart, en cheat kan blokkere bildet fra og bli tatt, a cheat may be blocking the screenshot from being taken.",

		PlayerLine_Active = "Aktiv",
		PlayerLine_Inactive = "AFK / Tabbed Out",
		PlayerLine_Unreachable = "Timing Out",

		RemoveFromSit      = "Fjern fra sit",
		TeleportToSit      = "Teleporter til Sit",
		MuteMicrophone     = "Demp mikrofon",
		UnmuteMicrophone   = "Slå på mikrofon",
		DisableTextChat    = "Deaktiver chat",
		EnableTextChat     = "Aktiver chat",
		SteamProfile       = "Steam Profil",
		CopySteamID        = "Kopier SteamID",
		CopySteamID64      = "Kopier SteamID64",
		CopyIPAddress      = "Kopier IP Address",
		TakeScreenshot     = "Ta Skjermbilde",
		CheckWeapons       = "Sjekk Weapons",
		CheckSteamFriends  = "Sjekk Steam Venner",
		CheckSteamGroups   = "Sjekk Steam Grupper",
		CheckSteamAge      = "Sjekk Steam Bruker Alder",
		CheckWallet        = "Sjekk Lommebok",
		CheckPocket        = "Sjekk Lomme",
		CheckValveBans     = "Sjekk Valve Bans",
		CheckGmodPlaytime  = "Sjekk GMod Spilletid",
		CheckSteamFamShare = "Sjekk Steam Familie Deling",
		FlashWindow        = "Flash Windows Oppgavelinje",

		NoPermission = "Du har ikke tillatelse til å bruke sit-systemet!",
		NoPermission_TargetStaff = "Du har ikke tillatelse til å fjerne PLY_NAME fra et sit.",
		ChatCommand_MultipleMatches = "Fant ARG_COUNT motstridende spillernavn: MATCH_FAILS - prøv å være mer spesifikk",
		ChatCommand_MatchFailed = "Kunne ikke finne MATCH_COUNT spiller med navn som inneholder: MATCH_FAILS",
		ChatCommand_MatchFailed_Plural = "Kunne ikke finne MATCH_COUNT spillere med navn som inneholder: MATCH_FAILS",
		ChatCommand_AlreadyInSit = "PLY_NAME er allerede i en sit! Skriv !sits for å se en liste over aktive sits.",
		ChatCommand_Clash = "Vi kunne ikke finne ut hva du ville gjøre med disse spillerne fordi de er i forskjellige situasjoner - prøv !sit med en spiller om gangen.",
		ChatCommand_Clash_AddToSit = "PLY_NAME er ikke i et sit (MATCH_FAIL)",
		ChatCommand_Clash_RemoveFromSit = "PLY_NAME er i et sit (MATCH_FAIL)",
		ChatCommand_NoResitArgs = "Du har ingen tidligere sit, eller din forrige sit ble foreldet (alle spillere koblet fra)",
		ChatCommand_InviteSent = "En invitasjon til å delta i et sit er sendt til PLY_NAME!",

		SitInviteReceivedTitle = "Admin Sit Invitasjon",
		SitInviteReceived = "Du har blitt invitert til et sit av %s, Klikk for å bli med!",
		JoinSit = "BLI MED",

		AddPlayer = "Legg til spiller",
		AddPlayerEllipsis = "Legg til spiller...",
		EndSit = "Stopp Sittet",
		EndSitAreYouSure = "Er du sikker på at du vil avslutte sittet?",
		PlayerAlreadyInSit = "Denne spilleren er allerede i en sit; skriv  !sits for å se hvilket sit de er i.",
		PlayerInvitedToSit = "Spilleren har blitt invitert til sittet!",

		ScreenshotFailedText = "Kunne ikke laste opp skjermbilde til serveren!\nEnten er skjermbilde serveren nede, eller spillerens / serverens nettverk blokkerer tilkoblinger til Enten er skjermdumpserveren nede, eller spillerens / serverens nettverk blokkerer tilkoblinger til skjermbilde serveren.\nCheaters kan være i stand til å forårsake dette ved å blokkere skjermbilde serveren i nettverket deres, eller ved å bryte denne funksjonen gjennom Lua.",
		ScreenshotFailed = "Skjermbilde mislyktes",

		AllStaffDisconnected = "Alle administratorer i sittet har frakoblet fra serveren; sittet har sluttet",
		AllPlayersDisconnected = "Alle spillere i sittet har frakoblet fra serverten, de vil bli lagt tilbake hvis de kobler til igjen.",
		AllPlayersDisconnected2 = "Hvis du avslutter sittet, hvis spilleren / spillerne kobler til, vil du bli varslet.",

		TakingScreenshot = "Tar skjermbilde...",
		Staff = "Administratorer",

		ShowDisconnectReason = "PLY_NAME koblet fra serveren under et sit (DISCONNECT_REASON)",
		ShowDisconnectReason_NoReason = "PLY_NAME koblet fra serveren under et sit",

		ReloadTip = "Reload for admin sit",
		ReloadTipRemove = "Reload for og fjerne fra sit",

		SitID = "Sit #%d",
		JoinSitLine = "Bli med i Sit",

		Refresh = "Forfriske",

		SitPosFailed = "Kunne ikke angi sittestilling! Forsikre deg om at du er i verden, og ikke sitter fast.",
		SitPosSuccess = "Angi sittestilling vellykket!",

} end }