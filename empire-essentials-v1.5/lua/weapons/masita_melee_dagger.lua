SWEP.Base = "arccw_base_melee"
SWEP.Spawnable = true
SWEP.Category = "[ArcCW 2.0] Empire Essentials - Melee"
SWEP.AdminOnly = false

SWEP.PrintName = "Electro Dagger"
SWEP.Trivia_Class = "Melee Weapon"
SWEP.Trivia_Desc = "An electro dagger was a vibroknife-like melee weapon manufactured by Baktoid Armor Workshop and Holowan Mechanical."
SWEP.Trivia_Manufacturer = "Galactic Empire"
SWEP.IconOverride = "entities/masita/dagger.png"

SWEP.Slot = 0
SWEP.NPCWeaponType = "weapon_crowbar"
SWEP.NPCWeight = 250

SWEP.MuzzleEffectAttachment = 1
SWEP.CaseEffectAttachment = 2
SWEP.CamAttachment = 3

SWEP.UseHands = true
SWEP.HideViewmodel = true
SWEP.ViewModelFOV = 90 
SWEP.ViewModel = "models/arccw/masita/weapons/melee/c_apex_melee_wraith.mdl"
SWEP.WorldModel = "models/arccw/masita/rising/inqusitor_dagger.mdl"
SWEP.WorldModelOffset = {
    pos = Vector(0, 0, 0),
    ang = Angle(0, 0, 0),
    bone = "ValveBiped.Bip01_R_Hand",
    scale = 0.009
}

SWEP.SprintPos = Vector(0, -2, 1)
SWEP.SprintAng = Angle(0, 0, 0)

SWEP.ActivePos = Vector(0, -2, 1)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.CustomizePos = Vector(0, -2, 1)
SWEP.CustomizeAng = Angle(0, 0, 0)

SWEP.CrouchPos = Vector(0, -2, -1)
SWEP.CrouchAng = Angle(0, 0, 0)

SWEP.ImpactEffect = "StunstickImpact"
SWEP.MeleeGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.ShootWhileSprint = true
SWEP.NotForNPCs = true

SWEP.Firemodes = {
    {
        Mode = 1,
        PrintName = "ELECTRO"
    },
}

SWEP.PrimaryBash = true
SWEP.CanBash = true
SWEP.MeleeDamage = 25
SWEP.MeleeRange = 45
SWEP.MeleeDamageType = DMG_SHOCK + DMG_AIRBOAT + DMG_GENERIC + DMG_CLUB

SWEP.MeleeHitSound = "melee/new/wraith/generic_kunaiimpact_1p_vs_3p_2.ogg"
SWEP.MeleeHitNPCSound = "melee/new/wraith/generic_kunaiimpact_1p_vs_3p_5.ogg"
SWEP.MeleeMissSound = "melee/new/wraith/wraith_mvmt_melee_kunai_swipe_1.ogg"
SWEP.MeleeSwingSound = "melee/new/wraith/wraith_mvmt_melee_kunai_swipe_3.ogg"

SWEP.MeleeTime = 1
SWEP.MeleeAttackTime = 0.35*0.75
SWEP.Delay = 60 / 670

SWEP.Lunge = true
SWEP.LungeLength = 72

SWEP.Melee2 = true
SWEP.Melee2Damage = 55
SWEP.Melee2DamageBackstab = 100
SWEP.Melee2Range = 30
SWEP.Melee2Time = 1
SWEP.Melee2Gesture = nil
SWEP.Melee2AttackTime = 0.25

SWEP.Backstab = true
SWEP.BackstabMultiplier = 2

SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "melee2"
SWEP.DrawCrosshair = true
SWEP.IronSightStruct = false
SWEP.ShootWhileSprint = false

SWEP.Primary.ClipSize = -1
SWEP.ActivePos = Vector(0, 1, 0)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.NoHideLeftHandInCustomization = false
SWEP.DefaultElements = {"melee"}
SWEP.AttachmentElements = {
    ["melee"] = {
        VMElements = {
            {
                Model = "models/arccw/masita/rising/inqusitor_dagger.mdl",
                Bone = "def_magazine",
                Scale = Vector(0.69, 0.69, 0.69),
                Offset = {
                    pos = Vector(-0.038, -4.572, 0.635),
                    ang = Angle(-1.109, -89.617, 83.041),
                }
            }
        },
        WMElements = {
            {
                Model = "models/arccw/masita/rising/inqusitor_dagger.mdl",
                Bone = "ValveBiped.Bip01_R_Hand",
                Scale = Vector(1, 1, 1),
                Offset = {
                    pos = Vector(670, 180, -670),
                    ang = Angle(-70, -180, 0)
                }
            },     
        },
    }
}WMOverride = "models/arccw/masita/rising/inqusitor_dagger.mdl"

SWEP.Attachments = {     
    {
        PrintName = "Perk",
        DefaultAttName = "None",
        Slot = "perk",
    }, 
}

SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
    },
    ["draw"] = {
        Source = {"draw", "draw2", "draw3"},
        SoundTable = {
            {s = "melee/new/lifeline/lifeline_mvmt_baton_draw_2.ogg", t = 0.1/30},
        },
    },
    ["holster"] = {
        Source = "holster",
        SoundTable = {
            {s = "melee/new/lifeline/lifeline_mvmt_baton_holster.ogg", t = 0.1/30},
        },
    },
    ["ready"] = {
        Source = {"draw_first"},
        SoundTable = {
            {s = "melee/new/lifeline/lifeline_mvmt_baton_draw_2.ogg", t = 0.1/30},
        },
    },
    ["bash"] = {
        Source = {"melee_idle", "melee_slide", "melee_sprint"},
    },
    ["bash2"] = {
        Source = {"melee_idle", "melee_slide", "melee_sprint"},
    },
    ["bash_backstab"] = {
        Source = {"melee_idle", "melee_slide", "melee_sprint"},
    },
    ["bash2_backstab"] = {
        Source = {"melee_idle", "melee_slide", "melee_sprint"},
    },
    ["enter_sprint"] = {
        Source = "inspect_in",
    },
    ["exit_sprint"] = {
        Source = "inspect_out",
    },
    ["idle_sprint"] = {
        Source = "sprint",
    },
    ["enter_inspect"] = {
        Source = "sprint_in",
    },
    ["exit_inspect"] = {
        Source = "sprint_out",
    },
    ["idle_inspect"] = {
        Source = "inspect",
    },
}