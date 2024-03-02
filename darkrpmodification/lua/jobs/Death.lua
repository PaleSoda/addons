AddCSLuaFile()

DarkRP.createCategory{
    name = "DeathTrooper",
    categorises = "jobs",
    startExpanded = true,
    color = Color(0, 0, 0),
    canSee = function(ply) return true end,
    sortOrder = 6,
}

TEAM_DT = DarkRP.createJob("DeathTrooper", {
    color = Color(0, 0, 0),
    model = {"models/bunny/white_deathtroopers/white_deathtrooper_trooper.mdl", "models/npc/markus/custom/characters/hero/deathtrooper/female/deathtrooper_female_01/deathtrooper_01_female_mesh.mdl"},
    description = [[You are a member of DeathTrooper.]],
    weapons = {"arccw_thermal_grenade", "masita_e11d", "masita_t21", "sc_tranceiver"},
    command = "DT",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "DeathTrooper",
    PlayerSpawn = EYNJobStats( 300, 150 ),
    sortOrder = 1,
})

TEAM_DTS = DarkRP.createJob("DeathTrooper Sniper", {
    color = Color(0, 0, 0),
    model = {"models/bunny/white_deathtroopers/white_deathtrooper_sergeant.mdl", "models/npc/markus/custom/characters/hero/deathtrooper/female/deathtrooper_female_01/deathtrooper_01_female_mesh.mdl"},
    description = [[You are a member of DeathTrooper Specilised As A Sniper.]],
    weapons = {"arccw_thermal_grenade", "masita_e11d", "masita_dlt19x", "sc_tranceiver"},
    command = "DTS",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "DeathTrooper",
    PlayerSpawn = EYNJobStats( 300, 150 ),
    sortOrder = 2,
})

TEAM_DTH = DarkRP.createJob("DeathTrooper Heavy", {
    color = Color(0, 0, 0),
    model = {"models/bunny/white_deathtroopers/white_deathtrooper_sergeant.mdl", "models/npc/markus/custom/characters/hero/deathtrooper/female/deathtrooper_female_01/deathtrooper_01_female_mesh.mdl"},
    description = [[You are a member of DeathTrooper Specilised As A Heavy.]],
    weapons = {"arccw_thermal_grenade", "masita_e11d", "masita_dlt19", "sc_tranceiver"},
    command = "DTH",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "DeathTrooper",
    PlayerSpawn = EYNJobStats( 300, 150 ),
    sortOrder = 3,
})

TEAM_DTB = DarkRP.createJob("DeathTrooper Breacher", {
    color = Color(0, 0, 0),
    model = {"models/bunny/white_deathtroopers/white_deathtrooper_officer.mdl", "models/npc/markus/custom/characters/hero/deathtrooper/female/deathtrooper_female_01/deathtrooper_01_female_mesh.mdl"},
    description = [[You are a member of DeathTrooper Specilised As A Breacher.]],
    weapons = {"arccw_thermal_grenade","arccw_flash_grenade", "masita_e11d", "masita_sx21", "sc_tranceiver"},
    command = "DTB",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "DeathTrooper",
    PlayerSpawn = EYNJobStats( 300, 150 ),
    sortOrder = 4,
})

TEAM_DTC = DarkRP.createJob("DeathTrooper Commander", {
    color = Color(0, 0, 0),
    model = {"models/bunny/white_deathtroopers/white_deathtrooper_lieutenant.mdl", "models/npc/markus/custom/characters/hero/deathtrooper/female/deathtrooper_female_01/deathtrooper_01_female_mesh.mdl"},
    description = [[You are a member of DeathTrooper Command.]],
    weapons = {"arccw_thermal_grenade","arccw_flash_grenade", "masita_e11d", "masita_t21", "sc_tranceiver"},
    command = "DTC",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "DeathTrooper",
    PlayerSpawn = EYNJobStats( 500, 150 ),
    sortOrder = 5,
    
})