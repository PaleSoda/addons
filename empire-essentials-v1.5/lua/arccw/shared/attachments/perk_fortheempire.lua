att.PrintName = "For the Empire!"
att.Icon = Material("entities/perks/fortheempire.png")
att.Description = "The Empire gives you strength. Your desire to destroy the rebel scum strengthens you. You gain some health from killing enemies in melee."
att.Desc_Pros = {
    "+ Health on bash"
}
att.Desc_Cons = {}
att.Slot = "perk"

att.NotForNPC = true
att.AutoStats = true
att.Mult_MeleeDamage = 1.35

att.Hook_PostBash = function(wep, data)
    local ent = data.tr.Entity
    local dir = data.tr.Normal:GetNormalized()

    if IsValid(ent) then
        if (ent.ArcCW_StreetJustice or 0) < CurTime() and (ent:IsNPC() or ent:IsPlayer()) then
			wep.Owner:SetHealth(math.Clamp(wep.Owner:Health() + (20), 0, wep.Owner:GetMaxHealth()))
			end
    end
end