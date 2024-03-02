AddCSLuaFile()

DarkRP.createCategory{
    name = "Imperial Navy",
    categorises = "jobs",
    startExpanded = true,
    color = Color(50, 200, 238),
    canSee = function(ply) return true end,
    sortOrder = 7,
}

TEAM_NVYCN = DarkRP.createJob("Naval Crewman", {
    color = Color(144, 238, 144, 255),
    model = {
        "models/nada/pms/male/imperialweapontechnician.mdl",
        "models/nada/pms/female/imperialweapontechnician.mdl"
    },
    description = [[You are a Crewman in the Imperial Navy.]],
    weapons = {
        "masita_e11_pistolext"
    },
    command = "NVYTRP",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Imperial Navy",
    PlayerSpawn = EYNJobStats( 100, 100 ),
    sortOrder = 0,
})

TEAM_NVYENG = DarkRP.createJob("Naval Engineer", {
    color = Color(144, 238, 144, 255),
    model = {
        "models/nada/pms/male/gunner.mdl",
        "models/nada/pms/female/gunner.mdl"
    },
    description = [[You are an Engineer in the Imperial Navy.]],
    weapons = {
        "masita_e11_pistolext",
        "weapon_lvsrepair"
    },
    command = "NVYENG",
    max = 5,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Imperial Navy",
    PlayerSpawn = EYNJobStats( 100, 100 ),
    sortOrder = 1,
})

TEAM_NVYMC = DarkRP.createJob("Naval Corspman", {
    color = Color(144, 238, 144, 255),
    model = {
        "models/nada/pms/male/medic.mdl",
        "models/nada/pms/female/medic.mdl"
    },
    description = [[You are a Corpsman in the Imperial Navy.]],
    weapons = {
        "weapon_bactanade", 
        "weapon_bactainjector",
        "masita_e11_pistolext"
    },
    command = "NVYMC",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Imperial Navy",
    PlayerSpawn = EYNJobStats( 100, 100 ),
    sortOrder = 2,
})

TEAM_NVYINT = DarkRP.createJob("Naval Intelligence", {
    color = Color(144, 238, 144, 255),
    model = {
        "models/nada/pms/male/naval_officer.mdl",
        "models/nada/pms/female/naval_officer.mdl"
    },
    description = [[You are an Intelligence Officer in the Imperial Navy.]],
    weapons = {
        "masita_e11_pistolext"
    },
    command = "NVYINT",
    max = 0,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Imperial Navy",
    PlayerSpawn = EYNJobStats( 100, 100 ),
    sortOrder = 3,
})

TEAM_NVYBC = DarkRP.createJob("Naval Bridge Crew", {
    color = Color(144, 238, 144, 255),
    model = {"models/nada/pms/female/bridgecrew.mdl", "models/nada/pms/male/bridgecrew.mdl"},
    description = [[You are a member of the Bridge Crew in the Imperial Navy.]],
    weapons = {
        "masita_e11_pistolext"
    },
    command = "NVYBC",
    max = 5,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Imperial Navy",
    PlayerSpawn = EYNJobStats( 100, 100 ),
    sortOrder = 4,
})

TEAM_NVYADM = DarkRP.createJob("Naval Admiral", {
    color = Color(144, 238, 144, 255),
    model = {
        "models/nada/pms/male/admiral.mdl",
        "models/nada/pms/female/admiral.mdl"
    },
    description = [[You are the Admiral of the Imperial Navy.]],
    weapons = {
        "masita_dt57"
    },
    command = "NVYADM",
    max = 1,
    salary = 400,
    admin = 0,
    vote = false,
    hasLicense = false,
    canDemote = true,
    category = "Imperial Navy",
    PlayerSpawn = EYNJobStats( 500, 250 ),
    sortOrder = 99,
})