AddCSLuaFile()

SWEP.Base = "arccw_imperialmasita_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Slot = 2 -- Change this if you want to select the weapon with other number

-- Trivia
SWEP.Category = "[ArcCW 2.0] Empire Essentials"
SWEP.Credits = "Kraken AKA Masita"
SWEP.PrintName = "Pistol A-280CFE"
SWEP.Trivia_Class = "Convertible Heavy Pistol"
SWEP.Trivia_Desc = "The A280-CFE (covert field edition) convertible heavy blaster pistol, also known as an A280-CFE blaster rifle or simply a A280-CFE blaster, was a modular version of the A280 blaster rifle. It featured a core pistol that could be reconfigured into an assault rifle or sniper rifle. Captain Cassian Andor used an A280-CFE during the Battle on Jedha, the mission to Eadu, and the Battle of Scarif."
SWEP.Trivia_Manufacturer = "BlastTech Industries"
SWEP.Trivia_Calibre = "Condensed Tibanna-Gas"
SWEP.IconOverride = "entities/masita/a280cfe_pistol.png"

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
SWEP.Damage = 29
SWEP.RangeMin = 123
SWEP.DamageMin = 20
SWEP.Range = 288
SWEP.Penetration = 8
SWEP.DamageType = DMG_BULLET
SWEP.MuzzleVelocity = 900

SWEP.BodyDamageMults =  {
     [HITGROUP_HEAD] = 2.5,
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
SWEP.Primary.ClipSize = 20
SWEP.ExtendedClipSize = 28
SWEP.ReducedClipSize = 12

SWEP.MaxRecoilBlowback = 1
SWEP.VisualRecoilMult = 1
SWEP.Recoil = 1.26
SWEP.RecoilSide = 0.34
SWEP.RecoilRise = 0.98
SWEP.RecoilPunch = 1

SWEP.Delay = 60 / 203
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
SWEP.HipDispersion = 500
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

SWEP.FirstShootSound = "weapons/a280cfe/blasters_a280-cfe_laser_close_var_01.mp3"
SWEP.ShootSound = "weapons/a280cfe/blasters_a280-cfe_laser_close_var_01.mp3"
SWEP.ShootSoundSilenced = "weapons/silenced.wav"

SWEP.NoFlash = nil
SWEP.MuzzleEffect = "wpn_muzzleflash_dc17_red"
SWEP.FastMuzzleEffect = false
SWEP.GMMuzzleEffect = false
SWEP.MuzzleFlashColor = Color(250, 0, 0)

-- Ironsight
SWEP.IronSightStruct = {
    Pos = Vector(-3.65, -13.179, 1),
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
SWEP.DefaultElements = {"a280cfe", "muzzle"}
SWEP.AttachmentElements = {
    ["a280cfe"] = {
        VMElements = {
            {
                Model = "models/arccw/masita/rising/w_a280cfe.mdl",
                Bone = "v_scoutblaster_reference001",
                Scale = Vector(1.1, 1.1, 1.1),
                Offset = {
                    pos = Vector(0.97, -6.5, 2.3),
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
                Model = "models/arccw/masita/rising/w_a280cfe.mdl",
                Bone = "ValveBiped.Bip01_R_Hand",
                Scale = Vector(1.3, 1.3, 1.3),
                Offset = {
                    pos = Vector(1100, 0, -480),
                    ang = Angle(0, -90, 180)
                }
            },
            {
                Model = "models/hunter/plates/plate.mdl",
                Bone = "ValveBiped.Bip01_R_Hand",
                Scale = Vector(0, 0, 0),
                Offset = {
                    pos = Vector(1400, 0, -600),
                    ang = Angle(-15, 0, 180)
                },
                IsMuzzleDevice = true
            },            
        },
    }
}WMOverride = "models/rising/w_x8.mdl"

SWEP.Attachments = {     
    {
        PrintName = "Sight", 
        DefaultAttName = "Iron Sight",
        Slot = "optic",
        Bone = "v_scoutblaster_reference001",
        WMScale = Vector(90, 90, 90),
        VMScale = Vector(0.7, 0.7, 0.7),
        Offset = {
            vpos = Vector(-0.220, -3, 3.8),
            vang = Angle(0, 90, 0),
            wpos = Vector(500, 160, -680),
            wang = Angle(0, 0, 180)
        },
        CorrectivePos = Vector(0, 0, 0),
        CorrectiveAng = Angle(0, 180, 0),
    },
    {
        PrintName = "Tactical",
        DefaultAttName = "None",
        Slot = {"tactical", "tac_pistol", "tac"},
        WMScale = Vector(80, 80, 80),
        VMScale = Vector(0.7, 0.7, 0.7),
        Bone = "v_scoutblaster_reference001",
        Offset = {
            vpos = Vector(-0.6, -5, 2.9),
            vang = Angle(-90, 90, 0),
            wpos = Vector(1200, 210, -540),
            wang = Angle(0, 0, -90)
        },
    },
    {
        PrintName = "Muzzle",
        DefaultAttName = "None",
        Slot = {"muzzle", "cr2_muzzle", "cr2c_muzzle", "stealth_muzzle"},
        WMScale = Vector(111, 111, 111),
        Bone = "v_scoutblaster_reference001",
        Offset = {
            vpos = Vector(-0.2, -9.8, 2.65),
            vang = Angle(0, 90, 0),
            wpos = Vector(1540, 155, -535),
            wang = Angle(0, 0, 180)
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
        WMScale = Vector(111, 111, 111),
        Bone = "v_scoutblaster_reference001",
        Offset = {
            vpos = Vector(-0.9, -5.3, 1.3),
            vang = Angle(0, 90, 0),
            wpos = Vector(950, 220, -340),
            wang = Angle(0 , 0, 180)
        },
    },    
    {
        PrintName = "Killcounter",
        DefaultAttName = "None",
        Slot = "killcounter",
        VMScale = Vector(0.8, 0.8, 0.8),
        WMScale = Vector(111, 111, 111),
        Bone = "v_scoutblaster_reference001",
        Offset = {
            vpos = Vector(-0.7, -2, 2),
            vang = Angle(0, 90, 0),
            wpos = Vector(550, 220, -400),
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