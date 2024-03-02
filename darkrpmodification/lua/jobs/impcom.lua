AddCSLuaFile()

DarkRP.createCategory{
    name = "Imperial Command",
    categorises = "jobs",
    startExpanded = true,
    color = Color(255, 255, 255, 255),
    canSee = function(ply) return true end,
    sortOrder = 13,
}

-- TEAM_MCMD = DarkRP.createJob("Marshal Commander", {
--     color = Color(0, 0, 0, 255),
--     model = {"models/halves/arcconcept/carnage.mdl"},
--     description = [[You are the Marshall Commander.]],
--     weapons = {
--         "sc_tranceiver",
--         "cloaking-infinite",

--         "masita_dc17mi",
--         "masita_dc17mi_sniper",
--         "arccw_dual_dh17"
--     },
--     command = "MCMD",
--     max = 1,
--     salary = 500,
--     admin = 0,
--     vote = false,
--     hasLicense = false,
--     canDemote = true,
--     category = "Imperial Command",
--     PlayerSpawn = EYNJobStats( 1000, 500 ),
--     sortOrder = 0,
-- })

TEAM_GGEN = DarkRP.createJob("Grand General", {
    color = Color(0, 140, 0, 255),
    model = {
        "models/nada/pms/male/GrandGeneral.mdl",
        "models/nada/pms/female/GrandGeneral.mdl"
    },
    description = [[You are the Grand General.]],
    weapons = {
        "sc_tranceiver",
        "arccw_dual_dh17"
    },
    command = "GGEN",
    max = 1,
    salary = 500,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Imperial Command",
    PlayerSpawn = EYNJobStats( 1000, 500 ),
    sortOrder = 1,
})

TEAM_GADM = DarkRP.createJob("Grand Admiral", {
    color = Color(0, 0, 255, 255),
    model = {
        "models/nada/pms/male/grandadmiral.mdl",
        "models/nada/pms/female/grandadmiral.mdl"
    },
    description = [[You are the Grand Admiral.]],
    weapons = {
        "thrawn_swep",
        "sc_tranceiver",

        "masita_e11sx",
        "masita_e11d_ext",
        "masita_dt57"
    },
    command = "GADM",
    max = 1,
    salary = 500,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Imperial Command",
    PlayerSpawn = EYNJobStats( 1000, 500 ),
    sortOrder = 2,
})

-- TEAM_EY = DarkRP.createJob("Evil Yoda", {
--     color = Color(0, 112, 0, 255),
--     model = {"models/tfa/comm/gg/pm_sw_yoda.mdl"},
--     description = [[You are Evil Yoda and Mascot of the server.]],
--     modelScale = 0.7,
--     weapons = {
-- 		"swep_yoda",
-- 		"seal6-tac-insert",
-- 		"sc_tranceiver"
-- 	},
--     command = "EY",
--     max = 1,
--     salary = 1000,
--     admin = 0,
--     vote = false,
--     hasLicense = false,
--     canDemote = true,
--     category = "Imperial Command",
--     PlayerSpawn = EYNJobStats( 2000, 1000 ),
-- 	sortOrder = 0
-- })

TEAM_IRC = DarkRP.createJob("Imperial Councilor", {
    color = Color(215, 175, 0),
    model = {
        "models/nada/pms/male/warlord.mdl",
        "models/nada/pms/female/warlord.mdl"
    },
    description = [[You are a member of the Imperial Ruling Councilor.]],
    modelScale = 1.0,
    weapons = {
        "sc_tranceiver"
    },
    command = "IRC",
    max = 0,
    salary = 500,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Imperial Command",
    PlayerSpawn = EYNJobStats( 2000, 1000 ),
    sortOrder = 96,
})

TEAM_GV = DarkRP.createJob("Grand Vizier", {
    color = Color(215, 175, 0),
    model = {
        "models/nada/pms/male/warlord.mdl",
        "models/nada/pms/female/warlord.mdl"
    },
    description = [[You are the Grand Vizier.]],
    modelScale = 1.0,
    weapons = {
        "sc_tranceiver"
    },
    command = "GV",
    max = 1,
    salary = 500,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Imperial Command",
    PlayerSpawn = EYNJobStats( 2000, 1000 ),
    sortOrder = 97,
})

TEAM_LV = DarkRP.createJob("Lord Vader", {
    color = Color(0, 0, 255, 255),
    model = {"models/nanb_darth_vader.mdl"},
    description = [[You are Darth Vader.]],
    modelScale = 1.08,
    weapons = {
        "swep_vader",
        "sc_tranceiver"
    },
    command = "LV",
    max = 1,
    salary = 500,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Imperial Command",
    PlayerSpawn = EYNJobStats( 2000, 1000 ),
    sortOrder = 98,
})

TEAM_EMP = DarkRP.createJob("Emperor Palpatine", {
    color = Color(0, 0, 0, 255),
    model = {"models/player/emperor_palpatine.mdl"},
    description = [[You are The Emperor.]],
    modelScale = 0.95,
    weapons = {
        "swep_palpatine",
        "sc_tranceiver"
    },
    command = "EMP",
    max = 1,
    salary = 750,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Imperial Command",
    PlayerSpawn = EYNJobStats( 3000, 2000 ),
    sortOrder = 99,
})