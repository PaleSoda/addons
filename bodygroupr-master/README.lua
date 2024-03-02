-- Arizard's bodyGroupr
-- How to edit jobs.lua

--Simple Example
TEAM_CITIZEN = DarkRP.createJob("Citizen", {
	color = Color(20, 150, 20, 255),
	model = {
		"models/player/zelpa/male_04.mdl",
	},
	description = [[The Citizen is the most basic level of society you can hold besides being a hobo. You have no specific role in city life.]],
	weapons = {},
	command = "citizen",
	max = 0,
	salary = GAMEMODE.Config.normalsalary,
	admin = 0,
	vote = false,
	hasLicense = false,
	candemote = false,

	-- !!! LOOK HERE !!! --

	skins = {4,5,6}, -- example configuration
	bodygroups = {
		["torso"] = {0,2,3},
		["legs"] = {0,1,2,3,4,5},
		["beanies"] = {0,1,2},
		["glasses"] = {0,1}, -- these are all examples, please don't actually copy-paste them because they might not work.
	} -- check below for playermodels that support this addon, and use the sandbox playermodel selector to check bodygroups.

	armorbodygroups = { -- configure armor to give players here (for Prior). first number in the pair is the bodygroup, second number is how much armor to give.
		-- eg. in this case, setting the "torso" bodygroup to 2 gives the player 30 armor.
		-- Note that armor is only given on spawn, and is reduced if the player takes off the bodygroup.
		["torso"] = { {0,10},{1,20}, {2,30} },
		["legs"] = {{0,12},{1,13},{2,14}},
	}

})

-- some supported playermodels:

	-- http://steamcommunity.com/sharedfiles/filedetails/?id=280384240 -- Enhanced Citizens Playermodels [Zelpa]
	-- http://steamcommunity.com/sharedfiles/filedetails/?id=283815805 -- Halo 3 Spartan Playermodels [Vipes]
	-- http://steamcommunity.com/sharedfiles/filedetails/?id=104491619 -- Metropolice Pack [DPotatoMan]