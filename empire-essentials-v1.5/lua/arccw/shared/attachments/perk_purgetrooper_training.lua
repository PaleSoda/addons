att.PrintName = "Purge Trooper Training"
att.Icon = Material("entities/perks/purge_training.png")
att.Description = "Purge Troopers, also known as Purge Stormtroopers, were a specialized variant of stormtroopers utilized by the mysterious Inquisitorius of the Galactic Empire as special forces and expendable death squads. These soldiers were assigned to hunt the remnants of the Jedi Order, being activated after the Clone Wars and subsequent termination of the cloning operation on Kamino. The first Purge Troopers were actually the last generation of clone troopers produced from the bounty hunter Jango Fett's template. As with their precursors in the Grand Army of the Galactic Republic, those early Purge Troopers were programmed to obey Order 66, making them hostile against all Jedi. They were resistant to most Jedi mind tricks, only when a Jedi had the power of a Master, the Purge Troopers would be affected by it. They were eventually supplemented and replaced by non-clone human recruits drawn from the Stormtrooper Corps. They were few in number and kept out of the public eye, with most citizens unaware they even existed."
att.Desc_Pros = {}
att.Desc_Cons = {}

att.AutoStats = true
att.Slot = "perk"

att.Mult_SpeedMult = 2.1
att.Mult_SightedSpeedMult = 2.1
att.Mult_MeleeDamage = 6.7
att.Add_MeleeRange = 5.3
att.NotForNPC = true

att.Hook_PostBash = function(wep, data)
    local ent = data.tr.Entity
    local dir = data.tr.Normal:GetNormalized()

    if IsValid(ent) then
        if (ent.ArcCW_StreetJustice or 0) < CurTime() and (ent:IsNPC() or ent:IsPlayer()) then
			wep.Owner:SetHealth(math.Clamp(wep.Owner:Health() + (40), 0, wep.Owner:GetMaxHealth()))
			end
    end
end