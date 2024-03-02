att.PrintName = "Smokescreen"
att.Icon = Material("entities/acwatt_ammo_rpg7_smoke.png")
att.Description = "Smoke rockets that produce a wide smokescreen on impact. Also does light damage."
att.Desc_Pros = {
    "Smoke Screen"
}
att.Desc_Cons = {
    "Splash Damage",
}
att.AutoStats = true
att.Slot = "ammo_rocket"

att.Mult_SightTime = 0.9
att.Mult_MoveSpeed = 1.15

att.Override_ShootEntity = "arccw_rocket_smoke"