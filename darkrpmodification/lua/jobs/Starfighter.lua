AddCSLuaFile()

DarkRP.createCategory{
    name = "Starfighter Corp",
    categorises = "jobs",
    startExpanded = true,
    color = Color(0, 0, 0),
    canSee = function(ply) return true end,
    sortOrder = 1,
}

TEAM_starp = DarkRP.createJob("Starfighter Pilot", {
    color = Color(0, 0, 0),
    model = {"models/nada/TiePilot.mdl"},
    description = [[Pilots are a Elite and important part of the empire.]],
    weapons = {"masita_e11_animated", "masita_rk3", "weapon_lvsrepair"},
    command = "starp",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Starfighter Corp",
    PlayerSpawn = EYNJobStats( 200, 100 ),
    sortOrder = 0,
}) 

TEAM_starwc = DarkRP.createJob("Starfighter Wing Commander", {
    color = Color(0, 0, 0),
    model = {"models/nada/SpecPilot.mdl"},
    description = [[Pilots are a Elite and important part of the empire.]],
    weapons = {"masita_e11_animated", "masita_rk3", "weapon_lvsrepair"},
    command = "starwc",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Starfighter Corp",
    PlayerSpawn = EYNJobStats( 400, 100 ),
    sortOrder = 0,
})