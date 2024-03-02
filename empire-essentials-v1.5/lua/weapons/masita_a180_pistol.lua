AddCSLuaFile()

SWEP.Base = "arccw_imperialmasita_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Slot = 2 -- Change this if you want to select the weapon with other number

-- Trivia
SWEP.Category = "[ArcCW 2.0] Empire Essentials"
SWEP.Credits = "Kraken AKA Masita"
SWEP.PrintName = "Pistol A-180"
SWEP.Trivia_Class = "Convertible Heavy Pistol"
SWEP.Trivia_Desc = "The A-180 blaster, also known as the A180 pistol, was a modular blaster manufactured by BlasTech Industries. It was a highly versatile design with multiple configurations that could be easily reconfigured from a blaster pistol to a blaster rifle, a sniper rifle/longblaster[5], or an portable ion launcher depending on the situation."
SWEP.Trivia_Manufacturer = "BlastTech Industries"
SWEP.Trivia_Calibre = "Condensed Tibanna-Gas"
SWEP.IconOverride = "entities/masita/a180_pistol.png"

-- Viewmodel & Entity Properties
SWEP.HideViewmodel = false
SWEP.UseHands = true
SWEP.ViewModel = "models/arccw/bf2017/c_scoutblaster.mdl"
SWEP.WorldModel = "models/arccw/bf2017/w_scoutblaster.mdl"
SWEP.ViewModelFOV = 55
SWEP.HideViewmodel = true
SWEP.WorldModelOffset = {
    pos = Vector(0, 0, 0),
    ang = Angle(0, 0, 0),
    bone = "ValveBiped.Bip01_R_Hand",
    scale = 0.009
}

-- Damage & Tracer
SWEP.Damage = 24
SWEP.RangeMin = 167
SWEP.DamageMin = 20
SWEP.Range = 320
SWEP.Penetration = 8
SWEP.DamageType = DMG_BULLET
SWEP.MuzzleVelocity = 900

SWEP.BodyDamageMults =  {
     [HITGROUP_HEAD] = 2,
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
SWEP.ChamberSize = 1
SWEP.Primary.ClipSize = 19
SWEP.ExtendedClipSize = 24
SWEP.ReducedClipSize = 10

SWEP.MaxRecoilBlowback = 1
SWEP.VisualRecoilMult = 1
SWEP.Recoil = 1.29
SWEP.RecoilSide = 0.34
SWEP.RecoilRise = 0.98
SWEP.RecoilPunch = 1

SWEP.Delay = 60 / 190
SWEP.Num = 1
SWEP.Firemode = 1
SWEP.Firemodes = {
    {
		Mode = 1,
        PrintName = "SINGLE-PLASMA",
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

-- Speed Mult
SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = 0.77
SWEP.ShootSpeedMult = 1

-- Ammo, Sounds & MuzzleEffect
SWEP.Primary.Ammo = "ar2"
SWEP.ShootVol = 100
SWEP.ShootPitch = 90
SWEP.ShootPitchVariation = 0.2

SWEP.FirstShootSound = "weapons/a-180/blasters_a180_laser_close_var_01.mp3"
SWEP.ShootSound = "weapons/a-180/blasters_a180_laser_close_var_02.mp3"
SWEP.ShootSoundSilenced = "weapons/silenced.wav"

SWEP.NoFlash = nil
SWEP.MuzzleEffect = "wpn_muzzleflash_dc17_red"
SWEP.FastMuzzleEffect = false
SWEP.GMMuzzleEffect = false
SWEP.MuzzleFlashColor = Color(250, 0, 0)

-- Ironsight
SWEP.IronSightStruct = {
    Pos = Vector(-3.890, -13.179, 1.504),
    Ang = Angle(0.79, 0.513, -0.647),
     Magnification = 1.5,
     SwitchToSound = "weapon_hand/ads/0242-00001a46.mp3",
     SwitchFromSound = "weapon_hand/ads/0242-00001a43.mp3",
     ViewModelFOV = 55,
}

-- Holdtype
SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "pistol"
SWEP.HoldtypeSights = "revolver"

SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL

SWEP.ActivePos = Vector(0, -2, 1)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.SprintPos = Vector(1, -6, -10)
SWEP.SprintAng = Angle(40, 0, 0)

SWEP.CustomizePos = Vector(15, -5, -5)
SWEP.CustomizeAng = Angle(18.2, 39.4, 14.8)

SWEP.HolsterPos = Vector(4, -3, 2)
SWEP.HolsterAng = Vector(-15, 30, -15)

-- Attachments
SWEP.DefaultElements = {"a180", "muzzle"}
SWEP.AttachmentElements = {
    ["a180"] = {
        VMElements = {
            {
                Model = "models/arccw/masita/rising/w_a180.mdl",
                Bone = "v_scoutblaster_reference001",
                Scale = Vector(1, 1, 1),
                Offset = {
                    pos = Vector(1.1, -6.5, 2.1),
                    ang = Angle(0, 180, 0)
                }
            }
        },
    },
    ["muzzle"] = {
        VMElements = {
           {
               Model = "models/hunter/plates/plate.mdl",
               Bone = "v_scoutblaster_reference001",
               Scale = Vector(0, 0, 0),                
               Offset = {
                   pos = Vector(4, -13, -3),
                   ang = Angle(-90, 180, 0)
               },
               IsMuzzleDevice = true
           }
        },
        WMElements = {
            {
                Model = "models/arccw/masita/rising/w_a180.mdl",
                Bone = "ValveBiped.Bip01_R_Hand",
                Scale = Vector(1, 1, 1),
                Offset = {
                    pos = Vector(1000, 0, -430),
                    ang = Angle(0, -90, 180)
                }
            },
            {
                Model = "models/hunter/plates/plate.mdl",
                Bone = "ValveBiped.Bip01_R_Hand",
                Scale = Vector(0, 0, 0),
                Offset = {
                    pos = Vector(1400, 0, -500),
                    ang = Angle(-15, 0, 180)
                },
                IsMuzzleDevice = true
            },            
        },
    }
}WMOverride = "models/arccw/masita/rising/w_a180.mdl"

SWEP.Attachments = {     
    {
        PrintName = "Sight", 
        DefaultAttName = "Iron Sight",
        Slot = "optic",
        Bone = "v_scoutblaster_reference001",
        WMScale = Vector(90, 90, 90),
        VMScale = Vector(0.7, 0.7, 0.7),
        Offset = {
            vpos = Vector(0, -1.3, 2.8),
            vang = Angle(0, 90, 0),
            wpos = Vector(380, 120, -500),
            wang = Angle(0, 0, 180)
        },
        CorrectivePos = Vector(0, 0, 0),
        CorrectiveAng = Angle(0, 180, 0),
    },
    {
        PrintName = "Tactical",
        DefaultAttName = "None",
        Slot = {"tactical", "tac_pistol", "tac"},
        WMScale = Vector(111, 111, 111),
        VMScale = Vector(0.7, 0.7, 0.7),
        Bone = "v_scoutblaster_reference001",
        Offset = {
            vpos = Vector(-0.6, -7, 2.3),
            vang = Angle(-90, 90, 0),
            wpos = Vector(1200, 180, -450),
            wang = Angle(0, 0, -90)
        },
    },
    {
        PrintName = "Energization",
        DefaultAttName = "None",
        Slot = {"ammo"},
    },
    {
        PrintName = "Perk",
        DefaultAttName = "None",
        Slot = "perk",
    },
    {
        PrintName = "Internal Modifications",
        DefaultAttName = "None",
        Slot = {"uc_fg"},
    },    
    {
        PrintName = "Charm",
        DefaultAttName = "None",
        Slot = "charm",
        VMScale = Vector(0.5, 0.5, 0.5),
        WMScale = Vector(80, 80, 80),
        Bone = "v_scoutblaster_reference001",
        Offset = {
            vpos = Vector(-1, 0.5, 2.7),
            vang = Angle(0, 90, 0),
            wpos = Vector(230, 220, -490),
            wang = Angle(0 , 0, 180)
        },
    },    
    {
        PrintName = "Killcounter",
        DefaultAttName = "None",
        Slot = "killcounter",
        VMScale = Vector(0.8, 0.8, 0.8),
        WMScale = Vector(80, 80, 80),
        Bone = "v_scoutblaster_reference001",
        Offset = {
            vpos = Vector(-1, -2.5, 1.8),
            vang = Angle(0, 90, 0),
            wpos = Vector(750, 190, -350),
            wang = Angle(0 , 0, 180)
        },
    },   
}

-- Don't touch this unless you know what you're doing
SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
    },
	["fire"] = {
        Source = {"shoot1", "shoot2", "shoot3"},
    },
    ["fire_iron"] = {
        Source = false,
    },
    ["reload"] = {
        Source = "reload",
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        LHIK = true,
        SoundTable = {
            {s = "weapon_hand/reloading/overheat/overheat_overheated_var_02.mp3", t = 1/30},
            {s = "weapon_hand/reloading/reset/overheatactivecoolingsupersuccess_var_01.mp3", t = 60/30},
        },
    },
    ["draw"] = {
        Source = "draw",
        SoundTable = {
            {
                s = "weapons/draw_pistol.wav", -- sound; can be string or table
                p = 100, -- pitch
                v = 75, -- volume
                t = 0, -- time at which to play relative to Animations.Time
                c = CHAN_ITEM, -- channel to play the sound
            },
        }
    },
    ["holster"] = {
        Source = "holster",
        SoundTable = {
            {
                s = "weapons/draw_pistol.wav", -- sound; can be string or table
                p = 100, -- pitch
                v = 75, -- volume
                t = 0, -- time at which to play relative to Animations.Time
                c = CHAN_ITEM, -- channel to play the sound
            },
        }
    },
}