att.PrintName = "Universal Hitscan Rounds"
att.Icon = Material("interfaz/armas/sw_lazetarget.png", "smooth mips")
att.Description = "Forces physical bullets on supported weaponry types."
att.Desc_Pros = {
"  Tracer Colors can be changed"
}
att.Desc_Cons = {
"  These are physbullets."
}
att.AutoStats = true
att.Slot = {"ammo"}

att.ToggleStats = {
    {
        PrintName = "Regular",
        Override_PhysTracerProfile = 0,
		Override_AlwaysPhysBullet = true
    },
	{
        PrintName = "Red",
        Override_PhysTracerProfile = 1,
		Override_AlwaysPhysBullet = true
    },
    {
        PrintName = "Blue",
        Override_PhysTracerProfile = 3,
		Override_AlwaysPhysBullet = true
    },
	{
        PrintName = "Cyan",
        Override_PhysTracerProfile = 6,
		Override_AlwaysPhysBullet = true
    },
	{
        PrintName = "Green",
        Override_PhysTracerProfile = 2,
		Override_AlwaysPhysBullet = true
    },
    {
        PrintName = "Yellow",
        Override_PhysTracerProfile = 4,
		Override_AlwaysPhysBullet = true
    },
    {
        PrintName = "Violet",
        Override_PhysTracerProfile = 5,
		Override_AlwaysPhysBullet = true
    },
}