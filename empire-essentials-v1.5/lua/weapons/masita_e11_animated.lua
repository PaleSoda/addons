AddCSLuaFile()

SWEP.Base = "arccw_masita_base"
SWEP.Spawnable = true

SWEP.Category = "[ArcCW 2.0] Empire Essentials - Animated"
SWEP.Credits = "Kraken"
SWEP.PrintName = "E-11 Blaster"
SWEP.Trivia_Class = "Blaster Rifle"
SWEP.Trivia_Desc = "The BlasTech Industries E-11 blaster rifle, also referred to as the E-11 BlasTech Standard Imperial Sidearm, the Stormtrooper Armament Blaster Rifle (BlasTech E-11), and the E-11 Military Issue Blaster Rifle, was a blaster rifle used during the time of the Galactic Empire. It was the standard-issue blaster rifle of the Imperial stormtroopers. A powerful, light and compact weapon, the E-11 was used widely throughout the galaxy for nearly a century and a half."
SWEP.Trivia_Manufacturer = "BlastTech Industries"
SWEP.Trivia_Calibre = "Condensed Tibanna-Gas"
SWEP.IconOverride = "entities/masita/e11_animated.png"

SWEP.Slot = 3

SWEP.UseHands = true

SWEP.MirrorVMWM = false
SWEP.UseHands = true
SWEP.NoHideLeftHandInCustomization = false
SWEP.ViewModel = "models/arccw/masita/imperial_e11/v_e11.mdl"
SWEP.WorldModel = "models/arccw/bf2017/w_e11.mdl"
SWEP.ViewModelFOV = 60
SWEP.HideViewmodel = false
SWEP.WorldModelOffset = {
    pos = Vector(0, 0, 0),
    ang = Angle(0, 0, 0),
    bone = "ValveBiped.Bip01_R_Hand",
    scale = 0.09
}

-- Damage & Tracer
SWEP.Damage = 27
SWEP.RangeMin = 175
SWEP.DamageMin = 18
SWEP.Range = 394
SWEP.Penetration = 8
SWEP.DamageType = DMG_BULLET
SWEP.MuzzleVelocity = 900

SWEP.BodyDamageMults =  {
     [HITGROUP_HEAD] = 1.5,
     [HITGROUP_CHEST] = 1,
     [HITGROUP_LEFTARM] = 0.9,
     [HITGROUP_RIGHTARM] = 0.9,
}

SWEP.TracerNum = 1
SWEP.TracerCol = Color(250, 0, 0)
SWEP.TracerWidth = 10
SWEP.Tracer = "tracer_red"
SWEP.HullSize = 1

SWEP.AmmoPerShot = 1
SWEP.ChamberSize = 0
SWEP.Primary.ClipSize = 25
SWEP.ExtendedClipSize = 40
SWEP.ReducedClipSize = 15

SWEP.MaxRecoilBlowback = 1
SWEP.VisualRecoilMult = 1
SWEP.Recoil = 0.76
SWEP.RecoilSide = 0.2
SWEP.RecoilRise = 0.45
SWEP.RecoilPunch = 1

SWEP.Delay = 60 / 270
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

SWEP.AccuracyMOA = 0.5
SWEP.HipDispersion = 300
SWEP.MoveDispersion = 125 
SWEP.SightsDispersion = 0 
SWEP.JumpDispersion = 200

-- Speed Mult
SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = 0.77
SWEP.ShootSpeedMult = 1

-- Ammo, Sounds & MuzzleEffect
SWEP.Primary.Ammo = "ar2"
SWEP.ShootVol = 120
SWEP.ShootPitch = 100
SWEP.ShootPitchVariation = 0.2

SWEP.FirstShootSound = "masita/weapons/imperiale11/e11_og.wav"
SWEP.ShootSound = "masita/weapons/imperiale11/e11_og_light.wav"
SWEP.ShootSoundSilenced = "masita/weapons/imperiale11/e11supp.wav"

SWEP.NoFlash = nil
SWEP.MuzzleEffect = "wpn_muzzleflash_dc17_red"
SWEP.FastMuzzleEffect = false
SWEP.GMMuzzleEffect = false
SWEP.MuzzleFlashColor = Color(250, 0, 0)

-- Ironsight
SWEP.IronSightStruct = {
    Pos = Vector(-3.379, -6.961, 2.45),
    Ang = Angle(0, 0, 0),
     Magnification = 1.5,
     SwitchToSound = "weapon_hand/ads/0242-00001a46.mp3",
     SwitchFromSound = "weapon_hand/ads/0242-00001a43.mp3",
     ViewModelFOV = 55,
}

-- Holdtype
SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "ar2"
SWEP.HoldtypeSights = "rpg"
SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2

SWEP.ActivePos = Vector(0, -2, 1)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.SprintPos = Vector(4.019, -5.226, -0.805)
SWEP.SprintAng = Angle(5, 40, 0)

SWEP.CustomizePos = Vector(10, 0, 0)
SWEP.CustomizeAng = Angle(6.8, 30.7, 10.3)

SWEP.HolsterPos = Vector(4, -3, 2)
SWEP.HolsterAng = Vector(-15, 30, -15)

-- Attachments
SWEP.DefaultElements = {"blaster"}
SWEP.AttachmentElements = {
    ["blaster"] = {
        VMElements = {
           {
               Model = "models/hunter/plates/plate.mdl",
               Bone = "e11_sight",
               Scale = Vector(0, 0, 0),                
               Offset = {
                   pos = Vector(-3, 6, 10),
                   ang = Angle(-90, 180, 0)
               },
               IsMuzzleDevice = true
           }
        },
        WMElements = {
            {
                Model = "models/arccw/masita/imperial_e11/w_e11.mdl",
                Bone = "ValveBiped.Bip01_R_Hand",
                Scale = Vector(1.1, 1.1, 1.1),
                Offset = {
                    pos = Vector(100, 0, -50.5),
                    ang = Angle(-15, -90, 180)
                }
            },
            {
                Model = "models/hunter/plates/plate.mdl",
                Bone = "ValveBiped.Bip01_R_Hand",
                Scale = Vector(0, 0, 0),
                Offset = {
                    pos = Vector(180, 10, -60),
                    ang = Angle(-15, 0, 180)
                },
                IsMuzzleDevice = true
            },            
        },
    }
}WMOverride = "models/arccw/masita/imperial_e11/w_e11.mdl"

SWEP.Attachments = {
    {
        PrintName = "Sight",
        DefaultAttName = "Standard",
        Slot = "optic",
        Bone = "E11_GUN",
        WMScale = Vector(11, 11, 11),
        Offset = {
            vpos = Vector(0.15, -5, 2.6),
            vang = Angle(0, -90, 0),
            wpos = Vector(0, 13, -43),
            wang = Angle(-15 , 0, 180)
        },
        CorrectiveAng = Angle(0, 180, 0),
        CorrectivePos = Vector(0, 0, 0),
    },
    {
        PrintName = "Tactical",
        DefaultAttName = "None",
        Slot = {"tactical", "tac_pistol"},
        Bone = "E11_GUN",
        WMScale = Vector(11, 11, 11),
        VMScale = Vector(0.7, 0.7, 0.7),
        Offset = {
            vpos = Vector(1.3, 5, 1),
            vang = Angle(0, -90, 90),
            wpos = Vector(120, 25, -55),
            wang = Angle(-15 , 0, -90)
        },
    },
    {
        PrintName = "Foregrip",
        DefaultAttName = "None",
        Slot = {"foregrip"},
        WMScale = Vector(11, 11, 11),
        Bone = "E11_GUN",
        Offset = {
            vpos = Vector(-0, 0.2, 2.5),
            vang = Angle(90, -90, -90),   
            wpos = Vector(0, 9.5, -50),
            wang = Angle(-15, 0, 180)
        },
        SlideAmount = {
        vmin = Vector(0.2, 4, 0.4),
        vmax = Vector(0.2, 6, 0.5),
        wmin = Vector(100, 13, -40),
        wmax = Vector(150, 13, -55),
        },    
    },
    {
        PrintName = "Muzzle",
        DefaultAttName = "None",
        Slot = {"muzzle", "dlt19_muzzle", "dc15a_muzzle", "cr2_muzzle", "cr2c_muzzle", "stealth_muzzle", "b1120_muzzle"},
        Bone = "E11_GUN",
        WMScale = Vector(11, 11, 11),
        Offset = {
            vpos = Vector(0.2, 10, 1.1),
            vang = Angle(0, -90, 0),
            wpos = Vector(182, 11, -73),
            wang = Angle(-15 , 0, 180)
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
        Bone = "E11_GUN",
        VMScale = Vector(0.7, 0.7, 0.7),
        WMScale = Vector(11, 11, 11),
        Offset = {
            vpos = Vector(1.2, -7.1, 1.15),
            vang = Angle(0, -90, 0),
            wpos = Vector(-28, 26, -16),
            wang = Angle(-15 , 0, 180)
        },
    },
    {
        PrintName = "Killcounter",
        DefaultAttName = "None",
        Slot = {"killcounter"},
        Bone = "E11_GUN",
        VMScale = Vector(0.9, 0.9, 0.9),
        WMScale = Vector(11, 11, 11),
        Offset = {
            vpos = Vector(0.8, -4, 1),
            vang = Angle(0, -90, 0),
            wpos = Vector(20, 23, -28),
            wang = Angle(-15 , 0, 180)
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
        Source = "fnuxreload",
        LHIK = true,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2, 
        SoundTable = {
            {s = "armas/disparos/dc17m/dc17m_reload.wav", t = 0.1 }, --s sound file
        },
    },
    ["reload_empty"] = {
        LHIK = true,
        Source = "reload",
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2, 
        SoundTable = {
            {s = "masita/weapons/imperiale11/standard_reload.ogg", t = 0.1 }, --s sound file
        },
    },
}