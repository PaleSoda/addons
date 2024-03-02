AddCSLuaFile()

SWEP.Base = "arccw_meeks_sw_base"
SWEP.Spawnable = true
SWEP.Category = "[ ArcCW ] Meek's Misc Weapons"
SWEP.Credits = { Author1 = "cat"}
SWEP.PrintName = "Z-6"
SWEP.Trivia_Class = "Rotary Blaster Cannon"
SWEP.Trivia_Desc = "A powerful chain gun."
SWEP.Trivia_Manufacturer = "BlasTech Industries"
SWEP.Trivia_Calibre = "Heavy Density Bolt"
SWEP.Trivia_Mechanism = "Energized Compressed Tibanna"
SWEP.Trivia_Country = "GAR"
SWEP.Trivia_Year = 2020

SWEP.Slot = 3

SWEP.UseHands = true

SWEP.ViewModel = "models/starwars/grady/props/weapons/z6-rotatory-blaster.mdl"
SWEP.WorldModel = "models/arccw/bf2017/w_t21.mdl"
SWEP.ViewModelFOV = 60
SWEP.HideViewmodel = false
SWEP.WorldModelOffset = {
    pos = Vector(0, 0, 0),
    ang = Angle(0, 0, 0),
    bone = "ValveBiped.Bip01_R_Hand",
    scale = 0.009
}

SWEP.IconOverride = "materials/entities/rw_sw_z6.png"

SWEP.DefaultBodygroups = "000000000000"

SWEP.Damage = 25
SWEP.RangeMin = 120
SWEP.DamageMin = 11
SWEP.Range = 350
SWEP.Penetration = 1
SWEP.DamageType = DMG_BULLET
SWEP.MuzzleVelocity = 400


SWEP.TraceNum = 1
SWEP.PhysTracerProfile = 1

SWEP.TracerNum = 1
SWEP.Tracer = "tfa_tracer_blue"
SWEP.TracerCol = Color(0, 0, 255)
SWEP.HullSize = 1

SWEP.ChamberSize = 0
SWEP.Primary.ClipSize = 150

SWEP.Recoil = 0.28
SWEP.RecoilSide = 0.25
SWEP.RecoilPunch = 2
SWEP.VisualRecoilMult = 0
SWEP.RecoilRise = 0.34

SWEP.Hook_ModifyRPM = function(wep, delay)
    return delay / Lerp(wep:GetBurstCount() / 15, 1, 3)
end

SWEP.Delay = 60 / 330
SWEP.Num = 1

SWEP.BobMult = 1

SWEP.TriggerDelay = true

SWEP.Firemodes = {
    {
        Mode = 2,
    },
    {
        Mode = 2,
        Mult_RPM = 2800 / 2400,
        PrintName = "2800RPM"
    },
    {
        Mode = 0
    }
}

SWEP.AccuracyMOA = 0.55 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 330 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 50

SWEP.Bipod_Integral = true -- Integral bipod (ie, weapon model has one)
SWEP.BipodDispersion = 0.8 -- Bipod dispersion for Integral bipods
SWEP.BipodRecoil = 0.5 -- Bipod recoil for Integral bipods

SWEP.NoFlash = nil -- disable light flash
SWEP.MuzzleEffect = "wpn_muzzleflash_dc17"
SWEP.FastMuzzleEffect = nil
SWEP.GMMuzzleEffect = false --
SWEP.MuzzleFlashColor = Color(0, 0, 255)

SWEP.SpeedMult = 0.5
SWEP.SightedSpeedMult = 0.8
SWEP.SightTime = 1

----AMMO / stuff----

SWEP.Primary.Ammo = "ar2"

SWEP.ShootVol = 100
SWEP.ShootPitch = 100
SWEP.ShootPitchVariation = 0.02

SWEP.ShootSound = "weapons/z6/SW02_Blasters_Z6RotaryBlaster_Laser_Close_VAR_01.wav"
SWEP.ShootSoundSilenced = "w/dc19.wav"

SWEP.IronSightStruct = {
    Pos = Vector(0, -12, -4),
    Ang = Angle(0, 0, 0),
    Magnification = 1,
    SwitchToSound = "zoom_in/gunfoley_zoomin_blasterheavy_05.mp3",
    CrosshairInSights = true
}
SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "crossbow"
SWEP.HoldtypeSights = "smg"

SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN

SWEP.ActivePos = Vector(0, -0, -3)
SWEP.ActiveAng = Angle(0, 2, 0)

SWEP.SprintPos = Vector(5, -30, -20)
SWEP.SprintAng = Angle(40, 0, -10)

SWEP.HolsterPos = Vector(4, -3, 2)
SWEP.HolsterAng = Vector(-15, 30, -15)

SWEP.CustomizePos = Vector(20.824, -4, -4.897)
SWEP.CustomizeAng = Angle(12.149, 30.547, 0)


SWEP.DefaultElements = {"nil"}
SWEP.AttachmentElements = {
    ["nil"] = {
         VMElements = {},
        WMElements = {
            {
                Model = "models/starwars/grady/props/weapons/z6-rotatory-blaster.mdl",
                Bone = "ValveBiped.Bip01_R_Hand",
                Scale = Vector(1, 1, 1),
                Offset = {
                    pos = Vector(-2000, 1000, -800),
                    ang = Angle(-10, 0, 180)
                }
            },
            {
                Model = "models/hunter/plates/plate.mdl",
                Bone = "ValveBiped.Bip01_R_Hand",
                Scale = Vector(0, 0, 0),
                Offset = {
                    pos = Vector(4500, 0, -900),
                    ang = Angle(-15, 0, 180)
                },
                IsMuzzleDevice = true
            },            
        }, -- change the world model to something else. Please make sure it's compatible with the last one.
    }
}

WMOverride = "models/starwars/grady/props/weapons/z6-rotatory-blaster.mdl"

SWEP.Jamming = true
SWEP.HeatGain = 0.95 -- heat gained per shot
SWEP.HeatCapacity = 75 -- rounds that can be fired non-stop before the gun jams, playing the "fix" animation
SWEP.HeatDissipation = 10 -- rounds' worth of heat lost per second
SWEP.HeatLockout = true -- overheating means you cannot fire until heat has been fully depleted
SWEP.HeatDelayTime = 0.5

--SWEP.Attachments 
SWEP.Attachments = {                 
    [1] = {
        PrintName = "Energization", -- print name
        DefaultAttName = "Standard Energization", -- used to display the "no attachment" text
        Slot = "ammo",
    },
    [2] = {
        PrintName = "Training/Perk", -- print name
        DefaultAttName = "None", -- used to display the "no attachment" text
        Slot = "perk",
    },          
}
SWEP.Animations = {
    ["idle"] = {
        Source = "idle"
    },
    ["fire"] = {
        Source = {"fire_1","fire_2", "fire_3"},
        Time = 0.4
    },
    ["draw"] = {
        Source = "draw",
        Time = 1.6,
        SoundTable = {
            {
                s = "draw/blasters_deathray_foley_undeploy_var_03.mp3", -- sound; can be string or table
                p = 100, -- pitch
                v = 200, -- volume
                t = 0, -- time at which to play relative to Animations.Time
                c = CHAN_ITEM, -- channel to play the sound
            },
        }
    },
    ["holster"] = {
        Source = "holster",
        SoundTable = {
            {
                s = "holster/blasters_deathray_foley_undeploy_var_02.mp3", -- sound; can be string or table
                p = 100, -- pitch
                v = 75, -- volume
                t = 0, -- time at which to play relative to Animations.Time
                c = CHAN_ITEM, -- channel to play the sound
            },
        }
    },
    ["trigger"] = {
        Source = {"fire_2"},
        SoundTable = {
        {s = "weapons/z6/SW02_Blasters_Z6RotaryBlaster_Start_Short_VAR_01.ogg", v = 75,t = 0 / 30, c = CHAN_ITEM},
        },
        Time = 0.9,
    },
    ["reload"] = {
        Source = "reload", 
        Time = 3.54,
        SoundTable = {
            {s = "weapons/z6/blasters_deathray_foley_undeploy_var_03.mp3", t = 0},
            {s = "weapons/z6/overheat_overheated_var_01.mp3", t = 1} --s sound file
        },
    },


sound.Add({
    name =          "ArcCW_z6.reload2",
    channel =       CHAN_ITEM,
    volume =        1.0,
    sound =             "weapons/bf3/heavy.wav"
    }),


sound.Add({
    name =          "ArcCW_z6.reload1",
    channel =       CHAN_ITEM,
    volume =        1.0,
    sound =             "weapons/z6/SW02_Blasters_Z6RotaryBlaster_Stop_03.wav"
    }),
}