SWEP.Base = "arccw_base_melee"
SWEP.Spawnable = true
SWEP.Category = "[ArcCW 2.0] Empire Essentials - Melee"
SWEP.AdminOnly = false

SWEP.PrintName = "Preatorian Sword"
SWEP.Trivia_Class = "Melee Weapon"
SWEP.Trivia_Desc = "Melee weapon with good damage. Designed and prepared for Preatorian Guards from the Galactic Empire."
SWEP.Trivia_Manufacturer = "Galactic Empire"
SWEP.IconOverride = "entities/masita/preatorian.png"

SWEP.Slot = 0
SWEP.NPCWeaponType = "weapon_crowbar"
SWEP.NPCWeight = 250

SWEP.MuzzleEffectAttachment = 1
SWEP.CaseEffectAttachment = 2
SWEP.CamAttachment = 3

SWEP.UseHands = true
SWEP.HideViewmodel = true
SWEP.ViewModelFOV = 90 
SWEP.ViewModel = "models/arccw/masita/weapons/melee/c_apex_melee_rampart.mdl"
SWEP.WorldModel = "models/arccw/masita/rising/praetorian_weapon.mdl"
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
SWEP.MeleeDamage = 30
SWEP.MeleeRange = 75
SWEP.MeleeDamageType = DMG_SHOCK + DMG_AIRBOAT + DMG_GENERIC + DMG_CLUB

SWEP.MeleeHitSound = "melee/new/lifeline/generic_baton_impact_5.ogg"
SWEP.MeleeHitNPCSound = "melee/new/lifeline/generic_baton_impact_3.ogg"
SWEP.MeleeMissSound = "melee/new/lifeline/lifeline_mvmt_baton_doubleswipe_1.ogg"
SWEP.MeleeSwingSound = "melee/new/lifeline/lifeline_mvmt_baton_swipe_4.ogg"

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
SWEP.ActivePos = Vector(0, 1, 2)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.NoHideLeftHandInCustomization = false
SWEP.DefaultElements = {"melee"}
SWEP.AttachmentElements = {
    ["melee"] = {
        VMElements = {
            {
                Model = "models/arccw/masita/rising/praetorian_weapon.mdl",
                Bone = "def_c_base",
                Scale = Vector(0.9, 0.9, 0.9),
                Offset = {
                    pos = Vector(-2.6, 2, 1.5),
                    ang = Angle(0, 0, 90)
                }
            }
        },
        WMElements = {
            {
                Model = "models/arccw/masita/rising/praetorian_weapon.mdl",
                Bone = "ValveBiped.Bip01_R_Hand",
                Scale = Vector(1, 1, 1),
                Offset = {
                    pos = Vector(700, 300, 0),
                    ang = Angle(0, -180, 0)
                }
            },     
        },
    }
}WMOverride = "models/arccw/masita/rising/praetorian_weapon.mdl"

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
    },
    ["holster"] = {
        Source = "putaway",
    },
    ["ready"] = {
        Source = {"draw", "draw2", "draw3"},
    },
    ["bash"] = {
        Source = {"melee_jump","melee_sliding","melee_smack_down","melee_sprinting","melee_swing_down"},
    },
    ["bash2"] = {
        Source = {"melee_swirl","melee_reversal"},
    },
    ["bash_backstab"] = {
        Source = {"melee_crouch"},
    },
    ["bash2_backstab"] = {
        Source = {"melee_crouch"},
    },
    ["enter_inspect"] = {
        Source = "inspect_in",
    },
    ["exit_inspect"] = {
        Source = "inspect_out",
    },
    ["idle_inspect"] = {
        Source = "inspect",
    },
}