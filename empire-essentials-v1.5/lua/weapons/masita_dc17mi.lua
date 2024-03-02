AddCSLuaFile()

SWEP.Base = "arccw_masita_base"
SWEP.Spawnable = true

SWEP.Category = "[ArcCW 2.0] Empire Essentials - Animated"
SWEP.Credits = "Kraken"
SWEP.PrintName = "DC-17mi"
SWEP.Trivia_Class = "Modular Blaster Rifle"
SWEP.Trivia_Desc = "The DC-17m Interchangeable Weapon System, also known as the DC-17m Repeating Blaster Rifle, was a type of repeating blaster rifle used by Republic clone commandos during the Clone Wars. It could change between a repeating blaster rifle and grenade launcher by switching the weapon's barrel module."
SWEP.Trivia_Manufacturer = "BlasTech Industries"
SWEP.Trivia_Calibre = "Tibanna Gas"
SWEP.Trivia_Year = 2023
SWEP.IconOverride = "entities/masita/dc17mi.png"

SWEP.Slot = 3

SWEP.UseHands = true

SWEP.MirrorVMWM = true
SWEP.UseHands = true
SWEP.ViewModel = "models/arccw/masita/imperial_17m/c_dc17m.mdl"
SWEP.WorldModel = "models/arccw/masita/imperial_17m/w_dc17m.mdl"
SWEP.ViewModelFOV = 60
SWEP.HideViewmodel = false
SWEP.WorldModelOffset = {
    pos = Vector(-5, 9, -6),
    ang = Angle(-10, 0, 180),
    bone = "ValveBiped.Bip01_R_Hand",
    scale = 1,
}

-- Damage & Tracer
SWEP.Damage = 39
SWEP.RangeMin = 276
SWEP.DamageMin = 23
SWEP.Range = 523
SWEP.Penetration = 8
SWEP.DamageType = DMG_BULLET
SWEP.MuzzleVelocity = 900

SWEP.BodyDamageMults =  {
     [HITGROUP_HEAD] = 2.3,
     [HITGROUP_CHEST] = 1.2,
     [HITGROUP_LEFTARM] = 1,
     [HITGROUP_RIGHTARM] = 1,
}

SWEP.TracerNum = 1
SWEP.TracerCol = Color(250, 0, 0)
SWEP.TracerWidth = 10
SWEP.Tracer = "tracer_red"
SWEP.HullSize = 1

SWEP.AmmoPerShot = 1
SWEP.ChamberSize = 1
SWEP.Primary.ClipSize = 75
SWEP.ExtendedClipSize = 150
SWEP.ReducedClipSize = 25

SWEP.MaxRecoilBlowback = 1
SWEP.VisualRecoilMult = 1
SWEP.Recoil = 0.98
SWEP.RecoilSide = 0.13
SWEP.RecoilRise = 0.67
SWEP.RecoilPunch = 1

SWEP.Delay = 60 / 426
SWEP.Num = 1
SWEP.Firemode = 1
SWEP.Firemodes = {
    {
		Mode = 2,
        PrintName = "FULLAUTO-PLASMA",
    },
    {
		Mode = 1,
        PrintName = "SINGLE-PLASMA",
    },
	{
		Mode = 0,
   	}
}

SWEP.AccuracyMOA = 0.1
SWEP.HipDispersion = 200
SWEP.MoveDispersion = 125 
SWEP.SightsDispersion = 0 
SWEP.JumpDispersion = 200

-- Speed Mult
SWEP.SpeedMult = 1.1
SWEP.SightedSpeedMult = 0.77
SWEP.ShootSpeedMult = 1

-- Ironsight & Properties
SWEP.NoFlash = nil
SWEP.MuzzleEffect = "wpn_muzzleflash_dc17_red"
SWEP.FastMuzzleEffect = false
SWEP.GMMuzzleEffect = false
SWEP.MuzzleFlashColor = Color(250, 0, 0)

SWEP.Primary.Ammo = "ar2"

SWEP.ShootVol = 150
SWEP.ShootPitch = 100
SWEP.ShootPitchVariation = 0.05

SWEP.ShootSound = "armas/disparos/dc17m/dc17m_fire0.wav"
SWEP.FirstShootSound = "armas/disparos/dc17m/dc17m_fire3.wav"
SWEP.ShootSoundSilenced = "armas/disparos/dc17m/dc17m_fire_silenced.wav"

SWEP.IronSightStruct = {
    Pos = Vector(-8.389, 0, 0.689),
    Ang = Angle(1.332, -1.168, 0),
     Magnification = 1.2,
     SwitchToSound = "weapon_hand/ads/0242-00001a46.mp3",
     SwitchFromSound = "weapon_hand/ads/0242-00001a43.mp3",
     ViewModelFOV = 55,
}

SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "ar2"
SWEP.HoldtypeSights = "rpg"

SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2

SWEP.ActivePos = Vector(-3, 5, 0)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.SprintPos = Vector(7, 0, -4)
SWEP.SprintAng = Angle(5, 40, 0)

SWEP.CustomizePos = Vector(0, 3, -4)
SWEP.CustomizeAng = Angle(12.149, 30.547, 0)

SWEP.HolsterPos = Vector(4, -3, 2)
SWEP.HolsterAng = Vector(-15, 30, -15)

-- Attachments
SWEP.Attachments = {
    {
        PrintName = "Sight",
        DefaultAttName = "Standard",
        Slot = "optic",
        Bone = "weaponAttach_R",
        Offset = {
            vpos = Vector(3.5, -0.1, 4.8),
            vang = Angle(0, 0, 0),
        },
        CorrectiveAng = Angle(0, 0, 0),
        CorrectivePos = Vector(0, 0, 0),
    },
    {
        PrintName = "Tactical",
        DefaultAttName = "None",
        Slot = {"tactical", "tac_pistol"},
        Bone = "weaponAttach_R",
        Offset = {
            vpos = Vector(9, -1.5, 2.7),
            vang = Angle(0, 0, 90),
        },
    },
    {
        PrintName = "Muzzle",
        DefaultAttName = "None",
        Slot = {"muzzle", "dlt19_muzzle", "dc15a_muzzle", "cr2_muzzle", "cr2c_muzzle", "stealth_muzzle", "b1120_muzzle"},
        Bone = "weaponAttach_R",
        Offset = {
            vpos = Vector(14.5, 0, 3.5),
            vang = Angle(0, 0, 0),
        },
    },
    {
        PrintName = "Energization",
        DefaultAttName = "Standard",
        Slot = {"ammo", "special_ammo"}
    },
    {
        PrintName = "Perk",
        DefaultAttName = "None",
        Slot = "perk",
    },
    {
        PrintName = "Charm",
        DefaultAttName = "None",
        Slot = {"charm"},
        Bone = "weaponAttach_R",
        VMScale = Vector(0.7, 0.7, 0.7),
        Offset = {
            vpos = Vector(0, -1.4, 2.4),
            vang = Angle(0, 0, 0),
        },
    },
    {
        PrintName = "Killcounter",
        DefaultAttName = "None",
        Slot = {"killcounter"},
        Bone = "weaponAttach_R",
        VMScale = Vector(0.9, 0.9, 0.9),
        Offset = {
            vpos = Vector(-2, -1.3, 3.4),
            vang = Angle(0, 0, 20),
        },
    },
}

SWEP.Animations = {
    ["enter_inspect"]= {
        Source = "pose",
        SoundTable = {
            {
                s = "armas/disparos/dc17m/dc17m_pose.wav", -- sound; can be string or table
                p = 100, -- pitch
                v = 100, -- volume
                t = 1, -- time at which to play relative to Animations.Time
                c = CHAN_ITEM, -- channel to play the sound
            },
        }
    },
    ["idle"] = {
        Source = "idle",
    },
    ["bash"] = {
        Source = "melee", 
        SoundTable = {
            {s = "armas/disparos/dc17m/melee0.wav", t = 0.1 },
        },
    },
    ["fire"] = {
        Source = "fire"
    },
    ["idle_iron"] = {
        Source = false
    },
    ["idle_sight"] = {
        Source = false
    },
    ["fire_iron"] = {
        Source = false
    },
    ["draw"] = {
        Source = "draw",
        SoundTable = {
            {
                s = "armas/disparos/dc17m/dc17m_unholster.wav", -- sound; can be string or table
                p = 100, -- pitch
                v = 100, -- volume
                t = 0.1, -- time at which to play relative to Animations.Time
                c = CHAN_ITEM, -- channel to play the sound
            },
        }
    },
    ["holster"] = {
        Source = "holster",
        SoundTable = {
            {
                s = "armas/disparos/dc17m/dc17m_sniper_unholster.wav", -- sound; can be string or table
                p = 100, -- pitch
                v = 75, -- volume
                t = 0.1, -- time at which to play relative to Animations.Time
                c = CHAN_ITEM, -- channel to play the sound
            },
        }
    },
    ["reload"] = {
        Source = "reload",
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2, 
        SoundTable = {
            {s = "armas/disparos/dc17m/dc17m_reload.wav", t = 0.1 }, --s sound file
        },
    },
}