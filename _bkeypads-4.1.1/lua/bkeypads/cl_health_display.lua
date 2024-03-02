local scale_3d2d = 0.02
local barPadding = 10
function bKeypads:DrawHealth(ent, w, h)
	if ent:Health() <= 0 then return end

	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(-w / 2, -h, w, h)

	ent.m_fHealthFrac = Lerp(FrameTime() * 15, ent.m_fHealthFrac or 1, math.max(math.min(ent:Health() / ent:GetMaxHealth(), 1), 0))
	local healthFrac = math.Round(ent.m_fHealthFrac, 3)

	surface.SetDrawColor((1 - healthFrac) * 255, healthFrac * 255, 0)
	surface.DrawRect((-w / 2) + barPadding, -h + barPadding, (w - (barPadding * 2)) * healthFrac, h - (barPadding * 2))

	if ent.GetMaxShield and ent:GetMaxShield() > 0 then
		ent.ShieldFrac = Lerp(FrameTime() * 15, ent.ShieldFrac or 0, math.max(math.min(ent:GetShield() / math.max(ent.m_iMaxShield, ent:GetMaxHealth()), 1), 0))
		local shieldFrac = math.Round(ent.ShieldFrac, 3)

		surface.SetDrawColor(bKeypads.COLOR.GMODBLUE)
		surface.DrawRect((-w / 2) + barPadding, -h + barPadding, (w - (barPadding * 2)) * shieldFrac, h - (barPadding * 2))
	end

	return (-50 * 2 * scale_3d2d) - 1.5
end