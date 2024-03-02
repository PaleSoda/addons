bKeypads.Cracker = {}

if SERVER then
	bKeypads.Cracker.License = include("bkeypads/cracker_license.lua")
	if not bKeypads.Cracker.License then return end
	bKeypads:print("Version " .. bKeypads.Cracker.License.Version, bKeypads.PRINT_TYPE_SPECIAL, "CRACKER")
	bKeypads:print("Licensed to " .. util.SteamIDFrom64(bKeypads.Cracker.License.SteamID64), bKeypads.PRINT_TYPE_SPECIAL, "CRACKER")
	
	resource.AddWorkshop("2328355906")

	include("bkeypads/sv_cracker_drm.lua")
	include("bkeypads/sv_permissions.lua")

	AddCSLuaFile("bkeypads/cl_cracker.lua")
	AddCSLuaFile("bkeypads_cracker_config.lua")
else
	include("bkeypads/cl_cracker.lua")
end

--## Fonts ##--

if CLIENT then
	surface.CreateFont("bKeypads.Cracker", {
		size = 48,
		font = "8BIT WONDER"
	})

	surface.CreateFont("bKeypads.Cracker.Small", {
		size = 32,
		font = "8BIT WONDER"
	})
end

--## Materials ##--

if CLIENT then
	bKeypads.Cracker.Materials = {}
	bKeypads.Cracker.Materials.SCREEN_BLUE  = Material("bkeypads/keypad_cracker_screen_blue.png", "smooth")
	bKeypads.Cracker.Materials.SCREEN_RED   = Material("bkeypads/keypad_cracker_screen_red.png", "smooth")
	bKeypads.Cracker.Materials.SCREEN_GREEN = Material("bkeypads/keypad_cracker_screen_green.png", "smooth")

	bKeypads.Cracker.CrackingEmotes = { "neutral", "default", "happy", "surprised", "success", "confused", "sorry" }
end

--## Load Config ##--

bKeypads_Cracker_ConfigAutoRefresh = nil
function bKeypads.Cracker:SetConfig(conf)
	bKeypads.Cracker.Config = conf
	bKeypads.Cracker:ProcessConfig()

	if bKeypads_Cracker_ConfigAutoRefresh then
		hook.Run("bKeypads.Cracker.ConfigUpdated")
		bKeypads:print("Config was updated", bKeypads.PRINT_TYPE_SPECIAL, "CRACKER")
	else
		bKeypads_Cracker_ConfigAutoRefresh = true
		bKeypads:print("Config loaded successfully", bKeypads.PRINT_TYPE_SPECIAL, "CRACKER")
	end
end

function bKeypads.Cracker:LoadConfig()
	bKeypads.Cracker.Config = nil

	if SERVER and bKeypads.simplerr then
		local succ, err = bKeypads.simplerr.runFile("bkeypads_cracker_config.lua")
		if not succ then
			MsgC("\n")
			ErrorNoHalt(err or "[ERROR] UNKNOWN error in \"bkeypads_cracker_config.lua\"")
		end
	end
	include("bkeypads_cracker_config.lua")
end

function bKeypads.Cracker:ProcessConfig()
	bKeypads.Cracker.Settings = {}

	if isnumber(bKeypads.Cracker.Config.CrackTime) then
		bKeypads.Cracker.Settings.CrackTime = {bKeypads.Cracker.Config.CrackTime, bKeypads.Cracker.Config.CrackTime}
	elseif istable(bKeypads.Cracker.Config.CrackTime) and #bKeypads.Cracker.Config.CrackTime == 1 then
		bKeypads.Cracker.Settings.CrackTime = {bKeypads.Cracker.Config.CrackTime[1], bKeypads.Cracker.Config.CrackTime[1]}
	elseif istable(bKeypads.Cracker.Config.CrackTime) and #bKeypads.Cracker.Config.CrackTime == 2 and isnumber(bKeypads.Cracker.Config.CrackTime[1]) and isnumber(bKeypads.Cracker.Config.CrackTime[2]) then
		bKeypads.Cracker.Settings.CrackTime = {math.min(unpack(bKeypads.Cracker.Config.CrackTime)), math.max(unpack(bKeypads.Cracker.Config.CrackTime))}
	else
		bKeypads.Cracker.Settings.CrackTime = {20, 30}
	end

	bKeypads.Cracker.Settings.SpecialCrackTimes = {
		Teams = {},
		Usergroups = {},
		Functions = {}
	}
	for _, specialCrackTime in pairs(bKeypads.Cracker.Config.SpecialCrackTimes) do
		if #specialCrackTime ~= 2 then continue end

		local tbl
		if isstring(specialCrackTime[1]) then
			tbl = bKeypads.Cracker.Settings.SpecialCrackTimes.Usergroups
		elseif isnumber(specialCrackTime[1]) then
			tbl = bKeypads.Cracker.Settings.SpecialCrackTimes.Teams
		elseif isfunction(specialCrackTime[1]) then
			tbl = bKeypads.Cracker.Settings.SpecialCrackTimes.Functions
		else
			continue
		end

		local bounds = specialCrackTime[2]
		if isnumber(bounds) then
			bounds = {bounds, bounds}
		elseif istable(bounds) then
			if #bounds == 0 then continue end
			if #bounds == 1 then bounds[2] = bounds[1] end
			if not isnumber(bounds[1]) or not isnumber(bounds[2]) then continue end
			bounds = { math.min(unpack(bounds)), math.max(unpack(bounds)) }
		elseif not isfunction(bounds) then
			continue
		end
		
		if tbl == bKeypads.Cracker.Settings.SpecialCrackTimes.Functions then
			table.insert(tbl, bounds)
		else
			tbl[specialCrackTime[1]] = bounds
		end
	end

	if bKeypads.Cracker.Config.Damage.Enable and not table.IsEmpty(bKeypads.Cracker.Config.Damage.DamageTypeWhitelist) then
		bKeypads.Cracker.Settings.DamageTypeWhitelist = {}
		for _, dmg in pairs(bKeypads.Cracker.Config.Damage.DamageTypeWhitelist) do
			if isnumber(dmg) then
				table.insert(bKeypads.Cracker.Settings.DamageTypeWhitelist, dmg)
			end
		end
		bKeypads.Cracker.Settings.DamageTypeWhitelist = not table.IsEmpty(bKeypads.Cracker.Settings.DamageTypeWhitelist) and bit.bor(unpack(bKeypads.Cracker.Settings.DamageTypeWhitelist)) or nil

		bKeypads.Cracker.Settings.DamageTypeBlacklist = {}
		for _, dmg in pairs(bKeypads.Cracker.Config.Damage.DamageTypeBlacklist) do
			if isnumber(dmg) then
				table.insert(bKeypads.Cracker.Settings.DamageTypeBlacklist, dmg)
			end
		end
		bKeypads.Cracker.Settings.DamageTypeBlacklist = not table.IsEmpty(bKeypads.Cracker.Settings.DamageTypeBlacklist) and bit.bor(unpack(bKeypads.Cracker.Settings.DamageTypeBlacklist)) or nil
	end

	if not table.IsEmpty(bKeypads.Cracker.Config.CrackerPhrases) then
		bKeypads.Cracker.Settings.CrackerPhrases = {}
		for _, phrase in pairs(bKeypads.Cracker.Config.CrackerPhrases) do
			if not isstring(phrase) then continue end
			phrase = phrase:gsub("[^A-Za-z0-9 ]", "")
			if #phrase > 0 then
				table.insert(bKeypads.Cracker.Settings.CrackerPhrases, phrase)
			end
		end
	end
	if not bKeypads.Cracker.Settings.CrackerPhrases or table.IsEmpty(bKeypads.Cracker.Settings.CrackerPhrases) then
		bKeypads.Cracker.Settings.CrackerPhrases = { "CRACKING" }
	end

	bKeypads.Cracker.Settings.FailChance = 0
	if isnumber(bKeypads.Cracker.Config.FailChance) then
		bKeypads.Cracker.Settings.FailChance = math.Clamp(bKeypads.Cracker.Config.FailChance, 0, 1)
	end

	bKeypads.Cracker.Settings.CrackDistance = 2500
	if isnumber(bKeypads.Cracker.Config.FailChance) then
		bKeypads.Cracker.Settings.FailChance = math.max(bKeypads.Cracker.Config.FailChance, 0)
	end

	if CLIENT then
		if bKeypads.Cracker.Config.SeeDroppedCrackerThroughWalls then
			hook.Add("PreDrawViewModel", "bKeypads.Cracker.PreDrawViewModel", bKeypads.Cracker.PreDrawViewModel)
			hook.Add("PostDrawTranslucentRenderables", "bKeypads.Cracker.PostDrawTranslucentRenderables", bKeypads.Cracker.PostDrawTranslucentRenderables)
		else
			hook.Remove("PreDrawViewModel", "bKeypads.Cracker.PreDrawViewModel")
			hook.Remove("PostDrawTranslucentRenderables", "bKeypads.Cracker.PostDrawTranslucentRenderables")
		end
	end

	if DarkRP and DarkRP.createShipment and not bKeypads_Cracker_InitF4 then
		bKeypads_Cracker_InitF4 = true
		if bKeypads.Cracker.Config.F4Cracker.EnableShipment then
			local conf = table.Copy(bKeypads.Cracker.Config.F4Cracker.Shipment)
			conf.entity = "bkeypads_cracker"
			conf.model = "models/bkeypads/cracker.mdl"
			conf.separate = false
			conf.pricesep = nil
			conf.noship = nil

			conf.label = conf.label or "Keypad Cracker"
			DarkRP.createShipment("Keypad Cracker (Shipment)", conf)
		end
		if bKeypads.Cracker.Config.F4Cracker.EnableSingle then
			local conf = table.Copy(bKeypads.Cracker.Config.F4Cracker.Single)
			conf.entity = "bkeypads_cracker"
			conf.model = "models/bkeypads/cracker.mdl"
			conf.noship = true
			conf.separate = true
			conf.pricesep = conf.price or conf.pricesep or nil
			conf.price = conf.price or conf.pricesep or nil

			conf.label = conf.label or "Keypad Cracker"
			DarkRP.createShipment("Keypad Cracker", conf)
		end
	end
end

bKeypads.Cracker:LoadConfig()

if not bKeypads.Cracker.Config then
	MsgC("\n")
	bKeypads:print("Your KEYPAD CRACKER config file has a Lua error! Aborting.\n", bKeypads.PRINT_TYPE_BAD, "ERROR")
	return
else
	bKeypads:postLoadCustomDarkRPItems(bKeypads.Cracker.LoadConfig)
end

--## Sounds ##--

bKeypads.Cracker.Sounds = {
	alarm = {
		path = "bkeypads/cracker/alarm.mp3",
		duration = 0.5526562333107
	},
	error = {
		path = "bkeypads/cracker/error.mp3",
		duration = 1.1847916841507
	},
	success = {
		path = "bkeypads/cracker/success.mp3",
		duration = 0.46987500786781
	},
	typing = {
		{
			path = "bkeypads/cracker/typing_001.mp3",
			duration = 2.2309896945953
		},
		{
			path = "bkeypads/cracker/typing_002.mp3",
			duration = 10
		},
	},
	warning = {
		path = "bkeypads/cracker/warning.mp3",
		duration = 0.62650001049042
	},
	charge = {
		path = "bkeypads/cracker/charge.mp3",
		duration = 0.63439285755157
	},
	whirr = {
		path = "bkeypads/cracker/whirr.mp3",
		duration = 1.4367187023163
	},
	hello = {
		path = "bkeypads/cracker/hello.mp3",
		duration = 0.31719642877579
	},
	critical = {
		path = "bkeypads/cracker/critical.mp3",
		duration = 0.59707140922546
	},
}

for _, snd in ipairs(bKeypads.Cracker.Sounds) do
	if snd.path then
		snd.sound = Sound(snd.path)
	else
		for _, snd in ipairs(snd) do
			snd.sound = Sound(snd.path)
		end
	end
end

--## Utility ##--

function bKeypads.Cracker:GetCrackingPhrase()
	return bKeypads.Cracker.Settings.CrackerPhrases[math.random(1, #bKeypads.Cracker.Settings.CrackerPhrases)]
end

function bKeypads.Cracker:RollFailDice()
	if bKeypads.Cracker.Config.FailChance == 0 then return false end
	if bKeypads.Cracker.Config.FailChance == 1 then return true end
	return math.Rand(0, 1) <= bKeypads.Cracker.Settings.FailChance
end

function bKeypads.Cracker:CheckDamageType(dmg)
	if bKeypads.Cracker.Settings.DamageTypeWhitelist then
		return bKeypads.Cracker.Settings.DamageTypeWhitelist[dmg] or false
	else
		return true
	end
end

-- TODO bLogs support