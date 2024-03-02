SWEP.Base = "arccw_base"
SWEP.Spawnable = true -- this obviously has to be set to true
SWEP.Category = "[ ArcCW ] Explosives" -- edit this if you like
SWEP.AdminOnly = false

SWEP.PrintName = "RPS-6"
SWEP.TrueName = "RPS-6 Launcher"
SWEP.Trivia_Class = "Rocket Launcher"
SWEP.Trivia_Desc = "A rocket launcher with 4 different payload options; HE, HEAT, Tandem, and Smoke. HE rockets have high splash but low immediate damage. HEAT rounds have good damage and splash. Tandem rounds have very little splash, but massive damage. Smoke rounds do no damage, but create an obscuring smokescreen."
SWEP.Trivia_Manufacturer = "BlasTech Industries"
SWEP.Trivia_Calibre = "Rocket"
SWEP.Trivia_Mechanism = "Single-Action"
SWEP.Trivia_Country = "Russia"
SWEP.Trivia_Year = 1961

SWEP.Slot = 4
SWEP.UseHands = true

SWEP.ViewModel = "models/holdtypes/c_rpg7.mdl"
SWEP.WorldModel = "models/holdtypes/w_rpg7.mdl"
SWEP.WorldModelOffset = {
    pos = Vector(0, 0, 0),
    ang = Angle(0, 0, 0),
    bone = "ValveBiped.Bip01_R_Hand",
    scale = 0.09
}
SWEP.ViewModelFOV = 60
SWEP.HideViewmodel = true

SWEP.IconOverride = "materials/entities/rps6_meeks.png"

SWEP.ShootEntity = "arccw_rocket_heat" -- entity to fire, if any
SWEP.MuzzleVelocity = 100000 -- projectile or phys bullet muzzle velocity
-- IN M/S

SWEP.ChamberSize = 0 -- how many rounds can be chambered.
SWEP.Primary.ClipSize = 1 -- DefaultClip is automatically set.
SWEP.ExtendedClipSize = 1
SWEP.ReducedClipSize = 1

SWEP.Recoil = 2
SWEP.RecoilSide = 0.175
SWEP.RecoilRise = 2

SWEP.Delay = 60 / 600 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemodes = {
    {
        Mode = 1,
    },
    {
        Mode = 0
    }
}

SWEP.NPCWeaponType = "weapon_rpg"
SWEP.NPCWeight = 150

SWEP.AccuracyMOA = 10 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 500 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 500

SWEP.Primary.Ammo = "RPG_Round" -- what ammo type the gun uses
SWEP.MagID = "rpg7" -- the magazine pool this gun draws from

SWEP.ShootVol = 130 -- volume of shoot sound
SWEP.ShootPitch = 100 -- pitch of shoot sound

SWEP.ShootSound = "weapons/rocket launcher/explosive_rocketlauncher_corebass_close_var_03.mp3"
SWEP.DistantShootSound = "weapons/arccw/rpg7/rpg7_dist.wav"

SWEP.MuzzleEffect = "muzzleflash_m79"

SWEP.MuzzleEffectAttachment = 1 -- which attachment to put the muzzle on

SWEP.SightTime = 0.35

SWEP.SpeedMult = 0.875
SWEP.SightedSpeedMult = 0.75

SWEP.BarrelLength = 24

SWEP.BulletBones = { -- the bone that represents bullets in gun/mag
    -- [0] = "bulletchamber",
    -- [1] = "bullet1"
}

SWEP.ProceduralRegularFire = false
SWEP.ProceduralIronFire = false

SWEP.CaseBones = {}

SWEP.IronSightStruct = {
    Pos = Vector(-2, -12, 2),
    Ang = Angle(1.5, 0, 0),
    Magnification = 1.5,
    SwitchToSound = "", -- sound that plays when switching to this sight
}

SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "smg"
SWEP.HoldtypeSights = "rpg"

SWEP.AnimShoot = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL

SWEP.ActivePos = Vector(1, 2, 0)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.SprintPos = Vector(0, 0, 5)
SWEP.SprintAng = Angle(-30, 0, 0)

SWEP.HolsterPos = Vector(1, 4, -14)
SWEP.HolsterAng = Angle(40, 0, 0)

SWEP.BarrelOffsetSighted = Vector(0, 0, 0)
SWEP.BarrelOffsetHip = Vector(2, 0, -2)

SWEP.CustomizePos = Vector(13.824, 2, 0.897)
SWEP.CustomizeAng = Angle(12.149, 40.547, 45)

SWEP.ExtraSightDist = 15

SWEP.DefaultElements = {"rocketlauncher"}

SWEP.AttachmentElements = {
    ["rocketlauncher"] = {
        VMElements = {
            {
                Model = "models/weapons/rocket3/rocket_launcher3.mdl",
                Bone = "Weapon_Main",
                Scale = Vector(0.8, 0.8, 0.8),
                Offset = {
                    pos = Vector(0.2, -2, -6),
                    ang = Angle(0, 0, -90)
                }
            }
        },
        WMElements = {
            {
                Model = "models/weapons/rocket3/rocket_launcher3.mdl",
                Bone = "ValveBiped.Bip01_R_Hand",
                Scale = Vector(1, 1, 1),
                Offset = {
                    pos = Vector(-50, 10, -55),
                    ang = Angle(0, -90, 180)
                }
            }
        },
    },
}

SWEP.Attachments = {
    {
        PrintName = "Optic", -- print name
        DefaultAttName = "Iron Sights",
        WMScale = Vector(11, 11, 11),
        Slot = {"optic", "optic_lp"}, -- what kind of attachments can fit here, can be string or table
        Bone = "Weapon_Main", -- relevant bone any attachments will be mostly referring to
        Offset = {
            vpos = Vector(0.3, -5.9, 4), -- offset that the attachment will be relative to the bone
            vang = Angle(90, 0, -90),
            wpos = Vector(90.36, 10, -110.301),
            wang = Angle(0, 0, 180)
        },
        InstalledEles = {"nors"},
    },
    {
        PrintName = "Underbarrel",
        Slot = {"foregrip", "bipod"},
        WMScale = Vector(11, 11, 11),
        Bone = "Weapon_Main",
        Offset = {
            vpos = Vector(0, -2, 6),
            vang = Angle(90, 0, -90),
            wpos = Vector(140, 10, -55.453),
            wang = Angle(-180.216, 0, 0)
        },
        InstalledEles = {"nogrip"},
    },
    {
        PrintName = "Tactical",
        Slot = "tac",
        Bone = "Weapon_Main",
        WMScale = Vector(11, 11, 11),
        Offset = {
            vpos = Vector(1.6, -3.5, 10),
            vang = Angle(90, 0, 0),
            wpos = Vector(140.625, 30.253, -80.298),
            wang = Angle(0, 0, -90)
        },
    },
    {
        PrintName = "Grip",
        Slot = "grip",
        DefaultAttName = "Standard Grip"
    },
    {
        PrintName = "Ammo Type",
        DefaultAttName = "Default",
        Slot = "ammo_rocket"
    },
    {
        PrintName = "Perk",
        Slot = "perk"
    },
    {
        PrintName = "Charm",
        Slot = "charm",
        FreeSlot = true,
        NoWM = true,
        Bone = "Weapon_Main",
        Offset = {
            vpos = Vector(1.7, -3, 1), -- offset that the attachment will be relative to the bone
            vang = Angle(90, 0, -90),
            wpos = Vector(11, 1.25, -4.5),
            wang = Angle(0, -4.211, 180)
        },
    },
}

SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
        Time = 1,
    },
    ["idle_empty"] = {
        Source = "idle_empty",
        Time = 1,
    },
    ["draw_empty"] = {
        Source = "draw_empty",
        Time = 1.5,
    },
    ["draw"] = {
        Source = "draw",
        Time = 1.5,
    },
    ["fire"] = {
        Source = "fire",
        Time = 0.5,
    },
    ["reload"] = {
        Source = "reload",
        Time = 4,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {20, 26, 40},
        FrameRate = 30,
        LHIK = false,
        SoundTable = {
            {
                s = "insertrocket", -- sound; can be string or table
                p = 100, -- pitch
                v = 75, -- volume
                t = 74 / 60, -- time at which to play relative to Animations.Time
                c = CHAN_ITEM, -- channel to play the sound
            },
            {
                s = "insertrocket2", -- sound; can be string or table
                p = 100, -- pitch
                v = 75, -- volume
                t = 115 / 60, -- time at which to play relative to Animations.Time
                c = CHAN_ITEM, -- channel to play the sound
            },
            {
                s = "rocketclick", -- sound; can be string or table
                p = 100, -- pitch
                v = 75, -- volume
                t = 174 / 60, -- time at which to play relative to Animations.Time
                c = CHAN_ITEM, -- channel to play the sound
            },
        }
    },
}

local path = "weapons/rocket launcher/"

sound.Add({
	name = "insertrocket",
	channel = CHAN_ITEM,
	volume = 1,
	soundlevel = 100,
	pitch = 100,
	sound = path .. "insert.wav"
	})

sound.Add({
	name = "insertrocket2",
	channel = CHAN_ITEM,
	volume = 1,
	soundlevel = 100,
	pitch = 100,
	sound = path .. "insert2.wav"
	})


sound.Add({
	name = 			"rocketclick",
	channel = 		CHAN_ITEM,
	volume = 		1.0,
	sound = path ..	"click.wav"
})
