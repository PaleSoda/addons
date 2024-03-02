return {
	Name = "Polish",
	Flag = "flags16/pl.png",
	Phrases = function() return {

		module_name = "Admin Sits",

		NotAllowedInSit = "Nie możesz tego zrobić w czasie posiedzenia!",
		PlayerMayBeStuck = "PLY_NAME został teleportowany, ale utknął.!",
		DisconnectedPlayerReconnected = "PLY_NAME PLY_STEAMID z posiedzenia SIT_ID połączył się ponownie!",
		NoSitPosition = "Dla tej mapy nie ma ustawionej pozycji administratorskiej! Wpisz !sitpos do ustawienia pozycji miejsca administratora.",

		AdminSit = "Admin Sit",
		Unknown = "Nieznany",
		Dismiss = "Oddalić",
		Error = "Błąd",
		Yes = "Tak",
		No = "Nie",

		LeaveSit = "Opuść posiedzenie",

		Hours = "%s godzin",
		Never = "Nigdy",
		VACBans = "Bany VAC: %s",
		LastBan = "Dni od ostatniego bana: %s",
		GameBans = "Bany gier: %s",
		TradeBanned = "Handlów zbanowanych: %s",
		MemberSince = "Członek Od: %s",
		CheckPocketNone = "Brak przedmiotów w kieszeni",
		NoSteamAPIKey = "Właściciel serwera nie ustawił klucza API Steam, więc ta funkcja jest niedostępna :(\nProszę poprosić właściciela serwera/ dewelopera, aby skonfigurował gmodadminsuite_steam_apikey.lua w swoim dodatku konfiguracyjnym GmodAdminSuite.",
		CheckSteamFamilySharing_Error = "Podczas próby pobrania danych z serwerów Steam wystąpił błąd. Mogą one być niedostępne.\nProszę upewnić się, że właściciel serwera ustawił poprawny klucz API Steam w pliku gmodadminsuite_steam_apikey.lua w dodatku konfiguracyjnym GmodAdminSuite.",
		CheckSteamFamilySharingYes = "%s Wykryto udostępnianie rodzinne z  %s.",
		CheckSteamFamilySharingNo = "%s To konto nie udostępnia rodzinnie żadnej gry z nikim.",

		SteamFriendStatusYes = "%s jest przyjacielem z %s na Steam!",
		SteamFriendStatusNo = "%s NIE są przyjaciółmi z %s na Steam!",
		PlayerOfflineError = "Aby wykonać tę czynność, gracz docelowy musi znajdować się na serwerze.",

		SteamProfile_Failure = "Nie udało się odzyskać profilu Steam! (%s)\nCheck status steam  lub połączenie sieciowe.",
		SteamProfile_CheckGmodPlaytime_Failed = "Nie udało się odzyskać gry Gmod z profilu Steam.\nUżytkownik mógł nie skonfigurować swojego profilu społecznościowego lub mieć ustawione ustawienia prywatności, aby ukryć te dane..",
		SteamProfile_CheckSteamAge_Failed = "Nie udało się odzyskać wieku konta Steam z profilu Steam.\nUżytkownik może nie mieć ustawionego profilu społecznościowego lub ma ustawione ustawienia prywatności, aby ukryć te dane..",

		NoWeapons = "Brak broni",
		Screenshot = "Zrzut ekranu",
		ScreenshotTip = "Zrzut ekranu z  %s [%s] załatwiony od %s",
		ScreenshotTip2 = "Jeśli zrzut ekranowy jest czarny, oszust może blokować zrzut ekranowy..",

		PlayerLine_Active = "Aktywny",
		PlayerLine_Inactive = "AFK / Zablokowany",
		PlayerLine_Unreachable = "Utracono połączenie",

		RemoveFromSit      = "Usuń z posiedzenia",
		TeleportToSit      = "Teleportuj do posiedzenia",
		MuteMicrophone     = "Zmutuj Mikrofon",
		UnmuteMicrophone   = "Odmutuj Mikrofon",
		DisableTextChat    = "Wyłącz czat pisemny",
		EnableTextChat     = "Włącz czat pisemny ",
		SteamProfile       = "Profil Steam",
		CopySteamID        = "Kopiuj SteamID",
		CopySteamID64      = "Kopiuj SteamID64",
		CopyIPAddress      = "Kopiuj Adres IP",
		TakeScreenshot     = "Zrób zrzut ekranu",
		CheckWeapons       = "Sprawdź bronie",
		CheckSteamFriends  = "Sprawdź przyjaciół steam",
		CheckSteamGroups   = "Sprawdź grupy steam",
		CheckSteamAge      = "Sprawdź wiek konta Steam",
		CheckWallet        = "Sprawdź portfel",
		CheckPocket        = "Sprawdź kieszenie",
		CheckValveBans     = "Sprawdź bany VALVE",
		CheckGmodPlaytime  = "Sprawdź czas rozgrywki GMOD",
		CheckSteamFamShare = "Sprawdź udostępnianie rodzinne konta",
		FlashWindow        = "Zamaż Windows Taskbara",

		NoPermission = "Nie masz pozwolenia na korzystanie z systemu posiedzeń!",
		NoPermission_TargetStaff = "Nie masz pozwolenia na usunięcie PLY_NAME z posiedzenia!",
		ChatCommand_MultipleMatches = "Znaleziono ARG_COUNT sprzeczne nazwy graczy: MATCH_FAILS - spróbuj być bardziej konkretny",
		ChatCommand_MatchFailed = "Nie udało się znaleźć MATCH_COUNT gracza z nazwą zawierającą: MATCH_FAILS",
		ChatCommand_MatchFailed_Plural = "Nie udało się znaleźć MATCH_COUNT  gracza z nazwą zawierającą: MATCH_FAILS",
		ChatCommand_AlreadyInSit = "PLY_NAME jest już na miejscu! Wpisz !sits aby zobaczyć listę aktualnie aktywnych miejsc posiedzeń.",
		ChatCommand_Clash = "Nie mogliśmy wymyślić, co chcesz zrobić z tymi graczami, bo są w różnych sytuacjach - spróbuj wpisać !sit z jednym zawodnikiem na raz.",
		ChatCommand_Clash_AddToSit = "PLY_NAME NIE jest w posiedzeniu (MATCH_FAIL)",
		ChatCommand_Clash_RemoveFromSit = "PLY_NAME znajduje się w posiedzeniu (MATCH_FAIL)",
		ChatCommand_NoResitArgs = "Nie masz znanego poprzedniego miejsca, lub Twoje poprzednie miejsce było nieużywane (wszyscy gracze rozłączeni)",
		ChatCommand_InviteSent = "Zaproszenie do udziału w posiedzeniu zostało przesłane do PLY_NAME!",

		SitInviteReceivedTitle = "Zaproszenie do posiedzenia",
		SitInviteReceived = "Zostałeś zaproszony do posiedzenia przez %s, kliknij aby dołączyć!",
		JoinSit = "DOŁĄCZ",

		AddPlayer = "Dodaj graczy",
		AddPlayerEllipsis = "Dodaj graczy...",
		EndSit = "Zakończ posiedzenie",
		EndSitAreYouSure = "Czy napewno chcesz zakończyć posiedzenie?",
		PlayerAlreadyInSit = "Ten gracz jest już na miejscu; wpisz !sits, aby zobaczyć, na którym posiedzeniu siedzą.",
		PlayerInvitedToSit = "Gracz został zaproszony do posiedzenia!",

		ScreenshotFailedText = "Nie udało się przesłać zrzutu ekranu na serwer! Albo serwer zrzutów ekranu jest uszkodzony, albo sieć gracza/serwera blokuje połączenia z serwerem zrzutów ekranu.\nCheaters mogą to spowodować, blokując serwer zrzutów ekranu w swojej sieci, albo przerywając tę funkcję przez Lua.",
		ScreenshotFailed = "Niepowodzenie podczas zrzut ekraniu",

		AllStaffDisconnected = "Wszyscy członkowie personelu zostali rozłączeni; posiedzenie zostało zakończone.",
		AllPlayersDisconnected = "Wszyscy gracze na miejscu rozłączyli się, zostaną dodani z powrotem, jeśli ponownie się przyłączą.",
		AllPlayersDisconnected2 = "Jeśli zakończysz posiedzenie, jeśli gracz(e) ponownie dołączy(ą), zostaniesz powiadomiony(e) o tym fakcie.",

		TakingScreenshot = "Rozbienie zrzutu...",
		Staff = "Administracja",

		ShowDisconnectReason = "PLY_NAME odłączony od serwera podczas posiedzenia (DISCONNECT_REASON)",
		ShowDisconnectReason_NoReason = "PLY_NAME odłączony od serwera podczas posiedzenia",

		ReloadTip = "Przełąduj (R) aby rozpocząć posiedzenie",
		ReloadTipRemove = "Przeładuj (R) aby usunąć z posiedzenia",

		SitID = "Posiedzenie #%d",
		JoinSitLine = "Dołącz do posiedzenia",

		Refresh = "Odśwież",

		SitPosFailed = "Nie udało się ustawić pozycji posiedzenia! Upewnij się, że jesteś na świecie, a nie utknąłeś.",
		SitPosSuccess = "Pomyślni ustawiono miejsce posiedzenia!",

		NoActiveSits = "Brak aktywnych posiedzeń",

		--## Admin Prison ##--

		AdminPrison = "Więźienie administratorskie",
		AdminPrison_ChatCommand_NoMatches = "Nie udało się znaleźć gracza odpowiadającego tej nazwie, SteamID lub SteamID64!",
		AdminPrison_ChatCommand_OverQualified = "Znaleziono ARG_COUNT sprzeczne nazwy graczy: MATCH_FAILS - starać się być bardziej szczegółowym",
		AdminPrison_Prisoner = "Więźień",
		AdminPrison_ImprisonmentTime = "Czas uwięzienia",
		AdminPrison_Reason = "Powód",
		AdminPrison_Imprison = "Więzienie",
		AdminPrison_PlayerDisconnected = "Gracz rozłączył się, gdy miałeś zamiar ich uwięzić. :(",
		AdminPrison_ClickToFocus = "Kliknij, aby się skupić",
		AdminPrison_NoPermission = "Nie masz pozwolenia na używanie tego!",
		AdminPrison_SentToPrison_Success = "PLY_NAME został wysłany do więzienia za RELEASE_TIME",
		AdminPrison_ReleasedFromPrison = "Zostałeś zwolniony z więzienia!",

} end }