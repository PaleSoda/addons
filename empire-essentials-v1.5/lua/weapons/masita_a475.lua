AddCSLuaFile()

SWEP.Base = "arccw_imperialmasita_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Slot = 3 -- Change this if you want to select the weapon with other number

-- Trivia
SWEP.Category = "[ArcCW 2.0] Empire Essentials"
SWEP.Credits = "Kraken AKA Masita"
SWEP.PrintName = "A-475"
SWEP.Trivia_Class = "Heavy Blaster Rifle"
SWEP.Trivia_Desc = "The A475 blaster rifle was a type of blaster rifle in use around 34 ABY. It was prone to overheating. It had a foldable shoulder stock, which was rarely used considering it was made more for close combat. The blaster was favored by the Guavian Death Gang. Overheating commonly caused malfunctions in the blaster, causing its use to be ceased."
SWEP.Trivia_Manufacturer = "BlastTech Industries"
SWEP.Trivia_Calibre = "Condensed Tibanna-Gas"
SWEP.IconOverride = "entities/masita/a475.png"

-- Viewmodel & Entity Properties
SWEP.HideViewmodel = false
SWEP.UseHands = true
SWEP.ViewModel = "models/arccw/weapons/synbf3/c_dlt19.mdl"
SWEP.WorldModel = "models/arccw/weapons/synbf3/w_dlt19.mdl"
SWEP.ViewModelFOV = 68
SWEP.HideViewmodel = true
SWEP.WorldModelOffset = {
    pos = Vector(0, 0, 0),
    ang = Angle(0, 0, 0),
    bone = "ValveBiped.Bip01_R_Hand",
    scale = 0.009
}

-- Damage & Tracer
SWEP.Damage = 37
SWEP.RangeMin = 243
SWEP.DamageMin = 23
SWEP.Range = 365
SWEP.Penetration = 8
SWEP.DamageType = DMG_BULLET
SWEP.MuzzleVelocity = 900

SWEP.BodyDamageMults =  {
     [HITGROUP_HEAD] = 2.1,
     [HITGROUP_CHEST] = 1,
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
SWEP.ExtendedClipSize = 100
SWEP.ReducedClipSize = 50

SWEP.MaxRecoilBlowback = 1
SWEP.VisualRecoilMult = 1
SWEP.Recoil = 1.28
SWEP.RecoilSide = 0.2
SWEP.RecoilRise = 0.76
SWEP.RecoilPunch = 1

SWEP.Delay = 60 / 620
SWEP.Num = 1
SWEP.Firemode = 1
SWEP.Firemodes = {
    {
		Mode = -3,
        PrintName = "BURST-PLASMA",
    },
    {
		Mode = 1,
        PrintName = "SINGLE-PLASMA",
    },
	{
		Mode = 0,
   	}
}

SWEP.AccuracyMOA = 1
SWEP.HipDispersion = 450
SWEP.MoveDispersion = 125 
SWEP.SightsDispersion = 0 
SWEP.JumpDispersion = 200

-- Speed Mult
SWEP.SpeedMult = 0.9
SWEP.SightedSpeedMult = 0.77
SWEP.ShootSpeedMult = 1

-- Ammo, Sounds & MuzzleEffect
SWEP.Primary.Ammo = "ar2"
SWEP.ShootVol = 120
SWEP.ShootPitch = 100
SWEP.ShootPitchVariation = 0.2

SWEP.FirstShootSound = "weapons/a475/style_2/a475_1.mp3"
SWEP.ShootSound = "weapons/a475/style_2/a475_2.mp3"
SWEP.ShootSoundSilenced = "weapons/silenced.wav"

SWEP.NoFlash = nil
SWEP.MuzzleEffect = "wpn_muzzleflash_dc17_red"
SWEP.FastMuzzleEffect = false
SWEP.GMMuzzleEffect = false
SWEP.MuzzleFlashColor = Color(250, 0, 0)

-- Ironsight
SWEP.IronSightStruct = {
    Pos = Vector(-3.375, -6, 1.2),
    Ang = Angle(-1.678, -0.378, 0),
     Magnification = 1.5,
     SwitchToSound = "weapon_hand/ads/0242-00001a46.mp3",
     SwitchFromSound = "weapon_hand/ads/0242-00001a43.mp3",
     ViewModelFOV = 55,
}

-- Special Properties
SWEP.Jamming = true
SWEP.HeatGain = 1
SWEP.HeatCapacity = 25
SWEP.HeatDissipation = 5
SWEP.HeatLockout = true
SWEP.HeatDelayTime = 0.3
SWEP.HeatFix = false
SWEP.HeatOverflow = nil

-- Holdtype
SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "shotgun"
SWEP.HoldtypeSights = "ar2"
SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2

SWEP.ActivePos = Vector(0, 0, 0)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.SprintPos = Vector(4.019, -5.226, -3)
SWEP.SprintAng = Angle(5, 40, 0)

SWEP.CustomizePos = Vector(15, 0, -1.321)
SWEP.CustomizeAng = Angle(18.2, 39.4, 14.8)

SWEP.HolsterPos = Vector(4, -3, 0)
SWEP.HolsterAng = Vector(-15, 30, -15)

SWEP.Bipod_Integral = true
SWEP.BipodDispersion = 1
SWEP.BipodRecoil = 1

-- Attachments
SWEP.DefaultElements = {"a475", "muzzle"}
SWEP.AttachmentElements = {
    ["a475"] = {
        VMElements = {
            {
                Model = "models/arccw/masita/rising/w_a475.mdl",
                Bone = "v_dlt19_reference001",
                Scale = Vector(1, 1, 1),
                Offset = {
                    pos = Vector(-0.9, 5.9, 2),
                    ang = Angle(0, 0.65, -2)
                }
            }
        },
    },
    ["muzzle"] = {
        VMElements = {
           {
               Model = "models/hunter/plates/plate.mdl",
               Bone = "v_dlt19_reference001",
               Scale = Vector(0, 0, 0),                
               Offset = {
                   pos = Vector(0, 16, 0),
                   ang = Angle(-90, 180, 0)
               },
               IsMuzzleDevice = true
           }
        },
        WMElements = {
            {
                Model = "models/arccw/masita/rising/w_a475.mdl",
                Bone = "ValveBiped.Bip01_R_Hand",
                Scale = Vector(1.2, 1.2, 1.2),
                Offset = {
                    pos = Vector(1100, -100, -480.5),
                    ang = Angle(0, -90, 180)
                }
            },
            {
                Model = "models/hunter/plates/plate.mdl",
                Bone = "ValveBiped.Bip01_R_Hand",
                Scale = Vector(0, 0, 0),
                Offset = {
                    pos = Vector(3400, 0, -550),
                    ang = Angle(0, 0, 180)
                },
                IsMuzzleDevice = true
            },            
        },
    }
}WMOverride = "models/arccw/masita/rising/w_a475.mdl"

SWEP.Attachments = {     
    {
        PrintName = "Sight", 
        DefaultAttName = "Iron Sight",
        Slot = "optic",
        Bone = "v_dlt19_reference001",
        WMScale = Vector(111, 111, 111),
        Offset = {
            vpos = Vector(0.3, 3, 4.3),
            vang = Angle(0, -90, 0),
            wpos = Vector(850, 90, -820),
            wang = Angle(0 , 0, 180)
        },
        CorrectiveAng = Angle(0, 180, 0),
    },
    {
        PrintName = "Tactical",
        DefaultAttName = "None",
        Slot = {"tactical", "tac_pistol", "tac"},
        WMScale = Vector(111, 111, 111),
        VMScale = Vector(1, 1, 1),
        Bone = "v_dlt19_reference001",
        Offset = {
            vpos = Vector(1.4, 14, 1),
            vang = Angle(0, -90, 90),
            wpos = Vector(3800, 190, -525),
            wang = Angle(0, 0, -90)
        },
    },
    {
        PrintName = "Muzzle",
        DefaultAttName = "None",
        Slot = {"muzzle", "cr2_muzzle", "cr2c_muzzle", "stealth_muzzle"},
        WMScale = Vector(130, 130, 130),
        Bone = "v_dlt19_reference001",
        Offset = {
            vpos = Vector(0.5, 25.8, 3),
            vang = Angle(0, -90, 0),
            wpos = Vector(3900, 60, -620),
            wang = Angle(0, 0, 0)
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
        VMScale = Vector(0.8, 0.8, 0.8),
        WMScale = Vector(111, 111, 111),
        Bone = "v_dlt19_reference001",
        Offset = {
            vpos = Vector(1.8, 8.3, 2.8),
            vang = Angle(0, -90, 0),
            wpos = Vector(1520, 260, -625),
            wang = Angle(0 , 0, 180)
        },
    },    
    {
        PrintName = "Killcounter",
        DefaultAttName = "None",
        Slot = "killcounter",
        VMScale = Vector(0.8, 0.8, 0.8),
        WMScale = Vector(111, 111, 111),
        Bone = "v_dlt19_reference001",
        Offset = {
            vpos = Vector(1.4, 0, 2.5),
            vang = Angle(0, -90, 0),
            wpos = Vector(400, 200, -620),
            wang = Angle(0, 0, 180)
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
            {s = "weapon_hand/reloading/reset/overheatactivecoolingsupersuccess_var_01.mp3", t = 80/30},
        },
    },
    ["draw"] = {
        Source = "draw",
        SoundTable = {
            {
                s = "weapons/draw_rifle.wav", -- sound; can be string or table
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
                s = "weapons/draw_rifle.wav", -- sound; can be string or table
                p = 100, -- pitch
                v = 75, -- volume
                t = 0, -- time at which to play relative to Animations.Time
                c = CHAN_ITEM, -- channel to play the sound
            },
        }
    },
}