AddCSLuaFile()
SWEP.Base = "arccw_meeks_sw_base"
SWEP.Spawnable = true -- this obviously has to be set to true
SWEP.Category = "[ ArcCW ] Star Wars Weapons" -- edit this if you like
SWEP.AdminOnly = false

SWEP.PrintName = "BTRS"
SWEP.Trivia_Class = "Modular Blaster"
SWEP.Trivia_Desc = "High tech verstile modular blaster base, suited for allround usage."
SWEP.Trivia_Manufacturer = "BlasTech Industries"
SWEP.Trivia_Calibre = "Medium Density"
SWEP.Trivia_Mechanism = "Energized Compressed Tibanna"
SWEP.Trivia_Country = "GAR"

SWEP.ViewModel = "models/arccw/btrs_41_viewmodel.mdl"
SWEP.WorldModel = "models/arccw/btrs_41_world.mdl"
SWEP.IconOverride = "entities/btrs_41.png"
SWEP.WorldModelOffset = {
    pos = Vector(-3.3, 4, -7.2),
    ang = Angle(-10, -90, 180),
    bone = "ValveBiped.Bip01_R_Hand",
    scale = 1
}

SWEP.ViewModelFOV = 70


SWEP.IconOverride = "materials/entities/btrs_41.png"
SWEP.DefaultBodygroups = "09"

SWEP.NoHideLeftHandInCustomization = false

SWEP.Damage = 435
SWEP.DamageMin = 103 -- damage done at maximum range
SWEP.DamageRand = 0 -- damage will vary randomly each shot by this fraction
SWEP.RangeMin = 220 -- how far bullets will retain their maximum damage for
SWEP.Range = 550 -- in METRES
SWEP.Penetration = 1
SWEP.DamageType = DMG_AIRBOAT
SWEP.DamageTypeHandled = false -- set to true to have the base not do anything with damage types
-- this includes: igniting if type has DMG_BURN; adding DMG_AIRBOAT when hitting helicopter; adding DMG_BULLET to DMG_BUCKSHOT

SWEP.MuzzleVelocity = 400 -- projectile muzzle velocity in m/s

SWEP.AlwaysPhysBullet = false
SWEP.NeverPhysBullet = false
SWEP.PhysTracerProfile = 3 -- color for phys tracer.

SWEP.TracerNum = 1 -- tracer every X
SWEP.TracerFinalMag = 0 -- the last X bullets in a magazine are all tracers
SWEP.Tracer = "tfa_tracer_green" -- override tracer (hitscan) effect
SWEP.TracerCol = Color(255, 0, 0)
SWEP.HullSize = 2 -- HullSize used by FireBullets

SWEP.ChamberSize = 0 -- how many rounds can be chambered.
SWEP.Primary.ClipSize = 10 -- DefaultClip is automatically set.

SWEP.ManualAction = true -- pump/bolt action
SWEP.NoLastCycle = true -- do not cycle on last shot

SWEP.AmmoPerShot = 1

SWEP.ReloadInSights = false
SWEP.ReloadInSights_CloseIn = 0.25
SWEP.ReloadInSights_FOVMult = 0.875
SWEP.LockSightsInReload = false

SWEP.Recoil = 3
SWEP.RecoilSide = 0.2
SWEP.RecoilRise = 0.4
SWEP.VisualRecoilMult = 2
SWEP.RecoilPunch = 1.8
SWEP.RecoilPunchBackMax = 0.9

SWEP.RecoilDirection = Angle(1.1, 0, 0)
SWEP.RecoilDirectionSide = Angle(0, 1.1, 0)

SWEP.Delay = 60 / 330 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemode = 2 -- 0: safe, 1: semi, 2: auto, negative: burst
SWEP.Firemodes = {
    {
		Mode = 1,
    },
	{
		Mode = 0,
   	}
}

SWEP.NotForNPCS = true
SWEP.NPCWeaponType = nil -- string or table, the NPC weapons for this gun to replace

SWEP.AccuracyMOA = 2 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 330 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 99 -- inaccuracy added by moving. Applies in sights as well! Walking speed is considered as "maximum".
SWEP.SightsDispersion = 15 -- dispersion that remains even in sights
SWEP.JumpDispersion = 200 -- dispersion penalty when in the air

SWEP.ShootWhileSprint = false

SWEP.Primary.Ammo = "ar2" -- what ammo type the gun uses
SWEP.MagID = "mpk1" -- the magazine pool this gun draws from

SWEP.ShootVol = 125 -- volume of shoot sound
SWEP.ShootPitch = 100 -- pitch of shoot sound
SWEP.ShootPitchVariation = 0.05

SWEP.ShootSound = "weapons/anti_tank_shot.wav"
SWEP.FiremodeSound = "weapons/arccw/firemode.wav"
SWEP.MeleeSwingSound = "weapons/arccw/melee_lift.wav"
SWEP.MeleeMissSound = "weapons/arccw/melee_miss.wav"
SWEP.MeleeHitSound = "weapons/arccw/melee_hitworld.wav"
SWEP.MeleeHitNPCSound = "weapons/arccw/melee_hitbody.wav"
SWEP.FiremodeSound = "weapons/tfa_ww2_pzb39/pzb39_safety.wav"

SWEP.NoFlash = nil -- disable light flash
SWEP.MuzzleEffect = "wpn_muzzleflash_dc17_green"
SWEP.FastMuzzleEffect = nil
SWEP.GMMuzzleEffect = false -- Use Gmod muzzle effects rather than particle effects

SWEP.MuzzleEffectAttachment = 1 -- which attachment to put the muzzle on
SWEP.ProceduralViewBobAttachment = 1 -- attachment on which coolview is affected by, default is muzzleeffect
SWEP.MuzzleFlashColor = Color(255, 0, 0)

SWEP.SpeedMult = 0.9
SWEP.SightedSpeedMult = 0.75
SWEP.ShootSpeedMult = 1

SWEP.BulletBones = {
    [1] = "bullet.010",
    [2] = "bullet.009",
    [3] = "bullet.008",
    [4] = "bullet.007",
    [5] = "bullet.006",
    [6] = "bullet.005",
    [7] = "bullet.004",
    [8] = "bullet.003",
    [9] = "bullet.002",
    [10] = "bullet.001",
}

-- O

SWEP.IronSightStruct = {
    Pos = Vector(-3.155, 0, 2.04),
    Ang = Angle(0.2, 0.05, 0),
    Midpoint = { -- Where the gun should be at the middle of it's irons
        Pos = Vector(0, 0, 0),
        Ang = Angle(0, 0, 0),
    },
    Magnification = 1,
    SwitchToSound = "zoom_in/gunfoley_zoomin_blasterpistol_04.mp3",
    CrosshairInSights = false,
}


SWEP.SightTime = 0.13
SWEP.SprintTime = 0
-- If Malfunction is enabled, the gun has a random chance to be jammed
-- after the gun is jammed, it won't fire unless reload is pressed, which plays the "unjam" animation
-- if no "unjam", "fix", or "cycle" animations exist, the weapon will reload instead
SWEP.Malfunction = false
SWEP.MalfunctionJam = true -- After a malfunction happens, the gun will dryfire until reload is pressed. If unset, instead plays animation right after.
SWEP.MalfunctionTakeRound = true -- When malfunctioning, a bullet is consumed.
SWEP.MalfunctionWait = 0.5 -- The amount of time to wait before playing malfunction animation (or can reload)
SWEP.MalfunctionMean = nil -- The mean number of shots between malfunctions, will be autocalculated if nil
SWEP.MalfunctionVariance = 0.25 -- The fraction of mean for variance. e.g. 0.2 means 20% variance
SWEP.MalfunctionSound = "weapons/arccw/malfunction.wav"

SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "ar2"
SWEP.HoldtypeSights = "rpg"
SWEP.HoldtypeCustomize = "slam"

SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
SWEP.CanBash = true
SWEP.MeleeDamage = 25
SWEP.MeleeRange = 16
SWEP.MeleeDamageType = DMG_CLUB
SWEP.MeleeTime = 0.5
SWEP.MeleeGesture = nil
SWEP.MeleeAttackTime = 0.2

SWEP.SprintPos = Vector(2, -5,-10)
SWEP.SprintAng = Angle(40, 0, 0)

SWEP.BashPreparePos = Vector(2.187, -4.117, -7.14)
SWEP.BashPrepareAng = Angle(32.182, -3.652, -19.039)

SWEP.BashPos = Vector(8.876, 0, 0)
SWEP.BashAng = Angle(-16.524, 70, -11.046)

SWEP.ActivePos = Vector(0, 1, 1)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.HolsterPos = Vector(0.532, -6, 0)
SWEP.HolsterAng = Angle(-4.633, 36.881, 0)

SWEP.BarrelOffsetSighted = Vector(0, 0, 0)
SWEP.BarrelOffsetCrouch = nil
SWEP.BarrelOffsetHip = Vector(3, 0, -3)

SWEP.CustomizePos = Vector(10, 0, -5.897)
SWEP.CustomizeAng = Angle(30.149, 20.547, 40)

SWEP.InBipodPos = Vector(-2, 0, -4)
SWEP.InBipodMult = Vector(2, 1, 1)

SWEP.BarrelLength = 24

SWEP.SightPlusOffset = true

SWEP.DefaultElements = {}

SWEP.AttachmentElements = {
    ["btrs_41_bipod"] = {
        VMBodygroups = {{ind = 3, bg = 1}},-- change the world model to something else. Please make sure it's compatible with the last one.
    },
}


SWEP.Attachments = {
	[1] = {
		PrintName = "Optic", -- print name
		DefaultAttName = "Iron Sights", -- used to display the "no attachment" text
		Slot = "optic",
		Bone = "body", -- relevant bone any attachments will be mostly referring to
		Offset = {
            vpos = Vector(-2.4, 0, 7),
            vang = Angle(90, 0, -0),
            wpos = Vector(12, 0.85, -7.4),
            wang = Angle(-10, 0, 180)
        },
        NoWM = false
	},
    [2] = {
        PrintName = "Tactical", -- print name
        DefaultAttName = "No Attachment", -- used to display the "no attachment" text
        Slot = {"tactical", "tac_pistol"},
        VMScale = Vector(1, 1, 1),
        Bone = "body", -- relevant bone any attachments will be mostly referring to
        Offset = {
            vpos = Vector(-0.5, 0, 19),
            vang = Angle(90, 00, 0),
            wpos = Vector(25, .85, -7.9),
            wang = Angle(-10, 0, -180)
        },
        NoWM = false
    },
    [3] = {
        PrintName = "Charms", -- print name
        DefaultAttName = "No Attachment", -- used to display the "no attachment" text
        Slot = {"charm"},
        Bone = "body", -- relevant bone any attachments will be mostly referring to
        Offset = {
            vpos = Vector(-1, -1, 2.3),
            vang = Angle(90, 0, 0),
            wpos = Vector(3.5, 1.8, -2.5),
            wang = Angle(90, 0, 90)
        },
    },
    [4] = {
        PrintName = "Bipod", -- print name
        Slot = {"btrs_41_bipod"},
        DefaultAttName = "Undeployed", -- used to display the "no attachment" text        -- Set this to false if you want the foregrips to display on ViewModels.          
    },
    [5] = {
        PrintName = "Energization", -- print name
        DefaultAttName = "Standard Energization", -- used to display the "no attachment" text
        Slot = {"anti_vehicle_btrs", "ammo"},
    },
    [6] = {
        PrintName = "Training/Perk", -- print name
        DefaultAttName = "None", -- used to display the "no attachment" text
        Slot = "perk",
    },
    [7] = {
        PrintName = "Muzzle", -- print name
        DefaultAttName = "No Attachment", -- used to display the "no attachment" text
    },                              
}

SWEP.Animations = {
    ["ready"] = {
        Source = "base_ready",
    },
    ["idle"] = {
        Source = "base_idle",
    },
    ["fire"] = {
        Source = {"base_fire"},
    },
    ["fire_empty"] = {
        Source = {"base_firelast"},
    },
    ["fire_iron"] = {
        Source = {"iron_fire"},
    },
    ["fire_iron_empty"] = {
        Source = {"iron_fire_last"},
    },
    ["idle_sights"] = {
        Source = "neutral",
        Time = 0, -- Overwrites the duration of the animation (changes speed). Don't set to use sequence length
    },
	["reload_empty"] = {
        Source = "base_reload",
        LHIK = true,
    },
    ["cycle"] = {
        Source = "base_fire_end",
        LHIK = true,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
    },
    ["idle_inspect"] = {
        Source = "base_inspect",
    },
    ["exit_inspect"] = {
        Source = "base_idle",
    },
	["draw"] = {
        Source = "base_draw",
        SoundTable = {
            {
                s = "w/dt12/gunfoley_pistol_draw_var_11.mp3", -- sound; can be string or table
                p = 100, -- pitch
                v = 75, -- volume
                t = 0, -- time at which to play relative to Animations.Time
                c = CHAN_ITEM, -- channel to play the sound
            },
        }
    },
	["holster"] = {
        Source = "base_holster",
        SoundTable = {
            {
                s = "w/dt12/gunfoley_pistol_sheathe_var_01.mp3", -- sound; can be string or table
                p = 100, -- pitch
                v = 75, -- volume
                t = 0, -- time at which to play relative to Animations.Time
                c = CHAN_ITEM, -- channel to play the sound
            },
        }
    },
}

sound.Add({
    name =          "TFA_WW2_PZB39.OpenLever",
    channel =       CHAN_ITEM,
    volume =        1.0,
    sound =             "weapons/tfa_ww2_pzb39/pzb39_leveropen.wav"
})

sound.Add({
    name =          "TFA_WW2_PZB39.OpenRightAmmoBox",
    channel =       CHAN_ITEM,
    volume =        1.0,
    sound =             "weapons/tfa_ww2_pzb39/pzb39_openrightammobox.wav"
})

sound.Add({
    name =          "TFA_WW2_PZB39.InsertRound",
    channel =       CHAN_ITEM,
    volume =        1.0,
    sound =             "weapons/tfa_ww2_pzb39/pzb39_insertround.wav"
})

sound.Add({
    name =          "TFA_WW2_PZB39.CloseRightAmmobox",
    channel =       CHAN_ITEM,
    volume =        1.0,
    sound =             "weapons/tfa_ww2_pzb39/pzb39_closerightammobox.wav"
})

sound.Add({
    name =          "TFA_WW2_PZB39.Safety",
    channel =       CHAN_ITEM,
    volume =        1.0,
    sound =             "weapons/tfa_ww2_pzb39/pzb39_safety.wav"
})

sound.Add({
    name =          "TFA_WW2_PZB39.CloseLever",
    channel =       CHAN_ITEM,
    volume =        1.0,
    sound =             "weapons/tfa_ww2_pzb39/pzb39_leverclose.wav"
})

sound.Add({
    name =          "TFA_WW2_PZB39.Tap",
    channel =       CHAN_ITEM,
    volume =        1.0,
    sound =             "weapons/tfa_ww2_pzb39/pzb39_tap.wav"
})

sound.Add({
    name =          "TFA_WW2_PZB39.pzb39_ammoboxout",
    channel =       CHAN_ITEM,
    volume =        1.0,
    sound =             "weapons/tfa_ww2_pzb39/pzb39_leverclose.wav"
})

sound.Add({
    name =          "TFA_WW2_PZB39.AmmoBoxin",
    channel =       CHAN_ITEM,
    volume =        1.0,
    sound =             "weapons/tfa_ww2_pzb39/pzb39_ammoboxin.wav"
})