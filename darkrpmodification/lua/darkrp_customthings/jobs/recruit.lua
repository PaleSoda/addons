AddCSLuaFile()


DarkRP.createCategory{
    name = "Recruits",
    categorises = "jobs",
    startExpanded = true,
    color = Color(255, 255, 255, 255),
    canSee = function(ply) return true end,
    sortOrder = 0,
}


TEAM_CDT = DarkRP.createJob("Imperial Recruit", {
    color = Color(255, 255, 255, 255),
    model = {"models/nada/imperialcadet_male.mdl", "models/nada/imperialcadet_female.mdl"},
    description = [[You are Recruit for the Galactic Empire.]],
    weapons = {},
    command = "RCT",
    max = 0,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Recruits",
    sortOrder = 0,
})