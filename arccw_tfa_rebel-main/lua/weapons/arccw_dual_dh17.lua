AddCSLuaFile()

SWEP.Base = "arccw_meeks_sw_base"
SWEP.Spawnable = true
SWEP.Category = "[ ArcCW ] Rebels TFA Weapons"
SWEP.Credits = { Author1 = "cat"}
SWEP.PrintName = "Dual DH-17"
SWEP.Trivia_Class = "Rebel Dual Blaster Pistol"
SWEP.Trivia_Desc = "Preffered for CQB enviroments and general allround usage."
SWEP.Trivia_Manufacturer = "Forged Armory"
SWEP.Trivia_Calibre = "Low Density Bolt"
SWEP.Trivia_Mechanism = "Energized Compressed Tibanna"
SWEP.Trivia_Country = "GAR"
SWEP.Trivia_Year = 2020

SWEP.Slot = 1

SWEP.UseHands = true

SWEP.ViewModel = "models/arccw/strasser/weapons/c_ddeagle.mdl"
SWEP.WorldModel = "models/arccw/bf2017/w_scoutblaster.mdl"
SWEP.ViewModelFOV = 90
SWEP.HideViewmodel = true
SWEP.WorldModelOffset = {
    pos = Vector(0, 0, 0),
    ang = Angle(0, 0, 0),
    bone = "ValveBiped.Bip01_R_Hand",
    scale = 0.09
}

SWEP.IconOverride = "materials/entities/rw_sw_dual_dh17a.png"

SWEP.DefaultBodygroups = "000000000000"

SWEP.Damage = 30
SWEP.RangeMin = 180
SWEP.DamageMin = 17
SWEP.Range = 450
SWEP.Penetration = 1
SWEP.DamageType = DMG_BULLET
SWEP.MuzzleVelocity = 400


SWEP.TraceNum = 1
SWEP.PhysTracerProfile = 1

SWEP.TracerNum = 1
SWEP.Tracer = "tfa_tracer_red"
SWEP.TracerCol = Color(250, 0, 0)
SWEP.HullSize = 1.5

SWEP.ChamberSize = 0
SWEP.Primary.ClipSize = 30

SWEP.Recoil = 0.4
SWEP.RecoilPunch = 0.34
SWEP.RecoilSide = 0.27
SWEP.RecoilRise = 0.22

SWEP.Delay = 60 / 300
SWEP.Num = 1
SWEP.Firemodes = {
	{
		Mode = 1
	},
    {
        Mode = 2
    },
    {
        Mode = 0
    }        
}

SWEP.AccuracyMOA = 0.55 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 500 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 50


----AMMO / stuff----

SWEP.Primary.Ammo = "ar2"

SWEP.ShootVol = 100
SWEP.ShootPitch = 100

SWEP.ShootSound = "w/dh17/dh17_1.wav"

SWEP.MuzzleFlashColor = Color(255, 0, 0, 50)

SWEP.IronSightStruct = {
    Pos = Vector(0, -4, 1),
    Ang = Angle(0, 0, 0),
     Magnification = 1,
     SwitchToSound = "",
     ViewModelFOV = 90,
}
SWEP.HoldtypeHolstered = ""
SWEP.HoldtypeActive = "duel"
SWEP.HoldtypeSights = ""


SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2

SWEP.ActivePos = Vector(0, -5, -1)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.SprintPos = Vector(0, -14,-10)
SWEP.SprintAng = Angle(40, 0, 0)

SWEP.HolsterPos = Vector(0.532, -6, 0)
SWEP.HolsterAng = Vector(-25, 0, 0)

SWEP.ReloadPos = Vector(0, -10, -5)

SWEP.CustomizePos = Vector(-0.5, -8, -4.897)
SWEP.CustomizeAng = Angle(30, 0, 0)

SWEP.InBipodPos = Vector(-8, 0, -4)
SWEP.InBipodMult = Vector(2, 1, 1)
SWEP.DrawCrosshair = true

SWEP.BarrelLength = 60
SWEP.BarrelOffsetSighted = Vector(0, 0, 0)
SWEP.BarrelOffsetHip = Vector(3, 0, -3)
SWEP.DefaultElements = {"dh17", "dh17+"}

SWEP.AttachmentElements = {
    ["dh17"] = {
        VMElements = {
            {
                Model = "models/arccw/sw_battlefront/weapons/dh17_noscope.mdl",
                Bone = "LeftHand_1stP",
                Scale = Vector(1, 1, 1),
                Offset = {
                    pos = Vector(4, -1.9, -1),
                    ang = Angle(-4, -2, 90)
                }
            }
        },
    },
    ["dh17+"] = {
         VMElements = {
            {
                Model = "models/arccw/sw_battlefront/weapons/dh17_noscope.mdl",
                Bone = "RightHand_1stP",
                Scale = Vector(1, 1, 1),                
                Offset = {
                    pos = Vector(-4, 1.2, 1.5),
                    ang = Angle(-4, 178, 90)
                }
            }
        }, 
        WMElements = {
            {
                Model = "models/arccw/sw_battlefront/weapons/dh17_noscope.mdl",
                Bone = "ValveBiped.Bip01_R_Hand",
                Scale = Vector(1.1, 1.1, 1.1),
                Offset = {
                    pos = Vector(40, 10, 20.75),
                    ang = Angle(180, -180, 2)
                }
            },
            {
                Model = "models/arccw/sw_battlefront/weapons/dh17_noscope.mdl",
                Bone = "ValveBiped.Bip01_L_Hand",
                Scale = Vector(1.1, 1.1, 1.1),
                Offset = {
                    pos = Vector(-40, 230, -25),
                    ang = Angle(180, -180, 2)
                }
            },
        },            -- change the world model to something else. Please make sure it's compatible with the last one.
    }
}
WMOverride = "models/arccw/sw_battlefront/weapons/dh17_noscope.mdl"

--SWEP.Attachments 
SWEP.Attachments = {
    [1] = {
        PrintName = "Tactical", -- print name
        DefaultAttName = "No Attachment", -- used to display the "no attachment" text
        Slot = {"tactical","tac_pistol"},
        Bone = "RightHand_1stP", -- relevant bone any attachments will be mostly referring to
        Offset = {
            vpos = Vector(-12, -4, 2.5),
            vang = Angle(170, 0, 0),
        },
    },    
    [2] = {
        PrintName = "Energization", -- print name
        DefaultAttName = "Standard Energization", -- used to display the "no attachment" text
        Slot = "ammo",
    }
}


SWEP.Animations = {
    ["idle"] = {
        Source = "idle"
    },
    ["fire"] = {
        Source = {"shoot_lw", "shoot_rw"},
    },
    ["draw"] = {
        Source = "draw",
        Mult = 1.5,
        SoundTable = {
            {
                s = "draw/gunfoley_pistol_draw_var_10.mp3", -- sound; can be string or table
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
                s = "holster/gunfoley_pistol_sheathe_var_09.mp3", -- sound; can be string or table
                p = 100, -- pitch
                v = 75, -- volume
                t = 0, -- time at which to play relative to Animations.Time
                c = CHAN_ITEM, -- channel to play the sound
            },
        }
    },
    ["reload"] = {
        Source = "reload", 
        Time = 3.35,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_PHYSGUN,
        SoundTable = {
            {s = "ArcCW_dc17.reload2", t = 4 / 30}, --s sound file
        },
    },


sound.Add({
    name =          "ArcCW_dc17.reload2",
    channel =       CHAN_ITEM,
    volume =        1.0,
    sound =             "weapons/bf3/pistols.wav"
    }),
}