AddCSLuaFile()

DarkRP.createCategory{
    name = "Nova Corp",
    categorises = "jobs",
    startExpanded = true,
    color = Color(255, 255, 51),
    canSee = function(ply) return true end,
    sortOrder = 4,
}

TEAM_Nova = DarkRP.createJob("Nova Trooper", {
    color = Color(255, 255, 51),
    model = {"models/player/ven/tk_novatrooper_02/tk_novatrooper.mdl", "models/xozz/hydra/inquisitor/female/inqfemale_07.mdl"},
    description = [[You are a Nova Police Trooper.]],
    weapons = {"masita_dlt19", "masita_rk3_stun", "arrest_stick", "unarrest_stick"},
    command = "nova",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Nova Corp",
    PlayerSpawn = EYNJobStats( 250, 100 ),
    sortOrder = 0,
})

TEAM_Novademo = DarkRP.createJob("Nova Demolitions", {
    color = Color(255, 255, 51),
    model = {"models/player/ven/tk_novatrooper_02/tk_novatrooper.mdl", "models/xozz/hydra/inquisitor/female/inqfemale_07.mdl"},
    description = [[You are a Nova Police Trooper.]],
    weapons = {"masita_dlt19", "masita_rk3_stun", "arccw_sw_rocket_smartlauncher", "arrest_stick", "unarrest_stick"},
    command = "novademo",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Nova Corp",
    PlayerSpawn = EYNJobStats( 250, 150 ),
    sortOrder = 1,
})

TEAM_Novariot = DarkRP.createJob("Nova Riot", {
    color = Color(255, 255, 51),
    model = {"models/player/ven/tk_novatrooper_02/tk_novatrooper.mdl", "models/xozz/hydra/inquisitor/female/inqfemale_07.mdl"},
    description = [[You are a Nova Police Trooper.]],
    weapons = {"masita_dlt19", "masita_rk3_stun", "masita_empireshield", "arrest_stick", "unarrest_stick", "arccw_flash_grenade", "masita_melee_riot"},
    command = "novariot",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Nova Corp",
    PlayerSpawn = EYNJobStats( 300, 150 ),
    sortOrder = 2,
})

TEAM_Novabreach = DarkRP.createJob("Nova Breacher", {
    color = Color(255, 255, 51),
    model = {"models/player/ven/tk_novatrooper_02/tk_novatrooper.mdl", "models/xozz/hydra/inquisitor/female/inqfemale_07.mdl"},
    description = [[You are a Nova Police Trooper.]],
    weapons = {"masita_dlt19", "masita_rk3_stun", "masita_empireshield", "arrest_stick", "unarrest_stick", "arccw_flash_grenade", "masita_a180_shotgun"},
    command = "novabreach",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Nova Corp",
    PlayerSpawn = EYNJobStats( 250, 150 ),
    sortOrder = 3,
})

TEAM_NovaCS = DarkRP.createJob("Nova Command Staff", {
    color = Color(255, 255, 51),
    model = {"models/player/ven/tk_novatrooper_01/tk_novatrooper.mdl", "models/player/ven/tk_novatrooper_03/tk_novatrooper.mdl"},
    description = [[You are a Nova Police Trooper.]],
    weapons = {"masita_dlt19", "masita_rk3_stun", "masita_empireshield", "arrest_stick", "unarrest_stick", "arccw_flash_grenade"},
    command = "novacs",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Nova Corp",
    PlayerSpawn = EYNJobStats( 450, 100 ),
    sortOrder = 4,
})