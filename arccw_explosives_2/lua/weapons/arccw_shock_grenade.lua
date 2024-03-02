SWEP.Base = "arccw_grenade_base"
SWEP.Spawnable = true -- this obviously has to be set to true
SWEP.Category = "[ ArcCW ] Explosives" -- edit this if you like
SWEP.AdminOnly = false

SWEP.PrintName = "Shock Grenade"
SWEP.Trivia_Class = "Hand Grenade"
SWEP.Trivia_Desc = "Standard Shock ordnance with a timed fuse and a small-medium blast radius."

SWEP.Slot = 4

SWEP.CamAttachment = 3

SWEP.NotForNPCs = true

SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/nade_frag.mdl"
SWEP.WorldModel = "models/weapons/w_nade_frag.mdl"
SWEP.HideViewmodel = true
SWEP.MirrorVMWM = false
SWEP.WorldModelOffset = {
    pos = Vector(0, 0, 0),
    ang = Angle(0, 0, 0),
    scale = 0.09
}

SWEP.Firemodes = {
    {
        Mode = 1,
        PrintName = "fcg.nade",
    },
}

SWEP.IconOverride = "materials/entities/stun_grenade_meeks.png"

SWEP.FuseTime = 2.1

SWEP.Primary.Ammo = "grenade"

SWEP.Primary.ClipSize = 1

SWEP.MuzzleVelocity = 1300
SWEP.MuzzleVelocityAlt = 500
SWEP.ShootEntity = "arccw_thr_ion"

SWEP.PullPinTime = 0.5

SWEP.ViewModelFOV = 70

SWEP.DefaultElements = {"shock_grenade"}

SWEP.AttachmentElements = {
    ["shock_grenade"] = {
        VMElements = {
            {
                Model = "models/arccw/shock_grenade.mdl",
                Bone = "def_c_base",
                Scale = Vector(0.8, 0.8, 0.8),
                Offset = {
                    pos = Vector(-.5, -0.1, -.1),
                    ang = Angle(-35, -190, 90)
                }
            }
        },
        WMElements = {
            {
                Model = "models/arccw/shock_grenade.mdl",
                Bone = "ValveBiped.Bip01_R_Hand",
                Scale = Vector(0.8, 0.8, 0.8),
                Offset = {
                    pos = Vector(35, 25, 0),
                    ang = Angle(0, 0, 0)
                }
            }
        },
    },
}

WMOverride = "models/arccw/shock_grenade.mdl" -- change the world model to something else. Please make sure it's compatible with the last one.

SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
    },
    ["idle_sprint"] = {Source = "sprint", Mult = 0.9},
    ["enter_sprint"] = {Source = "sprint_in", Mult = 0.1},
    ["exit_sprint"] = {Source = "sprint_out", Mult = 0.1},
    ["ready"] = {
        Source = "draw",
        SoundTable = {
           {s = "ArcCW_ThermalDet.firstdeploy1", t = 0 / 30},
        },
    },
    ["draw"] = {
        Source = "draw",
        SoundTable = {
            {s = "misc/gunfoley_blaster_sheathe_var_03.mp3", t = 0 / 30},
        },
    },
    ["holster"] = {
        Source = "holster",
        SoundTable = {
            {s = "ArcCW_ThermalDet.holster1", t = 0 / 30}
        },
    },
    ["pre_throw"] = {
        Source = "pullpin",
        SoundTable = {
            {s = "ArcCW_primer.button", t = 0 / 30},
        },
        MinProgress = 0.5,
    },
    ["fire"] = {
        Source = "pullpin",
        SoundTable = {
            {s = "ArcCW_primer.button", t = 0 / 30},
        },
    },
    ["throw"] = {
        Source = {"toss_overhead"},
        TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE,
    },
    ["throw_alt"] = {
        Source = {"underhand"},
        TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE,
    },
    ["enter_inspect"] = {
        Source = "inspect_in",
        LHIK = true,
    },
    ["exit_inspect"] = {
        Source = "inspect_out",
        LHIK = true,
    },
    ["idle_inspect"] = {
        Source = "inspect",
        LHIK = true,
    },

sound.Add({
    name =          "ArcCW_ThermalDet.holster1",
    channel =       CHAN_ITEM,
    volume =        1.0,
    sound =             "misc/sw01_characters_gunfoley_draw_blaster_var21.mp3"
    }),

sound.Add({
    name =          "ArcCW_ThermalDet.armthrow",
    channel =       CHAN_ITEM,
    volume =        1.0,
    sound =             "weapons/shock/SW02_Weapons_Grenades_Shock_Beep_01.wav"
    }),

sound.Add({
    name =          "ArcCW_ThermalDet.deploy1",
    channel =       CHAN_ITEM,
    volume =        1.0,
    sound =             "misc/gunfoley_blaster_sheathe_var_03.mp3"
    }),
       
sound.Add({
    name =          "ArcCW_ThermalDet.firstdeploy1",
    channel =       CHAN_ITEM,
    volume =        1.0,
    sound =             "misc/sw01_characters_gunfoley_draw_blaster_var19.mp3"
    }),
        
sound.Add({
    name =          "ArcCW_primer.button",
    channel =       CHAN_ITEM,
    volume =        1.0,
    sound =             "w/buttonpress.mp3"
    }),

sound.Add({
    name =          "ArcCW_Underhand.explosion2",
    channel =       CHAN_ITEM,
    volume =        1.0,
    sound =             "w/underhand.mp3"
    }),
}