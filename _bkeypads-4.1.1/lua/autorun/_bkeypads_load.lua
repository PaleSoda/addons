bKeypads_Ready = nil

local function includeSV(path)
	if SERVER then
		return include(path)
	end
end

local function includeSH(path)
	if SERVER then
		AddCSLuaFile(path)
	end
	return include(path)
end

local function includeCS(path)
	if SERVER then
		AddCSLuaFile(path)
	end
	if CLIENT then
		return include(path)
	end
end

file.CreateDir("bkeypads")
if CLIENT then
	file.CreateDir("bkeypads/stool")
	file.CreateDir("bkeypads/saved")
	file.CreateDir("bkeypads/keypad_img")
	file.CreateDir("bkeypads/keypad_img/saved")
elseif SERVER then
	file.CreateDir("bkeypads/persistence")
end

if SERVER then
	resource.AddWorkshop("2299543771")
end

bKeypads_ConfigAutoRefresh = nil

bKeypads = {}

bKeypads.noop = function() end

bKeypads.Keypads = {}
bKeypads.KeypadsRegistry = {}
for _, ent in ipairs(ents.GetAll()) do
	if IsValid(ent) and ent.bKeypad then
		table.insert(bKeypads.Keypads, ent)
		bKeypads.KeypadsRegistry[ent] = true
	end
end

function bKeypads:IsKeypad(ent)
	return IsValid(ent) and ent.bKeypad
end

--## Polyfills ##--

if SERVER then
	local escapeEntities = { ["&"] = "&amp;", ["<"] = "&lt;", [">"] = "&gt;" }
	bKeypads.markup = {}
	bKeypads.markup.Escape = (markup and markup.Escape) or function(str)
		return (tostring(str):gsub("[&<>]", escapeEntities))
	end
	bKeypads.markup.Color = (markup and markup.Color) or function(col)
		return
			col.r .. "," ..
			col.g .. "," ..
			col.b ..
			(col.a == 255 and "" or ("," .. col.a))
	end
end

do
	bKeypads.math = {}
	bKeypads.math.min = function(...)
		if #({...}) == 1 then
			return select(1, ...)
		else
			return math.min(...)
		end
	end
	bKeypads.math.max = function(...)
		if #({...}) == 1 then
			return select(1, ...)
		else
			return math.max(...)
		end
	end
end

do
	bKeypads.table = {}
	bKeypads.table.Shuffle = table.Shuffle or function(t)
		local n = #t
		for i = 1, n - 1 do
			local j = math.random(i, n)
			t[i], t[j] = t[j], t[i]
		end
	end
end

do
	local _net = net

	local fake_net = {}
	local debug_meta = {
		__index = function(self, key)
			return getmetatable(self)[key] or _net[key]
		end
	}
	for name, func in pairs(_net) do
		if isfunction(func) and name:match("^Write") or name:match("^Read") or name:match("^Start") or name:match("^Send") or name:match("^Broadcast") then
			debug_meta[name] = function(...)

				local args = {...}
				for i, arg in ipairs(args) do
					args[i] = isstring(arg) and "\"" .. (arg:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\"", "\\\"")) .. "\"" or tostring(arg)
				end

				local returns = { func(...) }
				local debug_returns = {}
				for i, val in ipairs(returns) do
					debug_returns[i] = isstring(val) and "\"" .. (val:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\"", "\\\"")) .. "\"" or tostring(val)
				end
				bKeypads:print("[NET] net." .. name .. "(" .. table.concat(args, ", ") .. ")" .. (#debug_returns > 0 and (" = " .. table.concat(debug_returns, ", ")) or ""))

				return unpack(returns)
			end
		end
	end
	setmetatable(fake_net, debug_meta)

	local function apply_net_debug(bkeypads_net_debug)
		bKeypads.net = bkeypads_net_debug and fake_net or _net
		return bkeypads_net_debug
	end
	apply_net_debug(CreateConVar("bkeypads_net_debug", "0", FCVAR_CHEAT, nil, 0, 1):GetBool())
	cvars.AddChangeCallback("bkeypads_net_debug", function(_, __, net_debug) bkeypads_net_debug = apply_net_debug(tobool(net_debug)) end)
end

do
	bKeypads.player = {}

	local plyHashTable_SteamID = {}
	local plyHashTable_SteamID64 = {}
	local plyHashTable_AccountID = {}
	local plyHashTable_UniqueID = {}

	function bKeypads.player.GetBySteamID(sid)
		return plyHashTable_SteamID[sid] or false
	end
	function bKeypads.player.GetBySteamID64(sid64)
		return plyHashTable_SteamID64[sid64] or false
	end
	function bKeypads.player.GetByAccountID(accountid)
		return plyHashTable_AccountID[accountid] or false
	end
	function bKeypads.player.GetByUniqueID(uniqueid)
		return plyHashTable_UniqueID[uniqueid] or false
	end

	local hashTableKeyCache = {}
	local function register(ply)
		local sid = ply:SteamID()
		if sid then
			plyHashTable_SteamID[sid] = ply
		end

		local sid64 = ply:SteamID64()
		if sid64 then
			plyHashTable_SteamID64[sid64] = ply
		end

		local accountid = ply:AccountID()
		if accountid then
			plyHashTable_AccountID[accountid] = ply
		end

		local uniqueid = ply:UniqueID()
		if uniqueid then
			plyHashTable_UniqueID[uniqueid] = ply
		end

		if sid then
			hashTableKeyCache[sid] = {
				sid64 = sid64,
				accountid = accountid,
				uniqueid = uniqueid
			}
		end
	end

	if CLIENT then
		hook.Add("bKeypads.PlayerInitialSpawn", "bKeypads.PlayerGetters.PlayerInitialSpawn", register)
		timer.Create("bKeypads.LocalPlayer", 0, 0, function()
			if LocalPlayer():IsValid() then
				register(LocalPlayer())
				timer.Remove("bKeypads.LocalPlayer")
			end
		end)
	else
		hook.Add("PlayerInitialSpawn", "bKeypads.PlayerGetters.PlayerInitialSpawn", register)
	end

	gameevent.Listen("player_disconnect")
	hook.Add("player_disconnect", "bKeypads.PlayerGetters.player_disconnect", function(data)
		local sid = data.networkid
		if sid then
			plyHashTable_SteamID[sid] = nil

			local keyCache = hashTableKeyCache[sid]
			if keyCache then
				if keyCache.sid64 then
					plyHashTable_SteamID64[keyCache.sid64] = nil
				end
				if keyCache.accountid then
					plyHashTable_AccountID[keyCache.accountid] = nil
				end
				if keyCache.uniqueid then
					plyHashTable_UniqueID[keyCache.uniqueid] = nil
				end
				hashTableKeyCache[sid] = nil
			end
		end
	end)

	for _, ply in ipairs(player.GetAll()) do
		register(ply)
	end
end

--## Enumerations & Constants ##--

bKeypads.COLOR = {}
	bKeypads.COLOR.BLACK     = Color(0,0,0)
	bKeypads.COLOR.WHITE     = Color(255,255,255)
	bKeypads.COLOR.RED       = Color(255,0,0)
	bKeypads.COLOR.GREEN     = Color(0,255,0)
	bKeypads.COLOR.GMODBLUE  = Color(0,150,255)
	bKeypads.COLOR.SLATE     = Color(32,32,32)
	bKeypads.COLOR.LCDSCREEN = Color(84,104,91)
	bKeypads.COLOR.PINK      = Color(250,0,255)

bKeypads.BODYGROUP = {}
	bKeypads.BODYGROUP.KEYPAD       = 0
	bKeypads.BODYGROUP.INTERNALS    = 1
	bKeypads.BODYGROUP.CAMERA       = 2
	bKeypads.BODYGROUP.LED_TOP      = 3
	bKeypads.BODYGROUP.LED_BOTTOM   = 4
	bKeypads.BODYGROUP.KEYCARD_SLOT = 5
	bKeypads.BODYGROUP.PANEL        = 6

bKeypads.SCANNING_STATUS = {}
	bKeypads.SCANNING_STATUS.LOADING  = 0
	bKeypads.SCANNING_STATUS.IDLE     = 1
	bKeypads.SCANNING_STATUS.SCANNING = 2
	bKeypads.SCANNING_STATUS.GRANTED  = 3
	bKeypads.SCANNING_STATUS.DENIED   = 4

bKeypads.AUTH_MODE = {}
	bKeypads.AUTH_MODE.PIN     = 1
	bKeypads.AUTH_MODE.FACEID  = 2
	bKeypads.AUTH_MODE.KEYCARD = 3

bKeypads.ACCESS_TYPE = {}
bKeypads.ACCESS_GROUP = {}
	bKeypads.ACCESS_GROUP.VERSION               = 1

	bKeypads.ACCESS_TYPE.WHITELIST              = 2
	bKeypads.ACCESS_TYPE.BLACKLIST              = 3

	bKeypads.ACCESS_GROUP.PAYMENT               = 4

	bKeypads.ACCESS_GROUP.CUSTOM_TEAM_GROUP     = 5
	bKeypads.ACCESS_GROUP.CUSTOM_LUA_FUNCTION   = 6
	bKeypads.ACCESS_GROUP.CUSTOM_ADDON_FUNCTION = 18

	bKeypads.ACCESS_GROUP.PLAYER                = 7
	bKeypads.ACCESS_GROUP.USERGROUP             = 8
	bKeypads.ACCESS_GROUP.TEAM                  = 9
	bKeypads.ACCESS_GROUP.KEYCARD_LEVEL         = 10
	bKeypads.ACCESS_GROUP.SUPERIOR_KEYCARDS     = 11
	bKeypads.ACCESS_GROUP.STEAM_FRIENDS         = 12

	bKeypads.ACCESS_GROUP.DARKRP_JOB_CATEGORY   = 13
	bKeypads.ACCESS_GROUP.DARKRP_JOB            = 14
	bKeypads.ACCESS_GROUP.DARKRP_DOOR_GROUP     = 15
	bKeypads.ACCESS_GROUP.DARKRP_DEMOTE_GROUP   = 16
	bKeypads.ACCESS_GROUP.DARKRP_AGENDA_GROUP   = 17

	bKeypads.ACCESS_GROUP.HELIX_FLAG            = 19

	bKeypads.ACCESS_GROUP.MRS_RANK              = 20
	bKeypads.ACCESS_GROUP.MRS_SUPERIOR_RANKS    = 21

	bKeypads.ACCESS_GROUP.LAST = math.max(bKeypads.ACCESS_GROUP[table.GetWinningKey(bKeypads.ACCESS_GROUP)], bKeypads.ACCESS_TYPE[table.GetWinningKey(bKeypads.ACCESS_TYPE)])
	bKeypads.ACCESS_GROUP.BITS = 32

bKeypads.ACCESS_GROUP_BOOL = {
	[bKeypads.ACCESS_GROUP.STEAM_FRIENDS] = true,
	[bKeypads.ACCESS_GROUP.SUPERIOR_KEYCARDS] = true,
	[bKeypads.ACCESS_GROUP.MRS_SUPERIOR_RANKS] = true,
}

bKeypads.ACCESS_TYPES = { bKeypads.ACCESS_TYPE.WHITELIST, bKeypads.ACCESS_TYPE.BLACKLIST }
bKeypads.ACCESS_TYPES_REVERSE = { bKeypads.ACCESS_TYPE.BLACKLIST, bKeypads.ACCESS_TYPE.WHITELIST }
bKeypads.ACCESS_TYPES_BOOL = { true, false }

bKeypads.MODEL = {}
	bKeypads.MODEL.KEYPAD        = "models/bkeypads/keypad_3.0.0.mdl"
	bKeypads.MODEL.KEYCARD       = "models/bkeypads/keycard.mdl"
	bKeypads.MODEL.KEYCARD_HANDS = "models/bkeypads/c_keycard.mdl"

util.PrecacheModel(bKeypads.MODEL.KEYPAD)
util.PrecacheModel(bKeypads.MODEL.KEYCARD)
util.PrecacheModel(bKeypads.MODEL.KEYCARD_HANDS)

--## Printing ##--

bKeypads.PRINT_TYPE_NEUTRAL = Color(0,255,255)
bKeypads.PRINT_TYPE_GOOD    = Color(0,255,0)
bKeypads.PRINT_TYPE_BAD     = Color(255,0,0)
bKeypads.PRINT_TYPE_WARN    = Color(255,255,0)
bKeypads.PRINT_TYPE_SPECIAL = Color(255,0,255)

function bKeypads:print(txt, print_type, print_prefix)
	MsgC(print_type or bKeypads.PRINT_TYPE_NEUTRAL, "[bKeypads] " .. (print_prefix and ("[" .. print_prefix .. "] ") or ""), bKeypads.COLOR.WHITE, txt, "\n")
end

function bKeypads:chat(txt, print_type, print_prefix)
	chat.AddText(print_type or bKeypads.PRINT_TYPE_NEUTRAL, "[bKeypads] " .. (print_prefix and ("[" .. print_prefix .. "] ") or ""), bKeypads.COLOR.WHITE, txt)
end

bKeypads:print("Hello, world!")

--## License ##--

if SERVER then
	bKeypads.License = include("bkeypads/license.lua")
	if not bKeypads.License then return end
	bKeypads:print("Version " .. bKeypads.License.Version, bKeypads.PRINT_TYPE_SPECIAL)
	bKeypads:print("Licensed to " .. util.SteamIDFrom64(bKeypads.License.SteamID64), bKeypads.PRINT_TYPE_SPECIAL)
end

--## Guaranteed Hooks ##--

do
	local _InitPostEntity = {}
	function bKeypads:InitPostEntity(f)
		if bKeypads_InitPostEntity then
			f()
		else
			table.insert(_InitPostEntity, f)
		end
	end
	local function InitPostEntity()
		hook.Remove("InitPostEntity", "bKeypads.InitPostEntity")
		if bKeypads_InitPostEntity then return end

		bKeypads_InitPostEntity = true
		for _, f in ipairs(_InitPostEntity) do f() end
		_InitPostEntity = {}
	end
	hook.Add("InitPostEntity", "bKeypads.InitPostEntity", InitPostEntity)
	timer.Simple(0.1, InitPostEntity)
end

do
	local _Initialize = {}
	function bKeypads:GMInitialize(f)
		if bKeypads_Initialize then
			f()
		else
			table.insert(_Initialize, f)
		end
	end
	local function Initialize()
		bKeypads_Initialize = true
		for _, f in ipairs(_Initialize) do f() end
		_Initialize = {}
	end
	hook.Add("Initialize", "bKeypads.Initialize", Initialize)
end

do
	local _postLoadCustomDarkRPItems = {}
	function bKeypads:postLoadCustomDarkRPItems(f)
		if bKeypads_postLoadCustomDarkRPItems then
			f()
		end

		table.insert(_postLoadCustomDarkRPItems, f)
	end

	local function postLoadCustomDarkRPItems()
		bKeypads_postLoadCustomDarkRPItems = true
		for _, f in ipairs(_postLoadCustomDarkRPItems) do f() end

		hook.Remove("PlayerInitialSpawn", "bKeypads.postLoadCustomDarkRPItems")
	end
	hook.Add("loadCustomDarkRPItems", "bKeypads", function() timer.Simple(1, postLoadCustomDarkRPItems) end)
	hook.Add("postLoadCustomDarkRPItems", "bKeypads", function() timer.Simple(1, postLoadCustomDarkRPItems) end)
	hook.Add("PlayerInitialSpawn", "bKeypads.postLoadCustomDarkRPItems", postLoadCustomDarkRPItems)
	hook.Add("Initialize", "bKeypads.postLoadCustomDarkRPItems", postLoadCustomDarkRPItems)

	local function applyDarkRPConfig(_GAMEMODE)
		if not _GAMEMODE.Config then return end
		_GAMEMODE.Config.DisallowDrop["bkeycard"] = true
		_GAMEMODE.Config.noStripWeapons["bkeycard"] = true

		_GAMEMODE.Config.allowedProperties["bkeypads"] = true

		_GAMEMODE.Config.PocketBlacklist["keypad"] = true
		_GAMEMODE.Config.PocketBlacklist["bkeypad"] = true
		_GAMEMODE.Config.PocketBlacklist["bkeycard_pickup"] = true
	end
	local function safeApplyDarkRPConfig()
		local _GAMEMODE = GM or GAMEMODE
		if not DarkRP or not _GAMEMODE or not _GAMEMODE.Config then return end
		pcall(applyDarkRPConfig, _GAMEMODE)
	end
	bKeypads:postLoadCustomDarkRPItems(safeApplyDarkRPConfig)
	safeApplyDarkRPConfig()
end

if SERVER then
	function bKeypads:nextTick(func)
		timer.Simple(0, func)
	end
else
	local nextTick
	function bKeypads:nextTick(func)
		nextTick = nextTick or {}
		table.insert(nextTick, func)
	end
	hook.Add("Tick", "bKeypads.Tick", function()
		if not nextTick then return end
		local execNextTick = nextTick
		nextTick = nil
		for _, func in ipairs(execNextTick) do func() end
	end)
end

--## Config ##--

do
	for name in pairs(hook.GetTable()["bKeypads.ConfigUpdated"] or {}) do hook.Remove("bKeypads.ConfigUpdated", name) end

	function bKeypads:SetConfig(config)
		bKeypads.Config = config

		if bKeypads_ConfigAutoRefresh then
			hook.Run("bKeypads.ConfigUpdated")
			bKeypads:print("Config was updated", bKeypads.PRINT_TYPE_SPECIAL)
		else
			bKeypads_ConfigAutoRefresh = true
			bKeypads:print("Config loaded successfully", bKeypads.PRINT_TYPE_SPECIAL)
		end
	end

	function bKeypads:LoadConfig()
		bKeypads.Config = nil

		if SERVER and not bKeypads.Config then
			bKeypads.simplerr = simplerr or include("bkeypads/lib/simplerr.lua")
			if bKeypads.simplerr then
				local succ, err = bKeypads.simplerr.runFile("bkeypads_config.lua")
				if not succ then
					MsgC("\n")
					ErrorNoHalt(err or "[ERROR] UNKNOWN error in \"bkeypads_config.lua\"")
				end
			end
		end

		include("bkeypads_config.lua")
	end
	bKeypads:LoadConfig()

	if not bKeypads.Config then
		MsgC("\n")
		bKeypads:print("Your config file has a Lua error! Aborting.\n", bKeypads.PRINT_TYPE_BAD, "ERROR")
		return
	else
		bKeypads:postLoadCustomDarkRPItems(bKeypads.LoadConfig)
	end
end

--## Load files ##--

bKeypads:print("Loading files...")

AddCSLuaFile("bkeypads_config.lua")
AddCSLuaFile("bkeypads_custom_access.lua")

includeSH "bkeypads/sh_lang.lua"
includeSV "bkeypads/sv_keypads.lua"
includeSH "bkeypads/sh_keypad_data.lua"
includeSH "bkeypads/sh_context_menu.lua"

includeCS "bkeypads/cl_settings.lua"
includeCS "bkeypads/cl_fonts.lua"
includeCS "bkeypads/cl_ui.lua"
includeCS "bkeypads/cl_performance.lua"

includeSH "bkeypads/sh_permissions.lua"

includeSV "bkeypads/sv_networking.lua"

includeSH "bkeypads/sh_economy.lua"
includeSH "bkeypads/sh_keycards.lua"
includeSH "bkeypads/sh_keycard_inventory.lua"
includeSH "bkeypads/sh_keypad_images.lua"
includeSH "bkeypads/sh_keypad_linking.lua"
includeSH "bkeypads/sh_access_logs.lua"
includeSH "bkeypads/sh_fading_doors.lua"
includeSH "bkeypads/sh_map_linking.lua"
includeSH "bkeypads/sh_notifications.lua"
includeSH "bkeypads/sh_stool.lua"
includeSH "bkeypads/sh_destruction.lua"

includeCS "bkeypads/cl_keycard_textures.lua"
includeCS "bkeypads/cl_keypad_esp.lua"
includeCS "bkeypads/cl_properties_display.lua"
includeCS "bkeypads/cl_fake_angles.lua"
includeCS "bkeypads/cl_health_display.lua"
includeCS "bkeypads/cl_tutorial.lua"
includeSV "bkeypads/cl_tutorial_scenes.lua"

bKeypads.md5    = includeCS "bkeypads/lib/md5.lua"
bKeypads.clip   = includeCS "bkeypads/lib/clip.lua"
bKeypads.ease   = ease or ( includeSH "bkeypads/lib/ease.lua" )
bKeypads.markup = Either(SERVER, bKeypads.markup, includeCS "bkeypads/lib/markup.lua")

includeSH "bkeypads/sh_custom_access.lua"

if file.Exists("bkeypads/sh_cracker.lua", "LUA") then
	includeSH "bkeypads/sh_cracker.lua"
end

includeSV "bkeypads/sv_drm.lua"

bKeypads_Ready = true
hook.Run("bKeypads.Ready")