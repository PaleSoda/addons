return {
	Name = "French",
	Flag = "flags16/fr.png",
	Phrases = function() return {

		module_name = "Admin Sits",

		NotAllowedInSit = "Tu ne peux pas faire ça pendant un sit!",
		PlayerMayBeStuck = "PLY_NAME ont été téléportés, mais ils sont coincés !",
		DisconnectedPlayerReconnected = "PLY_NAME PLY_STEAMID du sit SIT_ID s'est reconnecté !",
		NoSitPosition = "Il n'y a pas de position sit définie pour cette carte ! Tapez !sitpos pour définir une position.",

		AdminSit = "Admin Sit",
		Unknown = "Inconnu",
		Dismiss = "Rejeter",
		Error = "Erreur",
		Yes = "Oui",
		No = "Non",

		Hours = "%s heures",
		Never = "Jamais",
		VACBans = "VAC Bans: %s",
		LastBan = "Jours depuis le dernier bannissement: %s",
		GameBans = "Bannissement en jeu: %s",
		TradeBanned = "Interdiction d'échanges: %s",
		MemberSince = "Membre depuis: %s",
		CheckPocketNone = "Aucun objet dans la poche",
		NoSteamAPIKey = "Le propriétaire du serveur n'a pas défini sa clé Steam API, cette fonctionnalité n'est donc pas disponible. :(\nPVeuillez demander au propriétaire/développeur du serveur de configurer gmodadminsuite_steam_apikey.lua dans la configuration de leur addon GmodAdminSuite.",
		CheckSteamFamilySharing_Error = "Une erreur s'est produite en essayant de récupérer les données des serveurs Steam. Ils sont peut-être indisponibles.\nVeuillez vous assurer que le propriétaire du serveur a défini la bonne clé API de steam dans le fichier gmodadminsuite_steam_apikey.lua du module de configuration GmodAdminSuite.",
		CheckSteamFamilySharingYes = "%s est en partage familiale pour Garry's Mod avec %s.",
		CheckSteamFamilySharingNo = "%s n'est pas en partage familiale pour Garry's Mod.",

		SteamFriendStatusYes = "%s est amis avec %s sur Steam!",
		SteamFriendStatusNo = "%s n'est pas amis avec %s sur Steam!",
		PlayerOfflineError = "Le joueur cible doit être sur le serveur pour effectuer cette action.",

		SteamProfile_Failure = "Impossible de récupérer le profil Steam ! (%s)\nVérifiez l'état des serveurs steam ou de votre connexion réseau.",
		SteamProfile_CheckGmodPlaytime_Failed = "Impossible de récupérer le temps de jeux sur gmod à partir du profil Steam.\nIl se peut que l'utilisateur n'ait pas configuré son profil de communauté ou que ses paramètres de confidentialité soient configurés pour masquer ces données.",
		SteamProfile_CheckSteamAge_Failed = "Impossible de récupérer l'âge du compte Steam à partir du profil Steam. L'utilisateur peut ne pas avoir configuré son profil de communauté ou ses paramètres de confidentialité masque ces données.",

		NoWeapons = "Pas d'armes",
		Screenshot = "Screenshot",
		ScreenshotTip = "Capture d'écran de %s [%s] pris sur %s",
		ScreenshotTip2 = "Si la capture d'écran est noire, un tricheur peut bloquer la capture d'écran..",

		PlayerLine_Active = "Actif",
		PlayerLine_Inactive = "AFK / ALT-Tab",
		PlayerLine_Unreachable = "Perte de connexion",

		RemoveFromSit      = "Retirer du Sit",
		TeleportToSit      = "Teleporter dans le Sit",
		MuteMicrophone     = "Mute Microphone",
		UnmuteMicrophone   = "Unmute Microphone",
		DisableTextChat    = "Désactiver Chat Textuel",
		EnableTextChat     = "Activer Chat Textuel",
		SteamProfile       = "Profil Steam",
		CopySteamID        = "Copier son SteamID",
		CopySteamID64      = "Copier son SteamID64",
		CopyIPAddress      = "Copier son Adresse IP",
		TakeScreenshot     = "Prendre un screenshot",
		CheckWeapons       = "Vérifier les armes",
		CheckSteamFriends  = "Vérifier les amis steam",
		CheckSteamGroups   = "Vérifier les groupes steam",
		CheckSteamAge      = "Vérifier l'âge du compte steam",
		CheckWallet        = "Vérifier sont portefeuille",
		CheckPocket        = "Vérifier sont inventaire",
		CheckValveBans     = "Vérifier ses bans VAC",
		CheckGmodPlaytime  = "Vérifier son temps de jeux",
		CheckSteamFamShare = "Vérifier le Partage familiale",
		FlashWindow        = "Avertir sur la barre des taches",

		NoPermission = "Vous n'avez pas la permission d'utiliser le système sit !",
		NoPermission_TargetStaff = "Vous n'avez pas la permission de retirer PLY_NAME d'un sit.",
		ChatCommand_MultipleMatches = "ARG_COUNT a trouvé des noms de joueurs identiques : MATCH_FAILS - essayez d'être plus spécifique",
		ChatCommand_MatchFailed = "Échec de la recherche du joueur MATCH_COUNT dont le nom contient : MATCH_FAILS",
		ChatCommand_MatchFailed_Plural = "Échec de la recherche des joueurs MATCH_COUNT avec des noms contenant : MATCH_FAILS",
		ChatCommand_AlreadyInSit = "PLY_NAME est déjà dans un sit! Executer !sits pour voir la liste des sits en cours.",
		ChatCommand_Clash = "Nous n'avons pas pu déterminer ce que vous vouliez faire avec ces joueurs parce qu'ils se trouvent dans des situations différentes - essayez de faire !sit avec un joueur à la fois.",
		ChatCommand_Clash_AddToSit = "PLY_NAME n'est pas dans un sit (MATCH_FAIL)",
		ChatCommand_Clash_RemoveFromSit = "PLY_NAME est dans un sit (MATCH_FAIL)",
		ChatCommand_NoResitArgs = "Vous n'avez pas de sit en cours, ou votre sit précédent est devenue obsolète (tous les joueurs sont déconnectés).",
		ChatCommand_InviteSent = "Une invitation à se joindre au sit a été envoyée à PLY_NAME!",

		SitInviteReceivedTitle = "Invitation à un sit",
		SitInviteReceived = "Vous avez été inviter à un sit %s, appuyez pour rejoindre! (Règlement de comptes entre joueurs)",
		JoinSit = "Rejoindre",

		AddPlayer = "Ajouter un joueur",
		AddPlayerEllipsis = "Ajouter...",
		EndSit = "Fin du sit",
		EndSitAreYouSure = "Tu es sûr de vouloir mettre fin à ce sit ?",
		PlayerAlreadyInSit = "Ce joueur est déjà dans un sit ; tapez !sits pour voir dans quelle sit est-il.",
		PlayerInvitedToSit = "Ce joueur a été invité à participer au sit!",

		ScreenshotFailedText = "Impossible de télécharger une capture d'écran sur le serveur!\nLe serveur de capture d'écran est hors service ou le réseau du lecteur/serveur bloque les connexions au serveur de capture d'écran.\nLes tricheurs peuvent être en mesure de le faire en bloquant le serveur de capture d'écran sur leur réseau, ou en cassant cette fonctionnalité via du Lua.",
		ScreenshotFailed = "Échec de la Capture d'écran",

		AllStaffDisconnected = "Tous les membres du personnel présents dans ce sit se sont déconnectés ; le sit est terminée.",
		AllPlayersDisconnected = "Tous les joueurs dans le sit se sont déconnectés, ils seront rajoutés s'ils se reconnectent.",
		AllPlayersDisconnected2 = "Si vous terminez le sit, si le(s) joueur(s) se reconnecte, vous serez avertis.",

		TakingScreenshot = "Prise de  la capture d'écran...",
		Staff = "Staff",

		ShowDisconnectReason = "PLY_NAME déconnecté du serveur pendant le sit (DISCONNECT_REASON)",
		ShowDisconnectReason_NoReason = "PLY_NAME déconnecté du serveur pendant le sit",

		ReloadTip = " Recharger pour mettre dans un sit",
		ReloadTipRemove = "Recharger pour retirer du sit",

		SitID = "Sit #%d",
		JoinSitLine = "Rejoindre le sit",

		Refresh = "Actualiser",

		SitPosFailed = "Échec de la mise en sit ! Assurez-vous de ne pas être coincé.",
		SitPosSuccess = "Ajout d'une position de sit avec succès!",

} end }