AddCSLuaFile()

SWEP.Base = "arccw_masita_base"
SWEP.Spawnable = true

SWEP.Category = "[ArcCW 2.0] Empire Essentials - Animated"
SWEP.Credits = "Kraken/Masita"
SWEP.PrintName = "DC-17mi Launcher"
SWEP.Trivia_Class = "Modular Blaster Rifle"
SWEP.Trivia_Desc = "The DC-17m Interchangeable Weapon System, also known as the DC-17m Repeating Blaster Rifle, was a type of repeating blaster rifle used by Republic clone commandos during the Clone Wars. It could change between a repeating blaster rifle and grenade launcher by switching the weapon's barrel module."
SWEP.Trivia_Manufacturer = "BlasTech Industries"
SWEP.Trivia_Calibre = "Tibanna Gas"
SWEP.Trivia_Year = 2023
SWEP.IconOverride = "entities/masita/dc17mi_launcher.png"

SWEP.Slot = 3

SWEP.UseHands = true
SWEP.NoHideLeftHandInCustomization = true
SWEP.MirrorVMWM = true
SWEP.UseHands = true
SWEP.ViewModel = "models/arccw/masita/imperial_17m/c_dc17m_grenade.mdl"
SWEP.WorldModel = "models/arccw/masita/imperial_17m/w_dc17m_antiarmour.mdl"
SWEP.ViewModelFOV = 60
SWEP.HideViewmodel = false
SWEP.WorldModelOffset = {
    pos = Vector(-6.5, 5, -8),
    ang = Angle(-10, 0, 180),
    bone = "ValveBiped.Bip01_R_Hand",
    scale = 1,
}

SWEP.ViewModelFOV = 60

-- Grenade Launcher properties
SWEP.ShootEntity = "arccw_nade_launched"
SWEP.MuzzleVelocity = 4000

-- Damage & Tracer
SWEP.ChamberSize = 0
SWEP.Primary.ClipSize = 1
SWEP.ExtendedClipSize = 1
SWEP.ReducedClipSize = 1

SWEP.Recoil = 0.1
SWEP.RecoilSide = 0.175
SWEP.RecoilRise = 0.76

SWEP.Delay = 60 / 105
SWEP.Num = 1
SWEP.Firemode = 1
SWEP.Firemodes = {
    {
		Mode = 1,
        PrintName = "ROCKET",
    },
	{
		Mode = 0,
   	}
}

SWEP.AccuracyMOA = 1
SWEP.HipDispersion = 300
SWEP.MoveDispersion = 125 
SWEP.SightsDispersion = 0 
SWEP.JumpDispersion = 200

-- Ammo, Sounds & MuzzleEffect
SWEP.Primary.Ammo = "grenade"
SWEP.ShootVol = 120
SWEP.ShootPitch = 100
SWEP.ShootPitchVariation = 0.2

SWEP.FirstShootSound = "masita/weapons/dc17m/dc17m_grenade_fire0.wav"
SWEP.ShootSound = "masita/weapons/dc17m/dc17m_grenade_fire0.wav"

SWEP.NoFlash = nil
SWEP.MuzzleEffect = "wpn_muzzleflash_dc17_orange"
SWEP.FastMuzzleEffect = false
SWEP.GMMuzzleEffect = false
SWEP.MuzzleFlashColor = Color(250, 167, 0)


SWEP.IronSightStruct = {
    Pos = Vector(-4.14, -0.32, 2.207),
    Ang = Angle(2.267, -0.76, 0),
     Magnification = 1.5,
     SwitchToSound = "weapon_hand/ads/0242-00001a46.mp3",
     SwitchFromSound = "weapon_hand/ads/0242-00001a43.mp3",
     ViewModelFOV = 55,
}

SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "ar2"
SWEP.HoldtypeSights = "rpg"

SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN

SWEP.ActivePos = Vector(0, 2, 2)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.SprintPos = Vector(7, 0, -4)
SWEP.SprintAng = Angle(5, 40, 0)

SWEP.CustomizePos = Vector(0, 2, 2)
SWEP.CustomizeAng = Angle(0, 0, 0)

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
            vpos = Vector(3.3, -0.1, 4.9),
            vang = Angle(0, -0.5, 0),
        },
        CorrectiveAng = Angle(0, 1, 0),
        CorrectivePos = Vector(0, 0, 0),
    },
    {
        PrintName = "Tactical",
        DefaultAttName = "None",
        Slot = {"tactical", "tac_pistol"},
        VMScale = Vector(0.7, 0.7, 0.7),
        Bone = "weaponAttach_R",
        Offset = {
            vpos = Vector(13, -1.76, 2.7),
            vang = Angle(0, 0, 90),
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
}



SWEP.Animations = {
    ["enter_inspect"]= {
        Source = "pose",
        SoundTable = {
            {
                s = "masita/weapons/dc17m/dc17m_grenade_pose.wav", -- sound; can be string or table
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
    ["fire_iron"] = {
        Source = false
    },
    ["idle_iron"] = {
        Source = false
    },
    ["idle_sight"] = {
        Source = false
    },
    ["draw"] = {
        Source = "draw",
        SoundTable = {
            {
                s = "masita/weapons/dc17m/dc17m_grenade_draw.wav", -- sound; can be string or table
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
                s = "masita/weapons/dc17m/dc17m_grenade_holster.wav", -- sound; can be string or table
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
            {s = "masita/weapons/dc17m/dc17m_grenade_reload.wav", t = 0.1 }, --s sound file
        },
    },
}