-- Contributors:
-- yam (STEAM_0:0:89734076)
-- AL4aZ (STEAM_0:1:36450381)

return {
	Name = "French",
	Flag = "flag16/fr.png",
	Phrases = {
		-- 3.2.0
		RainbowBackground = "Fond arc-en-ciel",

		-- 3.1.0
		KeypadOnlyFadingDoors = "PAS DE FADING DOOR",

		-- 3.0.2
		PaymentPrompt = "Ce keypad vous facturera %s pour l'accès.\nVoulez-vous continuer?",
		PaymentNamedPrompt = "\"%s\" vous facturera %s pour l'accès.\nVoulez-vous continuer?",
		PaymentPromptTitle = "Paiement Requis",

		-- 3.0.1
		CrackerNotLinked = "NON LIÉ",

		-- 3.0.0
		CrackerWaiting = "ATTENDRE",
		CrackerTooFar = "TROP LOIN",
		CrackerReady = "PRÊT",
		CrackerCantCrack = "NE PEUT PAS CRACKER",
		CrackSuccess = "SUCCESS",
		CrackFailed = "FAILED",
		KeypadCracker = "Keypad Cracker",
		NoneProfileError = "Vous ne pouvez pas utiliser des keypads persistants lorsque \"none\" le profil est actif",
		NoneProfileToolscreen = "\"none\" le profil est actif",

		-- 2.4.0
		DoorLock = "Verrouiller la porte",
		DoorLockTip = "Verrouille la porte automatiquement pour vous",
		DisableMapObjTip = "Lorsqu'il est activé, l'objet de la carte sera désactivé; rien ne pourra interagir avec lui (y compris les béliers, les crochets, etc.) et il ne peut être interagi que via le keypad.\n\nPour les portes, cela les maintiendra automatiquement verrouillées.",
		Undo_bkeycard_pickup = "Annuler la carte abandonnée",
		Undone_bkeycard_pickup = "Carte-clé perdue annulée",
		FlagName = "Drapeau: %s",
		HelixFlag = "Helix Flag", -- do not translate Helix
		Flag = "Flag",

		-- 2.3.0
		KeypadImages = "Keypad Images",
		BanFromFeature = "Interdire le joueur de la fonctionnalité",
		UnbanFromFeature = "Retirer le joueur de la fonctionnalité",
		BannedFromFeature = "Vous êtes banni de cette fonctionnalité!",
		BannedFromFeatureAdmin = "Joueur banni avec succès de la fonctionnalité",
		UnbannedFromFeatureAdmin = "Joueur déban avec succès de la fonctionnalité",
		FadingDoorKey = "Ouvrir la clé", -- touche du keypad qui ouvre la porte qui s'efface
		FadingDoorKeyTip = "La touche de votre keypad qui ouvre la porte qui s'estompe",
		FadingDoorLinkTip = "Vous pouvez lier les portes qui s'effacent aux keypads à l'aide de l'outil Linker",
		UncrackableIncompatibilitiesTip = "NOTE: Certains crackers de keypad peuvent ne pas être compatibles et peuvent ignorer cela",

		-- 2.2.0
		Access = "Accès",
		AccessCharge = "Accès taxé",
		AccessDenied = "Accès refusé",
		AccessDeniedKey = "Touche accès non autorisé",
		AccessDeniedKeyTip = "Correspond à la touche de votre clavier activée lorsque vous obtenez un accès refusé",
		AccessDeniedNotificationTip = "Voulez vous recevoir des notifiations lorsqu'une personne obtient un accès non autorisé sur ce pavé numérique ?",
		AccessGranted = "Accès autorisé",
		AccessGrantedKey = "Touche accès autorisé",
		AccessGrantedKeyTip = "Correspond à la touche de votre clavier activée lorsque vous obtenez un accès autorisé",
		AccessGrantedNotificationTip = "Voulez-vous recevoir des notifications lorsqu'une personne obtient un accès autorisé sur ce pavé numérique ?",
		AccessLogs = "Historique des accès",
		AccessLogsTitle = "Historique des accès du pavé numérique",
		AccessLogsWarrant = "Vous devez avoir une autorisation pour consulter l'historique des accès de ce pavé numérique.",
		AccessTable = "Liste des accès",
		ActiveSound = "Son d'activation",
		AddGroup = "Ajouter %s",
		Added = "Ajouté",
		AdminMenu = "Menu Administrateur",
		AdminTool = "Outil Administrateur",
		All = "Tous",
		AllSuperiorKeycards = "Toutes les cartes d'accès supérieures",
		Appearance = "Apparence",
		AreYouSureDeleteImage = "Êtes-vous sûr de vouloir supprimer cette image?",
		AuthMode = "Mode d'authentification",
		AutoFadingDoor = "Création d'une porte automatique (Fading Door)", -- might be good to refer to the fading door expression as a lot of people better know this
		AutoFadingDoorTip = "Créer automatiquement une porte sur le prop ciblé lorsque vous y mettez un pavé numérique",
		BackgroundColor = "Couleur d'arrière plan",
		Behaviour = "Comportement",
		Blacklist = "Liste noire",
		BlacklistTip = "Les personnes qui se verront refuser l'accès?\nLa liste noire (blacklist) est prioritaire sur la liste blanche (whitelist).",
		Blacklisted = "Mis sur liste noire",
		Broken = "Cassé",
		Buttons = "Boutons",
		CanKeypadCrack = "Possibilité de pirater le pavé numérique",
		Cancel = "Annuler",
		Charge = "Taxer",
		ChargeUnauthorized = "Taxer uniquement les personnes non autorisées",
		ChargeUnauthorizedTip = "Est-ce que les personnes non autorisés (dans la liste noire/pas dans la liste blanche) sont les seules à être taxées pour l'accès,\nou alors est-ce que l'on taxe toutes les personnes sans distinctions?",
		CheckingURL = "Vérification de l'URL... veuillez patienter",
		Cleaned__bkeypads_fading_doors = "Portes automatiques nettoyées(bKeypads)",
		Cleaned_bKeypads = "Pavés numériques néttoyés",
		Cleanup__bkeypads_fading_doors = "Portes automatiques (bKeypads)",
		Clear = "Nettoyer",
		ClearAccessMatrixConfirm = "Êtes-vous sûr de vouloir effacer la liste des accès ?",
		CloseSound = "Son de fermeture",
		Configuration = "Configuration",
		CopiedExclamation = "Copié!",
		CopyName = "Copier le nom",
		CopySteamID = "Copier le SteamID",
		CopySteamID64 = "Copier le SteamID64",
		CopyValue = "Copier la valeur",
		CustomEllipsis = "Personnalisé...",
		DBinderTip = "Faites un clic droit pour supprimer",
		Delay = "Délai",
		Delete = "Supprimer",
		DeleteImage = "Supprimer l'image",
		DeleteSaveConfirm = "Êtes-vous sûr de vouloir supprimer la sauvegarde \"%s\"?",
		Denied = "Refusé",
		Destructible = "Déstructible",
		Destruction = "Déstruction",
		DisableMapObj = "Désactiver les objets de la carte",
		Dismiss = "Ignorer",
		DomainNotWhitelisted = "Ce nom de domaine n'est pas autorisé !",
		Done = "Fait",
		Doors = "Porte",
		DroppedKeycard = "Déposer carte d'accès",
		DroppedKeycardHideToHolders = "Cacher aux personnes déjà en possession d'une carte",
		DroppedKeycardHideToHoldersTip = "Si coché alors les joueurs, ayant ramassé une carte d'accès, ne seront pas en mesure de les voir de nouveau au sol.\n\nATTENTION : Du fait d'un bug Gmod, il est actuellement impossible de cacher et d'enlever la collision des cartes avec les joueurs, autrement dit elles pourraient être pousées par des joueurs ne les voyant pas.",
		DroppedKeycardLevel = "Niveau(x)",
		DroppedKeycardPersistenceTip = "Si coché alors cette carte d'accès apparaitra à chaque chargement de la map.\n\nFaites clique droit sur la carte d'accès avec l'outil de persistence < Billy's Keypads > (vous pouvez le trouver dans Spawn Menu > Admin Tab > Persistence) afin de le supprimer définitivement de la map. \n\nVous pouvez aussi manipuler la carte d'accès avec votre physgun afin de la déplacer et de la sauvegarder à un meilleur emplacement.",
		DroppedKeycardPhysics = "Activer la physique",
		DroppedKeycardPhysicsTip = "Si coché alors la carte d'accès peut être déplacée à volonté.\n\nSi persistant alors la dernière position ne sera pas prise en compte, que ce soit la derniere avant l'extinction du serveur ou celle à la suite d'un déplacement via physgun.",
		DroppedKeycardPlayerModel = "Modèle du joueur",
		DroppedKeycardQuantity = "Quantité",
		DroppedKeycardQuantityInfinite = "Infini",
		DroppedKeycardTouchToPickup = "Toucher pour ramasser",
		DroppedKeycardTouchToPickupTip = "Si coché alors les joueurs pourront ramasser la carte juste en la touchant ou en passant dessus, de même lorsque l'on appuiera sur E.",
		Enable = "Activer",
		EnterUsergroup = "Entrer le nom du groupe utilisateur",
		Error = "Erreur",
		FaceID = "FaceID",
		FaceIDTip = "Utiliser la reconnaissance faciale comme mode d'authentification",
		FadingDoor = "Porte Automatique",
		FadingDoorCreated = "< Porte automatique > créée !",
		FadingDoorHelp = "L'outil < Porte automatique > permet de transformer n'importe quel prop en porte!\n\nLes portes peuvent être liées à des pavés numériques en utilisant l'outil < Liaison >, vous permettant de contrôler l'accès à vos bases, vos créations ou vos biens.",
		FadingDoorRemoved = "< Porte automatique > supprimée!",
		FadingDoorSettingsCopied = "Les propriétés de la porte automatique ont été copiées!",
		FadingDoorUpdated = "Porte automatique mise à jour!",
		Finished = "Terminé",
		Freeze = "Figer",
		FreezeTip = "Si le pavé numérique doit être figé ou non lorsqu'il apparaît",
		Friends = "Amis",
		General = "Général",
		Granted = "Autorisé",
		GroupAgendaGroup = "Groupe agenda",
		GroupCustomLuaFunction = "Fonctions Lua personnalisées",
		GroupCustomTeamGroup = "Groupe équipes",
		GroupDemoteGroup = "Groupe rétrogradés",
		GroupDoorGroup = "Groupe de porte",
		GroupJobCategory = "Catégorie métier",
		GroupKeycardLevel = "Niveau carte d'accès",
		GroupMe = "Moi",
		Hacked = "Piraté",
		HealthAdded = "+%d de Santé",
		Help = "Aide",
		HideMapObj = "Cacher",
		HideMapObjTip = "Cela permet de ne pas afficher le rendu du bouton.\n\nIl y'a un risque que ça ne marche pas sur certaines cartes; rediriger l'utilisation +use est plus approprié dans ce cas.",
		HoldLength = "Durée maintien:",
		HoldLengthTip = "Combien de temps va durer l'action du pavé numérique (en secondes)?",
		Idle = "Inactif",
		ImageAlreadyExists = "Vous avez déjà ajouté cette image (\"%s\")",
		ImageName = "Nom de l'image...",
		ImageURL = "URL de l'image",
		Indestructible = "Indéstructible",
		InitialDelay = "Délai initial:",
		InitialDelayTip = "Combien de temps va attendre un pavé numérique avant d'émettre une action?",
		InvalidImage = "Image invalide:\n",
		InvalidURL = "URL invalide. Exemples:\n\nhttps://i.imgur.com/9j3U3SY.jpg\nhttps://i.imgur.com/auA1H2y.jpg",
		Job = "Métier",
		Jobs = "Métiers",
		JobsSelector = "Sélecteur métier(s)",
		Key = "Clé",
		Keycard = "Carte d'accès",
		KeycardDrop = "Déposer",
		KeycardInstructions = "Clique gauche sur un scanneur pour passer votre carte d'accès\n\nClique droit pour vous identifier\n\nR/Recharger pour ouvrir l'inventaire de vos cartes",
		KeycardLevel = "Niveau %d",
		KeycardLevels = "Niveaux",
		KeycardSwitch = "Échanger",
		KeycardTip = "Utilise les cartes d'accès comme mode d'authentification",
		KeypadAccessLogs = "Scanneur d'historique",
		KeypadAccessMatrixCopied = "Liste des accès du pavé numérique copié !",
		KeypadAccessMatrixCopyError = "Il y'a eu une erreur lors de la copie de la liste des accès - désolé!",
		KeypadAccessMatrixCopying = "Téléchargement de la liste des accès du pavé numérique...",
		KeypadAccessTip2 = "Clique droit sur une ligne afin de la supprimer",
		KeypadBattery = "Batterie keypad",
		KeypadBroken = "Pavé numérique détérioré!",
		KeypadHackedAdminHidden = "[CLIQUER POUR VISUALISER]",
		KeypadMethod = "Méthode",
		KeypadNameTip = "Donnez un nom adapté à votre pavé numérique.\nIl va apparaître dans les notifications et peut aider les membres du staff à être identifié dans l'historique.",
		KeypadOnlyFadingDoor = "Cette porte automatique peut être uniquement ouverte et fermée via un pavé numérique!",
		KeypadRepaired = "Pavé numérique réparé!",
		KeypadShield = "Protection pour pavé numérique",
		KeypadShieldBattery = "Batterie protection keypad",
		LastSaved = "Dernière sauvegarde: %s",
		LastUpdated = "Dernière mise à jour",
		LinkTypeButton = "LIEN AVEC UN BOUTON DE LA CARTE",
		LinkTypeDoor = "LIEN AVEC UNE PORTE DE LA CARTE",
		LinkTypeFadingDoor = "LIEN AVEC UNE PORTE AUTOMATIQUE",
		LinkTypeKeypad = "LIEN AVEC UN PAVE NUMERIQUE",
		LinkTypeMap = "LIEN AVEC UN OBJET DE LA CARTE",
		LinkedSuccessfully = "Lié avec succès!",
		Linker = "Système de liaison",
		LinkerHelp = "L'outil de liaison vous permet de lier les portes automatiques, les portes et les boutons de la map à des pavés numériques.\n\nAvec cet outil, vous êtes également en mesure de lier deux pavés numériques ensemble, ce qui signifie qu'ils partageront la même configuration d'accès!",
		LoadSave = "Charger",
		LoadSaveFailed = "Échec de la sauvegarde! Cette sauvegarde est potentiellement corrompue, trop vielle ou une erreur s'est produite.",
		LoadSaveWarning = "Êtes-vous sûr de vouloir charger la sauvegarde \"%s\"?\nVous allez perdre tous les paramètres non sauvegardés.",
		LoadingEllipsis = "Chargement...",
		LogoImage = "Logo/Image",
		Look = "Regard",
		ManualSteamID = "SteamID/SteamID64/Lien profil Steam",
		ManualSteamIDError = "Nous n'avons pas reconnu le SteamID, SteamID64 ou le lien de profil Steam saisi.\nExemples:\n\nSteamID: %s\nSteamID64: %s\nLien profil Steam: %s\nLien profil Steam: %s",
		ManualSteamIDNetworkError = "Une erreur réseau nous a empêché d'analyser le lien du profil Steam.\nVeuillez s'il vous plaît essayer plus tard de nouveau ou entrer un SteamID/SteamID64.",
		ManualSteamIDProfileError = "Nous n'avons pas pu extraire un SteamID depuis ce lien profil Steam - veuillez vérifier le lien et essayer de nouveau.",
		ManualSteamIDProfileNotFound = "Il n'existe pas d'utilisateur Steam pour ce lien !\nVeuillez réessayer plus tard ou entrer manuelle un SteamID/SteamID64.",
		MapDoorToggleTip = "Cela va permettre d'ouvrir ou de fermer la porte mais ne permettra pas de rétablir son état intial suite à l'action du pavé numérique.",
		MapDoubleToggle = "Double basculement",
		MapDoubleToggleTip = "Cela va permettre d'actionner deux fois le bouton (APPUYER .. APPUYER).",
		MapHold = "Maintenir",
		MapHoldTip = "Cela va permettre au bouton d'attendre un certain moment avant de terminer son action (APPUYER .. ATTENDRE .. RELACHER)",
		MapLinking = "Liaison de la carte",
		MapPreventLockpick = "Désactiver les pieds de biche",
		MapPreventLockpickTip = "Dans le cadre du DarkRP, cela interdit simplement l'utilisation des pieds de biche sur les portes automatiques.",
		MapRedirectUse = "Redirection < +use > vers un pavé numérique",
		MapRedirectUseTip = "Cela permet de transmettre toutes les actions d'un joueur sur un objet de la map vers l'utilisation d'un pavé numérique.",
		MapToggle = "Bascule",
		MapToggleTip = "Cela permet au bouton de basculer, ce qui équivaut au comportement (APPUYER) plutôt que le comportement par défaut (APPUYER .. RELACHER).",
		MaxHealth = "Vie maximale",
		Mode = "Mode",
		Mouse = "Souris",
		Name = "Nom",
		Nearby = "A proximité",
		NewImage = "+ Nouveau",
		NewImageSubtitle = "Entrer l'URL de l'image.\n\n* Doit obligatoirement être hebergé sur un nom de domaine autorisé\n* Dimensions recommandées: 256x256\n* Doit être de type JPEG or PNG\n* Taille maximale: 2 MB",
		NewImageTitle = "Nouvelle image",
		No = "Non",
		NoCollide = "Pas de collisions",
		NoCollideTip = "Est-ce que le pavé numérique aura des collisions avec les joueurs et entités ? - ne vous inquiétez pas, ça ne tombera pas en dehors de la carte si vous désactivez les collisions.",
		NoData = "Aucune donnée",
		None = "Aucune",
		NotPersistent = "Non persistant",
		Notification_Access = "L'accès a été %s à %s",
		Notification_Access_Named = "L'accès a été %s à %s pour le pavé numérique %s",
		Notification_DENIED = "REFUSÉ",
		Notification_GRANTED = "AUTORISÉ",
		Notification_PaymentCantAfford = "Vous ne pouvez pas payer les frais de %s pour accéder à ce pavé numérique!",
		Notification_PaymentCantAfford_Named = "Vous ne pouvez pas payer les frais de %s pour accéder à %s!",
		Notification_PaymentReceived = "Vous avez reçu %s de la part de %s pour un accès au pavé numérique!",
		Notification_PaymentReceived_Named = "Vous avez reçu %s de la part de %s pour l'accès à %s!",
		Notification_PaymentTaken = "Vous avez payé %s pour accéder à ce pavé numérique",
		Notification_PaymentTaken_Named = "Vous avez payé %s pour accéder à %s",
		Notifications = "Notifications",
		Offline = "Hors Ligne",
		Online = "En Ligne",
		OpenSound = "Son d'ouverture",
		Optimizing = "Optimisations: %s",
		OwnedBy = "Possédé par",
		PIN = "Code PIN",
		PINTip = "Utilise un code pin de 1 à 6 chiffres comme mode d'authentification\nAIDE: Vous pouvez utiliser votre pavé numérique d'ordinateur pour entrer le code PIN!",
		Payment = "Paiement",
		PaymentAboveMaximum = "La taxe maximale est de %s",
		PaymentBelowMinimum = "La taxe minimale est de %s",
		PaymentEntry = "Entrer le montant de la taxe pour y accéder.\nIls seront alertés de la taxe avant tout paiement de cette dernière.",
		PaymentMaximum = "Maximum: %s",
		PaymentMinimum = "Minimum: %s",
		Persistence = "Persistence",
		PersistenceHelp = "Cet outil vous permet de créer des pavés numériques permanents - Les pavés numériques permanents sont bien entendu présents après chaque relance du serveur.\n\nL'outil a également une fonctionnalité supplémentaire puissante qui vous permet de créer des configurations différentes pour la même carte, tout en sautant de l'une à l'autre à la volée.\n\nNOTE: Si vous avez effectué des modifications sur un pavé numériqué permanent, comme modifier sa position ou son angle, vous devrez appuyer sur votre touche \"Rechargement\" pour sauvegarder les modifications.",
		Persistent = "Persistant",
		PersistentKeycardSave = "Cartes d'accès permanentes sauvegardées!",
		Player = "Joueur",
		Players = "Joueurs",
		PlayersSelector = "Sélecteur Joueur(s)",
		Preview = "Prévisualisation",
		Profile = "Profil",
		ProfileSwitchedChat = "Profil permanent changé à \"%s\"",
		Profiles = "Profils",
		Properties = "Propriétés",
		PseudoMapLink = "Faux lien",
		PseudoMapLinkTip = "Si il est activé, le pavé numérique relié n'aura pas d'incidence sur l'objet de la carte lors de l'autorisation ou du dénie. Cela permet simplement de désactiver l'utilisation du pied de biche, de rediriger son utilisation, de désactiver ou de cacher les boutons et portes sans que le pavé numérique puisse les affécter.",
		Recent = "Récent",
		Refresh = "Actualiser",
		Remove = "Supprimer",
		RepeatDelay = "Répéter le délai:",
		RepeatDelayTip = "Quel est le temps d'attente en secondes entre les différentes répétitions du pavé numérique?",
		Repeats = "Répétitions:",
		RepeatsTip = "Combien de répétitions vont être appliquées par le pavé numérique?",
		Reset = "Réinitialiser",
		ResetAllData = "Réinitialiser toutes les données du script < Billy's Keypads >",
		ResetAllDataAreYouSure = "Êtes-vous sûr de vouloir supprimer les données du script < Billy's Keypads >?\nVous pouvez par exemple utiliser cette action pour des fichiers corrompus.\nCela engendrera la réinitialisation de tous les paramètres, les pavés numériques sauvegardés, les caches, etc et vous permettra de faire table rase.\n\nSi vous avez continuellement des erreurs sur votre serveur, le script < Billy's Keypads > n'est sûrement plus à jour. Demandez aux propriétaires du serveur si ils ont maintenu le script à jour!",
		ResetSettings = "Réinitialiser les paramètres",
		ResetSettingsAreYouSure = "Êtes-vous sûr de vouloir réinitialiser les paramètres?\nLe \"spawn menu\" va être rechargé.",
		Reversed = "Revenir",
		SBoxLimit__bkeypads_fading_doors = "Vous avez atteint la limite de porte automatique (bKeypads) !",
		SBoxLimit_bKeypads = "Vous avez atteint la limite de pavé numérique (bKeypads)!",
		Save = "Sauvegarder",
		SaveKeypad = "Sauvegarder le pavé numérique",
		SaveKeypadAlreadyExists = "Ce fichier existe déjà, voulez-vous le remplacer?\nLa dernière modification du fichier date de %s",
		SaveKeypadFileName = "Sauvegarde effectué pour le pavé numérique nommé :",
		SaveLoadTip = "Vous pouvez sauvegarder et charger des configurations de pavé numérique ici!",
		SavePersistentKeypads = "Sauvegarder les keypads permanents",
		SavedKeypads = "Pavés numériques sauvegardés",
		Scanning = "Scan en cours",
		ScanningStatus = "Statut du scan",
		Search = "Recherche",
		SearchEllipsis = "Recherche...",
		SetLogoImage = "Mettre le logo/l'image",
		SetPayment = "Mettre des frais d'accès",
		SetPaymentTip = "Taxer les personnes accédant à ce pavé numérique",
		Setting_3D2DDistance = "Distance rendu",
		Setting_3D2DDistanceTip = "A quelle distance doit on arrêter le rendu 3D2D ? (exemple, les écrans des pavés numériques, leurs formes, leurs identifications etc.)",
		Setting_Accessibility = "Accessibilité",
		Setting_AutoThreshold = "Seuil de FPS",
		Setting_AutoThresholdTip = "Quel est le seuil de FPS à partir duquel des optimisations seront automatiquement appliquées?",
		Setting_CustomImages = "Images personnalisées",
		Setting_CustomImagesTip = "Si vous ne voulez pas voir des images personnalisées sur les pavés numériques, vous pouvez forcer leur interdiction ici. Vous serez toujours en mesure de voir vos propres images personnalisées.",
		Setting_CustomImages_Imgur = "Uniquement Imgur",
		Setting_CustomImages_ImgurTip = "Les images personnalisées peuvent être utilisées pour trouver votre adresse IP. C'est très difficile de lier une adresse IP à chaque joueur sur le serveur mais si vous êtes soucieux de la sécurité vous pouvez restreindre les images uniquement en provenance de Imgur.\n\nNOTE: Par défaut, Imgur est la seule source d'image autorisée mais c'est à la main du propriétaire du serveur (qui connait déjà votre adresse IP au passage)",
		Setting_DrawKeypadProperties = "Afficher les propriétés du pavé numérique",
		Setting_DrawKeypadPropertiesTip = "Permet d'afficher les propriétés en dessous des pavés numériques que vous vous apprêtez à placer.",
		Setting_KeycardTextures = "Désactiver les textures dynamiques des pavés numériques",
		Setting_KeycardTexturesTip = "Les textures dynamiques sont généralement bien optimisées mais les PCs bas de gamme ou les serveurs en manque de FPS vont avoir des difficultés.",
		Setting_NotificationsMax = "Limite max notifs",
		Setting_NotificationsMaxTip = "Le nombre maximale de notifications pouvant apparaître avant de devoir effacer les anciennes",
		Setting_NotificationsTextSize = "Taille du texte",
		Setting_NotificationsTime = "Temps des notifs",
		Setting_NotificationsTimeTip = "Quelle est la durée d'affichage d'une notification avant de devoir la supprimer ?",
		Setting_Optimizations = "Optimisations",
		Setting_OptimizationsTip = "Le script < Billy's Keypads > adapte ses optimisations de performance en fonction de vos FPS.\n\nAuto: Surveille vos FPS et fait des optimisations à la volée\nAucune: Pas d'optimisations\nPatate: Toutes les optimisations sont forcées",
		Setting_Optimizations_Auto = "Auto",
		Setting_Optimizations_Potato = "Patate",
		Setting_Other = "Autre",
		Setting_PINInputMode = "Mode de saisie",
		Setting_PINInputModeTip = "Comment souhaitez vous saisir le code PIN?\n\nRegard = Regarder les differents boutons et appuyer sur E\nSouris = Appuyer sur E sur le pavé numérique et utiliser la souris pour intéragir avec les boutons",
		Setting_TooltipSize = "Taille texte aides",
		Settings = "Paramètres",
		Shield = "Protection",
		ShieldAdded = "+%d Protection",
		Size = "Taille",
		Slant = "Pavé numérique pendant/incliné",
		SlantTip = "Donne un effet au pavé numérique et nous laisse à penser qu'il est cassé tout en pendant sur le mur",
		Slanted = "Incliné",
		Sounds = "Sons",
		Spawn = "Apparaître",
		SpawnDroppedKeycard = "Faire apparaître une carte d'accès qui sera deposée",
		SpawnMenuKeypad = " " .. "Pavé numérique",
		SteamFriends = "Amis Steam",
		SteamIDFinder = "SteamID Finder",
		Switch = "Changer",
		Team = "Équipe",
		Teams = "Équipes",
		Time = "Temps",
		ToggleActive = "Basculement activé",
		ToolHelp1 = "Les pavés numériques vous permettent de contrôler l'accès des portes, des portes automatiques, des composants Wiremod et bien plus.",
		ToolHelp2 = "Vous pouvez donner des droits d'accès aux pavés numériques via des cartes d'accès ou par reconnaissance faciale, et ce par détection du SteamID, d'un groupe utilisateur, d'un métier/d'une équipe d'un ami.",
		ToolHelp3 = "A travers l'utilisation de fonctions Lua personnalisées, les développeurs peuvent ajouter plus de fonctionnalités comme la gestion des levels, des gangs/des clubs etc...",
		ToolHelp4 = "Cependant, vos pavés numériques sont exposés à des piratages notamment les < keypads crackers >, faites attention aux bruits des bips!",
		ToolScreenNoPermission = "Vous n'avez pas la permission pour utiliser cela!",
		ToolScreenNoPermissionEnt = "Vous n'avez pas la permission pour cette entité!",
		Tutorial = "Tutoriel",
		Type = "Type",
		Uncrackable = "Protéger des piratages",
		UncrackableTip = "Est-ce que le pavé numérique est résistant au piratage des < keypad crackers >",
		Undo_bKeypad = "Pavé numérique",
		Undo_bKeypads_Button_Link = "Lien bouton (bKeypads)",
		Undo_bKeypads_Door_Link = "Lien porte (bKeypads)",
		Undo_bKeypads_FadingDoor = "Porte automatique (bKeypads)",
		Undo_bKeypads_FadingDoor_Link = "Lien porte automatique (bKeypads)",
		Undo_bKeypads_Keypad_Link = "Lien pavé numérique (bKeypads)",
		Undo_bKeypads_Map_Link = "Lien objet map (bKeypads)",
		Undone_bKeypad = "Annulation pavé numérique",
		Undone_bKeypads_Button_Link = "Annulation lien bouton (bKeypads)",
		Undone_bKeypads_Door_Link = "Annulation lien porte (bKeypads)",
		Undone_bKeypads_FadingDoor = "Annulation porte automatique (bKeypads)",
		Undone_bKeypads_FadingDoor_Link = "Annulation lien porte automatique (bKeypads)",
		Undone_bKeypads_Keypad_Link = "Annulation lien pavé numérique (bKeypads)",
		Undone_bKeypads_Map_Link = "Annulation lien objet map (bKeypads)",
		Unknown = "Inconnu",
		UnlinkedSuccessfully = "Lien dissocié avec succès!",
		Unnamed = "(Anonyme)",
		Usergroup = "Groupe utilisateur",
		Value = "Valeur",
		ViewProfile = "Visualiser profil",
		Weld = "Souder",
		WeldTip = "Est-ce que le pavé numérique doit être soudé quand il apparaît?",
		When = "Quand",
		Whitelist = "Liste blanche",
		WhitelistTip = "A qui l'accès doit-il être accordé?",
		Whitelisted = "Mis sur liste blanche",
		WhitelistedDomains = "Domaines autorisés",
		WhitelistedDomainsTip = "Ce serveur permet uniquement de sourcer les images à partir des domaines suivants:",
		Who = "Qui",
		WiremodTip = "Voulez-vous activer les entrées/sorties Wiremod pour ce pavé numérique?",
		Yes = "Oui",
		s_hour = "il y'a %d heure",
		s_hours = "il y'a %d heures",
		s_minute = "il y'a %d minute",
		s_minutes = "il y'a %d minutes",
		s_second = "il y'a %d seconde",
		s_seconds = "il y'a %d secondes",
		["tool.bkeypads.copy"] = "Copier la liste des accès du pavé numérique",
		["tool.bkeypads.create_update"] = "Créer/Mettre à jour le pavé numérique",
		["tool.bkeypads.desc"] = "Créer des pavés numériques pour protéger l'accès des portes etc...",
		["tool.bkeypads.name"] = "Billy's Keypads",
		["tool.bkeypads.switch_linker"] = "Changer pour l'outil de Liaison",
		["tool.bkeypads_admin_tool.desc"] = "Visualiser les liens des pavés numériques, les listes des accès, les propriétés et l'historique",
		["tool.bkeypads_admin_tool.focus"] = "Cibler un pavé numérique",
		["tool.bkeypads_admin_tool.help"] = "L'outil administrateur peut être utilisé pour visualiser une variété d'informations à propos d'un pavé numérique.\n\nRegarder un pavé numérique pour afficher ses propriétés.\n\nClique gauche pour cibler un pavé numérique.\nClique droit pour ne plus cibler un pavé numérique.\n\nAppuyer \"Rechargement\" pour ouvrir l'interface administrateur (propriétés, historique d'accès, liste des accès.)",
		["tool.bkeypads_admin_tool.menu"] = "Voir l'interface administrateur",
		["tool.bkeypads_admin_tool.name"] = "Outil Administrateur",
		["tool.bkeypads_admin_tool.unfocus"] = "Ne plus cibler",
		["tool.bkeypads_breaker.break_keypad"] = "Casser le pavé numérique",
		["tool.bkeypads_breaker.desc"] = "\"Casse\" les pavés numériques et leur donne un effet de pendaison",
		["tool.bkeypads_breaker.help"] = "\"Casse\" les pavés numériques et leur donne un effet de pendaison. Les pavés numériques détériorés ne peuvent plus être utilisés et garderont tous les liens sur la map avec les entités, les portes et les états bloquées ou débloqués.\n\nC'est sympa pour les événements de serveur où l'on veut simuler une brèche ou une défaillance des systèmes de sécurité.",
		["tool.bkeypads_breaker.name"] = "Destructeur de pavé numérique",
		["tool.bkeypads_breaker.repair_keypad"] = "Réparer le pavé numérique",
		["tool.bkeypads_fading_door.copy"] = "Copier les paramètres",
		["tool.bkeypads_fading_door.desc"] = "Peut transformer n'importe quoi en une porte automatique",
		["tool.bkeypads_fading_door.door"] = "Créer/Mettre à jour une porte automatique",
		["tool.bkeypads_fading_door.info1"] = "Les portes automatiques vous permettent de transformer n'importe quel prop en une porte utilisable par tous",
		["tool.bkeypads_fading_door.info2"] = "La porte automatique peut seulement être ouverte et fermée via un pavé numérique",
		["tool.bkeypads_fading_door.info3"] = "Utiliser l'outil liaison afin de lier des pavés numériques à des portes automatiques",
		["tool.bkeypads_fading_door.name"] = "Portes automatiques",
		["tool.bkeypads_fading_door.remove"] = "Supprimer une porte automatique",
		["tool.bkeypads_linker.Finished"] = "Terminé",
		["tool.bkeypads_linker.desc"] = "Lier les pavés numériques aux portes automatiques, aux objets de la carte et à d'autres pavés numériques",
		["tool.bkeypads_linker.link_all"] = "Lier à un pavé numérique/une porte automatique/un objet de la carte",
		["tool.bkeypads_linker.link_fading_door"] = "Lier à une porte automatique",
		["tool.bkeypads_linker.link_keypad"] = "Lier à un pavé numérique",
		["tool.bkeypads_linker.link_map_obj"] = "Lier à un objet de la map",
		["tool.bkeypads_linker.link_map_obj_info"] = "N'oubliez pas de configurer les liens des objets de la carte selon vos souhaits et ce dans la partie paramètre de l'outil!",
		["tool.bkeypads_linker.name"] = "Liaison",
		["tool.bkeypads_linker.on_access_denied"] = "Pour un accès refusé...",
		["tool.bkeypads_linker.on_access_granted"] = "Pour un accès autorisé...",
		["tool.bkeypads_linker.select"] = "Sélectionner un pavé numérique",
		["tool.bkeypads_linker.switch_access"] = "Échanger le mode d'accès",
		["tool.bkeypads_linker.switch_keypads"] = "Changer pour l'outil pavé numérique",
		["tool.bkeypads_linker.unlink_fading_door"] = "Dissocier de la porte automatique",
		["tool.bkeypads_linker.unlink_keypad"] = "Dissocier du pavé numérique",
		["tool.bkeypads_linker.unlink_map_obj"] = "Dissocier de l'objet",
		["tool.bkeypads_persistence.delete"] = "Supprimer un pavé numérique permanent",
		["tool.bkeypads_persistence.desc"] = "Permet de créer des pavés numériques persistants même aprés la relance des serveurs",
		["tool.bkeypads_persistence.make_persistent"] = "En faire un pavé numérique persistant",
		["tool.bkeypads_persistence.name"] = "Persistence",
		["tool.bkeypads_persistence.notification.created"] = "Création d'un pavé numérique persistant pour le profil \"%s\"",
		["tool.bkeypads_persistence.notification.deleted"] = "Suppression d'un pavé numérique persistant depuis le profil \"%s\"",
		["tool.bkeypads_persistence.notification.updated"] = "Sauvegarde d'un pavé numérique persistant pour le profil \"%s\"",
		["tool.bkeypads_persistence.update"] = "Mettre à jour le pavé numérique persistant",
	}
}