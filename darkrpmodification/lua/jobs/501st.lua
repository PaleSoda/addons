AddCSLuaFile()

DarkRP.createCategory{
    name = "501st Legion",
    categorises = "jobs",
    startExpanded = true,
    color = Color(0, 0, 255),
    canSee = function(ply) return true end,
    sortOrder = 2,
}

TEAM_Blue = DarkRP.createJob("501st Trooper", {
    color = Color(0, 0, 255),
    model = {"models/player/ven/tk_501_01/tk_501.mdl", "models/player/ven/tk_501_02/tk_501.mdl"},
    description = [[The 501st Legion served under Lord Vader directly as his elite guard and force.]],
    weapons = {"masita_tl50", "masita_rk3"},
    command = "blue",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "501st Legion",
    PlayerSpawn = EYNJobStats( 200, 150 ),
    sortOrder = 0,
})

TEAM_Bluecqb = DarkRP.createJob("501st CQB", {
    color = Color(0, 0, 255),
    model = {"models/player/ven/tk_501_01/tk_501.mdl", "models/player/ven/tk_501_02/tk_501.mdl"},
    description = [[The 501st Legion served under Lord Vader directly as his elite guard and force.]],
    weapons = {"masita_tl50", "masita_a180_shotgun"},
    command = "bluecqb",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "501st Legion",
    PlayerSpawn = EYNJobStats( 250, 150 ),
    sortOrder = 1,
})

TEAM_Bluehvy = DarkRP.createJob("501st Heavy", {
    color = Color(0, 0, 255),
    model = {"models/player/ven/tk_501_01/tk_501.mdl", "models/player/ven/tk_501_02/tk_501.mdl"},
    description = [[The 501st Legion served under Lord Vader directly as his elite guard and force.]],
    weapons = {"masita_z6i", "masita_rk3"},
    command = "bluehvy",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "501st Legion",
    PlayerSpawn = EYNJobStats( 350, 150 ),
    sortOrder = 2,
})

TEAM_Bluecs = DarkRP.createJob("501st Command Staff", {
    color = Color(0, 0, 255),
    model = {"models/player/ven/tk_basic_commander_01/tk_basic_commander.mdl", "models/player/ven/tk_basic_commander_02/tk_basic_commander.mdl"},
    description = [[The 501st Legion served under Lord Vader directly as his elite guard and force.]],
    weapons = {"masita_tl50", "masita_rk3"},
    command = "bluecs",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "501st Legion",
    PlayerSpawn = EYNJobStats( 400, 150 ),
    sortOrder = 3,
})