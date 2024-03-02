AddCSLuaFile()

DarkRP.createCategory{
    name = "Royal Guard",
    categorises = "jobs",
    startExpanded = true,
    color = Color(255, 0, 0),
    canSee = function(ply) return true end,
    sortOrder = 7,
}

TEAM_royalg = DarkRP.createJob("Red Guard", {
    color = Color(255, 0, 0),
    model = {"models/nada/male/MedicalTrooper.mdl"},
    description = [[Royal Guard are the Emperors personal protection.]],
    weapons = {"masita_e105d", "masita_rk3"},
    command = "royalg",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Royal Guard",
    PlayerSpawn = EYNJobStats( 850, 250 ),
    sortOrder = 0,
})