escore.text = escore.text or {}
local lang = escore.config.language


--case sensitive!
local langs = {
	["english"] = {
		--regular
		["online"] = "Online",
		["name"] = "Name",
		["nickname"] = "Nick",
		["job"] = "Job",
		["privilege"] = "Group",
		["ping"] = "Ping",
		["you"] = "You",
		["copyphrase"] = "Copied to clipboard!",
		["search"] = "Search",
		["radio"] = "Radio",
		["effect"] = "Effect",
		["on"] = "On",
		["off"] = "Off",
		["nofound"] = "Nothing found",

		--COMMANDS
		["friend"] = "Friend",
		["openprof"] = "Open profile",
		["tp"] = "Teleport",
		["bring"] = "Bring",
		["freeze"] = "TP + Freeze",
		["unfreeze"] = "Unfreeze",

		["common"] = "Common",
		["admin"] = "Admin",
		["copysteamid"] = "Copy STEAMID",
		["copynick"] = "Copy nickname",
		["current"] = "Current",

		--post
		["props"] = "Props",
		["kills"] = "Kills",
		["deaths"] = "Deaths",
		["joined"] = "joined",
		["disconnected"] = "disconnected",
	},

	["german"] = {
		--regular
		["online"] = "Online",
		["name"] = "Name",
		["nickname"] = "Nick",
		["job"] = "Arbeit",
		["privilege"] = "Privileg",
		["ping"] = "Ping",
		["you"] = "Sie",
		["copyphrase"] = "In die Zwischenablage kopiert!",
		["search"] = "Suche",
		["radio"] = "Radio",
		["effect"] = "Wirkung",
		["on"] = "Auf",
		["off"] = "Aus",
		["nofound"] = "Nichts gefunden",

		--COMMANDS
		["friend"] = "Freund",
		["openprof"] = "Profil öffnen",
		["tp"] = "Teleport",
		["bring"] = "Bring",
		["freeze"] = "TP + Einfrieren",
		["unfreeze"] = "Aufheben",

		["common"] = "Verbreitet",
		["admin"] = "Admin",
		["copysteamid"] = "STEAMID kopieren",
		["copynick"] = "Nickname kopieren",
		["current"] = "Strom",

		--post
		["props"] = "Props",
		["kills"] = "Tötet",
		["deaths"] = "Todesfälle",
		["joined"] = "beitreten",
		["disconnected"] = "getrennt",
	},

	["russian"] = {
		--regular
        ["online"] = "Онлайн",
        ["nickname"] = "Ник",
        ["name"] = "Имя",
        ["job"] = "Работа",
        ["privilege"] = "Привилегия",
        ["ping"] = "Пинг",
        ["you"] = "Вы",
        ["copyphrase"] = "Скопировано!",
        ["search"] = "Поиск",
        ["radio"] = "Радио",
        ["effect"] = "Эффект",
		["on"] = "Включить",
		["off"] = "Выключить",
		["nofound"] = "Ничего не найдено",

        --COMMANDS
        ["friend"] = "Друг",
        ["openprof"] = "Открыть профиль",
        ["tp"] = "Телепортироваться к игроку",
        ["bring"] = "Призвать к себе",
        ["freeze"] = "ТП + Заморозить",
        ["unfreeze"] = "Разморозить",

        ["common"] = "Обычные",
		["admin"] = "Админ",
		["copysteamid"] = "Скопировать STEAMID",
		["copynick"] = "Скопировать ник",
		["current"] = "Текущее",

        --post
        ["props"] = "Пропов",
        ["kills"] = "Убийств",
        ["deaths"] = "Смертей",
        ["joined"] = "присоединился",
        ["disconnected"] = "вышел",
	},

	["spanish"] = {
		--regular
		["online"] = "En Línea",
		["name"] = "Nombre",
		["nickname"] = "Nick",
		["job"] = "Trabajo",
		["privilege"] = "Grupo",
		["ping"] = "Ping",
		["you"] = "Tú",
		["copyphrase"] = "¡Copiado al portapapeles!",
		["search"] = "Buscar",
		["radio"] = "Radio",
		["effect"] = "Efecto",
		["on"] = "Encender",
		["off"] = "Apagar",
		["nofound"] = "Nada Encontrado",

		--COMMANDS
		["friend"] = "Amigo",
		["openprof"] = "Abrir perfil",
		["tp"] = "Teletransportar",
		["bring"] = "Traer",
		["freeze"] = "TP + Congelar",
		["unfreeze"] = "Descongelar",

		["common"] = "Común",
		["admin"] = "Admin",
		["copysteamid"] = "Copiar STEAMID",
		["copynick"] = "Copiar nick",
		["current"] = "Actual",

		--post
		["props"] = "Props",
		["kills"] = "Asesinatos",
		["deaths"] = "Muertes",
		["joined"] = "se ha unido",
		["disconnected"] = "desconectado",
	},

	["turkish"] = {
		--regular
		["online"] = "Çevrimiçi",
		["name"] = "İsim",
		["nickname"] = "Kullanıcı Adı",
		["job"] = "Meslek",
		["privilege"] = "Grup",
		["ping"] = "Gecikme",
		["you"] = "Sen",
		["copyphrase"] = "Panoya kopyalandı!",
		["search"] = "Ara",
		["radio"] = "Radyo",
		["effect"] = "Etki",
		["on"] = "Etkinleştirme",
		["off"] = "Kapat",
		["nofound"] = "Hiçbirşey Bulunamadı",

		--COMMANDS
		["friend"] = "arkadaş",
		["openprof"] = "Profili aç",
		["tp"] = "Işınlan",
		["bring"] = "Yanına Çek",
		["freeze"] = "Işınlan + Dondur",
		["unfreeze"] = "Dondurmayı Çöz",

		["common"] = "Genel",
		["admin"] = "Yetkili",
		["copysteamid"] = "STEAMID Kopyala",
		["copynick"] = "Kullanıcı adını kopyala",
		["current"] = "Mevcut",

		--post
		["props"] = "Proplar",
		["kills"] = "Leşler",
		["deaths"] = "Ölümler",
		["joined"] = "katıldı",
		["disconnected"] = "ayrıldı",
	},

	["french"] = {
		--regular
		["online"] = "En Ligne",
		["name"] = "Nom",
		["nickname"] = "Prénom",
		["job"] = "Métier",
		["privilege"] = "Grades",
		["ping"] = "Ping",
		["you"] = "Toi",
		["copyphrase"] = "Copier dans le presse papier",
		["search"] = "Rechercher",
		["radio"] = "Radio",
		["effect"] = "Effet",
		["on"] = "Activer",
		["off"] = "Éteindre",
		["nofound"] = "Rien n'a été trouvé",

		--COMMANDS
		["friend"] = "Ami(e)",
		["openprof"] = "Ouvir le profil",
		["tp"] = "Teleporter",
		["bring"] = "Ammener",
		["freeze"] = "TP + Geler",
		["unfreeze"] = "Dégeler",

		["common"] = "Basique",
		["admin"] = "Administration",
		["copysteamid"] = "Copier STEAMID",
		["copynick"] = "Copier Nom",
		["current"] = "Actuelle",

		--post
		["props"] = "Props",
		["kills"] = "Tué(s)",
		["deaths"] = "Mort(s)",
		["joined"] = "rejoindre",
		["disconnected"] = "déconnecté",
	},

	["swedish"] = {
		--regular
		["online"] = "Online",
		["name"] = "Namn",
		["nickname"] = "Nick",
		["job"] = "Job",
		["privilege"] = "Group",
		["ping"] = "Ping",
		["you"] = "Du",
		["copyphrase"] = "Kopieras till Urklipp!",
		["search"] = "Söka",
		["radio"] = "Radio",
		["effect"] = "Effekt",
		["on"] = "På",
		["off"] = "Av",
		["nofound"] = "Inget hittat",

		--COMMANDS
		["friend"] = "Kompis",
		["openprof"] = "Öppna profil",
		["tp"] = "Teleportera",
		["bring"] = "Bringa",
		["freeze"] = "TP + Frys",
		["unfreeze"] = "Unfreeze",

		["common"] = "Gemensam",
		["admin"] = "Admin",
		["copysteamid"] = "Kopia STEAMID",
		["copynick"] = "Kopia nickname",
		["current"] = "Närvarande",

		--post
		["props"] = "Props",
		["kills"] = "Kills",
		["deaths"] = "Dödsfall",
		["joined"] = "Ansluten",
		["disconnected"] = "bortkopplad",
	},
	["chinese"] = {
		--regular
		["online"] = "在线",
		["name"] = "名称",
		["nickname"] = "昵称",
		["job"] = "职业",
		["privilege"] = "组",
		["ping"] = "延迟",
		["you"] = "你",
		["copyphrase"] = "已复制到剪贴板!",
		["search"] = "搜索",
		["radio"] = "电台",
		["effect"] = "效果",
		["on"] = "开",
		["off"] = "关",
		["nofound"] = "未找到",

		--COMMANDS
		["friend"] = "好友",
		["openprof"] = "打开个人资料",
		["tp"] = "传送",
		["bring"] = "带来",
		["freeze"] = "TP + 冻结",
		["unfreeze"] = "解冻",

		["common"] = "普通",
		["admin"] = "管理员",
		["copysteamid"] = "复制 STEAMID",
		["copynick"] = "复制昵称",
		["current"] = "当前",

		--post
		["props"] = "物品",
		["kills"] = "击杀",
		["deaths"] = "死亡",
		["joined"] = "在线",
		["disconnected"] = "未在线",
	},
}



-----------------------------------
/// DO NOT EDIT AFTER THIS LINE ///
-----------------------------------
--Check
for st,phrase in pairs(langs["english"]) do
	for k,v in pairs(langs) do
		if k ~= "english" then
			if not v[st] then v[st] = phrase end
		end
	end
end

escore.text = langs[lang] or langs["english"]

-- TEXT FUNCTIONS
escore.text.capitalize = function(str)
	return str:gsub("^%l", string.upper)
end
escore.text.capitalizeall = function(str)
	function titleCase( first, rest ) return first:upper()..rest:lower() end
	return string.gsub(str, "(%a)([%w_']*)", titleCase)
end
escore.text.spacecase = function(str)
	local newstr = ""
	for _,v in ipairs(string.ToTable( str )) do
		newstr = newstr..v.." "
	end
	return newstr
end