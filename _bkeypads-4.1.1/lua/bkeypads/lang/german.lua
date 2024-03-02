-- Contributors:
-- Aevoa (STEAM_0:0:80308585)

return {
	Name = "German",
	Flag = "flag16/de.png",
	Phrases = {
		-- 4.0.0
		Welcome = "Willkommen",
		TutorialWelcomeTip = "Willkommen zu Billy's Keypads!",
		TutorialPlacingKeypads = "Keypads platzieren ",
		TutorialPlacingKeypadsTip = "Lerne, wie du mit der Toolgun Keypads platzierst",
		TutorialWhatIsKeypad = "Was is ein Keypad?",
		TutorialKeypadAppearance = "Keypad Aussehen",
		TutorialKeypadAppearanceTip = "Das Aussehen deines Keypads anpassen",
		TutorialKeypadAccess = "Keypad Zugang",
		TutorialKeypadAccessTip = "Kontrolliere, wer Zugriff hat und wer keinen Zugriff auf dein Keypad hat",
		TutorialWhatIsFadingDoor = "Was ist eine Fading Door?",
		Linking = "Verknüpfung",
		TutorialLinkingKeypads = "Keypads Verknüpfen",
		TutorialLinkingKeypadsTip = "Keypads miteinander Verknüpfen um ein Netzwerk aus Zugangsregeln zu erstellen",
		TutorialLinkingFadingDoors = "Fading Doors Verknüpfen",
		TutorialLinkingFadingDoorsTip = "Keypads mit Fading Doors verknüpfen",
		TutorialLinkingMapObjects = "Map Objekte Verknüpfen",
		TutorialLinkingMapObjectsTip = "Keypads mit Map Objekten verknüpfen (Türen, Knöpfe, etc.)",
		TutorialKeypadTypes = "Keypad Typen", -- Types = types of keypad: FaceID, PIN, keycard, etc.
		KeycardScanner = "Karten Scanner",
		TutorialPINTip = "Keypads in welche du numerischer Codes eingibst (z.b. 0187)",
		TutorialKeycardScannerTip = "Keypads in welchen du eine Karte scannst",
		TutorialFaceIDTip = "Keypads welche dein Gesicht scannen",
		Language = "Sprache",
		TutorialLanguageMsg = "Du kannst die Sprache von Billy's Keypads ändern, indem du die Garry's Mod Sprache unten rechts änderst.\nFalls immernoch alles auf Englisch ist, ist Billy's Keypads noch nicht in diese Sprache übersetzt, Sorry!",
		TutorialSettingsMsg = "Du kannst deine Persönlichen Billy's Keypads einstellungen (Werden auf andere Server übertragen) unter Q > Optionen > Billy's Keypads ändern.\nWir haben es für dich geöffnet! Wenn du das Spawnmenü schließen möchtest, klicke auf den leeren Bereich außerhalb des Menüs.",
		TutorialConfiguringFadingDoors = "Fading Doors Konfigurieren",
		TutorialMapDoors = "Karten Türen",
		TutorialMapButtons = "Knöpfe",
		MapObjects = "Map Objekte",
		TutorialQuickStart = "Schnellstart / TL;DR",

		YouTubeTutorials = "YouTube Tutorials",
		YouTubeTutorialsTip = "Eine Kollektion von YouTube Tutorials erstellt von der Community",

		TutorialWhatIsFadingDoorCaption = "Fading Doors sind Props, welche Temporär transparent und passierbar werden, wenn geöffnet",
		TutorialWhatIsFadingDoorCaption2 = "Du kannst sie mithilfe des \"%tool.bkeypads_fading_door.name%\" Werkzeugs erstellen",
		TutorialWhatIsFadingDoorCaption3 = "Du kannst nicht stecken bleiben; Sie schließen nicht solange du in ihnen bist.",
		TutorialWhatIsFadingDoorCaption4 = "Sie schließen wenn du sie verlassen hast.",

		TutorialWhatIsKeypadCaption1 = "Keypads sind geräte, welche benutzt werden um den Zugang zu einer großen vielfalt an Systemen, Türen und Objekten zu sichern",
		TutorialWhatIsKeypadCaption2 = "Es gibt drei Arten von Keypads: FaceID, PIN und Karten leser",
		TutorialWhatIsKeypadCaption3 = "Hier ist ein Keypad in aktion!",

		TutorialKeypadAccessCaption1 = "Keypads sind in der Lage, sehr fortschrittliche Zugriffskonfigurationen, d.h. wer hat Zugriff, und wer nicht zu verwalten",
		TutorialKeypadAccessCaption2 = "Jedes Keypad hat eine Whitelist und eine Blacklist, konfiguriert von seinem Ersteller",
		TutorialKeypadAccessCaption3 = "Eine Vielzahl verschiedener Zugriffsgruppen können auf das Keypad in die Whitelist- oder Blacklist aufgenommen werden",
		TutorialKeypadAccessCaption4 = "Probier es aus!",

		TutorialLinkingFadingDoorsStep1 = "Als erstes, erstelle eine Fading Door (falls du das noch nicht hast)",
		TutorialLinkingFadingDoorsStep2 = "Als nächstes, benutze dein \"%tool.bkeypads_linker.name%\" Werkzeug und klicke auf das Keypad",
		TutorialLinkingFadingDoorsStep3 = "Danach, klicke einfach auf die Fading Door",
		TutorialLinkingFadingDoorsStep4 = "Testen wir es!",
		TutorialLinkingFadingDoorsStep5 = "Nice.",

		TutorialPaymentKeypads = "Zahlungs Keypads",
		TutorialPaymentKeypadsCaption1 = "Keypads können mit einer Zugangsgebühr eingerichtet werden",
		TutorialPaymentKeypadsCaption2 = "Das Keypad verhält sich wie ein normales Keypad für den Besitzer des Keypads",
		TutorialPaymentKeypadsCaption3 = "Aber, alle anderen müssen eine Gebühr für den Zugang bezahlen",
		TutorialPaymentKeypadsCaption4 = "Zahlungs Keypads können auch so konfiguriert werden, dass nur Personen belastet werden, die nicht auf der Whitelist stehen",

		TutorialEasy = "Leicht!",

		-- 3.3.1
		Setting_Dyslexia = "Dyslexie",
		Setting_DyslexiaTip = "Dyslexie Schriftart aktivieren",

		-- 3.3.0
		PermaProps = "Was machst du? Bruder das ist das falsche Werkzeug, um Tastaturen permanent zu machen!",
		PermaProps_AlreadySaved = "Dieses Entitie wurde bereits durch Billy's Keypads gespeichert. PermaProp wird nicht benötigt.",
		Nevermind = "Egal",
		MirrorPlacement = "Platzierung spiegeln", -- Mirror Placement will place the keypad on the opposite side of the prop too
		MirrorPlacementTip = "Spiegelt die Platzierung des Keypads.\nDas gespiegelte Keypad wird nicht bei dem Keypad limit gezählt.\nSie sind miteinander verschweißt, und das entfernen eines der beiden, entfernt das andere ebenfalls.\nSie werden automatisch miteinander verknüpft.",

		-- 3.2.0
		RainbowBackground = "Regenbogen Hintergrund",

		-- 3.1.0
		KeypadOnlyFadingDoors = "KEINE FADING DOOR",

		-- 3.0.2
		PaymentPrompt = "Dieses Keypad berechnet Ihnen %s für den Zugang.\nMöchtest Du fortfahren?",
		PaymentNamedPrompt = "\"%s\" berechnet Ihnen %s für den Zugang.\nMöchtest Du fortfahren?",
		PaymentPromptTitle = "Zahlung benötigt",

		-- 3.0.1
		CrackerNotLinked = "NICHT VERBUNDEN",

		-- 3.0.0
		CrackerWaiting = "WARTEN",
		CrackerTooFar = "ZU WEIT",
		CrackerReady = "BEREIT",
		CrackerCantCrack = "NICHT KNACKBAR",
		CrackSuccess = "ERFOLG",
		CrackFailed = "FEHLGESCHLAGEN",
		KeypadCracker = "Keypad Knacker",
		NoneProfileError = "Du kannst das Tool für dauerhafte Keypads nicht verwenden, während das \"none\" profil aktiv ist",
		NoneProfileToolscreen = "\"none\" profil ist aktiv",

		-- 2.4.0
		DoorLock = "Tür abschließen",
		DoorLockTip = "Schließt die Tür automatisch für dich",
		DisableMapObjTip = "Wenn aktiviert, wird das Karten Objekt deaktiviert; nichts wird damit mehr interagieren können (inklusive Rammbock, Lockpicks usw.) und es kann nur über das Keypad interagiert werden. \n\nTüren werden automatisch abgeschlossen bleiben.",
		Undo_bkeycard_pickup = "Rückgängig Machen: abgelegte Schlüsselkarte",
		Undone_bkeycard_pickup = "abgelegte Schlüsselkarte rückgangig gemacht",
		FlagName = "Flagge: %s",
		HelixFlag = "Helix Flagge", -- do not translate Helix
		Flag = "Flagge",

		-- 2.3.0
		KeypadImages = "Keypad Bilder",
		BanFromFeature = "Spieler von Feature bannen",
		UnbanFromFeature = "Spieler von Feature entbannen",
		BannedFromFeature = "Du bist von diesem Feature gebannt!",
		BannedFromFeatureAdmin = "Spieler erfolgreich von Feature GEBANNT",
		UnbannedFromFeatureAdmin = "Spieler erfolgreich von Feature ENTBANNT",
		FadingDoorKey = "Öffnen Taste", -- key on keyboard that opens fading door
		FadingDoorKeyTip = "Die Taste auf der Tastatur, die die Fading Door öffnet",
		FadingDoorLinkTip = "Du kannst Fading Doors mit dem Verbinder Werkzeug mit Keypads verbinden",
		UncrackableIncompatibilitiesTip = "HINWEIS: Einige Keypad Knacker sind möglicherweise nicht kompatibel und ignorieren dies",

		-- 2.2.0
		Access = "Zugang",
		AccessCharge = "Zugangsgebühr",
		AccessDenied = "Zugriff verweigert",
		AccessDeniedKey = "Zugriff verweigert Taste",
		AccessDeniedKeyTip = "Die Taste, welche gedrückt wird, wenn der Zugriff verweigert wird",
		AccessDeniedNotificationTip = "Benachrichtigungen erhalten, wenn der Zugriff von jemandem über dieses Keypad VERWEIGERT wird?",
		AccessGranted = "Zugriff gewährt",
		AccessGrantedKey = "Zugriff gewährt Taste",
		AccessGrantedKeyTip = "Die Taste, welche gedrückt wird, wenn der Zugriff gewährt wird",
		AccessGrantedNotificationTip = "Benachrichtigungen erhalten, wenn der Zugriff von jemandem über dieses Keypad GEWÄHRT wird?",
		AccessLogs = "Zugriff Logs",
		AccessLogsTitle = "Keypad Zugriff Logs",
		AccessLogsWarrant = "Du benötigst einen Haftbefehl, um die Zugriff Logs dieses Keypads ansehen zu können.",
		AccessTable = "Zugriffstabelle",
		ActiveSound = "Aktivierungs Sound",
		AddGroup = "%s hinzufügen",
		Added = "Hinzugefügt",
		AdminMenu = "Admin Menü",
		AdminTool = "Admin Werkzeug",
		All = "Alle",
		AllSuperiorKeycards = "Alle überlegenen Schlüsselkarten",
		Appearance = "Aussehen",
		AreYouSureDeleteImage = "Bist du dir sicher, dass du dieses Bild löschen möchtest?",
		AuthMode = "Authentifizierungsmodus",
		AutoFadingDoor = "Auto Fading Door", -- Doesn't make sense when translated to german, German translation would be "Verblassende Tür" tho (If you decide to change it, you have to change Line 30 aswell)
		AutoFadingDoorTip = "Erstellt und verlinkt die Fading Door automatisch, wenn du ein Keypad für ein Prop erstellst, welches du gerade anguckst",
		BackgroundColor = "Hintergrundfarbe",
		Behaviour = "Verhalten",
		Blacklist = "Blacklist", -- Doesn't make sense when translated to german, German translation would be "Schwarze Liste" tho (If you decide to change it, you have to change Line 33 aswell)
		BlacklistTip = "Wem sollte der Zugang verweigert werden? \nDie Blacklist hat Vorrang vor der Whitelist.",
		Blacklisted = "Blacklisted", -- Litterally no fitting German word for this existing
		Broken = "Kaputt",
		Buttons = "Tasten",
		CanKeypadCrack = "Kann geknackt werden",
		Cancel = "Abbrechen",
		Charge = "Gebühr",
		ChargeUnauthorized = "Nur nicht autorisierte Spieler müssen die Gebühr bezahlen",
		ChargeUnauthorizedTip = "Sollen nur nicht autorisierte Benutzer (auf der Blacklist / Whitelist) für den Zugang eine Gebühr bezahlen, \noder soll jeder für den Zugang bezahlen müssen?",
		CheckingURL = "Überprüfe URL... bitte warten",
		Cleaned__bkeypads_fading_doors = "Fading Doors aufgeräumt (bKeypads)",
		Cleaned_bKeypads = "Keypads aufgeräumt",
		Cleanup__bkeypads_fading_doors = "Fading Doors (bKeypads)",
		Clear = "Bereinigen", -- Ask Billy about this one
		ClearAccessMatrixConfirm = "Bist du dir sicher, dass du die Zugriffstabelle löschen möchtest?",
		CloseSound = "Schließen Sound",
		Configuration = "Konfiguration",
		CopiedExclamation = "Kopiert!",
		CopyName = "Namen kopieren",
		CopySteamID = "SteamID kopieren",
		CopySteamID64 = "SteamID64 kopieren",
		CopyValue = "Wert kopieren",
		CustomEllipsis = "Benutzerdefiniert...",
		DBinderTip = "Rechtsklick um die Zugriff gewährt/verweigert Taste zu löschen",
		Delay = "Verzögerung",
		Delete = "Löschen",
		DeleteImage = "Bild löschen",
		DeleteSaveConfirm = "Bist du dir sicher, dass du den Save \"%s\" löschen möchtest?",
		Denied = "Verweigert",
		Destructible = "Zerstörbar",
		Destruction = "Zerstörung",
		DisableMapObj = "Map Objekte Deaktivieren",
		Dismiss = "Schließen",
		DomainNotWhitelisted = "Diese Domain ist nicht auf der Whitelist!",
		Done = "Fertig",
		Doors = "Türen",
		DroppedKeycardHideToHolders = "Vor besitzern verstecken",
		DroppedKeycardHideToHoldersTip = "Wenn diese Option aktiviert ist, können Spieler, die diese Karte aufsammeln, sie später nicht ehr auf dem Boden sehen.\n\nACHTUNG: Aufgrund eines Gmod Bugs ist es derzeit nicht möglich, die Schlüsselkarten auszublenden und zu verhindern, dass Spieler mit ihnen kollidieren, was manche Spieler verwirren könnte.",
		DroppedKeycardLevel = "Stufe(n)",
		DroppedKeycardPersistenceTip = "Wenn diese Option aktiviert ist, werden neue Karten gespawnt, wenn die Map geladen wird.\n\nRechtsklick auf eine Karte mit dem Billy's Keypads Persistence Werkzeug (im Spawn Menü > Admin Reiter > Persistence) um die Karte von der Map zu entfernen. \n\nDu kannst die Schlüsselkarte auch mit der Physgun bewegen um sie an dem gewünschten Ort zu platzieren und zu speichern.",
		DroppedKeycardPhysics = "Physik aktivieren",
		DroppedKeycardPhysicsTip = "Wenn diese Option aktiviert ist, kann die Karte verschoben werden.\n\nWenn die Schlüsselkarte permanent ist, wird die Position der Karte nicht gespeichert nach dem Herunterfahren oder bewegen mit der Physgun.",
		DroppedKeycardPlayerModel = "Spielermodell",
		DroppedKeycardQuantity = "Menge",
		DroppedKeycardQuantityInfinite = "Unendlich",
		DroppedKeycardTouchToPickup = "Berühren Zum Aufsammeln",
		DroppedKeycardTouchToPickupTip = "Wenn diese Option aktiviert ist, können die Spieler über die Schlüsselkarte gehen / sie berühren, um sie aufzuheben oder E darauf drücken.",
		Enable = "Aktivieren",
		EnterUsergroup = "Gib den Namen der Benutzergruppe ein",
		Error = "Fehler",
		FaceID = "FaceID",
		FaceIDTip = "Benutze Gesichtserkennung zur Authentifizierung",
		FadingDoorCreated = "Fading door erstellt!",
		FadingDoorHelp = "Das Fading Door Werkzeug erlaubt es dir, fast jedes Prop in eine Tür zu verwandeln!\n\nFading Doors können mit hilfe des Verbinder Werkzeugs mit einem Keypad verbunden werden, welches den Zugang zu deiner Base, Kreationen und Wergegenständen kontrolliert.",
		FadingDoorRemoved = "Fading door entfernt!",
		FadingDoorSettingsCopied = "Fading door Einstellungen kopiert!",
		FadingDoorUpdated = "Fading door aktualisiert!",
		Finished = "Abgeschloßen",
		Freeze = "Einfrieren",
		FreezeTip = "Gibt an, ob die Tastatur beim Spawnen eingefroren werden soll",
		Friends = "Freunde",
		General = "Allgemein",
		Granted = "Gewährt",
		GroupAgendaGroup = "Agenda-Gruppe",
		GroupCustomLuaFunction = "Benutzerdefinierte Lua-Funktion",
		GroupCustomTeamGroup = "Benutzerdefinierte Teamgruppe",
		GroupDemoteGroup = "Herabstufungsgruppe",
		GroupDoorGroup = "Tür Gruppe",
		GroupJobCategory = "Job Kategorie",
		GroupKeycardLevel = "Keycard Stufe",
		GroupMe = "Ich",
		Hacked = "Gehackt",
		HealthAdded = "+%d HP",
		Help = "Hilfe",
		HideMapObj = "Verstecken",
		HideMapObjTip = "Dies verhindert, dass die Schaltfläche in der Welt gerendert wird.\n\nDies funktioniert bei einigen Schaltflächen aufgrund der Karte möglicherweise nicht; umleitung +use kann in diesem Fall angemessener sein.",
		HoldLength = "Länge halten:",
		HoldLengthTip = "Wie lange sollte das Keypad in Sekunden ein Signal ausgeben?",
		Idle = "Inaktiv",
		ImageAlreadyExists = "Du hast dieses Bild bereits hinzugefügt (\"%s\")",
		ImageName = "Bild name...",
		ImageURL = "Bild URL",
		Indestructible = "Unzerstörbar",
		InitialDelay = "Anfängliche Verzögerung:",
		InitialDelayTip = "Wie lange sollte das Keypad in Sekunden warten, bevor ein Signal ausgegeben wird?",
		InvalidImage = "Ungültiges Bild:\n",
		InvalidURL = "Das war eine ungültige URL. Beispiel:\n\nhttps://i.imgur.com/9j3U3SY.jpg\nhttps://i.imgur.com/auA1H2y.jpg",
		Job = "Job",
		Jobs = "Jobs",
		JobsSelector = "Job(s) Wähler",
		Key = "Taste",
		Keycard = "Schlüsselkarte",
		KeycardDrop = "Fallenlassen",
		KeycardInstructions = "Linksklick auf einen Schlüsselkartenscanner, um deine Schlüsselkarte einzufügen\n\nRechtsklick um dich zu identifizieren\n\nR/NACHLADEN um das Schlüsselkarten Inventar zu öffnen",
		KeycardLevel = "Stufe %d",
		KeycardLevels = "Stufen",
		KeycardSwitch = "Wechseln",
		KeycardTip = "Verwende zur Authentifizierung eine Schlüsselkarten",
		KeypadAccessMatrixCopied = "Keypad Zugriffstabelle kopiert!",
		KeypadAccessMatrixCopyError = "Beim Kopieren der Zugriffstabelle dieses Keypads ist ein Fehler aufgetreten - sorry!",
		KeypadAccessMatrixCopying = "Keypad Zugriffstabelle wird runtergeladen...",
		KeypadAccessTip2 = "Rechtsklick auf eine Zeile um sie zu entfernen",
		KeypadBattery = "Keypad Batterie",
		KeypadBroken = "Keypad kapput!",
		KeypadHackedAdminHidden = "[KLICKE ZUM ZEIGEN]",
		KeypadMethod = "Methode",
		KeypadNameTip = "Gib deinem Keypad einen freundlichen Namen.\nDieser wird in Benachrichtigungen angezeigt und kann Team Mitgliedern beim Identifizieren in den Logs helfen.",
		KeypadOnlyFadingDoor = "Diese Fading Door kann nur über ein Keypad geöffnet und geschlossen werden!",
		KeypadRepaired = "Keypad repariert!",
		KeypadShield = "Keypad Schild",
		LastSaved = "Zuletzt gespeichert: %s",
		LastUpdated = "Zuletzt aktualisiert",
		LinkTypeButton = "KARTEN KNOPF VERKNÜPFUNG",
		LinkTypeDoor = "KARTEN TÜR VERKNÜPFUNG",
		LinkTypeFadingDoor = "FADING DOOR VERKNÜPFUNG",
		LinkTypeKeypad = "KEYPAD VERKNÜPFUNG",
		LinkTypeMap = "KARTEN OBJEKT VERKNÜPFUNG",
		LinkedSuccessfully = "Erfolgreich verknüpft!",
		LinkerHelp = "Das Verbinder Werkzeug erlaubt es dir, eine verknüpfung zwischen Fading Doors, Karten Türen, Karten Knöpfen und einem Keypad herzustellen.\n\nMit dem Verbinder Werkzeug, kannst du sogar zwei Keypads miteinander verbinden, das heißt, das sie die Selbe Zugriffskonfiguration miteinander teilen!",
		LoadSave = "Speicherstand Laden",
		LoadSaveFailed = "Fehler beim Laden dieses Speicherstands! Es kann beschädigt sein, zu alt, oder ein Fehler aufgetreten.",
		LoadSaveWarning = "Bist du sicher, dass du diesen Speicherstand laden möchten? \"%s\"?\nUngespeicherte einstellungen werden verloren gehen.",
		LoadingEllipsis = "Lädt...",
		LogoImage = "Logo/Bild",
		ManualSteamID = "SteamID/SteamID64/Steam Profil Link",
		ManualSteamIDError = "Die von Ihnen eingegebene SteamID, SteamID64 oder Steam Profil Link konnten nicht erkannt werden.\nBeispiel:\n\nSteamID: %s\nSteamID64: %s\nSteam Profil Link: %s\nSteam Profil Link: %s",
		ManualSteamIDNetworkError = "Es gab einen Netzwerkfehler, der uns daran hinderte, diese Steam-Profilverbindung zu analysieren.\nBitte versuche es später erneut oder gib eine SteamID/SteamID64 manuell ein.",
		ManualSteamIDProfileError = "Aus diesem Steam-Profillink konnte keine SteamID extrahiert werden. Bitte überprüfen Sie den Link und versuchen Sie es erneut.",
		ManualSteamIDProfileNotFound = "Es gibt keinen Steam-Benutzer mit diesem Profillink!\nBitte versuche es später erneut oder gib eine SteamID/SteamID64 manuell ein.",
		MapDoorToggleTip = "Dadurch wird die Tür geöffnet oder geschlossen, aber nicht umgekehrt, wenn das Keypad die Ausgabe beendet hat.",
		MapDoubleToggle = "Doppel Umschalten",
		MapDoubleToggleTip = "Dadurch wird die Taste zweimal umgeschaltet (DRÜCK .. DRÜCK).",
		MapHold = "Halten",
		MapHoldTip = "Dadurch wird die Taste gedrückt gehalten, bis das Keypad die \"Halte Länge\" erreicht hat (DRÜCK .. WARTE .. LOSLASSEN)",
		MapLinking = "Karten Verknüpfung",
		MapPreventLockpick = "Entsperren verhindern",
		MapPreventLockpickTip = "Bei DarkRP verhindert dies, dass die Tür geknackt werden kann.",
		MapRedirectUse = "+use an das Keypad weiterleiten",
		MapRedirectUseTip = "Dies führt dazu, dass jeder Spieler, der versucht, das Kartenobjekt zu verwenden, +use auf das Keypad umleitet.",
		MapToggle = "Umschalten",
		MapToggleTip = "Dadurch wird die Schaltfläche einmal umgeschaltet (DRÜCK) anstelle des Standarts (DRÜCK .. LOSLASSEN).",
		MaxHealth = "Max HP",
		Mode = "Modus",
		Name = "Name",
		Nearby = "In der Nähe",
		NewImage = "+ Neu",
		NewImageSubtitle = "Geben Sie die URL des Bildes ein.\n\n* Muss auf einer Gewhitelisten Domain gehostet werden\n* Empfohlene Abmessungen: 256x256\n* Muss ein JPEG oder PNG sein\n* Maximale Größe: 2 MB",
		NewImageTitle = "Neues Bild",
		No = "Nein",
		NoCollide = "Keine Kollision",
		NoCollideTip = "Ob das Keypad mit Spielern und Entities kollidieren soll oder nicht - keine Sorge, es fällt nicht aus der Welt",
		NoData = "Keine Daten",
		None = "Keine",
		NotPersistent = "Nicht Permanent",
		Notification_Access = "Zugriff war %s auf %s",
		Notification_Access_Named = "Zugriff war %s auf %s für Keypad %s",
		Notification_DENIED = "VERWEIGERT",
		Notification_GRANTED = "GEWÄHRT",
		Notification_PaymentCantAfford = "Du kannst dir die %s Gebühr für den Zugang auf dieses Keypad nicht leisten!",
		Notification_PaymentCantAfford_Named = "Sie können sich die %s Gebühr für den Zugriff auf %s! nicht leisten.",
		Notification_PaymentReceived = "Du hast %s von %s für den Keypad Zugang erhalten!",
		Notification_PaymentReceived_Named = "Du hast %s von %s für den Zugang auf %s erhalten!",
		Notification_PaymentTaken = "Du hast %s bezahlt, um auf dieses Keypad zuzugreifen!",
		Notification_PaymentTaken_Named = "Du hast %s bezahlt, um auf %s zuzugreifen!",
		Notifications = "Benachrichtigungen",
		Offline = "Offline",
		Online = "Online",
		OpenSound = "Sound öffnen",
		Optimizing = "Optimiere: %s",
		OwnedBy = "Im Besitz von",
		PIN = "PIN",
		PINTip = "1- bis 6-stellige PINs zur Authentifizierung verwenden\nTIPP: Du kannst mit deinem Numpad PINs auf Keypads eingeben!",
		Payment = "Zahlung",
		PaymentAboveMaximum = "Der Maximal zu zahlende Betrag beträgt %s",
		PaymentBelowMinimum = "Der Mindestbetrag, den Sie berechnen können, ist %s",
		PaymentEntry = "Geben Sie ein, wie viel du den Spielern für den Zugang berechnen möchtest.\nSie werden gewarnt, bevor sie belastet werden.",
		PaymentMaximum = "Maximal: %s",
		PaymentMinimum = "Minimum: %s",
		Persistence = "Permanent",
		PersistenceHelp = "Mit diesem Tool kannst Du Permanente Keypads erstellen - Keypads, die nach einem Neustart des Servers bestehen bleiben.\n\nDas Werkzeug hat auch eine leistungsstarke Funktion namens Profile. Dadurch können Sie separate Permanente Tastaturbelegungskonfigurationen auf derselben Karte erstellen und zwischen diesen im Handumdrehen wechseln.\n\nHINWEIS: Wenn Du Änderungen an einer Permanenten Tastatur vorgenommen haben, wie z. B. das Verschieben der Position oder des Winkels, musst du die NACHLADEN-Taste drücken, um die Änderungen zu speichern.",
		Persistent = "Permanent",
		PersistentKeycardSave = "Permanente Fallengelassene Schlüsselkarte gespeichert!",
		Player = "Spieler",
		Players = "Spieler",
		PlayersSelector = "Spieler-Auswahl",
		Preview = "Vorschau",
		Profile = "Profil",
		ProfileSwitchedChat = "Dauerhaftes Profil umgeschaltet auf \"%s\"",
		Profiles = "Profile",
		Properties = "Eigenschaften",
		PseudoMapLink = "Pseudolink",
		PseudoMapLinkTip = "Wenn diese Option aktiviert ist, bewirkt die verknüpfte Zehnertastatur nichts für das Kartenobjekt, wenn der Zugriff gewährt/verweigert wird. So kannst du einfach die Entsperrung deaktivieren, +redirect, Tasten und Türen deaktivieren oder ausblenden, ohne dass die Tastatur sie beeinflusst.",
		Recent = "Zuletzt",
		Refresh = "Aktualisieren",
		Remove = "Entfernen",
		RepeatDelay = "Wiederholungs Verzögerung:",
		RepeatDelayTip = "Wie lange sollte das Keypad in Sekunden warten, bis die Ausgabe wiederholt wird?",
		Repeats = "Wiederholungen:",
		RepeatsTip = "Wie oft sollte die Tastatur die Ausgabe wiederholen?",
		Reset = "zurücksetzen",
		ResetAllData = "Alle Billy-Keypads Daten zurücksetzen",
		ResetAllDataAreYouSure = "Bist du dir sicher, dass du alle Billy's Keypads Daten zurücksetzen möchtest?\nDies kann verwendet werden, um Fehler zu beheben, wenn deine lokalen Dateien beschädigt wurden.\nDies wird alle Ihre Einstellungen zurücksetzen, gespeicherte Tastaturen, Caches usw. und Billy's Keypads zurück in einen sauberen Zustand setzen.\n\nWenn du nur auf diesem Server fehler auftreten, könnte Billy's Keyapds outdated sein. Frage den Server Besitzer ob er das Script up to date gehalten hat!",
		ResetSettings = "Einstellungen zurücksetzen",
		ResetSettingsAreYouSure = "Bist du dir sicher, dass du die Einstellungen zurücksetzen möchten?\nDas Spawn menü wird neu geladen.",
		Reversed = "Umgekehrt",
		SBoxLimit__bkeypads_fading_doors = "Du hast die Grenze für Fading Doors (bKeypads) erreicht!",
		SBoxLimit_bKeypads = "Dz hast die Grenze für Keypads (bKeypads) erreicht!",
		Save = "Speichern",
		SaveKeypad = "Keypad Speichern",
		SaveKeypadAlreadyExists = "Diese Datei ist bereits vorhanden. Möchtest du sie überschreiben?\nDie Datei wurde zuletzt am %s geändert.",
		SaveKeypadFileName = "Gespeichertes Keypad Dateiname:",
		SaveLoadTip = "Du kannst Konfigurationen hier speichern und laden!",
		SavePersistentKeypads = "Permanente Keypads speichern",
		SavedKeypads = "Keypads Gespeichert",
		Scanning = "Scannen",
		ScanningStatus = "Scanstatus",
		Search = "Suchen",
		SearchEllipsis = "Suchen...",
		SetLogoImage = "Logo/Bild festlegen",
		SetPayment = "Zahlung festlegen",
		SetPaymentTip = "Personen für den Zugriff auf diese Keypad belasten",
		Setting_3D2DDistance = "3D2D-Renderabstand",
		Setting_3D2DDistanceTip = "In welcher Entfernung sollte die 3D2D-GUI verschwinden? (z. B. Tastaturbildschirme, Tastaturabziehbilder, Schlüsselkartenidentifizierung usw.))",
		Setting_AutoThreshold = "Automatisch FPS-Schwellenwert",
		Setting_AutoThresholdTip = "Bei wievielen FPS sollte die automatische Optimierung beginnen?",
		Setting_CustomImages = "Benutzerdefinierte Bilder",
		Setting_CustomImagesTip = "Wenn du keine benutzerdefinierten Bilder auf den Keypads sehen möchten, kannst du sie hier deaktivieren. Du kannst weiterhin deine eigenen benutzerdefinierten Bilder sehen.",
		Setting_CustomImages_Imgur = "Nur Imgur",
		Setting_CustomImages_ImgurTip = "Benutzerdefinierte Bilder können verwendet werden, um deine IP-Adresse zu identifizieren. Es ist sehr schwierig, eine IP-Adresse mit jedem Player auf dem Server zu verknüpfen, aber wenn du dich um deine Sicherheit sorgst, kannst du benutzerdefinierte Bilder auf Imgur.com beschränken.\n\nHINWEIS: Imgur ist standardmäßig die einzige Quelle für benutzerdefinierte Bilder mit Whitelist, kann jedoch vom Serverbesitzer geändert werden (der deine IP-Adresse bereits kennt)",
		Setting_DrawKeypadProperties = "Eigenschaften der Zehnertastatur",
		Setting_DrawKeypadPropertiesTip = "Zeichnet die Eigenschaften der Zehnertastatur unter den Zehnertastaturen, die du gerade platzierst.",
		Setting_KeycardTextures = "Dynamische Tastaturtexte deaktivieren",
		Setting_KeycardTexturesTip = "Dynamische Schlüsselkarten-Texturen sind im Allgemeinen sehr gut optimiert, aber Low-End-PCs oder FPS-Entleerungsserver können Probleme haben.",
		Setting_NotificationsMax = "Maximale Benachrichtigungen",
		Setting_NotificationsMaxTip = "Die maximale Anzahl von Benachrichtigungen, die angezeigt werden können, bevor alte Benachrichtigungen verworfen werden.",
		Setting_NotificationsTextSize = "Textgröße",
		Setting_NotificationsTime = "Benachrichtigungszeit",
		Setting_NotificationsTimeTip = "Wie lange sollten Benachrichtigungen angezeigt werden, bevor sie verschwinden?",
		Setting_Optimizations = "Optimierungen",
		Setting_OptimizationsTip = "Billy's Keypads führt Leistungsoptimierungen basierend auf den FPS deines Spiels durch.\n\nAuto: Verfolgt Ihre FPS und führt sofort Optimierungen durch\nKeine: Es werden keine Optimierungen vorgenommen\nKartoffel: Alle Optimierungen sind erzwungen",
		Setting_Optimizations_Auto = "Auto",
		Setting_Optimizations_Potato = "Kartoffel",
		Setting_Other = "Sonstige",
		Setting_TooltipSize = "Textgröße der QuickInfo",
		Settings = "Einstellungen",
		Shield = "Schild",
		ShieldAdded = "+%d Schild",
		Size = "Größe",
		Slant = "Slant Keypad",
		SlantTip = "Gibt den (zufälligen) Effekt dass das keypad gerade noch an der Wand hängt",
		Slanted = "Schräg",
		Sounds = "Sounds",
		Spawn = "Spawnen",
		SpawnDroppedKeycard = "Fallengelassene Schlüsselkarte spawnen",
		SteamFriends = "Steam Freunde",
		SteamIDFinder = "SteamID-Finder",
		Switch = "Umschalten",
		Team = "Team",
		Teams = "Teams",
		Time = "Zeit",
		ToggleActive = "Aktiv umschalten",
		ToolHelp1 = "Mit den Keypads kannst du den Zugriff auf Türen, Fading Doors, Wiremod-Komponenten und mehr steuern.",
		ToolHelp2 = "Du kannst Spielern Zugriff auf Tastaturen durch Keycards und Gesichtserkennung geben, durch eingabe der SteamID, Benutzergruppe, Job / Team eines Freundes.",
		ToolHelp3 = "Durch benutzerdefinierte Lua-Funktionen können die Serverentwickler weitere Funktionen hinzufügen, z. B. Level, Gangs/Partys usw..",
		ToolHelp4 = "Allerdings können Ihre Tastaturen von Keypad crackern geknackt werden; achte auf Signaltöne!",
		ToolScreenNoPermission = "Du hast keine Erlaubnis, das zu benutzen!",
		ToolScreenNoPermissionEnt = "Sie haben keine Berechtigung für dieses Entitie!",
		Tutorial = "Tutorial",
		Type = "Typ",
		Uncrackable = "Unknackbar",
		UncrackableTip = "Gibt an, ob die Tastatur von einem Keypad Knacker geknackt werden kann",
		Undo_bKeypad = "Keypad",
		Undo_bKeypads_Button_Link = "Knopf Verknüpfung (bKeypads)",
		Undo_bKeypads_Door_Link = "Tür Verknüpfung (bKeypads)",
		Undo_bKeypads_FadingDoor = "Fading Door (bKeypads)",
		Undo_bKeypads_FadingDoor_Link = "Fading Door verknüpfung (bKeypads)",
		Undo_bKeypads_Keypad_Link = "Keypad Verknüpfung (bKeypads)",
		Undo_bKeypads_Map_Link = "Verknüpfung zuordnen (bKeypads)",
		Undone_bKeypad = "Rückgängig-Taste",
		Undone_bKeypads_Button_Link = "Rückgängig: Knopf Verknüpfung (bKeypads)",
		Undone_bKeypads_Door_Link = "Rückgängig: Tür Verknüpfung (bKeypads)",
		Undone_bKeypads_FadingDoor = "Rückgängig: Fading Door (bKeypads)",
		Undone_bKeypads_FadingDoor_Link = "Rückgängig: Fading Door Verknüpfung (bKeypads)",
		Undone_bKeypads_Keypad_Link = "Rückgängig: Keypad Verknüpfung (bKeypads)",
		Undone_bKeypads_Map_Link = "Rückgängig: Karten Verknüpfung (bKeypads)",
		Unknown = "Unbekannt",
		UnlinkedSuccessfully = "Verknüpfung erfolgreich aufgehoben!",
		Unnamed = "(Unbenannt)",
		Usergroup = "Benutzergruppe",
		Value = "Wert",
		ViewProfile = "Profil anzeigen",
		Weld = "Weld",
		WeldTip = "Legt fest, ob die Tastatur beim Spawnen verschweißt werden soll",
		When = "Wann",
		Whitelist = "Whitelist",
		WhitelistTip = "Wem sollte der Zugang gewährt werden?",
		Whitelisted = "Whitelisted",
		WhitelistedDomains = "Whitelisted Domains",
		WhitelistedDomainsTip = "Dieser Server lässt nur die folgenden Bild-URL-Domains zu:",
		Who = "Wer",
		WiremodTip = "Gibt an, ob Wiremode Ein- und Ausgänge auf dieser Tastatur aktiviert werden sollen oder nicht",
		Yes = "Ja",
		s_hour = "Vor %d Stunde",
		s_hours = "Vor %d Stunden",
		s_minute = "Vor %d Minute",
		s_minutes = "Vor %d Minuten",
		s_second = "Vor %d Sekunde",
		s_seconds = "Vor %d Sekunden",
		["tool.bkeypads.copy"] = "Zugriffstabelle Kopieren",
		["tool.bkeypads.create_update"] = "Keypad Erstellen/Aktualisieren",
		["tool.bkeypads.desc"] = "Erstellt Keypads für den sicheren Zugriff auf Türen, Fading Doors usw.",
		["tool.bkeypads.name"] = "Billy's Keypads",
		["tool.bkeypads.switch_linker"] = "Wechsel zum Verbinder Werkzeug",
		["tool.bkeypads_admin_tool.desc"] = "Zeige Keypad Verknüpfungen, Zugriffstabellen, Eigenschaften und Zugriffsprotokoll an",
		["tool.bkeypads_admin_tool.focus"] = "Auf Tastatur konzentrieren",
		["tool.bkeypads_admin_tool.help"] = "Das Admin-Tool kann verwendet werden, um eine Vielzahl von Informationen über ein Keypad anzuzeigen.\n\nSehen Sie sich eine Tastatur an, um ihre Eigenschaften anzuzeigen.\n\nLinksklick um auf das Keypad zu fokusieren\nRechtsklick um den Fokus auf das Keypad aufheben.\n\nDrück NACHLADEN um das Admin Menü zu öffnen (Eigenschaften, Zugriffsprotokoll, Zugriffstabelle)",
		["tool.bkeypads_admin_tool.menu"] = "Öffne das Admin Menü",
		["tool.bkeypads_admin_tool.name"] = "Admin Werkzeug",
		["tool.bkeypads_admin_tool.unfocus"] = "Fokus aufheben",
		["tool.bkeypads_breaker.break_keypad"] = "Keypad zerstören",
		["tool.bkeypads_breaker.desc"] = "\"Zerstört\" Keypads für einen Kinoeffekt",
		["tool.bkeypads_breaker.help"] = "\"Zerstört\" Keypads für einen Kinoeffekt. Zerstörte Keypads können nicht verwendet werden und lassen alle Verknüpften Karten Entities, Türen, Fading Doors und Tasten geöffnet und aufgeschlossen halten.\n\nDies ist perfekt für Server Events, bei welchen ein Gehacktes oder Kapputes Sicherheitssystem Simuliert werden soll.",
		["tool.bkeypads_breaker.name"] = "Keypad Zerstörer",
		["tool.bkeypads_breaker.repair_keypad"] = "Keypad reparieren",
		["tool.bkeypads_fading_door.copy"] = "Einstellungen kopieren",
		["tool.bkeypads_fading_door.desc"] = "Macht alles zu einer Fading Door",
		["tool.bkeypads_fading_door.door"] = "Erstellt/Aktualisiert Fading Door",
		["tool.bkeypads_fading_door.info1"] = "Mit Fading Doors kannst du jedes Prop in eine Tür, durch welche Spieler durch gehen können verwandeln",
		["tool.bkeypads_fading_door.info2"] = "Die Fading Door kann nur durch ein Keypad geöffnet und geschlossen werden",
		["tool.bkeypads_fading_door.info3"] = "Verwende das Verbinder Werkzeug, um die Fading Door mit einem Keypad zu verbinden",
		["tool.bkeypads_fading_door.name"] = "Fading Doors",
		["tool.bkeypads_fading_door.remove"] = "Fading Door entfernen",
		["tool.bkeypads_linker.Finished"] = "Fertig",
		["tool.bkeypads_linker.desc"] = "Verknüpft Keypads mit Fading Doors, Kartenobjekten und anderen Tastaturen",
		["tool.bkeypads_linker.link_all"] = "Verknüpfung zu Tastatur/Fading Door/Kartenobjekt",
		["tool.bkeypads_linker.link_fading_door"] = "Mit Fading Door Verknüpfen",
		["tool.bkeypads_linker.link_keypad"] = "Mit Keypad Verknüpfen",
		["tool.bkeypads_linker.link_map_obj"] = "Mit Kartenobjekt Verknüpfen",
		["tool.bkeypads_linker.link_map_obj_info"] = "Vergiss nicht, in den Werkzeugeinstellungen Map-Objekt-Verbindungen nach deinen Wünschen zu konfigurieren!",
		["tool.bkeypads_linker.name"] = "Verbinder",
		["tool.bkeypads_linker.on_access_denied"] = "Bei Zugriff verweigert...",
		["tool.bkeypads_linker.on_access_granted"] = "Bei Zugriff gewährt...",
		["tool.bkeypads_linker.select"] = "Keypad auswählen",
		["tool.bkeypads_linker.switch_access"] = "Zugriffsmodus wechseln",
		["tool.bkeypads_linker.switch_keypads"] = "Zu Keypad Werkzeug wechseln",
		["tool.bkeypads_linker.unlink_fading_door"] = "Fading Door Verknüpfung aufheben",
		["tool.bkeypads_linker.unlink_keypad"] = "Keypad Verknüpfung aufheben",
		["tool.bkeypads_linker.unlink_map_obj"] = "Map Objekt Verknüpfung aufheben",
		["tool.bkeypads_persistence.delete"] = "Permanente Keypads löschen",
		["tool.bkeypads_persistence.desc"] = "Ermöglicht das Erstellen von Tastaturen, die nach dem Neustart des Servers erhalten bleiben",
		["tool.bkeypads_persistence.make_persistent"] = "Permanent machen",
		["tool.bkeypads_persistence.name"] = "Permanent",
		["tool.bkeypads_persistence.notification.created"] = "Permanentes Keypad für Profil \"%s\" erstellt",
		["tool.bkeypads_persistence.notification.deleted"] = "Permanentes Keypad für Profil \"%s\" gelöscht",
		["tool.bkeypads_persistence.notification.updated"] = "Permanente Keypads für Profil \"%s\" gespeichert",
		["tool.bkeypads_persistence.update"] = "Permanente Keypads aktualisieren",
	}
}